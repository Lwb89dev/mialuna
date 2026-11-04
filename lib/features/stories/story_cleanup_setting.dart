import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/auth/auth_controller.dart';
import '../../core/nostr/signer.dart';
import '../../l10n/strings.dart';
import 'story_cleanup.dart';

/// Settings: whether expired stories are taken down from the relays and the
/// media servers. With Amber or a remote signer, which would have to approve
/// from a timer, the cleanup waits for a button instead.
class StoryCleanupSetting extends ConsumerWidget {
  const StoryCleanupSetting({super.key});

  Future<void> _now(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    final cleanup = ref.read(storyCleanupProvider.notifier);
    final done = await cleanup.run(ask: true);
    if (!messenger.mounted) return;
    messenger.showSnackBar(
      SnackBar(
        content: Text(done ? l10n.storyCleanupDone : l10n.storyCleanupPartly),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final signer = ref.watch(authProvider.select((a) => a.signer));
    if (!signer.canSign) return const SizedBox.shrink();
    final due = ref.watch(storyCleanupProvider.select((s) => s.due));
    final asks = signer.type != SignerType.nsec;
    return Column(
      children: [
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          secondary: const Icon(Icons.auto_delete_outlined),
          title: Text(context.l10n.storyCleanupSetting),
          subtitle: Text(context.l10n.storyCleanupSettingExplain),
          value: ref.watch(deleteExpiredStoriesProvider),
          onChanged: ref.read(deleteExpiredStoriesProvider.notifier).set,
        ),
        if (asks && due > 0)
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.hourglass_bottom_outlined),
            title: Text(context.l10n.storyCleanupWaiting(due)),
            trailing: TextButton(
              onPressed: () => _now(context, ref),
              child: Text(context.l10n.storyCleanupNow),
            ),
          ),
      ],
    );
  }
}
