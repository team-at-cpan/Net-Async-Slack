package Net::Async::Slack::Event::FileShared;

use strict;
use warnings;

use Net::Async::Slack::EventType;

=head1 NAME

Net::Async::Slack::Event::FileShared - A file was shared

=head1 DESCRIPTION

Example input data:

    files:read

=cut

sub type { 'file_shared' }

1;

