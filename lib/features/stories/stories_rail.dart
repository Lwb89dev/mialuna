import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/auth/auth_controller.dart';
import '../../core/nostr/models/media_event.dart';
import '../../l10n/strings.dart';
import '../feed/widgets/post_card.dart' show closeFriendsGreen;
import '../profile/profile_widgets.dart';
import 'stories_controller.dart';
import 'story_composer_screen.dart';
import 'story_ring.dart';
import 'story_viewer.dart';

/// What the rail shows, in order: the button that starts a story, your own
/// stories (once you have published any), then everyone else's, those you
/// have not watched yet first.
class StoriesRailModel {
  final bool canPost;
  final StoryGroup? own;
  final List<StoryGroup> others;

  const StoriesRailModel({
    required this.canPost,
    required this.own,
    required this.others,
  });

  factory StoriesRailModel.of({
    required List<StoryGroup> groups,
    required String? me,
    required Set<String> seen,
  }) {
    StoryGroup? own;
    final others = <StoryGroup>[];
    for (final g in groups) {
      if (g.author == me) {
        own = g;
      } else {
        others.add(g);
      }
    }
    // Unseen creators first, as Instagram does.
    others.sort((a, b) {
      final ua = hasUnseen(a, seen) ? 0 : 1;
      final ub = hasUnseen(b, seen) ? 0 : 1;
      return ua != ub ? ua - ub : b.latestTimestamp - a.latestTimestamp;
    });
    return StoriesRailModel(canPost: me != null, own: own, others: others);
  }

  static bool hasUnseen(StoryGroup g, Set<String> seen) =>
      g.stories.any((s) => !seen.contains(s.id));

  /// What the full-screen viewer plays, in the rail's order.
  List<StoryGroup> get playlist => [?own, ...others];

  bool get isEmpty => !canPost && own == null && others.isEmpty;
}

/// Circular avatar rail above the Home feed. It is always there for someone
/// who can post: the first circle — your picture with a plus — starts a new
/// story; once you have published, a second one with your picture and a ring
/// shows them. Every ring is divided into as many equal parts as the person
/// has stories from the last 24 hours, new ones coloured and seen ones grey.
class StoriesRail extends ConsumerWidget {
  const StoriesRail({super.key});

  static const _itemWidth = 68.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(storiesProvider);
    final seen = ref.watch(seenStoriesProvider);
    final me = ref.watch(authProvider.select((a) => a.publicKey));
    final model = StoriesRailModel.of(groups: state.groups, me: me, seen: seen);
    if (model.isEmpty) return const SizedBox.shrink();
    final items = <Widget>[
      if (model.canPost) _AddStory(me: me!, hasStories: model.own != null),
      if (model.own != null) _circle(context, model, seen, model.own!, 0),
      for (var i = 0; i < model.others.length; i++)
        _circle(
          context,
          model,
          seen,
          model.others[i],
          i + (model.own == null ? 0 : 1),
        ),
    ];
    // Room for the circle and one line of name, however large the text.
    final label = Theme.of(context).textTheme.labelSmall;
    final line = MediaQuery.textScalerOf(context).scale(label?.fontSize ?? 11);
    return SizedBox(
      height: 12 + 66 + 4 + (line * 1.5).ceilToDouble(),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        children: items,
      ),
    );
  }

  Widget _circle(
    BuildContext context,
    StoriesRailModel model,
    Set<String> seen,
    StoryGroup group,
    int playlistIndex,
  ) {
    final isOwn = identical(group, model.own);
    final unseen = StoriesRailModel.hasUnseen(group, seen);
    return _StoryCircle(
      group: group,
      seen: seen,
      isOwn: isOwn,
      label: unseen
          ? context.l10n.storiesStateUnseen
          : context.l10n.storiesStateSeen,
      // Full screen: over the tab bar too, not inside the Home tab.
      onTap: () => Navigator.of(context, rootNavigator: true).push(
        MaterialPageRoute(
          fullscreenDialog: true,
          builder: (_) => StoryViewerScreen(
            groups: model.playlist,
            initialGroup: playlistIndex,
          ),
        ),
      ),
    );
  }
}

/// What one story's part of a ring shows.
StorySegment storySegment(MediaPost story, {required bool seen}) {
  if (seen) return StorySegment.seen;
  return story.isPrivate ? StorySegment.closeFriends : StorySegment.unseen;
}

/// Your picture with a plus: starts a new story.
class _AddStory extends StatelessWidget {
  final String me;
  final bool hasStories;
  const _AddStory({required this.me, required this.hasStories});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    return Semantics(
      button: true,
      label: l10n.storyAddSemantics,
      child: GestureDetector(
        onTap: () => StoryComposerScreen.show(context),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
          child: SizedBox(
            width: StoriesRail._itemWidth,
            child: Column(
              children: [
                SizedBox(
                  width: 66,
                  height: 66,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      ProfileAvatar(pubkey: me, radius: 30, tappable: false),
                      Positioned(right: 0, bottom: 0, child: _plus(theme)),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  hasStories ? l10n.storyNew : l10n.storyYourStory,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelSmall,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _plus(ThemeData theme) => Container(
    width: 22,
    height: 22,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: theme.colorScheme.primary,
      border: Border.all(color: theme.scaffoldBackgroundColor, width: 2),
    ),
    child: Icon(Icons.add, size: 14, color: theme.colorScheme.onPrimary),
  );
}

/// One person's stories: the avatar inside a ring of equal parts.
class _StoryCircle extends StatelessWidget {
  final StoryGroup group;
  final Set<String> seen;
  final bool isOwn;
  final String label;
  final VoidCallback onTap;

  const _StoryCircle({
    required this.group,
    required this.seen,
    required this.isOwn,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final segments = [
      for (final s in group.stories) storySegment(s, seen: seen.contains(s.id)),
    ];
    return Semantics(
      button: true,
      label: isOwn
          ? context.l10n.storyOwnRailLabel(group.stories.length, label)
          : context.l10n.storiesRailLabel(label),
      child: GestureDetector(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
          child: SizedBox(
            width: StoriesRail._itemWidth,
            child: Column(
              children: [
                StoryRing(segments: segments, child: _avatar()),
                const SizedBox(height: 4),
                _name(context, theme),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _avatar() => Stack(
    clipBehavior: Clip.none,
    children: [
      ProfileAvatar(pubkey: group.author, radius: 27, tappable: false),
      if (group.hasPrivate)
        const Positioned(
          right: -2,
          bottom: -2,
          child: CircleAvatar(
            radius: 9,
            backgroundColor: closeFriendsGreen,
            child: Icon(Icons.star, size: 12, color: Colors.white),
          ),
        ),
    ],
  );

  Widget _name(BuildContext context, ThemeData theme) {
    if (isOwn) {
      return Text(
        context.l10n.storyYourStory,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.labelSmall,
      );
    }
    return AuthorName(
      pubkey: group.author,
      tappable: false,
      style: theme.textTheme.labelSmall,
    );
  }
}
