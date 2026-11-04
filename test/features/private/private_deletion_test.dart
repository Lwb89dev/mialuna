import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:mialuna/app/providers.dart';
import 'package:mialuna/core/auth/auth_controller.dart';
import 'package:mialuna/core/media/blossom.dart';
import 'package:mialuna/core/media/private_media.dart';
import 'package:mialuna/core/nostr/event.dart';
import 'package:mialuna/core/nostr/nip59.dart';
import 'package:mialuna/core/nostr/relay_pool.dart';
import 'package:mialuna/core/nostr/signer.dart';
import 'package:mialuna/core/storage/local_cache.dart';
import 'package:mialuna/features/create/create_controller.dart';
import 'package:mialuna/features/feed/feed_controller.dart';
import 'package:mialuna/features/messages/dm_controller.dart';
import 'package:mialuna/features/private/close_friends.dart';
import 'package:mialuna/features/private/private_posts.dart';
import 'package:mialuna/features/social/deleted_posts.dart';
import 'package:mialuna/features/social/post_deletion.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../support/fake_blossom.dart';
import '../../support/fake_relay.dart';

class _FixedAuth extends AuthController {
  final Signer signer;
  _FixedAuth(this.signer);
  @override
  AuthState build() => AuthState(signer);
}

NsecSigner newSigner() => NsecSigner.fromNsec(NsecSigner.generatePrivateKey());

Uint8List jpegFixture() {
  final image = img.Image(width: 40, height: 30);
  img.fill(image, color: img.ColorRgb8(220, 90, 50));
  return Uint8List.fromList(img.encodeJpg(image));
}

void main() {
  late FakeRelay relay;
  late FakeBlossom blossom;
  late NsecSigner alice; // author
  late NsecSigner bob; // close friend with an inbox
  late NsecSigner carol; // somebody else
  late NsecSigner dave; // close friend WITHOUT an inbox

  ProviderContainer app(Signer signer, {Directory? dir}) {
    final cacheDir = dir ?? Directory.systemTemp.createTempSync('mialuna_pd_');
    final c = ProviderContainer(
      overrides: [
        authProvider.overrideWith(() => _FixedAuth(signer)),
        indexerRelaysProvider.overrideWithValue(const []),
        localCacheProvider.overrideWithValue(LocalCache(directory: cacheDir)),
        httpClientProvider.overrideWithValue(blossom.client),
        privateMediaProvider.overrideWithValue(
          PrivateMediaService(blossom.client, directory: cacheDir),
        ),
        relayPoolProvider.overrideWith((ref) {
          final pool = RelayPool([RelayConfig(relay.url)]);
          pool.authSigner = (url, challenge) => signer.signEvent(
            kind: NostrKinds.clientAuth,
            tags: [
              ['relay', url],
              ['challenge', challenge],
            ],
            content: '',
          );
          ref.onDispose(pool.dispose);
          return pool;
        }),
      ],
    );
    addTearDown(c.dispose);
    return c;
  }

  Future<void> online(ProviderContainer c) async {
    c.listen(dmProvider, (_, _) {});
    c.listen(privatePostsProvider, (_, _) {});
    await eventually(() => c.read(dmProvider).inboxConfigured == true);
  }

  /// Alice posts a close-friends photo to Bob and Dave; Bob has it.
  Future<({ProviderContainer alice, ProviderContainer bob})> posted() async {
    final a = app(alice);
    await online(a);
    await a.read(closeFriendsProvider.notifier).add([
      bob.publicKey,
      dave.publicKey,
    ]);
    final b = app(bob);
    await online(b);
    final composer = a.read(composerProvider.notifier);
    final bytes = jpegFixture();
    composer.setMode(ComposerMode.photo);
    composer.addPicked(
      PickedMedia(
        file: XFile.fromData(bytes, name: 'a.jpg'),
        bytes: bytes,
        mimeType: 'image/jpeg',
      ),
    );
    composer.setCaption('solo per voi');
    composer.setAudience(Audience.closeFriends);
    expect(
      await composer.publish(),
      true,
      reason: a.read(composerProvider).error,
    );
    await eventually(() => b.read(privatePostsProvider).posts.isNotEmpty);
    return (alice: a, bob: b);
  }

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    BlossomClient.forgetServerBehaviour();
    relay = await FakeRelay(authKinds: {1059}).start();
    blossom = FakeBlossom();
    alice = newSigner();
    bob = newSigner();
    carol = newSigner();
    dave = newSigner();
    for (final s in [alice, bob, carol]) {
      relay.add(
        await signed(
          s,
          kind: NostrKinds.dmRelayList,
          tags: [
            ['relay', relay.url],
          ],
        ),
      );
    }
  });

  tearDown(() => relay.stop());

  group('deleting a close-friends post', () {
    test('tells the friends, and takes the encrypted file down with the key that put it there', () async {
      final both = await posted();
      final a = both.alice;
      final b = both.bob;
      final post = a.read(privatePostsProvider).posts.single;
      final file = blossom.blobs.keys.single;
      bool inHome() {
        final home = b.read(feedProvider(FeedMode.following));
        return home.posts.any((p) => p.id == post.id);
      }

      b.listen(feedProvider(FeedMode.following), (_, _) {});
      await eventually(inHome, reason: 'the friend has it in Home');
      expect(await a.read(uploadKeysProvider).keysFor([file]), hasLength(1));

      final report = await a.read(postDeletionProvider).delete(post);

      expect(report.ok, true, reason: report.detail);
      expect(report.friendsAsked, 2);
      expect(report.friendsReached, 1, reason: 'Dave has no inbox');
      expect(report.complete, false);
      expect(report.mediaLeft, isEmpty);

      // Gone from the author's phone, and from the friend's: store and Home.
      expect(a.read(privatePostsProvider).posts, isEmpty);
      expect(a.read(deletedPostsProvider), contains(post.id));
      await eventually(() => b.read(privatePostsProvider).posts.isEmpty);
      expect(b.read(deletedPostsProvider), contains(post.id));
      await eventually(() => !inHome(), reason: 'the post stayed in Home');

      // The file is gone, asked for by the one-time key, not by Alice.
      expect(blossom.blobs, isEmpty);
      final askedBy = blossom.deleteTokens.map((t) => t.pubkey).toSet();
      expect(askedBy, blossom.uploaderPubkeys.toSet());
      expect(askedBy, hasLength(1));
      expect(askedBy, isNot(contains(alice.publicKey)));
      expect(await a.read(uploadKeysProvider).keysFor([file]), isEmpty);

      // No relay was asked in the open: nothing readable names the post.
      expect(relay.stored.where((e) => e.kind == NostrKinds.deletion), isEmpty);
      final dump = jsonEncode(relay.stored.map((e) => e.toJson()).toList());
      expect(dump, isNot(contains(post.id)));
    });

    test(
      'a file whose key was not kept stays, and the report says where',
      () async {
        final both = await posted();
        final a = both.alice;
        final post = a.read(privatePostsProvider).posts.single;
        // An older post: the key was not kept then.
        await a.read(uploadKeysProvider).forget(blossom.blobs.keys);

        final report = await a.read(postDeletionProvider).delete(post);

        expect(report.ok, true);
        expect(report.mediaLeft, isNotEmpty);
        expect(blossom.blobs, isNotEmpty);
        expect(blossom.deleteRequests, isEmpty);
        expect(a.read(privatePostsProvider).posts, isEmpty);
      },
    );

    test(
      'keeps the key when the server refuses, so it can be asked again',
      () async {
        final both = await posted();
        final a = both.alice;
        final post = a.read(privatePostsProvider).posts.single;
        final file = blossom.blobs.keys.single;
        blossom.refuseDeleteWith = 500;

        final report = await a.read(postDeletionProvider).delete(post);

        expect(report.mediaLeft, isNotEmpty);
        expect(await a.read(uploadKeysProvider).keysFor([file]), hasLength(1));
      },
    );

    test('only the author of a post can delete it', () async {
      final both = await posted();
      final b = both.bob;
      final post = b.read(privatePostsProvider).posts.single;

      final report = await b.read(postDeletionProvider).delete(post);

      expect(report.failure, DeletionFailure.notAllowed);
      expect(b.read(privatePostsProvider).posts, hasLength(1));
      expect(blossom.blobs, isNotEmpty);
    });
  });

  group('the notice that a post was taken back', () {
    Rumor privatePost(Signer author, {String caption = 'for you'}) =>
        Rumor.create(
          pubkey: author.publicKey!,
          kind: NostrKinds.picture,
          createdAt: 1700000000,
          content: caption,
          tags: [
            [
              'imeta',
              'url https://cdn.example.com/${'a' * 64}.jpg',
              'm image/jpeg',
            ],
            ['audience', 'close-friends'],
            ['p', bob.publicKey],
          ],
        );

    Rumor notice(Signer by, String target) => Rumor.create(
      pubkey: by.publicKey!,
      kind: NostrKinds.deletion,
      tags: [
        ['e', target],
        ['k', '${NostrKinds.picture}'],
      ],
      content: '',
    );

    test('removes the post and what it gathered', () async {
      final b = app(bob);
      final store = b.read(privatePostsProvider.notifier);
      final post = privatePost(alice);
      final like = Rumor.create(
        pubkey: bob.publicKey,
        kind: NostrKinds.reaction,
        tags: [
          ['e', post.id],
          ['p', alice.publicKey],
        ],
        content: '+',
      );
      expect(store.ingest(post), true);
      expect(store.ingest(like), true);
      expect(b.read(privatePostsProvider).posts, hasLength(1));

      expect(store.ingest(notice(alice, post.id)), true);

      expect(b.read(privatePostsProvider).posts, isEmpty);
      expect(b.read(privatePostsProvider).of(post.id).likers, isEmpty);
      expect(b.read(deletedPostsProvider), contains(post.id));
    });

    test('that arrives before the post keeps the post out', () async {
      final b = app(bob);
      final store = b.read(privatePostsProvider.notifier);
      final post = privatePost(alice);

      expect(store.ingest(notice(alice, post.id)), true);
      expect(store.ingest(post), true, reason: 'handled, not an unknown kind');

      expect(b.read(privatePostsProvider).posts, isEmpty);
    });

    test('from somebody else does nothing to the post', () async {
      final b = app(bob);
      final store = b.read(privatePostsProvider.notifier);
      final post = privatePost(alice);
      store.ingest(post);

      store.ingest(notice(carol, post.id));

      expect(b.read(privatePostsProvider).posts, hasLength(1));
      expect(b.read(deletedPostsProvider), isEmpty);
    });

    test('from somebody else cannot keep the real post out either', () async {
      final b = app(bob);
      final store = b.read(privatePostsProvider.notifier);
      final post = privatePost(alice);

      store.ingest(notice(carol, post.id)); // before the post, from a stranger
      store.ingest(post);

      expect(b.read(privatePostsProvider).posts, hasLength(1));
    });

    test('that names nothing is not ours to keep', () async {
      final b = app(bob);
      final store = b.read(privatePostsProvider.notifier);
      final empty = Rumor.create(
        pubkey: alice.publicKey,
        kind: NostrKinds.deletion,
        tags: const [],
        content: '',
      );

      expect(store.ingest(empty), false);
    });

    test('is remembered after a restart, whichever comes first', () async {
      final dir = Directory.systemTemp.createTempSync('mialuna_pd_restart_');
      addTearDown(() => dir.deleteSync(recursive: true));
      final first = app(bob, dir: dir);
      final post = privatePost(alice);
      first.read(privatePostsProvider.notifier).ingest(notice(alice, post.id));
      final saved = File('${dir.path}/private_posts_${bob.publicKey}.json');
      await eventually(() => saved.existsSync(), reason: 'never saved');
      first.dispose();

      final second = app(bob, dir: dir);
      second.read(privatePostsProvider.notifier).ingest(post);
      await Future<void>.delayed(const Duration(milliseconds: 300));

      expect(second.read(privatePostsProvider).posts, isEmpty);
    });
  });
}
