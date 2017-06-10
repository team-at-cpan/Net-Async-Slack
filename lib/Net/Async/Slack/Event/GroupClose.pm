package Net::Async::Slack::Event::GroupClose;

use strict;
use warnings;

use Net::Async::Slack::EventType;

=head1 NAME

Net::Async::Slack::Event::GroupClose - You closed a private channel

=head1 DESCRIPTION

Example input data:

    groups:read

=cut

sub type { 'group_close' }

1;

