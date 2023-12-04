package Net::Async::Slack;
# ABSTRACT: Slack realtime messaging API support for IO::Async

use strict;
use warnings;

our $VERSION = '0.014';

use parent qw(IO::Async::Notifier Net::Async::Slack::Commands);

=head1 NAME

Net::Async::Slack - support for the L<https://slack.com> APIs with L<IO::Async>

=head1 SYNOPSIS

 use IO::Async::Loop;
 use Net::Async::Slack;
 my $loop = IO::Async::Loop->new;
 $loop->add(
  my $slack = Net::Async::Slack->new(
   token => '...',
  )
 );

=head1 DESCRIPTION

This is a basic wrapper for Slack's API. It's an early version, the module API is likely
to change somewhat over time.

See the C<< examples/ >> directory for usage.

=cut

no indirect;
use mro;

use Future;
use Future::AsyncAwait;
use Dir::Self;
use URI;
use URI::QueryParam;
use URI::Template;
use JSON::MaybeUTF8 qw(:v1);
use Time::Moment;
use Syntax::Keyword::Try;
use File::ShareDir ();
use Path::Tiny ();

use Cache::LRU;

use Ryu::Async;
use Ryu::Observable;
use Net::Async::WebSocket::Client;

use Log::Any qw($log);

use Net::Async::OAuth::Client;

use Net::Async::Slack::RTM;
use Net::Async::Slack::Socket;
use Net::Async::Slack::Message;

=head1 METHODS

=cut

=head2 rtm

Establishes a connection to the Slack RTM websocket API, and
resolves to a L<Net::Async::Slack::RTM> instance.

=cut

sub rtm {
    my ($self, %args) = @_;
    warn "RTM is deprecated and will no longer be supported by slack.com, please use socket mode instead: https://slack.com/apis/connections/socket";
    $log->tracef('Endpoint is %s', $self->endpoint(
        'rtm_connect',
    ));
    $self->{rtm} //= $self->http_get(
        uri => $self->endpoint(
            'rtm_connect',
        ),
    )->then(sub {
        my $result = shift;
        return Future->done(URI->new($result->{url})) if exists $result->{url};
        return Future->fail('invalid URL');
    })->then(sub {
        my ($uri) = @_;
        $self->add_child(
            my $rtm = Net::Async::Slack::RTM->new(
                slack => $self,
                wss_uri => $uri,
            )
        );
        $rtm->connect->transform(done => sub { $rtm })
    })
}

async sub socket_mode {
    my ($self, %args) = @_;
    my ($uri) = await $self->socket;
    $self->add_child(
        my $socket = Net::Async::Slack::Socket->new(
            slack => $self,
            wss_uri => $uri,
        )
    );
    await $socket->connect;
    return $socket;
}

=head2 send_message

Send a message to a user or channel.

Supports the following named parameters:

=over 4

=item * channel - who to send the message to, can be a channel ID or C<< #channel >> name, or user ID

=item * text - the message, see L<https://api.slack.com/docs/message-formatting> for details

=item * attachments - more advanced messages, see L<https://api.slack.com/docs/message-attachments>

=item * parse - whether to parse content and convert things like links

=back

and the following named boolean parameters:

=over 4

=item * link_names - convert C<< @user >> and C<< #channel >> to links

=item * unfurl_links - show preview for URLs

=item * unfurl_media - show preview for things that look like media links

=item * as_user - send as user

=item * reply_broadcast - send to all users when replying to a thread

=back

Returns a L<Future>, although the content of the response is subject to change.

=cut

async sub send_message {
    my ($self, %args) = @_;
    die 'You need to pass either text or attachments' unless $args{text} || $args{attachments};
    my @content;
    push @content, token => $self->token;
    push @content, channel => $args{channel} || die 'need a channel';
    push @content, text => $args{text} if defined $args{text};
    push @content, attachments => encode_json_text($args{attachments}) if $args{attachments};
    push @content, blocks => encode_json_text($args{blocks}) if $args{blocks};
    push @content, $_ => $args{$_} for grep exists $args{$_}, qw(parse link_names unfurl_links unfurl_media as_user reply_broadcast thread_ts);
    my ($data) = await $self->http_post(
        $self->endpoint(
            'chat_post_message',
        ),
        \@content,
    );
    Future::Exception->throw('send failed', slack => $data) unless $data->{ok};
    return Net::Async::Slack::Message->new(
        slack => $self,
        channel => $data->{channel},
        thread_ts => $data->{ts},
    );
}

=head2 files_upload

Upload file(s) to a channel or thread.

Supports the following named parameters:

=over 4

=item * channel - who to send the message to, can be a channel ID or C<< #channel >> name, or user ID

=item * text - the message, see L<https://api.slack.com/docs/message-formatting> for details

=item * attachments - more advanced messages, see L<https://api.slack.com/docs/message-attachments>

=item * parse - whether to parse content and convert things like links

=back

and the following named boolean parameters:

=over 4

=item * link_names - convert C<< @user >> and C<< #channel >> to links

=item * unfurl_links - show preview for URLs

=item * unfurl_media - show preview for things that look like media links

=item * as_user - send as user

=item * reply_broadcast - send to all users when replying to a thread

=back

Returns a L<Future>, although the content of the response is subject to change.

=cut

async sub files_upload {
    my ($self, %args) = @_;
    die 'You need to pass file name and content' unless length($args{filename} // '') and defined($args{content});
    my @content;
    push @content, channels => $args{channel} || die 'need a channel';
    push @content, initial_comment => $args{text} if defined $args{text};
    push @content, $_ => $args{$_} for grep exists $args{$_}, qw(filetype thread_ts title);
    push @content, file => [ undef, $args{filename}, Content => $args{content} ];
    my ($data) = await $self->http_post(
        $self->endpoint(
            'files_upload',
        ),
        \@content,
        content_type => 'form-data',
    );
    Future::Exception->throw('send failed', slack => $data) unless $data->{ok};
    return $data;
}

=head2 conversations_info

Provide information about a channel.

Takes the following named parameters:

=over 4

=item * C<channel> - the channel ID to look up

=back

and returns a L<Future> which will resolve to a hashref containing
C<< { channel => { name => '...' } } >>.

=cut

sub conversations_info {
    my ($self, %args) = @_;
    my @content;
    push @content, token => $self->token;
    push @content, channel => $args{channel} || die 'need a channel';
    return $self->http_post(
        $self->endpoint(
            'conversations_info',
        ),
        \@content,
    )
}

sub conversations_invite {
    my ($self, %args) = @_;
    my $chan = $args{channel} or die 'need a channel';
    my @users = ref($args{users}) ? $args{users}->@* : $args{users};
    return $self->http_post(
        $self->endpoint(
            'conversations_invite',
        ),
        {
            channel => $chan,
            users => join(',', @users),
        }
    )
}

async sub users_list {
    my ($self, %args) = @_;
    return await $self->http_get_paged(
        key => 'members',
        uri => $self->endpoint(
            'users_list',
            %args
        ),
    )
}
async sub conversations_list {
    my ($self, %args) = @_;
    return await $self->http_get(
        uri => $self->endpoint(
            'conversations_list',
            %args
        ),
    )
}
async sub conversations_history {
    my ($self, %args) = @_;
    return await $self->http_get(
        uri => $self->endpoint(
            'conversations_history',
            %args
        ),
    )
}

=head2 join_channel

Attempt to join the given channel.

Takes the following named parameters:

=over 4

=item * C<channel> - the channel ID or name to join

=back

=cut

sub join_channel {
    my ($self, %args) = @_;
    die 'You need to pass a channel name' unless $args{channel};
    my @content;
    push @content, token => $self->token;
    push @content, channel => $args{channel};
    $self->http_post(
        $self->endpoint(
            'conversations_join',
        ),
        \@content,
    )
}

async sub users_profile_get {
    my ($self, %args) = @_;
    return await $self->http_get(
        uri => $self->endpoint(
            'users_profile_get',
            %args
        ),
    )
}

async sub workflows_update_step {
    my ($self, %args) = @_;
    return await $self->http_post(
        $self->endpoint(
            'workflows_update_step',
        ),
        \%args,
    )
}

=head1 METHODS - Internal

=head2 endpoints

Returns the hashref of API endpoints, loading them on first call from the C<share/endpoints.json> file.

=cut

sub endpoints {
    my ($self) = @_;
    $self->{endpoints} ||= do {
        my $path = Path::Tiny::path(__DIR__)->parent(3)->child('share/endpoints.json');
        $path = Path::Tiny::path(
            File::ShareDir::dist_file(
                'Net-Async-Slack',
                'endpoints.json'
            )
        ) unless $path->exists;
        $log->tracef('Loading endpoints from %s', $path);
        decode_json_text($path->slurp_utf8)
    };
}

sub slack_host { shift->{slack_host} }

=head2 endpoint

Processes the given endpoint as a template, using the named parameters
passed to the method.

=cut

sub endpoint {
    my ($self, $endpoint, %args) = @_;
    my $uri = URI::Template->new($self->endpoints->{$endpoint})->process(%args);
    $uri->host($self->slack_host) if $self->slack_host;
    $uri
}

sub oauth {
    my ($self) = @_;
    $self->{oauth} //= Net::Async::OAuth::Client->new(
        realm           => 'Slack',
        consumer_key    => $self->key,
        consumer_secret => $self->secret,
        token           => $self->token,
        token_secret    => $self->token_secret,
    )
}

sub client_id { shift->{client_id} }

=head2 oauth_request

=cut

sub oauth_request {
    use Bytes::Random::Secure qw(random_string_from);
    use namespace::clean qw(random_string_from);
    my ($self, $code, %args) = @_;

    my $state = random_string_from('abcdefghjklmnpqrstvwxyz0123456789', 32);

    my $uri = $self->endpoint(
        'oauth',
        client_id => $self->client_id,
        scope     => 'bot,channels:write',
        state     => $state,
        %args,
    );
    $log->debugf("OAuth URI endpoint is %s", "$uri");
    $code->($uri)->then(sub {
            Future->done;
    })
}

=head2 token

API token.

=cut

sub token { shift->{token} }

sub app_token { shift->{app_token} }

=head2 http

Returns the HTTP instance used for communicating with the API.

Currently autocreates a L<Net::Async::HTTP> instance.

=cut

sub http {
    my ($self) = @_;
    $self->{http} ||= do {
        require Net::Async::HTTP;
        $self->add_child(
            my $ua = Net::Async::HTTP->new(
                fail_on_error            => 1,
                close_after_request      => 0,
                max_connections_per_host => 4,
                pipeline                 => 1,
                max_in_flight            => 8,
                decode_content           => 1,
                timeout                  => 30,
                user_agent               => 'Mozilla/4.0 (perl; https://metacpan.org/pod/Net::Async::Slack; TEAM@cpan.org)',
            )
        );
        $ua
    }
}

=head2 http_get

Issues an HTTP GET request.

=cut

sub http_get {
    my ($self, %args) = @_;

    my $uri = delete $args{uri};
    $args{headers} ||= $self->auth_headers;
    $log->tracef("GET %s { %s }", "$uri", \%args);
    $self->http->GET(
        $uri,
        %args
    )->then(sub {
        my ($resp) = @_;
        return { } if $resp->code == 204;
        return { } if 3 == ($resp->code / 100);
        try {
            $log->tracef('HTTP response for %s was %s', "$uri", $resp->as_string("\n"));
            return Future->done(decode_json_utf8($resp->content))
        } catch {
            $log->errorf("JSON decoding error %s from HTTP response %s", $@, $resp->as_string("\n"));
            return Future->fail($@ => json => $resp);
        }
    })->else(sub {
        my ($err, $src, $resp, $req) = @_;
        $src //= '';
        if($src eq 'http') {
            $log->errorf("HTTP error %s, request was %s with response %s", $err, $req->as_string("\n"), $resp->as_string("\n"));
        } else {
            $log->errorf("Other failure (%s): %s", $src // 'unknown', $err);
        }
        Future->fail(@_);
    })
}

async sub http_get_paged {
    my ($self, %args) = @_;
    my $key = delete $args{key}
        or die 'need a hash key to find the results array in the response';
    my $uri = delete $args{uri};
    $uri = URI->new($uri) unless ref($uri);
    $uri->query_param(limit => 500) unless $uri->query_param('limit');
    my $data;
    my $found;
    my $offset;
    do {
        my $res = await $self->http_get(uri => $uri, %args);
        die $res unless $res->{ok};
        $offset = $res->{offset};
        $uri->query_param(offset => $offset);
        $found = 0 + $res->{$key}->@*;
        if($data) {
            push $data->@*, $res->{$key}->@*;
        } else {
            $data = $res->{$key};
        }
    } while $found and $offset;
    return $data;
}

sub auth_headers {
    my ($self) = @_;
    return {} unless $self->token;
    return {
        Authorization => 'Bearer ' . $self->token
    }
}

=head2 http_post

Issues an HTTP POST request.

=cut

sub http_post {
    my ($self, $uri, $content, %args) = @_;

    $log->tracef("POST %s { %s } <= %s", "$uri", \%args, $content);

    $args{headers} ||= $self->auth_headers;
    if(ref $content eq 'HASH') {
        $content = encode_json_utf8($content);
        $args{content_type} = 'application/json; charset=utf-8';
    }
    $self->http->POST(
        $uri,
        $content,
        %args,
    )->then(sub {
        my ($resp) = @_;
        return { } if $resp->code == 204;
        return { } if 3 == ($resp->code / 100);
        try {
            $log->tracef('HTTP response for %s was %s', "$uri", $resp->as_string("\n"));
            return Future->done(decode_json_utf8($resp->content))
        } catch {
            $log->errorf("JSON decoding error %s from HTTP response %s", $@, $resp->as_string("\n"));
            return Future->fail($@ => json => $resp);
        }
    })->else(sub {
        my ($err, $src, $resp, $req) = @_;
        $src //= '';
        if($src eq 'http') {
            $log->errorf("HTTP error %s, request was %s with response %s", $err, $req->as_string("\n"), $resp->as_string("\n"));
        } else {
            $log->errorf("Other failure (%s): %s", $src // 'unknown', $err);
        }
        Future->fail(@_);
    })
}

async sub socket {
    my ($self) = @_;
    my $target_uri = do {
        my $uri = $self->endpoint(
            'apps_connections_open',
        ) or die 'no endpoint';
        my $res = await $self->http_post(
            $uri,
            [ ],
            headers => {
                Authorization => 'Bearer ' . $self->app_token
            }
        );
        die 'failed to obtain socket-mode URL' unless $res->{ok};
        URI->new($res->{url});
    };
    $target_uri->query_param(debug_reconnects => 'true') if $self->{debug};
    return $target_uri;
}

sub configure {
    my ($self, %args) = @_;
    for my $k (qw(client_id token app_token slack_host debug)) {
        $self->{$k} = delete $args{$k} if exists $args{$k};
    }
    $self->next::method(%args);
}

1;

=head1 SEE ALSO

=over 4

=item * L<AnyEvent::SlackRTM> - low-level API wrapper around RTM

=item * L<Mojo::SlackRTM> - another RTM-specific wrapper, this time based on Mojolicious

=item * L<Slack::RTM::Bot> - more RTM support, this time via LWP and a subprocess/thread for handling the websocket part

=item * L<WebService::Slack::WebApi> - Furl-based wrapper around the REST API

=item * L<AnyEvent::SlackBot> - another AnyEvent RTM implementation

=back

=head1 AUTHOR

Tom Molesworth <TEAM@cpan.org>

=head1 LICENSE

Copyright Tom Molesworth 2016-2023. Licensed under the same terms as Perl itself.

