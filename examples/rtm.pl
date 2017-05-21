#!/usr/bin/env perl 
use strict;
use warnings;

use IO::Async::Loop;
use Net::Async::Slack;

use Log::Any::Adapter qw(Stdout), log_level => 'trace';

my $loop = IO::Async::Loop->new;

my $token = shift or die 'Invalid token';
$loop->add(
    my $slack = Net::Async::Slack->new(
        client_id => '159837476818.159130832832',
        token     => $token,
    )
);

my $rtm = $slack->rtm->get;

$loop->run;
