package Net::Async::Slack::Event::ChannelLeft;

use strict;
use warnings;

our $VERSION = '0.013'; # VERSION

use Net::Async::Slack::EventType;

=head1 NAME

Net::Async::Slack::Event::ChannelLeft - You left a channel

=head1 DESCRIPTION

Example input data:

    channels:read

=cut

sub type { 'channel_left' }

1;

__END__

=head1 AUTHOR

Tom Molesworth <TEAM@cpan.org>

=head1 LICENSE

Copyright Tom Molesworth 2016-2023. Licensed under the same terms as Perl itself.
