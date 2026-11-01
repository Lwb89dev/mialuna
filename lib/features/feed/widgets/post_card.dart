import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' show DateFormat;

import '../../../core/auth/auth_controller.dart';
import '../../../core/nostr/models/media_event.dart';
import '../../../l10n/strings.dart';
import '../../comments/comments_sheet.dart';
import '../../messages/send_to_sheet.dart';
import '../../messages/share_utils.dart';
import '../../profile/profile_widgets.dart';
import '../../social/interactions_controller.dart';
import '../../social/moderation_controller.dart';
import '../../social/zap_sheet.dart';
import 'inline_video.dart';
import 'nostr_image.dart';
import 'pinch_zoom.dart';

/// Instagram feed limits: media is shown between 4:5 (portrait) and 1.91:1
/// (landscape); anything beyond is cropped in the feed and shown whole when
/// pinched.
/// The colour of everything meant for close friends only.
const closeFriendsGreen = Color(0xFF2EB872);

const double minFeedAspect = 0.8;
const double maxFeedAspect = 1.91;

/// Renders a single media post: header, carousel, caption beneath the media
/// (Instagram-style), action row. Hashtags are clickable.
class PostCard extends ConsumerWidget {
  final MediaPost post;
  final ValueChanged<String>? onHashtagTap;

  const PostCard({super.key, required this.post, this.onHashtagTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final interactions = ref.watch(interactionsProvider(post));
    final isGuest = ref.watch(authProvider).isGuest;
    final saved = ref.watch(bookmarksProvider).contains(post.id);
    final isPrivate = post.isPrivate;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 4, 8),
            child: Row(
              children: [
                ProfileAvatar(pubkey: post.author, radius: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AuthorName(
                        pubkey: post.author,
                        style: theme.textTheme.titleSmall,
                      ),
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 6,
                        children: [
                          if (isPrivate)
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.star,
                                  size: 13,
                                  color: closeFriendsGreen,
                                ),
                                const SizedBox(width: 3),
                                Flexible(
                                  child: Text(
                                    context.l10n.closeFriends,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: closeFriendsGreen,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          Text(
                            formatPostTime(post.createdAt),
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  tooltip: context.l10n.more,
                  onSelected: (value) => _onMenu(context, ref, value),
                  itemBuilder: (_) => [
                    // A private post has no public id to save, link or report.
                    if (!isPrivate) ...[
                      PopupMenuItem(
                        value: 'save',
                        child: Text(
                          saved
                              ? context.l10n.removeFromSaved
                              : context.l10n.save,
                        ),
                      ),
                      PopupMenuItem(
                        value: 'copy',
                        child: Text(context.l10n.copyLink),
                      ),
                    ],
                    PopupMenuItem(
                      value: 'mute',
                      child: Text(context.l10n.muteAuthor),
                    ),
                    PopupMenuItem(
                      value: 'block',
                      child: Text(context.l10n.blockAuthor),
                    ),
                    if (!isPrivate)
                      PopupMenuItem(
                        value: 'report',
                        child: Text(context.l10n.report),
                      ),
                  ],
                ),
              ],
            ),
          ),
          PostMedia(post: post),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(
                    interactions.likedByMe
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color: interactions.likedByMe
                        ? theme.colorScheme.secondary
                        : null,
                  ),
                  onPressed: isGuest ? null : () => _like(context, ref),
                  tooltip: context.l10n.like,
                ),
                if (interactions.likeCount > 0)
                  Text(
                    '${interactions.likeCount}',
                    style: theme.textTheme.labelMedium,
                  ),
                IconButton(
                  icon: const Icon(Icons.chat_bubble_outline),
                  onPressed: () => CommentsSheet.show(context, post),
                  tooltip: context.l10n.comments,
                ),
                if (interactions.comments.isNotEmpty)
                  Text(
                    '${interactions.comments.length}',
                    style: theme.textTheme.labelMedium,
                  ),
                if (!isPrivate) ...[
                  IconButton(
                    icon: const Icon(Icons.send_outlined),
                    tooltip: context.l10n.sendInMessage,
                    onPressed: () => SendToSheet.show(context, post),
                  ),
                  IconButton(
                    icon: const Icon(Icons.bolt_outlined),
                    tooltip: context.l10n.zapOptional,
                    onPressed: isGuest
                        ? null
                        : () => showZapSheet(context, ref, post),
                  ),
                ],
                const Spacer(),
                if (isPrivate)
                  Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: Tooltip(
                      message: context.l10n.closeFriendsOnlyNote,
                      child: const Icon(Icons.lock_outline, size: 18),
                    ),
                  )
                else
                  IconButton(
                    icon: Icon(saved ? Icons.bookmark : Icons.bookmark_border),
                    tooltip: saved
                        ? context.l10n.removeFromSaved
                        : context.l10n.save,
                    onPressed: () =>
                        ref.read(bookmarksProvider.notifier).toggle(post.id),
                  ),
              ],
            ),
          ),
          if (post.caption.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: CaptionText(
                caption: post.caption,
                onHashtagTap: onHashtagTap,
              ),
            )
          else
            const SizedBox(height: 8),
        ],
      ),
    );
  }

  Future<void> _like(BuildContext context, WidgetRef ref) async {
    HapticFeedback.selectionClick();
    final ok = await ref.read(interactionsProvider(post).notifier).like(post);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(context.l10n.likeFailed)));
    }
  }

  Future<void> _onMenu(
    BuildContext context,
    WidgetRef ref,
    String value,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    switch (value) {
      case 'save':
        await ref.read(bookmarksProvider.notifier).toggle(post.id);
      case 'copy':
        await Clipboard.setData(
          ClipboardData(
            text: shareReference(ProviderScope.containerOf(context), post),
          ),
        );
        messenger.showSnackBar(SnackBar(content: Text(l10n.nostrLinkCopied)));
      case 'mute':
        await ref.read(muteControllerProvider.notifier).mute(post.author);
        messenger.showSnackBar(SnackBar(content: Text(l10n.authorMuted)));
      case 'block':
        await ref.read(blockProvider.notifier).block(post.author);
        messenger.showSnackBar(SnackBar(content: Text(l10n.authorBlocked)));
      case 'report':
        final ok = await reportEvent(
          ref,
          eventId: post.id,
          authorPubkey: post.author,
          reason: 'other',
        );
        messenger.showSnackBar(
          SnackBar(content: Text(ok ? l10n.reportSent : l10n.signInToReport)),
        );
    }
  }
}

String formatPostTime(int createdAtSeconds) {
  final dt = DateTime.fromMillisecondsSinceEpoch(createdAtSeconds * 1000);
  final diff = DateTime.now().difference(dt);
  final l10n = AppStrings.current;
  if (diff.inMinutes < 1) return l10n.now;
  if (diff.inHours < 1) return l10n.minutesAgo(diff.inMinutes);
  if (diff.inDays < 1) return l10n.hoursAgo(diff.inHours);
  if (diff.inDays < 7) return l10n.daysAgo(diff.inDays);
  return DateFormat.yMd(l10n.localeName).format(dt);
}

/// Screen showing a single post (opened from a message or a link).
class PostScreen extends StatelessWidget {
  final MediaPost post;
  const PostScreen({super.key, required this.post});

  static Future<void> open(BuildContext context, MediaPost post) =>
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (_) => PostScreen(post: post)));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(child: PostCard(post: post)),
    );
  }
}

/// The media area of a post: photos and videos, carousel, double-tap like,
/// pinch to zoom in place, sensitive-content cover.
class PostMedia extends ConsumerStatefulWidget {
  final MediaPost post;
  const PostMedia({super.key, required this.post});

  @override
  ConsumerState<PostMedia> createState() => _PostMediaState();
}

class _PostMediaState extends ConsumerState<PostMedia> {
  int _page = 0;
  bool _revealed = false;
  bool _heart = false;
  double? _discoveredAspect;

  double get _aspect {
    final declared = widget.post.media.first.aspectRatio;
    return (declared ?? _discoveredAspect ?? 1.0).clamp(
      minFeedAspect,
      maxFeedAspect,
    );
  }

  void _onSize(Size size) {
    if (size.height <= 0 || widget.post.media.first.aspectRatio != null) return;
    final aspect = size.width / size.height;
    if (_discoveredAspect == null && mounted) {
      // Reported while building: apply after the frame.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _discoveredAspect = aspect);
      });
    }
  }

  Future<void> _doubleTapLike() async {
    final auth = ref.read(authProvider);
    if (auth.isGuest) return;
    setState(() => _heart = true);
    Future.delayed(const Duration(milliseconds: 650), () {
      if (mounted) setState(() => _heart = false);
    });
    final interactions = ref.read(interactionsProvider(widget.post));
    // Double-tap only ever adds a like; taking it back is the heart button.
    if (!interactions.likedByMe) {
      HapticFeedback.mediumImpact();
      await ref
          .read(interactionsProvider(widget.post).notifier)
          .like(widget.post);
    }
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post;
    final media = post.media;
    if (post.isSensitive && !_revealed) {
      return AspectRatio(
        aspectRatio: 1,
        child: _SensitiveCover(
          reason: post.sensitiveReason,
          onReveal: () => setState(() => _revealed = true),
        ),
      );
    }
    return AspectRatio(
      aspectRatio: _aspect,
      child: Stack(
        fit: StackFit.expand,
        children: [
          PageView.builder(
            itemCount: media.length,
            onPageChanged: (i) => setState(() => _page = i),
            itemBuilder: (context, i) {
              final item = media[i];
              if (item.isVideo) {
                return InlineVideo(
                  key: ValueKey('${post.id}:$i'),
                  item: item,
                  postId: post.id,
                  onSize: i == 0 ? _onSize : null,
                );
              }
              return PinchToZoom(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onDoubleTap: _doubleTapLike,
                  child: NostrImage(
                    item: item,
                    postId: post.id,
                    onSize: i == 0 ? _onSize : null,
                  ),
                ),
              );
            },
          ),
          if (media.length > 1)
            Positioned(
              top: 10,
              right: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${_page + 1}/${media.length}',
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ),
          if (media.length > 1)
            Positioned(
              bottom: 8,
              left: 0,
              right: 0,
              child: IgnorePointer(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (var i = 0; i < media.length; i++)
                      Container(
                        width: 6,
                        height: 6,
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: i == _page ? Colors.white : Colors.white38,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          IgnorePointer(
            child: Center(
              child: AnimatedScale(
                scale: _heart ? 1 : 0.4,
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutBack,
                child: AnimatedOpacity(
                  opacity: _heart ? 1 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: const Icon(
                    Icons.favorite,
                    color: Colors.white,
                    size: 96,
                    shadows: [Shadow(blurRadius: 18, color: Colors.black45)],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SensitiveCover extends StatelessWidget {
  final String? reason;
  final VoidCallback onReveal;
  const _SensitiveCover({this.reason, required this.onReveal});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black87,
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.visibility_off_outlined,
            color: Colors.white70,
            size: 40,
          ),
          const SizedBox(height: 12),
          Text(
            reason?.isNotEmpty == true
                ? reason!
                : context.l10n.sensitiveContent,
            style: const TextStyle(color: Colors.white70),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: onReveal,
            style: OutlinedButton.styleFrom(foregroundColor: Colors.white),
            child: Text(context.l10n.show),
          ),
        ],
      ),
    );
  }
}

/// Caption with clickable #hashtags, collapsed after a few lines.
class CaptionText extends StatefulWidget {
  final String caption;
  final ValueChanged<String>? onHashtagTap;
  final int collapsedLines;

  const CaptionText({
    super.key,
    required this.caption,
    this.onHashtagTap,
    this.collapsedLines = 3,
  });

  @override
  State<CaptionText> createState() => _CaptionTextState();
}

class _CaptionTextState extends State<CaptionText> {
  bool _expanded = false;
  final List<TapGestureRecognizer> _recognizers = [];

  @override
  void dispose() {
    for (final r in _recognizers) {
      r.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    for (final r in _recognizers) {
      r.dispose();
    }
    _recognizers.clear();
    final caption = widget.caption;
    final spans = <InlineSpan>[];
    var last = 0;
    for (final m in RegExp(r'#(\w+)').allMatches(caption)) {
      if (m.start > last) {
        spans.add(TextSpan(text: caption.substring(last, m.start)));
      }
      final tag = m.group(1)!;
      TapGestureRecognizer? recognizer;
      if (widget.onHashtagTap != null) {
        recognizer = TapGestureRecognizer()
          ..onTap = () => widget.onHashtagTap!(tag);
        _recognizers.add(recognizer);
      }
      spans.add(
        TextSpan(
          text: m.group(0),
          style: TextStyle(
            color: theme.colorScheme.secondary,
            fontWeight: FontWeight.w600,
          ),
          recognizer: recognizer,
        ),
      );
      last = m.end;
    }
    if (last < caption.length) {
      spans.add(TextSpan(text: caption.substring(last)));
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final span = TextSpan(
          children: spans,
          style: theme.textTheme.bodyMedium,
        );
        final painter = TextPainter(
          text: span,
          textDirection: TextDirection.ltr,
          maxLines: widget.collapsedLines,
        )..layout(maxWidth: constraints.maxWidth);
        final overflows = painter.didExceedMaxLines;
        painter.dispose();
        return GestureDetector(
          onTap: overflows
              ? () => setState(() => _expanded = !_expanded)
              : null,
          child: Text.rich(
            span,
            maxLines: _expanded ? null : widget.collapsedLines,
            overflow: _expanded ? TextOverflow.visible : TextOverflow.ellipsis,
          ),
        );
      },
    );
  }
}
