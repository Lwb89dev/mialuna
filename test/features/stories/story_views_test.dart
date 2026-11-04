import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mialuna/app/providers.dart';
import 'package:mialuna/core/auth/auth_controller.dart';
import 'package:mialuna/core/nostr/event.dart';
import 'package:mialuna/core/nostr/models/media_event.dart';
import 'package:mialuna/core/nostr/nip59.dart';
import 'package:mialuna/core/nostr/relay_pool.dart';
import 'package:mialuna/core/nostr/signer.dart';
import 'package:mialuna/core/storage/local_cache.dart';
import 'package:mialuna/features/messages/dm_controller.dart';
import 'package:mialuna/features/social/moderation_controller.dart';
import 'package:mialuna/features/stories/stories_controller.dart';
import 'package:mialuna/features/stories/story_receipts.dart';
import 'package:mialuna/features/stories/story_views.dart';
import 'package:mialuna/features/stories/story_views_sheet.dart';
import 'package:mialuna/l10n/strings.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../support/fake_relay.dart';

class _FixedAuth extends AuthController {
  final Signer signer;
  _FixedAuth(this.signer);
  @override
  AuthState build() => AuthState(signer);
}

class _FakeViews extends StoryViewsController {
  final StoryViewsState fixed;
  _FakeViews(this.fixed);
  @override
  StoryViewsState build() => fixed;
}

NsecSigner newSigner() => NsecSigner.fromNsec(NsecSigner.generatePrivateKey());

/// Who watched your stories: a message from the viewer to the author, nothing
/// to Blossom, nothing a relay can read.
void main() {
  late FakeRelay relay;
  late NsecSigner alice; // the author
  late NsecSigner bob; // a viewer
  late NsecSigner carol; // another viewer

  ProviderContainer app(Signer signer, {Directory? dir}) {
    final cache = dir ?? Directory.systemTemp.createTempSync('mialuna_views_');
    final c = ProviderContainer(
      overrides: [
        authProvider.overrideWith(() => _FixedAuth(signer)),
        indexerRelaysProvider.overrideWithValue(const []),
        localCacheProvider.overrideWithValue(LocalCache(directory: cache)),
        relayPoolProvider.overrideWith((ref) {
          final pool = RelayPool([RelayConfig(relay.url)]);
          pool.authSigner = (url, challenge) => signer.signEvent(
            kind: NostrKinds.clientAuth,
            tags: [
              ['relay', url],
              ['challenge', challenge],
            ],
            content: '',
          );
          ref.onDispose(pool.dispose);
          return pool;
        }),
      ],
    );
    addTearDown(c.dispose);
    return c;
  }

  Future<ProviderContainer> online(Signer signer, {Directory? dir}) async {
    final c = app(signer, dir: dir);
    c.listen(dmProvider, (_, _) {});
    c.listen(storyViewsProvider, (_, _) {});
    await eventually(() => c.read(dmProvider).inboxConfigured == true);
    return c;
  }

  /// A story by Alice. Given her app, it is also in her rail, as it is the
  /// moment she publishes it — which is what makes a receipt for it count.
  Future<MediaPost> story(String text, [ProviderContainer? aliceApp]) async {
    final event = await signed(
      alice,
      kind: NostrKinds.picture,
      content: text,
      tags: [
        [
          'imeta',
          'url https://cdn.example.com/${text.hashCode.abs()}.jpg',
          'm image/jpeg',
        ],
        ['L', 'mialuna.story'],
        ['l', 'story', 'mialuna.story'],
        [
          'expiration',
          '${DateTime.now().millisecondsSinceEpoch ~/ 1000 + 86400}',
        ],
      ],
    );
    aliceApp?.read(storiesProvider.notifier).addPublished(event);
    return MediaPost.tryParse(event)!;
  }

  int wraps() =>
      relay.stored.where((e) => e.kind == NostrKinds.giftWrap).length;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    relay = await FakeRelay(authKinds: {1059}).start();
    alice = newSigner();
    bob = newSigner();
    carol = newSigner();
    for (final s in [alice, bob, carol]) {
      relay.add(
        await signed(
          s,
          kind: NostrKinds.dmRelayList,
          tags: [
            ['relay', relay.url],
          ],
        ),
      );
    }
  });

  tearDown(() => relay.stop());

  group('watching', () {
    test('tells the author, and only the author', () async {
      final a = await online(alice);
      final b = await online(bob);
      final s = await story('tramonto', a);

      final reporter = b.read(storyViewReporterProvider);
      await reporter.viewed(s);
      expect(wraps(), 0, reason: 'nothing is sent while the story plays');
      await reporter.flush();

      await eventually(
        () => a.read(storyViewsProvider).countOf(s.id) == 1,
        reason: 'the author never heard',
      );
      final viewer = a.read(storyViewsProvider).of(s.id).single;
      expect(viewer.pubkey, bob.publicKey);

      // The relay saw one gift wrap from a throw-away key: no names, no ids.
      expect(wraps(), 1);
      final dump = jsonEncode(relay.stored.map((e) => e.toJson()).toList());
      expect(dump, isNot(contains(s.id)));
      for (final w in relay.stored.where(
        (e) => e.kind == NostrKinds.giftWrap,
      )) {
        expect(w.pubkey, isNot(anyOf(alice.publicKey, bob.publicKey)));
        expect(w.firstTagValue('p'), alice.publicKey);
      }
    });

    test('one message per author, however many stories', () async {
      final a = await online(alice);
      final b = await online(bob);
      final stories = [
        await story('uno', a),
        await story('due', a),
        await story('tre', a),
      ];
      final reporter = b.read(storyViewReporterProvider);
      for (final s in stories) {
        await reporter.viewed(s);
      }
      await reporter.flush();

      await eventually(
        () =>
            stories.every((s) => a.read(storyViewsProvider).countOf(s.id) == 1),
      );
      expect(wraps(), 1, reason: 'a signer round trip per story would be rude');
    });

    test('a story already reported is not reported again', () async {
      final b = await online(bob);
      final s = await story('ancora');
      final reporter = b.read(storyViewReporterProvider);
      await reporter.viewed(s);
      await reporter.flush();
      expect(wraps(), 1);

      await reporter.viewed(s);
      await reporter.flush();
      expect(wraps(), 1);
    });

    test('with the switch off, nothing leaves the phone', () async {
      final b = await online(bob);
      await b.read(storyViewReceiptsProvider.notifier).set(false);
      final reporter = b.read(storyViewReporterProvider);
      await reporter.viewed(await story('in incognito'));
      await reporter.flush();
      expect(wraps(), 0);
    });

    test('on by default, and the choice is remembered', () async {
      final b = app(bob);
      expect(b.read(storyViewReceiptsProvider), true);
      await b.read(storyViewReceiptsProvider.notifier).set(false);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('mialuna_send_story_views'), false);
    });

    test('your own stories and guests report nothing', () async {
      final a = await online(alice);
      final reporter = a.read(storyViewReporterProvider);
      await reporter.viewed(await story('mia'));
      await reporter.flush();
      expect(wraps(), 0);

      final guest = app(GuestSigner());
      final g = guest.read(storyViewReporterProvider);
      await g.viewed(await story('di alice'));
      await g.flush();
      expect(wraps(), 0);
    });
  });

  group('being watched', () {
    test('lists each viewer once, most recent first', () async {
      final a = await online(alice);
      final b = await online(bob);
      final c = await online(carol);
      final s = await story('chi guarda', a);

      await b.read(storyViewReporterProvider).viewed(s);
      await b.read(storyViewReporterProvider).flush();
      await eventually(() => a.read(storyViewsProvider).countOf(s.id) == 1);
      await Future<void>.delayed(const Duration(milliseconds: 1100));
      await c.read(storyViewReporterProvider).viewed(s);
      await c.read(storyViewReporterProvider).flush();
      await eventually(() => a.read(storyViewsProvider).countOf(s.id) == 2);

      expect(a.read(storyViewsProvider).of(s.id).map((v) => v.pubkey), [
        carol.publicKey,
        bob.publicKey,
      ]);
    });

    test('somebody you blocked is not counted', () async {
      final a = await online(alice);
      await a.read(blockProvider.notifier).block(bob.publicKey);
      final b = await online(bob);
      final c = await online(carol);
      final s = await story('bloccati', a);

      await b.read(storyViewReporterProvider).viewed(s);
      await b.read(storyViewReporterProvider).flush();
      await c.read(storyViewReporterProvider).viewed(s);
      await c.read(storyViewReporterProvider).flush();

      await eventually(() => a.read(storyViewsProvider).countOf(s.id) >= 1);
      expect(a.read(storyViewsProvider).of(s.id).map((v) => v.pubkey), [
        carol.publicKey,
      ]);
    });

    test('receipts are kept across a restart', () async {
      final dir = Directory.systemTemp.createTempSync('mialuna_views_keep_');
      final a = await online(alice, dir: dir);
      final b = await online(bob);
      final s = await story('resta', a);
      await b.read(storyViewReporterProvider).viewed(s);
      await b.read(storyViewReporterProvider).flush();
      await eventually(() => a.read(storyViewsProvider).countOf(s.id) == 1);
      await Future<void>.delayed(const Duration(seconds: 3)); // saved

      relay.stored.removeWhere((e) => e.kind == NostrKinds.giftWrap);
      final again = app(alice, dir: dir);
      again.listen(storyViewsProvider, (_, _) {});
      await eventually(() => again.read(storyViewsProvider).countOf(s.id) == 1);
    });

    Rumor receipt(Signer from, {required List<List<String>> tags, int? at}) =>
        Rumor.create(
          pubkey: from.publicKey!,
          kind: NostrKinds.storyView,
          tags: tags,
          content: '',
          createdAt: at,
        );

    test('only receipts addressed to you count, and never your own', () async {
      final a = app(alice);
      a.listen(storyViewsProvider, (_, _) {});
      final mine = await story('mia', a);
      final id = mine.id;
      final ctl = a.read(storyViewsProvider.notifier);
      await Future<void>.delayed(const Duration(milliseconds: 50));
      await pumpEventQueue();

      // Addressed to somebody else.
      expect(
        ctl.ingest(
          receipt(
            bob,
            tags: [
              ['e', id],
              ['p', carol.publicKey],
            ],
          ),
        ),
        false,
      );
      // From yourself.
      expect(
        ctl.ingest(
          receipt(
            alice,
            tags: [
              ['e', id],
              ['p', alice.publicKey],
            ],
          ),
        ),
        false,
      );
      // Another kind.
      expect(
        ctl.ingest(
          Rumor.create(
            pubkey: bob.publicKey,
            kind: NostrKinds.chatMessage,
            tags: [
              ['e', id],
              ['p', alice.publicKey],
            ],
            content: '',
          ),
        ),
        false,
      );
      // A malformed story id.
      expect(
        ctl.ingest(
          receipt(
            bob,
            tags: [
              ['e', 'short'],
              ['p', alice.publicKey],
            ],
          ),
        ),
        false,
      );
      expect(a.read(storyViewsProvider).byStory, isEmpty);

      expect(
        ctl.ingest(
          receipt(
            bob,
            tags: [
              ['e', id],
              ['p', alice.publicKey],
            ],
          ),
        ),
        true,
      );
      expect(a.read(storyViewsProvider).countOf(id), 1);
    });

    test(
      'a receipt cannot come from the future, nor list endless stories',
      () async {
        final a = app(alice);
        a.listen(storyViewsProvider, (_, _) {});
        final ctl = a.read(storyViewsProvider.notifier);
        await Future<void>.delayed(const Duration(milliseconds: 50));
        final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
        final stories = [for (var i = 0; i < 100; i++) await story('s$i', a)];
        // The rail tells the views controller which stories are Alice's a
        // moment after they are added: let that happen before the receipt.
        await pumpEventQueue();

        ctl.ingest(
          receipt(
            bob,
            at: now + 100000,
            tags: [
              for (final s in stories) ['e', s.id],
              ['p', alice.publicKey],
            ],
          ),
        );
        // Signing a hundred stories can take seconds on a slow machine: the
        // receipt is held to the time it was read, not to the time before.
        final readAt = DateTime.now().millisecondsSinceEpoch ~/ 1000;
        final byStory = a.read(storyViewsProvider).byStory;
        expect(byStory.length, StoryViewsController.maxStoriesPerReceipt);
        expect(byStory.values.first.single.at, lessThanOrEqualTo(readAt + 1));
        expect(byStory.values.first.single.at, lessThan(now + 100000));
      },
    );
  });

  group('the list of viewers', () {
    Widget host(StoryViewsState views) => ProviderScope(
      overrides: [
        indexerRelaysProvider.overrideWithValue(const []),
        relayPoolProvider.overrideWithValue(RelayPool(const [])),
        storyViewsProvider.overrideWith(() => _FakeViews(views)),
      ],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: StoryViewersSheet(storyId: 'a' * 64)),
      ),
    );

    testWidgets('says how many, and who', (tester) async {
      await tester.pumpWidget(
        host(
          StoryViewsState({
            'a' * 64: [
              StoryViewer(bob.publicKey, 1700000100),
              StoryViewer(carol.publicKey, 1700000000),
            ],
          }),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Seen by 2 people'), findsOneWidget);
      expect(find.byType(ListTile), findsNWidgets(2));
      expect(
        find.text(
          'Only people who allow it send a receipt, so the real number can be higher.',
        ),
        findsOneWidget,
      );
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 40));
    });

    testWidgets('and says so when nobody has', (tester) async {
      await tester.pumpWidget(host(const StoryViewsState()));
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('No views yet'), findsOneWidget);
      expect(find.byType(ListTile), findsNothing);
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 40));
    });
  });
}
