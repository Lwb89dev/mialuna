import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mialuna/app/providers.dart';
import 'package:mialuna/core/auth/auth_controller.dart';
import 'package:mialuna/core/nostr/event.dart';
import 'package:mialuna/core/nostr/models/media_event.dart';
import 'package:mialuna/core/nostr/relay_pool.dart';
import 'package:mialuna/core/nostr/signer.dart';
import 'package:mialuna/core/storage/local_cache.dart';
import 'package:mialuna/features/explore/explore_screen.dart'
    show PostThumbnail;
import 'package:mialuna/features/feed/feed_controller.dart';
import 'package:mialuna/features/profile/profile_screen.dart';
import 'package:mialuna/features/reels/reels_controller.dart';
import 'package:mialuna/features/social/deleted_posts.dart';
import 'package:mialuna/features/stories/stories_controller.dart';
import 'package:mialuna/l10n/strings.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../support/fake_relay.dart';
import '../../support/story_harness.dart';

class _FixedAuth extends AuthController {
  final Signer signer;
  _FixedAuth(this.signer);
  @override
  AuthState build() => AuthState(signer);
}

/// A relay that ignores deletion requests keeps handing the post out. A post
/// the user deleted must stay out of every list anyway.
void main() {
  late FakeRelay relay;
  late NsecSigner me;
  late Directory tmp;

  Future<NostrEvent> photo(String text, {int? at}) => signed(
    me,
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

  Future<NostrEvent> reel(String text) => signed(
    me,
    kind: 22,
    content: text,
    tags: [
      [
        'imeta',
        'url https://cdn.example.com/${text.hashCode.abs()}.mp4',
        'm video/mp4',
        'dim 1080x1920',
      ],
    ],
  );

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

  Future<List<String>> home(ProviderContainer c) async {
    c.listen(feedProvider(FeedMode.following), (_, _) {});
    await eventually(
      () => !c.read(feedProvider(FeedMode.following)).isLoading,
      timeout: const Duration(seconds: 20),
    );
    return [
      for (final p in c.read(feedProvider(FeedMode.following)).posts) p.caption,
    ];
  }

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    relay = await FakeRelay().start();
    me = NsecSigner.fromNsec(NsecSigner.generatePrivateKey());
    tmp = Directory.systemTemp.createTempSync('mialuna_hide_');
    // Home shows an account that follows somebody (here: somebody else).
    relay.add(
      await signed(
        me,
        kind: 3,
        tags: [
          ['p', NsecSigner.fromNsec(NsecSigner.generatePrivateKey()).publicKey],
        ],
      ),
    );
    addTearDown(() => tmp.deleteSync(recursive: true));
    addTearDown(relay.stop);
  });

  test(
    'Home drops a deleted post, and a relay that serves it again cannot bring it back',
    () async {
      final keep = await photo('keep', at: 1700000100);
      final gone = await photo('gone', at: 1700000200);
      relay.add(keep);
      relay.add(gone);
      final c = app();
      expect(await home(c), ['gone', 'keep']);

      c.read(deletedPostsProvider.notifier).add([gone.id]);
      expect(
        c.read(feedProvider(FeedMode.following)).posts.map((p) => p.caption),
        ['keep'],
      );

      // The relay never deleted it: a refresh asks for it once more.
      await c.read(feedProvider(FeedMode.following).notifier).refresh();
      expect(
        c.read(feedProvider(FeedMode.following)).posts.map((p) => p.caption),
        ['keep'],
      );
    },
  );

  test(
    'a post saved on the phone before it was deleted does not come back at start',
    () async {
      final gone = await photo('gone');
      relay.add(gone);
      final first = app();
      expect(await home(first), ['gone']);
      final feed = first.read(feedProvider(FeedMode.following).notifier);
      await feed.persistCache();
      first.read(deletedPostsProvider.notifier).add([gone.id]);
      await Future<void>.delayed(const Duration(milliseconds: 200));
      first.dispose();

      // The next run reads the saved Home first, before any relay answers.
      await relay.stop();
      relay = await FakeRelay().start();
      final second = app();
      second.listen(feedProvider(FeedMode.following), (_, _) {});
      await Future<void>.delayed(const Duration(seconds: 1));

      expect(second.read(feedProvider(FeedMode.following)).posts, isEmpty);
    },
  );

  test('Reels drops a deleted reel', () async {
    final keep = await reel('keep');
    final gone = await reel('gone');
    relay.add(keep);
    relay.add(gone);
    final c = app();
    c.listen(reelsProvider, (_, _) {});
    await eventually(() => c.read(reelsProvider).reels.length == 2);

    c.read(deletedPostsProvider.notifier).add([gone.id]);

    expect(c.read(reelsProvider).reels.map((r) => r.caption), ['keep']);
    await c.read(reelsProvider.notifier).refresh();
    expect(c.read(reelsProvider).reels.map((r) => r.caption), ['keep']);
  });

  test('the story rail drops a deleted story', () async {
    final harness = StoryHarness(relay);
    final c = harness.app(me);
    c.listen(storiesProvider, (_, _) {});
    final story = await harness.publish(c, me, 'tonight');
    await eventually(() => c.read(storiesProvider).groups.isNotEmpty);

    c.read(deletedPostsProvider.notifier).add([story.id]);

    await eventually(() => c.read(storiesProvider).groups.isEmpty);
  });

  testWidgets('the profile grid drops a deleted post', (tester) async {
    // Pictures are cached on disk: give the cache a place, nothing more.
    const channel = MethodChannel('plugins.flutter.io/path_provider');
    final messenger = tester.binding.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(channel, (_) async => tmp.path);
    addTearDown(() => messenger.setMockMethodCallHandler(channel, null));
    final events = (await tester.runAsync(
      () async => [
        await photo('one', at: 1700000100),
        await photo('two', at: 1700000200),
        await photo('three', at: 1700000300),
      ],
    ))!;
    final posts = [for (final e in events) MediaPost.tryParse(e)!];
    tester.view.physicalSize = const Size(822, 1846);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authProvider.overrideWith(() => _FixedAuth(me)),
          indexerRelaysProvider.overrideWithValue(const []),
          localCacheProvider.overrideWithValue(LocalCache(directory: tmp)),
          relayPoolProvider.overrideWithValue(RelayPool(const [])),
          userPostsProvider.overrideWith((ref, pubkey) => Stream.value(posts)),
        ],
        child: MaterialApp(
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: const ProfileScreen(),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byType(PostThumbnail), findsNWidgets(3));

    final container = ProviderScope.containerOf(
      tester.element(find.byType(ProfileScreen)),
    );
    container.read(deletedPostsProvider.notifier).add([events[1].id]);
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byType(PostThumbnail), findsNWidgets(2));
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 40));
  });
}
