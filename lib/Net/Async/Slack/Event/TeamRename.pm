package Net::Async::Slack::Event::TeamRename;

use strict;
use warnings;

# VERSION

use Net::Async::Slack::EventType;

=head1 NAME

Net::Async::Slack::Event::TeamRename - The workspace name has changed

=head1 DESCRIPTION

Example input data:

    team:read

=cut

sub type { 'team_rename' }

1;

__END__

=head1 AUTHOR

Tom Molesworth <TEAM@cpan.org>

=head1 LICENSE

Copyright Tom Molesworth 2016-2024. Licensed under the same terms as Perl itself.
