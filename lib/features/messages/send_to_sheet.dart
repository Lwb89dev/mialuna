import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/auth/auth_controller.dart';
import '../../core/nostr/models/media_event.dart';
import '../../l10n/strings.dart';
import '../profile/profile_widgets.dart';
import '../search/people_search.dart';
import 'dm_controller.dart';
import 'share_utils.dart';

/// "Send to…" sheet used to forward a post, reel or story as a private
/// message (NIP-17) straight from the feed, the Reels viewer or the story
/// viewer. Also offers copying the plain link.
class SendToSheet extends ConsumerStatefulWidget {
  final MediaPost post;
  const SendToSheet({super.key, required this.post});

  static Future<void> show(BuildContext context, MediaPost post) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (_) => SendToSheet(post: post),
    );
  }

  @override
  ConsumerState<SendToSheet> createState() => _SendToSheetState();
}

class _SendToSheetState extends ConsumerState<SendToSheet> {
  final _search = TextEditingController();
  final _note = TextEditingController();
  final Set<String> _selected = {};
  bool _sending = false;

  @override
  void dispose() {
    _search.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (_selected.isEmpty || _sending) return;
    setState(() => _sending = true);
    final reference = shareReference(
      ProviderScope.containerOf(context),
      widget.post,
    );
    final note = _note.text.trim();
    final text = note.isEmpty ? reference : '$note\n$reference';
    final result = await ref
        .read(dmProvider.notifier)
        .sendToMany(_selected, text);
    if (!mounted) return;
    setState(() => _sending = false);
    final messenger = ScaffoldMessenger.of(context);
    Navigator.of(context).pop();
    if (result.failures.isEmpty) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            result.sent == 1
                ? context.l10n.sent
                : context.l10n.sentToPeople(result.sent),
          ),
        ),
      );
    } else {
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            result.sent > 0
                ? context.l10n.sentToPeopleWithFailure(
                    result.sent,
                    result.failures.first,
                  )
                : result.failures.first,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final auth = ref.watch(authProvider);
    final dm = ref.watch(dmProvider);
    final bottom = MediaQuery.viewInsetsOf(context).bottom;

    if (auth.isGuest || !dm.supported) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              auth.isGuest
                  ? context.l10n.signInToSendPrivateMessages
                  : context.l10n.signerNoPrivateMessagesShort,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            _CopyLinkButton(post: widget.post),
          ],
        ),
      );
    }

    final search = ref.watch(peopleSearchProvider);
    final candidates = search.results;
    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.78,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: TextField(
                controller: _search,
                onChanged: ref.read(peopleSearchProvider.notifier).setQuery,
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
            Expanded(
              child: candidates.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          search.searching
                              ? context.l10n.searching
                              : search.query.isEmpty
                              ? context.l10n.followToStartOrSearch
                              : context.l10n.noOneWithNameHint,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.outline,
                          ),
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: candidates.length,
                      itemBuilder: (context, i) {
                        final pubkey = candidates[i];
                        final selected = _selected.contains(pubkey);
                        return CheckboxListTile(
                          value: selected,
                          onChanged: (v) => setState(() {
                            v == true
                                ? _selected.add(pubkey)
                                : _selected.remove(pubkey);
                          }),
                          secondary: ProfileAvatar(
                            pubkey: pubkey,
                            radius: 20,
                            tappable: false,
                          ),
                          title: AuthorName(pubkey: pubkey, tappable: false),
                          subtitle: ProfileHandle(
                            pubkey: pubkey,
                            style: theme.textTheme.bodySmall,
                          ),
                          controlAffinity: ListTileControlAffinity.trailing,
                        );
                      },
                    ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _note,
                      maxLines: 2,
                      minLines: 1,
                      decoration: InputDecoration(
                        hintText: context.l10n.addMessage,
                        isDense: true,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.icon(
                    onPressed: _selected.isEmpty || _sending ? null : _send,
                    icon: _sending
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.send, size: 18),
                    label: Text(
                      _selected.length > 1
                          ? context.l10n.sendWithCount(_selected.length)
                          : context.l10n.send,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _CopyLinkButton(post: widget.post),
            ),
          ],
        ),
      ),
    );
  }
}

class _CopyLinkButton extends ConsumerWidget {
  final MediaPost post;
  const _CopyLinkButton({required this.post});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TextButton.icon(
      icon: const Icon(Icons.link, size: 18),
      label: Text(context.l10n.copyLink),
      onPressed: () {
        final link = shareReference(ProviderScope.containerOf(context), post);
        Clipboard.setData(ClipboardData(text: link));
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(context.l10n.linkCopied)));
      },
    );
  }
}
