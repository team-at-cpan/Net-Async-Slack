package Net::Async::Slack::Event::ReactionAdded;

use strict;
use warnings;

use Net::Async::Slack::EventType;

=head1 NAME

Net::Async::Slack::Event::ReactionAdded - A team member has added an emoji reaction to an item

=head1 DESCRIPTION

Example input data:

    reactions:read

=cut

sub type { 'reaction_added' }

1;

