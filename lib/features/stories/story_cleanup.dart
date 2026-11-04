import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/auth/auth_controller.dart';
import '../../core/nostr/event.dart';
import '../../core/nostr/models/media_event.dart';
import '../../core/nostr/signer.dart';
import '../../core/notify/system_notifier.dart';
import '../social/post_deletion.dart';

/// Whether Mialuna takes your own stories down once their 24 hours are over.
/// On by default: a story is meant to be gone after a day, and until now it
/// was only hidden, while its photo or video stayed on the media server.
class DeleteExpiredStories extends Notifier<bool> {
  static const _key = 'mialuna_delete_expired_stories';
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

/// What the settings screen shows of the cleanup.
class StoryCleanupState {
  /// Stories whose 24 hours are over and that are still to be taken down.
  final int due;
  const StoryCleanupState({this.due = 0});
}

/// A story of this account that has to be taken down once it expires.
class _Pending {
  final String id;
  final bool private;

  /// The signed event; for a close-friends story only what is needed to find
  /// its files (see [StoryCleanup._minimal]), never its text nor its keys.
  final NostrEvent event;

  /// The request to the relays went through (always true for close-friends
  /// stories, which no relay can be asked about).
  bool relaysDone;
  bool mediaDone;
  int attempts;

  /// Not before this time (seconds), after a failure.
  int nextTry;

  _Pending({
    required this.id,
    required this.private,
    required this.event,
    this.relaysDone = false,
    this.mediaDone = false,
    this.attempts = 0,
    this.nextTry = 0,
  });

  bool get done => relaysDone && mediaDone;

  Map<String, dynamic> toJson() => {
    'event': event.toJson(),
    'private': private,
    'relays_done': relaysDone,
    'media_done': mediaDone,
    'attempts': attempts,
    'next_try': nextTry,
  };

  static _Pending? tryParse(Object? raw) {
    if (raw is! Map) return null;
    try {
      final event = NostrEvent.fromJson(
        Map<String, dynamic>.from(raw['event'] as Map),
      );
      return _Pending(
        id: event.id,
        private: raw['private'] == true,
        event: event,
        relaysDone: raw['relays_done'] == true,
        mediaDone: raw['media_done'] == true,
        attempts: (raw['attempts'] as num?)?.toInt() ?? 0,
        nextTry: (raw['next_try'] as num?)?.toInt() ?? 0,
      );
    } catch (_) {
      return null;
    }
  }

  MediaPost? get post => MediaPost.tryParse(event, allowPrivate: private);
}

/// Takes the account's own stories down once their 24 hours are over.
///
/// A story is only ever hidden by the app after a day (and dropped by the
/// relays that honour its NIP-40 expiration); its photo or video stays on the
/// media server. So each story of this account is written down when it is
/// published or first seen, and later, once expired, the relays and the media
/// servers are asked to delete it, in one batch for all that are due.
///
/// Nobody is bothered for it: with a key on the phone it just happens, with
/// Amber or a remote signer (which would ask for approval from a timer) it
/// waits until the person asks, in Settings. Close-friends stories need no
/// signature (their files go with the one-off key kept on the phone), and
/// their friends' apps let go of an expired story by themselves.
class StoryCleanup extends Notifier<StoryCleanupState> {
  static const _maxEntries = 300;
  static const _maxAttempts = 8;
  static const _batch = 50;
  static const _interval = Duration(minutes: 10);
  static const _firstRun = Duration(seconds: 20);

  final Map<String, _Pending> _entries = {};
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
      if (on) unawaited(run());
    });
    _timer = Timer.periodic(_interval, (_) => unawaited(run()));
    _first = Timer(_firstRun, () => unawaited(run()));
    return const StoryCleanupState();
  }

  int _now() => ref.read(unixClockProvider)();

  /// Writes [post], a story of this account, down for when it expires.
  void track(MediaPost post) {
    if (_pub == null || post.author != _pub || !post.isStory) return;
    if (_entries.containsKey(post.id)) return;
    final private = post.isPrivate;
    _entries[post.id] = _Pending(
      id: post.id,
      private: private,
      event: private ? _minimal(post) : post.event,
      relaysDone: private,
    );
    while (_entries.length > _maxEntries) {
      _entries.remove(_entries.keys.first);
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

  Future<void> _load(int generation) async {
    final json = await ref.read(localCacheProvider).readJson(_file);
    if (generation != _generation) return;
    if (json is Map) {
      for (final raw in (json['entries'] as List? ?? const [])) {
        final entry = _Pending.tryParse(raw);
        if (entry != null) _entries.putIfAbsent(entry.id, () => entry);
      }
    }
    _publishState();
  }

  void _changed() {
    _publishState();
    unawaited(_save());
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
    final due = _entries.values.where((e) => _expired(e, now)).length;
    if (due != state.due) state = StoryCleanupState(due: due);
  }

  static bool _expired(_Pending entry, int now) =>
      entry.post?.isExpired(now) ?? true;

  /// Takes down the stories that have expired. [ask] lets a signer such as
  /// Amber be asked to approve (the person pressed the button); without it
  /// such a signer is left alone, and so is a "no" in Settings. True when
  /// nothing that is due remains.
  Future<bool> run({bool ask = false}) async {
    final generation = _generation;
    if (_pub == null || _running) return false;
    if (!ask && !ref.read(deleteExpiredStoriesProvider)) return false;
    _running = true;
    try {
      await _loaded;
      if (generation != _generation) return false;
      await _takeDown(ask);
    } finally {
      if (generation == _generation) {
        _running = false;
        _publishState();
      }
    }
    return state.due == 0;
  }

  Future<void> _takeDown(bool ask) async {
    final now = _now();
    final signer = ref.read(authProvider).signer;
    final canSign = signer.canSign && (ask || signer.type == SignerType.nsec);
    final due = <_Pending>[];
    for (final entry in _entries.values.toList()) {
      if (entry.post == null) {
        _entries.remove(entry.id); // not a story any more, whatever it was
      } else if (_expired(entry, now) && (ask || entry.nextTry <= now)) {
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
        _entries.remove(entry.id);
      } else if (failed.contains(entry.id)) {
        entry.attempts++;
        entry.nextTry = now + _backoff(entry.attempts).inSeconds;
        if (entry.attempts >= _maxAttempts) _entries.remove(entry.id);
      }
    }
    _changed();
  }

  /// One request to the relays for each batch of stories.
  Future<void> _relays(
    ExpiredDeletion deletion,
    List<_Pending> entries,
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
    List<_Pending> entries,
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
        }
      }
    }
  }

  /// 15 minutes, doubling, up to 6 hours.
  static Duration _backoff(int attempts) {
    final minutes = 15 * (1 << (attempts - 1).clamp(0, 10));
    return Duration(minutes: minutes.clamp(15, 360));
  }
}

final storyCleanupProvider = NotifierProvider<StoryCleanup, StoryCleanupState>(
  StoryCleanup.new,
);
