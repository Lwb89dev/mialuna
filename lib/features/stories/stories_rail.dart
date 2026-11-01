import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'stories_controller.dart';
import 'story_viewer.dart';

/// Circular avatar rail above the Home feed, grouped by creator.
class StoriesRail extends ConsumerWidget {
  const StoriesRail({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(storiesProvider);
    if (state.groups.isEmpty) return const SizedBox.shrink();
    final theme = Theme.of(context);
    return SizedBox(
      height: 96,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemCount: state.groups.length,
        itemBuilder: (context, i) {
          final group = state.groups[i];
          return GestureDetector(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) =>
                    StoryViewerScreen(groups: state.groups, initialGroup: i),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: theme.colorScheme.secondary,
                        width: 2.5,
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 28,
                      child: Text(group.author.substring(0, 2).toUpperCase()),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${group.author.substring(0, 6)}…',
                    style: theme.textTheme.labelSmall,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
