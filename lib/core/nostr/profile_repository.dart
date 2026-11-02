import 'dart:async';
import 'dart:convert';

import 'event.dart';
import 'filter.dart';
import 'nip19.dart';
import 'relay_pool.dart';

/// NIP-01 kind 0 profile metadata.
class ProfileMetadata {
  final String pubkey;
  final String? name;
  final String? displayName;
  final String? about;
  final String? picture;
  final String? banner;
  final String? nip05;
  final String? lud16;
  final String? lud06;
  final String? website;

  /// `created_at` of the kind 0 event this was parsed from.
  final int createdAt;

  const ProfileMetadata({
    required this.pubkey,
    this.name,
    this.displayName,
    this.about,
    this.picture,
    this.banner,
    this.nip05,
    this.lud16,
    this.lud06,
    this.website,
    this.createdAt = 0,
  });

  /// The name the person gave themselves, null when they set none.
  String? get givenName => displayName?.isNotEmpty == true
      ? displayName
      : name?.isNotEmpty == true
      ? name
      : null;

  /// Best human-readable name, never empty: the person's own, or their
  /// shortened npub.
  String get label => givenName ?? shortNpub(pubkey);

  /// `@handle` style secondary name when it differs from [label].
  String? get handle {
    final n = name;
    if (n == null || n.isEmpty || n == label) return null;
    return '@$n';
  }

  /// `npub1abcdefghij…xyz123`: what stands for a person with no name. Falls
  /// back to the start of the hex key for something that is not a pubkey.
  static String shortNpub(String pubkey) {
    try {
      final npub = Nip19.encodeNpub(pubkey);
      return '${npub.substring(0, 14)}…${npub.substring(npub.length - 6)}';
    } catch (_) {
      return pubkey.length >= 8 ? '${pubkey.substring(0, 8)}…' : pubkey;
    }
  }

  static String? _str(dynamic v) {
    if (v == null) return null;
    final s = v.toString().trim();
    return s.isEmpty ? null : s;
  }

  static String? _url(dynamic v) {
    final s = _str(v);
    if (s == null) return null;
    final uri = Uri.tryParse(s);
    if (uri == null || (uri.scheme != 'https' && uri.scheme != 'http')) {
      return null;
    }
    return s;
  }

  static ProfileMetadata fromEvent(NostrEvent event) {
    Map<String, dynamic> json;
    try {
      final decoded = jsonDecode(event.content);
      json = decoded is Map<String, dynamic> ? decoded : const {};
    } catch (_) {
      json = const {};
    }
    return ProfileMetadata(
      pubkey: event.pubkey,
      name: _str(json['name']) ?? _str(json['username']),
      displayName: _str(json['display_name']) ?? _str(json['displayName']),
      about: _str(json['about']),
      picture: _url(json['picture']) ?? _url(json['image']),
      banner: _url(json['banner']),
      nip05: _str(json['nip05']),
      lud16: _str(json['lud16']),
      lud06: _str(json['lud06']),
      website: _str(json['website']),
      createdAt: event.createdAt,
    );
  }

  /// Fields to publish back in a kind 0 event; unknown fields of the
  /// previous profile are kept by the caller.
  Map<String, dynamic> toJson() => {
    if (name != null) 'name': name,
    if (displayName != null) 'display_name': displayName,
    if (about != null) 'about': about,
    if (picture != null) 'picture': picture,
    if (banner != null) 'banner': banner,
    if (nip05 != null) 'nip05': nip05,
    if (lud16 != null) 'lud16': lud16,
    if (lud06 != null) 'lud06': lud06,
    if (website != null) 'website': website,
  };

  Map<String, dynamic> toCacheJson() => {
    'pubkey': pubkey,
    'created_at': createdAt,
    ...toJson(),
  };

  static ProfileMetadata fromCacheJson(Map<String, dynamic> json) =>
      ProfileMetadata(
        pubkey: json['pubkey'] as String,
        name: _str(json['name']),
        displayName: _str(json['display_name']),
        about: _str(json['about']),
        picture: _url(json['picture']),
        banner: _url(json['banner']),
        nip05: _str(json['nip05']),
        lud16: _str(json['lud16']),
        lud06: _str(json['lud06']),
        website: _str(json['website']),
        createdAt: (json['created_at'] as num?)?.toInt() ?? 0,
      );
}

/// Loads kind 0 metadata in batches: requests made within a short window are
/// merged into a single REQ (one `authors` filter) sent to the user's relays
/// plus the indexer relays. The newest event always wins, misses are retried
/// after a cool-down, and everything is kept in a persistent cache so names
/// and avatars appear instantly on the next start.
class ProfileRepository {
  final RelayPool pool;
  final List<String> indexers;
  final Map<String, ProfileMetadata> _cache = {};
  final Map<String, DateTime> _fetchedAt = {};
  final Map<String, DateTime> _missedAt = {};
  final Set<String> _wanted = {};
  final Set<String> _inflight = {};
  final _updates = StreamController<ProfileMetadata>.broadcast();
  Timer? _timer;
  bool _disposed = false;
  int _active = 0;

  static const maxBatch = 100;
  static const maxConcurrent = 3;
  static const refreshAfter = Duration(hours: 6);
  static const retryMissAfter = Duration(seconds: 45);

  ProfileRepository(this.pool, {this.indexers = const []});

  Stream<ProfileMetadata> get updates => _updates.stream;

  ProfileMetadata? cached(String pubkey) => _cache[pubkey];

  /// Seeds the cache from disk; entries are considered stale (refreshed in
  /// the background on first use) but are shown immediately.
  void seed(Iterable<ProfileMetadata> profiles) {
    for (final p in profiles) {
      final prev = _cache[p.pubkey];
      if (prev == null || p.createdAt > prev.createdAt) _cache[p.pubkey] = p;
    }
  }

  List<ProfileMetadata> get all => _cache.values.toList();

  /// Marks [pubkey] as needed. Cheap to call from `build()`.
  void request(String pubkey, {bool force = false}) {
    if (_disposed || pubkey.length != 64) return;
    if (_inflight.contains(pubkey) || _wanted.contains(pubkey)) return;
    if (!force) {
      final fetched = _fetchedAt[pubkey];
      if (fetched != null &&
          DateTime.now().difference(fetched) < refreshAfter) {
        return;
      }
      final missed = _missedAt[pubkey];
      if (missed != null &&
          DateTime.now().difference(missed) < retryMissAfter) {
        return;
      }
    }
    _wanted.add(pubkey);
    _timer ??= Timer(const Duration(milliseconds: 80), _flush);
  }

  /// Requests [pubkey] and resolves with its profile (null when no relay
  /// has one).
  Future<ProfileMetadata?> fetch(String pubkey, {bool force = false}) async {
    request(pubkey, force: force);
    if (_cache.containsKey(pubkey) && !force) return _cache[pubkey];
    try {
      return await updates
          .where((p) => p.pubkey == pubkey)
          .first
          .timeout(const Duration(seconds: 10));
    } on TimeoutException {
      return _cache[pubkey];
    }
  }

  Future<void> _flush() async {
    _timer = null;
    if (_wanted.isEmpty || _disposed) return;
    // Hundreds of profiles may be queued (a whole follow list): never more
    // than a few requests at a time, relays cap concurrent subscriptions.
    if (_active >= maxConcurrent) {
      _timer = Timer(const Duration(milliseconds: 150), _flush);
      return;
    }
    final batch = _wanted.take(maxBatch).toList();
    _wanted.removeAll(batch);
    _inflight.addAll(batch);
    _active++;
    if (_wanted.isNotEmpty) {
      _timer = Timer(const Duration(milliseconds: 40), _flush);
    }

    final sub = pool.subscribe(
      [
        NostrFilter(
          kinds: const [NostrKinds.profileMetadata],
          authors: batch,
          limit: batch.length * 3,
        ),
      ],
      extraRelays: indexers,
      eoseTimeout: const Duration(seconds: 7),
    );
    final listener = sub.events.listen(_ingest);
    await sub.eose;
    // Slow relays often deliver their last events right after EOSE.
    await Future<void>.delayed(const Duration(milliseconds: 250));
    await listener.cancel();
    sub.close();

    _active--;
    final now = DateTime.now();
    for (final pk in batch) {
      _inflight.remove(pk);
      if (_cache.containsKey(pk)) {
        _fetchedAt[pk] = now;
      } else {
        _missedAt[pk] = now;
      }
    }
  }

  void _ingest(NostrEvent event) {
    if (event.kind != NostrKinds.profileMetadata) return;
    final prev = _cache[event.pubkey];
    if (prev != null && prev.createdAt >= event.createdAt) return;
    final meta = ProfileMetadata.fromEvent(event);
    _cache[event.pubkey] = meta;
    if (!_updates.isClosed) _updates.add(meta);
  }

  /// Applies a profile the user just published, so the UI updates before any
  /// relay echoes it back.
  void applyLocal(NostrEvent event) => _ingest(event);

  void dispose() {
    _disposed = true;
    _timer?.cancel();
    _updates.close();
  }
}
