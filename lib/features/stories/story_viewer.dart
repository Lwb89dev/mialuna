import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';

import '../../app/providers.dart';
import '../../core/auth/auth_controller.dart';
import '../../core/nostr/models/media_event.dart';
import '../../core/platform/secure_window.dart';
import '../../core/text/clip.dart';
import '../../l10n/strings.dart';
import '../explore/hashtag_link.dart';
import '../feed/widgets/hashtag_text.dart';
import '../feed/widgets/inline_video.dart';
import '../feed/widgets/nostr_image.dart';
import '../feed/widgets/post_card.dart' show closeFriendsGreen;
import '../messages/send_to_sheet.dart';
import '../profile/profile_widgets.dart';
import 'stories_controller.dart';
import 'story_playback.dart';
import 'story_receipts.dart';
import 'story_text_view.dart';
import 'story_views.dart';
import 'story_views_sheet.dart';

/// Full-screen story viewer: progress bars, tap to advance/go back,
/// long-press to pause, swipe between creators.
///
/// A story is *watched* — marked seen, reported to its author — only once its
/// media has really been on screen (see [StoryPlayback]), not when it is
/// merely selected.
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

class _StoryViewerScreenState extends ConsumerState<StoryViewerScreen>
    with WidgetsBindingObserver {
  static const _tick = Duration(milliseconds: 50);
  static const _captionStyle = TextStyle(
    color: Colors.white,
    shadows: [Shadow(blurRadius: 4, color: Colors.black87)],
  );

  late PageController _pageController;
  late int _groupIndex;
  int _storyIndex = 0;
  final _playback = StoryPlayback();
  Timer? _timer;
  VideoPlayerController? _video;
  int _generation = 0; // invalidates in-flight video initialisations

  /// Kept for [dispose]: a widget's `ref` is gone by then, and the receipts
  /// still have to leave.
  late final ProviderContainer _container;

  StoryGroup get _group => widget.groups[_groupIndex];
  MediaPost get _story => _group.stories[_storyIndex];
  bool get _isOwn => _group.author == ref.read(authProvider).publicKey;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _container = ProviderScope.containerOf(context, listen: false);
    _groupIndex = widget.initialGroup;
    _pageController = PageController(initialPage: _groupIndex);
    _storyIndex = _firstUnseenIndex();
    WidgetsBinding.instance.addPostFrameCallback((_) => _startStory());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    // Whoever's stories were being watched is told (if the viewer allows it).
    // The screen can outlive its providers (the app is closing, the account
    // changed): then there is nobody to tell.
    try {
      unawaited(_container.read(storyViewReporterProvider).flush());
    } catch (_) {}
    _timer?.cancel();
    _video?.dispose();
    _pageController.dispose();
    super.dispose();
  }

  /// Not in the foreground (a call, the notification shade, another app):
  /// the story holds still and does not count.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final away = state != AppLifecycleState.resumed;
    _playback.inBackground = away;
    if (away) {
      _video?.pause();
    } else if (!_playback.paused) {
      _video?.play();
    }
  }

  /// First unseen story of the current creator, like Instagram.
  int _firstUnseenIndex() {
    final seen = ref.read(seenStoriesProvider);
    final firstUnseen = _group.stories.indexWhere((s) => !seen.contains(s.id));
    return firstUnseen < 0 ? 0 : firstUnseen;
  }

  void _startStory() {
    if (!mounted) return;
    _timer?.cancel();
    _video?.dispose();
    _video = null;
    _playback.reset();
    _generation++;
    final item = _story.media.first;
    if (item.isVideo) _initVideo(item, _generation);
    // A picture starts its clock when it is on screen ([_pictureShown]).
    _timer = Timer.periodic(_tick, (_) => _onTick());
    setState(() {});
  }

  /// The story has been on screen for real: now it is seen, and its author
  /// is told.
  void _watched() {
    final story = _story;
    ref.read(seenStoriesProvider.notifier).markSeen(story.id);
    unawaited(ref.read(storyViewReporterProvider).viewed(story));
  }

  void _pictureShown(String storyId, int generation) {
    if (!mounted || generation != _generation || storyId != _story.id) return;
    _playback.pictureShown();
    setState(() {});
  }

  /// Nothing to show: on to the next, without having watched this one.
  void _mediaFailed(String storyId, int generation) {
    if (!mounted || generation != _generation || storyId != _story.id) return;
    if (_playback.hasFailed) return;
    _playback.mediaFailed();
    _timer?.cancel();
    _next();
  }

  Future<void> _initVideo(MediaItem item, int generation) async {
    final storyId = _story.id;
    VideoPlayerController c;
    try {
      c = item.isEncrypted
          ? VideoPlayerController.file(
              await ref.read(privateMediaProvider).videoFile(item),
            )
          : VideoPlayerController.networkUrl(Uri.parse(item.url));
    } catch (_) {
      _mediaFailed(storyId, generation);
      return;
    }
    try {
      await c.initialize().timeout(const Duration(seconds: 20));
      if (!mounted || generation != _generation) {
        await c.dispose();
        return;
      }
      _video = c;
      if (!_playback.paused && !_playback.inBackground) c.play();
      final length = c.value.duration;
      if (length > Duration.zero) {
        _playback.videoShown(length);
      } else {
        _playback.pictureShown(); // no length to follow: the clock decides
      }
      setState(() {});
    } catch (_) {
      await c.dispose();
      _mediaFailed(storyId, generation);
    }
  }

  void _onTick() {
    if (!mounted) return;
    final value = _video?.value;
    if (value != null && value.hasError) {
      _mediaFailed(_story.id, _generation);
      return;
    }
    final wasMoving = _playback.isReady && !_playback.paused;
    final step = _playback.advance(
      _tick,
      position: value?.position ?? Duration.zero,
      playing: value?.isPlaying ?? true,
      buffering: value?.isBuffering ?? false,
      completed: value?.isCompleted ?? false,
    );
    if (step.count) _watched();
    if (wasMoving && !_playback.inBackground) setState(() {});
    if (step.done) {
      _timer?.cancel();
      _next();
    }
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
    } else {
      _startStory(); // first story of the first creator: play it again
    }
  }

  void _setPaused(bool paused) {
    _playback.paused = paused;
    if (paused) {
      _video?.pause();
    } else if (!_playback.inBackground) {
      _video?.play();
    }
  }

  /// A tapped #hashtag opens the search for it; the story waits meanwhile.
  Future<void> _openHashtag(String tag) async {
    _setPaused(true);
    await openHashtagSearch(context, tag);
    if (mounted) _setPaused(false);
  }

  /// Your own story: who watched it.
  Future<void> _showViewers() async {
    _setPaused(true);
    await StoryViewersSheet.show(context, _story.id);
    if (mounted) _setPaused(false);
  }

  Future<void> _sendToFriends() async {
    _setPaused(true);
    await SendToSheet.show(context, _story);
    if (mounted) _setPaused(false);
  }

  @override
  Widget build(BuildContext context) {
    // A close-friends story is for them only: no screenshots of it either.
    return SecureScreen(
      enabled: widget.groups.any((g) => g.hasPrivate),
      child: Scaffold(
        backgroundColor: Colors.black,
        body: PageView.builder(
          controller: _pageController,
          itemCount: widget.groups.length,
          onPageChanged: (i) {
            // Moving on from this creator: tell them what was watched.
            unawaited(
              ref.read(storyViewReporterProvider).flush(author: _group.author),
            );
            _groupIndex = i;
            _storyIndex = _firstUnseenIndex();
            _startStory();
          },
          itemBuilder: (context, index) {
            if (index != _groupIndex) {
              // Neighbour while swiping: static first frame, no playback.
              final firstStory = widget.groups[index].stories.first;
              final first = firstStory.media.first;
              return Stack(
                fit: StackFit.expand,
                children: [
                  first.isVideo
                      ? VideoPoster(item: first)
                      : NostrImage(item: first, fit: BoxFit.contain),
                  StoryOverlayLayer(
                    texts: firstStory.overlays,
                    mediaAspect: first.aspectRatio,
                  ),
                ],
              );
            }
            return _buildActive(context);
          },
        ),
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
          else ...[
            NostrImage(
              key: ValueKey('story-${story.id}'),
              item: item,
              postId: story.id,
              fit: BoxFit.contain,
              onSize: (_) => _pictureShown(story.id, _generation),
              onFailed: () => _mediaFailed(story.id, _generation),
            ),
            if (!_playback.isReady && !_playback.hasFailed)
              const IgnorePointer(
                child: Center(child: CircularProgressIndicator()),
              ),
          ],
          // Texts laid over the picture; their hashtags can be tapped.
          Positioned.fill(
            child: StoryOverlayLayer(
              texts: story.overlays,
              mediaAspect: item.aspectRatio,
              onHashtagTap: _openHashtag,
            ),
          ),
          // A fade under the bars and the name, so they read on a bright sky.
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: top + 96,
            child: const IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0x73000000), Color(0x00000000)],
                  ),
                ),
              ),
            ),
          ),
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
                            ? _playback.progress
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
                if (_isOwn)
                  Consumer(
                    builder: (context, ref, _) {
                      final count = ref.watch(
                        storyViewsProvider.select((s) => s.countOf(story.id)),
                      );
                      return TextButton.icon(
                        onPressed: _showViewers,
                        icon: const Icon(
                          Icons.visibility_outlined,
                          color: Colors.white,
                          size: 20,
                        ),
                        label: Text(
                          '$count',
                          style: const TextStyle(color: Colors.white),
                        ),
                      );
                    },
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
              child: HashtagText(
                clipForDisplay(story.caption),
                style: _captionStyle,
                tagStyle: _captionStyle.copyWith(
                  fontWeight: FontWeight.w800,
                  decoration: TextDecoration.underline,
                ),
                onHashtagTap: _openHashtag,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
        ],
      ),
    );
  }
}
