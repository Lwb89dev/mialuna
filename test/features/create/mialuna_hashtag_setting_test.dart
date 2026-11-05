import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:mialuna/app/providers.dart';
import 'package:mialuna/core/auth/auth_controller.dart';
import 'package:mialuna/core/media/blossom.dart';
import 'package:mialuna/core/nostr/event.dart';
import 'package:mialuna/core/nostr/relay_pool.dart';
import 'package:mialuna/core/nostr/signer.dart';
import 'package:mialuna/core/storage/local_cache.dart';
import 'package:mialuna/features/create/create_controller.dart';
import 'package:mialuna/features/private/close_friends.dart';
import 'package:mialuna/features/settings/settings_controller.dart';
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

PickedMedia _photo() {
  final image = img.Image(width: 20, height: 20);
  img.fill(image, color: img.ColorRgb8(30, 60, 90));
  final bytes = Uint8List.fromList(img.encodeJpg(image));
  return PickedMedia(
    file: XFile.fromData(bytes, name: 'photo.jpg'),
    bytes: bytes,
    mimeType: 'image/jpeg',
  );
}

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
    final dir = Directory.systemTemp.createTempSync('mialuna_hashtag_');
    final container = ProviderContainer(
      overrides: [
        authProvider.overrideWith(() => _FixedAuth(signer)),
        indexerRelaysProvider.overrideWithValue(const []),
        localCacheProvider.overrideWithValue(LocalCache(directory: dir)),
        httpClientProvider.overrideWithValue(blossom.client),
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

  test('the setting defaults to on and persists when switched off', () async {
    final prefs = await SharedPreferences.getInstance();
    expect(SettingsController.load(prefs).addMialunaHashtag, true);

    final container = app();
    await container.read(settingsProvider.notifier).setAddMialunaHashtag(false);

    expect(container.read(settingsProvider).addMialunaHashtag, false);
    expect(SettingsController.load(prefs).addMialunaHashtag, false);
  });

  test(
    'publishing without the official hashtag changes content and tags',
    () async {
      final container = app();
      await container
          .read(settingsProvider.notifier)
          .setAddMialunaHashtag(false);
      final composer = container.read(composerProvider.notifier);
      composer.addPicked(_photo());
      composer.setCaption('Tramonto #mare');

      expect(
        container.read(composerProvider).finalCaption(addMialunaTag: false),
        'Tramonto #mare',
      );
      expect(await composer.publish(), true);

      final event = relay.stored.singleWhere(
        (e) => e.kind == NostrKinds.picture,
      );
      expect(event.content, 'Tramonto #mare');
      expect(event.tagsNamed('t').map((tag) => tag[1]), contains('mare'));
      expect(
        event.tagsNamed('t').map((tag) => tag[1].toLowerCase()),
        isNot(contains('mialuna')),
      );
    },
  );

  test('switching it back on restores the existing behavior', () async {
    final container = app();
    final composer = container.read(composerProvider.notifier);
    composer.addPicked(_photo());
    composer.setCaption('Tramonto');

    expect(await composer.publish(), true);

    final event = relay.stored.singleWhere((e) => e.kind == NostrKinds.picture);
    expect(event.content, 'Tramonto #mialuna');
    expect(event.tagsNamed('t').map((tag) => tag[1]), contains('mialuna'));
  });

  test('close-friends captions never gain the official hashtag', () {
    const state = ComposerState(
      caption: 'Solo per noi',
      audience: Audience.closeFriends,
    );
    expect(state.finalCaption(), 'Solo per noi');
    expect(state.finalCaption(addMialunaTag: false), 'Solo per noi');
  });
}
