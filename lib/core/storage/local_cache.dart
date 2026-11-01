import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../nostr/event.dart';

/// Simple JSON-file local cache for events and drafts. Keeps the app usable
/// offline and preserves composer drafts across relay/upload failures.
/// Planned replacement: Drift/SQLite (see docs/ARCHITECTURE.md).
class LocalCache {
  static const _eventsFile = 'events_cache.json';
  static const _draftsFile = 'drafts.json';
  static const _maxCachedEvents = 2000;

  Future<File> _file(String name) async {
    final dir = await getApplicationSupportDirectory();
    return File('${dir.path}/$name');
  }

  Future<void> saveEvents(List<NostrEvent> events) async {
    try {
      final file = await _file(_eventsFile);
      final trimmed = events.length > _maxCachedEvents
          ? events.sublist(0, _maxCachedEvents)
          : events;
      await file.writeAsString(
        jsonEncode([for (final e in trimmed) e.toJson()]),
      );
    } catch (_) {
      // Cache failures must never break the app.
    }
  }

  Future<List<NostrEvent>> loadEvents() async {
    try {
      final file = await _file(_eventsFile);
      if (!file.existsSync()) return [];
      final list = jsonDecode(await file.readAsString()) as List;
      return [
        for (final j in list) NostrEvent.fromJson(j as Map<String, dynamic>),
      ];
    } catch (_) {
      return [];
    }
  }

  Future<void> saveDraft(String key, Map<String, dynamic> draft) async {
    try {
      final drafts = await loadDrafts();
      drafts[key] = draft;
      final file = await _file(_draftsFile);
      await file.writeAsString(jsonEncode(drafts));
    } catch (_) {}
  }

  Future<Map<String, dynamic>> loadDrafts() async {
    try {
      final file = await _file(_draftsFile);
      if (!file.existsSync()) return {};
      return Map<String, dynamic>.from(
        jsonDecode(await file.readAsString()) as Map,
      );
    } catch (_) {
      return {};
    }
  }

  Future<void> deleteDraft(String key) async {
    try {
      final drafts = await loadDrafts();
      drafts.remove(key);
      final file = await _file(_draftsFile);
      await file.writeAsString(jsonEncode(drafts));
    } catch (_) {}
  }
}
