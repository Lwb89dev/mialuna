import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/auth/auth_controller.dart';
import '../core/media/blossom.dart';
import '../core/nostr/event_store.dart';
import '../core/nostr/profile_repository.dart';
import '../core/nostr/relay_pool.dart';
import '../core/storage/local_cache.dart';
import '../features/settings/settings_controller.dart';

final localCacheProvider = Provider((ref) => LocalCache());

final eventStoreProvider = Provider((ref) => EventStore());

final relayPoolProvider = Provider((ref) {
  final settings = ref.watch(settingsProvider);
  final pool = RelayPool(settings.relays);
  ref.onDispose(pool.dispose);
  return pool;
});

final blossomClientProvider = Provider(
  (ref) => BlossomClient(ref.watch(settingsProvider).blossomServer),
);

/// Convenience: the active signer.
final signerProvider = Provider((ref) => ref.watch(authProvider).signer);

final profileRepositoryProvider = Provider(
  (ref) => ProfileRepository(ref.watch(relayPoolProvider)),
);

/// Watches (async) the metadata of a pubkey.
final profileMetadataProvider = FutureProvider.family<ProfileMetadata?, String>(
  (ref, pubkey) => ref.watch(profileRepositoryProvider).fetch(pubkey),
);
