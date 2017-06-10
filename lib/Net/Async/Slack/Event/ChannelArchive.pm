package Net::Async::Slack::Event::ChannelArchive;

use strict;
use warnings;

# VERSION

use parent qw(Net::Async::Slack::Event::Channel);

use Net::Async::Slack::EventType;

=head1 DESCRIPTION

{
"type": "channel_archive",
"channel": "C024BE91L",
"user": "U024BE7LH"
}

=cut

sub type { 'channel_archive' }

1;

