import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

import '../../core/nostr/models/media_event.dart';
import '../../core/nostr/nip19.dart';
import 'stories_controller.dart';

/// Full-screen story viewer: progress bars, tap to advance/go back,
/// long-press to pause, swipe between creators.
class StoryViewerScreen extends StatefulWidget {
  final List<StoryGroup> groups;
  final int initialGroup;

  const StoryViewerScreen({
    super.key,
    required this.groups,
    this.initialGroup = 0,
  });

  @override
  State<StoryViewerScreen> createState() => _StoryViewerScreenState();
}

class _StoryViewerScreenState extends State<StoryViewerScreen>
    with SingleTickerProviderStateMixin {
  static const _photoDuration = Duration(seconds: 5);

  late PageController _pageController;
  late int _groupIndex;
  int _storyIndex = 0;
  double _progress = 0;
  Timer? _timer;
  VideoPlayerController? _video;
  bool _paused = false;

  StoryGroup get _group => widget.groups[_groupIndex];
  MediaPost get _story => _group.stories[_storyIndex];

  @override
  void initState() {
    super.initState();
    _groupIndex = widget.initialGroup;
    _pageController = PageController(initialPage: _groupIndex);
    _startStory();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _video?.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _startStory() {
    _timer?.cancel();
    _video?.dispose();
    _video = null;
    _progress = 0;
    final story = _story;
    if (story.media.first.isVideo) {
      _initVideo(story.media.first.url);
    } else {
      _startTimer(_photoDuration);
    }
    setState(() {});
  }

  Future<void> _initVideo(String url) async {
    final c = VideoPlayerController.networkUrl(Uri.parse(url));
    try {
      await c.initialize();
      if (!mounted) {
        c.dispose();
        return;
      }
      _video = c;
      c.play();
      _startTimer(c.value.duration);
      setState(() {});
    } catch (_) {
      if (mounted) _next();
    }
  }

  void _startTimer(Duration duration) {
    _timer?.cancel();
    const tick = Duration(milliseconds: 50);
    var elapsed = Duration.zero;
    _timer = Timer.periodic(tick, (t) {
      if (_paused) return;
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

  @override
  Widget build(BuildContext context) {
    final story = _story;
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
        itemBuilder: (context, _) {
          return GestureDetector(
            onTapUp: (d) {
              final width = MediaQuery.of(context).size.width;
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
                if (story.media.first.isVideo)
                  _video != null && _video!.value.isInitialized
                      ? FittedBox(
                          fit: BoxFit.contain,
                          child: SizedBox(
                            width: _video!.value.size.width,
                            height: _video!.value.size.height,
                            child: VideoPlayer(_video!),
                          ),
                        )
                      : const Center(child: CircularProgressIndicator())
                else
                  CachedNetworkImage(
                    imageUrl: story.media.first.url,
                    fit: BoxFit.contain,
                    placeholder: (_, _) =>
                        const Center(child: CircularProgressIndicator()),
                    errorWidget: (_, _, _) => const Icon(
                      Icons.broken_image_outlined,
                      color: Colors.white38,
                      size: 64,
                    ),
                  ),
                // Progress bars.
                Positioned(
                  top: MediaQuery.of(context).padding.top + 8,
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
                              valueColor: const AlwaysStoppedAnimation(
                                Colors.white,
                              ),
                              minHeight: 2.5,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                // Header + caption.
                Positioned(
                  top: MediaQuery.of(context).padding.top + 20,
                  left: 16,
                  right: 56,
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        child: Text(
                          _group.author.substring(0, 2).toUpperCase(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${_group.author.substring(0, 8)}…',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
                if (story.caption.isNotEmpty)
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 24,
                    child: Text(
                      story.caption,
                      style: const TextStyle(color: Colors.white),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                Positioned(
                  top: MediaQuery.of(context).padding.top + 16,
                  right: 8,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.share_outlined,
                          color: Colors.white,
                        ),
                        tooltip: 'Condividi',
                        onPressed: () {
                          final note = Nip19.encodeNote(story.event.id);
                          Clipboard.setData(ClipboardData(text: 'nostr:$note'));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Link Nostr copiato negli appunti'),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
