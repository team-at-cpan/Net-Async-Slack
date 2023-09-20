package Net::Async::Slack::Event::ChannelMarked;

use strict;
use warnings;

our $VERSION = '0.013'; # VERSION

use Net::Async::Slack::EventType;

=head1 NAME

Net::Async::Slack::Event::ChannelMarked - Your channel read marker was updated

=head1 DESCRIPTION

Example input data:

    {
        "type": "channel_marked",
        "channel": "C024BE91L",
        "ts": "1401383885.000061"
    }


=cut

sub type { 'channel_marked' }

1;

__END__

=head1 AUTHOR

Tom Molesworth <TEAM@cpan.org>

=head1 LICENSE

Copyright Tom Molesworth 2016-2023. Licensed under the same terms as Perl itself.
