import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/auth/auth_controller.dart';
import '../../core/nostr/models/comment.dart';
import '../../core/nostr/models/media_event.dart';
import '../../core/text/clip.dart';
import '../../l10n/strings.dart';
import '../profile/profile_widgets.dart';
import '../social/interactions_controller.dart';
import 'comment_likes_controller.dart';

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
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(context.l10n.commentNotSent)));
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
          child: Text(
            context.l10n.comments,
            style: theme.textTheme.titleMedium,
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: interactions.comments.isEmpty
              ? Center(
                  child: Text(
                    context.l10n.noCommentsYet,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                )
              : ListView.builder(
                  itemCount: interactions.comments.length,
                  itemBuilder: (context, i) => _CommentTile(
                    post: widget.post,
                    comment: interactions.comments[i],
                  ),
                ),
        ),
        const Divider(height: 1),
        if (isGuest)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(context.l10n.signInToComment),
          )
        else
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 8, 12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    enableIMEPersonalizedLearning: false,
                    decoration: InputDecoration(
                      hintText: context.l10n.addComment,
                      border: const OutlineInputBorder(),
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

class _CommentTile extends ConsumerWidget {
  final MediaPost post;
  final Comment comment;
  const _CommentTile({required this.post, required this.comment});

  Future<void> _like(BuildContext context, WidgetRef ref) async {
    final target = (post: post, comment: comment);
    final ok = await ref.read(commentLikesProvider(target).notifier).like();
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(context.l10n.likeFailed)));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final target = (post: post, comment: comment);
    final likes = ref.watch(commentLikesProvider(target));
    final isGuest = ref.watch(authProvider.select((a) => a.isGuest));
    final theme = Theme.of(context);
    return ListTile(
      dense: true,
      leading: ProfileAvatar(pubkey: comment.author, radius: 14),
      title: AuthorName(
        pubkey: comment.author,
        style: theme.textTheme.labelMedium,
      ),
      subtitle: Text(clipForDisplay(comment.text)),
      trailing: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox.square(
            dimension: 32,
            child: IconButton(
              padding: EdgeInsets.zero,
              iconSize: 18,
              tooltip: context.l10n.like,
              onPressed: isGuest ? null : () => _like(context, ref),
              icon: Icon(
                likes.likedByMe ? Icons.favorite : Icons.favorite_border,
                color: likes.likedByMe ? theme.colorScheme.secondary : null,
              ),
            ),
          ),
          if (likes.count > 0)
            Text('${likes.count}', style: theme.textTheme.labelSmall),
        ],
      ),
    );
  }
}
