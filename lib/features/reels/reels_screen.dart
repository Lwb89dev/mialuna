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

/// Full-screen vertical Reels viewer: swipe navigation, autoplay of the
/// active video, pause on leave, creator overlay with actions.
class ReelsScreen extends ConsumerStatefulWidget {
  const ReelsScreen({super.key});

  @override
  ConsumerState<ReelsScreen> createState() => _ReelsScreenState();
}

class _ReelsScreenState extends ConsumerState<ReelsScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(reelsProvider);
    // Reels live in an IndexedStack: they keep running when another tab is
    // open, so playback follows the visible tab.
    final tabActive = ref.watch(currentTabProvider) == 3;
    ref.listen(tabReselectProvider, (_, event) {
      if (event != null && event.branch == 3) {
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
          : state.reels.isEmpty
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
              itemCount: state.reels.length,
              onPageChanged: (i) => setState(() => _currentPage = i),
              itemBuilder: (context, i) => _ReelPage(
                key: ValueKey(state.reels[i].id),
                reel: state.reels[i],
                active: tabActive && i == _currentPage,
              ),
            ),
    );
  }
}

class _ReelPage extends ConsumerStatefulWidget {
  final MediaPost reel;
  final bool active;
  const _ReelPage({super.key, required this.reel, required this.active});

  @override
  ConsumerState<_ReelPage> createState() => _ReelPageState();
}

class _ReelPageState extends ConsumerState<_ReelPage>
    with WidgetsBindingObserver {
  VideoPlayerController? _controller;
  bool _failed = false;
  bool _expanded = false;
  bool _disposed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Data-saver: off-screen reels are not downloaded at all; they start
    // loading only when the user swipes to them.
    final dataSaver = ref.read(settingsProvider).dataSaver;
    if (widget.active || !dataSaver) _init();
  }

  Future<void> _init() async {
    setState(() => _failed = false);
    final c = VideoPlayerController.networkUrl(
      Uri.parse(widget.reel.media.first.url),
    );
    try {
      await c.initialize().timeout(const Duration(seconds: 20));
      await c.setLooping(true);
      await c.setVolume(ref.read(videoMutedProvider) ? 0 : 1);
      if (_disposed) {
        await c.dispose();
        return;
      }
      if (widget.active) c.play();
      setState(() => _controller = c);
    } catch (_) {
      await c.dispose();
      if (mounted) setState(() => _failed = true);
    }
  }

  @override
  void didUpdateWidget(_ReelPage old) {
    super.didUpdateWidget(old);
    final c = _controller;
    if (c == null || !c.value.isInitialized) {
      if (widget.active && !old.active && c == null && !_failed) _init();
      return;
    }
    if (widget.active && !old.active) {
      c.play();
    } else if (!widget.active && old.active) {
      c.pause();
      if (ref.read(currentTabProvider) == 3) c.seekTo(Duration.zero);
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
