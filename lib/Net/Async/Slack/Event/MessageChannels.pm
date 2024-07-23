package Net::Async::Slack::Event::MessageChannels;

use strict;
use warnings;

# VERSION

use Net::Async::Slack::EventType;

=head1 NAME

Net::Async::Slack::Event::MessageChannels - A message was posted to a channel

=head1 DESCRIPTION

Example input data:

    channels:history

=cut

sub type { 'message.channels' }

1;

__END__

=head1 AUTHOR

Tom Molesworth <TEAM@cpan.org>

=head1 LICENSE

Copyright Tom Molesworth 2016-2024. Licensed under the same terms as Perl itself.
