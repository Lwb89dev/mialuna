import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/branding/mialuna_tag.dart';
import '../../core/nostr/event.dart';
import '../../core/nostr/filter.dart';
import '../../core/nostr/models/media_event.dart';
import '../../core/nostr/nip19.dart';
import '../../core/nostr/relay_pool.dart';
import '../../core/text/hashtags.dart';
import '../../l10n/strings.dart';
import '../feed/feed_controller.dart';
import '../feed/widgets/inline_video.dart';
import '../feed/widgets/nostr_image.dart';
import '../feed/widgets/post_card.dart';
import '../profile/profile_widgets.dart';
import '../search/people_search.dart';
import '../social/moderation_controller.dart';

/// Discover: everything the relays have (not just the people you follow),
/// as an image-first grid, with search by person, hashtag or words.
class ExploreScreen extends ConsumerStatefulWidget {
  /// Query to run on open (e.g. `#sunset` from a tapped hashtag).
  final String? initialQuery;
  const ExploreScreen({super.key, this.initialQuery});

  @override
  ConsumerState<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends ConsumerState<ExploreScreen> {
  final _searchController = TextEditingController();
  final _scroll = ScrollController();
  final Map<String, MediaPost> _results = {};
  PoolSubscription? _sub;
  StreamSubscription<NostrEvent>? _listener;
  Timer? _flush;
  bool _loading = false;

  /// null → the discover feed; otherwise the label of the running search.
  String? _activeLabel;
  List<NostrFilter> _lastFilters = const [];

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_maybeLoadMore);
    final q = widget.initialQuery;
    if (q != null && q.isNotEmpty) {
      _searchController.text = q;
      Future.microtask(() => _searchUniversal(q));
    }
  }

  @override
  void dispose() {
    _listener?.cancel();
    _sub?.close();
    _flush?.cancel();
    _searchController.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _maybeLoadMore() {
    if (_activeLabel != null || !_scroll.hasClients) return;
    if (_scroll.position.extentAfter < 900) {
      ref.read(feedProvider(FeedMode.discover).notifier).loadMore();
    }
  }

  void _showDiscover() {
    _listener?.cancel();
    _sub?.close();
    _searchController.clear();
    ref.read(peopleSearchProvider.notifier).setQuery('');
    setState(() {
      _activeLabel = null;
      _results.clear();
      _loading = false;
    });
  }

  void _search(String hashtag) {
    final normalized = hashtag.replaceFirst('#', '').toLowerCase().trim();
    if (normalized.isEmpty) return;
    _activeLabel = '#$normalized';
    _runQuery([
      NostrFilter(
        kinds: NostrKinds.mediaKinds,
        tagFilters: {
          '#t': [normalized],
        },
        limit: 60,
      ),
    ]);
  }

  /// Universal search: hashtag, npub account, or NIP-50 full-text.
  void _searchUniversal(String input) {
    final query = input.trim();
    if (query.isEmpty) {
      _showDiscover();
      return;
    }
    if (Nip19.isValidNpub(query)) {
      final pubkey = Nip19.decodeNpub(query);
      _activeLabel = context.l10n.postsByAuthor(query.substring(0, 12));
      _runQuery([
        NostrFilter(kinds: NostrKinds.mediaKinds, authors: [pubkey], limit: 60),
      ]);
    } else if (query.startsWith('#') || Hashtags.isBareWord(query)) {
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

  Future<void> _runQuery(List<NostrFilter> filters) async {
    _lastFilters = filters;
    _listener?.cancel();
    _sub?.close();
    setState(() {
      _results.clear();
      _loading = true;
    });
    final sub = ref
        .read(relayPoolProvider)
        .subscribe(filters, eoseTimeout: const Duration(seconds: 12));
    _sub = sub;
    _listener = sub.events.listen((event) {
      if (_results.containsKey(event.id)) return;
      if (ref.read(muteProvider).contains(event.pubkey) ||
          ref.read(blockProvider).contains(event.pubkey)) {
        return;
      }
      final post = MediaPost.tryParse(event);
      if (post == null || post.isStory || post.isExpired()) return;
      if (post.hashtags.any(ref.read(mutedHashtagsProvider).contains)) return;
      _results[event.id] = post;
      _flush ??= Timer(const Duration(milliseconds: 250), () {
        _flush = null;
        if (mounted) setState(() {});
      });
    });
    await sub.eose;
    await Future<void>.delayed(const Duration(milliseconds: 300));
    if (mounted && identical(_sub, sub)) setState(() => _loading = false);
  }

  Future<void> _refresh() async {
    if (_activeLabel == null) {
      await ref.read(feedProvider(FeedMode.discover).notifier).refresh();
    } else if (_lastFilters.isNotEmpty) {
      await _runQuery(_lastFilters);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    ref.listen(tabReselectProvider, (_, event) {
      if (event != null && event.branch == 1 && widget.initialQuery == null) {
        if (_scroll.hasClients) {
          _scroll.animateTo(
            0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
        _refresh();
      }
    });
    final broken = ref.watch(brokenMediaProvider);
    final discover = ref.watch(feedProvider(FeedMode.discover));
    final searching = _activeLabel != null;
    final source = searching ? _results.values.toList() : discover.posts;
    final posts = [
      for (final p in source)
        if (!broken.contains(p.id)) p,
    ]..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final loading = searching
        ? _loading
        : discover.isLoading || discover.isRefreshing;

    final typed = _searchController.text.trim();
    final people = ref.watch(peopleSearchProvider);
    final showPeople =
        typed.length >= 2 &&
        !typed.startsWith('#') &&
        people.results.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: context.l10n.searchHint,
            prefixIcon: const Icon(Icons.search),
            suffixIcon: typed.isEmpty && !searching
                ? null
                : IconButton(
                    icon: const Icon(Icons.close),
                    tooltip: context.l10n.clear,
                    onPressed: _showDiscover,
                  ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(24),
              borderSide: BorderSide.none,
            ),
            filled: true,
            isDense: true,
          ),
          textInputAction: TextInputAction.search,
          onChanged: (v) {
            ref.read(peopleSearchProvider.notifier).setQuery(v);
            setState(() {});
          },
          onSubmitted: _searchUniversal,
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: CustomScrollView(
          controller: _scroll,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                child: Wrap(
                  spacing: 8,
                  children: [
                    ChoiceChip(
                      label: Text(context.l10n.recent),
                      selected: !searching,
                      onSelected: (_) => _showDiscover(),
                    ),
                    ChoiceChip(
                      label: const Text('#${MialunaTag.hashtag}'),
                      selected: _activeLabel == '#${MialunaTag.hashtag}',
                      onSelected: (_) {
                        _searchController.text = '#${MialunaTag.hashtag}';
                        _search(MialunaTag.hashtag);
                      },
                    ),
                    if (searching)
                      Chip(
                        label: Text(_activeLabel!),
                        backgroundColor: theme.colorScheme.secondaryContainer,
                      ),
                  ],
                ),
              ),
            ),
            if (showPeople)
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 96,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    itemCount: people.results.take(15).length,
                    itemBuilder: (context, i) {
                      final pk = people.results[i];
                      return GestureDetector(
                        onTap: () => openProfile(context, pk),
                        child: SizedBox(
                          width: 78,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ProfileAvatar(
                                pubkey: pk,
                                radius: 26,
                                tappable: false,
                              ),
                              const SizedBox(height: 4),
                              AuthorName(
                                pubkey: pk,
                                tappable: false,
                                style: theme.textTheme.labelSmall,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                child: Text(
                  searching
                      ? context.l10n.searchDependsOnRelays
                      : context.l10n.recentPostsEverywhere,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
              ),
            ),
            if (posts.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: loading
                      ? const CircularProgressIndicator()
                      : Padding(
                          padding: const EdgeInsets.all(32),
                          child: Text(
                            context.l10n.noResultsOnRelays,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.outline,
                            ),
                          ),
                        ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.all(2),
                sliver: SliverGrid.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 2,
                    crossAxisSpacing: 2,
                  ),
                  itemCount: posts.length,
                  itemBuilder: (context, i) => PostThumbnail(
                    post: posts[i],
                    onTap: () => PostScreen.open(context, posts[i]),
                  ),
                ),
              ),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }
}

/// Square grid cell for a post: photo, or a video poster with a play badge;
/// a stack icon marks carousels.
class PostThumbnail extends StatelessWidget {
  final MediaPost post;
  final VoidCallback? onTap;
  const PostThumbnail({super.key, required this.post, this.onTap});

  @override
  Widget build(BuildContext context) {
    final item = post.media.first;
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        fit: StackFit.expand,
        children: [
          item.isVideo
              ? VideoPoster(item: item, postId: post.id)
              : NostrImage(item: item, postId: post.id, preferThumbnail: true),
          if (item.isVideo)
            const Positioned(
              top: 6,
              right: 6,
              child: Icon(
                Icons.play_arrow_rounded,
                color: Colors.white,
                size: 22,
                shadows: [Shadow(blurRadius: 4, color: Colors.black87)],
              ),
            )
          else if (post.isCarousel)
            const Positioned(
              top: 6,
              right: 6,
              child: Icon(
                Icons.collections,
                color: Colors.white,
                size: 18,
                shadows: [Shadow(blurRadius: 4, color: Colors.black87)],
              ),
            ),
        ],
      ),
    );
  }
}
