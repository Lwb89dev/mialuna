import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../nostr/event.dart';

/// Simple JSON-file local cache for events, profiles, conversations and
/// drafts. Keeps the app usable offline and preserves composer drafts across
/// relay/upload failures. Files live in the app-private support directory.
/// Planned replacement: Drift/SQLite (see docs/ARCHITECTURE.md).
class LocalCache {
  static const _eventsFile = 'events_cache.json';
  static const _draftsFile = 'drafts.json';
  static const _profilesFile = 'profiles_cache.json';
  static const _maxCachedEvents = 2000;
  static const _maxCachedProfiles = 600;

  /// Overrides the storage directory (tests).
  final Directory? directory;

  LocalCache({this.directory});

  Future<File> _file(String name) async {
    final dir = directory ?? await getApplicationSupportDirectory();
    return File('${dir.path}/$name');
  }

  /// Atomic write: a crash mid-write never leaves a truncated cache.
  Future<void> writeJson(String name, Object? json) async {
    try {
      final file = await _file(name);
      final tmp = File('${file.path}.tmp');
      await tmp.writeAsString(jsonEncode(json), flush: true);
      await tmp.rename(file.path);
    } catch (_) {
      // Cache failures must never break the app.
    }
  }

  Future<Object?> readJson(String name) async {
    try {
      final file = await _file(name);
      if (!file.existsSync()) return null;
      return jsonDecode(await file.readAsString());
    } catch (_) {
      return null;
    }
  }

  Future<void> deleteFile(String name) async {
    try {
      final file = await _file(name);
      if (file.existsSync()) await file.delete();
    } catch (_) {}
  }

  /// Event cache files, one per feed so "following" and "discover" never mix.
  static const followingEventsFile = 'events_following.json';
  static const discoverEventsFile = 'events_discover.json';

  Future<void> saveEvents(
    List<NostrEvent> events, {
    String file = _eventsFile,
  }) async {
    final trimmed = events.length > _maxCachedEvents
        ? events.sublist(0, _maxCachedEvents)
        : events;
    await writeJson(file, [for (final e in trimmed) e.toJson()]);
  }

  /// Wipes every cached feed.
  Future<void> clearEvents() async {
    for (final f in [_eventsFile, followingEventsFile, discoverEventsFile]) {
      await deleteFile(f);
    }
  }

  Future<List<NostrEvent>> loadEvents({String file = _eventsFile}) async {
    final list = await readJson(file);
    if (list is! List) return [];
    final out = <NostrEvent>[];
    for (final j in list) {
      try {
        out.add(NostrEvent.fromJson(j as Map<String, dynamic>));
      } catch (_) {}
    }
    return out;
  }

  Future<void> saveProfiles(List<Map<String, dynamic>> profiles) async {
    final trimmed = profiles.length > _maxCachedProfiles
        ? profiles.sublist(0, _maxCachedProfiles)
        : profiles;
    await writeJson(_profilesFile, trimmed);
  }

  Future<List<Map<String, dynamic>>> loadProfiles() async {
    final list = await readJson(_profilesFile);
    if (list is! List) return [];
    return [
      for (final j in list)
        if (j is Map<String, dynamic>) j,
    ];
  }

  Future<void> saveDraft(String key, Map<String, dynamic> draft) async {
    final drafts = await loadDrafts();
    drafts[key] = draft;
    await writeJson(_draftsFile, drafts);
  }

  Future<Map<String, dynamic>> loadDrafts() async {
    final json = await readJson(_draftsFile);
    return json is Map ? Map<String, dynamic>.from(json) : {};
  }

  Future<void> deleteDraft(String key) async {
    final drafts = await loadDrafts();
    drafts.remove(key);
    await writeJson(_draftsFile, drafts);
  }
}
