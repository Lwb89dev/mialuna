import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mialuna/app/providers.dart';
import 'package:mialuna/core/media/blossom.dart';
import 'package:mialuna/core/net/safe_http.dart';
import 'package:mialuna/core/nostr/event.dart';
import 'package:mialuna/core/nostr/models/media_event.dart';
import 'package:mialuna/core/nostr/profile_repository.dart';
import 'package:mialuna/features/social/post_deletion.dart';
import 'package:mialuna/features/stories/stories_controller.dart';
import 'package:mialuna/features/stories/story_cleanup.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../support/fake_blossom.dart';
import '../../support/fake_relay.dart';
import '../../support/recording_signer.dart';
import '../../support/story_harness.dart';

const _day = 24 * 3600;
const ProfileMetadata? _noProfile = null;

/// Keeping a story, seeing what happened to each, and asking again.
void main() {
  late FakeRelay relay;
  late FakeBlossom blossom;
  late RecordingSigner alice;
  late StoryHarness harness;
  late Directory storage;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    SafeHttp.resolver = (_) async => [InternetAddress('93.184.216.34')];
    relay = await FakeRelay().start();
    blossom = FakeBlossom();
    alice = RecordingSigner.generate();
    harness = StoryHarness(relay);
    storage = Directory.systemTemp.createTempSync('mialuna_control_');
    addTearDown(() => SafeHttp.resolver = InternetAddress.lookup);
    addTearDown(relay.stop);
    addTearDown(() async {
      for (var i = 0; i < 5; i++) {
        try {
          if (storage.existsSync()) storage.deleteSync(recursive: true);
          return;
        } on FileSystemException {
          await Future<void>.delayed(const Duration(milliseconds: 50));
        }
      }
    });
  });

  ProviderContainer app() => harness.app(
    alice,
    dir: storage,
    overrides: [
      blossomClientProvider.overrideWithValue(
        BlossomClient(['https://cdn.example.com'], httpClient: blossom.client),
      ),
      httpClientProvider.overrideWithValue(blossom.client),
      profileProvider.overrideWith((ref, pubkey) => _noProfile),
      profileMetadataProvider.overrideWith((ref, pubkey) async => _noProfile),
    ],
  );

  Future<String> upload(int n) async {
    final result =
        await BlossomClient([
          'https://cdn.example.com',
        ], httpClient: blossom.client).upload(
          signer: alice,
          bytes: Uint8List.fromList([n, n, n, n, n]),
          mimeType: 'image/jpeg',
        );
    return result.sha256;
  }

  List<List<String>> imeta(String hash) => [
    [
      'imeta',
      'url https://cdn.example.com/$hash.jpg',
      'm image/jpeg',
      'x $hash',
    ],
  ];

  Future<MediaPost> story(
    String hash, {
    String text = 'tonight',
    bool keepTag = false,
  }) async {
    final at = harness.clock.now;
    final event = await signed(
      alice,
      kind: NostrKinds.story,
      content: text,
      createdAt: at,
      tags: [
        ...imeta(hash),
        ['L', 'mialuna.story'],
        ['l', 'story', 'mialuna.story'],
        if (keepTag) [MediaPost.keepTag, 'true'],
        ['expiration', '${at + _day}'],
      ],
    );
    relay.add(event);
    return MediaPost.tryParse(event)!;
  }

  void published(ProviderContainer c, MediaPost post) =>
      c.read(storiesProvider.notifier).addPublished(post.event);

  List<NostrEvent> requests() => [
    for (final e in relay.stored)
      if (e.kind == NostrKinds.deletion) e,
  ];

  void hoursPass(int hours) => harness.clock.advance(hours * 3600);

  StoryCleanup cleanupOf(ProviderContainer c) =>
      c.read(storyCleanupProvider.notifier);

  TrackedStory only(ProviderContainer c) =>
      c.read(storyCleanupProvider).stories.single;

  /// A story published here with a choice made for it, as the composer does.
  void chosen(ProviderContainer c, MediaPost post, {required bool keep}) {
    cleanupOf(c).track(post, keep: keep);
    published(c, post);
  }

  group('a story that is kept', () {
    test('is never taken down, not even by hand with "Delete now"', () async {
      final h = await upload(1);
      final c = app();
      chosen(c, await story(h), keep: true);

      hoursPass(25);
      await cleanupOf(c).run();
      await cleanupOf(c).run(ask: true);

      expect(requests(), isEmpty);
      expect(blossom.blobs, contains(h));
      expect(only(c).fate, StoryFate.kept);
      expect(c.read(storyCleanupProvider).due, 0);
    });

    test('chosen on another phone is known by its tag', () async {
      final h = await upload(1);
      final c = app();
      published(c, await story(h, keepTag: true));

      hoursPass(25);
      await cleanupOf(c).run();

      expect(blossom.blobs, contains(h));
      expect(only(c).fate, StoryFate.kept);
    });

    test(
      'stays kept after a restart, even if a relay hands it out first',
      () async {
        final h = await upload(1);
        final post = await story(h);
        final first = app();
        published(first, post);
        await cleanupOf(first).setKeep(post.id, true);
        await Future<void>.delayed(const Duration(milliseconds: 300));
        first.dispose();

        final second = app();
        // Noted again before the saved list has been read.
        cleanupOf(second).track(post);
        await Future<void>.delayed(const Duration(milliseconds: 300));
        hoursPass(25);
        await cleanupOf(second).run();

        expect(blossom.blobs, contains(h));
        expect(only(second).fate, StoryFate.kept);
      },
    );

    test('keeps a file it shares with a story that is deleted', () async {
      final h = await upload(1);
      final c = app();
      final kept = await story(h, text: 'kept');
      chosen(c, kept, keep: true);
      final gone = await story(h, text: 'gone');
      chosen(c, gone, keep: false);

      hoursPass(25);
      await cleanupOf(c).run();

      expect(requests().single.tagsNamed('e').single[1], gone.id);
      expect(blossom.blobs, contains(h));
    });

    test('keeps its file when a post that shares it is deleted', () async {
      final h = await upload(1);
      final c = app();
      chosen(c, await story(h), keep: true);
      final event = await signed(
        alice,
        kind: NostrKinds.picture,
        content: 'a post',
        createdAt: harness.clock.now,
        tags: imeta(h),
      );
      relay.add(event);
      hoursPass(25);

      final report = await c
          .read(postDeletionProvider)
          .delete(MediaPost.tryParse(event)!);

      expect(report.ok, true);
      expect(report.mediaKept, 1);
      expect(blossom.blobs, contains(h));
    });

    test('can be deleted later, after all', () async {
      final h = await upload(1);
      final c = app();
      final post = await story(h);
      chosen(c, post, keep: true);
      hoursPass(25);

      expect(await cleanupOf(c).deleteNow(post.id), true);

      expect(requests(), hasLength(1));
      expect(blossom.blobs, isEmpty);
      expect(only(c).fate, StoryFate.deleted);
    });
  });

  group('the choice made for a story', () {
    test('to delete it wins over a "no" in Settings', () async {
      final h = await upload(1);
      final c = app();
      await c.read(deleteExpiredStoriesProvider.notifier).set(false);
      chosen(c, await story(h), keep: false);
      expect(only(c).automatic, true);

      hoursPass(25);
      await cleanupOf(c).run();

      expect(blossom.blobs, isEmpty);
    });

    test('is not made for a story nobody chose for: Settings is', () async {
      final h = await upload(1);
      final c = app();
      await c.read(deleteExpiredStoriesProvider.notifier).set(false);
      published(c, await story(h));
      expect(only(c).automatic, false);

      hoursPass(25);
      await cleanupOf(c).run();

      expect(blossom.blobs, contains(h));
      expect(only(c).fate, StoryFate.waiting);
    });

    test('a saved "no" is read before anything is deleted', () async {
      SharedPreferences.setMockInitialValues({
        'mialuna_delete_expired_stories': false,
      });
      final h = await upload(1);
      final c = app();
      published(c, await story(h));
      hoursPass(25);

      // At once, with the preference still being read.
      await cleanupOf(c).run();

      expect(requests(), isEmpty);
      expect(blossom.blobs, contains(h));
    });
  });

  group('what happened to each story', () {
    test('is listed: live, then deleted', () async {
      final h = await upload(1);
      final c = app();
      published(c, await story(h));
      expect(only(c).fate, StoryFate.live);

      hoursPass(25);
      await cleanupOf(c).run();

      expect(only(c).fate, StoryFate.deleted);
      expect(only(c).relaysDone, true);
      expect(only(c).mediaLeft, isEmpty);
    });

    test('names the server that kept a file, and is asked again', () async {
      final h = await upload(1);
      final c = app();
      final post = await story(h);
      published(c, post);
      blossom.refuseDeleteWith = 500;
      hoursPass(25);

      await cleanupOf(c).run();
      expect(only(c).fate, StoryFate.waiting);
      expect(only(c).mediaLeft, ['cdn.example.com']);

      // By hand: no waiting for the back-off.
      blossom.refuseDeleteWith = null;
      expect(await cleanupOf(c).deleteNow(post.id), true);
      expect(only(c).fate, StoryFate.deleted);
      expect(only(c).mediaLeft, isEmpty);
      expect(blossom.blobs, isEmpty);
    });

    test('given up on, it stays listed and can still be asked', () async {
      final h = await upload(1);
      final c = app();
      final post = await story(h);
      published(c, post);
      relay.rejectWith = 'blocked: never';
      hoursPass(25);
      for (var i = 0; i < 8; i++) {
        await cleanupOf(c).run();
        hoursPass(7);
      }
      expect(only(c).fate, StoryFate.failed);

      relay.rejectWith = null;
      expect(await cleanupOf(c).deleteNow(post.id), true);
      expect(blossom.blobs, isEmpty);
    });

    test('a deleted one can be asked for again', () async {
      final h = await upload(1);
      final c = app();
      final post = await story(h);
      published(c, post);
      hoursPass(25);
      await cleanupOf(c).run();

      expect(await cleanupOf(c).deleteNow(post.id), true);

      expect(requests(), hasLength(2));
      expect(only(c).fate, StoryFate.deleted);
    });

    test('a story deleted by hand is listed as deleted', () async {
      final h = await upload(1);
      final c = app();
      final post = await story(h);
      published(c, post);

      await c.read(postDeletionProvider).delete(post);

      expect(only(c).fate, StoryFate.deleted);
    });

    test('deleted long ago, it is forgotten', () async {
      final h = await upload(1);
      final c = app();
      published(c, await story(h));
      hoursPass(25);
      await cleanupOf(c).run();

      hoursPass(31 * 24);
      cleanupOf(c).track(await story(await upload(2), text: 'new'));

      expect(c.read(storyCleanupProvider).stories, hasLength(1));
      expect(only(c).fate, StoryFate.live);
    });
  });

  group('checking the media server', () {
    test('says which still serves a file, and when it is gone', () async {
      final h = await upload(1);
      final c = app();
      final post = await story(h);
      published(c, post);

      var found = await cleanupOf(c).checkFiles(post.id);
      expect(found.online, ['cdn.example.com']);
      expect(found.unclear, false);

      hoursPass(25);
      await cleanupOf(c).run();
      found = await cleanupOf(c).checkFiles(post.id);
      expect(found.online, isEmpty);
      expect(found.unclear, false);
    });

    test('does not call a server that does not answer "gone"', () async {
      final h = await upload(1);
      final c = app();
      final post = await story(h);
      published(c, post);
      blossom.deadHosts.add('cdn.example.com');

      final found = await cleanupOf(c).checkFiles(post.id);

      expect(found.online, isEmpty);
      expect(found.unclear, true);
    });
  });
}
