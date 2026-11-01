import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;

import '../../l10n/strings.dart';
import '../nostr/event.dart';
import '../nostr/models/media_event.dart' show isUsableMediaUrl;
import '../nostr/signer.dart';

class BlossomUploadResult {
  final String url;
  final String sha256;
  final int size;
  final String? mimeType;

  /// The server that accepted the file.
  final String server;
  const BlossomUploadResult({
    required this.url,
    required this.sha256,
    required this.size,
    this.mimeType,
    this.server = '',
  });
}

class BlossomException implements Exception {
  final String message;

  /// One line per server that refused the upload.
  final List<String> details;
  const BlossomException(this.message, {this.details = const []});
  @override
  String toString() => 'BlossomException: $message';
}

class _ServerRefused implements Exception {
  final String reason;
  const _ServerRefused(this.reason);
}

/// Blossom media server client (BUD-01/BUD-02). Uploads are authorized with
/// a kind 24242 Nostr event passed in the `Authorization: Nostr <base64>`
/// header. The file is only ever sent to the servers in [servers] — the
/// user's own list — in order, until one accepts it.
class BlossomClient {
  final List<String> servers;
  final http.Client _http;

  BlossomClient(this.servers, {http.Client? httpClient})
    : _http = httpClient ?? http.Client();

  /// Servers that refused an opaque (encrypted) blob; later encrypted uploads
  /// try them last, so the answer is not paid for on every file.
  static final Set<String> _refusesOpaque = {};

  /// Forgets what was learned about servers (tests, settings changes).
  static void forgetServerBehaviour() => _refusesOpaque.clear();

  static const defaultServer = 'https://blossom.primal.net';

  /// Uploads [bytes] and returns the content-addressed descriptor.
  /// Throws [BlossomException] on any failure — callers must never publish
  /// a media event referencing a failed upload.
  Future<BlossomUploadResult> upload({
    required Signer signer,
    required Uint8List bytes,
    required String mimeType,
    String? label,
    void Function(double progress)? onProgress,

    /// The bytes are ciphertext (close-friends media): many servers inspect
    /// the content type and refuse random bytes, so servers known to do so
    /// are tried last.
    bool opaque = false,
  }) async {
    if (!signer.canSign) {
      throw BlossomException(AppStrings.current.signInToUploadMedia);
    }
    if (servers.isEmpty) {
      throw BlossomException(AppStrings.current.noMediaServer);
    }
    final hash = sha256.convert(bytes).toString();
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    // Signed once and reused for every server (one Amber prompt).
    final authEvent = await signer.signEvent(
      kind: NostrKinds.blossomAuth,
      tags: [
        ['t', 'upload'],
        ['x', hash],
        ['expiration', '${now + 600}'],
      ],
      content: 'Upload ${label ?? 'media'}',
    );
    final authHeader =
        'Nostr ${base64Encode(utf8.encode(jsonEncode(authEvent.toJson())))}';

    final failures = <String>[];
    final ordered = opaque
        ? [
            ...servers.where((s) => !_refusesOpaque.contains(s)),
            ...servers.where(_refusesOpaque.contains),
          ]
        : servers;
    for (final server in ordered) {
      try {
        return await _uploadTo(
          server,
          bytes: bytes,
          hash: hash,
          mimeType: mimeType,
          authHeader: authHeader,
          onProgress: onProgress,
        );
      } on _ServerRefused catch (e) {
        if (opaque &&
            (e.reason.startsWith('415') ||
                e.reason.startsWith('400') ||
                e.reason.startsWith('403'))) {
          _refusesOpaque.add(server);
        }
        failures.add('${_host(server)}: ${e.reason}');
      } on TimeoutException {
        failures.add(AppStrings.current.serverNoResponse(_host(server)));
      } on http.ClientException catch (e) {
        failures.add(
          AppStrings.current.serverUnreachable(_host(server), e.message),
        );
      } catch (e) {
        failures.add('${_host(server)}: $e');
      }
    }
    throw BlossomException(
      failures.length == 1
          ? AppStrings.current.uploadRejected(failures.first)
          : AppStrings.current.noServerAcceptedFile(failures.join(' · ')),
      details: failures,
    );
  }

  Future<BlossomUploadResult> _uploadTo(
    String server, {
    required Uint8List bytes,
    required String hash,
    required String mimeType,
    required String authHeader,
    void Function(double progress)? onProgress,
  }) async {
    final base = server.replaceAll(RegExp(r'/+$'), '');
    final request = http.StreamedRequest('PUT', Uri.parse('$base/upload'))
      ..contentLength = bytes.length
      ..headers['Authorization'] = authHeader
      ..headers['Content-Type'] = mimeType
      ..headers['X-SHA-256'] = hash;
    unawaited(
      request.sink
          .addStream(_chunks(bytes, onProgress))
          .whenComplete(request.sink.close),
    );

    final timeout = Duration(seconds: max(90, bytes.length ~/ (100 * 1024)));
    final response = await _http.send(request).timeout(timeout);
    final body = await response.stream.bytesToString().timeout(
      const Duration(seconds: 30),
    );
    final status = response.statusCode;

    if (status == 200 || status == 201) {
      Map<String, dynamic> json;
      try {
        json = jsonDecode(body) as Map<String, dynamic>;
      } catch (_) {
        throw _ServerRefused(AppStrings.current.blossomInvalidResponse);
      }
      final url = json['url'] as String?;
      if (url == null || !isUsableMediaUrl(url)) {
        throw _ServerRefused(AppStrings.current.blossomInvalidFileUrl);
      }
      final returnedHash = json['sha256'] as String?;
      if (returnedHash != null && returnedHash.toLowerCase() != hash) {
        throw _ServerRefused(AppStrings.current.blossomServerAlteredFile);
      }
      onProgress?.call(1.0);
      return BlossomUploadResult(
        url: url,
        sha256: hash,
        size: (json['size'] as num?)?.toInt() ?? bytes.length,
        mimeType: json['type'] as String? ?? mimeType,
        server: server,
      );
    }

    // The server already holds this exact file: it is not an error.
    if (status == 409 && _looksLikeDuplicate(response, body)) {
      final url = '$base/$hash${_extensionFor(mimeType)}';
      onProgress?.call(1.0);
      return BlossomUploadResult(
        url: url,
        sha256: hash,
        size: bytes.length,
        mimeType: mimeType,
        server: server,
      );
    }
    throw _ServerRefused(_describe(status, response.headers, body));
  }

  static Stream<List<int>> _chunks(
    Uint8List bytes,
    void Function(double)? onProgress,
  ) async* {
    const chunk = 64 * 1024;
    for (var i = 0; i < bytes.length; i += chunk) {
      final end = min(i + chunk, bytes.length);
      yield Uint8List.sublistView(bytes, i, end);
      // 5% is reserved for the server's final answer.
      onProgress?.call(0.95 * end / bytes.length);
    }
  }

  /// Header lookup that ignores case (proxies and clients differ).
  static String _header(Map<String, String> headers, String name) {
    for (final e in headers.entries) {
      if (e.key.toLowerCase() == name) return e.value;
    }
    return '';
  }

  static bool _looksLikeDuplicate(http.BaseResponse r, String body) {
    final text = '${_header(r.headers, 'x-reason')} $body'.toLowerCase();
    return text.contains('already') || text.contains('exist');
  }

  static String _extensionFor(String mime) => switch (mime) {
    'image/jpeg' => '.jpg',
    'image/png' => '.png',
    'image/webp' => '.webp',
    'image/gif' => '.gif',
    'video/mp4' => '.mp4',
    'video/quicktime' => '.mov',
    _ => '',
  };

  /// Human-readable reason for a refused upload.
  static String _describe(
    int status,
    Map<String, String> headers,
    String body,
  ) {
    var reason = _header(headers, 'x-reason').trim();
    if (reason.isEmpty) {
      try {
        final json = jsonDecode(body);
        if (json is Map) {
          reason = '${json['message'] ?? json['error'] ?? ''}'.trim();
        }
      } catch (_) {
        reason = body.trim();
      }
    }
    if (reason.length > 140) reason = '${reason.substring(0, 140)}…';
    final meaning = switch (status) {
      400 => AppStrings.current.blossomBadRequest,
      401 => AppStrings.current.blossomUnauthorized,
      402 => AppStrings.current.blossomPaymentRequired,
      403 => AppStrings.current.blossomForbidden,
      411 => AppStrings.current.blossomLengthRequired,
      413 => AppStrings.current.blossomTooLarge,
      415 => AppStrings.current.blossomUnsupportedType,
      429 => AppStrings.current.blossomTooManyRequests,
      >= 500 => AppStrings.current.blossomServerError,
      _ => AppStrings.current.blossomOtherError,
    };
    return reason.isEmpty ? '$status $meaning' : '$status $meaning ($reason)';
  }

  static String _host(String server) => Uri.tryParse(server)?.host ?? server;
}
