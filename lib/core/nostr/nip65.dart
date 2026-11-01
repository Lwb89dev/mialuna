import 'dart:async';

import 'event.dart';
import 'filter.dart';
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
    final url = tag[1].trim();
    if (!url.startsWith('wss://') && !url.startsWith('ws://')) continue;
    if (!seen.add(url)) continue;
    final marker = tag.length > 2 ? tag[2] : null;
    entries.add(
      RelayListEntry(url, read: marker != 'write', write: marker != 'read'),
    );
  }
  return entries;
}

/// Fetches the user's newest relay list from a bootstrap relay set.
/// Returns null on timeout or when the user has never published one.
Future<NostrEvent?> fetchLatestRelayList(
  List<String> bootstrapRelays,
  String pubkey, {
  Duration timeout = const Duration(seconds: 5),
}) async {
  final pool = RelayPool(bootstrapRelays);
  pool.connect();
  try {
    final (:id, :stream) = pool.subscribe([
      NostrFilter(kinds: const [10002], authors: [pubkey], limit: 5),
    ]);
    NostrEvent? newest;
    final sub = stream.listen((event) {
      if (newest == null || event.createdAt > newest!.createdAt) {
        newest = event;
      }
    });
    await Future<void>.delayed(timeout);
    await sub.cancel();
    pool.unsubscribe(id);
    return newest;
  } finally {
    await pool.dispose();
  }
}
