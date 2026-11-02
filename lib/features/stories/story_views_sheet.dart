import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/strings.dart';
import '../feed/widgets/post_card.dart' show formatPostTime;
import '../profile/profile_widgets.dart';
import 'story_views.dart';

/// Who watched one of your stories, most recent first.
class StoryViewersSheet extends ConsumerWidget {
  final String storyId;
  const StoryViewersSheet({super.key, required this.storyId});

  static Future<void> show(BuildContext context, String storyId) =>
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        showDragHandle: true,
        builder: (_) => StoryViewersSheet(storyId: storyId),
      );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final viewers = ref.watch(storyViewsProvider.select((s) => s.of(storyId)));
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.7,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Text(
              context.l10n.storySeenBy(viewers.length),
              style: theme.textTheme.titleMedium,
            ),
          ),
          if (viewers.isEmpty)
            Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                context.l10n.storyViewsEmpty,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
            )
          else
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: viewers.length,
                itemBuilder: (context, i) => ListTile(
                  leading: ProfileAvatar(pubkey: viewers[i].pubkey),
                  title: AuthorName(pubkey: viewers[i].pubkey),
                  trailing: Text(
                    formatPostTime(viewers[i].at),
                    style: theme.textTheme.bodySmall,
                  ),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Text(
              context.l10n.storyViewsHint,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
