import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/auth/auth_controller.dart';
import '../../core/nostr/event.dart';
import '../../core/nostr/nip59.dart';
import 'stories_controller.dart' show ownStoriesProvider;

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

/// A receipt for a story not (yet) known to be one of yours.
class _Held {
  final String story;
  final String viewer;
  final int at;
  const _Held(this.story, this.viewer, this.at);
}

/// Receipts that reached you, for your own stories. Kept on the device for a
/// few days (a story lives for one).
///
/// A receipt is a self-reported acknowledgement, not proof: the message is
/// authentic (only its sender can have sealed it) but nothing says that the
/// sender watched anything, or that the story is yours. So only receipts for
/// *your own live stories* are counted. One that names a story this phone
/// does not know yet (the rail is still loading, the story was published
/// elsewhere) is held for a little while, in a bounded buffer, and counted
/// the moment the story shows up; the rest is forgotten.
class StoryViewsController extends Notifier<StoryViewsState> {
  static const _keepFor = 3 * 24 * 3600;
  static const _maxStories = 400;
  static const _maxViewersPerStory = 2000;
  static const maxStoriesPerReceipt = 30;

  /// How many unverified receipts are held at most, how many for one sender,
  /// and for how long (seconds).
  static const maxHeld = 600;
  static const maxHeldPerViewer = 60;
  static const heldFor = 3600;

  static final _hexId = RegExp(r'^[0-9a-f]{64}$');

  /// Story id → viewer → when. Only your own stories are in here.
  final Map<String, Map<String, int>> _data = {};

  /// Not verified yet, oldest first. Keyed by "story:viewer".
  final Map<String, _Held> _held = {};
  final Map<String, int> _heldPerViewer = {};
  Map<String, int> _own = const {};
  Timer? _saveTimer;
  String? _pub;
  int _generation = 0;

  String get _file => 'story_views_$_pub.json';

  /// How many receipts are waiting for their story to be recognised.
  int get heldCount => _held.length;

  @override
  StoryViewsState build() {
    final generation = ++_generation;
    ref.onDispose(() {
      _generation++;
      _saveTimer?.cancel();
    });
    _data.clear();
    _held.clear();
    _heldPerViewer.clear();
    final pub = ref.watch(authProvider.select((a) => a.publicKey));
    _pub = pub;
    _own = pub == null ? const {} : ref.read(ownStoriesProvider);
    // A story of yours appearing is what turns held receipts into views.
    ref.listen(ownStoriesProvider, (_, own) {
      _own = own;
      _verifyHeld();
    });
    if (pub != null) Future.microtask(() => _load(generation));
    return const StoryViewsState();
  }

  int _now() => ref.read(unixClockProvider)();

  /// Offers a decrypted rumor; true when it was a receipt for this account
  /// and told us something new.
  bool ingest(Rumor rumor) {
    final me = _pub;
    if (me == null || rumor.kind != NostrKinds.storyView) return false;
    if (rumor.pubkey == me || rumor.firstTag('p') != me) return false;
    if (!_hexId.hasMatch(rumor.pubkey)) return false;
    final now = _now();
    // A viewer's clock may be a little ahead; a receipt cannot come from the
    // future, nor from before what is kept.
    final at = rumor.createdAt > now ? now : rumor.createdAt;
    if (at < now - _keepFor) return false;
    _forgetStale(now);
    final counted = <String>{};
    var changed = false;
    var seen = 0;
    for (final t in rumor.tags) {
      if (t.length < 2 || t[0] != 'e') continue;
      if (++seen > maxStoriesPerReceipt) break;
      final story = t[1];
      if (!_hexId.hasMatch(story)) continue;
      final created = _own[story];
      if (created == null) {
        changed |= _hold(story, rumor.pubkey, at);
      } else if (_record(story, rumor.pubkey, at < created ? created : at)) {
        counted.add(story);
        changed = true;
      }
    }
    if (counted.isNotEmpty) _publish(counted);
    if (changed) _scheduleSave();
    return changed;
  }

  bool _record(String storyId, String viewer, int at) {
    final viewers = _data.putIfAbsent(storyId, () => {});
    if (viewers.length >= _maxViewersPerStory && !viewers.containsKey(viewer)) {
      return false;
    }
    final known = viewers[viewer];
    if (known != null && known >= at) return false;
    viewers[viewer] = at;
    return true;
  }

  bool _hold(String story, String viewer, int at) {
    final key = '$story:$viewer';
    final known = _held[key];
    if (known != null) {
      if (known.at >= at) return false;
      _held[key] = _Held(story, viewer, at);
      return true;
    }
    if ((_heldPerViewer[viewer] ?? 0) >= maxHeldPerViewer) return false;
    while (_held.length >= maxHeld) {
      _unhold(_held.keys.first);
    }
    _held[key] = _Held(story, viewer, at);
    _heldPerViewer[viewer] = (_heldPerViewer[viewer] ?? 0) + 1;
    return true;
  }

  void _unhold(String key) {
    final gone = _held.remove(key);
    if (gone == null) return;
    final left = (_heldPerViewer[gone.viewer] ?? 1) - 1;
    if (left <= 0) {
      _heldPerViewer.remove(gone.viewer);
    } else {
      _heldPerViewer[gone.viewer] = left;
    }
  }

  void _forgetStale(int now) {
    while (_held.isNotEmpty && now - _held.values.first.at > heldFor) {
      _unhold(_held.keys.first);
    }
  }

  /// Counts the held receipts whose story has turned out to be yours.
  void _verifyHeld() {
    if (_held.isEmpty) return;
    final now = _now();
    _forgetStale(now);
    final counted = <String>{};
    for (final entry in _held.entries.toList()) {
      final created = _own[entry.value.story];
      if (created == null) continue;
      _unhold(entry.key);
      final h = entry.value;
      if (_record(h.story, h.viewer, h.at < created ? created : h.at)) {
        counted.add(h.story);
      }
    }
    if (counted.isEmpty) return;
    _publish(counted);
    _scheduleSave();
  }

  /// Puts the viewers of [stories] on screen; the others are left as they
  /// were, so a burst of receipts does not rebuild the whole list each time.
  void _publish(Iterable<String> stories) {
    final next = {...state.byStory};
    for (final id in stories) {
      final viewers = _data[id];
      if (viewers == null || viewers.isEmpty) {
        next.remove(id);
        continue;
      }
      next[id] = _sorted(viewers);
    }
    state = StoryViewsState(next);
  }

  static List<StoryViewer> _sorted(Map<String, int> viewers) =>
      [for (final v in viewers.entries) StoryViewer(v.key, v.value)]
        ..sort((a, b) => b.at.compareTo(a.at));

  void _prune() {
    final now = _now();
    final cutoff = now - _keepFor;
    _data.forEach((_, v) => v.removeWhere((_, at) => at < cutoff));
    _data.removeWhere((_, v) => v.isEmpty);
    for (final key in [
      for (final e in _held.entries)
        if (e.value.at < cutoff) e.key,
    ]) {
      _unhold(key);
    }
    _forgetStale(now);
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
    if (json['v'] == 2) {
      _readVerified(json['views']);
      _readHeld(json['held']);
    } else {
      // The first format kept whatever anybody had sent, unchecked: it is
      // trusted no further than a receipt that has just arrived.
      json.forEach((story, viewers) {
        if (story is! String || viewers is! Map) return;
        viewers.forEach((viewer, at) {
          if (viewer is String && at is num && _hexId.hasMatch(story)) {
            _hold(story, viewer, at.toInt());
          }
        });
      });
    }
    _prune();
    _verifyHeld();
    _publish(_data.keys.toSet()..addAll(state.byStory.keys));
  }

  void _readVerified(Object? views) {
    if (views is! Map) return;
    views.forEach((story, viewers) {
      if (story is! String || viewers is! Map) return;
      viewers.forEach((viewer, at) {
        if (viewer is String && at is num) _record(story, viewer, at.toInt());
      });
    });
  }

  void _readHeld(Object? held) {
    if (held is! List) return;
    for (final h in held) {
      if (h is! List || h.length != 3) continue;
      final [story, viewer, at] = h;
      if (story is String && viewer is String && at is num) {
        _hold(story, viewer, at.toInt());
      }
    }
  }

  /// Writes at most every couple of seconds, however many receipts arrive.
  void _scheduleSave() {
    if (_saveTimer?.isActive ?? false) return;
    final generation = _generation;
    _saveTimer = Timer(const Duration(seconds: 2), () {
      if (generation != _generation) return;
      _prune();
      ref.read(localCacheProvider).writeJson(_file, {
        'v': 2,
        'views': _data,
        'held': [
          for (final h in _held.values) [h.story, h.viewer, h.at],
        ],
      });
    });
  }
}

final storyViewsProvider =
    NotifierProvider<StoryViewsController, StoryViewsState>(
      StoryViewsController.new,
    );
