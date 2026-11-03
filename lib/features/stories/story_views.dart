import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/auth/auth_controller.dart';
import '../../core/nostr/event.dart';
import '../../core/nostr/nip59.dart';

// Who watched your stories, without asking any server.
//
// A Blossom server only knows that a URL was downloaded, never by whom; the
// story's own note is where this has to live. So whoever watches a story
// tells its author, in a message only the author can read: a rumor of
// [NostrKinds.storyView] listing the stories seen (`e` tags) and addressed
// to the author (`p`), gift-wrapped (NIP-59) like private likes and replies.
// Relays see a wrap from a throw-away key to the author: not who watched,
// not what.
//
// Watching is not announced unless `storyViewReceiptsProvider` allows it; the
// sending side lives in `story_receipts.dart`.

/// A person who watched a story, and when.
class StoryViewer {
  final String pubkey;
  final int at;
  const StoryViewer(this.pubkey, this.at);
}

class StoryViewsState {
  /// Story id → who watched it, most recent first.
  final Map<String, List<StoryViewer>> byStory;
  const StoryViewsState([this.byStory = const {}]);

  List<StoryViewer> of(String storyId) => byStory[storyId] ?? const [];
  int countOf(String storyId) => of(storyId).length;
}

/// Receipts that reached you, for your own stories. Kept on the device for a
/// few days (a story lives for one).
class StoryViewsController extends Notifier<StoryViewsState> {
  static const _keepFor = 3 * 24 * 3600;
  static const _maxStories = 400;
  static const _maxViewersPerStory = 2000;
  static const maxStoriesPerReceipt = 30;

  final Map<String, Map<String, int>> _data = {};
  Timer? _saveTimer;
  String? _pub;
  int _generation = 0;

  String get _file => 'story_views_$_pub.json';

  @override
  StoryViewsState build() {
    final generation = ++_generation;
    ref.onDispose(() {
      _generation++;
      _saveTimer?.cancel();
    });
    _data.clear();
    final pub = ref.watch(authProvider.select((a) => a.publicKey));
    _pub = pub;
    if (pub != null) Future.microtask(() => _load(generation));
    return const StoryViewsState();
  }

  static int _now() => DateTime.now().millisecondsSinceEpoch ~/ 1000;

  /// Offers a decrypted rumor; true when it was a receipt for this account.
  bool ingest(Rumor rumor) {
    final me = _pub;
    if (me == null || rumor.kind != NostrKinds.storyView) return false;
    if (rumor.pubkey == me || rumor.firstTag('p') != me) return false;
    final now = _now();
    // A viewer's clock may be a little ahead; a receipt cannot come from the
    // future.
    final at = rumor.createdAt > now ? now : rumor.createdAt;
    var changed = false;
    var count = 0;
    for (final t in rumor.tags) {
      if (t.length < 2 || t[0] != 'e') continue;
      if (++count > maxStoriesPerReceipt) break;
      changed |= _record(t[1], rumor.pubkey, at);
    }
    if (changed) {
      _publish();
      _scheduleSave();
    }
    return changed;
  }

  bool _record(String storyId, String viewer, int at) {
    if (storyId.length != 64) return false;
    final viewers = _data.putIfAbsent(storyId, () => {});
    if (viewers.length >= _maxViewersPerStory && !viewers.containsKey(viewer)) {
      return false;
    }
    final known = viewers[viewer];
    if (known != null && known >= at) return false;
    viewers[viewer] = at;
    return true;
  }

  void _publish() {
    state = StoryViewsState({
      for (final e in _data.entries)
        e.key: [for (final v in e.value.entries) StoryViewer(v.key, v.value)]
          ..sort((a, b) => b.at.compareTo(a.at)),
    });
  }

  void _prune() {
    final cutoff = _now() - _keepFor;
    _data.forEach((_, v) => v.removeWhere((_, at) => at < cutoff));
    _data.removeWhere((_, v) => v.isEmpty);
    if (_data.length <= _maxStories) return;
    final newest = _data.entries.toList()
      ..sort((a, b) => _latest(b.value).compareTo(_latest(a.value)));
    for (final e in newest.skip(_maxStories)) {
      _data.remove(e.key);
    }
  }

  static int _latest(Map<String, int> viewers) =>
      viewers.values.fold(0, (m, at) => at > m ? at : m);

  Future<void> _load(int generation) async {
    final json = await ref.read(localCacheProvider).readJson(_file);
    if (generation != _generation || json is! Map) return;
    json.forEach((story, viewers) {
      if (story is! String || viewers is! Map) return;
      viewers.forEach((viewer, at) {
        if (viewer is String && at is num) _record(story, viewer, at.toInt());
      });
    });
    _prune();
    _publish();
  }

  void _scheduleSave() {
    _saveTimer?.cancel();
    final generation = _generation;
    _saveTimer = Timer(const Duration(seconds: 2), () {
      if (generation != _generation) return;
      _prune();
      ref.read(localCacheProvider).writeJson(_file, _data);
    });
  }
}

final storyViewsProvider =
    NotifierProvider<StoryViewsController, StoryViewsState>(
      StoryViewsController.new,
    );
