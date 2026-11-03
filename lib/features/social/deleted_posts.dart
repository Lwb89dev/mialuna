import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';

/// Ids of posts that were deleted, as far as this device knows.
///
/// A deletion request (NIP-09) is only a request: a relay that ignores it
/// keeps handing the post out, and a feed that was saved to disk still holds
/// it. Every list of posts leaves out the ids in here, so a post that was
/// deleted stays gone. Not tied to an account: an id is one public event.
class DeletedPosts extends Notifier<Set<String>> {
  static const file = 'deleted_posts.json';
  static const _maxIds = 1000;

  bool _disposed = false;
  Future<void>? _loaded;

  @override
  Set<String> build() {
    _disposed = false;
    ref.onDispose(() => _disposed = true);
    _loaded = Future.microtask(_load);
    return const {};
  }

  Future<void> _load() async {
    final json = await ref.read(localCacheProvider).readJson(file);
    if (_disposed || json is! List) return;
    // What was deleted while this was reading comes last: it is the newest.
    state = {
      for (final id in json)
        if (id is String) id,
      ...state,
    };
  }

  /// Adds [ids] to the deleted ones and keeps them for the next start.
  void add(Iterable<String> ids) {
    final next = {...state};
    for (final id in ids) {
      next.remove(id); // newest last: the oldest are dropped first
      next.add(id);
    }
    while (next.length > _maxIds) {
      next.remove(next.first);
    }
    state = next;
    _save();
  }

  /// Writes what is known now, once the saved ids have been read: writing
  /// before would replace them with only what was deleted since.
  Future<void> _save() async {
    await _loaded;
    if (_disposed) return;
    await ref.read(localCacheProvider).writeJson(file, state.toList());
  }
}

final deletedPostsProvider = NotifierProvider<DeletedPosts, Set<String>>(
  DeletedPosts.new,
);
