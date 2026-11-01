import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;

import '../nostr/event.dart';
import '../nostr/signer.dart';

class BlossomUploadResult {
  final String url;
  final String sha256;
  final int size;
  final String? mimeType;
  const BlossomUploadResult({
    required this.url,
    required this.sha256,
    required this.size,
    this.mimeType,
  });
}

class BlossomException implements Exception {
  final String message;
  const BlossomException(this.message);
  @override
  String toString() => 'BlossomException: $message';
}

/// Blossom media server client (BUD-01/BUD-02). Uploads are authorized with
/// a kind 24242 Nostr event passed in the `Authorization: Nostr <base64>`
/// header.
class BlossomClient {
  final String serverUrl;
  final http.Client _http;

  BlossomClient(this.serverUrl, {http.Client? httpClient})
    : _http = httpClient ?? http.Client();

  static const defaultServer = 'https://blossom.primal.net';

  /// Uploads [bytes] and returns the content-addressed descriptor.
  /// Throws [BlossomException] on any failure — callers must never publish
  /// a media event referencing a failed upload.
  Future<BlossomUploadResult> upload({
    required Signer signer,
    required Uint8List bytes,
    required String mimeType,
    void Function(double progress)? onProgress,
  }) async {
    if (!signer.canSign) {
      throw const BlossomException('Cannot upload in guest mode');
    }
    final hash = sha256.convert(bytes).toString();
    final authEvent = await signer.signEvent(
      kind: NostrKinds.blossomAuth,
      tags: [
        ['t', 'upload'],
        ['x', hash],
        [
          'expiration',
          ((DateTime.now().millisecondsSinceEpoch ~/ 1000) + 300).toString(),
        ],
      ],
      content: 'Upload media to $serverUrl',
    );
    final authHeader =
        'Nostr ${base64Encode(utf8.encode(jsonEncode(authEvent.toJson())))}';

    final base = serverUrl.endsWith('/')
        ? serverUrl.substring(0, serverUrl.length - 1)
        : serverUrl;
    final request = http.Request('PUT', Uri.parse('$base/upload'))
      ..headers['Authorization'] = authHeader
      ..headers['Content-Type'] = mimeType
      ..bodyBytes = bytes;

    onProgress?.call(0.1);
    final response = await _http.send(request);
    final body = await response.stream.bytesToString();
    onProgress?.call(1.0);

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw BlossomException('Upload failed (${response.statusCode}): $body');
    }
    final json = jsonDecode(body) as Map<String, dynamic>;
    final url = json['url'] as String?;
    if (url == null || !_isValidMediaUrl(url)) {
      throw const BlossomException('Server returned an invalid media URL');
    }
    return BlossomUploadResult(
      url: url,
      sha256: json['sha256'] as String? ?? hash,
      size: (json['size'] as num?)?.toInt() ?? bytes.length,
      mimeType: json['type'] as String? ?? mimeType,
    );
  }

  static bool _isValidMediaUrl(String url) {
    final uri = Uri.tryParse(url);
    return uri != null && (uri.scheme == 'https' || uri.scheme == 'http');
  }
}
