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
import 'package:mialuna/core/nostr/models/media_event.dart';
import 'package:mialuna/core/nostr/models/story_text.dart';
import 'package:mialuna/core/nostr/relay_pool.dart';
import 'package:mialuna/core/nostr/signer.dart';
import 'package:mialuna/core/storage/local_cache.dart';
import 'package:mialuna/features/create/create_controller.dart';
import 'package:mialuna/features/messages/dm_controller.dart';
import 'package:mialuna/features/private/close_friends.dart';
import 'package:mialuna/features/private/private_posts.dart';
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
  return Uint8List.fromList(img.encodeJpg(image));
}

PickedMedia picked() {
  final bytes = jpegFixture();
  return PickedMedia(
    file: XFile.fromData(bytes, name: 'a.jpg'),
    bytes: bytes,
    mimeType: 'image/jpeg',
  );
}

const lakeText = StoryText(
  text: 'Sul #lago',
  x: 0.3,
  y: 0.7,
  scale: 1.4,
  rotation: -0.2,
  color: 0xFF3B30,
  font: StoryTextFont.bold,
  background: StoryTextBackground.solid,
);

void main() {
  late FakeRelay relay;
  late FakeBlossom blossom;
  late NsecSigner alice;
  late NsecSigner bob;

  ProviderContainer app(Signer signer) {
    final dir = Directory.systemTemp.createTempSync('mialuna_story_text_');
    final c = ProviderContainer(
      overrides: [
        authProvider.overrideWith(() => _FixedAuth(signer)),
        indexerRelaysProvider.overrideWithValue(const []),
        localCacheProvider.overrideWithValue(LocalCache(directory: dir)),
        httpClientProvider.overrideWithValue(blossom.client),
        privateMediaProvider.overrideWithValue(
          PrivateMediaService(blossom.client, directory: dir),
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

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    BlossomClient.forgetServerBehaviour();
    relay = await FakeRelay(authKinds: {1059}).start();
    blossom = FakeBlossom();
    alice = newSigner();
    bob = newSigner();
    for (final s in [alice, bob]) {
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

  test('a public story is published with its texts', () async {
    final a = app(alice);
    final composer = a.read(composerProvider.notifier);
    composer.setMode(ComposerMode.story);
    composer.addPicked(picked());
    composer.setOverlays(const [lakeText]);
    composer.setCaption('didascalia');

    final ok = await composer.publish();
    expect(ok, true, reason: a.read(composerProvider).error);

    final event = relay.stored.singleWhere((e) => e.kind == NostrKinds.picture);
    final post = MediaPost.tryParse(event)!;
    expect(post.isStory, true);
    expect(post.overlays, [lakeText]);
    expect(
      event.tags.where((t) => t[0] == 't').map((t) => t[1]),
      containsAll(['lago', 'mialuna']),
      reason: 'the hashtag of the text is searchable too',
    );
    // The picture on the server is a plain photo: nothing is baked in.
    expect(post.media.single.width, 40);
    // A finished post leaves nothing behind for the next one.
    expect(a.read(composerProvider).overlays, isEmpty);
  });

  test('a public story is in your rail the moment it is published', () async {
    final a = app(alice);
    a.listen(storiesProvider, (_, _) {});
    final composer = a.read(composerProvider.notifier);
    composer.setMode(ComposerMode.story);
    composer.addPicked(picked());
    composer.setOverlays(const [lakeText]);
    expect(a.read(storiesProvider).groups, isEmpty);

    final ok = await composer.publish();
    expect(ok, true, reason: a.read(composerProvider).error);

    final groups = a.read(storiesProvider).groups;
    expect(groups.single.author, alice.publicKey);
    expect(groups.single.stories.single.overlays, [lakeText]);

    // A second one makes two parts of the ring, oldest first.
    composer.setMode(ComposerMode.story);
    composer.addPicked(picked());
    expect(await composer.publish(), true);
    expect(a.read(storiesProvider).groups.single.stories, hasLength(2));
  });

  test('a new story starts clean', () {
    final a = app(alice);
    final composer = a.read(composerProvider.notifier);
    composer.setMode(ComposerMode.story);
    composer.addPicked(picked());
    composer.setOverlays(const [lakeText]);

    composer.startStory();

    final state = a.read(composerProvider);
    expect(state.mode, ComposerMode.story);
    expect(state.media, isEmpty);
    expect(state.overlays, isEmpty);
  });

  test(
    'a close-friends story keeps its texts inside the encrypted post',
    () async {
      final a = app(alice);
      final b = app(bob);
      for (final c in [a, b]) {
        c.listen(dmProvider, (_, _) {});
        c.listen(privatePostsProvider, (_, _) {});
        await eventually(() => c.read(dmProvider).inboxConfigured == true);
      }
      await a.read(closeFriendsProvider.notifier).add([bob.publicKey]);

      final composer = a.read(composerProvider.notifier);
      composer.setMode(ComposerMode.story);
      composer.addPicked(picked());
      composer.setOverlays(const [lakeText]);
      composer.setAudience(Audience.closeFriends);
      final ok = await composer.publish();
      expect(ok, true, reason: a.read(composerProvider).error);

      await eventually(
        () => b.read(privatePostsProvider).posts.isNotEmpty,
        reason: 'the friend never received the story',
      );
      final story = b.read(privatePostsProvider).posts.single;
      expect(story.isStory && story.isPrivate, true);
      expect(story.overlays, [lakeText]);

      // The relay only ever saw gift wraps: the text is not readable there.
      for (final e in relay.stored.where(
        (e) => e.kind == NostrKinds.giftWrap,
      )) {
        expect(e.content, isNot(contains('lago')));
        expect(e.tags.any((t) => t[0] == 'story-text'), false);
      }
    },
  );

  group('composer', () {
    late ProviderContainer a;
    late ComposerController composer;

    ComposerState state() => a.read(composerProvider);

    setUp(() {
      a = app(alice);
      composer = a.read(composerProvider.notifier);
      composer.setMode(ComposerMode.story);
      composer.addPicked(picked());
      composer.setOverlays(const [lakeText]);
    });

    test('the texts follow the picture, not the session', () {
      expect(state().overlays, [lakeText]);

      // Cropping the picture keeps them (they are placed in fractions)…
      composer.replaceMediaBytes(0, jpegFixture());
      expect(state().overlays, [lakeText]);

      // …another picture, no picture, or another kind of post does not.
      composer.addPicked(picked());
      expect(state().overlays, isEmpty);

      composer.setOverlays(const [lakeText]);
      composer.removeMedia(0);
      expect(state().overlays, isEmpty);

      composer.addPicked(picked());
      composer.setOverlays(const [lakeText]);
      composer.setMode(ComposerMode.photo);
      expect(state().overlays, isEmpty);
    });

    testWidgets('the backdrop of a photo story has the picture\'s shape', (
      tester,
    ) async {
      // Decoding a picture needs the real engine, not the test clock.
      final backdrop = await tester.runAsync(composer.storyBackdrop);
      expect(backdrop!.bytes, isNotNull);
      expect(backdrop.aspect, closeTo(40 / 30, 0.001));
    });
  });
}
