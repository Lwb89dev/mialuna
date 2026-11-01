import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';

import '../../../app/providers.dart';
import '../../../core/media/video_frames.dart';
import '../../../core/nostr/models/media_event.dart';
import '../../../l10n/strings.dart';
import 'nostr_image.dart';

/// The id of the inline video that is currently playing (or null). Starting
/// one pauses the previous; switching tab clears it.
final activeVideoProvider = StateProvider<String?>((ref) => null);

/// Whether feed videos play without sound; remembered for the session.
final videoMutedProvider = StateProvider<bool>((ref) => false);

/// Still image shown for a video before it plays: the event's own poster,
/// or a frame taken from the video itself (many publishers include none).
class VideoPoster extends StatelessWidget {
  final MediaItem item;
  final String? postId;
  final ValueChanged<Size>? onSize;

  const VideoPoster({super.key, required this.item, this.postId, this.onSize});

  @override
  Widget build(BuildContext context) {
    final preview = item.previewUrl;
    if (preview != null) {
      return NostrImage(
        item: MediaItem(
          url: preview,
          mimeType: 'image/jpeg',
          encryption: item.previewEncryption,
        ),
        fit: BoxFit.cover,
        onSize: onSize,
        semanticLabel: context.l10n.videoPreview,
      );
    }
    // An encrypted video without a cover cannot be sampled from the network.
    if (item.isEncrypted) return const ColoredBox(color: Color(0xFF14131A));
    return FutureBuilder<VideoFrame?>(
      future: VideoFrames.forUrl(item.url),
      builder: (context, snapshot) {
        final frame = snapshot.data;
        if (frame == null) {
          return const ColoredBox(color: Color(0xFF14131A));
        }
        onSize?.call(Size(frame.width.toDouble(), frame.height.toDouble()));
        return Image.memory(
          frame.bytes,
          fit: BoxFit.cover,
          gaplessPlayback: true,
          semanticLabel: context.l10n.videoPreview,
        );
      },
    );
  }
}

/// Plays a video right inside the feed card — no new screen. Shows the
/// poster until the user taps play; one video plays at a time, it pauses
/// when another starts, when the tab changes and when the app goes to the
/// background, and its resources are released as soon as it scrolls away.
class InlineVideo extends ConsumerStatefulWidget {
  final MediaItem item;
  final String postId;
  final ValueChanged<Size>? onSize;

  const InlineVideo({
    super.key,
    required this.item,
    required this.postId,
    this.onSize,
  });

  @override
  ConsumerState<InlineVideo> createState() => _InlineVideoState();
}

class _InlineVideoState extends ConsumerState<InlineVideo>
    with WidgetsBindingObserver {
  VideoPlayerController? _controller;
  bool _starting = false;
  String? _error;
  late final String _id = '${widget.postId}:${widget.item.url}';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.removeListener(_onTick);
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) _controller?.pause();
  }

  void _onTick() {
    if (mounted) setState(() {});
  }

  Future<void> _start() async {
    if (_starting) return;
    setState(() {
      _starting = true;
      _error = null;
    });
    ref.read(activeVideoProvider.notifier).state = _id;
    VideoPlayerController controller;
    try {
      controller = widget.item.isEncrypted
          ? VideoPlayerController.file(
              await ref.read(privateMediaProvider).videoFile(widget.item),
              videoPlayerOptions: VideoPlayerOptions(mixWithOthers: false),
            )
          : VideoPlayerController.networkUrl(
              Uri.parse(widget.item.url),
              videoPlayerOptions: VideoPlayerOptions(mixWithOthers: false),
            );
    } catch (_) {
      if (mounted) {
        setState(() {
          _starting = false;
          _error = context.l10n.cannotOpenPrivateVideo;
        });
      }
      return;
    }
    try {
      await controller.initialize().timeout(const Duration(seconds: 20));
      if (!mounted) {
        await controller.dispose();
        return;
      }
      await controller.setLooping(true);
      await controller.setVolume(ref.read(videoMutedProvider) ? 0 : 1);
      controller.addListener(_onTick);
      await controller.play();
      setState(() {
        _controller = controller;
        _starting = false;
      });
    } catch (e) {
      await controller.dispose();
      if (mounted) {
        setState(() {
          _starting = false;
          _error = context.l10n.cannotPlayVideo;
        });
      }
    }
  }

  void _toggle() {
    final c = _controller;
    if (c == null) {
      _start();
      return;
    }
    if (c.value.isPlaying) {
      c.pause();
    } else {
      ref.read(activeVideoProvider.notifier).state = _id;
      c.play();
    }
    setState(() {});
  }

  void _toggleMute() {
    final muted = !ref.read(videoMutedProvider);
    ref.read(videoMutedProvider.notifier).state = muted;
    _controller?.setVolume(muted ? 0 : 1);
  }

  @override
  Widget build(BuildContext context) {
    // Another video started, or the tab changed: pause this one.
    ref.listen(activeVideoProvider, (_, active) {
      if (active != _id) _controller?.pause();
    });
    final muted = ref.watch(videoMutedProvider);
    final c = _controller;
    final ready = c != null && c.value.isInitialized;
    final playing = ready && c.value.isPlaying;
    final buffering = _starting || (ready && c.value.isBuffering && playing);

    return Stack(
      fit: StackFit.expand,
      children: [
        VideoPoster(
          item: widget.item,
          postId: widget.postId,
          onSize: widget.onSize,
        ),
        if (ready)
          ClipRect(
            child: FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: c.value.size.width,
                height: c.value.size.height,
                child: VideoPlayer(c),
              ),
            ),
          ),
        Positioned.fill(
          child: Semantics(
            button: true,
            label: playing ? context.l10n.pauseVideo : context.l10n.playVideo,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _toggle,
              child: Center(
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 150),
                  opacity: playing || buffering ? 0 : 1,
                  child: _CircleIcon(
                    icon: _error != null
                        ? Icons.refresh
                        : Icons.play_arrow_rounded,
                    size: 64,
                  ),
                ),
              ),
            ),
          ),
        ),
        if (buffering)
          const Center(
            child: SizedBox(
              width: 36,
              height: 36,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: Colors.white,
              ),
            ),
          ),
        if (_error != null)
          Positioned(
            left: 12,
            right: 12,
            bottom: 12,
            child: Text(
              context.l10n.errorTapToRetry(_error!),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                shadows: [Shadow(blurRadius: 4)],
              ),
            ),
          ),
        if (ready)
          Positioned(
            right: 8,
            bottom: 12,
            child: Semantics(
              button: true,
              label: muted ? context.l10n.soundOn : context.l10n.soundOff,
              child: GestureDetector(
                onTap: _toggleMute,
                child: _CircleIcon(
                  icon: muted ? Icons.volume_off : Icons.volume_up,
                  size: 32,
                ),
              ),
            ),
          ),
        if (ready)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: VideoProgressIndicator(
              c,
              allowScrubbing: true,
              padding: EdgeInsets.zero,
              colors: const VideoProgressColors(
                playedColor: Colors.white,
                bufferedColor: Colors.white30,
                backgroundColor: Colors.black26,
              ),
            ),
          ),
        if (!ready && !_starting && widget.item.duration != null)
          Positioned(
            right: 10,
            top: 10,
            child: _DurationBadge(seconds: widget.item.duration!),
          ),
      ],
    );
  }
}

class _CircleIcon extends StatelessWidget {
  final IconData icon;
  final double size;
  const _CircleIcon({required this.icon, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: Colors.black54,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: Colors.white, size: size * 0.6),
    );
  }
}

class _DurationBadge extends StatelessWidget {
  final double seconds;
  const _DurationBadge({required this.seconds});

  @override
  Widget build(BuildContext context) {
    final total = seconds.round();
    final text = '${total ~/ 60}:${(total % 60).toString().padLeft(2, '0')}';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
    );
  }
}
