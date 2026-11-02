import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mialuna/app/providers.dart';
import 'package:mialuna/core/auth/auth_controller.dart';
import 'package:mialuna/core/nostr/event.dart';
import 'package:mialuna/core/nostr/relay_pool.dart';
import 'package:mialuna/core/nostr/signer.dart';
import 'package:mialuna/core/storage/local_cache.dart';
import 'package:mialuna/features/feed/feed_controller.dart';
import 'package:mialuna/features/feed/feed_screen.dart';
import 'package:mialuna/features/social/follow_controller.dart';
import 'package:mialuna/l10n/strings.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../support/fake_relay.dart';

class _FixedAuth extends AuthController {
  final AuthState fixed;
  _FixedAuth(this.fixed);
  @override
  AuthState build() => fixed;
}

NsecSigner newSigner() => NsecSigner.fromNsec(NsecSigner.generatePrivateKey());

Future<NostrEvent> photo(Signer s, String text, {int? at}) => signed(
  s,
  kind: 20,
  content: text,
  createdAt: at,
  tags: [
    [
      'imeta',
      'url https://cdn.example.com/${text.hashCode.abs()}.jpg',
      'm image/jpeg',
      'dim 800x1000',
    ],
  ],
);

/// How fast Home appears and how fast it answers a pull to refresh.
void main() {
  late FakeRelay relay;
  late NsecSigner me;
  late NsecSigner bob;
  late Directory dir;

  ProviderContainer app({AuthState? auth, Directory? cacheDir}) {
    final c = ProviderContainer(
      overrides: [
        authProvider.overrideWith(() => _FixedAuth(auth ?? AuthState(me))),
        indexerRelaysProvider.overrideWithValue(const []),
        localCacheProvider.overrideWithValue(
          LocalCache(directory: cacheDir ?? dir),
        ),
        relayPoolProvider.overrideWith((ref) {
          final pool = RelayPool([RelayConfig(relay.url)]);
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
    relay = await FakeRelay().start();
    me = newSigner();
    bob = newSigner();
    dir = Directory.systemTemp.createTempSync('mialuna_start_');
  });

  tearDown(() => relay.stop());

  Future<void> saveHomeFeed(NsecSigner owner, List<NostrEvent> events) =>
      LocalCache(directory: dir).saveOwnedEvents(
        owner.publicKey,
        events,
        file: LocalCache.followingEventsFile,
      );

  test(
    'Home shows last session\'s posts before any relay has answered',
    () async {
      await saveHomeFeed(me, [
        await photo(bob, 'saved-1'),
        await photo(bob, 'saved-2'),
      ]);
      relay.silent = true; // the network is as slow as it gets

      final c = app();
      c.listen(feedProvider(FeedMode.following), (_, _) {});
      await eventually(
        () => c.read(feedProvider(FeedMode.following)).posts.length == 2,
        timeout: const Duration(seconds: 2),
        reason: 'the saved posts waited for the network',
      );
      final state = c.read(feedProvider(FeedMode.following));
      expect(state.isLoading, false);
      expect(state.posts.map((p) => p.caption).toSet(), {'saved-1', 'saved-2'});
    },
  );

  test('what was saved for another account is not shown', () async {
    final other = newSigner();
    await saveHomeFeed(other, [await photo(bob, 'not-for-me')]);
    relay.silent = true;

    final c = app();
    c.listen(feedProvider(FeedMode.following), (_, _) {});
    await Future<void>.delayed(const Duration(milliseconds: 600));
    expect(c.read(feedProvider(FeedMode.following)).posts, isEmpty);
  });

  test(
    'the follow list is remembered, so it is usable before the relays',
    () async {
      relay.add(
        await signed(
          me,
          kind: 3,
          tags: [
            ['p', bob.publicKey],
          ],
        ),
      );
      final first = app();
      first.listen(followListProvider, (_, _) {});
      await first.read(followListProvider.notifier).ready;
      expect(first.read(followListProvider), {bob.publicKey});
      await Future<void>.delayed(const Duration(milliseconds: 300)); // saved

      // Next start, the relays do not answer at all.
      relay.silent = true;
      final second = app();
      second.listen(followListProvider, (_, _) {});
      await second
          .read(followListProvider.notifier)
          .usable
          .timeout(const Duration(seconds: 2));
      expect(second.read(followListProvider), {bob.publicKey});

      // Reading may use it; editing still waits for the real list.
      final ready = second.read(followListProvider.notifier).ready;
      var done = false;
      ready.then((_) => done = true);
      await Future<void>.delayed(const Duration(milliseconds: 200));
      expect(done, false);
    },
  );

  test('pull to refresh stops spinning after a few seconds even if a relay never answers', () async {
    await saveHomeFeed(me, [await photo(me, 'mine')]);
    relay.silent = true;
    final c = app();
    c.listen(feedProvider(FeedMode.following), (_, _) {});
    await eventually(
      () => c.read(feedProvider(FeedMode.following)).posts.isNotEmpty,
    );

    final watch = Stopwatch()..start();
    await c.read(feedProvider(FeedMode.following).notifier).refresh();
    expect(watch.elapsed, lessThan(const Duration(seconds: 7)));
    // The load itself goes on in the background.
    expect(c.read(feedProvider(FeedMode.following)).isRefreshing, true);
  });

  test('the account is restored before anything is asked as a guest', () async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    expect(c.read(authProvider).restoring, true);
    await c.read(authProvider.notifier).restore(); // no saved session here
    expect(c.read(authProvider).restoring, false);
    expect(c.read(authProvider).isGuest, true);
  });

  testWidgets(
    'Home does not start the Discover feed while the session is being read',
    (tester) async {
      final c = app(auth: AuthState(GuestSigner(), restoring: true));
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: c,
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const FeedScreen(),
          ),
        ),
      );
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 500)),
      );
      await tester.pump(const Duration(milliseconds: 500));
      expect(relay.reqCount, 0, reason: 'a guest feed was loaded for nothing');
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 40));
    },
  );
}
