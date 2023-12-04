package Net::Async::Slack::Event::ChannelHistoryChanged;

use strict;
use warnings;

our $VERSION = '0.014'; # VERSION

use Net::Async::Slack::EventType;

=head1 NAME

Net::Async::Slack::Event::ChannelHistoryChanged - Bulk updates were made to a channel's history

=head1 DESCRIPTION

Example input data:

    channels:history

=cut

sub type { 'channel_history_changed' }

1;

__END__

=head1 AUTHOR

Tom Molesworth <TEAM@cpan.org>

=head1 LICENSE

Copyright Tom Molesworth 2016-2023. Licensed under the same terms as Perl itself.
