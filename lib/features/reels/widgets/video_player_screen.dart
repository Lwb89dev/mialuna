import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../../core/nostr/models/media_event.dart';

/// Full-screen video player with controls, mute, scrubbing, buffering
/// indicator and retry on failure.
class VideoPlayerScreen extends StatefulWidget {
  final MediaItem item;
  final String? title;

  const VideoPlayerScreen({super.key, required this.item, this.title});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  VideoPlayerController? _controller;
  String? _error;
  bool _muted = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    setState(() => _error = null);
    final controller = VideoPlayerController.networkUrl(
      Uri.parse(widget.item.url),
    );
    try {
      await controller.initialize();
      controller.addListener(_onTick);
      await controller.play();
      if (mounted) setState(() => _controller = controller);
    } catch (e) {
      if (mounted) setState(() => _error = 'Errore di riproduzione: $e');
      controller.dispose();
    }
  }

  void _onTick() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller?.removeListener(_onTick);
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = _controller;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        title: widget.title != null ? Text(widget.title!) : null,
      ),
      body: Center(
        child: _error != null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _error!,
                    style: const TextStyle(color: Colors.white70),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  FilledButton.tonal(
                    onPressed: _init,
                    child: const Text('Riprova'),
                  ),
                ],
              )
            : c == null || !c.value.isInitialized
            ? const CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AspectRatio(
                    aspectRatio: c.value.aspectRatio,
                    child: GestureDetector(
                      onTap: () => c.value.isPlaying ? c.pause() : c.play(),
                      child: VideoPlayer(c),
                    ),
                  ),
                  VideoProgressIndicator(c, allowScrubbing: true),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        color: Colors.white,
                        icon: Icon(
                          c.value.isPlaying ? Icons.pause : Icons.play_arrow,
                        ),
                        onPressed: () =>
                            c.value.isPlaying ? c.pause() : c.play(),
                      ),
                      IconButton(
                        color: Colors.white,
                        icon: Icon(_muted ? Icons.volume_off : Icons.volume_up),
                        onPressed: () {
                          c.setVolume(_muted ? 1 : 0);
                          setState(() => _muted = !_muted);
                        },
                      ),
                      if (c.value.isBuffering)
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white70,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }
}
