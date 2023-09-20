use strict;
use warnings;

# this test was generated with Dist::Zilla::Plugin::Test::NoTabs 0.15

use Test::More 0.88;
use Test::NoTabs;

my @files = (
    'lib/Net/Async/Slack.pm',
    'lib/Net/Async/Slack.pod',
    'lib/Net/Async/Slack/Commands.pm',
    'lib/Net/Async/Slack/Event/AccountsChanged.pm',
    'lib/Net/Async/Slack/Event/AccountsChanged.pod',
    'lib/Net/Async/Slack/Event/AppHomeOpened.pm',
    'lib/Net/Async/Slack/Event/AppHomeOpened.pod',
    'lib/Net/Async/Slack/Event/AppMention.pm',
    'lib/Net/Async/Slack/Event/AppMention.pod',
    'lib/Net/Async/Slack/Event/AppRateLimited.pm',
    'lib/Net/Async/Slack/Event/AppRateLimited.pod',
    'lib/Net/Async/Slack/Event/AppUninstalled.pm',
    'lib/Net/Async/Slack/Event/AppUninstalled.pod',
    'lib/Net/Async/Slack/Event/BlockActions.pm',
    'lib/Net/Async/Slack/Event/BlockActions.pod',
    'lib/Net/Async/Slack/Event/Bot.pm',
    'lib/Net/Async/Slack/Event/BotAdded.pm',
    'lib/Net/Async/Slack/Event/BotAdded.pod',
    'lib/Net/Async/Slack/Event/BotChanged.pm',
    'lib/Net/Async/Slack/Event/BotChanged.pod',
    'lib/Net/Async/Slack/Event/Channel.pm',
    'lib/Net/Async/Slack/Event/ChannelArchive.pm',
    'lib/Net/Async/Slack/Event/ChannelArchive.pod',
    'lib/Net/Async/Slack/Event/ChannelCreated.pm',
    'lib/Net/Async/Slack/Event/ChannelCreated.pod',
    'lib/Net/Async/Slack/Event/ChannelDeleted.pm',
    'lib/Net/Async/Slack/Event/ChannelDeleted.pod',
    'lib/Net/Async/Slack/Event/ChannelHistoryChanged.pm',
    'lib/Net/Async/Slack/Event/ChannelHistoryChanged.pod',
    'lib/Net/Async/Slack/Event/ChannelJoined.pm',
    'lib/Net/Async/Slack/Event/ChannelJoined.pod',
    'lib/Net/Async/Slack/Event/ChannelLeft.pm',
    'lib/Net/Async/Slack/Event/ChannelLeft.pod',
    'lib/Net/Async/Slack/Event/ChannelMarked.pm',
    'lib/Net/Async/Slack/Event/ChannelMarked.pod',
    'lib/Net/Async/Slack/Event/ChannelRename.pm',
    'lib/Net/Async/Slack/Event/ChannelRename.pod',
    'lib/Net/Async/Slack/Event/ChannelUnarchive.pm',
    'lib/Net/Async/Slack/Event/ChannelUnarchive.pod',
    'lib/Net/Async/Slack/Event/CommandsChanged.pm',
    'lib/Net/Async/Slack/Event/CommandsChanged.pod',
    'lib/Net/Async/Slack/Event/DndUpdated.pm',
    'lib/Net/Async/Slack/Event/DndUpdated.pod',
    'lib/Net/Async/Slack/Event/DndUpdatedUser.pm',
    'lib/Net/Async/Slack/Event/DndUpdatedUser.pod',
    'lib/Net/Async/Slack/Event/EmailDomainChanged.pm',
    'lib/Net/Async/Slack/Event/EmailDomainChanged.pod',
    'lib/Net/Async/Slack/Event/EmojiChanged.pm',
    'lib/Net/Async/Slack/Event/EmojiChanged.pod',
    'lib/Net/Async/Slack/Event/FileChange.pm',
    'lib/Net/Async/Slack/Event/FileChange.pod',
    'lib/Net/Async/Slack/Event/FileCommentAdded.pm',
    'lib/Net/Async/Slack/Event/FileCommentAdded.pod',
    'lib/Net/Async/Slack/Event/FileCommentDeleted.pm',
    'lib/Net/Async/Slack/Event/FileCommentDeleted.pod',
    'lib/Net/Async/Slack/Event/FileCommentEdited.pm',
    'lib/Net/Async/Slack/Event/FileCommentEdited.pod',
    'lib/Net/Async/Slack/Event/FileCreated.pm',
    'lib/Net/Async/Slack/Event/FileCreated.pod',
    'lib/Net/Async/Slack/Event/FileDeleted.pm',
    'lib/Net/Async/Slack/Event/FileDeleted.pod',
    'lib/Net/Async/Slack/Event/FilePublic.pm',
    'lib/Net/Async/Slack/Event/FilePublic.pod',
    'lib/Net/Async/Slack/Event/FileShared.pm',
    'lib/Net/Async/Slack/Event/FileShared.pod',
    'lib/Net/Async/Slack/Event/FileUnshared.pm',
    'lib/Net/Async/Slack/Event/FileUnshared.pod',
    'lib/Net/Async/Slack/Event/Goodbye.pm',
    'lib/Net/Async/Slack/Event/Goodbye.pod',
    'lib/Net/Async/Slack/Event/GridMigrationFinished.pm',
    'lib/Net/Async/Slack/Event/GridMigrationFinished.pod',
    'lib/Net/Async/Slack/Event/GridMigrationStarted.pm',
    'lib/Net/Async/Slack/Event/GridMigrationStarted.pod',
    'lib/Net/Async/Slack/Event/GroupArchive.pm',
    'lib/Net/Async/Slack/Event/GroupArchive.pod',
    'lib/Net/Async/Slack/Event/GroupClose.pm',
    'lib/Net/Async/Slack/Event/GroupClose.pod',
    'lib/Net/Async/Slack/Event/GroupDeleted.pm',
    'lib/Net/Async/Slack/Event/GroupDeleted.pod',
    'lib/Net/Async/Slack/Event/GroupHistoryChanged.pm',
    'lib/Net/Async/Slack/Event/GroupHistoryChanged.pod',
    'lib/Net/Async/Slack/Event/GroupJoined.pm',
    'lib/Net/Async/Slack/Event/GroupJoined.pod',
    'lib/Net/Async/Slack/Event/GroupLeft.pm',
    'lib/Net/Async/Slack/Event/GroupLeft.pod',
    'lib/Net/Async/Slack/Event/GroupMarked.pm',
    'lib/Net/Async/Slack/Event/GroupMarked.pod',
    'lib/Net/Async/Slack/Event/GroupOpen.pm',
    'lib/Net/Async/Slack/Event/GroupOpen.pod',
    'lib/Net/Async/Slack/Event/GroupRename.pm',
    'lib/Net/Async/Slack/Event/GroupRename.pod',
    'lib/Net/Async/Slack/Event/GroupUnarchive.pm',
    'lib/Net/Async/Slack/Event/GroupUnarchive.pod',
    'lib/Net/Async/Slack/Event/Hello.pm',
    'lib/Net/Async/Slack/Event/Hello.pod',
    'lib/Net/Async/Slack/Event/ImClose.pm',
    'lib/Net/Async/Slack/Event/ImClose.pod',
    'lib/Net/Async/Slack/Event/ImCreated.pm',
    'lib/Net/Async/Slack/Event/ImCreated.pod',
    'lib/Net/Async/Slack/Event/ImHistoryChanged.pm',
    'lib/Net/Async/Slack/Event/ImHistoryChanged.pod',
    'lib/Net/Async/Slack/Event/ImMarked.pm',
    'lib/Net/Async/Slack/Event/ImMarked.pod',
    'lib/Net/Async/Slack/Event/ImOpen.pm',
    'lib/Net/Async/Slack/Event/ImOpen.pod',
    'lib/Net/Async/Slack/Event/LinkShared.pm',
    'lib/Net/Async/Slack/Event/LinkShared.pod',
    'lib/Net/Async/Slack/Event/ManualPresenceChange.pm',
    'lib/Net/Async/Slack/Event/ManualPresenceChange.pod',
    'lib/Net/Async/Slack/Event/MemberJoinedChannel.pm',
    'lib/Net/Async/Slack/Event/MemberJoinedChannel.pod',
    'lib/Net/Async/Slack/Event/MemberLeftChannel.pm',
    'lib/Net/Async/Slack/Event/MemberLeftChannel.pod',
    'lib/Net/Async/Slack/Event/Message.pm',
    'lib/Net/Async/Slack/Event/Message.pod',
    'lib/Net/Async/Slack/Event/MessageAction.pm',
    'lib/Net/Async/Slack/Event/MessageAction.pod',
    'lib/Net/Async/Slack/Event/MessageAppHome.pm',
    'lib/Net/Async/Slack/Event/MessageAppHome.pod',
    'lib/Net/Async/Slack/Event/MessageChannels.pm',
    'lib/Net/Async/Slack/Event/MessageChannels.pod',
    'lib/Net/Async/Slack/Event/MessageGroups.pm',
    'lib/Net/Async/Slack/Event/MessageGroups.pod',
    'lib/Net/Async/Slack/Event/MessageIm.pm',
    'lib/Net/Async/Slack/Event/MessageIm.pod',
    'lib/Net/Async/Slack/Event/MessageMpim.pm',
    'lib/Net/Async/Slack/Event/MessageMpim.pod',
    'lib/Net/Async/Slack/Event/PinAdded.pm',
    'lib/Net/Async/Slack/Event/PinAdded.pod',
    'lib/Net/Async/Slack/Event/PinRemoved.pm',
    'lib/Net/Async/Slack/Event/PinRemoved.pod',
    'lib/Net/Async/Slack/Event/PrefChange.pm',
    'lib/Net/Async/Slack/Event/PrefChange.pod',
    'lib/Net/Async/Slack/Event/PresenceChange.pm',
    'lib/Net/Async/Slack/Event/PresenceChange.pod',
    'lib/Net/Async/Slack/Event/PresenceQuery.pm',
    'lib/Net/Async/Slack/Event/PresenceQuery.pod',
    'lib/Net/Async/Slack/Event/PresenceSub.pm',
    'lib/Net/Async/Slack/Event/PresenceSub.pod',
    'lib/Net/Async/Slack/Event/ReactionAdded.pm',
    'lib/Net/Async/Slack/Event/ReactionAdded.pod',
    'lib/Net/Async/Slack/Event/ReactionRemoved.pm',
    'lib/Net/Async/Slack/Event/ReactionRemoved.pod',
    'lib/Net/Async/Slack/Event/ReconnectURL.pm',
    'lib/Net/Async/Slack/Event/ReconnectURL.pod',
    'lib/Net/Async/Slack/Event/ResourcesAdded.pm',
    'lib/Net/Async/Slack/Event/ResourcesAdded.pod',
    'lib/Net/Async/Slack/Event/ResourcesRemoved.pm',
    'lib/Net/Async/Slack/Event/ResourcesRemoved.pod',
    'lib/Net/Async/Slack/Event/ScopeDenied.pm',
    'lib/Net/Async/Slack/Event/ScopeDenied.pod',
    'lib/Net/Async/Slack/Event/ScopeGranted.pm',
    'lib/Net/Async/Slack/Event/ScopeGranted.pod',
    'lib/Net/Async/Slack/Event/Shortcut.pm',
    'lib/Net/Async/Slack/Event/Shortcut.pod',
    'lib/Net/Async/Slack/Event/SlashCommands.pm',
    'lib/Net/Async/Slack/Event/SlashCommands.pod',
    'lib/Net/Async/Slack/Event/StarAdded.pm',
    'lib/Net/Async/Slack/Event/StarAdded.pod',
    'lib/Net/Async/Slack/Event/StarRemoved.pm',
    'lib/Net/Async/Slack/Event/StarRemoved.pod',
    'lib/Net/Async/Slack/Event/SubteamCreated.pm',
    'lib/Net/Async/Slack/Event/SubteamCreated.pod',
    'lib/Net/Async/Slack/Event/SubteamMembersChanged.pm',
    'lib/Net/Async/Slack/Event/SubteamMembersChanged.pod',
    'lib/Net/Async/Slack/Event/SubteamSelfAdded.pm',
    'lib/Net/Async/Slack/Event/SubteamSelfAdded.pod',
    'lib/Net/Async/Slack/Event/SubteamSelfRemoved.pm',
    'lib/Net/Async/Slack/Event/SubteamSelfRemoved.pod',
    'lib/Net/Async/Slack/Event/SubteamUpdated.pm',
    'lib/Net/Async/Slack/Event/SubteamUpdated.pod',
    'lib/Net/Async/Slack/Event/TeamDomainChange.pm',
    'lib/Net/Async/Slack/Event/TeamDomainChange.pod',
    'lib/Net/Async/Slack/Event/TeamJoin.pm',
    'lib/Net/Async/Slack/Event/TeamJoin.pod',
    'lib/Net/Async/Slack/Event/TeamMigrationStarted.pm',
    'lib/Net/Async/Slack/Event/TeamMigrationStarted.pod',
    'lib/Net/Async/Slack/Event/TeamPlanChange.pm',
    'lib/Net/Async/Slack/Event/TeamPlanChange.pod',
    'lib/Net/Async/Slack/Event/TeamPrefChange.pm',
    'lib/Net/Async/Slack/Event/TeamPrefChange.pod',
    'lib/Net/Async/Slack/Event/TeamProfileChange.pm',
    'lib/Net/Async/Slack/Event/TeamProfileChange.pod',
    'lib/Net/Async/Slack/Event/TeamProfileDelete.pm',
    'lib/Net/Async/Slack/Event/TeamProfileDelete.pod',
    'lib/Net/Async/Slack/Event/TeamProfileReorder.pm',
    'lib/Net/Async/Slack/Event/TeamProfileReorder.pod',
    'lib/Net/Async/Slack/Event/TeamRename.pm',
    'lib/Net/Async/Slack/Event/TeamRename.pod',
    'lib/Net/Async/Slack/Event/TokensRevoked.pm',
    'lib/Net/Async/Slack/Event/TokensRevoked.pod',
    'lib/Net/Async/Slack/Event/URLVerification.pm',
    'lib/Net/Async/Slack/Event/URLVerification.pod',
    'lib/Net/Async/Slack/Event/UserChange.pm',
    'lib/Net/Async/Slack/Event/UserChange.pod',
    'lib/Net/Async/Slack/Event/UserResourceDenied.pm',
    'lib/Net/Async/Slack/Event/UserResourceDenied.pod',
    'lib/Net/Async/Slack/Event/UserResourceGranted.pm',
    'lib/Net/Async/Slack/Event/UserResourceGranted.pod',
    'lib/Net/Async/Slack/Event/UserResourceRemoved.pm',
    'lib/Net/Async/Slack/Event/UserResourceRemoved.pod',
    'lib/Net/Async/Slack/Event/UserTyping.pm',
    'lib/Net/Async/Slack/Event/UserTyping.pod',
    'lib/Net/Async/Slack/Event/ViewSubmission.pm',
    'lib/Net/Async/Slack/Event/ViewSubmission.pod',
    'lib/Net/Async/Slack/Event/WorkflowStepEdit.pm',
    'lib/Net/Async/Slack/Event/WorkflowStepEdit.pod',
    'lib/Net/Async/Slack/EventType.pm',
    'lib/Net/Async/Slack/Message.pm',
    'lib/Net/Async/Slack/RTM.pm',
    'lib/Net/Async/Slack/RTM.pod',
    'lib/Net/Async/Slack/Socket.pm',
    'lib/Net/Async/Slack/Socket.pod',
    't/00-check-deps.t',
    't/00-compile.t',
    't/00-report-prereqs.dd',
    't/00-report-prereqs.t',
    'xt/author/distmeta.t',
    'xt/author/eol.t',
    'xt/author/minimum-version.t',
    'xt/author/mojibake.t',
    'xt/author/no-tabs.t',
    'xt/author/pod-syntax.t',
    'xt/author/portability.t',
    'xt/author/test-version.t',
    'xt/release/common_spelling.t',
    'xt/release/cpan-changes.t'
);

notabs_ok($_) foreach @files;
done_testing;
