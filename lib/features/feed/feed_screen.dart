import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../core/nostr/models/media_event.dart';
import '../../core/auth/auth_controller.dart';
import '../../l10n/strings.dart';
import '../explore/hashtag_link.dart';
import '../feed/feed_controller.dart';
import '../feed/widgets/count_badge.dart';
import '../feed/widgets/post_card.dart';
import '../messages/dm_controller.dart';
import '../messages/inbox_screen.dart';
import '../notifications/notifications_controller.dart';
import '../notifications/notifications_screen.dart';
import '../settings/settings_controller.dart';
import '../stories/stories_controller.dart';
import '../stories/stories_rail.dart';

/// Home: the posts of the people you follow. Everything else lives in the
/// Discover tab. Guests (who cannot follow anyone) see Discover here.
class FeedScreen extends ConsumerStatefulWidget {
  const FeedScreen({super.key});

  @override
  ConsumerState<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends ConsumerState<FeedScreen> {
  final _scroll = ScrollController();

  /// One card widget per post, kept while the post is in the feed. Every
  /// change of the feed rebuilds the list; handing Flutter the very same card
  /// tells it that nothing in it changed, so scrolling during a load does
  /// not rebuild every card on screen each time a page arrives.
  final Map<String, PostCard> _cards = {};
  List<MediaPost>? _cardsFor;

  PostCard _card(MediaPost post) => _cards[post.id] ??= PostCard(
    key: ValueKey(post.id),
    post: post,
    onHashtagTap: _openHashtag,
  );

  void _openHashtag(String tag) => openHashtagSearch(context, tag);

  /// Forgets the cards of posts that left the feed.
  void _keepCardsOf(List<MediaPost> posts) {
    if (identical(posts, _cardsFor)) return;
    _cardsFor = posts;
    final live = {for (final p in posts) p.id};
    _cards.removeWhere((id, _) => !live.contains(id));
  }

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_maybeLoadMore);
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  FeedMode get _mode =>
      ref.read(authProvider).isGuest ? FeedMode.discover : FeedMode.following;

  void _maybeLoadMore() {
    if (!_scroll.hasClients) return;
    if (_scroll.position.extentAfter < 1400) {
      ref.read(feedProvider(_mode).notifier).loadMore();
    }
  }

  /// Refreshes posts and stories together. The connections are checked
  /// first: after the phone slept they are often dead without knowing it, and
  /// a refresh sent into them would bring nothing back.
  Future<void> _refresh() async {
    final pool = ref.read(relayPoolProvider);
    pool.connect();
    await pool.wake();
    if (!mounted) return;
    await Future.wait([
      ref.read(feedProvider(_mode).notifier).refresh(),
      ref.read(storiesProvider.notifier).refresh(),
    ]);
  }

  /// Tapping Home while already on Home: back to the top, then refresh.
  Future<void> _scrollTopAndRefresh() async {
    if (_scroll.hasClients && _scroll.offset > 40) {
      final reduce = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
      if (reduce) {
        _scroll.jumpTo(0);
      } else {
        await _scroll.animateTo(
          0,
          duration: const Duration(milliseconds: 380),
          curve: Curves.easeOutCubic,
        );
      }
    }
    await _refresh();
  }

  @override
  Widget build(BuildContext context) {
    final isGuest = ref.watch(authProvider.select((a) => a.isGuest));
    // The saved session is still being read: this is not a guest, so neither
    // the Discover feed nor the stories of "everybody" are started for it.
    final restoring = ref.watch(authProvider.select((a) => a.restoring));
    final mode = isGuest ? FeedMode.discover : FeedMode.following;
    final feed = restoring ? const FeedState() : ref.watch(feedProvider(mode));
    final unreadMessages = isGuest
        ? 0
        : ref.watch(dmProvider.select((s) => s.unreadCount));
    // Watching it here keeps the notifications subscription alive for the
    // whole session, so the bell knows about news before it is opened.
    final unseenNotifications = ref.watch(
      notificationsProvider.select((s) => s.unreadCount),
    );
    final theme = Theme.of(context);

    ref.listen(tabReselectProvider, (_, event) {
      if (event != null && event.branch == 0) _scrollTopAndRefresh();
    });
    // A different relay list (e.g. the user's NIP-65 list was just adopted)
    // means different content.
    ref.listen(settingsProvider.select((s) => s.relays), (prev, next) {
      if (prev != null) _refresh();
    });

    return Scaffold(
      appBar: AppBar(
        title: Semantics(
          label: 'Mialuna',
          excludeSemantics: true,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Decoded at 3x the displayed size instead of the full 1254 px.
              Image.asset(
                'assets/icons/icon.png',
                width: 32,
                height: 32,
                cacheWidth: 96,
                filterQuality: FilterQuality.medium,
              ),
              const SizedBox(width: 10),
              Flexible(
                child: Text(
                  'mialuna',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: CountBadge(
              count: unseenNotifications,
              child: const Icon(Icons.notifications_outlined),
            ),
            tooltip: unseenNotifications > 0
                ? context.l10n.notificationsNew(unseenNotifications)
                : context.l10n.notifications,
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const NotificationsScreen()),
            ),
          ),
          IconButton(
            tooltip: unreadMessages > 0
                ? context.l10n.messagesUnread(unreadMessages)
                : context.l10n.messages,
            icon: CountBadge(
              count: unreadMessages,
              child: const Icon(Icons.send_outlined),
            ),
            onPressed: () => Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => const InboxScreen())),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: _buildBody(context, feed, mode, restoring: restoring),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    FeedState feed,
    FeedMode mode, {
    bool restoring = false,
  }) {
    final theme = Theme.of(context);
    final header = _FeedSwitch(guest: mode == FeedMode.discover);
    final stories = restoring ? const SizedBox.shrink() : const StoriesRail();
    if (feed.posts.isEmpty) {
      // Always scrollable, so pull-to-refresh works on the empty states too.
      return ListView(
        controller: _scroll,
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          header,
          stories,
          if (feed.isLoading || feed.isRefreshing)
            for (var i = 0; i < 2; i++) const _PostSkeleton()
          else if (feed.followsNobody)
            _EmptyHint(
              icon: Icons.group_add_outlined,
              text: context.l10n.homeEmptyFollowsNobody,
              primaryLabel: context.l10n.discoverPeople,
              onPrimary: () => context.go('/explore'),
            )
          else
            _EmptyHint(
              icon: Icons.nightlight_round,
              text: feed.error ?? context.l10n.homeEmpty,
              primaryLabel: context.l10n.retry,
              onPrimary: _refresh,
              secondaryLabel: mode == FeedMode.following
                  ? context.l10n.tabDiscover
                  : null,
              onSecondary: () => context.go('/explore'),
            ),
        ],
      );
    }
    _keepCardsOf(feed.posts);
    return ListView.builder(
      controller: _scroll,
      physics: const AlwaysScrollableScrollPhysics(),
      // Pictures start loading a couple of screens before they are reached,
      // so scrolling does not show grey boxes.
      // ignore: deprecated_member_use
      cacheExtent: 1500,
      itemCount: feed.posts.length + 3,
      itemBuilder: (context, i) {
        if (i == 0) return header;
        if (i == 1) return stories;
        if (i == feed.posts.length + 2) {
          if (feed.isLoadingMore) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          if (!feed.hasMore) {
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Text(
                    context.l10n.seenEverything,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall,
                  ),
                  if (mode == FeedMode.following)
                    TextButton(
                      onPressed: () => context.go('/explore'),
                      child: Text(context.l10n.discoverMoreProfiles),
                    ),
                ],
              ),
            );
          }
          return const SizedBox(height: 48);
        }
        return _card(feed.posts[i - 2]);
      },
    );
  }
}

/// Says which feed this is, and jumps to the other one.
class _FeedSwitch extends StatelessWidget {
  final bool guest;
  const _FeedSwitch({required this.guest});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 4),
      child: Wrap(
        spacing: 8,
        runSpacing: 4,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          ChoiceChip(
            label: Text(
              guest ? context.l10n.tabDiscover : context.l10n.feedFollowing,
            ),
            selected: true,
            onSelected: (_) {},
          ),
          if (!guest)
            ActionChip(
              label: Text(context.l10n.tabDiscover),
              avatar: const Icon(Icons.explore_outlined, size: 18),
              onPressed: () => context.go('/explore'),
            ),
          if (guest)
            Text(
              context.l10n.signInToSeeFollowed,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
        ],
      ),
    );
  }
}

class _EmptyHint extends StatelessWidget {
  final IconData icon;
  final String text;
  final String primaryLabel;
  final VoidCallback onPrimary;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;

  const _EmptyHint({
    required this.icon,
    required this.text,
    required this.primaryLabel,
    required this.onPrimary,
    this.secondaryLabel,
    this.onSecondary,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 56, 24, 24),
      child: Column(
        children: [
          Icon(icon, size: 64, color: theme.colorScheme.tertiary),
          const SizedBox(height: 16),
          Text(
            text,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge,
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            alignment: WrapAlignment.center,
            children: [
              FilledButton.tonal(
                onPressed: onPrimary,
                child: Text(primaryLabel),
              ),
              if (secondaryLabel != null)
                OutlinedButton(
                  onPressed: onSecondary,
                  child: Text(secondaryLabel!),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PostSkeleton extends StatelessWidget {
  const _PostSkeleton();

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.surfaceContainerHighest;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Column(
        children: [
          ListTile(
            leading: CircleAvatar(backgroundColor: color),
            title: Container(height: 12, width: 120, color: color),
            subtitle: Container(height: 10, width: 60, color: color),
          ),
          AspectRatio(aspectRatio: 1, child: ColoredBox(color: color)),
          const SizedBox(height: 56),
        ],
      ),
    );
  }
}
