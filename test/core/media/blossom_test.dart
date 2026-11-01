import 'dart:convert';
import 'dart:typed_data';

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

  group('BlossomClient', () {
    test('sends a valid kind 24242 authorization event', () async {
      Map<String, dynamic>? capturedAuth;
      final mock = MockClient((request) async {
        final header = request.headers['Authorization']!;
        expect(header.startsWith('Nostr '), true);
        final json = jsonDecode(
          utf8.decode(base64Decode(header.substring('Nostr '.length))),
        ) as Map<String, dynamic>;
        capturedAuth = json;
        return http.Response(
          jsonEncode({
            'url': 'https://cdn.example.com/${'ab' * 32}.jpg',
            'sha256': 'ab' * 32,
            'size': 4,
            'type': 'image/jpeg',
          }),
          200,
        );
      });
      final client = BlossomClient(
        'https://blossom.example.com',
        httpClient: mock,
      );
      final result = await client.upload(
        signer: signer,
        bytes: Uint8List.fromList([1, 2, 3, 4]),
        mimeType: 'image/jpeg',
      );
      expect(result.url, contains('cdn.example.com'));
      expect(capturedAuth!['kind'], NostrKinds.blossomAuth);
      final tags = capturedAuth!['tags'] as List;
      expect(tags.any((t) => t[0] == 't' && t[1] == 'upload'), true);
      expect(tags.any((t) => t[0] == 'x'), true);
      expect(tags.any((t) => t[0] == 'expiration'), true);
      // The auth event must be verifiable.
      expect(verifyEventSignature(NostrEvent.fromJson(capturedAuth!)), true);
    });

    test('failed upload throws and yields no URL', () async {
      final mock = MockClient(
        (request) async => http.Response('{"message":"nope"}', 403),
      );
      final client = BlossomClient(
        'https://blossom.example.com',
        httpClient: mock,
      );
      expect(
        () => client.upload(
          signer: signer,
          bytes: Uint8List.fromList([1]),
          mimeType: 'image/jpeg',
        ),
        throwsA(isA<BlossomException>()),
      );
    });

    test('guest mode cannot upload', () {
      final client = BlossomClient('https://blossom.example.com');
      expect(
        () => client.upload(
          signer: GuestSigner(),
          bytes: Uint8List.fromList([1]),
          mimeType: 'image/jpeg',
        ),
        throwsA(isA<BlossomException>()),
      );
    });

    test('rejects invalid server URL in response', () {
      final mock = MockClient(
        (request) async => http.Response(jsonEncode({'url': 'not a url'}), 200),
      );
      final client = BlossomClient(
        'https://blossom.example.com',
        httpClient: mock,
      );
      expect(
        () => client.upload(
          signer: signer,
          bytes: Uint8List.fromList([1]),
          mimeType: 'image/jpeg',
        ),
        throwsA(isA<BlossomException>()),
      );
    });
  });
}
