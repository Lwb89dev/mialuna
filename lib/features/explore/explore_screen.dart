import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/branding/mialuna_tag.dart';
import '../../core/nostr/event.dart';
import '../../core/nostr/filter.dart';
import '../../core/nostr/models/media_event.dart';
import '../../core/nostr/nip19.dart';
import '../social/moderation_controller.dart';

/// Explore: image-first discovery grid + hashtag search + official
/// #mialuna feed.
class ExploreScreen extends ConsumerStatefulWidget {
  const ExploreScreen({super.key});

  @override
  ConsumerState<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends ConsumerState<ExploreScreen> {
  final _searchController = TextEditingController();
  final List<MediaPost> _results = [];
  final Set<String> _seen = {};
  StreamSubscription<NostrEvent>? _sub;
  String? _subId;

  @override
  void initState() {
    super.initState();
    _search(MialunaTag.hashtag);
  }

  @override
  void dispose() {
    _sub?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _search(String hashtag) {
    final normalized = hashtag.replaceFirst('#', '').toLowerCase().trim();
    if (normalized.isEmpty) return;
    _activeLabel = '#$normalized';
    _runQuery([
      const NostrFilter(
        kinds: NostrKinds.mediaKinds,
        tagFilters: {},
        limit: 60,
      ).withTag('t', normalized),
    ]);
  }

  /// Universal search: hashtag, npub account, or NIP-50 full-text.
  void _searchUniversal(String input) {
    final query = input.trim();
    if (query.isEmpty) return;
    if (Nip19.isValidNpub(query)) {
      final pubkey = Nip19.decodeNpub(query);
      _activeLabel = 'Post di ${query.substring(0, 12)}…';
      _runQuery([
        NostrFilter(kinds: NostrKinds.mediaKinds, authors: [pubkey], limit: 60),
      ]);
    } else if (query.startsWith('#') || RegExp(r'^\w+$').hasMatch(query)) {
      _search(query);
    } else {
      _activeLabel = '“$query”';
      _runQuery([
        NostrFilter(
          kinds: NostrKinds.mediaKinds,
          search: query, // NIP-50; relays without support return nothing
          limit: 60,
        ),
      ]);
    }
  }

  String _activeLabel = '#${MialunaTag.hashtag}';

  void _runQuery(List<NostrFilter> filters) {
    _sub?.cancel();
    if (_subId != null) ref.read(relayPoolProvider).unsubscribe(_subId!);
    setState(() {
      _results.clear();
      _seen.clear();
    });
    final pool = ref.read(relayPoolProvider);
    pool.connect();
    final (:id, :stream) = pool.subscribe(filters);
    _subId = id;
    _sub = stream.listen((event) {
      if (_seen.contains(event.id)) return;
      if (ref.read(muteProvider).contains(event.pubkey) ||
          ref.read(blockProvider).contains(event.pubkey)) {
        return;
      }
      final post = MediaPost.tryParse(event);
      if (post == null || post.isStory || post.isExpired()) return;
      if (post.hashtags.any(ref.read(mutedHashtagsProvider).contains)) return;
      _seen.add(event.id);
      setState(() => _results.add(post));
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Cerca hashtag, npub o parole…',
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(24),
              borderSide: BorderSide.none,
            ),
            filled: true,
            isDense: true,
          ),
          textInputAction: TextInputAction.search,
          onSubmitted: _searchUniversal,
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Text(
              _activeLabel,
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.secondary,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Text(
              'La scoperta dipende dai relay configurati: i risultati possono essere parziali.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
          ),
          Expanded(
            child: _results.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : GridView.builder(
                    padding: const EdgeInsets.all(2),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: 2,
                          crossAxisSpacing: 2,
                        ),
                    itemCount: _results.length,
                    itemBuilder: (context, i) {
                      final post = _results[i];
                      final item = post.media.first;
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

extension on NostrFilter {
  NostrFilter withTag(String name, String value) => NostrFilter(
    ids: ids,
    authors: authors,
    kinds: kinds,
    tagFilters: {
      ...?tagFilters,
      '#$name': [value],
    },
    since: since,
    until: until,
    limit: limit,
    search: search,
  );
}
