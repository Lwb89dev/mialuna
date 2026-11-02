import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' show DateFormat;

import '../../core/auth/auth_controller.dart';
import '../../core/nostr/nip19.dart';
import '../../l10n/strings.dart';
import '../../core/platform/secure_window.dart';
import '../profile/profile_widgets.dart';
import '../search/people_search.dart';
import 'chat_screen.dart';
import 'dm_controller.dart';

String formatChatTime(int createdAtSeconds) {
  final dt = DateTime.fromMillisecondsSinceEpoch(createdAtSeconds * 1000);
  final now = DateTime.now();
  final diff = now.difference(dt);
  final l10n = AppStrings.current;
  if (diff.inMinutes < 1) return l10n.now;
  if (dt.day == now.day && diff.inHours < 24) {
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
  if (diff.inDays < 7) {
    return l10n.weekdayShort(
      const ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'][dt.weekday - 1],
    );
  }
  return DateFormat.Md(l10n.localeName).format(dt);
}

/// What a message looks like in a conversation list.
String previewOf(DmMessage m) {
  final prefix = m.fromMe ? AppStrings.current.youPrefix : '';
  if (Nip19.eventRefPattern.hasMatch(m.text)) {
    final rest = m.text.replaceAll(Nip19.eventRefPattern, '').trim();
    return '$prefix${rest.isEmpty ? AppStrings.current.sharedAMoment : rest}';
  }
  return '$prefix${m.text}';
}

class InboxScreen extends ConsumerWidget {
  /// Shows the message requests (conversations started by people outside
  /// your web of trust) instead of the inbox.
  final bool requests;
  const InboxScreen({super.key, this.requests = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final dm = ref.watch(dmProvider);
    final theme = Theme.of(context);

    Widget body;
    if (auth.isGuest) {
      body = _Notice(
        icon: Icons.lock_outline,
        text: context.l10n.signInToReadMessages,
        action: FilledButton(
          onPressed: () => context.go('/login'),
          child: Text(context.l10n.signIn),
        ),
      );
    } else if (!dm.supported) {
      body = _Notice(
        icon: Icons.key_off_outlined,
        text: context.l10n.signerNoPrivateMessagesLong,
      );
    } else {
      final conversations = requests ? dm.requests : dm.sorted;
      body = ListView(
        children: [
          if (requests)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                context.l10n.messageRequestsHint,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
            )
          else if (dm.requests.isNotEmpty)
            ListTile(
              leading: const Icon(Icons.mark_email_unread_outlined),
              title: Text(context.l10n.messageRequests),
              subtitle: Text(
                context.l10n.messageRequestsSubtitle(dm.requests.length),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const InboxScreen(requests: true),
                ),
              ),
            ),
          if (dm.inboxConfigured == false && !requests) _SetupBanner(),
          if (dm.error != null)
            ListTile(
              leading: Icon(
                Icons.error_outline,
                color: theme.colorScheme.error,
              ),
              title: Text(dm.error!),
              trailing: TextButton(
                onPressed: () => ref.read(dmProvider.notifier).retry(),
                child: Text(context.l10n.retry),
              ),
            ),
          if (dm.loading && conversations.isEmpty)
            const Padding(
              padding: EdgeInsets.all(32),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (conversations.isEmpty && !requests)
            Padding(
              padding: const EdgeInsets.all(32),
              child: Text(
                context.l10n.inboxEmpty,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
            ),
          for (final c in conversations)
            ListTile(
              leading: ProfileAvatar(
                pubkey: c.peer,
                radius: 24,
                tappable: false,
              ),
              title: AuthorName(
                pubkey: c.peer,
                tappable: false,
                style: c.unread > 0
                    ? theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      )
                    : theme.textTheme.titleSmall,
              ),
              subtitle: Text(
                previewOf(c.last!),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: c.unread > 0
                    ? const TextStyle(fontWeight: FontWeight.w600)
                    : null,
              ),
              trailing: SizedBox(
                width: 56,
                child: FittedBox(
                  alignment: Alignment.centerRight,
                  fit: BoxFit.scaleDown,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        formatChatTime(c.last!.createdAt),
                        style: theme.textTheme.bodySmall,
                      ),
                      if (c.unread > 0)
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.secondary,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${c.unread}',
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              onTap: () => ChatScreen.open(context, c.peer),
            ),
        ],
      );
    }

    return SecureScreen(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            requests ? context.l10n.messageRequests : context.l10n.messages,
          ),
          actions: [
            if (!auth.isGuest && dm.supported && !requests)
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                tooltip: context.l10n.newMessage,
                onPressed: () => _newChat(context, ref),
              ),
          ],
        ),
        body: body,
      ),
    );
  }

  Future<void> _newChat(BuildContext context, WidgetRef ref) async {
    final peer = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (_) => const _NewChatSheet(),
    );
    if (peer != null && context.mounted) ChatScreen.open(context, peer);
  }
}

class _Notice extends StatelessWidget {
  final IconData icon;
  final String text;
  final Widget? action;
  const _Notice({required this.icon, required this.text, this.action});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: theme.colorScheme.tertiary),
            const SizedBox(height: 16),
            Text(
              text,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge,
            ),
            if (action != null) ...[const SizedBox(height: 16), action!],
          ],
        ),
      ),
    );
  }
}

class _SetupBanner extends ConsumerStatefulWidget {
  @override
  ConsumerState<_SetupBanner> createState() => _SetupBannerState();
}

class _SetupBannerState extends ConsumerState<_SetupBanner> {
  bool _busy = false;

  Future<void> _enable() async {
    setState(() => _busy = true);
    final ok = await ref
        .read(dmProvider.notifier)
        .publishInboxRelays(defaultInboxRelays);
    if (!mounted) return;
    setState(() => _busy = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok
              ? context.l10n.privateMessagesEnabled
              : context.l10n.enableMessagesFailed,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.all(12),
      color: theme.colorScheme.secondaryContainer.withValues(alpha: 0.35),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n.enablePrivateMessages,
              style: theme.textTheme.titleSmall,
            ),
            const SizedBox(height: 6),
            Text(
              context.l10n.enablePrivateMessagesExplain(
                defaultInboxRelays.length,
              ),
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: _busy ? null : _enable,
              child: _busy
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(context.l10n.turnOn),
            ),
          ],
        ),
      ),
    );
  }
}

/// Picks one person to start a conversation with.
class _NewChatSheet extends ConsumerStatefulWidget {
  const _NewChatSheet();

  @override
  ConsumerState<_NewChatSheet> createState() => _NewChatSheetState();
}

class _NewChatSheetState extends ConsumerState<_NewChatSheet> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final search = ref.watch(peopleSearchProvider);
    final shown = search.results;
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.7,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: TextField(
                controller: _controller,
                autofocus: true,
                onChanged: ref.read(peopleSearchProvider.notifier).setQuery,
                enableIMEPersonalizedLearning: false,
                decoration: InputDecoration(
                  hintText: context.l10n.searchByNameOrUsername,
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  isDense: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            if (search.searching) const LinearProgressIndicator(minHeight: 2),
            Expanded(
              child: shown.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          search.searching
                              ? context.l10n.searching
                              : context.l10n.noOneWithNameHint,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.outline,
                          ),
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: shown.length,
                      itemBuilder: (context, i) => ListTile(
                        leading: ProfileAvatar(
                          pubkey: shown[i],
                          tappable: false,
                        ),
                        title: AuthorName(pubkey: shown[i], tappable: false),
                        subtitle: ProfileHandle(
                          pubkey: shown[i],
                          style: theme.textTheme.bodySmall,
                        ),
                        onTap: () => Navigator.of(context).pop(shown[i]),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
