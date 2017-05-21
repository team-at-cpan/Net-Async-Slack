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

use Future;
use Dir::Self;
use URI;
use URI::QueryParam;
use URI::Template;
use JSON::MaybeXS;
use Time::Moment;
use Syntax::Keyword::Try;

use Cache::LRU;

use Ryu::Async;
use Ryu::Observable;
use Net::Async::WebSocket::Client;

use Log::Any qw($log);

use Net::Async::OAuth::Client;

use Net::Async::Slack::User;

my $json = JSON::MaybeXS->new;

=head1 METHODS

=cut

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

=head2 oauth_request

=cut

sub oauth_request {
    use Bytes::Random::Secure qw(random_string_from);
    use namespace::clean qw(random_string_from);
    my ($self, $code) = @_;

    my $state = random_string_from('abcdefghjklmnpqrstvwxyz0123456789', 32);

    my $uri = $self->endpoint(
        'oauth',
        client_id => $self->client_id,
        scope     => 'bot',
        state     => $state,
    );
    my $req = HTTP::Request->new(POST => "$uri");
    $req->protocol('HTTP/1.1');

    # $req->header(Authorization => 'Bearer ' . $self->req);
    $self->oauth->configure(
        token => '',
        token_secret => '',
    );
    my $hdr = $self->oauth->authorization_header(
        method => 'POST',
        uri    => $uri,
    );
    $req->header('Authorization' => $hdr);
    $log->tracef("Resulting auth header for userstream was %s", $hdr);

    $req->header('Host' => $uri->host);
    # $req->header('User-Agent' => 'OAuth gem v0.4.4');
    $req->header('Connection' => 'close');
    $req->header('Accept' => '*/*');
    $self->http->do_request(
        request => $req,
    )->then(sub {
        my ($resp) = @_;
        $log->debugf("RequestToken response was %s", $resp->as_string("\n"));
        my $rslt = URI->new('http://localhost?' . $resp->decoded_content)->query_form_hash;
        $log->debugf("Extracted token [%s]", $rslt->{oauth_token});
        $self->oauth->configure(token => $rslt->{oauth_token});
        $log->debugf("Extracted secret [%s]", $rslt->{oauth_token_secret});
        $self->oauth->configure(token_secret => $rslt->{oauth_token_secret});

        my $auth_uri = URI->new(
            'https://trello.com/1/OAuthAuthorizeToken'
        );
        $auth_uri->query_param(oauth_token => $rslt->{oauth_token});
        $auth_uri->query_param(scope       => 'read,write');
        $auth_uri->query_param(name        => 'trelloctl');
        $auth_uri->query_param(expiration  => 'never');
        $code->($auth_uri);
    }, sub {
        $log->errorf("Failed to do oauth lookup - %s", join ',', @_);
        die @_;
    })->then(sub {
        my ($verify) = @_;
        my $uri = URI->new('https://trello.com/1/OAuthGetAccessToken');
        my $req = HTTP::Request->new(POST => "$uri");
        $req->protocol('HTTP/1.1');

        my $hdr = $self->oauth->authorization_header(
            method => 'POST',
            uri    => $uri,
            parameters => {
                oauth_verifier => $verify
            }
        );
        $req->header('Authorization' => $hdr);
        $log->tracef("Resulting auth header was %s", $hdr);

        $req->header('Host' => $uri->host);
        $req->header('Connection' => 'close');
        $req->header('Accept' => '*/*');
        $self->http->do_request(
            request => $req,
        )
    })->then(sub {
        my ($resp) = @_;
        $log->tracef("GetAccessToken response was %s", $resp->as_string("\n"));
        my $rslt = URI->new('http://localhost?' . $resp->decoded_content)->query_form_hash;
        $log->tracef("Extracted token [%s]", $rslt->{oauth_token});
        $self->configure(token => $rslt->{oauth_token});
        $log->tracef("Extracted secret [%s]", $rslt->{oauth_token_secret});
        $self->configure(token_secret => $rslt->{oauth_token_secret});
        Future->done({
            token        => $rslt->{oauth_token},
            token_secret => $rslt->{oauth_token_secret},
        })
    })
}
1;

=head1 AUTHOR

Tom Molesworth <TEAM@cpan.org>

=head1 LICENSE

Copyright Tom Molesworth 2016-2017. Licensed under the same terms as Perl itself.

