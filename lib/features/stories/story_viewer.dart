import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';

import '../../app/providers.dart';
import '../../core/nostr/models/media_event.dart';
import '../../l10n/strings.dart';
import '../feed/widgets/inline_video.dart';
import '../feed/widgets/nostr_image.dart';
import '../feed/widgets/post_card.dart' show closeFriendsGreen;
import '../messages/send_to_sheet.dart';
import '../profile/profile_widgets.dart';
import 'stories_controller.dart';

/// Full-screen story viewer: progress bars, tap to advance/go back,
/// long-press to pause, swipe between creators.
class StoryViewerScreen extends ConsumerStatefulWidget {
  final List<StoryGroup> groups;
  final int initialGroup;

  const StoryViewerScreen({
    super.key,
    required this.groups,
    this.initialGroup = 0,
  });

  @override
  ConsumerState<StoryViewerScreen> createState() => _StoryViewerScreenState();
}

class _StoryViewerScreenState extends ConsumerState<StoryViewerScreen> {
  static const _photoDuration = Duration(seconds: 5);

  late PageController _pageController;
  late int _groupIndex;
  int _storyIndex = 0;
  double _progress = 0;
  Timer? _timer;
  VideoPlayerController? _video;
  bool _paused = false;
  int _generation = 0; // invalidates in-flight video initialisations

  StoryGroup get _group => widget.groups[_groupIndex];
  MediaPost get _story => _group.stories[_storyIndex];

  @override
  void initState() {
    super.initState();
    _groupIndex = widget.initialGroup;
    _pageController = PageController(initialPage: _groupIndex);
    // First unseen story of the creator, like Instagram.
    final seen = ref.read(seenStoriesProvider);
    final firstUnseen = _group.stories.indexWhere((s) => !seen.contains(s.id));
    _storyIndex = firstUnseen < 0 ? 0 : firstUnseen;
    WidgetsBinding.instance.addPostFrameCallback((_) => _startStory());
  }

  @override
  void dispose() {
    _timer?.cancel();
    _video?.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _startStory() {
    if (!mounted) return;
    _timer?.cancel();
    _video?.dispose();
    _video = null;
    _progress = 0;
    _generation++;
    final story = _story;
    ref.read(seenStoriesProvider.notifier).markSeen(story.id);
    final item = story.media.first;
    if (item.isVideo) {
      _initVideo(item, _generation);
    } else {
      _startTimer(_photoDuration);
    }
    setState(() {});
  }

  Future<void> _initVideo(MediaItem item, int generation) async {
    VideoPlayerController c;
    try {
      c = item.isEncrypted
          ? VideoPlayerController.file(
              await ref.read(privateMediaProvider).videoFile(item),
            )
          : VideoPlayerController.networkUrl(Uri.parse(item.url));
    } catch (_) {
      if (mounted && generation == _generation) _next();
      return;
    }
    try {
      await c.initialize().timeout(const Duration(seconds: 20));
      if (!mounted || generation != _generation) {
        await c.dispose();
        return;
      }
      _video = c;
      if (!_paused) c.play();
      final d = c.value.duration;
      _startTimer(d.inMilliseconds > 0 ? d : _photoDuration);
      setState(() {});
    } catch (_) {
      await c.dispose();
      if (mounted && generation == _generation) _next();
    }
  }

  void _startTimer(Duration duration) {
    _timer?.cancel();
    const tick = Duration(milliseconds: 50);
    var elapsed = Duration.zero;
    _timer = Timer.periodic(tick, (t) {
      if (_paused || !mounted) return;
      elapsed += tick;
      setState(
        () => _progress = elapsed.inMilliseconds / duration.inMilliseconds,
      );
      if (elapsed >= duration) {
        t.cancel();
        _next();
      }
    });
  }

  Duration get _transition =>
      MediaQuery.maybeOf(context)?.disableAnimations == true
      ? Duration.zero
      : const Duration(milliseconds: 250);

  void _next() {
    if (_storyIndex < _group.stories.length - 1) {
      _storyIndex++;
      _startStory();
    } else if (_groupIndex < widget.groups.length - 1) {
      _pageController.nextPage(duration: _transition, curve: Curves.easeOut);
    } else {
      Navigator.of(context).pop();
    }
  }

  void _previous() {
    if (_storyIndex > 0) {
      _storyIndex--;
      _startStory();
    } else if (_groupIndex > 0) {
      _pageController.previousPage(
        duration: _transition,
        curve: Curves.easeOut,
      );
    }
  }

  void _setPaused(bool paused) {
    _paused = paused;
    if (paused) {
      _video?.pause();
    } else {
      _video?.play();
    }
  }

  Future<void> _sendToFriends() async {
    _setPaused(true);
    await SendToSheet.show(context, _story);
    if (mounted) _setPaused(false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: PageView.builder(
        controller: _pageController,
        itemCount: widget.groups.length,
        onPageChanged: (i) {
          _groupIndex = i;
          _storyIndex = 0;
          _startStory();
        },
        itemBuilder: (context, index) {
          if (index != _groupIndex) {
            // Neighbour while swiping: static first frame, no playback.
            final first = widget.groups[index].stories.first.media.first;
            return Stack(
              fit: StackFit.expand,
              children: [
                first.isVideo
                    ? VideoPoster(item: first)
                    : NostrImage(item: first, fit: BoxFit.contain),
              ],
            );
          }
          return _buildActive(context);
        },
      ),
    );
  }

  Widget _buildActive(BuildContext context) {
    final story = _story;
    final item = story.media.first;
    final top = MediaQuery.paddingOf(context).top;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapUp: (d) {
        final width = MediaQuery.sizeOf(context).width;
        if (d.globalPosition.dx < width / 3) {
          _previous();
        } else {
          _next();
        }
      },
      onLongPressStart: (_) => _setPaused(true),
      onLongPressEnd: (_) => _setPaused(false),
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (item.isVideo)
            _video != null && _video!.value.isInitialized
                ? FittedBox(
                    fit: BoxFit.contain,
                    child: SizedBox(
                      width: _video!.value.size.width,
                      height: _video!.value.size.height,
                      child: VideoPlayer(_video!),
                    ),
                  )
                : Stack(
                    fit: StackFit.expand,
                    children: [
                      VideoPoster(item: item),
                      const Center(child: CircularProgressIndicator()),
                    ],
                  )
          else
            NostrImage(item: item, postId: story.id, fit: BoxFit.contain),
          // Progress bars.
          Positioned(
            top: top + 8,
            left: 8,
            right: 8,
            child: Row(
              children: [
                for (var i = 0; i < _group.stories.length; i++)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: LinearProgressIndicator(
                        value: i < _storyIndex
                            ? 1
                            : i == _storyIndex
                            ? _progress.clamp(0.0, 1.0)
                            : 0,
                        backgroundColor: Colors.white24,
                        valueColor: const AlwaysStoppedAnimation(Colors.white),
                        minHeight: 2.5,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // Header: creator, share, close.
          Positioned(
            top: top + 20,
            left: 12,
            right: 4,
            child: Row(
              children: [
                ProfileAvatar(
                  pubkey: _group.author,
                  radius: 16,
                  tappable: false,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: AuthorName(
                    pubkey: _group.author,
                    tappable: false,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      shadows: [Shadow(blurRadius: 4, color: Colors.black54)],
                    ),
                  ),
                ),
                if (story.isPrivate)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Chip(
                      avatar: const Icon(
                        Icons.star,
                        size: 16,
                        color: Colors.white,
                      ),
                      label: Text(
                        context.l10n.closeFriends,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                      backgroundColor: closeFriendsGreen,
                      visualDensity: VisualDensity.compact,
                      side: BorderSide.none,
                    ),
                  )
                else
                  IconButton(
                    icon: const Icon(Icons.send_outlined, color: Colors.white),
                    tooltip: context.l10n.sendInMessage,
                    onPressed: _sendToFriends,
                  ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  tooltip: context.l10n.close,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          if (story.caption.isNotEmpty)
            Positioned(
              left: 16,
              right: 16,
              bottom: MediaQuery.paddingOf(context).bottom + 24,
              child: Text(
                story.caption,
                style: const TextStyle(
                  color: Colors.white,
                  shadows: [Shadow(blurRadius: 4, color: Colors.black87)],
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
        ],
      ),
    );
  }
}
