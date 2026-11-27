import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' show DateFormat;

import '../../app/providers.dart';
import '../../core/text/clip.dart';
import '../../l10n/strings.dart';
import '../feed/widgets/inline_video.dart';
import '../feed/widgets/nostr_image.dart';
import 'story_cleanup.dart';

/// "Story deletion": every story of yours the phone remembers, what happened
/// to it, and what can still be asked: delete, ask again, keep, or check
/// whether the media server still serves its files.
class StoryHistoryScreen extends ConsumerWidget {
  const StoryHistoryScreen({super.key});

  static Future<void> open(BuildContext context) => Navigator.of(
    context,
    rootNavigator: true,
  ).push<void>(MaterialPageRoute(builder: (_) => const StoryHistoryScreen()));

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(storyCleanupProvider);
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final quiet = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.outline,
    );
    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.storyHistory,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        bottom: state.busy
            ? const PreferredSize(
                preferredSize: Size.fromHeight(3),
                child: LinearProgressIndicator(minHeight: 3),
              )
            : null,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          Text(l10n.storyHistoryExplain, style: quiet),
          const SizedBox(height: 8),
          if (state.stories.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 48),
              child: Text(
                l10n.storyHistoryEmpty,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
            ),
          for (final story in state.stories)
            _StoryEntry(
              key: ValueKey(story.post.id),
              story: story,
              busy: state.busy,
            ),
        ],
      ),
    );
  }
}

class _StoryEntry extends ConsumerWidget {
  final TrackedStory story;
  final bool busy;
  const _StoryEntry({super.key, required this.story, required this.busy});

  String _status(AppLocalizations l10n) => switch (story.fate) {
    StoryFate.live =>
      story.automatic ? l10n.storyStateLive : l10n.storyStateLiveManual,
    StoryFate.waiting =>
      story.automatic ? l10n.storyStateWaiting : l10n.storyStateExpiredManual,
    StoryFate.deleted => l10n.storyStateDeleted,
    StoryFate.kept => l10n.storyStateKept,
    StoryFate.failed => l10n.storyStateFailed,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final post = story.post;
    final when = DateFormat.yMMMd(l10n.localeName)
        .add_Hm()
        .format(DateTime.fromMillisecondsSinceEpoch(post.createdAt * 1000));
    final actions = _actions(context, ref);
    return Card(
      margin: const EdgeInsets.only(top: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _picture(theme),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(when, style: theme.textTheme.titleSmall),
                      const SizedBox(height: 2),
                      Text(
                        _status(l10n),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: story.fate == StoryFate.failed
                              ? theme.colorScheme.error
                              : theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      if (story.mediaLeft.isNotEmpty &&
                          story.fate != StoryFate.deleted)
                        Text(
                          l10n.storyFilesNotConfirmed(
                            story.mediaLeft.join(', '),
                          ),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.error,
                          ),
                        ),
                      if (post.caption.isNotEmpty)
                        Text(
                          clipForDisplay(post.caption),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall,
                        ),
                    ],
                  ),
                ),
              ],
            ),
            if (actions.isNotEmpty)
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: Wrap(
                  alignment: WrapAlignment.end,
                  spacing: 4,
                  children: actions,
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// The picture while it is there to be shown; a sign in its place once it
  /// is deleted, or when it is encrypted.
  Widget _picture(ThemeData theme) {
    final item = story.post.media.first;
    final Widget child;
    if (story.post.isPrivate || story.fate == StoryFate.deleted) {
      child = ColoredBox(
        color: theme.colorScheme.surfaceContainerHighest,
        child: Icon(
          story.post.isPrivate ? Icons.lock_outline : Icons.delete_outline,
          color: theme.colorScheme.outline,
        ),
      );
    } else if (item.isVideo) {
      child = VideoPoster(item: item);
    } else {
      child = NostrImage(item: item);
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(width: 56, height: 84, child: child),
    );
  }

  List<Widget> _actions(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final cleanup = ref.read(storyCleanupProvider.notifier);
    final id = story.post.id;
    // A close-friends story is neither kept (nothing could open its files
    // later) nor asked again (the key that deletes them is gone with them).
    final public = !story.post.isPrivate;
    final over = story.post.isExpired(ref.read(unixClockProvider)());

    Widget action(String label, VoidCallback onPressed) =>
        TextButton(onPressed: busy ? null : onPressed, child: Text(label));
    Widget keep() =>
        action(l10n.storyKeep, () => unawaited(cleanup.setKeep(id, true)));
    Widget deleteLater() => action(
      l10n.storyDeleteWhenExpired,
      () => unawaited(cleanup.setKeep(id, false)),
    );
    Widget check() =>
        action(l10n.storyCheckFiles, () => unawaited(_check(context, ref)));
    Widget delete(String label) =>
        action(label, () => unawaited(_delete(context, ref)));

    return switch (story.fate) {
      StoryFate.live when public => [story.automatic ? keep() : deleteLater()],
      StoryFate.live => const [],
      StoryFate.waiting => [if (public) keep(), delete(l10n.storyCleanupNow)],
      StoryFate.failed => [if (public) keep(), delete(l10n.storyAskAgain)],
      StoryFate.deleted => [
        check(),
        if (public) action(l10n.storyAskAgain, () => _askAgain(context, ref)),
      ],
      StoryFate.kept => [
        if (over) ...[check(), delete(l10n.storyCleanupNow)] else deleteLater(),
      ],
    };
  }

  Future<void> _check(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    final result = await ref
        .read(storyCleanupProvider.notifier)
        .checkFiles(story.post.id);
    if (!messenger.mounted) return;
    final text = result.online.isNotEmpty
        ? l10n.storyCheckOnline(result.online.join(', '))
        : result.unclear
        ? l10n.storyCheckUnclear
        : l10n.storyCheckGone;
    messenger.showSnackBar(SnackBar(content: Text(text)));
  }

  /// Deleting something that was being kept asks first: there is no way back.
  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    if (story.fate == StoryFate.kept) {
      final l10n = context.l10n;
      final sure = await showDialog<bool>(
        context: context,
        builder: (dialog) => AlertDialog(
          title: Text(l10n.deleteStoryTitle),
          content: SingleChildScrollView(child: Text(l10n.deletePostBody)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialog, false),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialog, true),
              child: Text(l10n.deletePost),
            ),
          ],
        ),
      );
      if (sure != true || !context.mounted) return;
    }
    await _askAgain(context, ref);
  }

  Future<void> _askAgain(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    final done = await ref
        .read(storyCleanupProvider.notifier)
        .deleteNow(story.post.id);
    if (!messenger.mounted) return;
    messenger.showSnackBar(
      SnackBar(
        content: Text(done ? l10n.storyCleanupDone : l10n.storyCleanupPartly),
      ),
    );
  }
}
