import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/auth/auth_controller.dart';
import '../../l10n/strings.dart';
import '../feed/widgets/post_card.dart' show closeFriendsGreen;
import '../profile/profile_widgets.dart';
import 'close_friends.dart';
import 'people_picker.dart';

/// Short, honest explanation of what "close friends" does and does not do.
/// Shown here, in onboarding and the first time the audience is switched.
class CloseFriendsExplainer extends StatelessWidget {
  final bool compact;
  const CloseFriendsExplainer({super.key, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    Widget bullet(IconData icon, String text) => Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: closeFriendsGreen),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: theme.textTheme.bodyMedium)),
        ],
      ),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        bullet(Icons.group_outlined, context.l10n.closeFriendsExplain1),
        bullet(Icons.lock_outline, context.l10n.closeFriendsExplain2),
        if (!compact) ...[
          bullet(
            Icons.warning_amber_outlined,
            context.l10n.closeFriendsExplain3,
          ),
          bullet(Icons.smartphone_outlined, context.l10n.closeFriendsExplain4),
          bullet(Icons.public, context.l10n.closeFriendsExplain5),
          bullet(Icons.cloud_off_outlined, context.l10n.closeFriendsExplain6),
        ],
      ],
    );
  }
}

/// Manage the close-friends list.
class CloseFriendsScreen extends ConsumerStatefulWidget {
  const CloseFriendsScreen({super.key});

  static Future<void> open(BuildContext context) =>
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (_) => const CloseFriendsScreen()));

  @override
  ConsumerState<CloseFriendsScreen> createState() => _CloseFriendsScreenState();
}

class _CloseFriendsScreenState extends ConsumerState<CloseFriendsScreen> {
  @override
  void initState() {
    super.initState();
    // Read the list other devices may have changed.
    Future.microtask(() => ref.read(closeFriendsProvider.notifier).sync());
  }

  Future<void> _add() async {
    final state = ref.read(closeFriendsProvider);
    final picked = await PeoplePickerSheet.show(
      context,
      exclude: state.members.toSet(),
      title: context.l10n.addToCloseFriends,
      limit: CloseFriendsController.maxMembers - state.members.length,
    );
    if (picked == null || picked.isEmpty) return;
    final added = await ref.read(closeFriendsProvider.notifier).add(picked);
    if (mounted && added < picked.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.l10n.maxFriendsReached(
              CloseFriendsController.maxMembers,
              added,
            ),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final auth = ref.watch(authProvider);
    final state = ref.watch(closeFriendsProvider);
    final canUse = !auth.isGuest && auth.signer.canEncrypt;
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.closeFriends),
        actions: [
          if (canUse)
            IconButton(
              icon: const Icon(Icons.person_add_alt_1_outlined),
              tooltip: context.l10n.add,
              onPressed: _add,
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const CloseFriendsExplainer(),
          const SizedBox(height: 16),
          if (!canUse)
            Text(
              auth.isGuest
                  ? context.l10n.signInToCreateList
                  : context.l10n.signerNoCloseFriends,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.error,
              ),
            )
          else ...[
            Row(
              children: [
                Text(
                  context.l10n.peopleOfMax(
                    state.members.length,
                    CloseFriendsController.maxMembers,
                  ),
                  style: theme.textTheme.titleSmall,
                ),
                const Spacer(),
                if (state.syncing)
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
            if (state.error != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  state.error!,
                  style: TextStyle(color: theme.colorScheme.error),
                ),
              ),
            const SizedBox(height: 8),
            if (state.members.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Column(
                  children: [
                    Icon(
                      Icons.star_outline,
                      size: 48,
                      color: theme.colorScheme.tertiary,
                    ),
                    const SizedBox(height: 8),
                    Text(context.l10n.noOneYet),
                    const SizedBox(height: 12),
                    FilledButton.tonalIcon(
                      onPressed: _add,
                      icon: const Icon(Icons.person_add_alt_1_outlined),
                      label: Text(context.l10n.addPeople),
                    ),
                  ],
                ),
              )
            else
              for (final pk in state.members)
                _FriendTile(
                  pubkey: pk,
                  onRemove: () =>
                      ref.read(closeFriendsProvider.notifier).remove(pk),
                ),
          ],
        ],
      ),
    );
  }
}

class _FriendTile extends ConsumerWidget {
  final String pubkey;
  final VoidCallback onRemove;
  const _FriendTile({required this.pubkey, required this.onRemove});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final reachable = ref.watch(friendReachableProvider(pubkey)).valueOrNull;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: ProfileAvatar(pubkey: pubkey, radius: 22),
      title: AuthorName(pubkey: pubkey),
      subtitle: reachable == false
          ? Text(
              context.l10n.friendNoPrivateMessagesWarning,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
              ),
            )
          : ProfileHandle(pubkey: pubkey, style: theme.textTheme.bodySmall),
      trailing: IconButton(
        icon: const Icon(Icons.remove_circle_outline),
        tooltip: context.l10n.removeFromList,
        onPressed: onRemove,
      ),
    );
  }
}
