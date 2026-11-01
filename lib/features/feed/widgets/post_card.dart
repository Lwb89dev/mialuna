import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../../core/nostr/models/media_event.dart';
import '../../reels/widgets/video_player_screen.dart';

/// Renders a single media post: header, carousel, caption beneath the media
/// (Instagram-style), action row. Hashtags are clickable.
class PostCard extends StatelessWidget {
  final MediaPost post;
  final VoidCallback? onLike;
  final VoidCallback? onComment;
  final VoidCallback? onShare;
  final ValueChanged<String>? onHashtagTap;

  const PostCard({
    super.key,
    required this.post,
    this.onLike,
    this.onComment,
    this.onShare,
    this.onHashtagTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: CircleAvatar(
              child: Text(post.author.substring(0, 2).toUpperCase()),
            ),
            title: Text(
              post.title?.isNotEmpty == true
                  ? post.title!
                  : '${post.author.substring(0, 8)}…',
              style: theme.textTheme.titleSmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              _formatTime(post.createdAt),
              style: theme.textTheme.bodySmall,
            ),
          ),
          if (post.isSensitive)
            _SensitiveOverlay(reason: post.sensitiveReason)
          else
            _MediaCarousel(post: post),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.favorite_border),
                  onPressed: onLike,
                  tooltip: 'Mi piace',
                ),
                IconButton(
                  icon: const Icon(Icons.chat_bubble_outline),
                  onPressed: onComment,
                  tooltip: 'Commenti',
                ),
                IconButton(
                  icon: const Icon(Icons.share_outlined),
                  onPressed: onShare,
                  tooltip: 'Condividi',
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
            ),
        ],
      ),
    );
  }

  static String _formatTime(int createdAtSeconds) {
    final dt = DateTime.fromMillisecondsSinceEpoch(createdAtSeconds * 1000);
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'adesso';
    if (diff.inHours < 1) return '${diff.inMinutes} min fa';
    if (diff.inDays < 1) return '${diff.inHours} h fa';
    if (diff.inDays < 7) return '${diff.inDays} g fa';
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}

class _MediaCarousel extends StatefulWidget {
  final MediaPost post;
  const _MediaCarousel({required this.post});

  @override
  State<_MediaCarousel> createState() => _MediaCarouselState();
}

class _MediaCarouselState extends State<_MediaCarousel> {
  int _page = 0;

  @override
  Widget build(BuildContext context) {
    final media = widget.post.media;
    return AspectRatio(
      aspectRatio: _aspectRatio(media.first),
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          PageView.builder(
            itemCount: media.length,
            onPageChanged: (i) => setState(() => _page = i),
            itemBuilder: (context, i) {
              final item = media[i];
              if (item.isVideo) {
                return GestureDetector(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => VideoPlayerScreen(
                        item: item,
                        title: widget.post.title,
                      ),
                    ),
                  ),
                  child: Container(
                    color: Colors.black,
                    child: const Center(
                      child: Icon(
                        Icons.play_circle_outline,
                        size: 64,
                        color: Colors.white70,
                      ),
                    ),
                  ),
                );
              }
              return CachedNetworkImage(
                imageUrl: item.url,
                fit: BoxFit.cover,
                placeholder: (_, _) => Container(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (_, _, _) => Container(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  child: const Icon(Icons.broken_image_outlined),
                ),
              );
            },
          ),
          if (media.length > 1)
            Padding(
              padding: const EdgeInsets.all(8),
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
        ],
      ),
    );
  }

  double _aspectRatio(MediaItem item) {
    if (item.width != null && item.height != null && item.height! > 0) {
      return item.width! / item.height!;
    }
    return 1;
  }
}

class _SensitiveOverlay extends StatelessWidget {
  final String? reason;
  const _SensitiveOverlay({this.reason});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Container(
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
              reason?.isNotEmpty == true ? reason! : 'Contenuto sensibile',
              style: const TextStyle(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Caption with clickable #hashtags.
class CaptionText extends StatelessWidget {
  final String caption;
  final ValueChanged<String>? onHashtagTap;

  const CaptionText({super.key, required this.caption, this.onHashtagTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pattern = RegExp(r'#(\w+)');
    final spans = <InlineSpan>[];
    var last = 0;
    for (final m in pattern.allMatches(caption)) {
      if (m.start > last) {
        spans.add(TextSpan(text: caption.substring(last, m.start)));
      }
      final tag = m.group(1)!;
      spans.add(
        TextSpan(
          text: m.group(0),
          style: TextStyle(
            color: theme.colorScheme.secondary,
            fontWeight: FontWeight.w600,
          ),
          recognizer: onHashtagTap == null
              ? null
              : (TapGestureRecognizer()..onTap = () => onHashtagTap!(tag)),
        ),
      );
      last = m.end;
    }
    if (last < caption.length) {
      spans.add(TextSpan(text: caption.substring(last)));
    }
    return Text.rich(
      TextSpan(children: spans),
      style: theme.textTheme.bodyMedium,
    );
  }
}
