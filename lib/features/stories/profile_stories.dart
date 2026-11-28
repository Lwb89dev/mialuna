import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/nostr/event.dart';
import '../../core/nostr/filter.dart';
import '../../core/nostr/models/media_event.dart';
import '../../core/nostr/relay_pool.dart';
import '../social/deleted_posts.dart';
import '../social/moderation_controller.dart';
import 'stories_controller.dart';

/// Live stories of one author, read from their own relays as well as this
/// account's: the rail only has the people you follow, a profile shows its
/// stories whoever it belongs to.
final _authorStoriesProvider = StreamProvider.autoDispose
    .family<List<MediaPost>, String>((ref, pubkey) {
      final controller = StreamController<List<MediaPost>>();
      final stories = <String, MediaPost>{};
      PoolSubscription? sub;
      StreamSubscription<NostrEvent>? listener;
      var closed = false;
      ref.onDispose(() {
        closed = true;
        listener?.cancel();
        sub?.close();
        controller.close();
      });
      final now = ref.read(unixClockProvider);
      () async {
        final outbox = ref.read(outboxProvider);
        try {
          await outbox.ensure([pubkey]).timeout(const Duration(seconds: 5));
        } catch (_) {
          // Look on this account's relays.
        }
        if (closed) return;
        sub = ref
            .read(relayPoolProvider)
            .subscribe(
              [
                NostrFilter(
                  kinds: NostrKinds.storyKinds,
                  authors: [pubkey],
                  tagFilters: const {
                    '#L': ['mialuna.story'],
                  },
                  since: now() - MediaPost.storyWindowSeconds,
                  limit: 50,
                ),
              ],
              extraRelays: outbox.writeRelays(pubkey),
              eoseTimeout: const Duration(seconds: 10),
            );
        listener = sub!.events.listen((event) {
          final post = MediaPost.tryParse(event);
          if (post == null || !post.isStory || post.isExpired(now())) return;
          if (stories.containsKey(post.id)) return;
          stories[post.id] = post;
          if (!closed) controller.add(stories.values.toList());
        });
      }();
      return controller.stream;
    });

/// The stories [pubkey] has up right now, oldest first, or null when there
/// are none (or none you would be shown: blocked, muted, taken down). Those
/// in the rail — close-friends ones too — and those found on the relays.
final profileStoriesProvider = Provider.autoDispose.family<StoryGroup?, String>(
  (ref, pubkey) {
    final rail = ref.watch(
      storiesProvider.select(
        (s) => s.groups.where((g) => g.author == pubkey).firstOrNull,
      ),
    );
    final fetched =
        ref.watch(_authorStoriesProvider(pubkey)).value ?? const <MediaPost>[];
    if (ref.watch(blockProvider).contains(pubkey) ||
        ref.watch(muteProvider).contains(pubkey)) {
      return null;
    }
    final deleted = ref.watch(deletedPostsProvider);
    final now = ref.read(unixClockProvider)();
    final byId = <String, MediaPost>{
      for (final s in [...?rail?.stories, ...fetched])
        if (!s.isExpired(now) && !deleted.contains(s.id)) s.id: s,
    };
    if (byId.isEmpty) return null;
    // Stories run out on their own: the ring goes with the last one.
    final tick = Timer(const Duration(minutes: 1), ref.invalidateSelf);
    ref.onDispose(tick.cancel);
    return StoryGroup(
      author: pubkey,
      stories: byId.values.toList()
        ..sort((a, b) => a.createdAt.compareTo(b.createdAt)),
    );
  },
);
