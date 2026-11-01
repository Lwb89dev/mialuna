import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mialuna/core/media/blossom.dart';
import 'package:mialuna/core/nostr/event.dart';
import 'package:mialuna/core/nostr/signer.dart';

void main() {
  final signer = NsecSigner.fromNsec(
    '67dea2ed018072d675f5415ecfaed7d2597555e202d85b3d65ea4e58d2d92ffa',
  );
  final bytes = Uint8List.fromList([1, 2, 3, 4]);
  final hash = sha256.convert(bytes).toString();

  http.Response okResponse(String host, {int status = 200, String? sha}) =>
      http.Response(
        jsonEncode({
          'url': 'https://$host/${sha ?? hash}.jpg',
          'sha256': sha ?? hash,
          'size': 4,
          'type': 'image/jpeg',
        }),
        status,
      );

  group('BlossomClient', () {
    test(
      'sends a valid kind 24242 authorization event and the hash header',
      () async {
        Map<String, dynamic>? auth;
        String? hashHeader;
        String? contentType;
        final mock = MockClient((request) async {
          final header = request.headers['Authorization']!;
          expect(header.startsWith('Nostr '), true);
          auth = jsonDecode(
            utf8.decode(base64Decode(header.substring(6))),
          ) as Map<String, dynamic>;
          hashHeader = request.headers['X-SHA-256'];
          contentType = request.headers['Content-Type'];
          expect(request.method, 'PUT');
          expect(request.url.path, '/upload');
          expect(request.bodyBytes, bytes);
          return okResponse('cdn.example.com');
        });
        final client = BlossomClient([
          'https://blossom.example.com',
        ], httpClient: mock);
        final result = await client.upload(
          signer: signer,
          bytes: bytes,
          mimeType: 'image/jpeg',
        );
        expect(result.url, contains('cdn.example.com'));
        expect(result.server, 'https://blossom.example.com');
        expect(hashHeader, hash);
        expect(contentType, 'image/jpeg');
        expect(auth!['kind'], NostrKinds.blossomAuth);
        final tags = auth!['tags'] as List;
        expect(tags.any((t) => t[0] == 't' && t[1] == 'upload'), true);
        expect(tags.any((t) => t[0] == 'x' && t[1] == hash), true);
        expect(tags.any((t) => t[0] == 'expiration'), true);
        expect(verifyEventSignature(NostrEvent.fromJson(auth!)), true);
      },
    );

    test('reports real progress while the body is sent', () async {
      final big = Uint8List(300 * 1024);
      final progress = <double>[];
      final mock = MockClient((request) async {
        final h = sha256.convert(big).toString();
        return okResponse('cdn.example.com', sha: h);
      });
      final client = BlossomClient(['https://b.example.com'], httpClient: mock);
      await client.upload(
        signer: signer,
        bytes: big,
        mimeType: 'image/jpeg',
        onProgress: progress.add,
      );
      expect(progress.length, greaterThan(3));
      expect(progress, orderedEquals([...progress]..sort()));
      expect(progress.last, 1.0);
    });

    test('falls back to the next server of the user\'s list', () async {
      final tried = <String>[];
      final mock = MockClient((request) async {
        tried.add(request.url.host);
        if (request.url.host == 'first.example.com') {
          return http.Response(
            '',
            401,
            headers: {'x-reason': 'Pubkey not authorized'},
          );
        }
        return okResponse(request.url.host);
      });
      final client = BlossomClient([
        'https://first.example.com',
        'https://second.example.com',
      ], httpClient: mock);
      final result = await client.upload(
        signer: signer,
        bytes: bytes,
        mimeType: 'image/jpeg',
      );
      expect(tried, ['first.example.com', 'second.example.com']);
      expect(result.server, 'https://second.example.com');
    });

    test(
      'signs the authorization once, whatever the number of servers',
      () async {
        final auths = <String>{};
        final mock = MockClient((request) async {
          auths.add(request.headers['Authorization']!);
          return http.Response('no', 500);
        });
        final client = BlossomClient([
          'https://a.example.com',
          'https://b.example.com',
          'https://c.example.com',
        ], httpClient: mock);
        await expectLater(
          client.upload(signer: signer, bytes: bytes, mimeType: 'image/jpeg'),
          throwsA(isA<BlossomException>()),
        );
        expect(auths, hasLength(1)); // one Amber prompt, not three
      },
    );

    test('says why every server refused', () async {
      final mock = MockClient((request) async {
        return switch (request.url.host) {
          'a.example.com' => http.Response('', 413),
          'b.example.com' => http.Response(
            jsonEncode({'message': 'type not allowed'}),
            415,
          ),
          _ => http.Response('', 403, headers: {'X-Reason': 'blocked'}),
        };
      });
      final client = BlossomClient([
        'https://a.example.com',
        'https://b.example.com',
        'https://c.example.com',
      ], httpClient: mock);
      try {
        await client.upload(
          signer: signer,
          bytes: bytes,
          mimeType: 'image/jpeg',
        );
        fail('should have thrown');
      } on BlossomException catch (e) {
        expect(e.details, hasLength(3));
        expect(e.message, contains('file too large'));
        expect(e.message, contains('type not allowed'));
        expect(e.message, contains('blocked'));
      }
    });

    test('a file the server already has (409) is a success', () async {
      final mock = MockClient((request) async {
        return http.Response(
          '',
          409,
          headers: {'X-Reason': 'An identical image already exists'},
        );
      });
      final client = BlossomClient([
        'https://nostr.example.com',
      ], httpClient: mock);
      final result = await client.upload(
        signer: signer,
        bytes: bytes,
        mimeType: 'image/jpeg',
      );
      expect(result.url, 'https://nostr.example.com/$hash.jpg');
    });

    test('a server that returns a different hash is not trusted', () async {
      final mock = MockClient(
        (request) async => okResponse('evil.example.com', sha: 'ab' * 32),
      );
      final client = BlossomClient(['https://b.example.com'], httpClient: mock);
      await expectLater(
        client.upload(signer: signer, bytes: bytes, mimeType: 'image/jpeg'),
        throwsA(
          isA<BlossomException>().having(
            (e) => e.message,
            'message',
            contains('modified'),
          ),
        ),
      );
    });

    test('failed upload throws and yields no URL', () async {
      final mock = MockClient(
        (request) async => http.Response('{"message":"nope"}', 403),
      );
      final client = BlossomClient([
        'https://blossom.example.com',
      ], httpClient: mock);
      await expectLater(
        client.upload(signer: signer, bytes: bytes, mimeType: 'image/jpeg'),
        throwsA(isA<BlossomException>()),
      );
    });

    test('guest mode cannot upload', () {
      final client = BlossomClient(['https://blossom.example.com']);
      expect(
        () => client.upload(
          signer: GuestSigner(),
          bytes: bytes,
          mimeType: 'image/jpeg',
        ),
        throwsA(isA<BlossomException>()),
      );
    });

    test('an empty server list is an explicit error', () {
      final client = BlossomClient(const []);
      expect(
        () =>
            client.upload(signer: signer, bytes: bytes, mimeType: 'image/jpeg'),
        throwsA(isA<BlossomException>()),
      );
    });

    test('rejects invalid or unsafe media URLs in the response', () async {
      for (final bad in [
        'not a url',
        'http://127.0.0.1/x.jpg',
        'https://www.youtube.com/watch?v=1',
      ]) {
        final mock = MockClient(
          (request) async => http.Response(jsonEncode({'url': bad}), 200),
        );
        final client = BlossomClient([
          'https://blossom.example.com',
        ], httpClient: mock);
        await expectLater(
          client.upload(signer: signer, bytes: bytes, mimeType: 'image/jpeg'),
          throwsA(isA<BlossomException>()),
          reason: bad,
        );
      }
    });
  });
}
