import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../core/auth/auth_controller.dart';
import '../../l10n/strings.dart';
import '../explore/explore_screen.dart';
import '../feed/feed_controller.dart';
import '../feed/widgets/post_card.dart';
import '../messages/dm_controller.dart';
import '../messages/inbox_screen.dart';
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

  /// Refreshes posts and stories together.
  Future<void> _refresh() async {
    ref.read(relayPoolProvider).connect();
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
    final mode = isGuest ? FeedMode.discover : FeedMode.following;
    final feed = ref.watch(feedProvider(mode));
    final unread = ref.watch(dmProvider.select((s) => s.unreadCount));
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
            icon: const Icon(Icons.notifications_outlined),
            tooltip: context.l10n.notifications,
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const NotificationsScreen()),
            ),
          ),
          IconButton(
            tooltip: context.l10n.messages,
            icon: Badge(
              isLabelVisible: unread > 0 && !isGuest,
              label: Text('$unread'),
              child: const Icon(Icons.send_outlined),
            ),
            onPressed: () => Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => const InboxScreen())),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: _buildBody(context, feed, mode),
      ),
    );
  }

  Widget _buildBody(BuildContext context, FeedState feed, FeedMode mode) {
    final theme = Theme.of(context);
    final header = _FeedSwitch(guest: mode == FeedMode.discover);
    if (feed.posts.isEmpty) {
      // Always scrollable, so pull-to-refresh works on the empty states too.
      return ListView(
        controller: _scroll,
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          header,
          const StoriesRail(),
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
    return ListView.builder(
      controller: _scroll,
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: feed.posts.length + 3,
      itemBuilder: (context, i) {
        if (i == 0) return header;
        if (i == 1) return const StoriesRail();
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
        final post = feed.posts[i - 2];
        return PostCard(
          key: ValueKey(post.id),
          post: post,
          onHashtagTap: (tag) => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ExploreScreen(initialQuery: '#$tag'),
            ),
          ),
        );
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
