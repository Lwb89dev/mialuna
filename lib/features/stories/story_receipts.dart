import 'dart:async';
import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../app/providers.dart';
import '../../core/auth/auth_controller.dart';
import '../../core/nostr/event.dart';
import '../../core/nostr/models/media_event.dart';
import '../../core/nostr/nip59.dart';
import '../../core/nostr/signer.dart';
import '../../core/storage/local_cache.dart';
import '../private/private_delivery.dart';
import 'story_views.dart' show StoryViewsController;

// Telling the author of a story that you watched it.
//
// The message itself (a kind 1417 rumor in a NIP-59 gift wrap) is described in
// `story_views.dart`. This file is the sending side: what is waiting to be
// sent, when, and what happens when it cannot be.
//
// A receipt is *delivered* only when the author's inbox relay accepted the
// gift wrap that carried it. That says the relay took it, not that the author
// read it. Anything short of that stays in a small outbox on the phone and is
// tried again later, so a refused signer request or a relay that is down does
// not lose it.

/// Whether watching a story tells its author. On by default (like every
/// other app with stories) and one switch away from off.
///
/// Switching it off also takes back what is waiting to be sent. A receipt a
/// relay has already accepted cannot be recalled.
class StoryViewReceipts extends Notifier<bool> {
  static const _key = 'mialuna_send_story_views';
  static const defaultValue = true;

  /// The user chose before the saved value was read: theirs wins.
  bool _chosen = false;
  Completer<void> _loaded = Completer<void>();

  /// Completes once the saved choice is known. Until then [defaultValue] is a
  /// guess, and nothing is sent on the strength of a guess.
  Future<void> get loaded => _loaded.future;

  /// What the user allows right now.
  bool get enabled => state;

  @override
  bool build() {
    _chosen = false;
    _loaded = Completer<void>();
    _load(_loaded);
    return defaultValue;
  }

  Future<void> _load(Completer<void> done) async {
    try {
      final prefs = await ref.read(sharedPreferencesLoader)();
      if (!_chosen) state = prefs.getBool(_key) ?? defaultValue;
    } catch (_) {
      // The saved choice cannot be read: fail closed.
      if (!_chosen) state = false;
    } finally {
      if (!done.isCompleted) done.complete();
    }
  }

  Future<void> set(bool enabled) async {
    _chosen = true;
    state = enabled;
    if (!_loaded.isCompleted) _loaded.complete();
    // What has not left the phone yet does not leave: now, not at the next
    // send, and not after a restart.
    if (!enabled) await ref.read(storyViewReporterProvider).withdraw();
    final prefs = await ref.read(sharedPreferencesLoader)();
    await prefs.setBool(_key, enabled);
  }
}

final storyViewReceiptsProvider = NotifierProvider<StoryViewReceipts, bool>(
  StoryViewReceipts.new,
);

/// Where a story's receipt stands.
enum ReceiptState {
  /// Waiting for the viewer to move on from the author's stories.
  pending,

  /// A gift wrap is being signed or published right now.
  sending,

  /// Tried and failed; will be tried again, not before its back-off is over.
  failed,

  /// The author's inbox relay accepted it.
  delivered,
}

/// A story that was watched and whose author has not been told about it yet.
/// Only what is needed to try again: no media, no text, no profile.
class PendingReceipt {
  final String storyId;
  final String author;

  /// When it was watched (unix seconds). Receipts are kept for a day from here.
  final int viewedAt;
  final int attempts;

  /// Not before this time (unix seconds).
  final int nextAttempt;

  const PendingReceipt({
    required this.storyId,
    required this.author,
    required this.viewedAt,
    this.attempts = 0,
    this.nextAttempt = 0,
  });

  PendingReceipt failedAt({required int next}) => PendingReceipt(
    storyId: storyId,
    author: author,
    viewedAt: viewedAt,
    attempts: attempts + 1,
    nextAttempt: next,
  );

  Map<String, dynamic> toJson() => {
    'id': storyId,
    'a': author,
    't': viewedAt,
    'n': attempts,
    'x': nextAttempt,
  };

  static PendingReceipt? fromJson(Object? json) {
    if (json is! Map) return null;
    final id = json['id'];
    final author = json['a'];
    final at = json['t'];
    if (id is! String || author is! String || at is! num) return null;
    if (!_isHexId(id) || !_isHexId(author)) return null;
    return PendingReceipt(
      storyId: id,
      author: author,
      viewedAt: at.toInt(),
      attempts: (json['n'] as num?)?.toInt() ?? 0,
      nextAttempt: (json['x'] as num?)?.toInt() ?? 0,
    );
  }

  static bool _isHexId(String s) => RegExp(r'^[0-9a-f]{64}$').hasMatch(s);
}

/// Collects the stories this account watched and tells each author, in
/// batches, when the viewer moves on (one message per author however many
/// stories they had: each message costs a signer round trip).
///
/// One reporter belongs to one account and never works for another: it is
/// rebuilt when the signed-in account changes, and refuses to send while the
/// account it was made for is not the one signed in.
///
/// * **Consent** is checked when a story is noted, again before every send,
///   and after every signer round trip. Withdrawing it empties the queue and
///   the outbox on disk.
/// * **Delivery** is marked only when the author's inbox accepted the wrap.
///   Anything else keeps the receipt, with a bounded exponential back-off.
/// * **Signers**: a local key retries by itself; Amber and bunker are never
///   woken up in the background — they are asked again only when the viewer
///   flushes, and then not more often than the back-off allows.
/// * **Durability**: waiting receipts are written to an account-scoped file
///   and picked up again after a restart.
class StoryViewReporter {
  /// Receipts older than this are dropped: the story is gone by then.
  static const retention = 24 * 3600;

  /// What can wait on the phone; the oldest go first when it is full.
  static const maxPending = 400;
  static const _maxRemembered = 800;
  static const _sentKeyPrefix = 'mialuna_story_views_sent_';

  /// Back-off after a relay-side failure (no inbox, nobody accepted it).
  static const relayBackoff = (base: 30, cap: 3600);

  /// Back-off after a signer-side failure (refused, timed out): a person is
  /// being asked, so not often.
  static const signerBackoff = (base: 300, cap: 6 * 3600);

  /// A send that takes longer than this is given up (and not published
  /// afterwards).
  static const sendTimeout = Duration(minutes: 2);

  /// The account whose receipts these are; null for a guest, who has none.
  final String? owner;

  final ProviderContainer _container;
  final LocalCache _cache;
  final Future<SharedPreferences> Function() _prefs;
  final PrivateDelivery _delivery;
  final StoryViewReceipts _consent;
  final int Function() _now;

  final Map<String, PendingReceipt> _queue = {};
  final Set<String> _inFlight = {};
  final Set<String?> _wanted = {};
  Set<String> _sent = {};
  Completer<void>? _draining;
  Timer? _retryTimer;
  late final Future<void> _ready;

  bool _closed = false;

  /// Bumped when consent is withdrawn: work begun before is void.
  int _epoch = 0;

  StoryViewReporter({
    required this.owner,
    required this._container,
    required this._cache,
    required this._prefs,
    required this._delivery,
    required this._consent,
    required this._now,
  }) {
    _ready = owner == null ? Future.value() : _restore();
  }

  String get _sentKey => '$_sentKeyPrefix$owner';
  String get _file => LocalCache.storyReceiptsFile(owner!);

  /// Still the account that is signed in.
  bool get _active {
    if (_closed || owner == null) return false;
    try {
      return _container.read(authProvider).publicKey == owner;
    } catch (_) {
      return false; // the app is shutting down
    }
  }

  /// A local key signs without asking anybody; Amber and bunker ask a person.
  bool get _signsQuietly {
    try {
      return _container.read(authProvider).signer.type == SignerType.nsec;
    } catch (_) {
      return false;
    }
  }

  // ── noting ──────────────────────────────────────────────────────────

  /// How many receipts wait to be delivered.
  int get pendingCount => _queue.length;

  /// Where the receipt for [storyId] stands; null when there is none.
  ReceiptState? stateOf(String storyId) {
    if (_inFlight.contains(storyId)) return ReceiptState.sending;
    final waiting = _queue[storyId];
    if (waiting != null) {
      return waiting.attempts > 0 ? ReceiptState.failed : ReceiptState.pending;
    }
    return _sent.contains(storyId) ? ReceiptState.delivered : null;
  }

  /// Notes that [story] was watched.
  Future<void> viewed(MediaPost story) async {
    final me = owner;
    if (me == null || story.author == me || !_active) return;
    if (!_container.read(authProvider).signer.canEncrypt) return;
    await _ready;
    if (!await _consented() || !_active) return;
    if (_sent.contains(story.id) || _queue.containsKey(story.id)) return;
    _queue[story.id] = PendingReceipt(
      storyId: story.id,
      author: story.author,
      viewedAt: _now(),
    );
    _trim();
    await _saveOutbox();
  }

  // ── sending ─────────────────────────────────────────────────────────

  /// Sends what is waiting: for [author] only, or for everybody. A request
  /// that arrives while a send is going on is not lost: it is served right
  /// after, and the returned future completes when it has been.
  Future<void> flush({String? author}) {
    if (!_active) return Future.value();
    _wanted.add(author);
    final running = _draining;
    if (running != null) return running.future;
    final done = _draining = Completer<void>();
    unawaited(_drain(done));
    return done.future;
  }

  Future<void> _drain(Completer<void> done) async {
    try {
      await _ready;
      while (_wanted.isNotEmpty && _active) {
        final authors = {..._wanted};
        _wanted.clear();
        await _sendDue(authors.contains(null) ? null : authors.cast<String>());
      }
    } catch (_) {
      // Whatever went wrong is already recorded against the receipts.
    } finally {
      _draining = null;
      _wanted.clear();
      _scheduleRetry();
      done.complete();
    }
  }

  Future<void> _sendDue(Set<String>? authors) async {
    _expire();
    final now = _now();
    final byAuthor = <String, List<PendingReceipt>>{};
    for (final r in _queue.values) {
      if (r.nextAttempt > now) continue;
      if (authors != null && !authors.contains(r.author)) continue;
      byAuthor.putIfAbsent(r.author, () => []).add(r);
    }
    final rounds = byAuthor.entries.toList();
    for (var i = 0; i < rounds.length; i++) {
      final outcome = await _sendAuthor(rounds[i].key, rounds[i].value);
      if (outcome == _Outcome.cancelled) return;
      if (outcome != _Outcome.signer) continue;
      // Nobody is asked twice in one round: the others wait their turn.
      _fail([for (final r in rounds.skip(i + 1)) ...r.value], signer: true);
      await _saveOutbox();
      return;
    }
  }

  static const _batchSize = StoryViewsController.maxStoriesPerReceipt;

  /// Everything due for [author], [_batchSize] stories to a message. A batch
  /// that fails takes the rest of this author's receipts with it: they would
  /// meet the same closed door.
  Future<_Outcome> _sendAuthor(String author, List<PendingReceipt> due) async {
    due.sort((a, b) => a.viewedAt - b.viewedAt);
    for (var i = 0; i < due.length; i += _batchSize) {
      final batch = due.sublist(i, math.min(i + _batchSize, due.length));
      final outcome = await _sendBatch(author, batch);
      if (outcome == _Outcome.delivered) continue;
      if (outcome != _Outcome.cancelled) {
        _fail(
          due.sublist(i + batch.length),
          signer: outcome == _Outcome.signer,
        );
        await _saveOutbox();
      }
      return outcome;
    }
    return _Outcome.delivered;
  }

  Future<_Outcome> _sendBatch(String author, List<PendingReceipt> batch) async {
    final me = owner!;
    final epoch = _epoch;
    var attemptOpen = true;
    bool wanted() => attemptOpen && epoch == _epoch && _active;
    if (!await _consented()) {
      withdraw(); // the queue should already be empty; make sure
      return _Outcome.cancelled;
    }
    if (!wanted()) return _Outcome.cancelled;

    final ids = [for (final r in batch) r.storyId];
    _inFlight.addAll(ids);
    DeliveryReport? report;
    Object? error;
    try {
      final rumor = Rumor.create(
        pubkey: me,
        kind: NostrKinds.storyView,
        tags: [
          for (final id in ids) ['e', id],
          ['p', author],
        ],
        content: '',
      );
      // To the author only: no copy for yourself, nothing to keep.
      report = await _delivery
          .send(rumor, [author], copyToSelf: false, shouldContinue: wanted)
          .timeout(sendTimeout);
    } catch (e) {
      error = e;
    } finally {
      _inFlight.removeAll(ids);
      // Whatever a late signer answer would do next, it does not publish.
      attemptOpen = false;
    }

    // Consent was withdrawn, or the account changed, meanwhile: the queue
    // was emptied for that, so there is nothing to put back.
    if (epoch != _epoch || !_active) return _Outcome.cancelled;

    if (report != null && report.delivered.contains(author)) {
      await _confirm(ids);
      return _Outcome.delivered;
    }
    final bySigner = error != null;
    _fail(batch, signer: bySigner);
    await _saveOutbox();
    return bySigner ? _Outcome.signer : _Outcome.relay;
  }

  Future<void> _confirm(List<String> ids) async {
    for (final id in ids) {
      _queue.remove(id);
    }
    _sent.addAll(ids);
    if (_sent.length > _maxRemembered) {
      _sent = _sent.toList().sublist(_sent.length - _maxRemembered).toSet();
    }
    // The memory of what was sent first: if the outbox write is lost, the
    // worst case is one more copy of a receipt the author already has.
    try {
      final prefs = await _prefs();
      if (_active) await prefs.setStringList(_sentKey, _sent.toList());
    } catch (_) {}
    await _saveOutbox();
  }

  void _fail(List<PendingReceipt> batch, {required bool signer}) {
    final now = _now();
    for (final r in batch) {
      final current = _queue[r.storyId];
      if (current == null) continue;
      final next = now + backoffSeconds(current.attempts + 1, signer: signer);
      _queue[r.storyId] = current.failedAt(next: next);
    }
  }

  /// Seconds to wait after the [attempts]th failure: doubling, capped.
  static int backoffSeconds(int attempts, {required bool signer}) {
    final (:base, :cap) = signer ? signerBackoff : relayBackoff;
    final seconds = base * (1 << math.min(math.max(attempts - 1, 0), 20));
    return math.min(seconds, cap);
  }

  /// A local key tries again by itself, once the back-off is over.
  void _scheduleRetry() {
    _retryTimer?.cancel();
    _retryTimer = null;
    if (!_active || _queue.isEmpty || !_signsQuietly) return;
    final next = _queue.values.map((r) => r.nextAttempt).reduce(math.min);
    final wait = math.max(next - _now(), 1);
    _retryTimer = Timer(Duration(seconds: wait), () {
      _retryTimer = null;
      unawaited(flush());
    });
  }

  // ── consent ─────────────────────────────────────────────────────────

  Future<bool> _consented() async {
    await _consent.loaded;
    return !_closed && _consent.enabled;
  }

  /// The user no longer wants receipts sent: whatever has not left goes,
  /// from memory and from disk. A send already past the point of handing its
  /// gift wrap to a relay cannot be taken back.
  Future<void> withdraw() async {
    _epoch++;
    _wanted.clear();
    _retryTimer?.cancel();
    _retryTimer = null;
    _queue.clear();
    // The file is gone before this returns. A caller that checks the disk
    // immediately, and a restart, must not still find the receipt.
    if (owner != null && !_closed) await _cache.deleteFile(_file);
  }

  /// Sign-out: forgets everything and writes nothing more (the files of the
  /// account are removed by the caller).
  void discard() {
    _closed = true;
    _epoch++;
    _wanted.clear();
    _retryTimer?.cancel();
    _queue.clear();
    _inFlight.clear();
    _sent = {};
  }

  /// The provider is going away (another account, or shutdown).
  void close() {
    _closed = true;
    _retryTimer?.cancel();
    _retryTimer = null;
  }

  // ── keeping ─────────────────────────────────────────────────────────

  void _expire() {
    final cutoff = _now() - retention;
    _queue.removeWhere((_, r) => r.viewedAt < cutoff);
  }

  void _trim() {
    while (_queue.length > maxPending) {
      final oldest = _queue.values.reduce(
        (a, b) => a.viewedAt <= b.viewedAt ? a : b,
      );
      _queue.remove(oldest.storyId);
    }
  }

  Future<void> _saveOutbox() async {
    if (!_active) return; // after a sign-out or a switch nothing is written
    if (_queue.isEmpty) {
      await _cache.deleteFile(_file);
      return;
    }
    await _cache.writeJson(_file, {
      'v': 1,
      'owner': owner,
      'items': [for (final r in _queue.values) r.toJson()],
    });
  }

  Future<void> _restore() async {
    final epoch = _epoch;
    List<String>? sent;
    Object? saved;
    try {
      sent = (await _prefs()).getStringList(_sentKey);
      saved = await _cache.readJson(_file);
    } catch (_) {
      // Nothing readable: start empty (a copy may be sent twice, which the
      // author's list does not count twice).
    }
    await _consent.loaded;
    if (_closed || epoch != _epoch) return;
    _sent = {...?sent};
    if (!_consent.enabled) {
      // They said no: what was left over from an earlier session goes.
      if (saved != null) unawaited(_cache.deleteFile(_file));
      return;
    }
    if (saved is Map && saved['owner'] == owner && saved['items'] is List) {
      final cutoff = _now() - retention;
      for (final raw in saved['items'] as List) {
        final r = PendingReceipt.fromJson(raw);
        if (r == null || r.viewedAt < cutoff || _sent.contains(r.storyId)) {
          continue;
        }
        _queue.putIfAbsent(r.storyId, () => r);
      }
      _trim();
    }
    // Picked up after a restart: a local key just sends them.
    if (_queue.isNotEmpty && _signsQuietly) unawaited(flush());
  }
}

enum _Outcome { delivered, relay, signer, cancelled }

/// One reporter per signed-in account.
final storyViewReporterProvider = Provider<StoryViewReporter>((ref) {
  // Another account (or none) means a new reporter; the old one stops.
  final owner = ref.watch(authProvider.select((a) => a.publicKey));
  final reporter = StoryViewReporter(
    owner: owner,
    container: ref.container,
    cache: ref.read(localCacheProvider),
    prefs: ref.read(sharedPreferencesLoader),
    delivery: ref.read(privateDeliveryProvider),
    consent: ref.read(storyViewReceiptsProvider.notifier),
    now: ref.read(unixClockProvider),
  );
  ref.onDispose(reporter.close);
  return reporter;
});
