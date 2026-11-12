import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mialuna/app/providers.dart';
import 'package:mialuna/core/media/blossom.dart';
import 'package:mialuna/core/nostr/event.dart';
import 'package:mialuna/core/nostr/models/media_event.dart';
import 'package:mialuna/core/nostr/nip59.dart';
import 'package:mialuna/core/nostr/profile_repository.dart';
import 'package:mialuna/core/nostr/relay_pool.dart';
import 'package:mialuna/core/nostr/signer.dart';
import 'package:mialuna/core/notify/system_notifier.dart';
import 'package:mialuna/core/storage/local_cache.dart';
import 'package:mialuna/features/private/private_posts.dart';
import 'package:mialuna/features/stories/stories_controller.dart';
import 'package:mialuna/features/stories/story_cleanup.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../support/fake_blossom.dart';
import '../../support/fake_relay.dart';
import '../../support/recording_signer.dart';
import '../../support/story_harness.dart';

/// Signs like a key but presents itself as Amber, which must be asked for
/// every signature.
class _AsAmber extends RecordingSigner {
  _AsAmber(RecordingSigner other) : super(other.inner);

  @override
  SignerType get type => SignerType.amber;
}

const _day = 24 * 3600;

/// Nobody has a profile picture to protect in these tests.
const ProfileMetadata? _noProfile = null;

void main() {
  late FakeRelay relay;
  late FakeBlossom blossom;
  late RecordingSigner alice;
  late StoryHarness harness;
  late Directory storage;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    relay = await FakeRelay().start();
    blossom = FakeBlossom();
    alice = RecordingSigner.generate();
    harness = StoryHarness(relay);
    storage = Directory.systemTemp.createTempSync('mialuna_cleanup_');
    addTearDown(relay.stop);
    addTearDown(() async {
      // A write still in flight can recreate a file while the folder is
      // being removed ("Directory not empty"): try again a few times.
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

  ProviderContainer app(Signer signer, {Directory? dir}) => harness.app(
    signer,
    dir: dir ?? storage,
    overrides: [
      blossomClientProvider.overrideWithValue(
        BlossomClient(['https://cdn.example.com'], httpClient: blossom.client),
      ),
      profileProvider.overrideWith((ref, pubkey) => _noProfile),
      profileMetadataProvider.overrideWith((ref, pubkey) async => _noProfile),
    ],
  );

  Future<String> upload(int n, {Signer? by}) async {
    final result =
        await BlossomClient([
          'https://cdn.example.com',
        ], httpClient: blossom.client).upload(
          signer: by ?? alice,
          bytes: Uint8List.fromList([n, n, n, n, n]),
          mimeType: 'image/jpeg',
        );
    return result.sha256;
  }

  /// A story by [author] showing the files [hashes], published [ago] seconds
  /// before the test clock, and handed to the relay.
  Future<MediaPost> story(
    Signer author,
    List<String> hashes, {
    int ago = 0,
    String text = 'tonight',
    bool onRelay = true,
  }) async {
    final at = harness.clock.now - ago;
    final event = await signed(
      author,
      kind: NostrKinds.picture,
      content: text,
      createdAt: at,
      tags: [
        for (final h in hashes)
          [
            'imeta',
            'url https://cdn.example.com/$h.jpg',
            'm image/jpeg',
            'x $h',
          ],
        ['L', 'mialuna.story'],
        ['l', 'story', 'mialuna.story'],
        ['expiration', '${at + _day}'],
      ],
    );
    if (onRelay) relay.add(event);
    return MediaPost.tryParse(event)!;
  }

  /// The story, as the app has it the moment it is published.
  void published(ProviderContainer c, MediaPost post) =>
      c.read(storiesProvider.notifier).addPublished(post.event);

  List<NostrEvent> requests() => [
    for (final e in relay.stored)
      if (e.kind == NostrKinds.deletion) e,
  ];

  void hoursPass(int hours) => harness.clock.advance(hours * 3600);

  group('a story is taken down once its 24 hours are over', () {
    test('from the relays and from the media server', () async {
      final h = await upload(1);
      final c = app(alice);
      final post = await story(alice, [h]);
      published(c, post);
      final cleanup = c.read(storyCleanupProvider.notifier);

      hoursPass(23);
      await cleanup.run();
      expect(requests(), isEmpty, reason: 'not yet');
      expect(blossom.blobs, contains(h));
      expect(c.read(storyCleanupProvider).due, 0);

      hoursPass(2);
      final allDone = await cleanup.run();

      expect(allDone, true);
      final request = requests().single;
      expect(request.pubkey, alice.publicKey);
      expect(request.tagsNamed('e').single[1], post.id);
      expect(request.tagsNamed('k').single[1], '${NostrKinds.picture}');
      expect(verifyEventSignature(request), true);
      expect(blossom.blobs, isEmpty);
      expect(c.read(storyCleanupProvider).due, 0);
    });

    test('with one request and one signature for all that are due', () async {
      final files = [await upload(1), await upload(2), await upload(3)];
      final c = app(alice);
      for (final h in files) {
        published(c, await story(alice, [h], text: 'story $h'));
      }

      hoursPass(25);
      await c.read(storyCleanupProvider.notifier).run();

      final request = requests().single;
      expect(request.tagsNamed('e').length, 3);
      expect(blossom.blobs, isEmpty);
      expect(alice.authorizations('delete').length, 1);
    });

    test(
      'the request goes to every relay, not only the ones written to',
      () async {
        // A relay this account reads from and never published to.
        final readOnly = await FakeRelay().start();
        addTearDown(readOnly.stop);
        final h = await upload(1);
        final c = harness.app(
          alice,
          dir: storage,
          overrides: [
            blossomClientProvider.overrideWithValue(
              BlossomClient([
                'https://cdn.example.com',
              ], httpClient: blossom.client),
            ),
            profileProvider.overrideWith((ref, pubkey) => _noProfile),
            profileMetadataProvider.overrideWith(
              (ref, pubkey) async => _noProfile,
            ),
            relayPoolProvider.overrideWith((ref) {
              final pool = RelayPool([
                RelayConfig(relay.url),
                RelayConfig(readOnly.url, write: false),
              ]);
              ref.onDispose(pool.dispose);
              return pool;
            }),
          ],
        );
        published(c, await story(alice, [h]));

        hoursPass(25);
        await c.read(storyCleanupProvider.notifier).run();

        expect(requests(), hasLength(1));
        expect(
          readOnly.stored.where((e) => e.kind == NostrKinds.deletion),
          hasLength(1),
        );
      },
    );

    test('a story that is not yours is left alone', () async {
      final bob = RecordingSigner.generate();
      final h = await upload(1, by: bob);
      final c = app(alice);
      published(c, await story(bob, [h]));

      hoursPass(25);
      await c.read(storyCleanupProvider.notifier).run();

      expect(requests(), isEmpty);
      expect(blossom.blobs, contains(h));
    });
  });

  group('when something fails', () {
    test('with no relay to answer, the files wait too', () async {
      final h = await upload(1);
      final c = app(alice);
      published(c, await story(alice, [h]));
      final cleanup = c.read(storyCleanupProvider.notifier);
      relay.rejectWith = 'blocked: no deletions here';

      hoursPass(25);
      final first = await cleanup.run();

      expect(first, false);
      expect(c.read(storyCleanupProvider).due, 1);
      expect(
        blossom.blobs,
        contains(h),
        reason: 'whether another post shows it cannot be checked with no relay',
      );

      // Too soon: it waits.
      relay.rejectWith = null;
      await cleanup.run();
      expect(requests(), isEmpty);

      harness.clock.advance(20 * 60);
      expect(await cleanup.run(), true);
      expect(requests(), hasLength(1));
      expect(blossom.blobs, isEmpty);
    });

    test('a media server that refuses is asked again later, without asking the relays twice', () async {
      final h = await upload(1);
      final c = app(alice);
      published(c, await story(alice, [h]));
      final cleanup = c.read(storyCleanupProvider.notifier);
      blossom.refuseDeleteWith = 500;

      hoursPass(25);
      expect(await cleanup.run(), false);
      expect(requests(), hasLength(1));
      expect(blossom.blobs, contains(h));

      blossom.refuseDeleteWith = null;
      harness.clock.advance(20 * 60);
      expect(await cleanup.run(), true);
      expect(requests(), hasLength(1), reason: 'the relays were asked already');
      expect(blossom.blobs, isEmpty);
    });

    test('is given up after enough failures', () async {
      final h = await upload(1);
      final c = app(alice);
      published(c, await story(alice, [h]));
      final cleanup = c.read(storyCleanupProvider.notifier);
      relay.rejectWith = 'blocked: never';

      hoursPass(25);
      for (var i = 0; i < 8; i++) {
        await cleanup.run();
        hoursPass(7);
      }

      expect(
        c.read(storyCleanupProvider).due,
        0,
        reason: 'nothing left to try',
      );
    });
  });

  group('whose signature it needs', () {
    test(
      'Amber is not asked from a timer, only when the person asks',
      () async {
        final h = await upload(1);
        final amber = _AsAmber(alice);
        final c = app(amber);
        published(c, await story(alice, [h]));
        final cleanup = c.read(storyCleanupProvider.notifier);

        hoursPass(25);
        expect(await cleanup.run(), false);

        expect(amber.signed, isEmpty, reason: 'no signature was asked for');
        expect(requests(), isEmpty);
        expect(blossom.blobs, contains(h));
        expect(c.read(storyCleanupProvider).due, 1);

        expect(await cleanup.run(ask: true), true);
        expect(requests(), hasLength(1));
        expect(blossom.blobs, isEmpty);
      },
    );

    test('a person who turned it off keeps their stories, but can still press the button', () async {
      final h = await upload(1);
      final c = app(alice);
      published(c, await story(alice, [h]));
      await c.read(deleteExpiredStoriesProvider.notifier).set(false);
      final cleanup = c.read(storyCleanupProvider.notifier);

      hoursPass(25);
      await cleanup.run();
      expect(requests(), isEmpty);
      expect(blossom.blobs, contains(h));

      await cleanup.run(ask: true);
      expect(requests(), hasLength(1));
      expect(blossom.blobs, isEmpty);
    });

    test('coming back to the app runs it', () async {
      final h = await upload(1);
      final c = app(alice);
      published(c, await story(alice, [h]));
      c.read(storyCleanupProvider);
      hoursPass(25);

      c.read(appForegroundProvider.notifier).state = false;
      c.read(appForegroundProvider.notifier).state = true;

      await eventually(() => requests().isNotEmpty);
      await eventually(() => blossom.blobs.isEmpty);
    });
  });

  group('a close-friends story', () {
    List<List<String>> privateTags(String hash, int at) => [
      [
        'imeta',
        'url https://cdn.example.com/$hash',
        'm image/jpeg',
        'x $hash',
        'decryption-key ${'a' * 64}',
        'decryption-nonce ${'b' * 24}',
      ],
      ['audience', 'close-friends'],
      ['p', RecordingSigner.generate().publicKey!],
      ['L', 'mialuna.story'],
      ['l', 'story', 'mialuna.story'],
      ['text', 'a secret caption'],
      ['expiration', '${at + _day}'],
    ];

    test('has its file taken down with the one-off key, with no signature and nothing to the relays', () async {
      final oneOffKey = NsecSigner.generatePrivateKey();
      final h = await upload(1, by: NsecSigner.fromNsec(oneOffKey));
      final amber = _AsAmber(alice);
      final c = app(amber);
      await c.read(uploadKeysProvider).remember([h], oneOffKey);
      // The private store hands it over when the story is published.
      final rumor = Rumor.create(
        pubkey: alice.publicKey!,
        kind: NostrKinds.picture,
        createdAt: harness.clock.now,
        content: 'a secret caption',
        tags: privateTags(h, harness.clock.now),
      );
      expect(c.read(privatePostsProvider.notifier).ingest(rumor), true);

      hoursPass(25);
      expect(await c.read(storyCleanupProvider.notifier).run(), true);

      expect(blossom.blobs, isEmpty);
      expect(amber.signed, isEmpty);
      expect(requests(), isEmpty);
      expect(relay.stored.where((e) => e.kind == NostrKinds.giftWrap), isEmpty);
    });

    test('is remembered without what was said in it', () async {
      final h = await upload(1);
      final c = app(alice);
      final at = harness.clock.now;
      final event = NostrEvent(
        id: 'c' * 64,
        pubkey: alice.publicKey!,
        createdAt: at,
        kind: NostrKinds.picture,
        tags: privateTags(h, at),
        content: 'a secret caption',
        sig: '',
      );
      c
          .read(storyCleanupProvider.notifier)
          .track(MediaPost.tryParse(event, allowPrivate: true)!);
      await Future<void>.delayed(const Duration(milliseconds: 300));

      final file = File(
        '${storage.path}/story_cleanup_${alice.publicKey}.json',
      );
      final saved = file.readAsStringSync();

      expect(saved, contains(h));
      expect(saved, isNot(contains('secret caption')));
      expect(saved, isNot(contains('decryption')));
      expect(saved, isNot(contains('a' * 64)));
    });
  });

  group('files shared with another story', () {
    test(
      'stay while a live story shows them, and go with the last one',
      () async {
        final shared = await upload(1);
        final c = app(alice);
        final old = await story(alice, [shared], ago: 20 * 3600, text: 'old');
        published(c, old);
        harness.clock.advance(5 * 3600); // the old one is 25 hours old
        final fresh = await story(alice, [shared], text: 'fresh');
        published(c, fresh);
        final cleanup = c.read(storyCleanupProvider.notifier);

        await cleanup.run();
        expect(requests().single.tagsNamed('e').single[1], old.id);
        expect(
          blossom.blobs,
          contains(shared),
          reason: 'a live story shows it',
        );

        hoursPass(25);
        await cleanup.run();

        expect(requests(), hasLength(2));
        expect(
          blossom.blobs,
          isEmpty,
          reason: 'the expired story a relay still serves does not keep it',
        );
      },
    );
  });

  group('what it remembers', () {
    test('survives a restart', () async {
      final h = await upload(1);
      final first = app(alice);
      published(first, await story(alice, [h]));
      await Future<void>.delayed(const Duration(milliseconds: 300));
      first.dispose();

      hoursPass(25);
      final second = app(alice);
      final cleanup = second.read(storyCleanupProvider.notifier);
      await eventually(() => second.read(storyCleanupProvider).due == 1);

      expect(await cleanup.run(), true);
      expect(blossom.blobs, isEmpty);
    });

    test('goes when the account signs out', () {
      expect(
        LocalCache.accountFiles(alice.publicKey!),
        contains('story_cleanup_${alice.publicKey}.json'),
      );
    });

    test('is kept apart for each account', () async {
      final h = await upload(1);
      final c = app(alice);
      published(c, await story(alice, [h]));
      await Future<void>.delayed(const Duration(milliseconds: 300));
      c.dispose();

      final bob = RecordingSigner.generate();
      hoursPass(25);
      final other = app(bob);
      await Future<void>.delayed(const Duration(milliseconds: 300));

      expect(other.read(storyCleanupProvider).due, 0);
      await other.read(storyCleanupProvider.notifier).run();
      expect(blossom.blobs, contains(h));
    });
  });
}
