package Net::Async::Slack::Event::ChannelArchive;

use strict;
use warnings;

our $VERSION = '0.015'; # VERSION

use parent qw(Net::Async::Slack::Event::Channel);

use Net::Async::Slack::EventType;

=head1 DESCRIPTION

{
"type": "channel_archive",
"channel": "C024BE91L",
"user": "U024BE7LH"
}

=cut

sub type { 'channel_archive' }

1;

__END__

=head1 AUTHOR

Tom Molesworth <TEAM@cpan.org>

=head1 LICENSE

Copyright Tom Molesworth 2016-2024. Licensed under the same terms as Perl itself.
