package Net::Async::Slack::Event::GroupJoined;

use strict;
use warnings;

use Net::Async::Slack::EventType;

=head1 NAME

Net::Async::Slack::Event::GroupJoined - You joined a private channel

=head1 DESCRIPTION

Example input data:

    {
        "type": "group_joined",
        "channel": { ... }
    }


=cut

sub type { 'group_joined' }

1;

