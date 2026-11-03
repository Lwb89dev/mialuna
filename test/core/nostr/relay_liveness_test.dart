import 'package:flutter_test/flutter_test.dart';
import 'package:mialuna/core/nostr/event.dart';
import 'package:mialuna/core/nostr/filter.dart';
import 'package:mialuna/core/nostr/relay.dart';
import 'package:mialuna/core/nostr/relay_pool.dart';
import 'package:mialuna/core/nostr/signer.dart';

import '../../support/fake_relay.dart';

/// After the phone sleeps, a WebSocket often dies without either side
/// noticing. A refresh sent into it brought nothing back; the pool now asks
/// a quiet relay a question with an instant answer first, and replaces the
/// connection when there is none.
void main() {
  late FakeRelay relay;
  late RelayPool pool;
  late NsecSigner author;

  setUp(() async {
    relay = await FakeRelay().start();
    pool = RelayPool([RelayConfig(relay.url)]);
    author = NsecSigner.fromNsec(NsecSigner.generatePrivateKey());
  });

  tearDown(() async {
    pool.dispose();
    await relay.stop();
  });

  Future<NostrEvent> photo(String text) => signed(
    author,
    kind: 20,
    content: text,
    tags: [
      ['imeta', 'url https://cdn.example.com/$text.jpg', 'm image/jpeg'],
    ],
  );

  /// Opens a subscription for the author's photos and waits for its end of
  /// stored events; returns what arrived.
  Future<List<NostrEvent>> ask({
    Duration eose = const Duration(seconds: 2),
  }) async {
    final got = <NostrEvent>[];
    final sub = pool.subscribe([
      NostrFilter(kinds: const [20], authors: [author.publicKey]),
    ], eoseTimeout: eose);
    final listener = sub.events.listen(got.add);
    await sub.eose;
    await Future<void>.delayed(const Duration(milliseconds: 100));
    await listener.cancel();
    sub.close();
    return got;
  }

  Future<void> connected() async {
    pool.connect();
    await eventually(
      () => pool.statuses.values.every(
        (s) => s == RelayConnectionState.connected,
      ),
    );
  }

  test('a dead connection is replaced before asking', () async {
    await connected();
    relay.add(await photo('nuova'));
    relay.freezeConnections(); // the phone slept

    final before = relay.connectionsAccepted;
    await pool.wake(
      quiet: Duration.zero,
      timeout: const Duration(milliseconds: 400),
    );
    expect(relay.connectionsAccepted, before + 1, reason: 'not replaced');

    final got = await ask();
    expect(got.map((e) => e.content), ['nuova']);
  });

  test('without the check, the same request comes back empty', () async {
    await connected();
    relay.add(await photo('persa'));
    relay.freezeConnections();

    final got = await ask(eose: const Duration(milliseconds: 600));
    expect(got, isEmpty, reason: 'this is what a pull-to-refresh used to see');
  });

  test('a subscription left open on the dead socket is asked again', () async {
    await connected();
    final got = <NostrEvent>[];
    final sub = pool.subscribe([
      NostrFilter(kinds: const [20], authors: [author.publicKey]),
    ]);
    sub.events.listen(got.add);
    await sub.eose;
    relay.freezeConnections();
    relay.push(await photo('mentre dormiva'));
    await Future<void>.delayed(const Duration(milliseconds: 200));
    expect(got, isEmpty);

    await pool.wake(
      quiet: Duration.zero,
      timeout: const Duration(milliseconds: 400),
    );
    await eventually(() => got.isNotEmpty);
    expect(got.single.content, 'mentre dormiva');
    sub.close();
  });

  test('a healthy connection is left alone', () async {
    await connected();
    final before = relay.connectionsAccepted;
    await pool.wake(quiet: Duration.zero, timeout: const Duration(seconds: 2));
    expect(relay.connectionsAccepted, before, reason: 'it answered: kept');
    expect((await ask()).isEmpty, true);
  });

  test('a relay that spoke a moment ago is not even asked', () async {
    await connected();
    await ask(); // it just answered
    final requests = relay.reqCount;
    await pool.wake();
    expect(relay.reqCount, requests);
  });

  test('a relay that is down is reconnected at once', () async {
    await connected();
    await relay.stop();
    relay = await FakeRelay().start(); // a new port: the old url is gone
    // The old relay's url now refuses; wake() must not throw or hang.
    await pool
        .wake(quiet: Duration.zero, timeout: const Duration(milliseconds: 300))
        .timeout(const Duration(seconds: 15));
  });
}
