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

  /// The last operation queued on each file. Two writers sharing one `.tmp`
  /// file could interleave and leave truncated JSON behind (typing a caption
  /// saves a draft on every keystroke), so every operation on a file waits
  /// for the previous one.
  static final Map<String, Future<void>> _tails = {};

  Future<T> _exclusive<T>(File file, Future<T> Function() op) {
    final path = file.path;
    final run = (_tails[path] ?? Future<void>.value()).then((_) => op());
    final tail = run.then<void>((_) {}, onError: (_) {});
    _tails[path] = tail;
    tail.whenComplete(() {
      if (identical(_tails[path], tail)) _tails.remove(path);
    });
    return run;
  }

  /// Atomic write: a crash mid-write never leaves a truncated cache.
  Future<void> writeJson(String name, Object? json) async {
    try {
      final file = await _file(name);
      await _exclusive(file, () => _writeNow(file, json));
    } catch (_) {
      // Cache failures must never break the app.
    }
  }

  Future<void> _writeNow(File file, Object? json) async {
    final tmp = File('${file.path}.tmp');
    await tmp.writeAsString(jsonEncode(json), flush: true);
    await tmp.rename(file.path);
  }

  Future<Object?> readJson(String name) async {
    try {
      final file = await _file(name);
      return await _exclusive(file, () => _readNow(file));
    } catch (_) {
      return null;
    }
  }

  Future<Object?> _readNow(File file) async {
    if (!file.existsSync()) return null;
    return jsonDecode(await file.readAsString());
  }

  Future<void> deleteFile(String name) async {
    try {
      final file = await _file(name);
      await _exclusive(file, () async {
        if (file.existsSync()) await file.delete();
      });
    } catch (_) {}
  }

  /// Story view receipts this account still has to send (see
  /// `story_receipts.dart`).
  static String storyReceiptsFile(String pubkey) =>
      'story_receipts_$pubkey.json';

  /// The files that hold one account's data on this device: decrypted
  /// messages, close-friends posts and list, follows, notifications, story
  /// views, story receipts waiting to be sent, web of trust. All of them go
  /// when the account signs out.
  static List<String> accountFiles(String pubkey) => [
    'dm_$pubkey.json',
    'private_posts_$pubkey.json',
    'close_friends_$pubkey.json',
    'follows_$pubkey.json',
    'notifications_$pubkey.json',
    'story_views_$pubkey.json',
    storyReceiptsFile(pubkey),
    'wot_$pubkey.json',
  ];

  static const draftsFile = 'drafts.json';

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

  /// The same, for a cache that belongs to one account (the Home feed): what
  /// was saved for somebody else is never shown, so it can be painted at
  /// once at start-up without waiting to learn whom the account follows.
  Future<void> saveOwnedEvents(
    String owner,
    List<NostrEvent> events, {
    required String file,
  }) async {
    final trimmed = events.length > _maxCachedEvents
        ? events.sublist(0, _maxCachedEvents)
        : events;
    await writeJson(file, {
      'owner': owner,
      'events': [for (final e in trimmed) e.toJson()],
    });
  }

  Future<List<NostrEvent>> loadOwnedEvents(
    String owner, {
    required String file,
  }) async {
    final json = await readJson(file);
    // A list is the old format, which did not say whose it was.
    if (json is! Map || json['owner'] != owner) return [];
    final list = json['events'];
    if (list is! List) return [];
    final out = <NostrEvent>[];
    for (final j in list) {
      try {
        out.add(NostrEvent.fromJson(j as Map<String, dynamic>));
      } catch (_) {}
    }
    return out;
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

  Future<void> saveDraft(String key, Map<String, dynamic> draft) =>
      _editDrafts((drafts) => drafts[key] = draft);

  Future<Map<String, dynamic>> loadDrafts() async {
    final json = await readJson(_draftsFile);
    return json is Map ? Map<String, dynamic>.from(json) : {};
  }

  Future<void> deleteDraft(String key) =>
      _editDrafts((drafts) => drafts.remove(key));

  /// Read-modify-write of the drafts file as one step, so a late
  /// `saveDraft` can never bring back a draft that was just deleted.
  Future<void> _editDrafts(void Function(Map<String, dynamic>) edit) async {
    try {
      final file = await _file(_draftsFile);
      await _exclusive(file, () async {
        Object? json;
        try {
          json = await _readNow(file);
        } catch (_) {}
        final drafts = json is Map
            ? Map<String, dynamic>.from(json)
            : <String, dynamic>{};
        edit(drafts);
        await _writeNow(file, drafts);
      });
    } catch (_) {}
  }
}
