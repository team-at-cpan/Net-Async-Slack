package Net::Async::Slack::Socket;

use strict;
use warnings;

our $VERSION = '0.014'; # VERSION
our $AUTHORITY = 'cpan:TEAM'; # AUTHORITY

use parent qw(IO::Async::Notifier);

=head1 NAME

Net::Async::Slack::Socket - socket-mode notifications for L<https://slack.com>

=head1 DESCRIPTION

This is a basic wrapper for Slack's socket-mode features.

See L<https://api.slack.com/apis/connections/socket> for some background on using this feature.

This provides an event stream using websockets.

For a full list of events, see L<https://api.slack.com/events>.

=cut

use Syntax::Keyword::Try;
no indirect qw(fatal);
use mro;

use Future;
use Future::AsyncAwait;
use Dir::Self;
use URI;
use URI::QueryParam;
use URI::Template;
use JSON::MaybeUTF8 qw(:v2);
use Time::Moment;

use IO::Async::Timer::Countdown;
use Net::Async::WebSocket::Client;

# We have a long list of events, these are all autogenerated - the
# idea being that you should be able to `->isa()` or check `->type`
# to filter on the features you are interested in.
use Net::Async::Slack::Event::AccountsChanged;
use Net::Async::Slack::Event::AppHomeOpened;
use Net::Async::Slack::Event::AppMention;
use Net::Async::Slack::Event::AppRateLimited;
use Net::Async::Slack::Event::AppUninstalled;
use Net::Async::Slack::Event::BlockActions;
use Net::Async::Slack::Event::BotAdded;
use Net::Async::Slack::Event::BotChanged;
use Net::Async::Slack::Event::Bot;
use Net::Async::Slack::Event::ChannelArchive;
use Net::Async::Slack::Event::ChannelCreated;
use Net::Async::Slack::Event::ChannelDeleted;
use Net::Async::Slack::Event::ChannelHistoryChanged;
use Net::Async::Slack::Event::ChannelJoined;
use Net::Async::Slack::Event::ChannelLeft;
use Net::Async::Slack::Event::ChannelMarked;
use Net::Async::Slack::Event::Channel;
use Net::Async::Slack::Event::ChannelRename;
use Net::Async::Slack::Event::ChannelUnarchive;
use Net::Async::Slack::Event::CommandsChanged;
use Net::Async::Slack::Event::DndUpdated;
use Net::Async::Slack::Event::DndUpdatedUser;
use Net::Async::Slack::Event::EmailDomainChanged;
use Net::Async::Slack::Event::EmojiChanged;
use Net::Async::Slack::Event::FileChange;
use Net::Async::Slack::Event::FileCommentAdded;
use Net::Async::Slack::Event::FileCommentDeleted;
use Net::Async::Slack::Event::FileCommentEdited;
use Net::Async::Slack::Event::FileCreated;
use Net::Async::Slack::Event::FileDeleted;
use Net::Async::Slack::Event::FilePublic;
use Net::Async::Slack::Event::FileShared;
use Net::Async::Slack::Event::FileUnshared;
use Net::Async::Slack::Event::Goodbye;
use Net::Async::Slack::Event::GridMigrationFinished;
use Net::Async::Slack::Event::GridMigrationStarted;
use Net::Async::Slack::Event::GroupArchive;
use Net::Async::Slack::Event::GroupClose;
use Net::Async::Slack::Event::GroupDeleted;
use Net::Async::Slack::Event::GroupHistoryChanged;
use Net::Async::Slack::Event::GroupJoined;
use Net::Async::Slack::Event::GroupLeft;
use Net::Async::Slack::Event::GroupMarked;
use Net::Async::Slack::Event::GroupOpen;
use Net::Async::Slack::Event::GroupRename;
use Net::Async::Slack::Event::GroupUnarchive;
use Net::Async::Slack::Event::Hello;
use Net::Async::Slack::Event::ImClose;
use Net::Async::Slack::Event::ImCreated;
use Net::Async::Slack::Event::ImHistoryChanged;
use Net::Async::Slack::Event::ImMarked;
use Net::Async::Slack::Event::ImOpen;
use Net::Async::Slack::Event::LinkShared;
use Net::Async::Slack::Event::ManualPresenceChange;
use Net::Async::Slack::Event::MemberJoinedChannel;
use Net::Async::Slack::Event::MemberLeftChannel;
use Net::Async::Slack::Event::MessageAction;
use Net::Async::Slack::Event::MessageAppHome;
use Net::Async::Slack::Event::MessageChannels;
use Net::Async::Slack::Event::MessageGroups;
use Net::Async::Slack::Event::MessageIm;
use Net::Async::Slack::Event::MessageMpim;
use Net::Async::Slack::Event::Message;
use Net::Async::Slack::Event::PinAdded;
use Net::Async::Slack::Event::PinRemoved;
use Net::Async::Slack::Event::PrefChange;
use Net::Async::Slack::Event::PresenceChange;
use Net::Async::Slack::Event::PresenceQuery;
use Net::Async::Slack::Event::PresenceSub;
use Net::Async::Slack::Event::ReactionAdded;
use Net::Async::Slack::Event::ReactionRemoved;
use Net::Async::Slack::Event::ReconnectURL;
use Net::Async::Slack::Event::ResourcesAdded;
use Net::Async::Slack::Event::ResourcesRemoved;
use Net::Async::Slack::Event::ScopeDenied;
use Net::Async::Slack::Event::ScopeGranted;
use Net::Async::Slack::Event::Shortcut;
use Net::Async::Slack::Event::SlashCommands;
use Net::Async::Slack::Event::StarAdded;
use Net::Async::Slack::Event::StarRemoved;
use Net::Async::Slack::Event::SubteamCreated;
use Net::Async::Slack::Event::SubteamMembersChanged;
use Net::Async::Slack::Event::SubteamSelfAdded;
use Net::Async::Slack::Event::SubteamSelfRemoved;
use Net::Async::Slack::Event::SubteamUpdated;
use Net::Async::Slack::Event::TeamDomainChange;
use Net::Async::Slack::Event::TeamJoin;
use Net::Async::Slack::Event::TeamMigrationStarted;
use Net::Async::Slack::Event::TeamPlanChange;
use Net::Async::Slack::Event::TeamPrefChange;
use Net::Async::Slack::Event::TeamProfileChange;
use Net::Async::Slack::Event::TeamProfileDelete;
use Net::Async::Slack::Event::TeamProfileReorder;
use Net::Async::Slack::Event::TeamRename;
use Net::Async::Slack::Event::TokensRevoked;
use Net::Async::Slack::Event::URLVerification;
use Net::Async::Slack::Event::UserChange;
use Net::Async::Slack::Event::UserResourceDenied;
use Net::Async::Slack::Event::UserResourceGranted;
use Net::Async::Slack::Event::UserResourceRemoved;
use Net::Async::Slack::Event::UserTyping;
use Net::Async::Slack::Event::ViewSubmission;
use Net::Async::Slack::Event::WorkflowStepEdit;

use List::Util qw(min);
use Log::Any qw($log);

=head1 METHODS

=head2 events

This is the stream of events, as a L<Ryu::Source>.

Example usage:

 $rtm->events
     ->filter(type => 'message')
     ->sprintf_methods('> %s', $_->text)
     ->say
     ->await;

=cut

sub events {
    my ($self) = @_;
    $self->{events} //= do {
        $self->ryu->source
    }
}

=head2 handle_unfurl_domain

Registers a handler for URLs.

Takes the following named parameters:

=over 4

=item * C<domain> - which host/domain to respond to, e.g. C<google.com> for L<https://google.com>

=item * C<handler> - a callback, expected to take a L<URI> instance and return a L<Future> with a Slack message

=back

Example usage:

 $sock->handle_unfurl_domain(
     domain => 'service.local',
     handler => async sub ($uri) {
         my ($id) = $uri->path =~ m{/id/([0-9]+)}
             or return undef;
         return +{
             blocks => [ {
                 "type" => "section",
                 "text" => {
                     "type" => "mrkdwn",
                     "text" => "Request with ID `$id`",
                 },
             } ]
         };
     }
 );

Returns the L<Net::Async::Slack::Socket> instance to allow chaining.

=cut

sub handle_unfurl_domain {
    my ($self, %args) = @_;
    $self->{unfurl_domain}{
        delete $args{domain} || die 'need a domain'
    } = $args{handler}
        or die 'need a handler';
    return $self;
}

=head2 last_frame_epoch

Returns the floating-point timestamp for the last frame we received. Will be
C<undef> if we have no frames yet.

=cut

sub last_frame_epoch {
    my ($self) = @_;
    return $self->{last_frame_epoch};
}

=head1 METHODS - Internal

You may not need to call these directly. If I'm wrong and you find yourself having
to do that, please complain via the usual channels.

=head2 connect

Establishes the connection. Called by the top-level L<Net::Async::Slack> instance.

=cut

async sub connect {
    my ($self, %args) = @_;
    my $uri = delete($args{uri}) // $self->wss_uri or die 'no websocket URI available';
    my $prev = delete $self->{ws};
    $self->add_child(
        $self->{ws} = Net::Async::WebSocket::Client->new(
            on_frame => $self->curry::weak::on_frame,
            on_ping_frame => $self->curry::weak::on_ping_frame,
            on_close_frame => $self->curry::weak::on_close_frame,
        )
    );
    $log->tracef('URL for websockets will be %s', "$uri");
    my $res = await $self->{ws}->connect(
        url        => "$uri",
    );
    if($prev) {
        $log->tracef('Closing previous websocket connection');
        try {
            $prev->send_close_frame('')->then(async sub {
                $prev->close_now;
                $self->remove_child($prev) if $prev->parent;
            })->retain;
        } catch($e) {
            $log->errorf('Unable to clean up previous connection: %s', $e);
        }
    }
    $self->event_mangler;
    return $res;
}

sub on_ping_frame {
    my ($self, $ws, $bytes) = @_;
    $self->connection_watchdog_nudge;
    $ws->send_pong_frame('');
}

sub on_close_frame {
    my ($self) = @_;
    $log->debugf('Received close frame');
    $self->trigger_reconnect_if_needed
}

async sub reconnect {
    my ($self) = @_;
    my $sleep = 0;
    my $count = 0;
    while(1) {
        ++$count;
        try {
            $log->debugf('Attempting reconnect, try %d', $count);
            my ($uri) = await Future->wait_any(
                $self->slack->socket,
                $self->loop->timeout_future(after => 30),
            );
            await Future->wait_any(
                $self->connect(
                    uri => $uri
                ),
                $self->loop->timeout_future(after => 30),
            );
            return;
        } catch($e) {
            $sleep = min(30.0, ($sleep || 0.008) * 2);
            $log->errorf('Failed to reconnect for socket mode, will try again in %.3fs: %s', $sleep, $e);
            await $self->loop->delay_future(after => $sleep);
        }
    }
}

sub on_close {
    my ($self) = @_;
    $self->trigger_reconnect_if_needed;
}

sub trigger_reconnect_if_needed {
    my ($self) = @_;
    $log->tracef('trigger_reconnect_if_needed');
    $self->connection_watchdog->stop;
    return $self->{reconnecting} ||= $self->reconnect->on_ready(sub {
        delete $self->{reconnecting}
    });
}

sub connection_watchdog {
    my ($self) = @_;
    $self->{connection_watchdog} ||= do {
        $self->add_child(
            my $timer = IO::Async::Timer::Countdown->new(
                delay => 30,
                on_expire => $self->$curry::weak(sub {
                    my ($self) = @_;
                    $self->trigger_reconnect_if_needed
                }),
            )
        );
        $timer->start;
        $timer
    };
}

sub connection_watchdog_nudge {
    my ($self) = @_;
    my $timer = $self->connection_watchdog;
    $timer->reset;
    $timer->start if $timer->is_expired;
    $self->{last_frame_epoch} = $self->loop->time;
    $timer
}

sub on_frame {
    my ($self, $ws, $bytes) = @_;
    $self->connection_watchdog_nudge;

    # Empty frame is used for PING, send a response back
    if(!length($bytes)) {
        $ws->send_frame('');
        return;
    }

    my $text = eval { Encode::decode_utf8($bytes) } // do {
        $log->errorf('Invalid UTF8 received from Slack: %v02x', $bytes);
        return;
    };
    try {
        $log->tracef("<< %s", $text);
        my $data = decode_json_text($text);
        if($data->{type} eq 'disconnect') {
            $log->debugf('Received disconnection notification, reason: %s (debug info: %s)', $data->{reason}, $data->{debug_info});
            $self->trigger_reconnect_if_needed;
        }

        my $pending;

        my $env_id = $data->{envelope_id};
        if($env_id) {
            if($data->{accepts_response_payload}) {

                # If the caller marks our future as done, send the result over as a payload
                $pending = $self->loop->new_future->on_done($self->$curry::weak(sub {
                    my ($self, $payload) = @_;
                    $self->send_response($env_id, $payload)->retain;
                    return;
                }));
                # ... but auto-acknowledge before the deadline if they don't, for back-compatibility
                my $f = $self->loop->delay_future(
                    after => 1.5
                )->on_done($self->$curry::weak(sub {
                    my ($self) = @_;
                    $self->send_response($env_id)->retain;
                    return;
                }));
                # Make sure only one of the actions completes
                Future->wait_any($pending, $f)->retain;
            } else {
                $self->send_response($env_id)->retain;
            }
        }

        if(my $type = $data->{payload}{type}) {
            if($type eq 'event_callback') {
                my $ev = Net::Async::Slack::EventType->from_json(
                    $data->{payload}{event}
                );
                $ev->{envelope_id} = $env_id;
                $ev->{response_future} = $pending if $pending;
                $log->tracef("Have event [%s], emitting", $ev->type);
                $self->events->emit($ev);
            } else {
                if(my $ev = Net::Async::Slack::EventType->from_json(
                    $data->{payload}
                )) {
                    $ev->{envelope_id} = $env_id;
                    $ev->{response_future} = $pending if $pending;
                    $log->tracef("Have event [%s], emitting", $ev->type);
                    $self->events->emit($ev);
                } else {
                    $log->errorf('Failed to locate event type from payload %s', $data->{payload});
                }
            }
        } elsif($type = $data->{type}) {
            $log->tracef("Have generic/unknown event [%s], emitting", $data);
            if(my $ev = Net::Async::Slack::EventType->from_json(
                $data
            )) {
                $self->events->emit($ev);
            } else {
                $log->errorf('Unable to find event type from %s', $data);
            }
        }
    } catch ($e) {
        $log->errorf("Exception in websocket raw frame handling: %s (original text %s)", $e, $text);
    }
}

sub send_response {
    my ($self, $env_id, $payload) = @_;
    die 'need env_id' unless $env_id;
    my $data = encode_json_utf8({
        envelope_id => $env_id,
        ($payload ? (payload => $payload) : ()),
    });
    $log->tracef(">> %s", $data);
    return $self->ws->send_frame(
        buffer => $data,
        masked => 1
    );
}

sub next_id {
    my ($self, $id) = @_;
    $self->{last_id} = $id // ++$self->{last_id};
}

sub configure {
    my ($self, %args) = @_;
    for my $k (qw(slack wss_uri)) {
        $self->{$k} = delete $args{$k} if exists $args{$k};
    }
    $self->next::method(%args);
}

sub ping_timer {
    my ($self) = @_;
    $self->{ping_timer} ||= do {
        $self->add_child(
            my $timer = IO::Async::Timer::Countdown->new(
                delay => 10,
                on_expire => $self->$curry::weak(sub { shift->trigger_ping }),
            )
        );
        $timer
    }
}

sub event_mangler {
    my ($self) = @_;
    $self->{event_handling} //= $self->events->map($self->$curry::weak(async sub {
        my ($self, $ev) = @_;
        try {
            if(my $code = $self->can($ev->type)) {
                await $self->$code($ev);
            } else {
                $log->tracef('Ignoring event %s', $ev->type);
            }
        } catch ($e) {
            $log->errorf('Event handling on %s failed: %s', $ev, $e);
        }
    }))->ordered_futures(
        low => 16,
        high => 100,
    );
}

async sub link_shared {
    my ($self, $ev) = @_;
    my %uri_map;
    for my $link ($ev->{links}->@*) {
        if(my $handler = $self->{unfurl_domain}{$link->{domain}}) {
            my $uri = URI->new($link->{url});
            $log->tracef('Unfurling URL %s', $uri);
            my $unfurled = await $handler->($uri);
            $uri_map{$uri} = $unfurled if $unfurled;
        }
    }
    return unless keys %uri_map;
    my $res = await $self->slack->chat_unfurl(
        channel => $ev->{channel_id} // $ev->{channel}->id,
        ts      => $ev->{message_ts},
        unfurls => \%uri_map,
    );
    die 'invalid URI unfurling' unless $res->{ok};
    return;
}

sub trigger_ping {
    my ($self, %args) = @_;
    my $id = $self->next_id($args{id});
    $self->ws->send_frame(
        buffer => encode_json_utf8({
            type    => 'ping',
            id      => $id,
        }),
        masked => 1
    );
    $self->ping_timer->reset;
    $self->ping_timer->start if $self->ping_timer->is_expired;
}

sub _add_to_loop {
    my ($self, $loop) = @_;
    $self->add_child(
        $self->{ryu} = Ryu::Async->new
    );
    # $self->ping_timer->start;
    $self->{last_id} //= 0;
}

sub slack { shift->{slack} }

sub wss_uri { shift->{wss_uri} }

sub ws { shift->{ws} }

sub ryu { shift->{ryu} }

1;

=head1 AUTHOR

Tom Molesworth <TEAM@cpan.org>

=head1 LICENSE

Copyright Tom Molesworth 2016-2023. Licensed under the same terms as Perl itself.

