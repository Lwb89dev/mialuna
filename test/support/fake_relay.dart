import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:mialuna/core/nostr/event.dart';
import 'package:mialuna/core/nostr/filter.dart';
import 'package:mialuna/core/nostr/signer.dart';

/// A real WebSocket relay on localhost, just enough of NIP-01 (and NIP-42)
/// to exercise the pool and the private-message flow end to end.
class FakeRelay {
  final List<NostrEvent> stored = [];
  final List<String> closedSubscriptions = [];
  int reqCount = 0;

  /// Kinds that need a NIP-42 AUTH before they are served or accepted.
  final Set<int> authKinds;

  /// When set, every published event is refused with this message.
  String? rejectWith;

  late HttpServer _server;
  final List<_Conn> _conns = [];

  FakeRelay({this.authKinds = const {}});

  String get url => 'ws://127.0.0.1:${_server.port}';

  Future<FakeRelay> start() async {
    _server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    _server.listen((request) async {
      final socket = await WebSocketTransformer.upgrade(request);
      final conn = _Conn(socket)..challenge = 'challenge-${_conns.length}';
      _conns.add(conn);
      if (authKinds.isNotEmpty) conn.send(['AUTH', conn.challenge]);
      socket.listen(
        (raw) => _onMessage(conn, raw as String),
        onDone: () {
          _conns.remove(conn);
        },
      );
    });
    return this;
  }

  Future<void> stop() async {
    for (final c in List.of(_conns)) {
      await c.socket.close();
    }
    await _server.close(force: true);
  }

  void add(NostrEvent event) => stored.add(event);

  /// Stores [event] and delivers it to live subscriptions (as if a client
  /// had just published it).
  void push(NostrEvent event) {
    stored.add(event);
    for (final c in _conns) {
      for (final entry in c.subs.entries) {
        if (entry.value.any((f) => f.matches(event))) {
          c.send(['EVENT', entry.key, event.toJson()]);
        }
      }
    }
  }

  void _onMessage(_Conn conn, String raw) {
    final msg = jsonDecode(raw) as List;
    switch (msg[0]) {
      case 'REQ':
        reqCount++;
        final id = msg[1] as String;
        final filters = [
          for (final f in msg.skip(2)) _filterFrom(f as Map<String, dynamic>),
        ];
        final needsAuth = filters.any(
          (f) => (f.filter.kinds ?? const []).any(authKinds.contains),
        );
        if (needsAuth && !conn.authed) {
          conn.send(['CLOSED', id, 'auth-required: authenticate first']);
          return;
        }
        conn.subs[id] = filters;
        for (final e in stored) {
          if (filters.any((f) => f.matches(e))) {
            conn.send(['EVENT', id, e.toJson()]);
          }
        }
        conn.send(['EOSE', id]);
      case 'CLOSE':
        closedSubscriptions.add(msg[1] as String);
        conn.subs.remove(msg[1]);
      case 'EVENT':
        final event = NostrEvent.fromJson(msg[1] as Map<String, dynamic>);
        if (rejectWith != null) {
          conn.send(['OK', event.id, false, rejectWith]);
          return;
        }
        if (authKinds.contains(event.kind) && !conn.authed) {
          conn.send([
            'OK',
            event.id,
            false,
            'auth-required: authenticate first',
          ]);
          return;
        }
        if (!verifyEventSignature(event)) {
          conn.send(['OK', event.id, false, 'invalid: bad signature']);
          return;
        }
        stored.add(event);
        conn.send(['OK', event.id, true, '']);
        for (final c in _conns) {
          for (final entry in c.subs.entries) {
            if (entry.value.any((f) => f.matches(event))) {
              c.send(['EVENT', entry.key, event.toJson()]);
            }
          }
        }
      case 'AUTH':
        final event = NostrEvent.fromJson(msg[1] as Map<String, dynamic>);
        final ok =
            event.kind == 22242 &&
            verifyEventSignature(event) &&
            event.firstTagValue('challenge') == conn.challenge;
        conn.authed = ok;
        conn.send(['OK', event.id, ok, ok ? '' : 'invalid: bad auth']);
    }
  }

  static _F _filterFrom(Map<String, dynamic> j) => _F(
    NostrFilter(
      ids: (j['ids'] as List?)?.cast<String>(),
      authors: (j['authors'] as List?)?.cast<String>(),
      kinds: (j['kinds'] as List?)?.cast<int>(),
      since: j['since'] as int?,
      until: j['until'] as int?,
      limit: j['limit'] as int?,
      tagFilters: {
        for (final e in j.entries)
          if (e.key.startsWith('#')) e.key: (e.value as List).cast<String>(),
      },
    ),
    j['search'] as String?,
  );
}

/// A filter plus NIP-50 `search` (substring match on the event content).
class _F {
  final NostrFilter filter;
  final String? search;
  _F(this.filter, this.search);

  bool matches(NostrEvent e) =>
      filter.matches(e) &&
      (search == null ||
          e.content.toLowerCase().contains(search!.toLowerCase()));
}

class _Conn {
  final WebSocket socket;
  final Map<String, List<_F>> subs = {};
  bool authed = false;
  String challenge = '';
  _Conn(this.socket);
  void send(Object message) {
    try {
      socket.add(jsonEncode(message));
    } catch (_) {
      // The client already left (a test tore its app down): nothing to tell.
    }
  }
}

/// A signed event for tests.
Future<NostrEvent> signed(
  Signer signer, {
  int kind = 20,
  List<List<String>> tags = const [],
  String content = '',
  int? createdAt,
}) => signer.signEvent(
  kind: kind,
  tags: tags,
  content: content,
  createdAt: createdAt,
);

/// Polls until [condition] holds (or fails the test after [timeout]).
Future<void> eventually(
  bool Function() condition, {
  Duration timeout = const Duration(seconds: 8),
  String? reason,
}) async {
  final end = DateTime.now().add(timeout);
  while (!condition()) {
    if (DateTime.now().isAfter(end)) {
      throw TimeoutException(reason ?? 'condition not met in $timeout');
    }
    await Future<void>.delayed(const Duration(milliseconds: 25));
  }
}
