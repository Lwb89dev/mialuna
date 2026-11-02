import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mialuna/app/providers.dart';
import 'package:mialuna/core/auth/auth_controller.dart';
import 'package:mialuna/core/nostr/relay_pool.dart';
import 'package:mialuna/core/nostr/signer.dart';
import 'package:mialuna/core/storage/local_cache.dart';
import 'package:mialuna/core/theme/mialuna_theme.dart';
import 'package:mialuna/features/stories/stories_controller.dart';
import 'package:mialuna/features/stories/stories_rail.dart';
import 'package:mialuna/features/stories/story_ring.dart';
import 'package:mialuna/l10n/strings.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../support/story_fixtures.dart';

class _FixedAuth extends AuthController {
  final Signer signer;
  _FixedAuth(this.signer);
  @override
  AuthState build() => AuthState(signer);
}

class _Stories extends StoriesController {
  final List<StoryGroup> groups;
  _Stories(this.groups);
  @override
  StoriesState build() => StoriesState(groups: groups, isLoading: false);
}

final _me = NsecSigner.fromNsec(NsecSigner.generatePrivateKey());
final _ana = 'a1' * 32;
final _bruno = 'b2' * 32;
final _carla = 'c3' * 32;

void main() {
  late Directory tmp;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    tmp = Directory.systemTemp.createTempSync('mialuna_rail_');
  });

  group('storyRingArcs', () {
    test('a single story is a whole ring', () {
      final arcs = storyRingArcs(1);
      expect(arcs, hasLength(1));
      expect(arcs.single.sweep, closeTo(2 * math.pi, 1e-9));
    });

    test('n stories divide the ring into n equal parts', () {
      for (final n in [2, 3, 4, 5, 8, 20]) {
        final arcs = storyRingArcs(n);
        expect(arcs, hasLength(n));
        final sweep = arcs.first.sweep;
        for (final a in arcs) {
          expect(a.sweep, closeTo(sweep, 1e-9), reason: 'equal parts');
          expect(a.sweep, greaterThan(0));
        }
        // Parts follow each other round the circle, with the same gap.
        final part = 2 * math.pi / n;
        for (var i = 0; i < n; i++) {
          expect(
            arcs[i].start - arcs.first.start,
            closeTo(part * i, 1e-9),
            reason: 'part $i starts one part after the previous',
          );
        }
        expect(sweep, lessThan(part), reason: 'a gap separates the parts');
      }
    });

    test('the first story starts at the top, running clockwise', () {
      final arcs = storyRingArcs(4);
      // Its middle is half a part past twelve o'clock.
      final middle = arcs.first.start + arcs.first.sweep / 2;
      expect(middle, closeTo(-math.pi / 2 + math.pi / 4, 1e-9));
    });

    test('a crowd of stories keeps every part visible', () {
      final arcs = storyRingArcs(60);
      expect(arcs, hasLength(60));
      expect(arcs.every((a) => a.sweep > 0.01), true);
    });

    test('nobody, no ring', () => expect(storyRingArcs(0), isEmpty));
  });

  group('StoriesRailModel', () {
    test('own stories lead, then unseen creators, then seen ones', () {
      final mine = storiesOf(_me.publicKey, 2);
      final ana = storiesOf(_ana, 1);
      final bruno = storiesOf(_bruno, 1);
      final carla = storiesOf(_carla, 1);
      final model = StoriesRailModel.of(
        groups: [ana, bruno, mine, carla],
        me: _me.publicKey,
        seen: {for (final s in ana.stories) s.id},
      );
      expect(model.own, mine);
      expect(model.playlist.map((g) => g.author), [
        _me.publicKey,
        _bruno,
        _carla,
        _ana,
      ]);
    });

    test('a guest has no button and no stories of their own', () {
      final model = StoriesRailModel.of(
        groups: [storiesOf(_ana, 1)],
        me: null,
        seen: const {},
      );
      expect(model.canPost, false);
      expect(model.own, isNull);
      expect(model.isEmpty, false);
      expect(
        StoriesRailModel.of(groups: const [], me: null, seen: const {}).isEmpty,
        true,
      );
    });
  });

  group('StoriesRail', () {
    /// Lets the profile requests' timers run out, so none is left pending.
    Future<void> finish(WidgetTester tester) async {
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 40));
    }

    Future<void> pump(
      WidgetTester tester,
      List<StoryGroup> groups, {
      Signer? as,
      Set<String> seen = const {},
      bool dark = false,
    }) async {
      SharedPreferences.setMockInitialValues({
        if (seen.isNotEmpty) 'mialuna_seen_stories': seen.toList(),
      });
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            indexerRelaysProvider.overrideWithValue(const []),
            relayPoolProvider.overrideWithValue(RelayPool(const [])),
            localCacheProvider.overrideWithValue(LocalCache(directory: tmp)),
            authProvider.overrideWith(() => _FixedAuth(as ?? _me)),
            storiesProvider.overrideWith(() => _Stories(groups)),
          ],
          child: MaterialApp(
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            theme: dark ? MialunaTheme.dark() : MialunaTheme.light(),
            home: const Scaffold(body: StoriesRail()),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));
    }

    List<StoryRing> rings(WidgetTester tester) =>
        tester.widgetList<StoryRing>(find.byType(StoryRing)).toList();

    testWidgets('the story button is there even with nothing to watch', (
      tester,
    ) async {
      await pump(tester, const []);

      expect(find.text('Your story'), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
      expect(rings(tester), isEmpty, reason: 'nothing published yet');
      await finish(tester);
    });

    testWidgets('after publishing, a second circle shows your stories', (
      tester,
    ) async {
      await pump(tester, [storiesOf(_me.publicKey, 3), storiesOf(_ana, 1)]);

      // The button stays, as "new story"; your circle is the second one.
      expect(find.text('New story'), findsOneWidget);
      expect(find.text('Your story'), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
      expect(rings(tester), hasLength(2), reason: 'yours and Ana\'s');
      expect(rings(tester).first.segments, hasLength(3));
      expect(
        tester.getTopLeft(find.text('New story')).dx,
        lessThan(tester.getTopLeft(find.text('Your story')).dx),
        reason: 'the button comes first',
      );
      await finish(tester);
    });

    testWidgets('a ring has one part per story, new ones coloured', (
      tester,
    ) async {
      final ana = storiesOf(_ana, 4);
      await pump(tester, [ana], seen: {ana.stories[0].id, ana.stories[1].id});

      final segments = rings(tester).single.segments;
      expect(segments, hasLength(4));
      expect(segments, [
        StorySegment.seen,
        StorySegment.seen,
        StorySegment.unseen,
        StorySegment.unseen,
      ]);
      await finish(tester);
    });

    testWidgets('a close-friends story has a green part', (tester) async {
      final ana = StoryGroup(
        author: _ana,
        stories: [story(_ana), story(_ana, private: true)],
      );
      await pump(tester, [ana]);

      final segments = rings(tester).single.segments;
      expect(segments, [StorySegment.unseen, StorySegment.closeFriends]);
      await finish(tester);
    });

    testWidgets('people with new stories come before the ones you saw', (
      tester,
    ) async {
      final ana = storiesOf(_ana, 1);
      final bruno = storiesOf(_bruno, 1);
      await pump(tester, [ana, bruno], seen: {ana.stories.single.id});

      final all = rings(tester);
      expect(all, hasLength(2));
      expect(all.first.segments.single, StorySegment.unseen);
      expect(all.last.segments.single, StorySegment.seen);
      await finish(tester);
    });

    testWidgets('a guest sees others\' stories but cannot start one', (
      tester,
    ) async {
      await pump(tester, [storiesOf(_ana, 1)], as: GuestSigner());

      expect(find.byIcon(Icons.add), findsNothing);
      expect(rings(tester), hasLength(1));
      await finish(tester);
    });

    testWidgets('a guest with nothing to watch sees nothing', (tester) async {
      await pump(tester, const [], as: GuestSigner());

      expect(find.byType(StoryRing), findsNothing);
      expect(find.byIcon(Icons.add), findsNothing);
      await finish(tester);
    });

    testWidgets('the plus opens the story composer', (tester) async {
      await pump(tester, const []);

      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      // The gallery cannot open in a test: the three sources are offered.
      expect(
        find.text('Choose a photo or a video for your story'),
        findsOneWidget,
      );
      await finish(tester);
    });

    testWidgets('the rail fits in the dark theme and with huge text', (
      tester,
    ) async {
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.platformDispatcher.clearAllTestValues);
      await pump(tester, [
        storiesOf(_me.publicKey, 2),
        storiesOf(_ana, 5),
      ], dark: true);
      expect(tester.takeException(), isNull);
      await finish(tester);
    });
  });
}
