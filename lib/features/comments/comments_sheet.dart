import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/auth/auth_controller.dart';
import '../../core/nostr/models/media_event.dart';
import '../social/interactions_controller.dart';

/// Bottom sheet with the comment thread (NIP-22) and composer.
class CommentsSheet extends ConsumerStatefulWidget {
  final MediaPost post;
  const CommentsSheet({super.key, required this.post});

  static Future<void> show(BuildContext context, MediaPost post) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.7,
          child: CommentsSheet(post: post),
        ),
      ),
    );
  }

  @override
  ConsumerState<CommentsSheet> createState() => _CommentsSheetState();
}

class _CommentsSheetState extends ConsumerState<CommentsSheet> {
  final _controller = TextEditingController();
  bool _sending = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _sending) return;
    setState(() => _sending = true);
    final comment = await ref
        .read(interactionsProvider(widget.post).notifier)
        .comment(widget.post, text);
    if (mounted) {
      setState(() => _sending = false);
      if (comment != null) {
        _controller.clear();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Commento non inviato. Riprova più tardi.'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final interactions = ref.watch(interactionsProvider(widget.post));
    final isGuest = ref.watch(authProvider).isGuest;
    final theme = Theme.of(context);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Text('Commenti', style: theme.textTheme.titleMedium),
        ),
        const Divider(height: 1),
        Expanded(
          child: interactions.comments.isEmpty
              ? Center(
                  child: Text(
                    'Nessun commento ancora.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                )
              : ListView.builder(
                  itemCount: interactions.comments.length,
                  itemBuilder: (context, i) {
                    final c = interactions.comments[i];
                    return ListTile(
                      dense: true,
                      leading: CircleAvatar(
                        radius: 14,
                        child: Text(
                          c.author.substring(0, 2).toUpperCase(),
                          style: theme.textTheme.labelSmall,
                        ),
                      ),
                      title: Text(
                        '${c.author.substring(0, 8)}…',
                        style: theme.textTheme.labelMedium,
                      ),
                      subtitle: Text(c.text),
                    );
                  },
                ),
        ),
        const Divider(height: 1),
        if (isGuest)
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text('Accedi per commentare.'),
          )
        else
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 8, 12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Aggiungi un commento…',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    onSubmitted: (_) => _send(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: _sending ? null : _send,
                  icon: _sending
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.send),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
