import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/auth/auth_controller.dart';
import '../../core/nostr/event.dart';
import '../../core/nostr/filter.dart';
import '../../l10n/strings.dart';
import '../messages/dm_controller.dart';

/// The audience of a post.
enum Audience { public, closeFriends }

class CloseFriendsState {
  /// Pubkeys, in the order they were added.
  final List<String> members;

  /// The list was read from the network (or this device has none yet).
  final bool synced;
  final bool syncing;
  final String? error;

  const CloseFriendsState({
    this.members = const [],
    this.synced = false,
    this.syncing = false,
    this.error,
  });

  CloseFriendsState copyWith({
    List<String>? members,
    bool? synced,
    bool? syncing,
    String? error,
    bool clearError = false,
  }) => CloseFriendsState(
    members: members ?? this.members,
    synced: synced ?? this.synced,
    syncing: syncing ?? this.syncing,
    error: clearError ? null : (error ?? this.error),
  );
}

/// Your close-friends list: a NIP-51 categorised people list
/// (kind 30000, `d` = `close-friends`) whose members are encrypted to
/// yourself, so nobody — relays included — can see who is on it. Kept on the
/// device too, so it works offline and survives a relay losing the event.
class CloseFriendsController extends Notifier<CloseFriendsState> {
  static const identifier = 'close-friends';

  /// Every post is wrapped once per friend (a signer round-trip each): beyond
  /// this a post would take minutes with a remote signer.
  static const maxMembers = 60;

  int _updatedAt = 0;
  bool _dirty = false;
  Timer? _publishTimer;
  String? _pub;
  int _generation = 0;
  Future<void>? _syncing;

  /// Completes when the list saved on this device has been read. Edits wait
  /// for it: made earlier, they would start from an empty list and the file
  /// would then overwrite them (or they would overwrite the file).
  Future<void> _loaded = Future.value();

  String get _file => 'close_friends_$_pub.json';

  @override
  CloseFriendsState build() {
    final pub = ref.watch(authProvider.select((a) => a.publicKey));
    final generation = ++_generation;
    ref.onDispose(() {
      _generation++;
      _publishTimer?.cancel();
    });
    _pub = pub;
    _updatedAt = 0;
    _dirty = false;
    _syncing = null;
    if (pub == null) return const CloseFriendsState();
    _loaded = Future.microtask(() => _loadLocal(generation));
    return const CloseFriendsState();
  }

  Future<void> _loadLocal(int generation) async {
    final json = await ref.read(localCacheProvider).readJson(_file);
    if (generation != _generation || json is! Map) return;
    _updatedAt = (json['updated_at'] as num?)?.toInt() ?? 0;
    _dirty = json['dirty'] as bool? ?? false;
    final members = [
      for (final m in (json['members'] as List? ?? const []))
        if (m is String && m.length == 64) m,
    ];
    state = state.copyWith(members: members);
  }

  Future<void> _saveLocal() => ref.read(localCacheProvider).writeJson(_file, {
    'members': state.members,
    'updated_at': _updatedAt,
    'dirty': _dirty,
  });

  bool contains(String pubkey) => state.members.contains(pubkey);

  /// Adds people; returns how many were added (the cap may refuse some).
  Future<int> add(Iterable<String> pubkeys) async {
    await _loaded;
    final me = _pub;
    final members = [...state.members];
    var added = 0;
    for (final pk in pubkeys) {
      if (pk == me || members.contains(pk) || pk.length != 64) continue;
      if (members.length >= maxMembers) break;
      members.add(pk);
      added++;
    }
    if (added > 0) await _changed(members);
    return added;
  }

  Future<void> remove(String pubkey) async {
    await _loaded;
    await _changed([...state.members]..remove(pubkey));
  }

  Future<void> _changed(List<String> members) async {
    _updatedAt = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    _dirty = true;
    state = state.copyWith(members: members);
    await _saveLocal();
    _publishTimer?.cancel();
    final generation = _generation;
    _publishTimer = Timer(const Duration(seconds: 2), () {
      if (generation == _generation) publish();
    });
  }

  /// Reads the list from the relays and adopts it when it is newer than the
  /// copy on this device; republishes the device copy when that is newer.
  /// Needs the signer (the members are encrypted): call it when the user
  /// opens the list or starts a close-friends post, not at start-up.
  Future<void> sync() => _syncing ??= _sync().whenComplete(() {
    _syncing = null;
  });

  Future<void> _sync() async {
    final auth = ref.read(authProvider);
    final me = auth.publicKey;
    if (me == null || !auth.signer.canEncrypt) return;
    final generation = _generation;
    state = state.copyWith(syncing: true, clearError: true);
    try {
      final sub = ref
          .read(relayPoolProvider)
          .subscribe(
            [
              NostrFilter(
                kinds: const [NostrKinds.followSet],
                authors: [me],
                tagFilters: const {
                  '#d': [identifier],
                },
                limit: 3,
              ),
            ],
            extraRelays: ref.read(indexerRelaysProvider),
            eoseTimeout: const Duration(seconds: 7),
          );
      NostrEvent? newest;
      final listener = sub.events.listen((e) {
        if (newest == null || e.createdAt > newest!.createdAt) newest = e;
      });
      await sub.eose;
      await Future<void>.delayed(const Duration(milliseconds: 250));
      await listener.cancel();
      sub.close();
      if (generation != _generation) return;

      final event = newest;
      if (event != null && event.createdAt > _updatedAt) {
        final members = await _decrypt(event, me);
        if (generation != _generation) return;
        if (members != null) {
          _updatedAt = event.createdAt;
          _dirty = false;
          state = state.copyWith(members: members);
          await _saveLocal();
        }
      } else if (_dirty || (event == null && state.members.isNotEmpty)) {
        await publish();
      }
      if (generation == _generation) {
        state = state.copyWith(syncing: false, synced: true);
      }
    } catch (e) {
      if (generation == _generation) {
        state = state.copyWith(
          syncing: false,
          error: AppStrings.current.syncFailed,
        );
      }
    }
  }

  Future<List<String>?> _decrypt(NostrEvent event, String me) async {
    if (event.content.isEmpty) return const [];
    try {
      final plain = await ref
          .read(authProvider)
          .signer
          .nip44Decrypt(me, event.content);
      final tags = jsonDecode(plain) as List;
      return [
        for (final t in tags)
          if (t is List && t.length > 1 && t[0] == 'p') t[1] as String,
      ];
    } catch (_) {
      return null;
    }
  }

  /// Publishes the list as an event only you can read.
  Future<bool> publish() async {
    final auth = ref.read(authProvider);
    final me = auth.publicKey;
    if (me == null || !auth.signer.canEncrypt) return false;
    try {
      final plain = jsonEncode([
        for (final pk in state.members) ['p', pk],
      ]);
      final content = state.members.isEmpty
          ? ''
          : await auth.signer.nip44Encrypt(me, plain);
      final event = await auth.signer.signEvent(
        kind: NostrKinds.followSet,
        tags: [
          ['d', identifier],
          ['title', AppStrings.current.closeFriends],
        ],
        content: content,
        createdAt: _updatedAt > 0 ? _updatedAt : null,
      );
      final report = await ref
          .read(relayPoolProvider)
          .publish(event, extraRelays: ref.read(indexerRelaysProvider));
      if (report.publishedSomewhere) {
        _dirty = false;
        await _saveLocal();
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  /// Whether [pubkey] can receive private posts at all (has an inbox).
  Future<bool> canReceive(String pubkey) async {
    try {
      return (await ref.read(dmProvider.notifier).inboxRelaysOf(pubkey))
          .isNotEmpty;
    } catch (_) {
      return false;
    }
  }
}

final closeFriendsProvider =
    NotifierProvider<CloseFriendsController, CloseFriendsState>(
      CloseFriendsController.new,
    );

/// Whether a friend can be reached (has turned private messages on).
final friendReachableProvider = FutureProvider.autoDispose.family<bool, String>(
  (ref, pubkey) => ref.read(closeFriendsProvider.notifier).canReceive(pubkey),
);

/// Audience chosen the last time a post was composed; used as the default
/// so the list does not have to be picked again and again.
class AudiencePreference extends Notifier<Audience> {
  static const _key = 'mialuna_audience';

  @override
  Audience build() {
    _load();
    return Audience.public;
  }

  Future<void> _load() async {
    final prefs = await ref.read(sharedPreferencesLoader)();
    final name = prefs.getString(_key);
    state = Audience.values.firstWhere(
      (a) => a.name == name,
      orElse: () => Audience.public,
    );
  }

  Future<void> set(Audience audience) async {
    state = audience;
    final prefs = await ref.read(sharedPreferencesLoader)();
    await prefs.setString(_key, audience.name);
  }
}

final audiencePreferenceProvider =
    NotifierProvider<AudiencePreference, Audience>(AudiencePreference.new);
