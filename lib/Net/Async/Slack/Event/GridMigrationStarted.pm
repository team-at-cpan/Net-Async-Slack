package Net::Async::Slack::Event::GridMigrationStarted;

use strict;
use warnings;

our $VERSION = '0.015'; # VERSION

use Net::Async::Slack::EventType;

=head1 NAME

Net::Async::Slack::Event::GridMigrationStarted - An enterprise grid migration has started on this workspace.

=head1 DESCRIPTION

Example input data:

    {
        "token": "XXYYZZ",
        "team_id": "TXXXXXXXX",
        "api_app_id": "AXXXXXXXXX",
        "event": {
            "type": "grid_migration_started",
            "enterprise_id": "EXXXXXXXX"
        },
        "type": "event_callback",
        "event_id": "EvXXXXXXXX",
        "event_time": 1234567890
    }


=cut

sub type { 'grid_migration_started' }

1;

__END__

=head1 AUTHOR

Tom Molesworth <TEAM@cpan.org>

=head1 LICENSE

Copyright Tom Molesworth 2016-2024. Licensed under the same terms as Perl itself.
