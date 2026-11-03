import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mialuna/app/providers.dart';
import 'package:mialuna/core/media/blossom.dart';
import 'package:mialuna/core/nostr/event.dart';
import 'package:mialuna/core/nostr/models/media_event.dart';
import 'package:mialuna/core/nostr/profile_repository.dart';
import 'package:mialuna/core/nostr/signer.dart';
import 'package:mialuna/features/social/deleted_posts.dart';
import 'package:mialuna/features/social/moderation_controller.dart';
import 'package:mialuna/features/social/post_deletion.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../support/fake_blossom.dart';
import '../../support/fake_relay.dart';
import '../../support/recording_signer.dart';
import '../../support/story_harness.dart';

/// A signer whose app crashes while signing: not a refusal, an accident.
class _Crashing extends RecordingSigner {
  final Set<int> crashKinds;
  _Crashing(RecordingSigner other, this.crashKinds) : super(other.inner);

  @override
  Future<NostrEvent> signEvent({
    required int kind,
    required List<List<String>> tags,
    required String content,
    int? createdAt,
  }) {
    if (crashKinds.contains(kind)) throw StateError('boom');
    return super.signEvent(
      kind: kind,
      tags: tags,
      content: content,
      createdAt: createdAt,
    );
  }
}

void main() {
  late FakeRelay relay;
  late FakeBlossom blossom;
  late RecordingSigner alice;
  late StoryHarness harness;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    relay = await FakeRelay().start();
    blossom = FakeBlossom();
    alice = RecordingSigner.generate();
    harness = StoryHarness(relay);
    addTearDown(relay.stop);
  });

  ProviderContainer app(
    Signer signer, {
    ProfileMetadata? profile,
    Directory? dir,
  }) {
    return harness.app(
      signer,
      dir: dir,
      overrides: [
        blossomClientProvider.overrideWithValue(
          BlossomClient([
            'https://cdn.example.com',
          ], httpClient: blossom.client),
        ),
        profileProvider.overrideWith((ref, pubkey) => profile),
        profileMetadataProvider.overrideWith((ref, pubkey) async => profile),
      ],
    );
  }

  /// A file on the media server, uploaded by [by].
  Future<String> upload(int n, {Signer? by}) async {
    final result =
        await BlossomClient([
          'https://cdn.example.com',
        ], httpClient: blossom.client).upload(
          signer: by ?? alice,
          bytes: Uint8List.fromList([n, n, n, n]),
          mimeType: 'image/jpeg',
        );
    return result.sha256;
  }

  /// A post by [author] showing [hashes], published on the relay.
  Future<MediaPost> post(
    Signer author,
    List<String> hashes, {
    int kind = NostrKinds.picture,
    List<List<String>> extra = const [],
    List<String>? urls,
    String caption = 'a post',
    String mime = 'image/jpeg',
  }) async {
    final event = await signed(
      author,
      kind: kind,
      content: caption,
      tags: [
        for (var i = 0; i < hashes.length; i++)
          [
            'imeta',
            'url ${urls?[i] ?? 'https://cdn.example.com/${hashes[i]}.jpg'}',
            'm $mime',
            'x ${hashes[i]}',
          ],
        ...extra,
      ],
    );
    relay.add(event);
    return MediaPost.tryParse(event)!;
  }

  List<NostrEvent> requests() => [
    for (final e in relay.stored)
      if (e.kind == NostrKinds.deletion) e,
  ];

  test(
    'asks the relays to delete the post and the media server to delete its file',
    () async {
      final h = await upload(1);
      final p = await post(alice, [h]);
      final c = app(alice);

      final report = await c.read(postDeletionProvider).delete(p);

      expect(report.ok, true);
      expect(report.complete, true);
      final request = requests().single;
      expect(request.pubkey, alice.publicKey);
      expect(request.tagsNamed('e').single[1], p.id);
      expect(request.tagsNamed('k').single[1], '${NostrKinds.picture}');
      expect(verifyEventSignature(request), true);
      expect(blossom.blobs, isEmpty);
      expect(blossom.deleteRequests, ['cdn.example.com/$h']);
      expect(c.read(deletedPostsProvider), contains(p.id));
    },
  );

  test('a video\'s cover image goes with it', () async {
    final video = await upload(1);
    final cover = await upload(2);
    final event = await signed(
      alice,
      kind: NostrKinds.video,
      tags: [
        [
          'imeta',
          'url https://cdn.example.com/$video.mp4',
          'm video/mp4',
          'x $video',
          'image https://cdn.example.com/$cover.jpg',
        ],
      ],
    );
    final c = app(alice);

    final videoPost = MediaPost.tryParse(event)!;
    final report = await c.read(postDeletionProvider).delete(videoPost);

    expect(report.complete, true);
    expect(blossom.blobs, isEmpty);
    expect(blossom.deleteRequests.toSet(), {
      'cdn.example.com/$video',
      'cdn.example.com/$cover',
    });
  });

  test('a carousel is one signature for all its files', () async {
    final files = [await upload(1), await upload(2), await upload(3)];
    final p = await post(alice, files);
    final c = app(alice);

    await c.read(postDeletionProvider).delete(p);

    expect(blossom.blobs, isEmpty);
    final tokens = alice.authorizations('delete');
    expect(tokens.length, 1);
    expect(tokens.single.tagsNamed('x').length, 3);
  });

  test('nothing is touched when no relay takes the request', () async {
    final h = await upload(1);
    final p = await post(alice, [h]);
    relay.rejectWith = 'blocked: no deletions here';
    final c = app(alice);

    final report = await c.read(postDeletionProvider).delete(p);

    expect(report.failure, DeletionFailure.noRelayAccepted);
    expect(report.detail, contains('blocked'));
    expect(blossom.blobs, contains(h), reason: 'the post is still online');
    expect(blossom.deleteRequests, isEmpty);
    expect(c.read(deletedPostsProvider), isEmpty);
  });

  test(
    'the post is gone from here even when the media server says no',
    () async {
      final h = await upload(1);
      final p = await post(alice, [h]);
      blossom.refuseDeleteWith = 403;
      final c = app(alice);

      final report = await c.read(postDeletionProvider).delete(p);

      expect(report.ok, true);
      expect(report.complete, false);
      expect(report.mediaLeft, ['cdn.example.com']);
      expect(c.read(deletedPostsProvider), contains(p.id));
      expect(blossom.blobs, contains(h));
    },
  );

  test(
    'a file that is not on a Blossom address is reported, not touched',
    () async {
      final p = await post(
        alice,
        ['0' * 64],
        urls: ['https://photos.example.org/holiday.jpg'],
      );
      final c = app(alice);

      final report = await c.read(postDeletionProvider).delete(p);

      expect(report.ok, true);
      expect(report.mediaLeft, ['photos.example.org']);
      expect(requests(), hasLength(1));
      expect(c.read(deletedPostsProvider), contains(p.id));
    },
  );

  test('a file another post still shows is left alone', () async {
    final shared = await upload(1);
    final first = await post(alice, [shared], caption: 'first');
    final second = await post(alice, [shared], caption: 'second');
    final c = app(alice);

    final report = await c.read(postDeletionProvider).delete(first);

    expect(report.complete, true);
    expect(report.mediaKept, 1);
    expect(blossom.blobs, contains(shared));
    expect(blossom.deleteRequests, isEmpty);

    // Once the other one goes too, nothing uses it any more.
    final last = await c.read(postDeletionProvider).delete(second);
    expect(last.mediaKept, 0);
    expect(blossom.blobs, isEmpty);
  });

  test('the profile picture counts as a use of its file', () async {
    final h = await upload(1);
    final p = await post(alice, [h]);
    final c = app(
      alice,
      profile: ProfileMetadata(
        pubkey: alice.publicKey!,
        picture: 'https://cdn.example.com/$h.jpg',
        createdAt: 1,
      ),
    );

    final report = await c.read(postDeletionProvider).delete(p);

    expect(report.ok, true);
    expect(report.mediaKept, 1);
    expect(blossom.blobs, contains(h));
  });

  test('only the author can delete a post', () async {
    final bob = RecordingSigner.generate();
    final h = await upload(1, by: bob);
    final p = await post(bob, [h]);
    final c = app(alice);

    final report = await c.read(postDeletionProvider).delete(p);

    expect(report.failure, DeletionFailure.notAllowed);
    expect(requests(), isEmpty);
    expect(blossom.blobs, contains(h));
    expect(c.read(deletedPostsProvider), isEmpty);
  });

  test('a guest cannot delete anything', () async {
    final h = await upload(1);
    final p = await post(alice, [h]);
    final c = app(GuestSigner());

    final report = await c.read(postDeletionProvider).delete(p);

    expect(report.failure, DeletionFailure.notAllowed);
    expect(requests(), isEmpty);
  });

  test('a signer that refuses stops it with nothing sent', () async {
    final h = await upload(1);
    final p = await post(alice, [h]);
    alice.refuseKinds.add(NostrKinds.deletion);
    final c = app(alice);

    final report = await c.read(postDeletionProvider).delete(p);

    expect(report.failure, DeletionFailure.signerRefused);
    expect(report.detail, 'denied');
    expect(requests(), isEmpty);
    expect(blossom.blobs, contains(h));
    expect(c.read(deletedPostsProvider), isEmpty);
  });

  test(
    'a signer that refuses the media authorization leaves the files and says so',
    () async {
      final h = await upload(1);
      final p = await post(alice, [h]);
      alice.refuseKinds.add(NostrKinds.blossomAuth);
      final c = app(alice);

      final report = await c.read(postDeletionProvider).delete(p);

      expect(report.ok, true, reason: 'the post itself is deleted');
      expect(report.mediaError, 'denied');
      expect(report.mediaLeft, ['cdn.example.com']);
      expect(blossom.blobs, contains(h));
      expect(c.read(deletedPostsProvider), contains(p.id));
    },
  );

  test(
    'an accident in the signer is reported, with nothing half done',
    () async {
      final h = await upload(1);
      final p = await post(alice, [h]);
      final c = app(_Crashing(alice, {NostrKinds.deletion}));

      final report = await c.read(postDeletionProvider).delete(p);

      expect(report.failure, DeletionFailure.failed);
      expect(report.detail, contains('boom'));
      expect(requests(), isEmpty);
      expect(blossom.blobs, contains(h));
      expect(c.read(deletedPostsProvider), isEmpty);
    },
  );

  test(
    'an accident while taking the files down does not undo the deletion',
    () async {
      final h = await upload(1);
      final p = await post(alice, [h]);
      final c = app(_Crashing(alice, {NostrKinds.blossomAuth}));

      final report = await c.read(postDeletionProvider).delete(p);

      expect(report.ok, true, reason: 'the request was accepted');
      expect(report.mediaError, contains('boom'));
      expect(report.mediaLeft, ['cdn.example.com']);
      expect(c.read(deletedPostsProvider), contains(p.id));
      expect(blossom.blobs, contains(h));
    },
  );

  test('an addressable video names its address as well', () async {
    final p = await post(
      alice,
      [await upload(1)],
      kind: NostrKinds.addressableVideo,
      mime: 'video/mp4',
      extra: [
        ['d', 'my-clip'],
      ],
    );
    final c = app(alice);

    await c.read(postDeletionProvider).delete(p);

    final request = requests().single;
    expect(
      request.tagsNamed('a').single[1],
      '34235:${alice.publicKey}:my-clip',
    );
    expect(request.tagsNamed('e').single[1], p.id);
  });

  test('a post that was saved is no longer saved', () async {
    final p = await post(alice, [await upload(1)]);
    SharedPreferences.setMockInitialValues({
      'mialuna_bookmarks': [p.id],
    });
    final c = app(alice);
    c.listen(bookmarksProvider, (_, _) {});
    await eventually(() => c.read(bookmarksProvider).contains(p.id));

    await c.read(postDeletionProvider).delete(p);

    await eventually(() => !c.read(bookmarksProvider).contains(p.id));
  });

  test('asking twice is harmless', () async {
    final h = await upload(1);
    final p = await post(alice, [h]);
    final c = app(alice);

    await c.read(postDeletionProvider).delete(p);
    final again = await c.read(postDeletionProvider).delete(p);

    expect(again.ok, true);
    expect(again.complete, true, reason: 'a file that is gone is done');
    expect(requests(), hasLength(2));
  });

  test('what was deleted is remembered after a restart', () async {
    final storage = Directory.systemTemp.createTempSync('mialuna_deleted_');
    addTearDown(() => storage.deleteSync(recursive: true));
    final p = await post(alice, [await upload(1)]);
    final c = app(alice, dir: storage);
    await c.read(postDeletionProvider).delete(p);
    await eventually(() => c.read(deletedPostsProvider).contains(p.id));
    await Future<void>.delayed(const Duration(milliseconds: 200));

    // A new run of the app on the same storage.
    final reopened = app(alice, dir: storage);
    reopened.listen(deletedPostsProvider, (_, _) {});

    await eventually(() => reopened.read(deletedPostsProvider).contains(p.id));
  });
}
