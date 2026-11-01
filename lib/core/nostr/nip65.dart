import 'event.dart';
import 'relay.dart';
import 'relay_pool.dart';

/// NIP-65 relay list metadata (kind 10002).
class RelayListEntry {
  final String url;
  final bool read;
  final bool write;
  const RelayListEntry(this.url, {this.read = true, this.write = true});
}

/// Parses the `r` tags of a kind 10002 event. A missing marker means the
/// relay is used for both reading and writing (NIP-65).
List<RelayListEntry> parseRelayList(NostrEvent event) {
  if (event.kind != 10002) return const [];
  final seen = <String>{};
  final entries = <RelayListEntry>[];
  for (final tag in event.tags) {
    if (tag.length < 2 || tag[0] != 'r') continue;
    final url = normalizeRelayUrl(tag[1]);
    if (url == null || !seen.add(url)) continue;
    final marker = tag.length > 2 ? tag[2] : null;
    entries.add(
      RelayListEntry(url, read: marker != 'write', write: marker != 'read'),
    );
  }
  return entries;
}

List<RelayConfig> relayListToConfigs(Iterable<RelayListEntry> entries) => [
  for (final e in entries) RelayConfig(e.url, read: e.read, write: e.write),
];

/// `r` tags for a kind 10002 event; the marker is omitted when a relay is
/// used for both directions.
List<List<String>> buildRelayListTags(Iterable<RelayConfig> relays) => [
  for (final r in relays)
    if (r.read || r.write)
      [
        'r',
        r.url,
        if (r.read && !r.write) 'read',
        if (r.write && !r.read) 'write',
      ],
];

/// Relays an author publishes to (NIP-65 "outbox"): where their posts live.
List<String> writeRelaysOf(NostrEvent relayList) => [
  for (final e in parseRelayList(relayList))
    if (e.write) e.url,
];

/// Relays an author reads from: where to deliver things addressed to them.
List<String> readRelaysOf(NostrEvent relayList) => [
  for (final e in parseRelayList(relayList))
    if (e.read) e.url,
];

/// BUD-03 user server list (kind 10063): `server` tags with https URLs.
List<String> parseBlossomServerList(NostrEvent event) {
  if (event.kind != NostrKinds.blossomServerList) return const [];
  final out = <String>[];
  for (final tag in event.tags) {
    if (tag.length < 2 || tag[0] != 'server') continue;
    final uri = Uri.tryParse(tag[1].trim());
    if (uri == null || uri.scheme != 'https' || uri.host.isEmpty) continue;
    final url = tag[1].trim().replaceAll(RegExp(r'/+$'), '');
    if (!out.contains(url)) out.add(url);
  }
  return out;
}

List<List<String>> buildBlossomServerTags(Iterable<String> servers) => [
  for (final s in servers) ['server', s],
];

/// The newest event of [kind] in [events], or null.
NostrEvent? newestOfKind(Iterable<NostrEvent> events, int kind) {
  NostrEvent? best;
  for (final e in events) {
    if (e.kind != kind) continue;
    if (best == null || e.createdAt > best.createdAt) best = e;
  }
  return best;
}
