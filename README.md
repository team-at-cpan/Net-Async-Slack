# NAME

Net::Async::Slack - support for the [https://slack.com](https://slack.com) APIs with [IO::Async](https://metacpan.org/pod/IO%3A%3AAsync)

# SYNOPSIS

    use IO::Async::Loop;
    use Net::Async::Slack;
    my $loop = IO::Async::Loop->new;
    $loop->add(
     my $slack = Net::Async::Slack->new(
      token => '...',
     )
    );

# DESCRIPTION

This is a basic wrapper for Slack's API. It's an early version, the module API is likely
to change somewhat over time.

See the `examples/` directory for usage.

# METHODS

## rtm

Establishes a connection to the Slack RTM websocket API, and
resolves to a [Net::Async::Slack::RTM](https://metacpan.org/pod/Net%3A%3AAsync%3A%3ASlack%3A%3ARTM) instance.

## send\_message

Send a message to a user or channel.

Supports the following named parameters:

- channel - who to send the message to, can be a channel ID or `#channel` name, or user ID
- text - the message, see [https://api.slack.com/docs/message-formatting](https://api.slack.com/docs/message-formatting) for details
- attachments - more advanced messages, see [https://api.slack.com/docs/message-attachments](https://api.slack.com/docs/message-attachments)
- parse - whether to parse content and convert things like links

and the following named boolean parameters:

- link\_names - convert `@user` and `#channel` to links
- unfurl\_links - show preview for URLs
- unfurl\_media - show preview for things that look like media links
- as\_user - send as user
- reply\_broadcast - send to all users when replying to a thread

Returns a [Future](https://metacpan.org/pod/Future), although the content of the response is subject to change.

## files\_upload

Upload file(s) to a channel or thread.

Supports the following named parameters:

- channel - who to send the message to, can be a channel ID or `#channel` name, or user ID
- text - the message, see [https://api.slack.com/docs/message-formatting](https://api.slack.com/docs/message-formatting) for details
- attachments - more advanced messages, see [https://api.slack.com/docs/message-attachments](https://api.slack.com/docs/message-attachments)
- parse - whether to parse content and convert things like links

and the following named boolean parameters:

- link\_names - convert `@user` and `#channel` to links
- unfurl\_links - show preview for URLs
- unfurl\_media - show preview for things that look like media links
- as\_user - send as user
- reply\_broadcast - send to all users when replying to a thread

Returns a [Future](https://metacpan.org/pod/Future), although the content of the response is subject to change.

## conversations\_info

Provide information about a channel.

Takes the following named parameters:

- `channel` - the channel ID to look up

and returns a [Future](https://metacpan.org/pod/Future) which will resolve to a hashref containing
`{ channel => { name => '...' } }`.

## join\_channel

Attempt to join the given channel.

Takes the following named parameters:

- `channel` - the channel ID or name to join

# METHODS - Internal

## endpoints

Returns the hashref of API endpoints, loading them on first call from the `share/endpoints.json` file.

## endpoint

Processes the given endpoint as a template, using the named parameters
passed to the method.

## oauth\_request

## token

API token.

## http

Returns the HTTP instance used for communicating with the API.

Currently autocreates a [Net::Async::HTTP](https://metacpan.org/pod/Net%3A%3AAsync%3A%3AHTTP) instance.

## http\_get

Issues an HTTP GET request.

## http\_post

Issues an HTTP POST request.

# SEE ALSO

- [AnyEvent::SlackRTM](https://metacpan.org/pod/AnyEvent%3A%3ASlackRTM) - low-level API wrapper around RTM
- [Mojo::SlackRTM](https://metacpan.org/pod/Mojo%3A%3ASlackRTM) - another RTM-specific wrapper, this time based on Mojolicious
- [Slack::RTM::Bot](https://metacpan.org/pod/Slack%3A%3ARTM%3A%3ABot) - more RTM support, this time via LWP and a subprocess/thread for handling the websocket part
- [WebService::Slack::WebApi](https://metacpan.org/pod/WebService%3A%3ASlack%3A%3AWebApi) - Furl-based wrapper around the REST API
- [AnyEvent::SlackBot](https://metacpan.org/pod/AnyEvent%3A%3ASlackBot) - another AnyEvent RTM implementation

# AUTHOR

Tom Molesworth <TEAM@cpan.org>

# LICENSE

Copyright Tom Molesworth 2016-2023. Licensed under the same terms as Perl itself.
