import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mialuna/app/providers.dart';
import 'package:mialuna/core/auth/auth_controller.dart';
import 'package:mialuna/core/nostr/event.dart';
import 'package:mialuna/core/nostr/nip51.dart';
import 'package:mialuna/core/nostr/relay_pool.dart';
import 'package:mialuna/core/nostr/signer.dart';
import 'package:mialuna/features/social/moderation_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../support/fake_relay.dart';

class _FixedAuth extends AuthController {
  final Signer signer;
  _FixedAuth(this.signer);
  @override
  AuthState build() => AuthState(signer);
}

ProviderContainer _app(Signer signer, FakeRelay relay) {
  final container = ProviderContainer(
    overrides: [
      authProvider.overrideWith(() => _FixedAuth(signer)),
      indexerRelaysProvider.overrideWithValue(const []),
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

/// Mialuna shares its mute list and bookmarks with every other Nostr client.
/// Republishing them must not delete what only the other clients understand.
void main() {
  late FakeRelay relay;
  late NsecSigner me;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    relay = await FakeRelay().start();
    me = NsecSigner.fromNsec(NsecSigner.generatePrivateKey());
  });

  tearDown(() => relay.stop());

  NostrEvent newest(int kind) =>
      (relay.stored.where((e) => e.kind == kind).toList()
            ..sort((a, b) => a.createdAt.compareTo(b.createdAt)))
          .last;

  test(
    'muting someone keeps the other clients\' entries and content',
    () async {
      final old = DateTime.now().millisecondsSinceEpoch ~/ 1000 - 100;
      relay.add(
        await signed(
          me,
          kind: NostrKinds.muteList,
          tags: [
            ['p', 'a' * 64],
            ['word', 'spoiler'],
            ['e', 'b' * 64],
            ['t', 'noise'],
          ],
          content: 'ENCRYPTED-PRIVATE-MUTES',
          createdAt: old,
        ),
      );
      final app = _app(me, relay);
      app.listen(muteControllerProvider, (_, _) {});
      final ctl = app.read(muteControllerProvider.notifier);

      await ctl.syncFromRelays(me.publicKey);
      await ctl.mute('c' * 64);

      final event = newest(NostrKinds.muteList);
      expect(event.createdAt, greaterThan(old), reason: 'a new list was sent');
      expect(event.content, 'ENCRYPTED-PRIVATE-MUTES');
      expect(
        event.tags,
        containsAll([
          ['word', 'spoiler'],
          ['e', 'b' * 64],
        ]),
      );
      expect(Nip51.mutedPubkeys(event), {'a' * 64, 'c' * 64});
      expect(Nip51.mutedHashtags(event), {'noise'});
    },
  );

  test(
    'an early mute waits for the relay copy instead of replacing it',
    () async {
      final old = DateTime.now().millisecondsSinceEpoch ~/ 1000 - 100;
      relay.add(
        await signed(
          me,
          kind: NostrKinds.muteList,
          tags: [
            ['p', 'a' * 64],
            ['word', 'spoiler'],
          ],
          createdAt: old,
        ),
      );
      final app = _app(me, relay);
      app.listen(muteControllerProvider, (_, _) {});
      final ctl = app.read(muteControllerProvider.notifier);

      // The sign-in sync has started, the user mutes before it finished.
      final sync = ctl.syncFromRelays(me.publicKey);
      await ctl.mute('c' * 64);
      await sync;

      final event = newest(NostrKinds.muteList);
      expect(Nip51.mutedPubkeys(event), {'a' * 64, 'c' * 64});
      expect(event.tags, contains(equals(['word', 'spoiler'])));
    },
  );

  test(
    'saving a post keeps the addressable bookmarks of other clients',
    () async {
      final old = DateTime.now().millisecondsSinceEpoch ~/ 1000 - 100;
      relay.add(
        await signed(
          me,
          kind: NostrKinds.bookmarks,
          tags: [
            ['e', 'a' * 64],
            ['a', '30023:${'d' * 64}:article'],
            ['t', 'recipes'],
          ],
          content: 'ENCRYPTED-PRIVATE-BOOKMARKS',
          createdAt: old,
        ),
      );
      final app = _app(me, relay);
      app.listen(bookmarksProvider, (_, _) {});
      final ctl = app.read(bookmarksProvider.notifier);

      await ctl.syncFromRelays(me.publicKey);
      await ctl.toggle('f' * 64);

      final event = newest(NostrKinds.bookmarks);
      expect(event.content, 'ENCRYPTED-PRIVATE-BOOKMARKS');
      expect(
        event.tags,
        containsAll([
          ['a', '30023:${'d' * 64}:article'],
          ['t', 'recipes'],
        ]),
      );
      expect(Nip51.bookmarkIds(event), {'a' * 64, 'f' * 64});
    },
  );

  test('keepingForeignTags drops only the tags Mialuna manages', () {
    final previous = NostrEvent(
      id: 'a' * 64,
      pubkey: 'b' * 64,
      createdAt: 1,
      kind: NostrKinds.muteList,
      tags: [
        ['p', 'x'],
        ['word', 'w'],
        [],
      ],
      content: '',
      sig: 'c' * 128,
    );
    expect(
      Nip51.keepingForeignTags(
        previous,
        [
          ['p', 'y'],
        ],
        managedNames: {'p'},
      ),
      [
        ['word', 'w'],
        [],
        ['p', 'y'],
      ],
    );
    expect(
      Nip51.keepingForeignTags(
        null,
        [
          ['p', 'y'],
        ],
        managedNames: {'p'},
      ),
      [
        ['p', 'y'],
      ],
    );
  });
}
