package Net::Async::Slack;
# ABSTRACT: Slack realtime messaging API support for IO::Async

use strict;
use warnings;

our $VERSION = '0.001';

use parent qw(IO::Async::Notifier);

=head1 NAME

Net::Async::Slack - support for the L<https://slack.com> APIs with L<IO::Async>

=head1 SYNOPSIS

 use IO::Async::Loop;
 use Net::Async::Slack;
 my $loop = IO::Async::Loop->new;
 $loop->add(
  my $gh = Net::Async::Slack->new(
   token => '...',
  )
 );

=head1 DESCRIPTION

This is a basic wrapper for Slack's API.

=cut

no indirect;
use mro;

use Future;
use Dir::Self;
use URI;
use URI::QueryParam;
use URI::Template;
use JSON::MaybeXS;
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

my $json = JSON::MaybeXS->new;

=head1 METHODS

=cut

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
        $json->decode($path->slurp_utf8)
    };
}

=head2 endpoint

Processes the given endpoint as a template, using the named parameters
passed to the method.

=cut

sub endpoint {
	my ($self, $endpoint, %args) = @_;
	URI::Template->new($self->endpoints->{$endpoint . '_url'})->process(%args);
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
        scope     => 'bot',
        state     => $state,
        %args,
    );
    $log->debugf("OAuth URI endpoint is %s", "$uri");
    $code->($uri)->then(sub {
            Future->done;
    })
}

=head2 rtm

Establishes a connection to the Slack RTM websocket API, and
resolves to a L<Net::Async::Slack::RTM> instance.

=cut

sub rtm {
    my ($self, %args) = @_;
    $self->{rtm} //= $self->http_get(
		uri => URI->new(
            $self->endpoint(
                'rtm_connect',
                token => $self->token
            )
        )
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

=head2 token

Travis token.

=cut

sub token { shift->{token} }

=head2 http

Returns the HTTP instance used for communicating with Travis.

Currently autocreates a L<Net::Async::HTTP> instance.

=cut

sub http {
	my ($self) = @_;
	$self->{http} ||= do {
		require Net::Async::HTTP;
		$self->add_child(
			my $ua = Net::Async::HTTP->new(
				fail_on_error            => 1,
				max_connections_per_host => 2,
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
    # my %auth = $self->auth_info;

    #if(my $hdr = delete $auth{headers}) {
    #	$args{headers}{$_} //= $hdr->{$_} for keys %$hdr
    #}
    #$args{headers}{Accept} //= $self->mime_type;
    #$args{$_} //= $auth{$_} for keys %auth;

    my $uri = delete $args{uri};
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
            return Future->done($json->decode($resp->decoded_content))
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


sub configure {
    my ($self, %args) = @_;
    for my $k (qw(client_id token)) {
        $self->{$k} = delete $args{$k} if exists $args{$k};
    }
    $self->next::method(%args);
}

1;

=head1 AUTHOR

Tom Molesworth <TEAM@cpan.org>

=head1 LICENSE

Copyright Tom Molesworth 2016-2017. Licensed under the same terms as Perl itself.

