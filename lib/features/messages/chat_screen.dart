import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/nostr/models/media_event.dart';
import '../../core/nostr/nip19.dart';
import '../../l10n/strings.dart';
import '../feed/widgets/inline_video.dart';
import '../feed/widgets/nostr_image.dart';
import '../feed/widgets/post_card.dart';
import '../../core/platform/secure_window.dart';
import '../../core/text/clip.dart';
import '../profile/profile_widgets.dart';
import 'dm_controller.dart';
import 'inbox_screen.dart';
import 'share_utils.dart';

/// One private conversation (NIP-17).
class ChatScreen extends ConsumerStatefulWidget {
  final String peer;
  const ChatScreen({super.key, required this.peer});

  static Future<void> open(BuildContext context, String peer) =>
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (_) => ChatScreen(peer: peer)));

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
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
    _controller.clear();
    try {
      await ref.read(dmProvider.notifier).send(widget.peer, text);
    } on DmException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.message)));
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final conv = ref.watch(
      dmProvider.select((s) => s.conversations[widget.peer]),
    );
    final messages = conv?.messages.reversed.toList() ?? const <DmMessage>[];
    // Opening (or receiving into) a conversation marks it as read.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) ref.read(dmProvider.notifier).markRead(widget.peer);
    });

    return SecureScreen(
      child: Scaffold(
        appBar: AppBar(
          titleSpacing: 0,
          title: GestureDetector(
            onTap: () => openProfile(context, widget.peer),
            child: Row(
              children: [
                ProfileAvatar(pubkey: widget.peer, radius: 16, tappable: false),
                const SizedBox(width: 10),
                Flexible(
                  child: AuthorName(
                    pubkey: widget.peer,
                    tappable: false,
                    style: theme.textTheme.titleMedium,
                  ),
                ),
              ],
            ),
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: messages.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Text(
                          context.l10n.chatEmptyHint,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.outline,
                          ),
                        ),
                      ),
                    )
                  : ListView.builder(
                      reverse: true,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      itemCount: messages.length,
                      itemBuilder: (context, i) =>
                          _Bubble(message: messages[i]),
                    ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 4, 8, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        minLines: 1,
                        maxLines: 5,
                        // What is said in private is not for the keyboard to
                        // learn from.
                        enableIMEPersonalizedLearning: false,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: InputDecoration(
                          hintText: context.l10n.messageHint,
                          filled: true,
                          isDense: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(22),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        onSubmitted: (_) => _send(),
                      ),
                    ),
                    const SizedBox(width: 6),
                    IconButton.filled(
                      onPressed: _sending ? null : _send,
                      icon: const Icon(Icons.send),
                      tooltip: context.l10n.send,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  final DmMessage message;
  const _Bubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mine = message.fromMe;
    final refMatch = Nip19.eventRefPattern.firstMatch(message.text);
    final text = message.text.replaceAll(Nip19.eventRefPattern, '').trim();
    final bg = mine
        ? theme.colorScheme.primary
        : theme.colorScheme.surfaceContainerHighest;
    final fg = mine ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface;
    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.78,
        ),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 3),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (refMatch != null) ...[
                SharedPostPreview(reference: refMatch.group(0)!),
                if (text.isNotEmpty) const SizedBox(height: 6),
              ],
              if (text.isNotEmpty)
                SelectableText(
                  clipForDisplay(text),
                  style: TextStyle(color: fg),
                ),
              const SizedBox(height: 2),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    formatChatTime(message.createdAt),
                    style: TextStyle(
                      color: fg.withValues(alpha: 0.7),
                      fontSize: 10,
                    ),
                  ),
                  if (mine && message.status == DmStatus.pending) ...[
                    const SizedBox(width: 4),
                    Icon(
                      Icons.schedule,
                      size: 11,
                      color: fg.withValues(alpha: 0.7),
                    ),
                  ],
                  if (mine && message.status == DmStatus.failed) ...[
                    const SizedBox(width: 4),
                    Icon(
                      Icons.error_outline,
                      size: 12,
                      color: theme.colorScheme.error,
                    ),
                    Text(
                      context.l10n.notSentSuffix,
                      style: TextStyle(
                        color: theme.colorScheme.error,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Compact card for a post/reel/story shared inside a message.
class SharedPostPreview extends ConsumerWidget {
  final String reference;
  const SharedPostPreview({super.key, required this.reference});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final async = ref.watch(sharedPostProvider(reference));
    return async.when(
      loading: () => _frame(
        context,
        const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      ),
      error: (_, _) => _unavailable(theme),
      data: (post) {
        if (post == null) return _unavailable(theme);
        final item = post.media.first;
        final isStory = post.isStory;
        return GestureDetector(
          onTap: () => PostScreen.open(context, post),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: 200,
              height: 240,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  item.isVideo
                      ? _VideoThumb(post: post)
                      : NostrImage(
                          item: item,
                          postId: post.id,
                          preferThumbnail: true,
                        ),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black54,
                          Colors.transparent,
                          Colors.black54,
                        ],
                        stops: [0, 0.4, 1],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 8,
                    top: 8,
                    right: 8,
                    child: Row(
                      children: [
                        ProfileAvatar(
                          pubkey: post.author,
                          radius: 11,
                          tappable: false,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: AuthorName(
                            pubkey: post.author,
                            tappable: false,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Icon(
                          isStory
                              ? Icons.auto_stories
                              : post.isReel
                              ? Icons.play_circle_outline
                              : post.isVideo
                              ? Icons.videocam_outlined
                              : Icons.photo_outlined,
                          color: Colors.white,
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                  if (post.caption.isNotEmpty)
                    Positioned(
                      left: 8,
                      right: 8,
                      bottom: 8,
                      child: Text(
                        post.caption,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _frame(BuildContext context, Widget child) => Container(
    width: 200,
    height: 120,
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(12),
    ),
    child: child,
  );

  Widget _unavailable(ThemeData theme) => Container(
    width: 200,
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: theme.colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      children: [
        Icon(Icons.hide_image_outlined, color: theme.colorScheme.outline),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            AppStrings.current.contentUnavailable,
            style: theme.textTheme.bodySmall,
          ),
        ),
      ],
    ),
  );
}

class _VideoThumb extends StatelessWidget {
  final MediaPost post;
  const _VideoThumb({required this.post});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        VideoPoster(item: post.media.first, postId: post.id),
        const Center(
          child: Icon(Icons.play_circle_fill, color: Colors.white70, size: 44),
        ),
      ],
    );
  }
}
