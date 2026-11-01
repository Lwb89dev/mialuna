import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/strings.dart';
import '../feed/widgets/post_card.dart' show closeFriendsGreen;
import '../profile/profile_widgets.dart';
import 'stories_controller.dart';
import 'story_viewer.dart';

/// Circular avatar rail above the Home feed, grouped by creator. A coloured
/// ring marks creators with stories you have not watched yet.
class StoriesRail extends ConsumerWidget {
  const StoriesRail({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(storiesProvider);
    final seen = ref.watch(seenStoriesProvider);
    if (state.groups.isEmpty) return const SizedBox.shrink();
    final theme = Theme.of(context);
    // Unseen creators first, as Instagram does.
    final groups = [...state.groups]
      ..sort((a, b) {
        final ua = a.stories.any((s) => !seen.contains(s.id)) ? 0 : 1;
        final ub = b.stories.any((s) => !seen.contains(s.id)) ? 0 : 1;
        return ua != ub ? ua - ub : b.latestTimestamp - a.latestTimestamp;
      });
    return SizedBox(
      height: 104,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemCount: groups.length,
        itemBuilder: (context, i) {
          final group = groups[i];
          final unseen = group.stories.any((s) => !seen.contains(s.id));
          return Semantics(
            button: true,
            label: context.l10n.storiesRailLabel(
              unseen
                  ? context.l10n.storiesStateUnseen
                  : context.l10n.storiesStateSeen,
            ),
            child: GestureDetector(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  fullscreenDialog: true,
                  builder: (_) =>
                      StoryViewerScreen(groups: groups, initialGroup: i),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                child: SizedBox(
                  width: 68,
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: unseen
                                ? (group.hasPrivate
                                      ? closeFriendsGreen
                                      : theme.colorScheme.secondary)
                                : theme.colorScheme.outlineVariant,
                            width: unseen ? 2.5 : 1.5,
                          ),
                        ),
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            ProfileAvatar(
                              pubkey: group.author,
                              radius: 27,
                              tappable: false,
                            ),
                            if (group.hasPrivate)
                              const Positioned(
                                right: -2,
                                bottom: -2,
                                child: CircleAvatar(
                                  radius: 9,
                                  backgroundColor: closeFriendsGreen,
                                  child: Icon(
                                    Icons.star,
                                    size: 12,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      AuthorName(
                        pubkey: group.author,
                        tappable: false,
                        style: theme.textTheme.labelSmall,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
