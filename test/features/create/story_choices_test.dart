import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:mialuna/app/providers.dart';
import 'package:mialuna/core/auth/auth_controller.dart';
import 'package:mialuna/core/media/blossom.dart';
import 'package:mialuna/core/nostr/event.dart';
import 'package:mialuna/core/nostr/models/media_event.dart';
import 'package:mialuna/core/nostr/models/story_link.dart';
import 'package:mialuna/core/nostr/profile_repository.dart';
import 'package:mialuna/core/nostr/relay_pool.dart';
import 'package:mialuna/core/nostr/signer.dart';
import 'package:mialuna/core/storage/local_cache.dart';
import 'package:mialuna/features/create/create_controller.dart';
import 'package:mialuna/features/create/editor/crop_tool.dart';
import 'package:mialuna/features/create/editor/image_edit_apply.dart';
import 'package:mialuna/features/settings/settings_controller.dart';
import 'package:mialuna/features/stories/post_story.dart';
import 'package:mialuna/features/stories/story_cleanup.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../support/fake_blossom.dart';
import '../../support/fake_relay.dart';
import '../../support/recording_signer.dart';

class _FixedAuth extends AuthController {
  final Signer signer;
  _FixedAuth(this.signer);
  @override
  AuthState build() => AuthState(signer);
}

const ProfileMetadata? _noProfile = null;

Uint8List _jpeg(int width, int height) {
  final image = img.Image(width: width, height: height);
  img.fill(image, color: img.ColorRgb8(30, 60, 90));
  return Uint8List.fromList(img.encodeJpg(image));
}

PickedMedia _photo([int width = 20, int height = 20]) {
  final bytes = _jpeg(width, height);
  return PickedMedia(
    file: XFile.fromData(bytes, name: 'photo.jpg'),
    bytes: bytes,
    mimeType: 'image/jpeg',
  );
}

/// What can be chosen for one post or story, and the stories the app draws.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeRelay relay;
  late FakeBlossom blossom;
  late RecordingSigner signer;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    BlossomClient.forgetServerBehaviour();
    relay = await FakeRelay().start();
    blossom = FakeBlossom();
    signer = RecordingSigner.generate();
  });

  tearDown(() => relay.stop());

  ProviderContainer app() {
    final dir = Directory.systemTemp.createTempSync('mialuna_choices_');
    final container = ProviderContainer(
      overrides: [
        authProvider.overrideWith(() => _FixedAuth(signer)),
        indexerRelaysProvider.overrideWithValue(const []),
        localCacheProvider.overrideWithValue(LocalCache(directory: dir)),
        httpClientProvider.overrideWithValue(blossom.client),
        profileProvider.overrideWith((ref, pubkey) => _noProfile),
        profileMetadataProvider.overrideWith((ref, pubkey) async => _noProfile),
        postImageLoaderProvider.overrideWithValue((_) => _solid(400, 300)),
        relayPoolProvider.overrideWith((ref) {
          final pool = RelayPool([RelayConfig(relay.url)]);
          ref.onDispose(pool.dispose);
          return pool;
        }),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  NostrEvent publishedStory() =>
      relay.stored.singleWhere((e) => e.kind == NostrKinds.story);

  List<String> hashtags(NostrEvent e) => [
    for (final t in e.tagsNamed('t')) t[1].toLowerCase(),
  ];

  group('#mialuna, post by post', () {
    test('can be left off one story while Settings says yes', () async {
      final c = app();
      final composer = c.read(composerProvider.notifier);
      composer.setMode(ComposerMode.story);
      composer.addPicked(_photo());
      composer.setCaption('Tramonto');
      composer.setMialunaTag(false);

      expect(await composer.publish(), true);

      expect(publishedStory().content, 'Tramonto');
      expect(hashtags(publishedStory()), isNot(contains('mialuna')));
      expect(c.read(settingsProvider).addMialunaHashtag, true);
      expect(c.read(composerProvider).mialunaTag, isNull, reason: 'that one');
    });

    test('can be added to one post while Settings says no', () async {
      final c = app();
      await c.read(settingsProvider.notifier).setAddMialunaHashtag(false);
      final composer = c.read(composerProvider.notifier);
      composer.addPicked(_photo());
      composer.setMialunaTag(true);

      expect(await composer.publish(), true);

      final post = relay.stored.singleWhere(
        (e) => e.kind == NostrKinds.picture,
      );
      expect(post.content, '#mialuna');
      expect(hashtags(post), contains('mialuna'));
    });
  });

  group('keeping or deleting, story by story', () {
    test('a kept story says so and is written down as kept', () async {
      final c = app();
      final composer = c.read(composerProvider.notifier);
      composer.startStory();
      composer.addPicked(_photo());
      composer.setKeepStory(true);

      expect(await composer.publish(), true);

      expect(publishedStory().firstTagValue(MediaPost.keepTag), 'true');
      expect(c.read(storyCleanupProvider).stories.single.fate, StoryFate.kept);
    });

    test('by default a story is to be deleted and carries no tag', () async {
      final c = app();
      final composer = c.read(composerProvider.notifier);
      composer.startStory();
      composer.addPicked(_photo());

      expect(await composer.publish(), true);

      expect(publishedStory().tagsNamed(MediaPost.keepTag), isEmpty);
      final tracked = c.read(storyCleanupProvider).stories.single;
      expect(tracked.fate, StoryFate.live);
      expect(tracked.automatic, true);
    });

    test('switching Settings off later still stops a default one', () async {
      final c = app();
      final composer = c.read(composerProvider.notifier);
      composer.startStory();
      composer.addPicked(_photo());
      expect(await composer.publish(), true);

      await c.read(deleteExpiredStoriesProvider.notifier).set(false);

      expect(c.read(storyCleanupProvider).stories.single.automatic, false);
    });

    test('one set to be deleted by hand stays set to be', () async {
      final c = app();
      final composer = c.read(composerProvider.notifier);
      composer.startStory();
      composer.addPicked(_photo());
      composer.setKeepStory(false);
      expect(await composer.publish(), true);

      await c.read(deleteExpiredStoriesProvider.notifier).set(false);

      expect(c.read(storyCleanupProvider).stories.single.automatic, true);
    });

    test('with Settings off, a new story is kept', () async {
      final c = app();
      await c.read(deleteExpiredStoriesProvider.notifier).set(false);
      final composer = c.read(composerProvider.notifier);
      composer.startStory();
      composer.addPicked(_photo());

      expect(await composer.publish(), true);

      expect(publishedStory().firstTagValue(MediaPost.keepTag), 'true');
    });
  });

  group('a photo taken for a story', () {
    test('starts out 9:16, with the whole photo kept', () async {
      final c = app();
      final composer = c.read(composerProvider.notifier);
      composer.startStory();
      final photo = _photo(300, 400);

      await composer.addCameraStory(photo);

      final media = c.read(composerProvider).media.single;
      final cut = img.decodeImage(media.bytes)!;
      expect(cut.height, 400);
      expect(cut.width / cut.height, closeTo(9 / 16, 0.01));
      expect(media.originalBytes, photo.bytes, reason: 'it can be undone');
      expect(
        CropTool.shapeOf(media.edit.crop, 300 / 400),
        CropShape.nineSixteen,
        reason: 'the editor opens with 9:16 selected',
      );
      expect(c.read(composerProvider).isPreparing, false);
    });

    test('a landscape one is left as it was framed', () {
      expect(cropPortrait(_jpeg(400, 300), 9 / 16), isNull);
      expect(cropPortrait(_jpeg(90, 160), 9 / 16), isNull);
    });

    test('thrown away while being cut, it does not come back', () async {
      final c = app();
      final composer = c.read(composerProvider.notifier);
      composer.startStory();

      final cutting = composer.addCameraStory(_photo(300, 400));
      composer.startStory();
      await cutting;

      expect(c.read(composerProvider).media, isEmpty);
      expect(c.read(composerProvider).isPreparing, false);
    });
  });

  group('a post shared to a story', () {
    Future<MediaPost> aPost({bool sensitive = false}) async {
      final author = RecordingSigner.generate();
      final event = await signed(
        author,
        kind: NostrKinds.picture,
        content: 'Il lago #sera',
        tags: [
          ['imeta', 'url https://cdn.example.com/a.jpg', 'm image/jpeg'],
          if (sensitive) ['content-warning', 'x'],
        ],
      );
      return MediaPost.tryParse(event)!;
    }

    test('is a 1080×1920 picture of it that points back to it', () async {
      final c = app();
      final composer = c.read(composerProvider.notifier);
      final post = await aPost();

      await composer.startPostStory(post);

      final state = c.read(composerProvider);
      expect(state.error, isNull);
      expect(state.mode, ComposerMode.story);
      final picture = img.decodeImage(state.media.single.bytes)!;
      expect((picture.width, picture.height), (1080, 1920));
      final area = state.sharedPost!.area!;
      expect(state.sharedPost!.eventId, post.id);
      expect(area.left, greaterThan(0.05));
      expect(area.left + area.width, lessThan(0.95));
      expect(area.top, greaterThan(0));
      expect(area.top + area.height, lessThan(1));

      expect(await composer.publish(), true);
      final story = MediaPost.tryParse(publishedStory())!;
      expect(story.link!.eventId, post.id);
      expect(story.link!.author, post.author);
      // Without the size, a viewer could not tell where the preview is.
      expect(story.media.single.aspectRatio, closeTo(9 / 16, 0.001));
      expect(story.link!.area!.top, closeTo(area.top, 0.001));
      expect(
        publishedStory().tagsNamed('p'),
        isEmpty,
        reason: 'on a story, p tags are the close-friends audience',
      );
    });

    test('says so when the picture of the post cannot be loaded', () async {
      final post = await aPost();
      final c = ProviderContainer(
        overrides: [
          authProvider.overrideWith(() => _FixedAuth(signer)),
          localCacheProvider.overrideWithValue(
            LocalCache(directory: Directory.systemTemp.createTempSync()),
          ),
          profileProvider.overrideWith((ref, pubkey) => _noProfile),
          profileMetadataProvider.overrideWith(
            (ref, pubkey) async => _noProfile,
          ),
          postImageLoaderProvider.overrideWithValue((_) async => null),
          relayPoolProvider.overrideWithValue(RelayPool(const [])),
        ],
      );
      addTearDown(c.dispose);

      await c.read(composerProvider.notifier).startPostStory(post);

      expect(c.read(composerProvider).media, isEmpty);
      expect(c.read(composerProvider).error, isNotNull);
    });

    test('draws nothing of a post behind a content warning', () async {
      var loads = 0;
      final post = await aPost(sensitive: true);
      final c = ProviderContainer(
        overrides: [
          profileProvider.overrideWith((ref, pubkey) => _noProfile),
          profileMetadataProvider.overrideWith(
            (ref, pubkey) async => _noProfile,
          ),
          postImageLoaderProvider.overrideWithValue((_) {
            loads++;
            return _solid(10, 10);
          }),
        ],
      );
      addTearDown(c.dispose);

      await c.read(postCardRendererProvider)(post);

      expect(loads, 0);
    });

    test('another picture drops the link to the post', () async {
      final c = app();
      final composer = c.read(composerProvider.notifier);
      await composer.startPostStory(await aPost());

      composer.addPicked(_photo());

      expect(c.read(composerProvider).sharedPost, isNull);
    });
  });

  group('what a story says about the post it shows', () {
    final id = 'a' * 64;
    final author = 'b' * 64;

    test('survives the trip through its tags', () {
      const area = StoryArea(left: 0.12, top: 0.2, width: 0.76, height: 0.6);
      final link = StoryPostLink(
        eventId: id,
        author: author,
        relay: 'wss://relay.example',
        area: area,
      );
      expect(StoryPostLink.fromTags(link.toTags()), link);

      final bare = StoryPostLink(eventId: id, author: author);
      expect(StoryPostLink.fromTags(bare.toTags()), bare);
    });

    test('ignores what cannot be right', () {
      expect(
        StoryPostLink.fromTags([
          ['q', 'not an id'],
        ]),
        isNull,
      );
      final odd = StoryPostLink.fromTags([
        ['q', id, 'http://plain.example', 'me'],
        ['story-card', '0.5,0.5,0.9,0.9'],
      ])!;
      expect(odd.relay, isNull);
      expect(odd.author, isNull);
      expect(odd.area, isNull);
      expect(StoryArea.decode('NaN,0,1,1'), isNull);
      expect(StoryArea.decode('0,0,1'), isNull);
    });

    test('only counts on a story', () {
      final tags = MediaPost.buildTags(
        media: const [MediaItem(url: 'https://cdn.example.com/a.jpg')],
        caption: '',
        link: StoryPostLink(eventId: id),
        keepStory: true,
      );
      expect(tags.map((t) => t[0]), isNot(contains('q')));
      expect(tags.map((t) => t[0]), isNot(contains(MediaPost.keepTag)));
    });
  });
}

Future<ui.Image> _solid(int width, int height) {
  final recorder = ui.PictureRecorder();
  ui.Canvas(recorder).drawRect(
    ui.Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()),
    ui.Paint()..color = const ui.Color(0xFF336699),
  );
  return recorder.endRecording().toImage(width, height);
}
