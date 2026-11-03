import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mialuna/app/providers.dart';
import 'package:mialuna/core/auth/auth_controller.dart';
import 'package:mialuna/core/nostr/event.dart';
import 'package:mialuna/core/nostr/relay_pool.dart';
import 'package:mialuna/core/nostr/signer.dart';
import 'package:mialuna/core/storage/local_cache.dart';
import 'package:mialuna/features/feed/feed_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../support/fake_relay.dart';

class _FixedAuth extends AuthController {
  final Signer signer;
  _FixedAuth(this.signer);
  @override
  AuthState build() => AuthState(signer);
}

NsecSigner newSigner() => NsecSigner.fromNsec(NsecSigner.generatePrivateKey());

Future<NostrEvent> photo(Signer s, String text) => signed(
  s,
  kind: 20,
  content: text,
  tags: [
    [
      'imeta',
      'url https://cdn.example.com/${text.hashCode.abs()}.jpg',
      'm image/jpeg',
      'dim 800x1000',
    ],
  ],
);

/// Home must follow whom you follow, and a pull-to-refresh must bring what is
/// new — without the list being rebuilt when nothing changed.
void main() {
  late FakeRelay relay;
  late NsecSigner me;
  late Directory tmp;

  ProviderContainer app() {
    final c = ProviderContainer(
      overrides: [
        authProvider.overrideWith(() => _FixedAuth(me)),
        indexerRelaysProvider.overrideWithValue(const []),
        localCacheProvider.overrideWithValue(LocalCache(directory: tmp)),
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

  Future<void> follows(List<Signer> people, {int age = 100}) async =>
      relay.push(
        await signed(
          me,
          kind: 3,
          createdAt: DateTime.now().millisecondsSinceEpoch ~/ 1000 - age,
          tags: [
            for (final p in people) ['p', p.publicKey!],
          ],
        ),
      );

  List<String> shown(ProviderContainer c) => [
    for (final p in c.read(feedProvider(FeedMode.following)).posts) p.caption,
  ];

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    relay = await FakeRelay().start();
    me = newSigner();
    tmp = Directory.systemTemp.createTempSync('mialuna_refresh_');
  });

  tearDown(() => relay.stop());

  test('swapping one followed account for another refreshes Home', () async {
    final bob = newSigner();
    final carol = newSigner();
    relay.add(await photo(bob, 'di bob'));
    relay.add(await photo(carol, 'di carol'));
    await follows([bob], age: 200);
    final c = app();
    c.listen(feedProvider(FeedMode.following), (_, _) {});
    await eventually(
      () => shown(c).contains('di bob'),
      timeout: const Duration(seconds: 20),
    );
    // Later, not while the first load is still running (that case was
    // already handled).
    final feed = c.read(feedProvider(FeedMode.following).notifier);
    await feed.whenIdle();
    await Future<void>.delayed(const Duration(milliseconds: 500));
    await feed.whenIdle();

    // Same number of people, a different one.
    await follows([carol]);
    await eventually(
      () => shown(c).contains('di carol'),
      timeout: const Duration(seconds: 20),
      reason: 'Home kept the old follow list',
    );
    expect(shown(c), isNot(contains('di bob')));
  });

  test('a refresh after the phone slept brings the new posts', () async {
    final bob = newSigner();
    relay.add(await photo(bob, 'prima'));
    await follows([bob]);
    final c = app();
    c.listen(feedProvider(FeedMode.following), (_, _) {});
    await eventually(
      () => shown(c).contains('prima'),
      timeout: const Duration(seconds: 20),
    );

    relay.freezeConnections();
    relay.add(await photo(bob, 'dopo'));
    // What Home does on pull-to-refresh.
    await c
        .read(relayPoolProvider)
        .wake(quiet: Duration.zero, timeout: const Duration(milliseconds: 500));
    await c.read(feedProvider(FeedMode.following).notifier).refresh();
    await eventually(() => shown(c).contains('dopo'));
  });

  test('nothing new, no new list: the screen is not rebuilt', () async {
    final bob = newSigner();
    relay.add(await photo(bob, 'una'));
    await follows([bob]);
    final c = app();
    var emissions = 0;
    c.listen(feedProvider(FeedMode.following), (_, _) => emissions++);
    await eventually(
      () => shown(c).contains('una'),
      timeout: const Duration(seconds: 20),
    );
    await c.read(feedProvider(FeedMode.following).notifier).whenIdle();
    await Future<void>.delayed(const Duration(milliseconds: 500));

    final before = emissions;
    // Something the feed listens to changes, without affecting any post.
    c.read(brokenMediaProvider.notifier).state = {'f' * 64};
    await Future<void>.delayed(const Duration(milliseconds: 100));
    expect(emissions, before);
  });
}
