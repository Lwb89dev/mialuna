import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../core/auth/auth_controller.dart';
import '../../core/nostr/event.dart';
import '../../core/nostr/filter.dart';
import '../../core/nostr/models/media_event.dart';
import '../../core/nostr/signer.dart';
import '../social/follow_controller.dart';
import 'edit_profile_screen.dart';

/// Own media posts grid data.
final ownPostsProvider = StreamProvider<List<MediaPost>>((ref) {
  final pub = ref.watch(authProvider).publicKey;
  if (pub == null) return const Stream.empty();
  final pool = ref.watch(relayPoolProvider)..connect();
  final (:id, :stream) = pool.subscribe([
    NostrFilter(kinds: NostrKinds.mediaKinds, authors: [pub], limit: 90),
  ]);
  ref.onDispose(() => pool.unsubscribe(id));
  final seen = <String>{};
  final posts = <MediaPost>[];
  final controller = StreamController<List<MediaPost>>();
  final sub = stream.listen((event) {
    if (seen.contains(event.id)) return;
    final post = MediaPost.tryParse(event);
    if (post == null || post.isStory || post.isExpired()) return;
    seen.add(event.id);
    posts.add(post);
    posts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    controller.add(List.of(posts));
  });
  ref.onDispose(() {
    sub.cancel();
    controller.close();
  });
  return controller.stream;
});

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final theme = Theme.of(context);

    if (auth.isGuest) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profilo')),
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
                'Stai navigando come ospite',
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Accedi per pubblicare, seguire e interagire.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () => context.go('/login'),
                child: const Text('Accedi'),
              ),
            ],
          ),
        ),
      );
    }

    final pub = auth.publicKey!;
    final metadata = ref.watch(profileMetadataProvider(pub));
    final posts = ref.watch(ownPostsProvider);
    final following = ref.watch(followListProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(metadata.value?.label ?? 'Profilo'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Modifica profilo',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => EditProfileScreen(current: metadata.value),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Esci',
            onPressed: () async {
              await ref.read(authProvider.notifier).logout();
              if (context.mounted) context.go('/login');
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundImage: metadata.value?.picture != null
                    ? CachedNetworkImageProvider(metadata.value!.picture!)
                    : null,
                child: metadata.value?.picture == null
                    ? Text(
                        pub.substring(0, 2).toUpperCase(),
                        style: theme.textTheme.headlineSmall,
                      )
                    : null,
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _Stat(label: 'Post', value: '${posts.value?.length ?? 0}'),
                    _Stat(label: 'Seguiti', value: '${following.length}'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (metadata.value?.label != null)
            Text(metadata.value!.label, style: theme.textTheme.titleMedium),
          if (metadata.value?.nip05 != null)
            Row(
              children: [
                Icon(
                  Icons.verified,
                  size: 16,
                  color: theme.colorScheme.secondary,
                ),
                const SizedBox(width: 4),
                Text(metadata.value!.nip05!, style: theme.textTheme.bodySmall),
              ],
            ),
          if (metadata.value?.about != null) ...[
            const SizedBox(height: 4),
            Text(metadata.value!.about!),
          ],
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: SelectableText(
                  auth.npub ?? '',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.copy, size: 18),
                tooltip: 'Copia npub',
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: auth.npub ?? ''));
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('npub copiato')));
                },
              ),
            ],
          ),
          Center(
            child: Chip(
              avatar: const Icon(Icons.key, size: 16),
              label: Text(switch (auth.signer.type) {
                SignerType.amber => 'Amber (NIP-55)',
                SignerType.nsec => 'Chiave locale',
                SignerType.bunker => 'Bunker (NIP-46)',
                SignerType.guest => 'Ospite',
              }),
            ),
          ),
          const SizedBox(height: 16),
          const Divider(),
          posts.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(32),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (_, _) => const SizedBox.shrink(),
            data: (list) => list.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(32),
                    child: Text(
                      'Non hai ancora pubblicato nulla.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                  )
                : GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: 2,
                          crossAxisSpacing: 2,
                        ),
                    itemCount: list.length,
                    itemBuilder: (context, i) {
                      final item = list[i].media.first;
                      return item.isVideo
                          ? Container(
                              color: Colors.black,
                              child: const Icon(
                                Icons.play_circle_outline,
                                color: Colors.white70,
                              ),
                            )
                          : CachedNetworkImage(
                              imageUrl: item.previewUrl ?? item.url,
                              fit: BoxFit.cover,
                              errorWidget: (_, _, _) => Container(
                                color:
                                    theme.colorScheme.surfaceContainerHighest,
                              ),
                            );
                    },
                  ),
          ),
        ],
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
    return Column(
      children: [
        Text(value, style: theme.textTheme.titleLarge),
        Text(label, style: theme.textTheme.bodySmall),
      ],
    );
  }
}
