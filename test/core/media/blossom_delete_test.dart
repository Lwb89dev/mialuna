import 'dart:async';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mialuna/core/media/blossom.dart';
import 'package:mialuna/core/nostr/event.dart';
import 'package:mialuna/core/nostr/signer.dart';

import '../../support/fake_blossom.dart';
import '../../support/recording_signer.dart';

void main() {
  final hash = sha256.convert([1, 2, 3]).toString();

  group('blobHashOfUrl', () {
    test(
      'reads the address out of a Blossom URL, with or without extension',
      () {
        expect(blobHashOfUrl('https://cdn.example.com/$hash.jpg'), hash);
        expect(blobHashOfUrl('https://cdn.example.com/media/$hash'), hash);
        expect(blobHashOfUrl('https://cdn.example.com/$hash.jpg?x=1#y'), hash);
        expect(
          blobHashOfUrl('https://cdn.example.com/${hash.toUpperCase()}'),
          hash,
        );
      },
    );

    test('is null for a URL that is not content-addressed', () {
      expect(blobHashOfUrl('https://cdn.example.com/photo.jpg'), isNull);
      expect(blobHashOfUrl('https://cdn.example.com/'), isNull);
      expect(blobHashOfUrl('https://cdn.example.com'), isNull);
      expect(blobHashOfUrl('not a url'), isNull);
      expect(
        blobHashOfUrl('https://cdn.example.com/${hash.substring(1)}.jpg'),
        isNull,
      );
      expect(blobHashOfUrl('https://cdn.example.com/${hash}00.jpg'), isNull);
    });
  });

  group('BlossomClient.delete', () {
    late FakeBlossom blossom;
    late RecordingSigner owner;

    setUp(() {
      blossom = FakeBlossom();
      owner = RecordingSigner.generate();
    });

    BlossomClient clientFor(List<String> servers) =>
        BlossomClient(servers, httpClient: blossom.client);

    Future<String> upload(
      int n, {
      Signer? by,
      String host = 'cdn.example.com',
    }) async {
      final result = await clientFor(['https://$host']).upload(
        signer: by ?? owner,
        bytes: Uint8List.fromList([n, n, n]),
        mimeType: 'image/jpeg',
      );
      return result.sha256;
    }

    test(
      'one authorization names every file, and the files are removed',
      () async {
        final files = [await upload(1), await upload(2), await upload(3)];
        final results = await clientFor(['https://cdn.example.com'])
            .delete(signer: owner, hashes: files);

        expect(results.length, 3);
        expect(
          results.every((r) => r.outcome == BlossomDeleteOutcome.deleted),
          true,
        );
        expect(blossom.blobs, isEmpty);
        expect(blossom.deleteRequests, [
          for (final h in files) 'cdn.example.com/$h',
        ]);

        final tokens = owner.authorizations('delete');
        expect(tokens.length, 1, reason: 'one signature, one Amber prompt');
        final token = tokens.single;
        expect(token.kind, NostrKinds.blossomAuth);
        expect(token.tagsNamed('x').map((t) => t[1]).toSet(), files.toSet());
        expect(verifyEventSignature(token), true);
        final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
        expect(token.expiration, inInclusiveRange(now + 1, now + 700));
      },
    );

    test(
      'asks the servers the post points at as well as the user\'s own',
      () async {
        final h = await upload(1);
        final results = await clientFor(['https://mine.example.org']).delete(
          signer: owner,
          hashes: [h],
          extraServers: [
            'https://cdn.example.com',
            'https://cdn.example.com/', // the same server
            'https://MINE.example.org', // the same as the user's own
          ],
        );

        expect(blossom.deleteRequests.toSet(), {
          'mine.example.org/$h',
          'cdn.example.com/$h',
        });
        expect(blossom.deleteRequests.length, 2);
        expect(results.every((r) => r.gone), true);
      },
    );

    test('never asks an insecure or private address', () async {
      final h = await upload(1);
      await clientFor(['http://insecure.example.com']).delete(
        signer: owner,
        hashes: [h],
        extraServers: [
          'https://localhost',
          'https://192.168.1.5',
          'https://box.local',
          'ftp://cdn.example.com',
          'not a server',
        ],
      );

      expect(blossom.deleteRequests, isEmpty);
      expect(
        owner.authorizations('delete'),
        isEmpty,
        reason: 'nothing to sign for',
      );
    });

    test('a server that does not hold the file counts as done', () async {
      final results = await clientFor(['https://cdn.example.com'])
          .delete(signer: owner, hashes: [hash]);

      expect(results.single.outcome, BlossomDeleteOutcome.absent);
      expect(results.single.gone, true);
    });

    test('a server that refuses says so, and the file stays', () async {
      final h = await upload(1);
      blossom.refuseDeleteWith = 403;
      final results = await clientFor(['https://cdn.example.com'])
          .delete(signer: owner, hashes: [h]);

      expect(results.single.outcome, BlossomDeleteOutcome.refused);
      expect(results.single.gone, false);
      expect(results.single.reason, contains('403'));
      expect(blossom.blobs, contains(h));
    });

    test('only the account that uploaded a file can take it down', () async {
      final h = await upload(1);
      final stranger = RecordingSigner.generate();
      final results = await clientFor(['https://cdn.example.com'])
          .delete(signer: stranger, hashes: [h]);

      expect(results.single.outcome, BlossomDeleteOutcome.refused);
      expect(results.single.reason, contains('not the owner'));
      expect(blossom.blobs, contains(h));
    });

    test(
      'a server that cannot be reached is asked once, not once per file',
      () async {
        final files = [await upload(1), await upload(2), await upload(3)];
        blossom.deadHosts.add('cdn.example.com');
        final results = await clientFor(['https://cdn.example.com'])
            .delete(signer: owner, hashes: files);

        expect(results.length, 3);
        expect(
          results.every((r) => r.outcome == BlossomDeleteOutcome.unreachable),
          true,
        );
        expect(results.first.reason, contains('unreachable'));
        expect(blossom.deleteRequests.length, 1);
        expect(blossom.blobs.length, 3);
      },
    );

    test('a request that times out is a server that did not answer', () async {
      final slow = MockClient((_) async => throw TimeoutException('slow'));
      final results = await BlossomClient([
        'https://cdn.example.com',
      ], httpClient: slow).delete(signer: owner, hashes: [hash]);

      expect(results.single.outcome, BlossomDeleteOutcome.unreachable);
      expect(results.single.reason, contains('no response'));
    });

    test(
      'a server that reads a single x tag is asked again, file by file',
      () async {
        final files = [await upload(1), await upload(2)];
        blossom.singleFileTokensOnly = true;
        final results = await clientFor(['https://cdn.example.com'])
            .delete(signer: owner, hashes: files);

        expect(
          results.every((r) => r.outcome == BlossomDeleteOutcome.deleted),
          true,
        );
        expect(blossom.blobs, isEmpty);
        final tokens = owner.authorizations('delete');
        expect(tokens.length, 3, reason: 'the shared one, then one per file');
        expect(tokens.where((t) => t.tagsNamed('x').length == 1).length, 2);
      },
    );

    test('a single file needs one authorization, and no second try', () async {
      final h = await upload(1);
      blossom.singleFileTokensOnly = true;
      await clientFor(['https://cdn.example.com'])
          .delete(signer: owner, hashes: [h]);

      expect(owner.authorizations('delete').length, 1);
      expect(blossom.deleteRequests.length, 1);
      expect(blossom.blobs, isEmpty);
    });

    test('a signer that refuses ends it before any request', () async {
      final h = await upload(1);
      owner.refuseKinds.add(NostrKinds.blossomAuth);

      await expectLater(
        clientFor(['https://cdn.example.com'])
            .delete(signer: owner, hashes: [h]),
        throwsA(isA<SignerException>()),
      );
      expect(blossom.deleteRequests, isEmpty);
      expect(blossom.blobs, contains(h));
    });

    test(
      'a refusal to sign the second authorization is that file\'s refusal',
      () async {
        final files = [await upload(1), await upload(2)];
        blossom.singleFileTokensOnly = true;
        // The shared authorization is signed; the per-file ones are not.
        final picky = _SignsOnce(owner);
        final results = await clientFor(['https://cdn.example.com'])
            .delete(signer: picky, hashes: files);

        expect(
          results.every((r) => r.outcome == BlossomDeleteOutcome.refused),
          true,
        );
        expect(results.first.reason, 'denied');
      },
    );

    test('anything that is not a file address is left out', () async {
      final h = await upload(1);
      final results = await clientFor(['https://cdn.example.com']).delete(
        signer: owner,
        hashes: ['nothex', h.toUpperCase(), '', h.substring(1)],
      );

      expect(results, isEmpty);
      expect(blossom.deleteRequests, isEmpty);
    });

    test('the same file twice is asked once', () async {
      final h = await upload(1);
      final results = await clientFor(['https://cdn.example.com'])
          .delete(signer: owner, hashes: [h, h]);

      expect(results.length, 1);
      expect(blossom.deleteRequests.length, 1);
    });

    test('a server\'s odd answer is a refusal, not a crash', () async {
      final odd = MockClient(
        (_) async => http.Response('<html>oops</html>', 502),
      );
      final results = await BlossomClient([
        'https://cdn.example.com',
      ], httpClient: odd).delete(signer: owner, hashes: [hash]);

      expect(results.single.outcome, BlossomDeleteOutcome.refused);
      expect(results.single.reason, contains('502'));
    });
  });
}

/// Signs the first Blossom authorization and refuses every later one.
class _SignsOnce extends RecordingSigner {
  _SignsOnce(RecordingSigner other) : super(other.inner);

  @override
  Future<NostrEvent> signEvent({
    required int kind,
    required List<List<String>> tags,
    required String content,
    int? createdAt,
  }) {
    if (kind == NostrKinds.blossomAuth && signedOf(kind).isNotEmpty) {
      throw const SignerException('denied');
    }
    return super.signEvent(
      kind: kind,
      tags: tags,
      content: content,
      createdAt: createdAt,
    );
  }
}
