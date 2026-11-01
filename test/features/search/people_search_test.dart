import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mialuna/app/providers.dart';
import 'package:mialuna/core/auth/auth_controller.dart';
import 'package:mialuna/core/nostr/event.dart';
import 'package:mialuna/core/nostr/relay_pool.dart';
import 'package:mialuna/core/nostr/signer.dart';
import 'package:mialuna/core/storage/local_cache.dart';
import 'package:mialuna/features/messages/dm_controller.dart';
import 'package:mialuna/features/search/people_search.dart';
import 'package:mialuna/features/social/follow_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../support/fake_relay.dart';

class _FixedAuth extends AuthController {
  final Signer signer;
  _FixedAuth(this.signer);
  @override
  AuthState build() => AuthState(signer);
}

class _QuietDm extends DmController {
  @override
  DmState build() => const DmState();
}

NsecSigner newSigner() => NsecSigner.fromNsec(NsecSigner.generatePrivateKey());

Future<NostrEvent> profile(
  Signer s,
  String name, {
  String? display,
  String? nip05,
}) => signed(
  s,
  kind: 0,
  content: jsonEncode({
    'name': name,
    'display_name': ?display,
    'nip05': ?nip05,
  }),
);

void main() {
  late FakeRelay home; // the user's relay
  late FakeRelay searchRelay; // a NIP-50 relay
  late NsecSigner me;
  late Directory tmp;

  ProviderContainer app({List<String>? follows}) {
    final container = ProviderContainer(
      overrides: [
        authProvider.overrideWith(() => _FixedAuth(me)),
        dmProvider.overrideWith(_QuietDm.new),
        indexerRelaysProvider.overrideWithValue(const []),
        profileSearchRelaysProvider.overrideWithValue([searchRelay.url]),
        localCacheProvider.overrideWithValue(LocalCache(directory: tmp)),
        relayPoolProvider.overrideWith((ref) {
          // The search relay is known to the pool but neither read nor
          // written by default, like a real NIP-50 relay would be.
          final pool = RelayPool([
            RelayConfig(home.url),
            RelayConfig(searchRelay.url, read: false, write: false),
          ]);
          ref.onDispose(pool.dispose);
          return pool;
        }),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    home = await FakeRelay().start();
    searchRelay = await FakeRelay().start();
    me = newSigner();
    tmp = Directory.systemTemp.createTempSync('mialuna_search_');
  });

  tearDown(() async {
    await home.stop();
    await searchRelay.stop();
  });

  group('normalization', () {
    test('accents, case and a leading @ do not matter', () {
      expect(normalizeForSearch('José'), 'jose');
      expect(normalizeForSearch('@Çağla'), 'cagla');
      expect(normalizeForSearch('  Zoë  '), 'zoe');
    });
  });

  test(
    'finds followed people by name — even before their profile was loaded',
    () async {
      final luigi = newSigner();
      final marta = newSigner();
      final carlo = newSigner();
      home.add(
        await signed(
          me,
          kind: 3,
          tags: [
            for (final s in [luigi, marta, carlo]) ['p', s.publicKey],
          ],
        ),
      );
      home.add(await profile(luigi, 'luigi', display: 'Luigi Rossi'));
      home.add(await profile(marta, 'marta', display: 'Marta Bianchi'));
      home.add(await profile(carlo, 'carlo'));

      final c = app();
      c.read(followListProvider.notifier); // starts loading the follow list
      await eventually(() => c.read(followListProvider).length == 3);
      c.listen(peopleSearchProvider, (_, _) {});
      // Nothing is known about their names yet.
      c.read(peopleSearchProvider.notifier).setQuery('marta');

      await eventually(
        () => c.read(peopleSearchProvider).results.contains(marta.publicKey),
        reason: 'a followed person was not found by name',
      );
      expect(c.read(peopleSearchProvider).results.first, marta.publicKey);
      expect(
        c.read(peopleSearchProvider).results,
        isNot(contains(luigi.publicKey)),
      );
    },
  );

  test('matches display name, username and NIP-05, ignoring accents', () async {
    final jose = newSigner();
    home.add(
      await signed(
        me,
        kind: 3,
        tags: [
          ['p', jose.publicKey],
        ],
      ),
    );
    home.add(
      await profile(
        jose,
        'jj',
        display: 'José Álvarez',
        nip05: 'pepe@example.com',
      ),
    );

    final c = app();
    c.read(followListProvider.notifier);
    await eventually(() => c.read(followListProvider).isNotEmpty);
    c.listen(peopleSearchProvider, (_, _) {});
    final search = c.read(peopleSearchProvider.notifier);
    for (final q in ['jose', 'alvarez', 'JOSÉ', 'pepe', 'jj']) {
      search.setQuery(q);
      await eventually(
        () => c.read(peopleSearchProvider).results.contains(jose.publicKey),
        reason: '"$q" did not find José',
      );
    }
    search.setQuery('xyzzy-nobody');
    await Future<void>.delayed(const Duration(milliseconds: 100));
    expect(c.read(peopleSearchProvider).results, isEmpty);
  });

  test('also finds strangers through a NIP-50 search relay', () async {
    final stranger = newSigner();
    searchRelay.add(await profile(stranger, 'giulia', display: 'Giulia Verdi'));
    searchRelay.add(await profile(newSigner(), 'someone-else'));

    final c = app();
    c.listen(peopleSearchProvider, (_, _) {});
    c.read(peopleSearchProvider.notifier).setQuery('giulia');

    await eventually(
      () => c.read(peopleSearchProvider).results.contains(stranger.publicKey),
      reason: 'the search relay result never arrived',
    );
    await eventually(() => !c.read(peopleSearchProvider).searching);
    expect(c.read(peopleSearchProvider).results, [stranger.publicKey]);
    // Their profile is now cached: the name can be shown.
    await eventually(
      () =>
          c.read(profilesProvider)[stranger.publicKey]?.label == 'Giulia Verdi',
    );
  });

  test('people you follow come before strangers with an equal match', () async {
    final friend = newSigner();
    final stranger = newSigner();
    home.add(
      await signed(
        me,
        kind: 3,
        tags: [
          ['p', friend.publicKey],
        ],
      ),
    );
    home.add(await profile(friend, 'anna'));
    searchRelay.add(await profile(stranger, 'anna'));

    final c = app();
    c.read(followListProvider.notifier);
    await eventually(() => c.read(followListProvider).isNotEmpty);
    c.listen(peopleSearchProvider, (_, _) {});
    c.read(peopleSearchProvider.notifier).setQuery('anna');
    await eventually(
      () => c.read(peopleSearchProvider).results.length == 2,
      reason: 'both Annas should be found',
    );
    expect(c.read(peopleSearchProvider).results.first, friend.publicKey);
  });

  test('an npub or hex key still works, but is not required', () async {
    final target = newSigner();
    final c = app();
    c.listen(peopleSearchProvider, (_, _) {});
    c.read(peopleSearchProvider.notifier).setQuery(target.publicKey);
    expect(c.read(peopleSearchProvider).results, [target.publicKey]);
  });

  test('yourself and blocked people are never offered', () async {
    final c = app();
    c.listen(peopleSearchProvider, (_, _) {});
    final own = await profile(me, 'me-myself');
    c.read(profileRepositoryProvider).applyLocal(own);
    c.read(peopleSearchProvider.notifier).setQuery('me-myself');
    await Future<void>.delayed(const Duration(milliseconds: 100));
    expect(c.read(peopleSearchProvider).results, isNot(contains(me.publicKey)));
  });
}
