import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mialuna/app/providers.dart';
import 'package:mialuna/core/auth/auth_controller.dart';
import 'package:mialuna/core/nostr/event.dart';
import 'package:mialuna/core/nostr/models/media_event.dart';
import 'package:mialuna/core/nostr/relay_pool.dart';
import 'package:mialuna/core/nostr/signer.dart';
import 'package:mialuna/core/storage/local_cache.dart';
import 'package:mialuna/features/feed/widgets/post_card.dart';
import 'package:mialuna/features/reels/reels_controller.dart';
import 'package:mialuna/features/reels/reels_screen.dart';
import 'package:mialuna/features/social/post_deletion.dart';
import 'package:mialuna/l10n/strings.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';

class _FixedAuth extends AuthController {
  final Signer signer;
  _FixedAuth(this.signer);
  @override
  AuthState build() => AuthState(signer);
}

class _Reels extends ReelsController {
  final List<MediaPost> fixed;
  _Reels(this.fixed);
  @override
  ReelsState build() => ReelsState(reels: fixed, isLoading: false);

  void show(List<MediaPost> next) =>
      state = ReelsState(reels: next, isLoading: false);
}

/// What the players of a screen have been through.
class _Players {
  int made = 0;
  int alive = 0;
  int mostAlive = 0;
  int playing = 0;

  /// Whether a player's `initialize()` answers: a slow connection never does.
  bool initializes = false;
  final List<Completer<void>> waiting = [];
}

/// A player that touches no platform: it only counts itself.
class _FakePlayer extends VideoPlayerController {
  final _Players log;
  bool _gone = false;
  _FakePlayer(this.log)
    : super.networkUrl(Uri.parse('https://x.example/v.mp4')) {
    log.made++;
    log.alive++;
    if (log.alive > log.mostAlive) log.mostAlive = log.alive;
  }

  @override
  Future<void> initialize() async {
    if (!log.initializes) {
      final never = Completer<void>();
      log.waiting.add(never);
      await never.future;
    }
    value = value.copyWith(
      isInitialized: true,
      duration: const Duration(seconds: 10),
      size: const Size(720, 1280),
    );
  }

  @override
  Future<void> setLooping(bool looping) async {}
  @override
  Future<void> setVolume(double volume) async {}
  @override
  Future<void> seekTo(Duration position) async {}
  @override
  Future<void> pause() async {
    if (value.isPlaying) log.playing--;
    value = value.copyWith(isPlaying: false);
  }

  @override
  Future<void> play() async {
    if (!value.isPlaying) log.playing++;
    value = value.copyWith(isPlaying: true);
  }

  @override
  Future<void> dispose() async {
    if (_gone) return;
    _gone = true;
    log.alive--;
    if (value.isPlaying) log.playing--;
    super.dispose();
  }
}

/// Stands in for deleting a post: records what it was asked.
class _Deletion implements PostDeletion {
  final List<MediaPost> calls = [];

  @override
  Future<DeletionReport> delete(MediaPost post) async {
    calls.add(post);
    return const DeletionReport();
  }
}

int _n = 0;

MediaPost _reel({String? author, String? warning}) {
  final id = '${++_n}'.padLeft(64, '0');
  return MediaPost.tryParse(
    NostrEvent(
      id: id,
      pubkey: author ?? 'ab' * 32,
      createdAt: 1700000000 + _n,
      kind: NostrKinds.shortVideo,
      tags: [
        [
          'imeta',
          'url https://x.example/$id.mp4',
          'm video/mp4',
          'dim 720x1280',
        ],
        if (warning != null) ['content-warning', warning],
      ],
      content: 'reel $_n',
      sig: '',
    ),
  )!;
}

/// The Reels screen holds a player (a hardware decoder and its buffers) for the
/// reel being watched and, once the viewer settles, the next one: no more.
/// Starting one for every reel swiped past used to end in an OutOfMemoryError.
void main() {
  late Directory tmp;
  late _Players log;
  late List<MediaPost> reels;
  late NsecSigner me;
  late _Deletion deletion;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    me = NsecSigner.fromNsec(NsecSigner.generatePrivateKey());
    deletion = _Deletion();
    tmp = Directory.systemTemp.createTempSync('mialuna_reels_');
    log = _Players();
    reels = [for (var i = 0; i < 15; i++) _reel()];
  });

  Future<ProviderContainer> pump(WidgetTester tester) async {
    tester.view.physicalSize = const Size(822, 1846);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    late ProviderContainer container;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          indexerRelaysProvider.overrideWithValue(const []),
          relayPoolProvider.overrideWithValue(RelayPool(const [])),
          localCacheProvider.overrideWithValue(LocalCache(directory: tmp)),
          authProvider.overrideWith(() => _FixedAuth(me)),
          postDeletionProvider.overrideWithValue(deletion),
          reelsProvider.overrideWith(() => _Reels(reels)),
          currentTabProvider.overrideWith((ref) => 3),
          reelPlayerFactoryProvider.overrideWithValue((_) => _FakePlayer(log)),
        ],
        child: Consumer(
          builder: (context, ref, _) {
            container = ProviderScope.containerOf(context);
            return MaterialApp(
              supportedLocales: AppLocalizations.supportedLocales,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              home: const ReelsScreen(),
            );
          },
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));
    return container;
  }

  Future<void> finish(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 40));
  }

  Future<void> swipeNext(WidgetTester tester) async {
    await tester.fling(find.byType(PageView), const Offset(0, -500), 2500);
    await tester.pump(const Duration(milliseconds: 120));
  }

  testWidgets(
    'swiping fast through slow-loading reels does not pile up players',
    (tester) async {
      await pump(tester);
      for (var i = 0; i < 10; i++) {
        await swipeNext(tester);
      }
      await tester.pump(const Duration(milliseconds: 500));

      expect(
        log.alive,
        lessThanOrEqualTo(2),
        reason: '${log.alive} players held at once, ${log.made} made',
      );
      expect(log.mostAlive, lessThanOrEqualTo(3));
      await finish(tester);
    },
  );

  testWidgets(
    'the reel being watched plays; the next is ready only once settled',
    (tester) async {
      log.initializes = true;
      await pump(tester);
      await tester.pump(const Duration(milliseconds: 100));
      expect(log.alive, 1, reason: 'only the one on screen at first');
      expect(log.playing, 1);

      await tester.pump(const Duration(seconds: 1)); // the viewer has settled
      expect(log.alive, 2, reason: 'the next one is made ready');
      expect(log.playing, 1, reason: 'but does not play');
      await finish(tester);
    },
  );

  testWidgets('moving on lets go of the previous reel', (tester) async {
    log.initializes = true;
    await pump(tester);
    await tester.pump(const Duration(seconds: 1));
    for (var i = 0; i < 3; i++) {
      await swipeNext(tester);
      await tester.pump(const Duration(seconds: 1));
    }
    expect(log.alive, lessThanOrEqualTo(2));
    expect(log.playing, 1);
    await finish(tester);
  });

  testWidgets('another tab: nothing is held', (tester) async {
    log.initializes = true;
    final c = await pump(tester);
    await tester.pump(const Duration(seconds: 1));
    expect(log.alive, greaterThan(0));

    c.read(currentTabProvider.notifier).state = 0;
    await tester.pump(const Duration(milliseconds: 100));
    expect(log.alive, 0);
    expect(log.playing, 0);
    await finish(tester);
  });

  group('the order on screen', () {
    test('new reels go to the end, not in front of the one being watched', () {
      final a = _reel(), b = _reel(), c = _reel(), fresh = _reel();
      final order = stableReelOrder([a, b, c], [fresh, a, b, c]);
      expect(order.map((r) => r.id), [a.id, b.id, c.id, fresh.id]);
    });

    test('reels that left are dropped, the rest keep their place', () {
      final a = _reel(), b = _reel(), c = _reel();
      expect(stableReelOrder([a, b, c], [c, a]).map((r) => r.id), [a.id, c.id]);
    });

    test('the first time, the order given', () {
      final a = _reel(), b = _reel();
      expect(stableReelOrder(const [], [b, a]).map((r) => r.id), [b.id, a.id]);
    });
  });

  testWidgets('your own reels have a delete button', (tester) async {
    reels = [_reel(author: me.publicKey), _reel(author: me.publicKey)];
    await pump(tester);

    expect(find.byIcon(Icons.delete_outline), findsWidgets);
    await finish(tester);
  });

  testWidgets('somebody else\'s reels have none', (tester) async {
    reels = [_reel(), _reel()];
    await pump(tester);

    expect(find.byIcon(Icons.delete_outline), findsNothing);
    await finish(tester);
  });

  testWidgets('deleting a reel asks, then deletes that reel', (tester) async {
    final mine = _reel(author: me.publicKey);
    reels = [mine, _reel()];
    await pump(tester);

    await tester.tap(find.byIcon(Icons.delete_outline));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Delete this post?'), findsOneWidget);
    await tester.tap(find.byType(FilledButton));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 500));

    expect(deletion.calls, [mine]);
    await finish(tester);
  });

  testWidgets('the pager carries on when the reel on screen disappears', (
    tester,
  ) async {
    reels = [for (var i = 0; i < 4; i++) _reel(author: me.publicKey)];
    final container = await pump(tester);
    expect(find.text(reels[0].caption), findsOneWidget);

    // What the list does once the reel on screen is deleted.
    (container.read(reelsProvider.notifier) as _Reels).show(reels.sublist(1));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 400));

    expect(tester.takeException(), isNull);
    expect(find.text(reels[0].caption), findsNothing);
    expect(find.text(reels[1].caption), findsOneWidget);
    expect(log.alive, lessThanOrEqualTo(2));
    await finish(tester);
  });

  testWidgets(
    'a reel with a content warning stays covered and loads nothing until shown',
    (tester) async {
      log.initializes = true;
      reels = [_reel(warning: 'nudity'), _reel()];
      await pump(tester);
      expect(find.text('nudity'), findsOneWidget);
      expect(log.made, 0);

      await tester.tap(
        find.descendant(
          of: find.byType(SensitiveCover),
          matching: find.byType(OutlinedButton),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('nudity'), findsNothing);
      expect(log.made, 1);
      expect(log.playing, 1);
      await finish(tester);
    },
  );
}
