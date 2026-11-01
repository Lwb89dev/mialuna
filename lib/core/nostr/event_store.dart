import 'event.dart';

/// In-memory event store with deduplication and replaceable-event handling.
/// Acts as the app's hot cache; persistence to disk happens in
/// `core/storage/local_cache.dart`.
class EventStore {
  final Map<String, NostrEvent> _byId = {};
  final Map<String, NostrEvent> _replaceable = {}; // kind:pubkey -> newest

  /// Returns true when the event was newly stored (not a duplicate and not
  /// superseded by a newer replaceable event).
  bool add(NostrEvent event) {
    if (_isReplaceable(event.kind)) {
      final key = '${event.kind}:${event.pubkey}';
      final existing = _replaceable[key];
      if (existing != null && existing.createdAt >= event.createdAt) {
        return false;
      }
      _replaceable[key] = event;
      _byId[event.id] = event;
      return true;
    }
    if (_byId.containsKey(event.id)) return false;
    _byId[event.id] = event;
    return true;
  }

  int addAll(Iterable<NostrEvent> events) {
    var count = 0;
    for (final e in events) {
      if (add(e)) count++;
    }
    return count;
  }

  NostrEvent? byId(String id) => _byId[id];

  NostrEvent? latestReplaceable(int kind, String pubkey) =>
      _replaceable['$kind:$pubkey'];

  List<NostrEvent> query({List<int>? kinds, int? limit}) {
    var events = _byId.values.toList();
    if (kinds != null) {
      events = events.where((e) => kinds.contains(e.kind)).toList();
    }
    events.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    if (limit != null && events.length > limit) {
      events = events.sublist(0, limit);
    }
    return events;
  }

  int get length => _byId.length;

  void clear() {
    _byId.clear();
    _replaceable.clear();
  }

  static bool _isReplaceable(int kind) =>
      kind == 0 ||
      kind == 3 ||
      (kind >= 10000 && kind < 20000) ||
      kind >= 30000;
}
