import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mialuna/app/providers.dart';
import 'package:mialuna/core/nostr/event.dart';
import 'package:mialuna/core/nostr/nip59.dart';
import 'package:mialuna/core/nostr/signer.dart';
import 'package:mialuna/core/storage/local_cache.dart';
import 'package:mialuna/features/private/private_delivery.dart';
import 'package:mialuna/features/stories/story_receipts.dart';
import 'package:mialuna/features/stories/story_views.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../support/fake_relay.dart';
import '../../support/story_fixtures.dart' as fixtures;
import '../../support/story_harness.dart';

/// What the viewer's phone does with the stories it showed: every receipt is
/// delivered once the author's inbox accepted it, and until then it is kept,
/// retried with a back-off, and withdrawn if the user changes their mind.
void main() {
  late FakeRelay relay;
  late StoryHarness h;
  late NsecSigner alice; // the author
  late NsecSigner bob; // the viewer
  late NsecSigner carol; // another account

  StoryViewReporter reporterOf(ProviderContainer c) =>
      c.read(storyViewReporterProvider);

  File outboxOf(Directory dir, Signer who) =>
      File('${dir.path}/${LocalCache.storyReceiptsFile(who.publicKey!)}');

  Future<List<String>> sentList(Signer who) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('mialuna_story_views_sent_${who.publicKey}') ??
        const [];
  }

  /// The story ids carried by every gift wrap on the relay, as the author
  /// reads them.
  Future<List<List<String>>> receiptsReadBy(Signer author) async {
    final out = <List<String>>[];
    for (final w in relay.stored.where((e) => e.kind == NostrKinds.giftWrap)) {
      final rumor = await GiftWrap.unwrap(signer: author, wrap: w);
      if (rumor == null || rumor.kind != NostrKinds.storyView) continue;
      out.add([
        for (final t in rumor.tags)
          if (t[0] == 'e') t[1],
      ]);
    }
    return out;
  }

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    relay = await FakeRelay(authKinds: {1059}).start();
    h = StoryHarness(relay);
    alice = newSigner();
    bob = newSigner();
    carol = newSigner();
    for (final s in [alice, bob, carol]) {
      await h.registerInbox(s);
    }
  });

  tearDown(() => relay.stop());

  group('delivery', () {
    test('a receipt is delivered once the author\'s inbox took it', () async {
      final a = await h.online(alice);
      final b = await h.online(bob);
      final s = await h.publish(a, alice, 'tramonto');
      final r = reporterOf(b);

      await r.viewed(s);
      expect(r.stateOf(s.id), ReceiptState.pending);
      expect(h.wraps, 0, reason: 'nothing leaves while the story plays');

      await r.flush();
      expect(r.stateOf(s.id), ReceiptState.delivered);
      expect(r.pendingCount, 0);
      expect(await sentList(bob), contains(s.id));
      await eventually(() => a.read(storyViewsProvider).countOf(s.id) == 1);
      expect(a.read(storyViewsProvider).of(s.id).single.pubkey, bob.publicKey);

      // The relay saw one wrap from a throw-away key: no ids, no viewer.
      final dump = jsonEncode(relay.stored.map((e) => e.toJson()).toList());
      expect(dump, isNot(contains(s.id)));
      for (final w in relay.stored.where(
        (e) => e.kind == NostrKinds.giftWrap,
      )) {
        expect(w.pubkey, isNot(anyOf(alice.publicKey, bob.publicKey)));
        expect(w.firstTagValue('p'), alice.publicKey);
      }
    });

    test('every relay refuses: the receipt is kept, not "sent"', () async {
      final dir = Directory.systemTemp.createTempSync('mialuna_outbox_');
      final a = await h.online(alice);
      final b = await h.online(bob, dir: dir);
      final s = await h.publish(a, alice, 'rifiutata');
      final r = reporterOf(b);
      relay.rejectWith = 'blocked: not today';

      await r.viewed(s);
      await r.flush();

      expect(r.stateOf(s.id), ReceiptState.failed);
      expect(r.pendingCount, 1);
      expect(await sentList(bob), isNot(contains(s.id)));
      expect(outboxOf(dir, bob).existsSync(), true);
      expect(h.wraps, 0);

      // Asking again at once does not hammer the relay: the back-off holds.
      final attempts = relay.publishAttempts;
      await r.flush();
      expect(relay.publishAttempts, attempts);

      relay.rejectWith = null;
      h.clock.advance(StoryViewReporter.backoffSeconds(1, signer: false) + 1);
      await r.flush();
      expect(r.stateOf(s.id), ReceiptState.delivered);
      await eventually(() => a.read(storyViewsProvider).countOf(s.id) == 1);
      expect(outboxOf(dir, bob).existsSync(), false);
    });

    test('an author with no inbox is retried when they get one', () async {
      final dave = newSigner();
      final b = await h.online(bob);
      final s = await h.story(dave, 'senza inbox');
      final r = reporterOf(b);

      await r.viewed(s);
      await r.flush();
      expect(r.stateOf(s.id), ReceiptState.failed);
      expect(h.wraps, 0);

      await h.registerInbox(dave);
      h.clock.advance(StoryViewReporter.backoffSeconds(1, signer: false) + 1);
      await r.flush();
      expect(r.stateOf(s.id), ReceiptState.delivered);
      expect(h.wraps, 1);
    });

    test(
      'a relay that never answers fails the receipt, which is retried',
      () async {
        final a = await h.online(alice);
        final b = await h.online(bob);
        final s = await h.publish(a, alice, 'muto');
        final r = reporterOf(b);
        relay.ignorePublishes = true;

        await r.viewed(s);
        await r.flush();
        expect(r.stateOf(s.id), ReceiptState.failed);
        expect(await sentList(bob), isNot(contains(s.id)));

        relay.ignorePublishes = false;
        h.clock.advance(3600);
        await r.flush();
        expect(r.stateOf(s.id), ReceiptState.delivered);
      },
      timeout: const Timeout(Duration(seconds: 60)),
    );

    test('one relay out of two accepting is delivery', () async {
      final second = await FakeRelay(authKinds: {1059}).start();
      addTearDown(second.stop);
      final two = StoryHarness(relay, more: [second]);
      final author = newSigner();
      final viewer = newSigner();
      await two.registerInbox(author);
      await two.registerInbox(viewer);
      final a = await two.online(author);
      final b = await two.online(viewer);
      final s = await two.publish(a, author, 'due relay');
      second.rejectWith = 'blocked: no';

      final r = reporterOf(b);
      await r.viewed(s);
      await r.flush();

      expect(r.stateOf(s.id), ReceiptState.delivered);
      expect(two.wraps, 1);
      expect(second.stored.where((e) => e.kind == 1059), isEmpty);
    });

    test('the signer refuses: kept, and not asked again at once', () async {
      final signer = ScriptedSigner(bob)..refuseEncrypt = true;
      final a = await h.online(alice);
      final b = await h.online(signer);
      final s = await h.publish(a, alice, 'rifiuto');
      final r = reporterOf(b);

      await r.viewed(s);
      await r.flush();
      expect(r.stateOf(s.id), ReceiptState.failed);
      expect(signer.encryptCalls, 1);
      expect(h.wraps, 0);
      expect(await sentList(bob), isNot(contains(s.id)));

      // A person was asked; they are not asked again for a while.
      await r.flush();
      h.clock.advance(60);
      await r.flush();
      expect(signer.encryptCalls, 1);

      h.clock.advance(StoryViewReporter.backoffSeconds(1, signer: true));
      await r.flush();
      expect(signer.encryptCalls, 2, reason: 'refused again, backs off more');
      expect(r.stateOf(s.id), ReceiptState.failed);

      signer.refuseEncrypt = false;
      h.clock.advance(StoryViewReporter.backoffSeconds(2, signer: true));
      await r.flush();
      expect(r.stateOf(s.id), ReceiptState.delivered);
      await eventually(() => a.read(storyViewsProvider).countOf(s.id) == 1);
    });

    test('a seal the signer will not sign is kept too', () async {
      final signer = ScriptedSigner(bob)..refuseSeal = true;
      final b = await h.online(signer);
      final s = await h.story(alice, 'sigillo');
      final r = reporterOf(b);

      await r.viewed(s);
      await r.flush();
      expect(r.stateOf(s.id), ReceiptState.failed);
      expect(h.wraps, 0);

      signer.refuseSeal = false;
      h.clock.advance(StoryViewReporter.backoffSeconds(1, signer: true));
      await r.flush();
      expect(r.stateOf(s.id), ReceiptState.delivered);
    });

    test('delivered twice, counted once', () async {
      final a = await h.online(alice);
      final s = await h.publish(a, alice, 'doppia');

      final first = await h.online(bob);
      await reporterOf(first).viewed(s);
      await reporterOf(first).flush();
      await eventually(() => a.read(storyViewsProvider).countOf(s.id) == 1);

      // The phone forgot it had told them (a reinstall, a lost file).
      SharedPreferences.setMockInitialValues({});
      final second = await h.online(bob);
      await reporterOf(second).viewed(s);
      await reporterOf(second).flush();

      expect(h.wraps, 2);
      await Future<void>.delayed(const Duration(milliseconds: 300));
      expect(a.read(storyViewsProvider).countOf(s.id), 1);
    });

    test('a story already reported is not queued again', () async {
      final b = await h.online(bob);
      final s = await h.story(alice, 'ancora');
      final r = reporterOf(b);
      await r.viewed(s);
      await r.flush();
      expect(h.wraps, 1);

      await r.viewed(s);
      expect(r.pendingCount, 0);
      await r.flush();
      expect(h.wraps, 1);
    });
  });

  group('batches', () {
    for (final count in [1, 29, 30, 31, 60, 75]) {
      test('$count stories reach the author, 30 to a message', () async {
        final a = await h.online(alice);
        final b = await h.online(bob);
        final r = reporterOf(b);
        final stories = [
          for (var i = 0; i < count; i++) await h.publish(a, alice, 's$i'),
        ];
        for (final s in stories) {
          await r.viewed(s);
        }
        await r.flush();

        expect(h.wraps, (count / 30).ceil());
        expect(r.pendingCount, 0);
        final messages = await receiptsReadBy(alice);
        expect(messages.every((ids) => ids.length <= 30), true);
        final ids = messages.expand((m) => m).toList();
        expect(ids.length, count, reason: 'none twice');
        expect(ids.toSet(), {for (final s in stories) s.id});
        await eventually(
          () => stories.every(
            (s) => a.read(storyViewsProvider).countOf(s.id) == 1,
          ),
        );
      });
    }

    test('a failed batch loses neither the others nor itself', () async {
      final a = await h.online(alice);
      final b = await h.online(bob);
      final r = reporterOf(b);
      final stories = [
        for (var i = 0; i < 60; i++) await h.publish(a, alice, 'b$i'),
      ];
      for (final s in stories) {
        await r.viewed(s);
      }
      relay.acceptLimit = 1; // the first message gets through, the second not

      await r.flush();
      final delivered = stories
          .where((s) => r.stateOf(s.id) == ReceiptState.delivered)
          .length;
      expect(delivered, 30);
      expect(r.pendingCount, 30);
      expect(
        stories.where((s) => r.stateOf(s.id) == ReceiptState.failed).length,
        30,
      );

      relay.acceptLimit = null;
      h.clock.advance(3600);
      await r.flush();
      expect(r.pendingCount, 0);
      expect(h.wraps, 2, reason: 'the 30 that got through are not sent twice');
      await eventually(
        () =>
            stories.every((s) => a.read(storyViewsProvider).countOf(s.id) == 1),
      );
    });
  });

  group('consent', () {
    test('switched off before watching: nothing is even queued', () async {
      final dir = Directory.systemTemp.createTempSync('mialuna_outbox_');
      final b = await h.online(bob, dir: dir);
      await b.read(storyViewReceiptsProvider.notifier).set(false);
      final r = reporterOf(b);

      await r.viewed(await h.story(alice, 'incognito'));
      expect(r.pendingCount, 0);
      await r.flush();
      expect(h.wraps, 0);
      expect(outboxOf(dir, bob).existsSync(), false);
    });

    test('switched off after watching, before sending: cancelled', () async {
      final dir = Directory.systemTemp.createTempSync('mialuna_outbox_');
      final b = await h.online(bob, dir: dir);
      final s = await h.story(alice, 'ripensamento');
      final r = reporterOf(b);
      await r.viewed(s);
      expect(outboxOf(dir, bob).existsSync(), true);

      await b.read(storyViewReceiptsProvider.notifier).set(false);
      expect(r.pendingCount, 0);
      expect(r.stateOf(s.id), isNull);
      expect(outboxOf(dir, bob).existsSync(), false);

      await r.flush();
      expect(h.wraps, 0);

      // Turning it on again does not bring the old receipt back.
      await b.read(storyViewReceiptsProvider.notifier).set(true);
      await r.flush();
      expect(h.wraps, 0);
    });

    test('switched off while the signer is working: not published', () async {
      final dir = Directory.systemTemp.createTempSync('mialuna_outbox_');
      final signer = ScriptedSigner(bob)..gate = Completer<void>();
      final b = await h.online(signer, dir: dir);
      final s = await h.story(alice, 'mentre firma');
      final r = reporterOf(b);
      await r.viewed(s);

      final sending = r.flush();
      await eventually(() => signer.encryptCalls == 1);
      expect(r.stateOf(s.id), ReceiptState.sending);

      await b.read(storyViewReceiptsProvider.notifier).set(false);
      signer.gate!.complete();
      await sending;

      expect(relay.publishAttempts, 0, reason: 'revoked before it left');
      expect(h.wraps, 0);
      expect(r.pendingCount, 0);
      expect(r.stateOf(s.id), isNull);
      expect(outboxOf(dir, bob).existsSync(), false);
    });

    test(
      'switched off while a relay is answering: nothing comes back',
      () async {
        final dir = Directory.systemTemp.createTempSync('mialuna_outbox_');
        final b = await h.online(bob, dir: dir);
        final s = await h.story(alice, 'mentre consegna');
        final r = reporterOf(b);
        await r.viewed(s);
        relay.publishDelay = const Duration(milliseconds: 600);

        final sending = r.flush();
        await eventually(() => relay.publishAttempts == 1);
        await b.read(storyViewReceiptsProvider.notifier).set(false);
        await sending;

        // The relay had the wrap before the user changed their mind: a
        // delivered wrap cannot be recalled. What the app guarantees is that
        // nothing else is sent, kept or retried.
        expect(h.wraps, 1);
        expect(r.pendingCount, 0);
        expect(r.stateOf(s.id), isNull);
        expect(outboxOf(dir, bob).existsSync(), false);

        await b.read(storyViewReceiptsProvider.notifier).set(true);
        h.clock.advance(7200);
        await r.flush();
        expect(relay.publishAttempts, 1);
      },
    );

    test('a restart does not bring cancelled receipts back', () async {
      final dir = Directory.systemTemp.createTempSync('mialuna_outbox_');
      final first = await h.online(bob, dir: dir);
      relay.rejectWith = 'down';
      final s = await h.story(alice, 'resta cancellata');
      await reporterOf(first).viewed(s);
      await reporterOf(first).flush();
      expect(outboxOf(dir, bob).existsSync(), true);
      await first.read(storyViewReceiptsProvider.notifier).set(false);
      first.dispose();

      relay.rejectWith = null;
      h.clock.advance(7200);
      final second = await h.online(bob, dir: dir);
      expect(reporterOf(second).pendingCount, 0);
      await reporterOf(second).flush();
      await Future<void>.delayed(const Duration(milliseconds: 300));
      expect(h.wraps, 0);
    });

    test('an old outbox is thrown away when the setting is off', () async {
      final dir = Directory.systemTemp.createTempSync('mialuna_outbox_');
      final s = await h.story(alice, 'avanzo');
      outboxOf(dir, bob).writeAsStringSync(
        jsonEncode({
          'v': 1,
          'owner': bob.publicKey,
          'items': [
            {
              'id': s.id,
              'a': alice.publicKey,
              't': h.clock.now,
              'n': 0,
              'x': 0,
            },
          ],
        }),
      );
      SharedPreferences.setMockInitialValues({
        'mialuna_send_story_views': false,
      });

      final b = await h.online(bob, dir: dir);
      final r = reporterOf(b);
      await r.flush();
      await eventually(() => !outboxOf(dir, bob).existsSync());
      expect(r.pendingCount, 0);
      expect(h.wraps, 0);
    });

    test('a choice that cannot be read counts as "no"', () async {
      final b = h.app(
        bob,
        overrides: [
          sharedPreferencesLoader.overrideWithValue(
            () async => throw StateError('disk'),
          ),
        ],
      );
      await b.read(storyViewReceiptsProvider.notifier).loaded;
      expect(b.read(storyViewReceiptsProvider), false);

      final r = reporterOf(b);
      await r.viewed(await h.story(alice, 'mistero'));
      expect(r.pendingCount, 0);
    });
  });

  group('whose receipt it is', () {
    test('an account switch leaves the queue with the account', () async {
      final dir = Directory.systemTemp.createTempSync('mialuna_outbox_');
      final auth = SwitchableAuth(bob);
      final b = await h.online(bob, dir: dir, auth: auth);
      final a = await h.online(alice);
      final s = await h.publish(a, alice, 'cambio account');
      relay.rejectWith = 'down';
      final asBob = reporterOf(b);
      await asBob.viewed(s);
      await asBob.flush();
      expect(asBob.pendingCount, 1);
      relay.rejectWith = null;

      auth.switchTo(carol);
      final asCarol = reporterOf(b);
      expect(identical(asCarol, asBob), false);
      expect(asCarol.owner, carol.publicKey);
      expect(asCarol.pendingCount, 0, reason: 'Bob\'s queue is not Carol\'s');
      h.clock.advance(7200);
      await asCarol.flush();
      await asBob.flush(); // the old reporter has nothing left to say
      expect(h.wraps, 0);
      expect(outboxOf(dir, bob).existsSync(), true);
      expect(outboxOf(dir, carol).existsSync(), false);

      // Back as Bob: his receipt is still his, and signed by him.
      auth.switchTo(bob);
      final again = reporterOf(b);
      await again.flush();
      expect(again.stateOf(s.id), ReceiptState.delivered);
      await eventually(() => a.read(storyViewsProvider).countOf(s.id) == 1);
      expect(a.read(storyViewsProvider).of(s.id).single.pubkey, bob.publicKey);
    });

    test(
      'a signature that comes late is not given to the new account',
      () async {
        final signer = ScriptedSigner(bob)..gate = Completer<void>();
        final auth = SwitchableAuth(signer);
        final b = await h.online(signer, auth: auth);
        final s = await h.story(alice, 'firma tardiva');
        final r = reporterOf(b);
        await r.viewed(s);

        final sending = r.flush();
        await eventually(() => signer.encryptCalls == 1);
        auth.switchTo(carol);
        signer.gate!.complete();
        await sending;

        expect(relay.publishAttempts, 0);
        expect(h.wraps, 0);
        expect(reporterOf(b).pendingCount, 0);
      },
    );

    test('after a sign-out nothing is written back', () async {
      final dir = Directory.systemTemp.createTempSync('mialuna_outbox_');
      final signer = ScriptedSigner(bob)..gate = Completer<void>();
      final b = await h.online(signer, dir: dir);
      final s = await h.story(alice, 'esco');
      final r = reporterOf(b);
      await r.viewed(s);
      final sending = r.flush();
      await eventually(() => signer.encryptCalls == 1);

      // What sign-out does: forget, then delete the account's files.
      r.discard();
      await LocalCache(
        directory: dir,
      ).deleteFile(LocalCache.storyReceiptsFile(bob.publicKey));
      signer.gate!.complete();
      await sending;
      await Future<void>.delayed(const Duration(milliseconds: 200));

      expect(outboxOf(dir, bob).existsSync(), false);
      expect(h.wraps, 0);
      expect(await sentList(bob), isEmpty);
    });

    test('guests and your own stories report nothing', () async {
      final a = await h.online(alice);
      final mine = await h.publish(a, alice, 'mia');
      await reporterOf(a).viewed(mine);
      await reporterOf(a).flush();
      expect(reporterOf(a).pendingCount, 0);

      final guest = h.app(GuestSigner());
      final g = reporterOf(guest);
      expect(g.owner, isNull);
      await g.viewed(await h.story(alice, 'di alice'));
      await g.flush();
      expect(g.pendingCount, 0);
      expect(h.wraps, 0);
    });

    test('a rumor written by somebody else is not signed by you', () async {
      final b = await h.online(bob);
      final foreign = Rumor.create(
        pubkey: carol.publicKey,
        kind: NostrKinds.storyView,
        tags: [
          ['e', 'a' * 64],
          ['p', alice.publicKey],
        ],
        content: '',
      );
      // Delivery refuses it outright.
      expect(
        () => b.read(privateDeliveryProvider).send(foreign, [
          alice.publicKey,
        ], copyToSelf: false),
        throwsA(anything),
      );
      expect(h.wraps, 0);
    });
  });

  group('one send at a time', () {
    test('work that arrives during a flush is sent right after', () async {
      final signer = ScriptedSigner(bob)..gate = Completer<void>();
      final a = await h.online(alice);
      final b = await h.online(signer);
      final r = reporterOf(b);
      final s1 = await h.publish(a, alice, 'primo');
      final s2 = await h.publish(a, alice, 'secondo');

      await r.viewed(s1);
      final first = r.flush();
      await eventually(() => signer.encryptCalls == 1);
      await r.viewed(s2);
      final second = r.flush(); // used to be dropped on the floor
      signer.gate!.complete();
      await Future.wait([first, second]);

      expect(r.stateOf(s1.id), ReceiptState.delivered);
      expect(r.stateOf(s2.id), ReceiptState.delivered);
      expect(h.wraps, 2);
      await eventually(
        () =>
            a.read(storyViewsProvider).countOf(s1.id) == 1 &&
            a.read(storyViewsProvider).countOf(s2.id) == 1,
      );
    });

    test('two authors at once: one signer request at a time', () async {
      final signer = ScriptedSigner(bob)..gate = Completer<void>();
      final a = await h.online(alice);
      final c = await h.online(carol);
      final b = await h.online(signer);
      final r = reporterOf(b);
      final fromAlice = await h.publish(a, alice, 'di alice');
      final fromCarol = await h.publish(c, carol, 'di carol');
      await r.viewed(fromAlice);
      await r.viewed(fromCarol);

      final one = r.flush(author: alice.publicKey);
      await eventually(() => signer.encryptCalls == 1);
      final two = r.flush(author: carol.publicKey);
      await Future<void>.delayed(const Duration(milliseconds: 100));
      expect(signer.encryptCalls, 1, reason: 'the second waits its turn');
      signer.gate!.complete();
      await Future.wait([one, two]);

      expect(signer.maxConcurrent, 1);
      expect(r.stateOf(fromAlice.id), ReceiptState.delivered);
      expect(r.stateOf(fromCarol.id), ReceiptState.delivered);
      await eventually(
        () =>
            a.read(storyViewsProvider).countOf(fromAlice.id) == 1 &&
            c.read(storyViewsProvider).countOf(fromCarol.id) == 1,
      );
    });

    test('a failing relay is tried once, not in a loop', () async {
      final b = await h.online(bob);
      final r = reporterOf(b);
      relay.rejectWith = 'down';
      await r.viewed(await h.story(alice, 'una volta'));
      await r.flush();
      await Future<void>.delayed(const Duration(milliseconds: 400));
      expect(relay.publishAttempts, 1);
    });

    test('only the author asked for is sent to', () async {
      final b = await h.online(bob);
      final r = reporterOf(b);
      final fromAlice = await h.story(alice, 'solo alice');
      final fromCarol = await h.story(carol, 'non ancora');
      await r.viewed(fromAlice);
      await r.viewed(fromCarol);

      await r.flush(author: alice.publicKey);
      expect(r.stateOf(fromAlice.id), ReceiptState.delivered);
      expect(r.stateOf(fromCarol.id), ReceiptState.pending);
    });
  });

  group('across restarts', () {
    test('a receipt that failed is delivered after the app restarts', () async {
      final dir = Directory.systemTemp.createTempSync('mialuna_outbox_');
      final a = await h.online(alice);
      final s = await h.publish(a, alice, 'dopo il riavvio');
      final first = await h.online(bob, dir: dir);
      relay.rejectWith = 'down';
      await reporterOf(first).viewed(s);
      await reporterOf(first).flush();
      first.dispose();

      // What is on disk is just what a retry needs.
      final saved = jsonDecode(outboxOf(dir, bob).readAsStringSync()) as Map;
      final item = (saved['items'] as List).single as Map;
      expect(item['id'], s.id);
      expect(item['a'], alice.publicKey);
      expect(item.keys.toSet(), {'id', 'a', 't', 'n', 'x'});

      relay.rejectWith = null;
      h.clock.advance(7200);
      final second = await h.online(bob, dir: dir);
      reporterOf(second); // the app creates it at start-up
      await eventually(() => h.wraps == 1, reason: 'not retried after restart');
      await eventually(() => a.read(storyViewsProvider).countOf(s.id) == 1);
      await eventually(() => !outboxOf(dir, bob).existsSync());
    });

    test('Amber is not woken up by a restart; the viewer asks it', () async {
      final dir = Directory.systemTemp.createTempSync('mialuna_outbox_');
      final s = await h.story(alice, 'amber');
      final first = await h.online(
        ScriptedSigner(bob, kind: SignerType.amber),
        dir: dir,
      );
      relay.rejectWith = 'down';
      await reporterOf(first).viewed(s);
      await reporterOf(first).flush();
      first.dispose();
      relay.rejectWith = null;
      h.clock.advance(24 * 3600 - 100);

      final amber = ScriptedSigner(bob, kind: SignerType.amber);
      final second = await h.online(amber, dir: dir);
      final r = reporterOf(second);
      await Future<void>.delayed(const Duration(milliseconds: 500));
      expect(amber.encryptCalls, 0, reason: 'no background prompt');
      expect(h.wraps, 0);
      expect(r.pendingCount, 1);

      await r.flush(); // the viewer closing: a person is there
      expect(amber.encryptCalls, 1);
      expect(r.stateOf(s.id), ReceiptState.delivered);
    });

    test('a receipt is dropped once its story is long gone', () async {
      final dir = Directory.systemTemp.createTempSync('mialuna_outbox_');
      final first = await h.online(bob, dir: dir);
      relay.rejectWith = 'down';
      await reporterOf(first).viewed(await h.story(alice, 'vecchia'));
      await reporterOf(first).flush();
      expect(reporterOf(first).pendingCount, 1);

      relay.rejectWith = null;
      h.clock.advance(StoryViewReporter.retention + 1);
      await reporterOf(first).flush();
      expect(reporterOf(first).pendingCount, 0);
      expect(h.wraps, 0);

      // ...and not read back from disk either.
      first.dispose();
      final second = await h.online(bob, dir: dir);
      expect(reporterOf(second).pendingCount, 0);
    });

    test('the outbox cannot grow without bound', () async {
      final b = await h.online(bob);
      final r = reporterOf(b);
      relay.rejectWith = 'down';
      for (var i = 0; i < StoryViewReporter.maxPending + 25; i++) {
        await r.viewed(fixtures.story(alice.publicKey));
      }
      expect(r.pendingCount, StoryViewReporter.maxPending);
    });
  });

  test('back-off doubles and stops growing', () {
    expect(StoryViewReporter.backoffSeconds(1, signer: false), 30);
    expect(StoryViewReporter.backoffSeconds(2, signer: false), 60);
    expect(StoryViewReporter.backoffSeconds(3, signer: false), 120);
    expect(StoryViewReporter.backoffSeconds(40, signer: false), 3600);
    expect(StoryViewReporter.backoffSeconds(1, signer: true), 300);
    expect(StoryViewReporter.backoffSeconds(40, signer: true), 6 * 3600);
  });
}
