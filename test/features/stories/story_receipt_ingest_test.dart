import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mialuna/core/nostr/event.dart';
import 'package:mialuna/core/nostr/nip59.dart';
import 'package:mialuna/features/messages/dm_controller.dart';
import 'package:mialuna/core/nostr/signer.dart';
import 'package:mialuna/features/private/private_delivery.dart';
import 'package:mialuna/features/stories/stories_controller.dart';
import 'package:mialuna/features/stories/story_views.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../support/fake_relay.dart';
import '../../support/story_harness.dart';

/// A receipt is a self-reported acknowledgement from somebody who can name
/// any story id they like. Only receipts for the author's own live stories
/// count; the rest waits, in a bounded buffer, or is forgotten.
void main() {
  late FakeRelay relay;
  late StoryHarness h;
  late NsecSigner alice; // the author
  late NsecSigner bob;
  late NsecSigner carol;

  Rumor receipt(
    Signer from,
    List<String> stories, {
    String? to,
    int? at,
    String? fromKey,
  }) => Rumor.create(
    pubkey: fromKey ?? from.publicKey!,
    kind: NostrKinds.storyView,
    tags: [
      for (final s in stories) ['e', s],
      ['p', to ?? alice.publicKey],
    ],
    content: '',
    createdAt: at,
  );

  String randomKey(Random r) => List.generate(
    32,
    (_) => r.nextInt(256).toRadixString(16).padLeft(2, '0'),
  ).join();

  /// Alice's app, listening to her views.
  Future<ProviderContainer> aliceApp({Directory? dir}) async {
    final c = h.app(alice, dir: dir);
    c.listen(storyViewsProvider, (_, _) {});
    await Future<void>.delayed(const Duration(milliseconds: 30));
    return c;
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

  group('which receipts count', () {
    test('a story that is not yours is never counted', () async {
      final a = await aliceApp();
      final theirs = await h.story(carol, 'di carol');
      final ctl = a.read(storyViewsProvider.notifier);

      ctl.ingest(receipt(bob, [theirs.id]));
      expect(a.read(storyViewsProvider).countOf(theirs.id), 0);
      expect(a.read(storyViewsProvider).byStory, isEmpty);

      // ...and a story of yours that appears later is not theirs either.
      await h.publish(a, alice, 'mia');
      expect(a.read(storyViewsProvider).countOf(theirs.id), 0);
    });

    test('a receipt that is early counts when the story appears', () async {
      final a = await aliceApp();
      final story = await h.story(alice, 'in arrivo');
      final ctl = a.read(storyViewsProvider.notifier);

      expect(ctl.ingest(receipt(bob, [story.id])), true);
      expect(a.read(storyViewsProvider).countOf(story.id), 0);
      expect(ctl.heldCount, 1);

      a.read(storiesProvider.notifier).addPublished(story.event);
      expect(a.read(storyViewsProvider).countOf(story.id), 1);
      expect(ctl.heldCount, 0);
    });

    test('a held receipt that never gets its story is forgotten', () async {
      final a = await aliceApp();
      final ctl = a.read(storyViewsProvider.notifier);
      ctl.ingest(receipt(bob, ['1' * 64], at: h.clock.now));
      expect(ctl.heldCount, 1);

      h.clock.advance(StoryViewsController.heldFor + 1);
      ctl.ingest(receipt(carol, ['2' * 64], at: h.clock.now));
      expect(ctl.heldCount, 1, reason: 'only the new one is left');
    });

    test('story ids must be 64 lowercase hex digits', () async {
      final a = await aliceApp();
      final ctl = a.read(storyViewsProvider.notifier);
      final good = (await h.publish(a, alice, 'ok')).id;
      for (final bad in [
        good.toUpperCase(),
        good.substring(1),
        '${good}0',
        'g' * 64,
        '',
      ]) {
        expect(ctl.ingest(receipt(bob, [bad])), false, reason: bad);
      }
      expect(ctl.heldCount, 0);
      expect(a.read(storyViewsProvider).byStory, isEmpty);
    });

    test('a viewer is counted once, with their latest time', () async {
      final a = await aliceApp();
      final t = h.clock.now;
      final story = await h.story(alice, 'doppio', createdAt: t - 100);
      a.read(storiesProvider.notifier).addPublished(story.event);
      final ctl = a.read(storyViewsProvider.notifier);

      expect(ctl.ingest(receipt(bob, [story.id], at: t - 10)), true);
      expect(ctl.ingest(receipt(bob, [story.id], at: t - 10)), false);
      expect(ctl.ingest(receipt(bob, [story.id], at: t - 20)), false);
      expect(ctl.ingest(receipt(bob, [story.id], at: t - 5)), true);

      final viewers = a.read(storyViewsProvider).of(story.id);
      expect(viewers.length, 1);
      expect(viewers.single.at, t - 5);
    });

    test('nobody watched a story before it existed', () async {
      final a = await aliceApp();
      final story = await h.publish(a, alice, 'presto');
      a
          .read(storyViewsProvider.notifier)
          .ingest(receipt(bob, [story.id], at: story.createdAt - 5000));
      expect(
        a.read(storyViewsProvider).of(story.id).single.at,
        story.createdAt,
      );
    });

    test('a receipt older than what is kept is ignored', () async {
      final a = await aliceApp();
      final story = await h.publish(a, alice, 'vecchia');
      final ctl = a.read(storyViewsProvider.notifier);
      final fourDays = 4 * 24 * 3600;
      expect(
        ctl.ingest(receipt(bob, [story.id], at: h.clock.now - fourDays)),
        false,
      );
      expect(a.read(storyViewsProvider).countOf(story.id), 0);
    });

    test('through the inbox: a forged id is not counted', () async {
      final a = await h.online(alice);
      final b = await h.online(bob);
      final mine = await h.publish(a, alice, 'vera');
      final theirs = await h.story(carol, 'di carol');

      // Bob tells Alice he watched Carol's story, and hers.
      final report = await b.read(privateDeliveryProvider).send(
        receipt(bob, [theirs.id, mine.id]),
        [alice.publicKey],
        copyToSelf: false,
      );
      expect(report.reachedSomeone, true);

      await eventually(() => a.read(storyViewsProvider).countOf(mine.id) == 1);
      expect(a.read(storyViewsProvider).countOf(theirs.id), 0);
    });
  });

  group('under attack', () {
    test('endless unknown ids from endless senders stay bounded', () async {
      final a = await aliceApp();
      final ctl = a.read(storyViewsProvider.notifier);
      final rng = Random(7);
      for (var sender = 0; sender < 1500; sender++) {
        final viewer = randomKey(rng);
        final ids = [for (var i = 0; i < 30; i++) randomKey(rng)];
        ctl.ingest(receipt(bob, ids, fromKey: viewer));
      }
      expect(ctl.heldCount, lessThanOrEqualTo(StoryViewsController.maxHeld));
      expect(a.read(storyViewsProvider).byStory, isEmpty);
    });

    test('one sender cannot fill the buffer', () async {
      final a = await aliceApp();
      final ctl = a.read(storyViewsProvider.notifier);
      final rng = Random(11);
      for (var receipts = 0; receipts < 40; receipts++) {
        ctl.ingest(receipt(bob, [for (var i = 0; i < 30; i++) randomKey(rng)]));
      }
      expect(
        ctl.heldCount,
        lessThanOrEqualTo(StoryViewsController.maxHeldPerViewer),
      );

      // Somebody else's receipt still finds room, and your own stories keep
      // being counted.
      final story = await h.publish(a, alice, 'ancora');
      ctl.ingest(receipt(carol, [story.id]));
      expect(a.read(storyViewsProvider).countOf(story.id), 1);
    });

    test('one story cannot list unlimited viewers', () async {
      final a = await aliceApp();
      final story = await h.publish(a, alice, 'popolare');
      final ctl = a.read(storyViewsProvider.notifier);
      final rng = Random(3);
      for (var i = 0; i < 2100; i++) {
        ctl.ingest(receipt(bob, [story.id], fromKey: randomKey(rng)));
      }
      expect(a.read(storyViewsProvider).countOf(story.id), 2000);
    });
  });

  group('kept on the phone', () {
    File viewsFile(Directory dir) =>
        File('${dir.path}/story_views_${alice.publicKey}.json');

    test('for three days, then gone', () async {
      final dir = Directory.systemTemp.createTempSync('mialuna_views_');
      final story = await h.publish(await aliceApp(), alice, 'x');
      final day = 24 * 3600;
      viewsFile(dir).writeAsStringSync(
        jsonEncode({
          'v': 2,
          'views': {
            story.id: {
              bob.publicKey: h.clock.now - 2 * day,
              carol.publicKey: h.clock.now - 4 * day,
            },
          },
          'held': [],
        }),
      );

      final a = await aliceApp(dir: dir);
      await eventually(() => a.read(storyViewsProvider).byStory.isNotEmpty);
      expect(a.read(storyViewsProvider).of(story.id).map((v) => v.pubkey), [
        bob.publicKey,
      ]);
    });

    test('an old file full of unchecked ids is not trusted', () async {
      final dir = Directory.systemTemp.createTempSync('mialuna_views_');
      final a0 = await aliceApp();
      final mine = await h.publish(a0, alice, 'mia');
      final now = h.clock.now;
      viewsFile(dir).writeAsStringSync(
        jsonEncode({
          mine.id: {bob.publicKey: now - 100},
          'f' * 64: {bob.publicKey: now - 100},
        }),
      );

      final a = await aliceApp(dir: dir);
      a.read(storiesProvider.notifier).addPublished(mine.event);
      await eventually(() => a.read(storyViewsProvider).countOf(mine.id) == 1);
      expect(a.read(storyViewsProvider).countOf('f' * 64), 0);
    });

    test('a receipt waiting for its story survives a restart', () async {
      final dir = Directory.systemTemp.createTempSync('mialuna_views_');
      final first = await aliceApp(dir: dir);
      final story = await h.story(alice, 'tardiva');
      first.read(storyViewsProvider.notifier).ingest(receipt(bob, [story.id]));
      await eventually(() => viewsFile(dir).existsSync());
      first.dispose();

      final again = await aliceApp(dir: dir);
      expect(
        again.read(storyViewsProvider.notifier).heldCount,
        1,
        reason: 'the held receipt was not saved',
      );
      again.read(storiesProvider.notifier).addPublished(story.event);
      expect(again.read(storyViewsProvider).countOf(story.id), 1);
    });
  });

  group('the inbox remembers what it has opened', () {
    late ScriptedSigner reading;

    Future<void> sendReaction(ProviderContainer from, Signer who) async {
      final rumor = Rumor.create(
        pubkey: who.publicKey!,
        kind: NostrKinds.reaction,
        tags: [
          ['e', 'c' * 64],
          ['p', alice.publicKey],
          ['k', '20'],
        ],
        content: '+',
      );
      await from.read(privateDeliveryProvider).send(rumor, [
        alice.publicKey,
      ], copyToSelf: false);
    }

    int wrapsForAlice() => relay.stored
        .where(
          (e) =>
              e.kind == NostrKinds.giftWrap &&
              e.firstTagValue('p') == alice.publicKey,
        )
        .length;

    /// The first sync of a new account writes its checkpoint when it ends;
    /// what arrives after that is live, and has to be saved on its own.
    Future<void> firstSyncDone(Directory dir) => eventually(
      () => File('${dir.path}/dm_${alice.publicKey}.json').existsSync(),
      reason: 'the first sync never finished',
    );

    Future<void> reopens(Directory dir, {required int wraps}) async {
      final file = File('${dir.path}/dm_${alice.publicKey}.json');
      await eventually(() {
        if (!file.existsSync()) return false;
        final json = jsonDecode(file.readAsStringSync()) as Map;
        return (json['wraps'] as List).length >= wraps;
      }, reason: 'the checkpoint was never written');
    }

    Future<void> restartAndCount(Directory dir) async {
      reading = ScriptedSigner(alice);
      final again = await h.online(reading, dir: dir);
      await Future<void>.delayed(const Duration(milliseconds: 600));
      expect(again.read(dmProvider).inboxConfigured, true);
      expect(
        reading.decryptCalls,
        0,
        reason: 'wraps already opened were decrypted again',
      );
    }

    Future<Directory> aliceOnlineWith(Directory dir) async {
      // The first sync finishes with an empty inbox, so everything that
      // follows is live.
      await h.online(ScriptedSigner(alice), dir: dir);
      return dir;
    }

    test('a session that only got story receipts', () async {
      final dir = Directory.systemTemp.createTempSync('mialuna_dm_');
      final a = await h.online(ScriptedSigner(alice), dir: dir);
      final b = await h.online(bob);
      await firstSyncDone(dir);
      final mine = await h.publish(a, alice, 'solo ricevute');
      await b.read(privateDeliveryProvider).send(receipt(bob, [mine.id]), [
        alice.publicKey,
      ], copyToSelf: false);
      await eventually(() => a.read(storyViewsProvider).countOf(mine.id) == 1);

      await reopens(dir, wraps: wrapsForAlice());
      a.dispose();
      await restartAndCount(dir);
    });

    test('a session that only got close-friends content', () async {
      final dir = Directory.systemTemp.createTempSync('mialuna_dm_');
      final a = await h.online(ScriptedSigner(alice), dir: dir);
      final b = await h.online(bob);
      await firstSyncDone(dir);
      await sendReaction(b, bob);
      await eventually(() => wrapsForAlice() == 1);
      await Future<void>.delayed(const Duration(milliseconds: 200));

      await reopens(dir, wraps: 1);
      a.dispose();
      await restartAndCount(dir);
    });

    test('a session of receipts, private content and chat together', () async {
      final dir = Directory.systemTemp.createTempSync('mialuna_dm_');
      final a = await h.online(ScriptedSigner(alice), dir: dir);
      final b = await h.online(bob);
      await firstSyncDone(dir);
      final mine = await h.publish(a, alice, 'misto');
      await b.read(privateDeliveryProvider).send(receipt(bob, [mine.id]), [
        alice.publicKey,
      ], copyToSelf: false);
      await sendReaction(b, bob);
      await b.read(dmProvider.notifier).send(alice.publicKey, 'ciao');
      await eventually(() => a.read(dmProvider).conversations.isNotEmpty);
      await eventually(() => wrapsForAlice() >= 3);

      await reopens(dir, wraps: wrapsForAlice());
      a.dispose();
      await restartAndCount(dir);
      await aliceOnlineWith(dir); // and it still opens
    });
  });
}
