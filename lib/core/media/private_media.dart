import 'dart:async';
import 'dart:collection';
import 'dart:io';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import '../../l10n/strings.dart';
import '../nostr/models/media_event.dart';
import 'media_cipher.dart';

/// Downloads and decrypts the media of close-friends posts. Nothing is
/// written to disk except decrypted *videos* (the player needs a file); those
/// live in the app's cache folder and are wiped after a day and at logout.
class PrivateMediaService {
  static const maxFileBytes = 120 * 1024 * 1024;
  static const _memoryBudget = 48 * 1024 * 1024;
  static const _fileMaxAge = Duration(hours: 24);

  final http.Client _http;
  final Directory? _directory;

  final LinkedHashMap<String, Uint8List> _memory = LinkedHashMap();
  final Map<String, Future<Uint8List>> _inflight = {};
  final Map<String, Future<File>> _files = {};
  int _memoryBytes = 0;

  PrivateMediaService(this._http, {this._directory});

  /// The decrypted picture of [item] — or of its cover when [preview].
  Future<Uint8List> imageBytes(MediaItem item, {bool preview = false}) {
    final url = preview ? item.previewUrl : item.url;
    final encryption = preview ? item.previewEncryption : item.encryption;
    if (url == null || encryption == null) {
      return Future.error(
        MediaCipherException(AppStrings.current.privateMediaNotEncrypted),
      );
    }
    final key = '$url|${encryption.key}';
    final hit = _memory.remove(key);
    if (hit != null) {
      _memory[key] = hit; // refresh LRU position
      return Future.value(hit);
    }
    return _inflight[key] ??=
        _load(
              url,
              encryption,
              expectedPlain: preview ? null : item.plainSha256,
              expectedCipher: preview ? null : item.sha256,
              mirrors: preview ? const [] : item.fallbackUrls,
            )
            .then((bytes) {
              _remember(key, bytes);
              return bytes;
            })
            .whenComplete(() {
              _inflight.remove(key);
            });
  }

  /// A decrypted copy of the video as a file the player can open.
  Future<File> videoFile(MediaItem item) {
    final encryption = item.encryption;
    if (encryption == null) {
      return Future.error(
        MediaCipherException(AppStrings.current.privateMediaNotEncrypted),
      );
    }
    final key = '${item.url}|${encryption.key}';
    return _files[key] ??= () async {
      try {
        final dir = await _folder();
        final name =
            '${MediaCipher.sha256Hex(key.codeUnits)}.${_extension(item)}';
        final file = File('${dir.path}/$name');
        if (file.existsSync() && file.lengthSync() > 0) return file;
        final bytes = await _load(
          item.url,
          encryption,
          expectedPlain: item.plainSha256,
          expectedCipher: item.sha256,
          mirrors: item.fallbackUrls,
        );
        final tmp = File('${file.path}.part');
        await tmp.writeAsBytes(bytes, flush: true);
        await tmp.rename(file.path);
        return file;
      } catch (_) {
        _files.remove(key); // a failure must not be remembered: allow retry
        rethrow;
      }
    }();
  }

  Future<Uint8List> _load(
    String url,
    MediaEncryption encryption, {
    String? expectedPlain,
    String? expectedCipher,
    List<String> mirrors = const [],
  }) async {
    Object? lastError;
    for (final candidate in [url, ...mirrors]) {
      try {
        final request = http.Request('GET', Uri.parse(candidate));
        final response = await _http
            .send(request)
            .timeout(const Duration(seconds: 60));
        if (response.statusCode != 200) {
          throw MediaCipherException(
            AppStrings.current.serverReplied(response.statusCode),
          );
        }
        if ((response.contentLength ?? 0) > maxFileBytes + 16) {
          throw MediaCipherException(AppStrings.current.fileTooLarge);
        }
        // Read at most the limit: a hostile server cannot fill the memory.
        final builder = BytesBuilder(copy: false);
        await for (final chunk in response.stream.timeout(
          const Duration(seconds: 60),
        )) {
          builder.add(chunk);
          if (builder.length > maxFileBytes + 16) {
            throw MediaCipherException(AppStrings.current.fileTooLarge);
          }
        }
        final cipher = builder.takeBytes();
        if (expectedCipher != null &&
            MediaCipher.sha256Hex(cipher) != expectedCipher.toLowerCase()) {
          throw MediaCipherException(AppStrings.current.serverFileNotOriginal);
        }
        final plain = await MediaCipher.decryptAsync(
          cipher,
          keyHex: encryption.key,
          nonceHex: encryption.nonce,
        );
        if (expectedPlain != null &&
            MediaCipher.sha256Hex(plain) != expectedPlain.toLowerCase()) {
          throw MediaCipherException(AppStrings.current.contentMismatch);
        }
        return plain;
      } catch (e) {
        lastError = e;
      }
    }
    throw lastError ??
        MediaCipherException(AppStrings.current.mediaUnreachable);
  }

  void _remember(String key, Uint8List bytes) {
    if (bytes.length > _memoryBudget ~/ 2) return;
    _memory[key] = bytes;
    _memoryBytes += bytes.length;
    while (_memoryBytes > _memoryBudget && _memory.isNotEmpty) {
      final oldest = _memory.keys.first;
      _memoryBytes -= _memory.remove(oldest)!.length;
    }
  }

  static String _extension(MediaItem item) {
    final m = (item.mimeType ?? '').toLowerCase();
    if (m.contains('quicktime')) return 'mov';
    if (m.contains('webm')) return 'webm';
    return 'mp4';
  }

  Future<Directory> _folder() async {
    final base = _directory ?? await getTemporaryDirectory();
    final dir = Directory('${base.path}/mialuna_private');
    if (!dir.existsSync()) dir.createSync(recursive: true);
    return dir;
  }

  /// Removes decrypted videos older than a day (at start-up) or all of them.
  Future<void> cleanUp({bool everything = false}) async {
    try {
      final dir = await _folder();
      final limit = DateTime.now().subtract(_fileMaxAge);
      for (final f in dir.listSync()) {
        if (f is! File) continue;
        if (everything || f.statSync().modified.isBefore(limit)) {
          await f.delete();
        }
      }
    } catch (_) {}
    if (everything) {
      _memory.clear();
      _memoryBytes = 0;
      _files.clear();
    }
  }
}
