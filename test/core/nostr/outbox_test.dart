import 'package:flutter_test/flutter_test.dart';
import 'package:mialuna/core/nostr/event.dart';
import 'package:mialuna/core/nostr/nip65.dart';
import 'package:mialuna/core/nostr/outbox.dart';
import 'package:mialuna/core/nostr/relay_pool.dart';

NostrEvent relayList(String pubkey, List<List<String>> tags, {int at = 100}) =>
    NostrEvent(
      id: pubkey.substring(0, 8).padRight(64, '0'),
      pubkey: pubkey,
      createdAt: at,
      kind: NostrKinds.relayList,
      tags: tags,
      content: '',
      sig: '',
    );

void main() {
  final a = 'a' * 64;
  final b = 'b' * 64;
  final c = 'c' * 64;
  late OutboxResolver outbox;

  setUp(() {
    outbox = OutboxResolver(RelayPool(const []));
    outbox.ingest(
      relayList(a, [
        ['r', 'wss://one.example'],
        ['r', 'wss://two.example', 'write'],
        ['r', 'wss://inbox.example', 'read'],
      ]),
    );
    outbox.ingest(
      relayList(b, [
        ['r', 'wss://one.example'],
        ['r', 'wss://three.example'],
      ]),
    );
    outbox.ingest(
      relayList(c, [
        ['r', 'wss://three.example'],
      ]),
    );
  });

  test(
    'write relays are where an author publishes, read relays their inbox',
    () {
      expect(outbox.writeRelays(a), ['wss://one.example', 'wss://two.example']);
      expect(outbox.readRelays(a), [
        'wss://one.example',
        'wss://inbox.example',
      ]);
      expect(outbox.writeRelays('d' * 64), isEmpty);
    },
  );

  test('only the newest list of an author counts', () {
    outbox.ingest(
      relayList(a, [
        ['r', 'wss://old.example'],
      ], at: 50),
    );
    expect(outbox.writeRelays(a), isNot(contains('wss://old.example')));
    outbox.ingest(
      relayList(a, [
        ['r', 'wss://new.example'],
      ], at: 200),
    );
    expect(outbox.writeRelays(a), ['wss://new.example']);
  });

  test('automatic relays are filtered: no localhost, LAN or plain ws', () {
    outbox.ingest(
      relayList(a, [
        ['r', 'wss://good.example'],
        ['r', 'ws://plain.example'],
        ['r', 'wss://127.0.0.1'],
        ['r', 'wss://192.168.0.9'],
      ], at: 300),
    );
    expect(outbox.writeRelays(a), ['wss://good.example']);
  });

  test('plan covers every author with as few relays as possible', () {
    final plan = outbox.plan([a, b, c], maxRelays: 8);
    final covered = plan.values.expand((s) => s).toSet();
    expect(covered, {a, b, c});
    // one.example serves a+b, three.example serves b+c: two relays suffice
    expect(plan.length, lessThanOrEqualTo(2));
  });

  test('plan respects the relay budget', () {
    final plan = outbox.plan([a, b, c], maxRelays: 1);
    expect(plan.length, 1);
  });

  test('survives a save/load cycle', () {
    final restored = OutboxResolver(RelayPool(const []))..load(outbox.toJson());
    expect(restored.writeRelays(a), outbox.writeRelays(a));
    expect(restored.readRelays(b), outbox.readRelays(b));
  });

  group('NIP-65 / BUD-03 tags', () {
    test('markers are written only when a relay is one-directional', () {
      final tags = buildRelayListTags(const [
        RelayConfig('wss://both.example'),
        RelayConfig('wss://r.example', write: false),
        RelayConfig('wss://w.example', read: false),
      ]);
      expect(tags, [
        ['r', 'wss://both.example'],
        ['r', 'wss://r.example', 'read'],
        ['r', 'wss://w.example', 'write'],
      ]);
      // and it round-trips
      final parsed = parseRelayList(relayList(a, tags));
      expect(parsed.map((e) => (e.read, e.write)), [
        (true, true),
        (true, false),
        (false, true),
      ]);
    });

    test('Blossom server list keeps only https servers', () {
      final event = NostrEvent(
        id: 'x' * 64,
        pubkey: a,
        createdAt: 1,
        kind: NostrKinds.blossomServerList,
        tags: [
          ['server', 'https://cdn.example/'],
          ['server', 'http://insecure.example'],
          ['server', 'https://cdn.example'],
          ['server', 'ftp://nope'],
        ],
        content: '',
        sig: '',
      );
      expect(parseBlossomServerList(event), ['https://cdn.example']);
    });
  });
}
