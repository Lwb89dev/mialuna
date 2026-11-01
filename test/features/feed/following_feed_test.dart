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
    ['title', text],
  ],
);

void main() {
  late FakeRelay relay;
  late NsecSigner me;
  late NsecSigner bob; // followed
  late NsecSigner carol; // not followed
  late Directory tmp;

  ProviderContainer app(Signer signer) {
    final c = ProviderContainer(
      overrides: [
        authProvider.overrideWith(() => _FixedAuth(signer)),
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

  Future<FeedState> settled(ProviderContainer c, FeedMode mode) async {
    c.listen(feedProvider(mode), (_, _) {});
    await eventually(
      () => !c.read(feedProvider(mode)).isLoading,
      timeout: const Duration(seconds: 20),
    );
    return c.read(feedProvider(mode));
  }

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    relay = await FakeRelay().start();
    me = newSigner();
    bob = newSigner();
    carol = newSigner();
    tmp = Directory.systemTemp.createTempSync('mialuna_feed_');
    relay.add(
      await signed(
        me,
        kind: 3,
        tags: [
          ['p', bob.publicKey],
        ],
      ),
    );
  });

  tearDown(() => relay.stop());

  test('Home shows only the people you follow (and you)', () async {
    relay.add(await photo(bob, 'bob-post'));
    relay.add(await photo(carol, 'carol-post'));
    relay.add(await photo(me, 'my-post'));

    final c = app(me);
    final state = await settled(c, FeedMode.following);
    expect(state.posts.map((p) => p.caption).toSet(), {'bob-post', 'my-post'});
    expect(state.posts.any((p) => p.author == carol.publicKey), false);
  });

  test('Discover shows everyone', () async {
    relay.add(await photo(bob, 'bob-post'));
    relay.add(await photo(carol, 'carol-post'));

    final c = app(me);
    final state = await settled(c, FeedMode.discover);
    expect(state.posts.map((p) => p.caption).toSet(), {
      'bob-post',
      'carol-post',
    });
  });

  test(
    'posts newer than the list are merged on refresh, without losing others',
    () async {
      relay.add(await photo(bob, 'first'));
      final c = app(me);
      await settled(c, FeedMode.following);
      expect(c.read(feedProvider(FeedMode.following)).posts, hasLength(1));

      relay.add(await photo(bob, 'second'));
      await c.read(feedProvider(FeedMode.following).notifier).refresh();
      final posts = c.read(feedProvider(FeedMode.following)).posts;
      expect(posts.map((p) => p.caption).toSet(), {'first', 'second'});
      expect(c.read(feedProvider(FeedMode.following)).isRefreshing, false);
    },
  );

  test('an account that follows nobody gets a clear empty state', () async {
    final loner = newSigner();
    relay.add(await photo(carol, 'carol-post'));
    final c = app(loner);
    final state = await settled(c, FeedMode.following);
    expect(state.followsNobody, true);
    expect(state.posts, isEmpty);
  });

  test('following someone adds their posts to Home', () async {
    final dave = newSigner();
    relay.add(await photo(dave, 'dave-post'));
    final c = app(me);
    await settled(c, FeedMode.following);
    expect(c.read(feedProvider(FeedMode.following)).posts, isEmpty);

    // The follow button publishes a newer kind 3.
    relay.push(
      await signed(
        me,
        kind: 3,
        createdAt: DateTime.now().millisecondsSinceEpoch ~/ 1000 + 5,
        tags: [
          ['p', bob.publicKey],
          ['p', dave.publicKey],
        ],
      ),
    );
    await eventually(
      () => c
          .read(feedProvider(FeedMode.following))
          .posts
          .any((p) => p.caption == 'dave-post'),
      reason: 'the new follow never reached the feed',
    );
  });

  test('stories, expired and unusable posts never appear', () async {
    relay.add(
      await signed(
        bob,
        kind: 20,
        content: 'story',
        tags: [
          ['imeta', 'url https://cdn.example.com/s.jpg', 'm image/jpeg'],
          ['L', 'mialuna.story'],
          ['l', 'story', 'mialuna.story'],
        ],
      ),
    );
    relay.add(
      await signed(
        bob,
        kind: 20,
        content: 'yt',
        tags: [
          ['imeta', 'url https://www.youtube.com/watch?v=abc'],
        ],
      ),
    );
    relay.add(await photo(bob, 'ok'));
    final c = app(me);
    final state = await settled(c, FeedMode.following);
    expect(state.posts.map((p) => p.caption), ['ok']);
  });
}
