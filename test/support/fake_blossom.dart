import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mialuna/core/nostr/event.dart';
import 'package:mialuna/core/nostr/signer.dart';

/// An in-memory Blossom server (any host name): PUT /upload stores a blob,
/// GET `/{sha256}` returns it, DELETE `/{sha256}` removes it for the account
/// that uploaded it. Records what was uploaded and by whom.
class FakeBlossom {
  final Map<String, Uint8List> blobs = {};
  final List<String> uploadContentTypes = [];
  final List<String> uploaderPubkeys = [];

  /// Who uploaded each file (hash → pubkey): the only one that may delete it.
  final Map<String, String> owners = {};

  /// Every deletion request that reached the server, as `host/hash`.
  final List<String> deleteRequests = [];

  /// The authorizations those requests carried.
  final List<NostrEvent> deleteTokens = [];

  /// Answer every deletion with this status (a server that does not allow it).
  int? refuseDeleteWith;

  /// Answer 401 to an authorization that names more than one file, like the
  /// servers that read a single `x` tag.
  bool singleFileTokensOnly = false;

  /// Hosts that do not answer at all.
  final Set<String> deadHosts = {};

  NostrEvent? _token(String? header) {
    if (header == null || !header.startsWith('Nostr ')) return null;
    try {
      return NostrEvent.fromJson(
        jsonDecode(utf8.decode(base64Decode(header.substring(6))))
            as Map<String, dynamic>,
      );
    } catch (_) {
      return null;
    }
  }

  /// Why [token] does not allow deleting [hash], or null when it does.
  String? _tokenProblem(NostrEvent? token, String hash) {
    if (token == null) return 'missing authorization';
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final names = token.tagsNamed('x').map((t) => t[1]).toList();
    if (token.kind != NostrKinds.blossomAuth ||
        token.firstTagValue('t') != 'delete' ||
        !verifyEventSignature(token) ||
        token.isExpired(now) ||
        token.expiration == null) {
      return 'invalid authorization';
    }
    if (!names.contains(hash)) return 'authorization does not name the file';
    if (singleFileTokensOnly && names.length > 1) {
      return 'authorization must name one file';
    }
    return null;
  }

  http.Response _delete(http.Request request) {
    final hash = request.url.pathSegments.isEmpty
        ? ''
        : request.url.pathSegments.last;
    deleteRequests.add('${request.url.host}/$hash');
    if (deadHosts.contains(request.url.host)) {
      throw http.ClientException('connection refused');
    }
    final token = _token(request.headers['Authorization']);
    if (token != null) deleteTokens.add(token);
    final problem = _tokenProblem(token, hash);
    if (problem != null) {
      return http.Response('', 401, headers: {'x-reason': problem});
    }
    if (refuseDeleteWith != null) {
      return http.Response('', refuseDeleteWith!);
    }
    if (!blobs.containsKey(hash)) return http.Response('', 404);
    if (owners[hash] != token!.pubkey) {
      return http.Response('', 403, headers: {'x-reason': 'not the owner'});
    }
    blobs.remove(hash);
    return http.Response('', 200);
  }

  /// Answer 415 to anything that is not a recognisable image/video, like
  /// Primal does.
  bool refuseOpaque = false;

  late final MockClient client = MockClient((request) async {
    if (request.method == 'PUT' && request.url.path == '/upload') {
      final type = request.headers['Content-Type'] ?? '';
      uploadContentTypes.add(type);
      final auth = request.headers['Authorization'] ?? '';
      String? uploader;
      if (auth.startsWith('Nostr ')) {
        final event = jsonDecode(
          utf8.decode(base64Decode(auth.substring(6))),
        ) as Map<String, dynamic>;
        uploader = event['pubkey'] as String;
        uploaderPubkeys.add(uploader);
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
      if (uploader != null) owners[hash] = uploader;
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
    if (request.method == 'DELETE') return _delete(request);
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
