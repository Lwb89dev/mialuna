import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';

import '../../app/providers.dart';
import '../../core/auth/auth_controller.dart';
import '../../core/nostr/models/media_event.dart';
import '../../l10n/strings.dart';
import '../comments/comments_sheet.dart';
import '../feed/widgets/inline_video.dart';
import '../messages/send_to_sheet.dart';
import '../profile/profile_widgets.dart';
import '../settings/settings_controller.dart';
import '../social/follow_controller.dart';
import '../social/interactions_controller.dart';
import 'reels_controller.dart';

/// [fresh] reels in the order already on screen; those not seen before are
/// added at the end, those that left (muted, blocked, broken) are dropped.
/// Sorting new arrivals in front moved the reel under the viewer's finger.
List<MediaPost> stableReelOrder(List<MediaPost> shown, List<MediaPost> fresh) {
  final byId = {for (final r in fresh) r.id: r};
  final kept = [
    for (final r in shown)
      if (byId.remove(r.id) != null) r,
  ];
  return [...kept, ...byId.values];
}

/// Makes the player of a reel. Replaceable, so tests can count them.
final reelPlayerFactoryProvider = Provider<VideoPlayerController Function(Uri)>(
  (ref) => VideoPlayerController.networkUrl,
);

/// Full-screen vertical Reels viewer: swipe navigation, autoplay of the
/// active video, pause on leave, creator overlay with actions.
class ReelsScreen extends ConsumerStatefulWidget {
  const ReelsScreen({super.key});

  @override
  ConsumerState<ReelsScreen> createState() => _ReelsScreenState();
}

class _ReelsScreenState extends ConsumerState<ReelsScreen> {
  /// How long the viewer must stay on a reel before the next one is prepared.
  static const _settleTime = Duration(milliseconds: 700);

  final _pageController = PageController();
  int _currentPage = 0;

  /// The viewer has stayed on this reel for a moment: only now is the next one
  /// loaded in the background. Swiping through a stack of reels must not
  /// start a player for each of them (every player holds a hardware decoder
  /// and buffers: 40 quick swipes used to end in an OutOfMemoryError).
  bool _settled = false;
  Timer? _settle;

  /// The order the reels were shown in. New reels that arrive while someone is
  /// watching go to the end instead of being sorted in front, which moved the
  /// reel under their finger.
  List<MediaPost> _shown = const [];

  @override
  void initState() {
    super.initState();
    _startSettling();
  }

  @override
  void dispose() {
    _settle?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startSettling() {
    _settle?.cancel();
    _settle = Timer(_settleTime, () {
      if (mounted) setState(() => _settled = true);
    });
  }

  void _onPageChanged(int i) {
    setState(() {
      _currentPage = i;
      _settled = false;
    });
    _startSettling();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(reelsProvider);
    // Reels live in an IndexedStack: they keep running when another tab is
    // open, so playback follows the visible tab.
    final tabActive = ref.watch(currentTabProvider) == 3;
    final reels = _shown = stableReelOrder(_shown, state.reels);
    ref.listen(tabReselectProvider, (_, event) {
      if (event != null && event.branch == 3) {
        // A deliberate refresh starts over, newest first.
        _shown = const [];
        if (_pageController.hasClients) _pageController.jumpToPage(0);
        ref.read(reelsProvider.notifier).refresh();
      }
    });
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        title: Text(context.l10n.tabReels),
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : reels.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    context.l10n.noReelsComeBack,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge
                        ?.copyWith(color: Colors.white70),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () => ref.read(reelsProvider.notifier).refresh(),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                    ),
                    child: Text(context.l10n.retry),
                  ),
                ],
              ),
            )
          : PageView.builder(
              controller: _pageController,
              scrollDirection: Axis.vertical,
              // The neighbours are built (a poster each) so that the next reel
              // can be made ready; none of them holds a player by itself.
              allowImplicitScrolling: true,
              itemCount: reels.length,
              onPageChanged: _onPageChanged,
              itemBuilder: (context, i) => _ReelPage(
                key: ValueKey(reels[i].id),
                reel: reels[i],
                active: tabActive && i == _currentPage,
                preload: tabActive && _settled && i == _currentPage + 1,
              ),
            ),
    );
  }
}

class _ReelPage extends ConsumerStatefulWidget {
  final MediaPost reel;

  /// The reel being watched: it plays.
  final bool active;

  /// The one after it, once the viewer has settled: it is made ready but
  /// does not play. Every other reel holds no player at all.
  final bool preload;
  const _ReelPage({
    super.key,
    required this.reel,
    required this.active,
    this.preload = false,
  });

  @override
  ConsumerState<_ReelPage> createState() => _ReelPageState();
}

class _ReelPageState extends ConsumerState<_ReelPage>
    with WidgetsBindingObserver {
  VideoPlayerController? _controller;

  /// Created but not initialised yet. Kept so that leaving the page releases
  /// it at once instead of when (if ever) the download answers.
  VideoPlayerController? _pending;
  bool _failed = false;
  bool _expanded = false;
  bool _disposed = false;

  bool get _wantsPlayer {
    if (widget.active) return true;
    // Data-saver: off-screen reels are not downloaded at all; they start
    // loading only when the user swipes to them.
    return widget.preload && !ref.read(settingsProvider).dataSaver;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (_wantsPlayer) _init();
  }

  Future<void> _init() async {
    if (_pending != null || _controller != null) return;
    setState(() => _failed = false);
    final VideoPlayerController c;
    try {
      c = ref.read(reelPlayerFactoryProvider)(
        Uri.parse(widget.reel.media.first.url),
      );
    } catch (_) {
      setState(() => _failed = true); // a URL that is not one
      return;
    }
    _pending = c;
    try {
      await c.initialize().timeout(const Duration(seconds: 20));
      await c.setLooping(true);
      await c.setVolume(ref.read(videoMutedProvider) ? 0 : 1);
      // Released while it was loading (the viewer moved on): nothing to keep.
      if (_disposed || !identical(_pending, c)) {
        await c.dispose();
        return;
      }
      _pending = null;
      if (widget.active) c.play();
      setState(() => _controller = c);
    } catch (_) {
      await c.dispose();
      if (identical(_pending, c)) _pending = null;
      if (mounted) setState(() => _failed = true);
    }
  }

  /// Lets go of the player (and its decoder and buffers).
  void _release() {
    final c = _pending ?? _controller;
    _pending = null;
    _controller = null;
    c?.dispose();
    if (mounted) setState(() {});
  }

  @override
  void didUpdateWidget(_ReelPage old) {
    super.didUpdateWidget(old);
    if (!_wantsPlayer) {
      if (_controller != null || _pending != null) _release();
      return;
    }
    final c = _controller;
    if (c == null || !c.value.isInitialized) {
      if (c == null && _pending == null && !_failed) _init();
      return;
    }
    if (widget.active && !old.active) {
      c.play();
    } else if (!widget.active && old.active) {
      c.pause();
      c.seekTo(Duration.zero);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) _controller?.pause();
  }

  @override
  void dispose() {
    _disposed = true;
    WidgetsBinding.instance.removeObserver(this);
    _pending?.dispose();
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = _controller;
    final reel = widget.reel;
    final interactions = ref.watch(interactionsProvider(reel));
    final following = ref.watch(followListProvider).contains(reel.author);
    final isMe = ref.watch(authProvider).publicKey == reel.author;
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    return Stack(
      fit: StackFit.expand,
      children: [
        if (_failed)
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.videocam_off_outlined,
                  color: Colors.white38,
                  size: 64,
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: _init,
                  child: Text(
                    context.l10n.retry,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          )
        else if (c == null || !c.value.isInitialized)
          Stack(
            fit: StackFit.expand,
            children: [
              VideoPoster(item: reel.media.first, postId: reel.id),
              const Center(child: CircularProgressIndicator()),
            ],
          )
        else
          GestureDetector(
            onTap: () => c.value.isPlaying ? c.pause() : c.play(),
            onDoubleTap: () {
              HapticFeedback.mediumImpact();
              ref.read(interactionsProvider(reel).notifier).like(reel);
            },
            child: FittedBox(
              fit: BoxFit.cover,
              clipBehavior: Clip.hardEdge,
              child: SizedBox(
                width: c.value.size.width,
                height: c.value.size.height,
                child: VideoPlayer(c),
              ),
            ),
          ),
        // Creator + caption overlay.
        Positioned(
          left: 16,
          right: 80,
          bottom: 24 + bottomInset,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  ProfileAvatar(pubkey: reel.author, radius: 18),
                  const SizedBox(width: 8),
                  Flexible(
                    child: AuthorName(
                      pubkey: reel.author,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        shadows: [Shadow(blurRadius: 4, color: Colors.black54)],
                      ),
                    ),
                  ),
                  if (!isMe) ...[
                    const SizedBox(width: 8),
                    OutlinedButton(
                      onPressed: () async {
                        final ok = await ref
                            .read(followListProvider.notifier)
                            .toggleFollow(reel.author);
                        if (!ok && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                context.l10n.followUpdateFailedShort,
                              ),
                            ),
                          );
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white70),
                        minimumSize: const Size(0, 32),
                      ),
                      child: Text(
                        following
                            ? context.l10n.followingButton
                            : context.l10n.follow,
                      ),
                    ),
                  ],
                ],
              ),
              if (reel.caption.isNotEmpty) ...[
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () => setState(() => _expanded = !_expanded),
                  child: Text(
                    reel.caption,
                    maxLines: _expanded ? 20 : 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      shadows: [Shadow(blurRadius: 4, color: Colors.black87)],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        // Action rail.
        Positioned(
          right: 8,
          bottom: 24 + bottomInset,
          child: Column(
            children: [
              _RailButton(
                icon: interactions.likedByMe
                    ? Icons.favorite
                    : Icons.favorite_border,
                color: interactions.likedByMe
                    ? Theme.of(context).colorScheme.secondary
                    : Colors.white,
                label: interactions.likeCount > 0
                    ? '${interactions.likeCount}'
                    : null,
                onPressed: () =>
                    ref.read(interactionsProvider(reel).notifier).like(reel),
              ),
              _RailButton(
                icon: Icons.chat_bubble_outline,
                label: interactions.comments.isNotEmpty
                    ? '${interactions.comments.length}'
                    : null,
                onPressed: () => CommentsSheet.show(context, reel),
              ),
              _RailButton(
                icon: Icons.send_outlined,
                onPressed: () => SendToSheet.show(context, reel),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RailButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String? label;
  final VoidCallback onPressed;
  const _RailButton({
    required this.icon,
    required this.onPressed,
    this.color = Colors.white,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        IconButton(
          icon: Icon(icon, color: color, size: 30),
          onPressed: onPressed,
        ),
        if (label != null)
          Text(
            label!,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              shadows: [Shadow(blurRadius: 4, color: Colors.black87)],
            ),
          ),
      ],
    );
  }
}
