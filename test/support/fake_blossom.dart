import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

/// An in-memory Blossom server (any host name): PUT /upload stores a blob,
/// GET `/{sha256}` returns it. Records what was uploaded and by whom.
class FakeBlossom {
  final Map<String, Uint8List> blobs = {};
  final List<String> uploadContentTypes = [];
  final List<String> uploaderPubkeys = [];

  /// Answer 415 to anything that is not a recognisable image/video, like
  /// Primal does.
  bool refuseOpaque = false;

  late final MockClient client = MockClient((request) async {
    if (request.method == 'PUT' && request.url.path == '/upload') {
      final type = request.headers['Content-Type'] ?? '';
      uploadContentTypes.add(type);
      final auth = request.headers['Authorization'] ?? '';
      if (auth.startsWith('Nostr ')) {
        final event = jsonDecode(
          utf8.decode(base64Decode(auth.substring(6))),
        ) as Map<String, dynamic>;
        uploaderPubkeys.add(event['pubkey'] as String);
      }
      if (refuseOpaque && type == 'application/octet-stream') {
        return http.Response(
          '',
          415,
          headers: {
            'x-reason': 'upload rejected: unsupported media type application/octet-stream',
          },
        );
      }
      final hash = sha256.convert(request.bodyBytes).toString();
      blobs[hash] = Uint8List.fromList(request.bodyBytes);
      return http.Response(
        jsonEncode({
          'url': 'https://${request.url.host}/$hash',
          'sha256': hash,
          'size': request.bodyBytes.length,
          'type': type,
        }),
        200,
      );
    }
    if (request.method == 'GET') {
      final hash = request.url.pathSegments.isEmpty
          ? ''
          : request.url.pathSegments.last.split('.').first;
      final blob = blobs[hash];
      return blob == null
          ? http.Response('', 404)
          : http.Response.bytes(blob, 200);
    }
    return http.Response('', 404);
  });
}
