import 'package:flutter_test/flutter_test.dart';
import 'package:mialuna/core/nostr/event.dart';
import 'package:mialuna/core/nostr/filter.dart';
import 'package:mialuna/core/nostr/relay.dart';
import 'package:mialuna/core/nostr/relay_pool.dart';
import 'package:mialuna/core/nostr/signer.dart';

import '../../support/fake_relay.dart';

void main() {
  late NsecSigner alice;
  late List<FakeRelay> relays;

  setUp(() {
    alice = NsecSigner.fromNsec(NsecSigner.generatePrivateKey());
    relays = [];
  });

  tearDown(() async {
    for (final r in relays) {
      await r.stop();
    }
  });

  Future<FakeRelay> startRelay({Set<int> authKinds = const {}}) async {
    final r = await FakeRelay(authKinds: authKinds).start();
    relays.add(r);
    return r;
  }

  Future<List<NostrEvent>> collect(PoolSubscription sub) async {
    final out = <NostrEvent>[];
    final l = sub.events.listen(out.add);
    await sub.eose;
    await Future<void>.delayed(const Duration(milliseconds: 150));
    await l.cancel();
    return out;
  }

  group('RelayPool subscriptions', () {
    test('delivers stored events and reports EOSE', () async {
      final relay = await startRelay();
      relay.add(await signed(alice, content: 'one'));
      relay.add(await signed(alice, content: 'two'));
      final pool = RelayPool([RelayConfig(relay.url)]);
      addTearDown(pool.dispose);

      final events = await collect(
        pool.subscribe([
          const NostrFilter(kinds: [20]),
        ]),
      );
      expect(events.map((e) => e.content).toSet(), {'one', 'two'});
    });

    test('a second subscription still receives events the first already '
        'saw (no global dedup — this blocked pull-to-refresh)', () async {
      final relay = await startRelay();
      relay.add(await signed(alice, content: 'seen'));
      final pool = RelayPool([RelayConfig(relay.url)]);
      addTearDown(pool.dispose);

      final first = await collect(
        pool.subscribe([
          const NostrFilter(kinds: [20]),
        ]),
      );
      final second = await collect(
        pool.subscribe([
          const NostrFilter(kinds: [20]),
        ]),
      );
      expect(first, hasLength(1));
      expect(second, hasLength(1));
      expect(second.single.id, first.single.id);
    });

    test('the same event from two relays is delivered once', () async {
      final a = await startRelay();
      final b = await startRelay();
      final event = await signed(alice, content: 'dup');
      a.add(event);
      b.add(event);
      final pool = RelayPool([RelayConfig(a.url), RelayConfig(b.url)]);
      addTearDown(pool.dispose);

      final events = await collect(
        pool.subscribe([
          const NostrFilter(kinds: [20]),
        ]),
      );
      expect(events, hasLength(1));
    });

    test('events with a bad signature are dropped', () async {
      final relay = await startRelay();
      final good = await signed(alice, content: 'good');
      final real = await signed(alice, content: 'forged');
      // Same id/sig, content swapped after signing.
      final forged = NostrEvent(
        id: real.id,
        pubkey: real.pubkey,
        createdAt: real.createdAt,
        kind: real.kind,
        tags: real.tags,
        content: 'tampered',
        sig: real.sig,
      );
      relay.add(good);
      relay.add(forged);
      final pool = RelayPool([RelayConfig(relay.url)]);
      addTearDown(pool.dispose);

      final events = await collect(
        pool.subscribe([
          const NostrFilter(kinds: [20]),
        ]),
      );
      expect(events.map((e) => e.content), ['good']);
    });

    test('a known id does not authenticate a tampered copy', () async {
      final relay = await startRelay();
      final real = await signed(alice, content: 'authentic');
      final forged = NostrEvent(
        id: real.id,
        pubkey: real.pubkey,
        createdAt: real.createdAt,
        kind: real.kind,
        tags: real.tags,
        content: 'tampered',
        sig: real.sig,
      );
      relay.add(real);
      final pool = RelayPool([RelayConfig(relay.url)]);
      addTearDown(pool.dispose);

      final first = await collect(
        pool.subscribe([
          const NostrFilter(kinds: [20]),
        ]),
      );
      expect(first.single.content, 'authentic');
      relay.stored
        ..clear()
        ..add(forged);
      final second = await collect(
        pool.subscribe([
          const NostrFilter(kinds: [20]),
        ]),
      );
      expect(second, isEmpty);
    });

    test(
      'a forged copy cannot hide the authentic one in the same batch',
      () async {
        final hostile = await startRelay();
        final honest = await startRelay()
          ..reqDelay = const Duration(milliseconds: 10);
        final real = await signed(alice, content: 'authentic');
        hostile.add(
          NostrEvent(
            id: real.id,
            pubkey: real.pubkey,
            createdAt: real.createdAt,
            kind: real.kind,
            tags: real.tags,
            content: 'tampered',
            sig: real.sig,
          ),
        );
        honest.add(real);
        final pool = RelayPool([
          RelayConfig(hostile.url),
          RelayConfig(honest.url),
        ]);
        addTearDown(pool.dispose);

        final events = await collect(
          pool.subscribe([
            const NostrFilter(kinds: [20]),
          ]),
        );
        expect(events.single.content, 'authentic');
      },
    );

    test('events that do not match the filter are ignored', () async {
      final relay = await startRelay();
      relay.add(await signed(alice, kind: 1, content: 'a note'));
      relay.add(await signed(alice, kind: 20, content: 'a photo'));
      final pool = RelayPool([RelayConfig(relay.url)]);
      addTearDown(pool.dispose);

      // The relay is asked for photos only; kind 1 must never surface.
      final events = await collect(
        pool.subscribe([
          const NostrFilter(kinds: [20]),
        ]),
      );
      expect(events.map((e) => e.kind).toSet(), {20});
    });

    test('closing a subscription tells the relay', () async {
      final relay = await startRelay();
      final pool = RelayPool([RelayConfig(relay.url)]);
      addTearDown(pool.dispose);
      final sub = pool.subscribe([
        const NostrFilter(kinds: [20]),
      ]);
      await sub.eose;
      sub.close();
      await eventually(() => relay.closedSubscriptions.contains(sub.id));
    });

    test('updateRelays joins open subscriptions without rebuilding the '
        'pool (settings changes no longer kill the feed)', () async {
      final a = await startRelay();
      final b = await startRelay();
      b.add(await signed(alice, content: 'only on b'));
      final pool = RelayPool([RelayConfig(a.url)]);
      addTearDown(pool.dispose);

      final sub = pool.subscribe([
        const NostrFilter(kinds: [20]),
      ]);
      final got = <NostrEvent>[];
      sub.events.listen(got.add);
      await sub.eose;
      expect(got, isEmpty);

      pool.updateRelays([RelayConfig(a.url), RelayConfig(b.url)]);
      await eventually(() => got.isNotEmpty, reason: 'new relay never joined');
      expect(got.single.content, 'only on b');
      sub.close();
    });

    test(
      'read/write roles pick relays for subscribing and publishing',
      () async {
        final reader = await startRelay();
        final writer = await startRelay();
        reader.add(await signed(alice, content: 'r'));
        writer.add(await signed(alice, content: 'w'));
        final pool = RelayPool([
          RelayConfig(reader.url, write: false),
          RelayConfig(writer.url, read: false),
        ]);
        addTearDown(pool.dispose);

        final events = await collect(
          pool.subscribe([
            const NostrFilter(kinds: [20]),
          ]),
        );
        expect(events.map((e) => e.content), ['r']);

        final report = await pool.publish(await signed(alice, content: 'out'));
        expect(report.relayResults.keys, [writer.url]);
        expect(writer.stored.any((e) => e.content == 'out'), true);
        expect(reader.stored.any((e) => e.content == 'out'), false);
      },
    );

    test('a subscription with no relay completes immediately', () async {
      final pool = RelayPool(const []);
      addTearDown(pool.dispose);
      await pool
          .subscribe([
            const NostrFilter(kinds: [20]),
          ])
          .eose
          .timeout(const Duration(seconds: 2));
    });
  });

  group('RelayPool publishing', () {
    test('reports each relay on its own', () async {
      final ok = await startRelay();
      final refusing = await startRelay()
        ..rejectWith = 'blocked: not allowed';
      final pool = RelayPool([
        RelayConfig(ok.url),
        RelayConfig(refusing.url),
        const RelayConfig('ws://127.0.0.1:1'), // nothing listens here
      ]);
      addTearDown(pool.dispose);

      final report = await pool.publish(await signed(alice, content: 'hi'));
      expect(report.relayResults[ok.url], true);
      expect(report.relayResults[refusing.url], false);
      expect(report.relayMessages[refusing.url], 'blocked: not allowed');
      expect(report.relayResults['ws://127.0.0.1:1'], false);
      expect(report.publishedSomewhere, true);
      expect(report.acceptedCount, 1);
    });

    test('nothing accepted means not published', () async {
      final refusing = await startRelay()
        ..rejectWith = 'rate-limited: slow down';
      final pool = RelayPool([RelayConfig(refusing.url)]);
      addTearDown(pool.dispose);
      final report = await pool.publish(await signed(alice));
      expect(report.publishedSomewhere, false);
      expect(report.firstFailureReason, contains('rate-limited'));
    });
  });

  group('NIP-42', () {
    test('answers AUTH and then receives gift wraps', () async {
      final relay = await startRelay(authKinds: {1059});
      final bob = NsecSigner.fromNsec(NsecSigner.generatePrivateKey());
      relay.add(
        await signed(
          alice,
          kind: 1059,
          tags: [
            ['p', bob.publicKey],
          ],
          content: 'wrapped',
        ),
      );
      final pool = RelayPool([RelayConfig(relay.url)]);
      addTearDown(pool.dispose);
      pool.authSigner = (url, challenge) => bob.signEvent(
        kind: 22242,
        tags: [
          ['relay', url],
          ['challenge', challenge],
        ],
        content: '',
      );

      final sub = pool.subscribe([
        NostrFilter(
          kinds: const [1059],
          tagFilters: {
            '#p': [bob.publicKey],
          },
        ),
      ], authRequired: true);
      final got = <NostrEvent>[];
      sub.events.listen(got.add);
      await eventually(
        () => got.isNotEmpty,
        reason: 'AUTH flow never completed',
      );
      expect(got.single.content, 'wrapped');
      sub.close();
    });

    test('without a signer the relay simply serves nothing', () async {
      final relay = await startRelay(authKinds: {1059});
      final pool = RelayPool([RelayConfig(relay.url)]);
      addTearDown(pool.dispose);
      final events = await collect(
        pool.subscribe([
          const NostrFilter(kinds: [1059]),
        ]),
      );
      expect(events, isEmpty);
    });
  });

  group('relay URLs', () {
    test('normalizes and validates', () {
      expect(
        normalizeRelayUrl('WSS://Relay.Example.com/'),
        'wss://relay.example.com',
      );
      expect(normalizeRelayUrl('relay.example.com'), 'wss://relay.example.com');
      expect(normalizeRelayUrl('https://relay.example.com'), isNull);
      expect(normalizeRelayUrl(''), isNull);
    });

    test('automatic relays must be public wss hosts', () {
      expect(isSafeRemoteRelayUrl('wss://relay.damus.io'), true);
      expect(isSafeRemoteRelayUrl('ws://relay.damus.io'), false);
      expect(isSafeRemoteRelayUrl('wss://localhost'), false);
      expect(isSafeRemoteRelayUrl('wss://127.0.0.1'), false);
      expect(isSafeRemoteRelayUrl('wss://192.168.1.10'), false);
      expect(isSafeRemoteRelayUrl('wss://10.0.0.5'), false);
      expect(isSafeRemoteRelayUrl('wss://printer.local'), false);
    });
  });
}
