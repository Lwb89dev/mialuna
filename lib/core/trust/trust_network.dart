import '../nostr/event.dart';

/// How many of your own follows must also follow an account before it counts
/// as part of your web of trust. The same value Outkast uses: low enough that
/// a real, socially-integrated account clears it easily, high enough that a
/// spam account — which by construction has next to no genuine mutual ties —
/// essentially never does without deliberately farming them.
const wotThreshold = 10;

/// Follow lists are asked for in chunks this big: a kind 3 carries somebody's
/// whole contact list (up to hundreds of KB), so a chunk of many authors in
/// one answer is real memory pressure.
const wotChunkSize = 50;

/// The accounts a kind 3 event follows: its `p` tags that are valid keys.
Set<String> followedBy(NostrEvent followList) => {
  for (final t in followList.tags)
    if (t.length >= 2 && t[0] == 'p' && _isHexKey(t[1])) t[1].toLowerCase(),
};

bool _isHexKey(String s) => RegExp(r'^[0-9a-fA-F]{64}$').hasMatch(s);

/// Counts, for every account, in how many of the follow lists given to [add]
/// it appears. One list counts an account once, however many times it
/// repeats it.
class FollowCounter {
  final Map<String, int> _counts = {};

  void add(Iterable<String> follows) {
    for (final pubkey in follows.toSet()) {
      _counts[pubkey] = (_counts[pubkey] ?? 0) + 1;
    }
  }

  /// The accounts that appear in at least [threshold] of the lists.
  Set<String> reaching([int threshold = wotThreshold]) => {
    for (final e in _counts.entries)
      if (e.value >= threshold) e.key,
  };
}

/// Who passes the filter right now. Mialuna's web of trust is a *local*
/// reading of public follow lists: you, the people you follow, and the people
/// followed by enough of them. When the filter is not [active] everybody
/// passes.
class TrustFilter {
  final bool active;
  final Set<String> _trusted;

  const TrustFilter(this.active, this._trusted);

  /// Nothing is filtered.
  static const open = TrustFilter(false, {});

  bool allows(String pubkey) => !active || _trusted.contains(pubkey);
}
