import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';

import '../../core/nostr/models/media_event.dart';
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
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        title: const Text('Reels'),
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.reels.isEmpty
          ? Center(
              child: Text(
                'Nessun reel trovato sui relay.\nTorna presto!',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge
                    ?.copyWith(color: Colors.white70),
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
                active: i == _currentPage,
              ),
            ),
    );
  }
}

class _ReelPage extends StatefulWidget {
  final MediaPost reel;
  final bool active;
  const _ReelPage({super.key, required this.reel, required this.active});

  @override
  State<_ReelPage> createState() => _ReelPageState();
}

class _ReelPageState extends State<_ReelPage> {
  VideoPlayerController? _controller;
  bool _failed = false;
  bool _expanded = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final c = VideoPlayerController.networkUrl(
      Uri.parse(widget.reel.media.first.url),
    );
    try {
      await c.initialize();
      c.setLooping(true);
      if (widget.active) c.play();
      if (mounted) setState(() => _controller = c);
    } catch (_) {
      if (mounted) setState(() => _failed = true);
      c.dispose();
    }
  }

  @override
  void didUpdateWidget(_ReelPage old) {
    super.didUpdateWidget(old);
    final c = _controller;
    if (c == null || !c.value.isInitialized) return;
    if (widget.active && !old.active) {
      c.play();
    } else if (!widget.active && old.active) {
      c.pause();
      c.seekTo(Duration.zero);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = _controller;
    final reel = widget.reel;
    return Stack(
      fit: StackFit.expand,
      children: [
        if (_failed)
          const Center(
            child: Icon(
              Icons.broken_image_outlined,
              color: Colors.white38,
              size: 64,
            ),
          )
        else if (c == null || !c.value.isInitialized)
          const Center(child: CircularProgressIndicator())
        else
          GestureDetector(
            onTap: () => c.value.isPlaying ? c.pause() : c.play(),
            child: FittedBox(
              fit: BoxFit.cover,
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
          bottom: 24,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    child: Text(reel.author.substring(0, 2).toUpperCase()),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      '${reel.author.substring(0, 8)}…',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white70),
                      minimumSize: const Size(0, 32),
                    ),
                    child: const Text('Segui'),
                  ),
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
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ],
          ),
        ),
        // Action rail.
        Positioned(
          right: 8,
          bottom: 24,
          child: Column(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.favorite_border,
                  color: Colors.white,
                  size: 30,
                ),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(
                  Icons.chat_bubble_outline,
                  color: Colors.white,
                  size: 30,
                ),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(
                  Icons.share_outlined,
                  color: Colors.white,
                  size: 30,
                ),
                onPressed: () {},
              ),
            ],
          ),
        ),
      ],
    );
  }
}
