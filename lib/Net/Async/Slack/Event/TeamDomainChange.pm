package Net::Async::Slack::Event::TeamDomainChange;

use strict;
use warnings;

use Net::Async::Slack::EventType;

=head1 NAME

Net::Async::Slack::Event::TeamDomainChange - The team domain has changed

=head1 DESCRIPTION

Example input data:

    team:read

=cut

sub type { 'team_domain_change' }

1;

