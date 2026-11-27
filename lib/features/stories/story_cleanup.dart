import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/auth/auth_controller.dart';
import '../../core/net/safe_http.dart';
import '../../core/nostr/event.dart';
import '../../core/nostr/models/media_event.dart';
import '../../core/nostr/signer.dart';
import '../../core/notify/system_notifier.dart';
import '../social/post_deletion.dart';

/// Whether Mialuna takes your own stories down once their 24 hours are over.
/// On by default: a story is meant to be gone after a day, and until now it
/// was only hidden, while its photo or video stayed on the media server.
///
/// It is the choice offered for each new story, and what applies to every
/// story nobody explicitly chose for, so switching it off stops those.
class DeleteExpiredStories extends Notifier<bool> {
  static const _key = 'mialuna_delete_expired_stories';
  static const defaultValue = true;

  /// The user chose before the saved value was read: theirs wins.
  bool _chosen = false;

  /// Completes once the saved value has been read: nothing may be deleted on
  /// the strength of the default while the person's "no" is still on disk.
  Future<void> ready = Future.value();

  @override
  bool build() {
    _chosen = false;
    ready = _load();
    return defaultValue;
  }

  Future<void> _load() async {
    try {
      final prefs = await ref.read(sharedPreferencesLoader)();
      if (!_chosen) state = prefs.getBool(_key) ?? defaultValue;
    } catch (_) {
      // Unreadable: keep the default.
    }
  }

  Future<void> set(bool on) async {
    _chosen = true;
    state = on;
    final prefs = await ref.read(sharedPreferencesLoader)();
    await prefs.setBool(_key, on);
  }
}

final deleteExpiredStoriesProvider =
    NotifierProvider<DeleteExpiredStories, bool>(DeleteExpiredStories.new);

/// Where one of this account's stories stands.
enum StoryFate {
  /// Still being shown.
  live,

  /// To be deleted, and not done yet.
  waiting,

  /// A relay accepted the request and the servers confirmed the files gone.
  deleted,

  /// Its files stay: the person chose so.
  kept,

  /// Tried too many times: only on request from now on.
  failed,
}

/// One story of this account, as the "story deletion" screen shows it.
class TrackedStory {
  final MediaPost post;
  final StoryFate fate;

  /// Mialuna will take it down by itself when its time comes.
  final bool automatic;

  /// A relay accepted the deletion request (close-friends stories have none).
  final bool relaysDone;

  /// Hosts that did not confirm a file is gone.
  final List<String> mediaLeft;

  const TrackedStory({
    required this.post,
    required this.fate,
    required this.automatic,
    required this.relaysDone,
    this.mediaLeft = const [],
  });
}

/// What the app knows about taking this account's stories down.
class StoryCleanupState {
  /// Stories whose 24 hours are over and that are still to be taken down.
  final int due;

  /// Every story the phone remembers, newest first.
  final List<TrackedStory> stories;

  /// A cleanup is under way.
  final bool busy;

  const StoryCleanupState({
    this.due = 0,
    this.stories = const [],
    this.busy = false,
  });
}

/// A story of this account and what has been done about it.
class _Record {
  final String id;
  final bool private;

  /// The signed event; for a close-friends story only what is needed to find
  /// its files (see [StoryCleanup._minimal]), never its text nor its keys.
  final NostrEvent event;

  /// What was chosen for this story on this phone: true keeps its files,
  /// false deletes them, null leaves it to the story's own tag and then to
  /// Settings.
  bool? keep;

  /// Deletion was asked for by hand: there is nothing to wait for.
  bool requested;

  /// The request to the relays went through (always true for close-friends
  /// stories, which no relay can be asked about).
  bool relaysDone;
  bool mediaDone;
  int attempts;

  /// Not before this time (seconds), after a failure.
  int nextTry;

  /// When it was found fully deleted (seconds).
  int? deletedAt;
  List<String> mediaLeft;

  /// Changed since the app started, so a copy read late from disk is older.
  bool touched = false;

  _Record({
    required this.id,
    required this.private,
    required this.event,
    this.keep,
    this.requested = false,
    this.relaysDone = false,
    this.mediaDone = false,
    this.attempts = 0,
    this.nextTry = 0,
    this.deletedAt,
    this.mediaLeft = const [],
  });

  bool get done => relaysDone && mediaDone;

  late final MediaPost? post = MediaPost.tryParse(event, allowPrivate: private);

  bool get keeps => keep ?? (post?.asksToBeKept ?? false);

  /// Its time has come: the 24 hours are over, or somebody asked.
  bool isDue(int now) => requested || (post?.isExpired(now) ?? true);

  Map<String, dynamic> toJson() => {
    'event': event.toJson(),
    'private': private,
    'keep': ?keep,
    'requested': requested,
    'relays_done': relaysDone,
    'media_done': mediaDone,
    'attempts': attempts,
    'next_try': nextTry,
    'deleted_at': ?deletedAt,
    if (mediaLeft.isNotEmpty) 'media_left': mediaLeft,
  };

  static _Record? tryParse(Object? raw) {
    if (raw is! Map) return null;
    try {
      final event = NostrEvent.fromJson(
        Map<String, dynamic>.from(raw['event'] as Map),
      );
      return _Record(
        id: event.id,
        private: raw['private'] == true,
        event: event,
        keep: raw['keep'] as bool?,
        requested: raw['requested'] == true,
        relaysDone: raw['relays_done'] == true,
        mediaDone: raw['media_done'] == true,
        attempts: (raw['attempts'] as num?)?.toInt() ?? 0,
        nextTry: (raw['next_try'] as num?)?.toInt() ?? 0,
        deletedAt: (raw['deleted_at'] as num?)?.toInt(),
        mediaLeft: [...?(raw['media_left'] as List?)?.whereType<String>()],
      );
    } catch (_) {
      return null;
    }
  }
}

/// Takes the account's own stories down once their 24 hours are over, and
/// remembers how that went.
///
/// A story is only ever hidden by the app after a day (and dropped by the
/// relays that honour its NIP-40 expiration); its photo or video stays on the
/// media server. So each story of this account is written down when it is
/// published or first seen, and later, once expired, the relays and the media
/// servers are asked to delete it, in one batch for all that are due. The
/// ones the person chose to keep are left alone, and their files are not
/// taken down with another post that happens to share them.
///
/// Nobody is bothered for it: with a key on the phone it just happens, with
/// Amber or a remote signer (which would ask for approval from a timer) it
/// waits until the person asks. Close-friends stories need no signature
/// (their files go with the one-off key kept on the phone), and their
/// friends' apps let go of an expired story by themselves.
class StoryCleanup extends Notifier<StoryCleanupState> {
  static const _maxEntries = 300;
  static const _maxAttempts = 8;
  static const _batch = 50;
  static const _interval = Duration(minutes: 10);
  static const _firstRun = Duration(seconds: 20);

  /// How long a story that is gone stays listed.
  static const _remembered = 30 * 24 * 3600;

  final Map<String, _Record> _entries = {};
  Timer? _timer;
  Timer? _first;
  String? _pub;
  int _generation = 0;
  Future<void> _loaded = Future.value();
  bool _running = false;

  String get _file => 'story_cleanup_$_pub.json';

  @override
  StoryCleanupState build() {
    final pub = ref.watch(authProvider.select((a) => a.publicKey));
    final generation = ++_generation;
    ref.onDispose(() {
      _generation++;
      _timer?.cancel();
      _first?.cancel();
    });
    _entries.clear();
    _pub = pub;
    _running = false;
    if (pub == null) return const StoryCleanupState();
    _loaded = Future.microtask(() => _load(generation));
    ref.listen(appForegroundProvider, (_, front) {
      if (front) unawaited(run());
    });
    ref.listen(deleteExpiredStoriesProvider, (_, on) {
      _publishState();
      if (on) unawaited(run());
    });
    _timer = Timer.periodic(_interval, (_) => unawaited(run()));
    _first = Timer(_firstRun, () => unawaited(run()));
    return const StoryCleanupState();
  }

  int _now() => ref.read(unixClockProvider)();

  /// Writes [post], a story of this account, down for when it expires. [keep]
  /// is what was chosen for it on this phone, when something was.
  void track(MediaPost post, {bool? keep}) {
    if (_pub == null || post.author != _pub || !post.isStory) return;
    final known = _entries[post.id];
    if (known != null) {
      if (keep == null || known.keep == keep) return;
      known
        ..keep = keep
        ..touched = true;
    } else {
      final private = post.isPrivate;
      _entries[post.id] = _Record(
        id: post.id,
        private: private,
        event: private ? _minimal(post) : post.event,
        keep: keep,
        relaysDone: private,
      )..touched = keep != null;
    }
    _changed();
  }

  /// What is needed to find the files of a close-friends story, and nothing
  /// that was said in it: no text, no audience, no decryption keys.
  static NostrEvent _minimal(MediaPost post) {
    final e = post.event;
    return NostrEvent(
      id: e.id,
      pubkey: e.pubkey,
      createdAt: e.createdAt,
      kind: e.kind,
      tags: [
        for (final tag in e.tags)
          if (tag.isNotEmpty && tag[0] == 'imeta')
            [
              for (final part in tag)
                if (!part.startsWith('decryption-') &&
                    !part.startsWith('image-decryption-'))
                  part,
            ],
        [MediaPost.audienceTag, MediaPost.closeFriendsAudience],
        ['L', 'mialuna.story'],
        ['l', 'story', 'mialuna.story'],
        for (final tag in e.tagsNamed('expiration')) tag,
      ],
      content: '',
      sig: '',
    );
  }

  /// The person deleted [post] themselves: write down how that went.
  /// [mediaLeft] names the servers that did not confirm, and [filesGone] is
  /// false when anything of the files is left to do.
  void noteDeleted(
    MediaPost post, {
    required bool filesGone,
    List<String> mediaLeft = const [],
  }) {
    track(post);
    final entry = _entries[post.id];
    if (entry == null) return;
    entry
      ..keep = false
      ..requested = true
      ..relaysDone = true
      ..mediaDone = filesGone
      ..mediaLeft = mediaLeft
      ..deletedAt = filesGone ? _now() : null
      ..touched = true;
    _changed();
  }

  /// The stories whose files are to stay: deleting something else that shows
  /// the same file must not take it away from them.
  Future<List<MediaPost>> keptStories() async {
    await _loaded;
    return [
      for (final e in _entries.values)
        if (e.keeps) ?e.post,
    ];
  }

  Future<void> _load(int generation) async {
    final json = await ref.read(localCacheProvider).readJson(_file);
    if (generation != _generation) return;
    if (json is Map) {
      for (final raw in (json['entries'] as List? ?? const [])) {
        final entry = _Record.tryParse(raw);
        // What was noted while this was being read is older on disk, unless
        // nothing was decided about it yet.
        if (entry != null && !(_entries[entry.id]?.touched ?? false)) {
          _entries[entry.id] = entry;
        }
      }
    }
    _publishState();
  }

  void _changed() {
    _prune();
    _publishState();
    unawaited(_save());
  }

  /// Forgets what was deleted long ago, and keeps the list bounded: first of
  /// what is over and done with, last of what is meant to stay.
  void _prune() {
    final now = _now();
    _entries.removeWhere(
      (_, e) => e.done && (e.deletedAt ?? now) < now - _remembered,
    );
    while (_entries.length > _maxEntries) {
      final oldest =
          _firstWhere((e) => e.done) ??
          _firstWhere((e) => e.attempts >= _maxAttempts) ??
          _firstWhere((e) => !e.keeps) ??
          _entries.values.first;
      _entries.remove(oldest.id);
    }
  }

  _Record? _firstWhere(bool Function(_Record) test) {
    for (final e in _entries.values) {
      if (test(e)) return e;
    }
    return null;
  }

  /// Written once the saved list has been read: writing before would replace
  /// it with only what was noted since.
  Future<void> _save() async {
    final generation = _generation;
    await _loaded;
    if (generation != _generation || _pub == null) return;
    await ref.read(localCacheProvider).writeJson(_file, {
      'entries': [for (final e in _entries.values) e.toJson()],
    });
  }

  void _publishState() {
    final now = _now();
    final byDefault = ref.read(deleteExpiredStoriesProvider);
    var due = 0;
    final stories = <TrackedStory>[];
    for (final e in _entries.values) {
      final post = e.post;
      if (post == null) continue;
      final fate = _fate(e, now);
      if (fate == StoryFate.waiting) due++;
      stories.add(
        TrackedStory(
          post: post,
          fate: fate,
          automatic: !e.keeps && (e.keep == false || byDefault),
          relaysDone: e.relaysDone,
          mediaLeft: e.mediaLeft,
        ),
      );
    }
    stories.sort((a, b) => b.post.createdAt.compareTo(a.post.createdAt));
    state = StoryCleanupState(due: due, stories: stories, busy: _running);
  }

  static StoryFate _fate(_Record e, int now) {
    if (e.done) return StoryFate.deleted;
    if (e.keeps) return StoryFate.kept;
    if (!e.isDue(now)) return StoryFate.live;
    return e.attempts >= _maxAttempts ? StoryFate.failed : StoryFate.waiting;
  }

  /// Takes down the stories that are due. [ask] lets a signer such as Amber
  /// be asked to approve (the person pressed the button); without it such a
  /// signer is left alone, and so are the stories that are only to be deleted
  /// when Settings says so. True when nothing that is due remains.
  Future<bool> run({bool ask = false}) async {
    if (!await _guarded(() => _takeDown(ask))) return false;
    return state.due == 0;
  }

  /// Takes down story [id] now, whatever was chosen for it before, and asks
  /// again if that was done already. True when it is now deleted.
  Future<bool> deleteNow(String id) async {
    final ran = await _guarded(() async {
      final entry = _entries[id];
      if (entry == null) return;
      if (entry.done) {
        entry
          ..relaysDone = entry.private
          ..mediaDone = false
          ..deletedAt = null;
      }
      entry
        ..keep = false
        ..requested = true
        ..attempts = 0
        ..nextTry = 0
        ..touched = true;
      _changed();
      await _takeDown(true, only: id);
    });
    return ran && (_entries[id]?.done ?? false);
  }

  /// Keeps the files of story [id] after it expires, or stops keeping them.
  /// Only this phone is told: the published story cannot be changed.
  Future<void> setKeep(String id, bool keep) async {
    await _loaded;
    final entry = _entries[id];
    if (entry == null) return;
    entry
      ..keep = keep
      ..requested = false
      ..attempts = 0
      ..nextTry = 0
      ..touched = true;
    _changed();
    if (!keep) unawaited(run());
  }

  /// Asks the media servers whether the files of story [id] are still there:
  /// the hosts that still serve one, and whether any answer was unclear.
  Future<({List<String> online, bool unclear})> checkFiles(String id) async {
    await _loaded;
    final post = _entries[id]?.post;
    final urls = {
      for (final item in post?.media ?? const <MediaItem>[]) ...[
        item.url,
        ?item.previewUrl,
      ],
    };
    final client = ref.read(httpClientProvider);
    final online = <String>{};
    var unclear = urls.isEmpty;
    for (final url in urls) {
      final uri = Uri.tryParse(url);
      final there = uri == null
          ? null
          : await SafeHttp.isOnline(uri, client: client);
      if (there == null) unclear = true;
      if (there == true) online.add(uri!.host);
    }
    return (online: online.toList()..sort(), unclear: unclear);
  }

  /// Runs [step] unless another cleanup is under way, or the account changes.
  Future<bool> _guarded(Future<void> Function() step) async {
    final generation = _generation;
    if (_pub == null || _running) return false;
    _running = true;
    try {
      await _loaded;
      await ref.read(deleteExpiredStoriesProvider.notifier).ready;
      if (generation != _generation) return false;
      _publishState();
      await step();
    } finally {
      if (generation == _generation) {
        _running = false;
        _publishState();
      }
    }
    return generation == _generation;
  }

  Future<void> _takeDown(bool ask, {String? only}) async {
    final now = _now();
    final signer = ref.read(authProvider).signer;
    final canSign = signer.canSign && (ask || signer.type == SignerType.nsec);
    final byDefault = ref.read(deleteExpiredStoriesProvider);
    final due = <_Record>[];
    for (final entry in _entries.values.toList()) {
      if (entry.post == null) {
        _entries.remove(entry.id); // not a story any more, whatever it was
      } else if (_fate(entry, now) != StoryFate.waiting ||
          (only != null && entry.id != only)) {
        continue;
      } else if (ask ||
          ((entry.keep == false || byDefault) && entry.nextTry <= now)) {
        due.add(entry);
      }
    }
    if (due.isEmpty) return;
    final deletion = ref.read(expiredDeletionProvider);
    final failed = <String>{};

    final publicStories = [
      for (final e in due)
        if (!e.private) e,
    ];
    if (canSign) {
      await _relays(deletion, [
        for (final e in publicStories)
          if (!e.relaysDone) e,
      ], failed);
      // The files go once a relay has answered, as when you delete a post: if
      // none does, the check that no other post still shows a file had nothing
      // to look at, and could let one that is in use be deleted.
      await _media(
        deletion,
        [
          for (final e in publicStories)
            if (e.relaysDone && !e.mediaDone) e,
        ],
        failed,
        private: false,
      );
    }
    await _media(
      deletion,
      [
        for (final e in due)
          if (e.private && !e.mediaDone) e,
      ],
      failed,
      private: true,
    );

    for (final entry in due) {
      if (entry.done) {
        entry
          ..deletedAt = now
          ..mediaLeft = const [];
      } else if (failed.contains(entry.id)) {
        entry.attempts++;
        entry.nextTry = now + _backoff(entry.attempts).inSeconds;
      }
    }
    _changed();
  }

  /// One request to the relays for each batch of stories.
  Future<void> _relays(
    ExpiredDeletion deletion,
    List<_Record> entries,
    Set<String> failed,
  ) async {
    for (var i = 0; i < entries.length; i += _batch) {
      final chunk = entries.sublist(i, (i + _batch).clamp(0, entries.length));
      final report = await deletion.requestRelays([
        for (final e in chunk) e.post!,
      ]);
      for (final e in chunk) {
        if (report.ok) {
          e.relaysDone = true;
        } else {
          failed.add(e.id);
        }
      }
    }
  }

  /// The files of each batch of stories, taken down together.
  Future<void> _media(
    ExpiredDeletion deletion,
    List<_Record> entries,
    Set<String> failed, {
    required bool private,
  }) async {
    for (var i = 0; i < entries.length; i += _batch) {
      final chunk = entries.sublist(i, (i + _batch).clamp(0, entries.length));
      final posts = [for (final e in chunk) e.post!];
      final report = private
          ? await deletion.removePrivateMedia(posts)
          : await deletion.removePublicMedia(posts);
      final clean =
          report.ok && report.mediaLeft.isEmpty && report.mediaError == null;
      for (final e in chunk) {
        if (clean) {
          e.mediaDone = true;
        } else {
          failed.add(e.id);
          e.mediaLeft = _hostsOf(e.post!)
              .where(report.mediaLeft.contains)
              .toList();
        }
      }
    }
  }

  static Set<String> _hostsOf(MediaPost post) => {
    for (final item in post.media)
      for (final url in [item.url, ?item.previewUrl, ...item.fallbackUrls])
        ?Uri.tryParse(url)?.host,
  };

  /// 15 minutes, doubling, up to 6 hours.
  static Duration _backoff(int attempts) {
    final minutes = 15 * (1 << (attempts - 1).clamp(0, 10));
    return Duration(minutes: minutes.clamp(15, 360));
  }
}

final storyCleanupProvider = NotifierProvider<StoryCleanup, StoryCleanupState>(
  StoryCleanup.new,
);
