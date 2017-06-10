package Net::Async::Slack::Event::SubteamUpdated;

use strict;
use warnings;

use Net::Async::Slack::EventType;

=head1 NAME

Net::Async::Slack::Event::SubteamUpdated - An existing User Group has been updated or its members changed

=head1 DESCRIPTION

Example input data:

    usergroups:read

=cut

sub type { 'subteam_updated' }

1;

