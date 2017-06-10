package Net::Async::Slack::Event::MemberJoinedChannel;

use strict;
use warnings;

use Net::Async::Slack::EventType;

=head1 NAME

Net::Async::Slack::Event::MemberJoinedChannel - A user joined a public or private channel

=head1 DESCRIPTION

Example input data:

    channels:read

=cut

sub type { 'member_joined_channel' }

1;

