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
import 'package:mialuna/core/media/media_sanitizer.dart';
import 'package:mialuna/core/media/private_media.dart';
import 'package:mialuna/core/nostr/event.dart';
import 'package:mialuna/core/nostr/models/media_event.dart';
import 'package:mialuna/core/nostr/relay_pool.dart';
import 'package:mialuna/core/nostr/signer.dart';
import 'package:mialuna/core/storage/local_cache.dart';
import 'package:mialuna/features/comments/comment_likes_controller.dart';
import 'package:mialuna/features/create/create_controller.dart';
import 'package:mialuna/features/feed/feed_controller.dart';
import 'package:mialuna/features/messages/dm_controller.dart';
import 'package:mialuna/features/private/close_friends.dart';
import 'package:mialuna/features/private/private_posts.dart';
import 'package:mialuna/features/social/interactions_controller.dart';
import 'package:mialuna/features/stories/stories_controller.dart';
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
  image.exif.gpsIfd.gpsLatitude = 41.89; // must be stripped before encryption
  image.exif.gpsIfd.gpsLatitudeRef = 'N';
  return Uint8List.fromList(img.encodeJpg(image));
}

void main() {
  late FakeRelay relay;
  late FakeBlossom blossom;
  late NsecSigner alice; // author
  late NsecSigner bob; // close friend with an inbox
  late NsecSigner carol; // NOT a close friend, has an inbox
  late NsecSigner dave; // close friend WITHOUT an inbox

  ProviderContainer app(Signer signer, {Directory? dir, bool offline = false}) {
    final cacheDir = dir ?? Directory.systemTemp.createTempSync('mialuna_pp_');
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
          final pool = RelayPool(offline ? const [] : [RelayConfig(relay.url)]);
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

  Future<ProviderContainer> aliceWithFriends() async {
    final a = app(alice);
    await online(a);
    await a.read(closeFriendsProvider.notifier).add([
      bob.publicKey,
      dave.publicKey,
    ]);
    return a;
  }

  void compose(
    ProviderContainer a, {
    String caption = 'solo per voi',
    ComposerMode mode = ComposerMode.photo,
  }) {
    final composer = a.read(composerProvider.notifier);
    composer.setMode(mode);
    final bytes = jpegFixture();
    composer.addPicked(
      PickedMedia(
        file: XFile.fromData(bytes, name: 'a.jpg'),
        bytes: bytes,
        mimeType: 'image/jpeg',
      ),
    );
    composer.setCaption(caption);
    composer.setAudience(Audience.closeFriends);
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

  test('a close-friends photo reaches only the friends, and the server holds '
      'nothing but ciphertext', () async {
    final a = await aliceWithFriends();
    final b = app(bob);
    final c = app(carol);
    await online(b);
    await online(c);

    compose(a);
    final ok = await a.read(composerProvider.notifier).publish();
    expect(ok, true, reason: a.read(composerProvider).error);
    expect(a.read(composerProvider).notice, contains('Sent to 1 friend'));
    expect(a.read(composerProvider).notice, contains('1 did not receive'));

    // Bob got it, with the author and the injected audience.
    await eventually(
      () => b.read(privatePostsProvider).posts.isNotEmpty,
      reason: 'the friend never received the post',
    );
    final post = b.read(privatePostsProvider).posts.single;
    expect(post.isPrivate, true);
    expect(post.author, alice.publicKey);
    expect(post.caption, 'solo per voi');
    expect(post.recipients.toSet(), {bob.publicKey, dave.publicKey});
    expect(
      post.hashtags,
      isNot(contains('mialuna')),
    ); // private: not discoverable

    // The picture decrypts to exactly the cleaned photo.
    final item = post.media.single;
    expect(item.isEncrypted, true);
    final plain = await b.read(privateMediaProvider).imageBytes(item);
    final cleaned = MediaSanitizer.sanitize(jpegFixture()).bytes;
    expect(plain, cleaned);
    expect(MediaSanitizer.inspect(plain), isEmpty); // no GPS inside either
    expect(img.decodeJpg(plain)!.width, 40);

    // What the Blossom server stores is opaque, and not tied to Alice.
    expect(blossom.blobs, isNotEmpty);
    for (final blob in blossom.blobs.values) {
      expect(MediaSanitizer.detect(blob), MediaFormat.unknown);
    }
    expect(blossom.uploadContentTypes.toSet(), {'application/octet-stream'});
    expect(blossom.uploaderPubkeys, isNotEmpty);
    expect(blossom.uploaderPubkeys, everyElement(isNot(alice.publicKey)));
    expect(
      item.sha256,
      blossom.blobs.keys.single,
    ); // x = hash of the ciphertext

    // The relay saw only gift wraps from throw-away keys.
    final contentKinds = relay.stored
        .where((e) => e.kind != NostrKinds.dmRelayList)
        .map((e) => e.kind)
        .toSet();
    expect(
      contentKinds.difference({NostrKinds.giftWrap, NostrKinds.followSet}),
      isEmpty,
    );
    final dump = jsonEncode(relay.stored.map((e) => e.toJson()).toList());
    expect(dump, isNot(contains('solo per voi')));
    expect(dump, isNot(contains(blossom.blobs.keys.single)));
    for (final w in relay.stored.where((e) => e.kind == NostrKinds.giftWrap)) {
      expect(w.pubkey, isNot(anyOf(alice.publicKey, bob.publicKey)));
    }

    // Carol, who is not a friend, got nothing.
    await Future<void>.delayed(const Duration(seconds: 1));
    expect(c.read(privatePostsProvider).posts, isEmpty);

    // Alice sees her own post at once, and Bob has it in Home though he
    // does not follow her.
    expect(a.read(privatePostsProvider).posts.single.id, post.id);
    b.listen(feedProvider(FeedMode.following), (_, _) {});
    await eventually(
      () => b
          .read(feedProvider(FeedMode.following))
          .posts
          .any((p) => p.id == post.id),
      reason: 'the private post is missing from Home',
    );
  });

  test(
    'likes and replies on a private post stay between friend and author',
    () async {
      final a = await aliceWithFriends();
      final b = app(bob);
      await online(b);
      compose(a);
      expect(await a.read(composerProvider.notifier).publish(), true);
      await eventually(() => b.read(privatePostsProvider).posts.isNotEmpty);
      final post = b.read(privatePostsProvider).posts.single;

      b.listen(interactionsProvider(post), (_, _) {});
      expect(
        await b.read(interactionsProvider(post).notifier).like(post),
        true,
      );
      final reply = await b
          .read(interactionsProvider(post).notifier)
          .comment(post, 'che bella!');
      expect(reply, isNotNull);
      final target = (post: post, comment: reply!);
      b.listen(commentLikesProvider(target), (_, _) {});
      expect(await b.read(commentLikesProvider(target).notifier).like(), true);

      // The author sees all three…
      await eventually(
        () =>
            a
                .read(privatePostsProvider)
                .of(post.id)
                .likers
                .contains(bob.publicKey) &&
            a.read(privatePostsProvider).of(post.id).replies.length == 1 &&
            a
                .read(privatePostsProvider)
                .commentLikers(reply.id)
                .contains(bob.publicKey),
        reason: 'the author never saw the likes and the reply',
      );
      expect(
        a.read(privatePostsProvider).of(post.id).replies.single.text,
        'che bella!',
      );
      // …the friend sees their own,
      expect(b.read(privatePostsProvider).of(post.id).likers, {bob.publicKey});
      expect(b.read(commentLikesProvider(target)).count, 1);
      expect(b.read(commentLikesProvider(target)).likedByMe, true);
      // …and nothing about it is on a public relay.
      expect(
        relay.stored.where(
          (e) => e.kind == NostrKinds.reaction || e.kind == NostrKinds.comment,
        ),
        isEmpty,
      );
      expect(
        jsonEncode(relay.stored.map((e) => e.toJson()).toList()),
        isNot(contains('che bella')),
      );
    },
  );

  test(
    'a close-friends story: green ring data, expiration on the wrap',
    () async {
      final a = await aliceWithFriends();
      final b = app(bob);
      await online(b);
      compose(a, caption: 'storia segreta', mode: ComposerMode.story);
      expect(
        await a.read(composerProvider.notifier).publish(),
        true,
        reason: a.read(composerProvider).error,
      );

      b.listen(storiesProvider, (_, _) {});
      await eventually(
        () => b
            .read(storiesProvider)
            .groups
            .any((g) => g.author == alice.publicKey && g.hasPrivate),
        reason: 'the private story is missing from the rail',
      );
      final story = b.read(storiesProvider).groups.single.stories.single;
      expect(story.isStory, true);
      expect(story.isPrivate, true);
      expect(story.expiresAt, isNotNull);

      final wraps = relay.stored
          .where((e) => e.kind == NostrKinds.giftWrap)
          .toList();
      expect(wraps, isNotEmpty);
      for (final w in wraps) {
        expect(
          w.expiration,
          isNotNull,
          reason: 'relays should be able to forget it',
        );
      }
      // Stories never show up in the post feed.
      b.listen(feedProvider(FeedMode.following), (_, _) {});
      await Future<void>.delayed(const Duration(milliseconds: 500));
      expect(b.read(feedProvider(FeedMode.following)).posts, isEmpty);
    },
  );

  test('if no server takes the encrypted file nothing is published — never '
      'a plaintext fallback', () async {
    blossom.refuseOpaque = true;
    final a = await aliceWithFriends();
    compose(a);
    final ok = await a.read(composerProvider.notifier).publish();
    expect(ok, false);
    final error = a.read(composerProvider).error!;
    expect(error, contains('encrypted'));
    expect(error, contains('in the clear'));
    expect(blossom.blobs, isEmpty);
    expect(blossom.uploadContentTypes, isNotEmpty);
    expect(blossom.uploadContentTypes.toSet(), {'application/octet-stream'});
    expect(relay.stored.where((e) => e.kind == NostrKinds.giftWrap), isEmpty);
    expect(a.read(privatePostsProvider).posts, isEmpty);
    // the draft is still there to retry
    expect(a.read(composerProvider).media, isNotEmpty);
  });

  test('refuses to publish for an empty list', () async {
    final a = app(alice);
    await online(a);
    compose(a);
    expect(await a.read(composerProvider.notifier).publish(), false);
    expect(a.read(composerProvider).error, contains('empty'));
    expect(blossom.uploadContentTypes, isEmpty);
  });

  test('nobody reachable: not published, nothing claimed delivered', () async {
    final a = app(alice);
    await online(a);
    await a.read(closeFriendsProvider.notifier).add([
      dave.publicKey,
    ]); // no inbox
    compose(a);
    expect(await a.read(composerProvider.notifier).publish(), false);
    expect(a.read(composerProvider).error, contains('No friend'));
  });

  test('private posts survive a restart without any relay', () async {
    final a = await aliceWithFriends();
    final dir = Directory.systemTemp.createTempSync('mialuna_bob_');
    final b = app(bob, dir: dir);
    await online(b);
    compose(a);
    expect(await a.read(composerProvider.notifier).publish(), true);
    await eventually(() => b.read(privatePostsProvider).posts.isNotEmpty);
    // Give the debounced write time to land.
    await Future<void>.delayed(const Duration(seconds: 3));

    final restarted = app(bob, dir: dir, offline: true);
    restarted.listen(privatePostsProvider, (_, _) {});
    await eventually(
      () => restarted.read(privatePostsProvider).posts.isNotEmpty,
      reason: 'the post was not restored from disk',
    );
    expect(
      restarted.read(privatePostsProvider).posts.single.caption,
      'solo per voi',
    );
  });

  test(
    'close friends list: encrypted on the relay, restored on another device',
    () async {
      final a = await aliceWithFriends();
      expect(a.read(closeFriendsProvider).members, [
        bob.publicKey,
        dave.publicKey,
      ]);
      await a.read(closeFriendsProvider.notifier).publish();

      final events = relay.stored
          .where((e) => e.kind == NostrKinds.followSet)
          .toList();
      expect(events, hasLength(1));
      expect(events.single.firstTagValue('d'), 'close-friends');
      expect(events.single.content, isNotEmpty);
      expect(events.single.content, isNot(contains(bob.publicKey)));
      expect(
        jsonEncode(events.single.toJson()),
        isNot(contains(bob.publicKey)),
      );

      // A second device (fresh storage) reads it back.
      final other = app(alice);
      await online(other);
      expect(other.read(closeFriendsProvider).members, isEmpty);
      await other.read(closeFriendsProvider.notifier).sync();
      expect(other.read(closeFriendsProvider).members, [
        bob.publicKey,
        dave.publicKey,
      ]);
    },
  );

  test('the list is capped and ignores yourself and duplicates', () async {
    final a = app(alice);
    await online(a);
    final notifier = a.read(closeFriendsProvider.notifier);
    expect(
      await notifier.add([alice.publicKey, bob.publicKey, bob.publicKey]),
      1,
    );
    final many = [for (var i = 0; i < 80; i++) newSigner().publicKey];
    await notifier.add(many);
    expect(
      a.read(closeFriendsProvider).members.length,
      CloseFriendsController.maxMembers,
    );
    await notifier.remove(bob.publicKey);
    expect(
      a.read(closeFriendsProvider).members,
      isNot(contains(bob.publicKey)),
    );
  });

  test(
    'a friend added right at start-up joins the saved list, not replaces it',
    () async {
      final dir = Directory.systemTemp.createTempSync('mialuna_cf_');
      File('${dir.path}/close_friends_${alice.publicKey}.json')
          .writeAsStringSync(
            jsonEncode({
              'members': [carol.publicKey],
              'updated_at': 1,
              'dirty': false,
            }),
          );
      final a = app(alice, dir: dir);
      // No waiting: this is what tapping "add" a moment after launch does.
      await a.read(closeFriendsProvider.notifier).add([bob.publicKey]);
      await Future<void>.delayed(const Duration(milliseconds: 300));

      expect(a.read(closeFriendsProvider).members.toSet(), {
        carol.publicKey,
        bob.publicKey,
      });
    },
  );

  test('a public event cannot pose as a private post', () {
    final fake = NostrEvent(
      id: 'a' * 64,
      pubkey: bob.publicKey,
      createdAt: 1,
      kind: 20,
      tags: [
        ['imeta', 'url https://x.example/a.jpg', 'm image/jpeg'],
        ['audience', 'close-friends'],
      ],
      content: '',
      sig: 'b' * 128,
    );
    expect(MediaPost.tryParse(fake), isNull);
    expect(MediaPost.tryParse(fake, allowPrivate: true)?.isPrivate, true);
  });
}
