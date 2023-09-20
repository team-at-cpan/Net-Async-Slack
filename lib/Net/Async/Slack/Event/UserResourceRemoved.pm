package Net::Async::Slack::Event::UserResourceRemoved;

use strict;
use warnings;

our $VERSION = '0.013'; # VERSION

use Net::Async::Slack::EventType;

=head1 NAME

Net::Async::Slack::Event::UserResourceRemoved - User resource was removed from your app

=head1 DESCRIPTION

Example input data:

    {
        "token": "XXYYZZ",
        "team_id": "TXXXXXXXX",
        "api_app_id": "AXXXXXXXXX",
        "event": {
            "type": "user_resource_removed",
            "user": "WXXXXXXXX",
            "trigger_id": "27082968880.6048553856.5eb9c671f75c636135fdb6bb9e87b606"
        },
        "type": "event_callback",
        "authed_teams": [],
        "event_id": "EvXXXXXXXX",
        "event_time": 1234567890
    }


=cut

sub type { 'user_resource_removed' }

1;

__END__

=head1 AUTHOR

Tom Molesworth <TEAM@cpan.org>

=head1 LICENSE

Copyright Tom Molesworth 2016-2023. Licensed under the same terms as Perl itself.
