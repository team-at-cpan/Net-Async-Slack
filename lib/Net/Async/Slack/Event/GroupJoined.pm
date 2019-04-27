package Net::Async::Slack::Event::GroupJoined;

use strict;
use warnings;

use utf8;

# VERSION

use Net::Async::Slack::EventType;

=encoding UTF-8

=head1 NAME

Net::Async::Slack::Event::GroupJoined - You joined a private channel

=head1 DESCRIPTION

Example input data:

    {
        "type": "group_joined",
        "channel": {
            …
        }
    }


=cut

sub type { 'group_joined' }

1;

__END__

=head1 AUTHOR

Tom Molesworth <TEAM@cpan.org>

=head1 LICENSE

Copyright Tom Molesworth 2016-2019. Licensed under the same terms as Perl itself.
