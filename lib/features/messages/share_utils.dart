import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/nostr/event.dart';
import '../../core/nostr/filter.dart';
import '../../core/nostr/models/media_event.dart';
import '../../core/nostr/nip19.dart';

/// `nostr:nevent1…` reference to [post] with relay hints, so the recipient's
/// app can find it (NIP-19/NIP-21). Works for photos, videos, reels and
/// stories alike: they are all events.
String shareReference(ProviderContainer ref, MediaPost post) {
  final outbox = ref.read(outboxProvider);
  final hints = <String>[
    ...outbox.writeRelays(post.author, max: 2),
    ...ref.read(relayPoolProvider).writeRelays,
  ];
  final unique = <String>{
    for (final h in hints)
      if (h.startsWith('wss://')) h,
  }.take(2).toList();
  return 'nostr:${Nip19.encodeNevent(post.id, relays: unique, author: post.author, kind: post.kind)}';
}

/// Resolves a `nostr:nevent1…`/`note1…` reference found in a message into a
/// media post (null when it is not a post or cannot be found).
final sharedPostProvider = FutureProvider.autoDispose
    .family<MediaPost?, String>((ref, reference) async {
      final EventRef target;
      try {
        target = Nip19.decodeEventRef(reference);
      } on FormatException {
        return null;
      }
      final store = ref.read(eventStoreProvider);
      final cached = store.byId(target.id);
      if (cached != null) return MediaPost.tryParse(cached);

      final pool = ref.read(relayPoolProvider);
      final outbox = ref.read(outboxProvider);
      final extra = <String>[...target.relays];
      if (target.author != null) {
        await outbox.ensure([target.author!]);
        extra.addAll(outbox.writeRelays(target.author!));
      }
      final sub = pool.subscribe(
        [
          NostrFilter(ids: [target.id], limit: 1),
        ],
        extraRelays: extra,
        eoseTimeout: const Duration(seconds: 8),
      );
      final found = Completer<NostrEvent?>();
      final listener = sub.events.listen((e) {
        if (!found.isCompleted) found.complete(e);
      });
      sub.eose.then((_) async {
        await Future<void>.delayed(const Duration(milliseconds: 300));
        if (!found.isCompleted) found.complete(null);
      });
      final event = await found.future;
      await listener.cancel();
      sub.close();
      if (event == null) return null;
      store.add(event);
      return MediaPost.tryParse(event);
    });
