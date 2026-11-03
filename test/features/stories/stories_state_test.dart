import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mialuna/app/providers.dart';
import 'package:mialuna/core/nostr/event.dart';
import 'package:mialuna/core/nostr/models/media_event.dart';
import 'package:mialuna/core/nostr/nip59.dart';
import 'package:mialuna/core/nostr/signer.dart';
import 'package:mialuna/features/private/private_posts.dart';
import 'package:mialuna/features/stories/stories_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../support/fake_relay.dart';
import '../../support/story_fixtures.dart' as fixtures;
import '../../support/story_harness.dart';

/// What the story rail knows and remembers: who is shown, what has been
/// watched (by whom), and when a story stops being there.
void main() {
  late FakeRelay relay;
  late StoryHarness h;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    relay = await FakeRelay().start();
    h = StoryHarness(relay);
  });

  tearDown(() => relay.stop());

  group('a story lives for a day', () {
    final author = 'a1' * 32;

    MediaPost post(
      int age, {
      List<List<String>>? extra,
      bool story = true,
      bool private = false,
    }) {
      final created = 1700000000;
      return MediaPost.tryParse(
        NostrEvent(
          id: '1' * 64,
          pubkey: author,
          createdAt: created + age,
          kind: NostrKinds.picture,
          tags: [
            ['imeta', 'url https://cdn.example.com/x.jpg', 'm image/jpeg'],
            if (story) ...[
              ['L', 'mialuna.story'],
              ['l', 'story', 'mialuna.story'],
            ],
            if (private)
              [MediaPost.audienceTag, MediaPost.closeFriendsAudience],
            ...?extra,
          ],
          content: '',
          sig: '',
        ),
        allowPrivate: true,
      )!;
    }

    const t0 = 1700000000;

    test('without an expiration tag it is over after 24 hours', () {
      final s = post(0);
      expect(s.isExpired(t0 + 86399), false);
      expect(s.isExpired(t0 + 86400), true);
    });

    test('a garbled expiration tag changes nothing', () {
      final s = post(
        0,
        extra: [
          ['expiration', 'soon'],
        ],
      );
      expect(s.isExpired(t0 + 86399), false);
      expect(s.isExpired(t0 + 86400), true);
    });

    test('a faraway expiration does not keep it longer', () {
      final s = post(
        0,
        extra: [
          ['expiration', '${t0 + 365 * 86400}'],
        ],
      );
      expect(s.isExpired(t0 + 3600), false);
      expect(s.isExpired(t0 + 86400), true);
    });

    test('an earlier expiration ends it earlier', () {
      final s = post(
        0,
        extra: [
          ['expiration', '${t0 + 3600}'],
        ],
      );
      expect(s.isExpired(t0 + 3599), false);
      expect(s.isExpired(t0 + 3600), true);
    });

    test('close-friends stories follow the same rule', () {
      final s = post(0, private: true);
      expect(s.isPrivate, true);
      expect(s.isExpired(t0 + 86399), false);
      expect(s.isExpired(t0 + 86400), true);
    });

    test('a story from the future is forgiven a little clock skew only', () {
      final s = post(0);
      expect(s.isExpired(t0 - MediaPost.storyClockSkewSeconds), false);
      expect(s.isExpired(t0 - MediaPost.storyClockSkewSeconds - 1), true);
    });

    test('other posts only obey their own expiration', () {
      final plain = post(0, story: false);
      expect(plain.isExpired(t0 + 10 * 86400), false);
      final expiring = post(
        0,
        story: false,
        extra: [
          ['expiration', '${t0 + 100}'],
        ],
      );
      expect(expiring.isExpired(t0 + 99), false);
      expect(expiring.isExpired(t0 + 100), true);
    });
  });

  group('the rail while the app stays open', () {
    Future<void> signIn(ProviderContainer c) async {
      c.listen(storiesProvider, (_, _) {});
      await eventually(() => !c.read(storiesProvider).isLoading);
    }

    List<String> authors(ProviderContainer c) => [
      for (final g in c.read(storiesProvider).groups) g.author,
    ];

    /// [who] follows [people], as the relays know it.
    Future<void> follows(Signer who, List<Signer> people) async {
      relay.add(
        await signed(
          who,
          kind: NostrKinds.followList,
          createdAt: h.clock.now - 100,
          tags: [
            for (final p in people) ['p', p.publicKey!],
          ],
        ),
      );
    }

    test('a story with no expiration disappears after 24 hours', () async {
      final dave = newSigner();
      final me = newSigner();
      final tagsWithoutExpiry = [
        ['imeta', 'url https://cdn.example.com/s.jpg', 'm image/jpeg'],
        ['L', 'mialuna.story'],
        ['l', 'story', 'mialuna.story'],
      ];
      final s = await h.story(dave, 'senza scadenza', tags: tagsWithoutExpiry);
      relay.add(s.event);
      await follows(me, [dave]);
      final c = h.app(me);
      await signIn(c);
      await eventually(() => authors(c).contains(dave.publicKey));

      h.clock.advance(86400 - 60);
      c.read(storiesProvider.notifier).dropExpired();
      expect(authors(c), contains(dave.publicKey));

      h.clock.advance(61);
      c.read(storiesProvider.notifier).dropExpired();
      expect(authors(c), isEmpty);
    });

    test('a close-friends story goes at the same moment', () async {
      final me = newSigner();
      final c = h.app(me);
      await signIn(c);
      final friend = fixtures.story('f1' * 32, private: true, age: 0);
      final created = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      final rumor = Rumor(
        id: friend.id,
        pubkey: friend.author,
        createdAt: created,
        kind: friend.kind,
        tags: friend.event.tags.where((t) => t.first != 'expiration').toList(),
        content: '',
      );
      expect(c.read(privatePostsProvider.notifier).ingest(rumor), true);
      await eventually(() => authors(c).contains('f1' * 32));

      h.clock.advance(created - h.clock.now + 86400 + 1);
      c.read(storiesProvider.notifier).dropExpired();
      expect(authors(c), isEmpty);
    });

    test('swapping one followed account for another refreshes', () async {
      final me = newSigner();
      final dave = newSigner();
      final erin = newSigner();
      relay.add((await h.story(dave, 'di dave')).event);
      relay.add((await h.story(erin, 'di erin')).event);
      await follows(me, [dave]);
      final c = h.app(me);
      await signIn(c);
      await eventually(() => authors(c).contains(dave.publicKey));
      expect(authors(c), isNot(contains(erin.publicKey)));

      // Same number of people, a different one.
      relay.push(
        await signed(
          me,
          kind: NostrKinds.followList,
          createdAt: h.clock.now,
          tags: [
            ['p', erin.publicKey],
          ],
        ),
      );
      await eventually(
        () => authors(c).contains(erin.publicKey),
        reason: 'the rail kept showing the old follow',
      );
      expect(authors(c), isNot(contains(dave.publicKey)));
    });

    test('a refresh asked for during a load is not swallowed', () async {
      final me = newSigner();
      final c = h.app(me);
      await signIn(c);
      final ctl = c.read(storiesProvider.notifier);

      final before = relay.reqCount;
      await ctl.refresh();
      final perLoad = relay.reqCount - before;
      expect(perLoad, greaterThan(0));

      final start = relay.reqCount;
      final first = ctl.refresh();
      await Future<void>.delayed(const Duration(milliseconds: 50));
      final second = ctl.refresh(); // arrives while the first is running
      await Future.wait([first, second]);
      expect(
        relay.reqCount - start,
        perLoad * 2,
        reason: 'the second request was absorbed by the older load',
      );
    });

    test('one account\'s rail does not carry over to the next', () async {
      final alice = newSigner();
      final bob = newSigner();
      final dave = newSigner();
      relay.add((await h.story(dave, 'di dave')).event);
      await follows(alice, [dave]);
      final auth = SwitchableAuth(alice);
      final c = h.app(alice, auth: auth);
      await signIn(c);
      await eventually(() => authors(c).contains(dave.publicKey));

      auth.switchTo(bob); // Bob follows nobody
      await eventually(() => !c.read(storiesProvider).isLoading);
      expect(
        authors(c),
        isNot(contains(dave.publicKey)),
        reason: 'Alice\'s follows leaked into Bob\'s rail',
      );

      // A load that Alice began and that ends after the switch is ignored.
      auth.switchTo(alice);
      await eventually(() => authors(c).contains(dave.publicKey));
      relay.reqDelay = const Duration(milliseconds: 700);
      final slow = c.read(storiesProvider.notifier).refresh();
      await eventually(() => relay.reqCount > 0);
      auth.switchTo(bob);
      relay.reqDelay = Duration.zero;
      await slow;
      await Future<void>.delayed(const Duration(seconds: 1));
      expect(authors(c), isNot(contains(dave.publicKey)));
    });
  });

  group('what has been watched belongs to whoever watched it', () {
    late NsecSigner alice;
    late NsecSigner bob;

    setUp(() {
      alice = newSigner();
      bob = newSigner();
    });

    Future<void> seen(ProviderContainer c, Set<String> expected) => eventually(
      () => c.read(seenStoriesProvider).containsAll(expected),
      reason: 'expected $expected, have ${c.read(seenStoriesProvider)}',
    );

    test('accounts on the same phone keep separate lists', () async {
      final auth = SwitchableAuth(alice);
      final c = h.app(alice, auth: auth);
      c.listen(seenStoriesProvider, (_, _) {});
      await c.read(seenStoriesProvider.notifier).markSeen('a' * 64);

      auth.switchTo(bob);
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(c.read(seenStoriesProvider), isEmpty);
      await c.read(seenStoriesProvider.notifier).markSeen('b' * 64);
      expect(c.read(seenStoriesProvider), {'b' * 64});

      auth.switchTo(alice);
      await seen(c, {'a' * 64});
      expect(c.read(seenStoriesProvider), isNot(contains('b' * 64)));
    });

    test(
      'a guest has a list of their own, and sign-out hides the rest',
      () async {
        final auth = SwitchableAuth(alice);
        final c = h.app(alice, auth: auth);
        c.listen(seenStoriesProvider, (_, _) {});
        await c.read(seenStoriesProvider.notifier).markSeen('a' * 64);

        auth.switchTo(GuestSigner());
        await Future<void>.delayed(const Duration(milliseconds: 50));
        expect(c.read(seenStoriesProvider), isEmpty);
        await c.read(seenStoriesProvider.notifier).markSeen('c' * 64);

        auth.switchTo(alice);
        await seen(c, {'a' * 64});
        expect(c.read(seenStoriesProvider), isNot(contains('c' * 64)));
      },
    );

    test('a restart brings back the right list', () async {
      final first = h.app(alice);
      first.listen(seenStoriesProvider, (_, _) {});
      await first.read(seenStoriesProvider.notifier).markSeen('a' * 64);
      first.dispose();

      final again = h.app(alice);
      again.listen(seenStoriesProvider, (_, _) {});
      await seen(again, {'a' * 64});

      final other = h.app(bob);
      other.listen(seenStoriesProvider, (_, _) {});
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(other.read(seenStoriesProvider), isEmpty);
    });

    test(
      'the old shared list goes to the first account that signs in',
      () async {
        SharedPreferences.setMockInitialValues({
          'mialuna_seen_stories': ['d' * 64],
        });
        // A guest does not take it.
        final guest = h.app(GuestSigner());
        guest.listen(seenStoriesProvider, (_, _) {});
        await Future<void>.delayed(const Duration(milliseconds: 50));
        expect(guest.read(seenStoriesProvider), isEmpty);
        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getStringList('mialuna_seen_stories'), isNotNull);

        final a = h.app(alice);
        a.listen(seenStoriesProvider, (_, _) {});
        await seen(a, {'d' * 64});
        expect(prefs.getStringList('mialuna_seen_stories'), isNull);
        expect(prefs.getStringList('mialuna_seen_stories_${alice.publicKey}'), [
          'd' * 64,
        ]);

        final b = h.app(bob);
        b.listen(seenStoriesProvider, (_, _) {});
        await Future<void>.delayed(const Duration(milliseconds: 50));
        expect(b.read(seenStoriesProvider), isEmpty);
      },
    );

    test('a list still being read does not overwrite a newer one', () async {
      final gate = Completer<void>();
      final auth = SwitchableAuth(alice);
      SharedPreferences.setMockInitialValues({
        'mialuna_seen_stories_${alice.publicKey}': ['a' * 64],
        'mialuna_seen_stories_${bob.publicKey}': ['b' * 64],
      });
      final c = h.app(
        alice,
        auth: auth,
        overrides: [
          sharedPreferencesLoader.overrideWithValue(() async {
            await gate.future;
            return SharedPreferences.getInstance();
          }),
        ],
      );
      c.listen(seenStoriesProvider, (_, _) {});
      await Future<void>.delayed(const Duration(milliseconds: 20));

      auth.switchTo(bob);
      await Future<void>.delayed(const Duration(milliseconds: 20));
      gate.complete();
      await seen(c, {'b' * 64});
      await Future<void>.delayed(const Duration(milliseconds: 100));
      expect(c.read(seenStoriesProvider), {'b' * 64});
    });

    test('marking before the list is read keeps both', () async {
      final gate = Completer<void>();
      SharedPreferences.setMockInitialValues({
        'mialuna_seen_stories_${alice.publicKey}': ['a' * 64],
      });
      final c = h.app(
        alice,
        overrides: [
          sharedPreferencesLoader.overrideWithValue(() async {
            await gate.future;
            return SharedPreferences.getInstance();
          }),
        ],
      );
      c.listen(seenStoriesProvider, (_, _) {});
      final marking = c.read(seenStoriesProvider.notifier).markSeen('n' * 64);
      gate.complete();
      await marking;
      await seen(c, {'a' * 64, 'n' * 64});
      final prefs = await SharedPreferences.getInstance();
      expect(
        prefs.getStringList('mialuna_seen_stories_${alice.publicKey}'),
        containsAll(['a' * 64, 'n' * 64]),
      );
    });
  });
}
