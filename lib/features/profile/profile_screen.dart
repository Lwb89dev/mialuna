import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../app/sign_out.dart';
import '../../core/auth/auth_controller.dart';
import '../../core/nostr/event.dart';
import '../../core/nostr/filter.dart';
import '../../core/nostr/models/media_event.dart';
import '../../core/nostr/nip05.dart';
import '../../core/nostr/nip19.dart';
import '../../core/nostr/profile_repository.dart';
import '../../core/nostr/relay_pool.dart';
import '../../core/nostr/signer.dart';
import '../../l10n/strings.dart';
import '../explore/explore_screen.dart';
import '../feed/widgets/post_card.dart';
import '../messages/chat_screen.dart';
import '../messages/dm_controller.dart';
import '../settings/settings_screen.dart';
import '../social/follow_controller.dart';
import '../social/moderation_controller.dart';
import 'edit_profile_screen.dart';
import 'profile_widgets.dart';

/// Media posts of [pubkey], read from the author's own relays (NIP-65
/// outbox) as well as the user's. Items show up as they arrive; an empty
/// list is only reported once the relays have answered.
final userPostsProvider = StreamProvider.autoDispose
    .family<List<MediaPost>, String>((ref, pubkey) {
      final controller = StreamController<List<MediaPost>>();
      final posts = <String, MediaPost>{};
      PoolSubscription? sub;
      StreamSubscription<NostrEvent>? listener;
      var closed = false;
      Timer? throttle;

      void emit() {
        if (closed) return;
        final list = posts.values.toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
        controller.add(list);
      }

      ref.onDispose(() {
        closed = true;
        throttle?.cancel();
        listener?.cancel();
        sub?.close();
        controller.close();
      });

      () async {
        final outbox = ref.read(outboxProvider);
        try {
          await outbox.ensure([pubkey]).timeout(const Duration(seconds: 5));
        } catch (_) {}
        if (closed) return;
        sub = ref
            .read(relayPoolProvider)
            .subscribe(
              [
                NostrFilter(
                  kinds: NostrKinds.mediaKinds,
                  authors: [pubkey],
                  limit: 90,
                ),
              ],
              extraRelays: outbox.writeRelays(pubkey),
              eoseTimeout: const Duration(seconds: 12),
            );
        listener = sub!.events.listen((event) {
          final post = MediaPost.tryParse(event);
          if (post == null || post.isStory || post.isExpired()) return;
          if (posts.containsKey(post.id)) return;
          posts[post.id] = post;
          throttle ??= Timer(const Duration(milliseconds: 250), () {
            throttle = null;
            emit();
          });
        });
        await sub!.eose;
        await Future<void>.delayed(const Duration(milliseconds: 300));
        emit(); // also reports "no posts" once the relays answered
      }();
      return controller.stream;
    });

/// Bookmarked posts, resolved from the relays by event id.
final savedPostsProvider = StreamProvider.autoDispose<List<MediaPost>>((ref) {
  final ids = ref.watch(bookmarksProvider);
  if (ids.isEmpty) return Stream.value(const <MediaPost>[]);
  final controller = StreamController<List<MediaPost>>();
  final posts = <String, MediaPost>{};
  final sub = ref.read(relayPoolProvider).subscribe([
    NostrFilter(kinds: NostrKinds.mediaKinds, ids: ids.toList()),
  ], eoseTimeout: const Duration(seconds: 12));
  final listener = sub.events.listen((event) {
    final post = MediaPost.tryParse(event);
    if (post == null || post.isExpired() || posts.containsKey(post.id)) return;
    posts[post.id] = post;
    if (!controller.isClosed) controller.add(posts.values.toList());
  });
  sub.eose.then((_) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    if (!controller.isClosed && posts.isEmpty) controller.add(const []);
  });
  ref.onDispose(() {
    listener.cancel();
    sub.close();
    controller.close();
  });
  return controller.stream;
});

/// How many accounts [pubkey] follows, from their newest kind 3.
final followingCountProvider = FutureProvider.autoDispose.family<int?, String>((
  ref,
  pubkey,
) async {
  final sub = ref
      .read(relayPoolProvider)
      .subscribe(
        [
          NostrFilter(
            kinds: const [NostrKinds.followList],
            authors: [pubkey],
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
  final event = newest;
  if (event == null) return null;
  return event.tags.where((t) => t.length > 1 && t[0] == 'p').length;
});

/// NIP-05: true only when the domain really maps the name to [pubkey].
final nip05VerifiedProvider = FutureProvider.autoDispose
    .family<bool, ({String pubkey, String nip05})>(
      (ref, args) => Nip05.verify(args.nip05, args.pubkey),
    );

/// A profile: your own (bottom tab, [pubkey] null) or anyone else's.
class ProfileScreen extends ConsumerWidget {
  final String? pubkey;
  const ProfileScreen({super.key, this.pubkey});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final theme = Theme.of(context);
    final target = pubkey ?? auth.publicKey;

    if (target == null) {
      return Scaffold(
        appBar: AppBar(title: Text(context.l10n.tabProfile)),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.person_outline,
                size: 72,
                color: theme.colorScheme.tertiary,
              ),
              const SizedBox(height: 16),
              Text(
                context.l10n.browsingAsGuest,
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                context.l10n.signInToInteract,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () => context.go('/login'),
                child: Text(context.l10n.signIn),
              ),
            ],
          ),
        ),
      );
    }

    final isSelf = target == auth.publicKey;
    final meta = ref.watch(profileProvider(target));
    final posts = ref.watch(userPostsProvider(target));
    final saved = isSelf ? ref.watch(savedPostsProvider) : null;

    return Scaffold(
      appBar: AppBar(
        title: Text(meta?.label ?? ProfileMetadata.shortNpub(target)),
        actions: [
          if (isSelf) ...[
            IconButton(
              icon: const Icon(Icons.settings_outlined),
              tooltip: context.l10n.settings,
              onPressed: () => Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const SettingsScreen())),
            ),
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: context.l10n.signOut,
              onPressed: () async {
                // The key, the wallet link, decrypted messages and close
                // friends' posts, caches and preferences all leave with you.
                await ref.read(signOutProvider)();
                if (context.mounted) context.go('/login');
              },
            ),
          ] else
            PopupMenuButton<String>(
              onSelected: (v) async {
                final messenger = ScaffoldMessenger.of(context);
                final l10n = context.l10n;
                switch (v) {
                  case 'copy':
                    await Clipboard.setData(
                      ClipboardData(text: Nip19.encodeNpub(target)),
                    );
                    messenger.showSnackBar(
                      SnackBar(content: Text(l10n.npubCopied)),
                    );
                  case 'mute':
                    await ref
                        .read(muteControllerProvider.notifier)
                        .mute(target);
                    messenger.showSnackBar(
                      SnackBar(content: Text(l10n.authorMuted)),
                    );
                  case 'block':
                    await ref.read(blockProvider.notifier).block(target);
                    messenger.showSnackBar(
                      SnackBar(content: Text(l10n.authorBlocked)),
                    );
                }
              },
              itemBuilder: (_) => [
                PopupMenuItem(
                  value: 'copy',
                  child: Text(context.l10n.copyNpub),
                ),
                PopupMenuItem(value: 'mute', child: Text(context.l10n.mute)),
                PopupMenuItem(value: 'block', child: Text(context.l10n.block)),
              ],
            ),
        ],
      ),
      body: DefaultTabController(
        length: isSelf ? 3 : 2,
        child: NestedScrollView(
          headerSliverBuilder: (context, _) => [
            SliverToBoxAdapter(
              child: _ProfileHeader(
                pubkey: target,
                isSelf: isSelf,
                meta: meta,
                postCount: posts.valueOrNull?.length,
              ),
            ),
            SliverToBoxAdapter(
              child: TabBar(
                tabs: [
                  Tab(
                    icon: const Icon(Icons.grid_on_outlined),
                    text: context.l10n.posts,
                  ),
                  Tab(
                    icon: const Icon(Icons.play_circle_outline),
                    text: context.l10n.tabReels,
                  ),
                  if (isSelf)
                    Tab(
                      icon: const Icon(Icons.bookmark_border),
                      text: context.l10n.saved,
                    ),
                ],
              ),
            ),
          ],
          body: TabBarView(
            children: [
              _MediaGrid(
                posts: posts,
                reelsOnly: false,
                emptyMessage: isSelf
                    ? context.l10n.nothingPublishedYet
                    : context.l10n.noPostsOnRelays,
                onRefresh: () async =>
                    ref.invalidate(userPostsProvider(target)),
              ),
              _MediaGrid(
                posts: posts,
                reelsOnly: true,
                emptyMessage: isSelf
                    ? context.l10n.noReelsPublished
                    : context.l10n.noReelsOnRelays,
                onRefresh: () async =>
                    ref.invalidate(userPostsProvider(target)),
              ),
              if (isSelf)
                _MediaGrid(
                  posts: saved!,
                  reelsOnly: null,
                  emptyMessage: context.l10n.noSavedPosts,
                  onRefresh: () async => ref.invalidate(savedPostsProvider),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileHeader extends ConsumerWidget {
  final String pubkey;
  final bool isSelf;
  final ProfileMetadata? meta;
  final int? postCount;

  const _ProfileHeader({
    required this.pubkey,
    required this.isSelf,
    required this.meta,
    required this.postCount,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final auth = ref.watch(authProvider);
    final follows = ref.watch(followListProvider);
    final following = follows.contains(pubkey);
    final followingCount = isSelf
        ? follows.length
        : ref.watch(followingCountProvider(pubkey)).valueOrNull;
    final nip05 = meta?.nip05;
    final verified = nip05 == null
        ? false
        : ref
                  .watch(nip05VerifiedProvider((pubkey: pubkey, nip05: nip05)))
                  .valueOrNull ??
              false;
    final npub = Nip19.encodeNpub(pubkey);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ProfileAvatar(pubkey: pubkey, radius: 40, tappable: false),
              const SizedBox(width: 24),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: _Stat(
                        label: context.l10n.posts,
                        value: postCount?.toString() ?? '–',
                      ),
                    ),
                    Expanded(
                      child: _Stat(
                        label: context.l10n.feedFollowing,
                        value: followingCount?.toString() ?? '–',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // With no name the npub *is* the name: shown once, still copyable.
          if (meta?.givenName != null)
            Text(meta!.label, style: theme.textTheme.titleMedium),
          if (meta?.handle != null)
            Text(
              meta!.handle!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
          // The key right under the name: who this really is, one tap to copy.
          _NpubLine(
            npub: npub,
            style: meta?.givenName == null ? theme.textTheme.titleMedium : null,
          ),
          if (nip05 != null)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Row(
                children: [
                  if (verified) ...[
                    Icon(
                      Icons.verified,
                      size: 16,
                      color: theme.colorScheme.secondary,
                    ),
                    const SizedBox(width: 4),
                  ],
                  Flexible(
                    child: Text(
                      nip05,
                      style: theme.textTheme.bodySmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          if (meta?.about != null) ...[
            const SizedBox(height: 6),
            SelectableText(meta!.about!),
          ],
          if (meta?.website != null) ...[
            const SizedBox(height: 4),
            Text(
              meta!.website!,
              style: TextStyle(color: theme.colorScheme.secondary),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              if (isSelf)
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => EditProfileScreen(current: meta),
                      ),
                    ),
                    child: Text(context.l10n.editProfile),
                  ),
                )
              else ...[
                Expanded(
                  child: following
                      ? OutlinedButton(
                          onPressed: auth.isGuest
                              ? null
                              : () => _toggle(context, ref),
                          child: Text(context.l10n.followingButton),
                        )
                      : FilledButton(
                          onPressed: auth.isGuest
                              ? null
                              : () => _toggle(context, ref),
                          child: Text(context.l10n.follow),
                        ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: auth.isGuest || !ref.watch(dmProvider).supported
                        ? null
                        : () => ChatScreen.open(context, pubkey),
                    child: Text(context.l10n.messageButton),
                  ),
                ),
              ],
            ],
          ),
          if (isSelf) ...[
            const SizedBox(height: 8),
            Wrap(
              children: [
                Chip(
                  avatar: const Icon(Icons.key, size: 16),
                  label: Text(switch (auth.signer.type) {
                    SignerType.amber => 'Amber (NIP-55)',
                    SignerType.nsec => context.l10n.loginLocalKey,
                    SignerType.bunker => 'Bunker (NIP-46)',
                    SignerType.guest => context.l10n.loginGuest,
                  }),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _toggle(BuildContext context, WidgetRef ref) async {
    final ok = await ref.read(followListProvider.notifier).toggleFollow(pubkey);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.followUpdateFailed)));
    }
  }
}

/// Media grid for a profile tab. [reelsOnly] true keeps only short videos
/// (kind 22), false keeps everything else, null keeps all.
class _MediaGrid extends ConsumerWidget {
  final AsyncValue<List<MediaPost>> posts;
  final bool? reelsOnly;
  final String emptyMessage;
  final Future<void> Function() onRefresh;

  const _MediaGrid({
    required this.posts,
    required this.reelsOnly,
    required this.emptyMessage,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final broken = ref.watch(brokenMediaProvider);
    return posts.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, _) => Center(
        child: TextButton(
          onPressed: onRefresh,
          child: Text(context.l10n.retry),
        ),
      ),
      data: (list) {
        final filtered = [
          for (final p in list)
            if (!broken.contains(p.id) &&
                (reelsOnly == null ||
                    (p.event.kind == NostrKinds.shortVideo) == reelsOnly!))
              p,
        ];
        if (filtered.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Text(
                emptyMessage,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
            ),
          );
        }
        return GridView.builder(
          padding: const EdgeInsets.all(2),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 2,
            crossAxisSpacing: 2,
          ),
          itemCount: filtered.length,
          itemBuilder: (context, i) => PostThumbnail(
            post: filtered[i],
            onTap: () => PostScreen.open(context, filtered[i]),
          ),
        );
      },
    );
  }
}

/// `npub1abc…xyz` that copies the whole key when tapped.
class _NpubLine extends StatelessWidget {
  final String npub;

  /// Overrides the quiet caption style (the npub standing in for a name).
  final TextStyle? style;
  const _NpubLine({required this.npub, this.style});

  void _copy(BuildContext context) {
    Clipboard.setData(ClipboardData(text: npub));
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(context.l10n.npubCopied)));
  }

  @override
  Widget build(BuildContext context) {
    final style =
        this.style ??
        Theme.of(context).textTheme.bodySmall
            ?.copyWith(color: Theme.of(context).colorScheme.outline);
    return Tooltip(
      message: context.l10n.copyNpub,
      child: InkWell(
        onTap: () => _copy(context),
        borderRadius: BorderRadius.circular(6),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  '${npub.substring(0, 14)}…${npub.substring(npub.length - 6)}',
                  style: style,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 6),
              Icon(Icons.copy, size: 14, color: style?.color),
            ],
          ),
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;
  const _Stat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Column(
        children: [
          Text(value, style: theme.textTheme.titleLarge),
          Text(label, style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }
}
