import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/auth/auth_controller.dart';
import '../../core/nostr/event.dart';
import '../../core/nostr/models/media_event.dart';
import '../../core/nostr/nip59.dart';
import '../private/private_delivery.dart';

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
// Watching is not announced unless [storyViewReceiptsProvider] allows it.

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

/// Whether watching a story tells its author. On by default (like every
/// other app with stories) and one switch away from off.
class StoryViewReceipts extends Notifier<bool> {
  static const _key = 'mialuna_send_story_views';
  static const defaultValue = true;

  /// The user chose before the saved value was read: theirs wins.
  bool _chosen = false;

  @override
  bool build() {
    _chosen = false;
    _load();
    return defaultValue;
  }

  Future<void> _load() async {
    final prefs = await ref.read(sharedPreferencesLoader)();
    if (!_chosen) state = prefs.getBool(_key) ?? defaultValue;
  }

  Future<void> set(bool enabled) async {
    _chosen = true;
    state = enabled;
    final prefs = await ref.read(sharedPreferencesLoader)();
    await prefs.setBool(_key, enabled);
  }
}

final storyViewReceiptsProvider = NotifierProvider<StoryViewReceipts, bool>(
  StoryViewReceipts.new,
);

/// Collects the stories this device watched and tells each author, once, when
/// the viewer moves on from their stories: one message per author however
/// many stories they had (each message costs a signer round trip).
class StoryViewReporter {
  static const _sentKeyPrefix = 'mialuna_story_views_sent_';
  static const _maxRemembered = 800;

  final Ref _ref;
  final Map<String, Set<String>> _pending = {}; // author → story ids
  Set<String>? _sent;
  String? _sentFor; // whose list [_sent] is
  bool _flushing = false;

  /// What was reported belongs to the account that watched.
  String get _sentKey => '$_sentKeyPrefix${_ref.read(authProvider).publicKey}';

  StoryViewReporter(this._ref);

  /// Notes that [story] was watched.
  Future<void> viewed(MediaPost story) async {
    final auth = _ref.read(authProvider);
    final me = auth.publicKey;
    if (me == null || story.author == me || !auth.signer.canEncrypt) return;
    if (!_ref.read(storyViewReceiptsProvider)) return;
    final sent = await _sentIds();
    if (sent.contains(story.id)) return;
    _pending.putIfAbsent(story.author, () => {}).add(story.id);
  }

  Future<Set<String>> _sentIds() async {
    final account = _ref.read(authProvider).publicKey;
    final known = _sent;
    if (known != null && _sentFor == account) return known;
    final prefs = await _ref.read(sharedPreferencesLoader)();
    _sentFor = account;
    return _sent = {...?prefs.getStringList(_sentKey)};
  }

  /// Sends what is waiting: for [author] only, or for everybody.
  Future<void> flush({String? author}) async {
    if (_flushing) return;
    _flushing = true;
    try {
      final authors = author == null ? _pending.keys.toList() : [author];
      for (final a in authors) {
        final ids = _pending.remove(a);
        if (ids == null || ids.isEmpty) continue;
        await _send(a, ids);
      }
    } finally {
      _flushing = false;
    }
  }

  Future<void> _send(String author, Set<String> ids) async {
    final me = _ref.read(authProvider).publicKey;
    if (me == null) return;
    final batch = ids.take(StoryViewsController.maxStoriesPerReceipt).toList();
    final rumor = Rumor.create(
      pubkey: me,
      kind: NostrKinds.storyView,
      tags: [
        for (final id in batch) ['e', id],
        ['p', author],
      ],
      content: '',
    );
    try {
      // To the author only: no copy for yourself, nothing to keep.
      await _ref.read(privateDeliveryProvider).send(rumor, [
        author,
      ], copyToSelf: false);
    } catch (_) {
      // A refused signer request or no reachable inbox: not worth asking again.
    }
    await _remember(batch);
  }

  Future<void> _remember(List<String> ids) async {
    final sent = await _sentIds();
    sent.addAll(ids);
    final list = sent.toList();
    final kept = list.length > _maxRemembered
        ? list.sublist(list.length - _maxRemembered)
        : list;
    _sent = kept.toSet();
    final prefs = await _ref.read(sharedPreferencesLoader)();
    await prefs.setStringList(_sentKey, kept);
  }
}

final storyViewReporterProvider = Provider<StoryViewReporter>(
  StoryViewReporter.new,
);
