import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

import '../nostr/models/media_event.dart' show isUsableMediaUrl;

/// One decoded still of a video.
class VideoFrame {
  final Uint8List bytes; // JPEG
  final int width;
  final int height;
  final int durationMs;
  const VideoFrame({
    required this.bytes,
    required this.width,
    required this.height,
    required this.durationMs,
  });
}

/// Extracts still frames from videos with the platform decoder (a small
/// native bridge, no plugin). Used for the feed posters of videos that have
/// no thumbnail in their event and for the cover image of new videos.
abstract final class VideoFrames {
  static const _channel = MethodChannel('app.mialuna.social/media');
  static const _maxConcurrent = 2;

  static final LinkedHashMap<String, VideoFrame?> _memory = LinkedHashMap();
  static final Map<String, Future<VideoFrame?>> _inflight = {};
  static final List<Completer<void>> _waiters = [];
  static int _active = 0;

  /// Frame at [timeMs] of a local file path or an https URL; null when the
  /// platform cannot decode it. Never throws.
  static Future<VideoFrame?> extract(
    String source, {
    int maxWidth = 720,
    int timeMs = 500,
    Duration timeout = const Duration(seconds: 15),
  }) => _limited(() async {
    try {
      final map = await _channel
          .invokeMapMethod<String, Object?>('videoThumbnail', {
            'source': source,
            'maxWidth': maxWidth,
            'timeMs': timeMs,
          })
          .timeout(timeout);
      if (map == null) return null;
      return VideoFrame(
        bytes: map['bytes'] as Uint8List,
        width: (map['width'] as num).toInt(),
        height: (map['height'] as num).toInt(),
        durationMs: (map['durationMs'] as num?)?.toInt() ?? 0,
      );
    } catch (_) {
      return null;
    }
  });

  /// Poster for a remote video: memory cache, then disk cache, then the
  /// platform decoder reading just enough of the stream.
  static Future<VideoFrame?> forUrl(String url) {
    if (!isUsableMediaUrl(url)) return Future.value(null);
    if (_memory.containsKey(url)) {
      final hit = _memory.remove(url);
      _memory[url] = hit; // refresh LRU position
      return Future.value(hit);
    }
    return _inflight[url] ??= _load(url).whenComplete(() {
      _inflight.remove(url);
    });
  }

  static Future<VideoFrame?> _load(String url) async {
    final key = sha1.convert(utf8.encode(url)).toString();
    VideoFrame? frame = await _readDisk(key);
    if (frame == null) {
      frame = await extract(url);
      if (frame != null) await _writeDisk(key, frame);
    }
    _memory[url] = frame;
    if (_memory.length > 80) _memory.remove(_memory.keys.first);
    return frame;
  }

  static Future<Directory> _dir() async {
    final base = await getTemporaryDirectory();
    final dir = Directory('${base.path}/mialuna_posters');
    if (!dir.existsSync()) dir.createSync(recursive: true);
    return dir;
  }

  static Future<VideoFrame?> _readDisk(String key) async {
    try {
      final dir = await _dir();
      final meta = File('${dir.path}/$key.json');
      final jpg = File('${dir.path}/$key.jpg');
      if (!meta.existsSync() || !jpg.existsSync()) return null;
      final json =
          jsonDecode(await meta.readAsString()) as Map<String, dynamic>;
      return VideoFrame(
        bytes: await jpg.readAsBytes(),
        width: (json['w'] as num).toInt(),
        height: (json['h'] as num).toInt(),
        durationMs: (json['d'] as num).toInt(),
      );
    } catch (_) {
      return null;
    }
  }

  static Future<void> _writeDisk(String key, VideoFrame frame) async {
    try {
      final dir = await _dir();
      await File('${dir.path}/$key.jpg').writeAsBytes(frame.bytes);
      await File('${dir.path}/$key.json').writeAsString(
        jsonEncode({
          'w': frame.width,
          'h': frame.height,
          'd': frame.durationMs,
        }),
      );
    } catch (_) {}
  }

  static Future<T> _limited<T>(Future<T> Function() op) async {
    while (_active >= _maxConcurrent) {
      final waiter = Completer<void>();
      _waiters.add(waiter);
      await waiter.future;
    }
    _active++;
    try {
      return await op();
    } finally {
      _active--;
      if (_waiters.isNotEmpty) _waiters.removeAt(0).complete();
    }
  }
}
