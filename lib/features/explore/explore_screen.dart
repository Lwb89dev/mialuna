import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/branding/mialuna_tag.dart';
import '../../core/nostr/event.dart';
import '../../core/nostr/filter.dart';
import '../../core/nostr/models/media_event.dart';

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
  String _activeTag = MialunaTag.hashtag;

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
    _activeTag = normalized;
    _sub?.cancel();
    if (_subId != null) ref.read(relayPoolProvider).unsubscribe(_subId!);
    setState(() {
      _results.clear();
      _seen.clear();
    });
    final pool = ref.read(relayPoolProvider);
    pool.connect();
    final (:id, :stream) = pool.subscribe([
      NostrFilter(
        kinds: NostrKinds.mediaKinds,
        tagFilters: const {},
        limit: 60,
      ).withTag('t', normalized),
    ]);
    _subId = id;
    _sub = stream.listen((event) {
      if (_seen.contains(event.id)) return;
      final post = MediaPost.tryParse(event);
      if (post == null || post.isStory || post.isExpired()) return;
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
            hintText: 'Cerca hashtag…',
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(24),
              borderSide: BorderSide.none,
            ),
            filled: true,
            isDense: true,
          ),
          textInputAction: TextInputAction.search,
          onSubmitted: _search,
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Text(
              '#$_activeTag',
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
  );
}
