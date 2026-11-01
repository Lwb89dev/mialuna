import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../feed/feed_controller.dart';
import '../feed/widgets/post_card.dart';

class FeedScreen extends ConsumerWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feed = ref.watch(feedProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Mialuna',
          style: Theme.of(context).textTheme.headlineSmall
              ?.copyWith(fontWeight: FontWeight.w700, letterSpacing: -0.5),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(feedProvider.notifier).refresh(),
        child: feed.isLoading
            ? const Center(child: CircularProgressIndicator())
            : feed.posts.isEmpty
            ? ListView(
                children: [
                  const SizedBox(height: 120),
                  Icon(
                    Icons.nightlight_round,
                    size: 64,
                    color: Theme.of(context).colorScheme.tertiary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Nessun momento ancora.\nScorri per aggiornare o pubblica il tuo primo scatto.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              )
            : ListView.builder(
                itemCount: feed.posts.length + 1,
                itemBuilder: (context, i) {
                  if (i == feed.posts.length) {
                    if (feed.isLoadingMore) {
                      return const Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    return TextButton(
                      onPressed: () =>
                          ref.read(feedProvider.notifier).loadMore(),
                      child: const Text('Carica altri momenti'),
                    );
                  }
                  return PostCard(post: feed.posts[i]);
                },
              ),
      ),
    );
  }
}
