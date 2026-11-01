import 'dart:async';
import 'dart:convert';

import 'event.dart';
import 'filter.dart';
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
  });

  String get label => displayName?.isNotEmpty == true
      ? displayName!
      : name?.isNotEmpty == true
      ? name!
      : '${pubkey.substring(0, 8)}…';

  static ProfileMetadata fromEvent(NostrEvent event) {
    Map<String, dynamic> json;
    try {
      json = jsonDecode(event.content) as Map<String, dynamic>;
    } catch (_) {
      json = const {};
    }
    return ProfileMetadata(
      pubkey: event.pubkey,
      name: json['name'] as String?,
      displayName:
          json['display_name'] as String? ?? json['displayName'] as String?,
      about: json['about'] as String?,
      picture: json['picture'] as String?,
      banner: json['banner'] as String?,
      nip05: json['nip05'] as String?,
      lud16: json['lud16'] as String?,
      lud06: json['lud06'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    if (name != null) 'name': name,
    if (displayName != null) 'display_name': displayName,
    if (about != null) 'about': about,
    if (picture != null) 'picture': picture,
    if (banner != null) 'banner': banner,
    if (nip05 != null) 'nip05': nip05,
  };
}

/// Fetches and caches kind 0 metadata from the relay pool.
class ProfileRepository {
  final RelayPool pool;
  final Map<String, ProfileMetadata> _cache = {};
  final Map<String, Completer<ProfileMetadata?>> _pending = {};

  ProfileRepository(this.pool);

  ProfileMetadata? cached(String pubkey) => _cache[pubkey];

  /// Requests metadata; resolves when it arrives (or null after timeout).
  Future<ProfileMetadata?> fetch(
    String pubkey, {
    Duration timeout = const Duration(seconds: 8),
  }) {
    final hit = _cache[pubkey];
    if (hit != null) return Future.value(hit);
    if (_pending.containsKey(pubkey)) return _pending[pubkey]!.future;

    final completer = Completer<ProfileMetadata?>();
    _pending[pubkey] = completer;
    pool.connect();
    final (:id, :stream) = pool.subscribe([
      NostrFilter(kinds: const [0], authors: [pubkey], limit: 1),
    ]);
    final sub = stream.listen((event) {
      final meta = ProfileMetadata.fromEvent(event);
      _cache[event.pubkey] = meta;
      _pending.remove(event.pubkey)?.complete(meta);
    });
    Future.delayed(timeout, () {
      sub.cancel();
      pool.unsubscribe(id);
      _pending.remove(pubkey)?.complete(null);
    });
    return completer.future;
  }
}
