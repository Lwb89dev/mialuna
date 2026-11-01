import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../core/auth/auth_controller.dart';
import '../core/media/blossom.dart';
import '../core/media/private_media.dart';
import '../core/nostr/event.dart';
import '../core/nostr/event_store.dart';
import '../core/nostr/outbox.dart';
import '../core/nostr/profile_repository.dart';
import '../core/nostr/relay_pool.dart';
import '../core/nostr/signer.dart';
import '../core/storage/local_cache.dart';
import '../features/settings/settings_controller.dart';

final localCacheProvider = Provider((ref) => LocalCache());

/// Where small preferences are read from (overridable in tests).
final sharedPreferencesLoader = Provider<Future<SharedPreferences> Function()>(
  (ref) => SharedPreferences.getInstance,
);

/// Relays that index profiles and relay lists. Overridable (tests run
/// without any public relay).
final indexerRelaysProvider = Provider<List<String>>((ref) => indexerRelays);

final eventStoreProvider = Provider((ref) => EventStore());

/// The one relay pool of the app. It is created once and follows the
/// settings through [RelayPool.updateRelays], so open subscriptions are never
/// torn down when the relay list changes.
final relayPoolProvider = Provider<RelayPool>((ref) {
  final pool = RelayPool(ref.read(settingsProvider).relays);
  ref.listen(settingsProvider.select((s) => s.relays), (_, relays) {
    pool.updateRelays(relays);
  });
  // NIP-42: relays that demand authentication (needed by private messages)
  // are answered with the user's signer.
  ref.listen<AuthState>(authProvider, (_, auth) {
    final signer = auth.signer;
    pool.authSigner = signer.canSign
        ? (url, challenge) => signer.signEvent(
            kind: NostrKinds.clientAuth,
            tags: [
              ['relay', url],
              ['challenge', challenge],
            ],
            content: '',
          )
        : null;
  }, fireImmediately: true);
  ref.onDispose(pool.dispose);
  pool.connect();
  return pool;
});

final httpClientProvider = Provider<http.Client>((ref) {
  final client = http.Client();
  ref.onDispose(client.close);
  return client;
});

final blossomClientProvider = Provider(
  (ref) => BlossomClient(
    ref.watch(settingsProvider).blossomServers,
    httpClient: ref.watch(httpClientProvider),
  ),
);

/// Fetches and decrypts close-friends media.
final privateMediaProvider = Provider<PrivateMediaService>((ref) {
  final service = PrivateMediaService(ref.watch(httpClientProvider));
  service.cleanUp(); // yesterday's decrypted videos
  return service;
});

/// Convenience: the active signer.
final signerProvider = Provider<Signer>(
  (ref) => ref.watch(authProvider).signer,
);

// ── profiles ──────────────────────────────────────────────────────────

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  final repo = ProfileRepository(
    ref.read(relayPoolProvider),
    indexers: ref.read(indexerRelaysProvider),
  );
  ref.onDispose(repo.dispose);
  return repo;
});

/// All profiles known so far, keyed by pubkey. Backed by a persistent cache
/// so names and avatars show instantly on the next start.
class ProfilesController extends Notifier<Map<String, ProfileMetadata>> {
  final Map<String, ProfileMetadata> _pending = {};
  Timer? _flushTimer;
  Timer? _saveTimer;

  @override
  Map<String, ProfileMetadata> build() {
    final repo = ref.watch(profileRepositoryProvider);
    final sub = repo.updates.listen((p) {
      _pending[p.pubkey] = p;
      _flushTimer ??= Timer(const Duration(milliseconds: 60), _flush);
    });
    ref.onDispose(() {
      sub.cancel();
      _flushTimer?.cancel();
      _saveTimer?.cancel();
    });
    _loadFromDisk(repo);
    return {for (final p in repo.all) p.pubkey: p};
  }

  Future<void> _loadFromDisk(ProfileRepository repo) async {
    final rows = await ref.read(localCacheProvider).loadProfiles();
    final loaded = <ProfileMetadata>[];
    for (final row in rows) {
      try {
        loaded.add(ProfileMetadata.fromCacheJson(row));
      } catch (_) {}
    }
    repo.seed(loaded);
    state = {for (final p in repo.all) p.pubkey: p};
  }

  void _flush() {
    _flushTimer = null;
    if (_pending.isEmpty) return;
    state = {...state, ..._pending};
    _pending.clear();
    _saveTimer?.cancel();
    _saveTimer = Timer(const Duration(seconds: 4), () {
      final all = state.values.toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      ref.read(localCacheProvider).saveProfiles([
        for (final p in all) p.toCacheJson(),
      ]);
    });
  }

  void request(String pubkey) =>
      ref.read(profileRepositoryProvider).request(pubkey);

  /// Applies a profile event this device just published.
  void applyLocal(NostrEvent event) {
    ref.read(profileRepositoryProvider).applyLocal(event);
  }
}

final profilesProvider =
    NotifierProvider<ProfilesController, Map<String, ProfileMetadata>>(
      ProfilesController.new,
    );

/// The profile of [pubkey] (null until a relay delivers one). Watching it
/// triggers the (batched) request, so every avatar and name in the app can
/// simply watch this provider.
final profileProvider = Provider.family<ProfileMetadata?, String>((
  ref,
  pubkey,
) {
  final meta = ref.watch(profilesProvider.select((m) => m[pubkey]));
  Future.microtask(() => ref.read(profilesProvider.notifier).request(pubkey));
  return meta;
});

/// Async view of a profile, for code that wants to await it.
final profileMetadataProvider = FutureProvider.family<ProfileMetadata?, String>(
  (ref, pubkey) => ref.watch(profileRepositoryProvider).fetch(pubkey),
);

// ── outbox (NIP-65) ───────────────────────────────────────────────────

final outboxProvider = Provider<OutboxResolver>((ref) {
  final resolver = OutboxResolver(
    ref.read(relayPoolProvider),
    indexers: ref.read(indexerRelaysProvider),
  );
  final cache = ref.read(localCacheProvider);
  cache.readJson('relay_lists.json').then(resolver.load);
  // Persist what was learned every half minute.
  final saveTimer = Timer.periodic(const Duration(seconds: 30), (_) {
    cache.writeJson('relay_lists.json', resolver.toJson());
  });
  ref.onDispose(saveTimer.cancel);
  return resolver;
});

// ── app-wide UI signals ───────────────────────────────────────────────

/// Fired when the user taps the tab that is already open.
class TabReselect {
  final int branch;
  final int tick;
  const TabReselect(this.branch, this.tick);
}

final tabReselectProvider = StateProvider<TabReselect?>((ref) => null);

/// Posts whose media is permanently unreachable (HTTP 4xx, undecodable
/// data). They are hidden from the feeds for the rest of the session.
final brokenMediaProvider = StateProvider<Set<String>>((ref) => const {});

/// Index of the bottom-navigation tab that is currently shown. Screens that
/// stay alive in the background (Reels, inline videos) use it to stop
/// playing when the user leaves them.
final currentTabProvider = StateProvider<int>((ref) => 0);
