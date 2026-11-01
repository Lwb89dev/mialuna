import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/auth/auth_controller.dart';
import '../core/media/blossom.dart';
import '../core/nostr/event_store.dart';
import '../core/nostr/relay_pool.dart';
import '../core/storage/local_cache.dart';

const defaultRelays = [
  'wss://relay.damus.io',
  'wss://nos.lol',
  'wss://relay.nostr.band',
  'wss://nostr.mom',
];

final localCacheProvider = Provider((ref) => LocalCache());

final eventStoreProvider = Provider((ref) => EventStore());

final relayPoolProvider = Provider((ref) {
  final pool = RelayPool(defaultRelays);
  ref.onDispose(pool.dispose);
  return pool;
});

final blossomClientProvider = Provider(
  (ref) => BlossomClient(BlossomClient.defaultServer),
);

/// Convenience: the active signer.
final signerProvider = Provider((ref) => ref.watch(authProvider).signer);
