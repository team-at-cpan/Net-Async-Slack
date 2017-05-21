package Net::Async::Slack::RTM;

use strict;
use warnings;

# VERSION

use parent qw(IO::Async::Notifier);

=head1 NAME

Net::Async::Slack::RTM - realtime messaging support for L<https://slack.com>

=head1 DESCRIPTION

This is a basic wrapper for Slack's RTM features.

=cut

use Net::Async::WebSocket::Client;

=head1 METHODS

=head2 connect

=cut

sub connect {
    my ($self, %args) = @_;
    my $uri = $self->wss_uri or die 'no websocket URI available';
    $self->add_child(
        $self->{ws} = Net::Async::WebSocket::Client->new(
            on_raw_frame => $self->curry::weak::on_raw_frame,
            on_frame     => sub { },
        )
    );
    $self->{ws}->connect(
        url        => $uri,
        host       => $uri->host,
        ($uri->scheme eq 'wss'
        ? (
            service      => 443,
            extensions   => [ qw(SSL) ],
            SSL_hostname => $uri->host,
        ) : (
            service    => 80,
        ))
    )
}


{
my %types = reverse %Protocol::WebSocket::Frame::TYPES;
sub on_raw_frame {
	my ($self, $ws, $frame, $bytes) = @_;
    my $text = Encode::decode_utf8($bytes);
    $log->debugf("Have frame opcode %d type %s with bytes [%s]", $frame->opcode, $types{$frame->opcode}, $text);

    # Empty frame is used for PING, send a response back
    if($frame->opcode == 1) {
        if(!length($bytes)) {
            $ws->send_frame('');
        } else {
            $log->tracef("<< %s", $text);
            try {
                my $data = $json->decode($text);
                if(my $chan = $data->{idModelChannel}) {
                    $log->tracef("Notification for [%s] - %s", $chan, $data);
                    $self->{update_channel}{$chan}->emit($data->{notify});
                } else {
                    $log->warnf("No idea what %s is", $data);
                }
            } catch {
                $log->errorf("Exception in websocket raw frame handling: %s (original text %s)", $@, $text);
            }
        }
    }
}
}

sub slack { shift->{slack} }
sub wss_uri { shift->{wss_uri} }

sub configure {
    my ($self, %args) = @_;
    for my $k (qw(slack wss_uri)) {
        $self->{$k} = delete $args{$k} if exists $args{$k};
    }
    $self->next::method(%args);
}

1;

