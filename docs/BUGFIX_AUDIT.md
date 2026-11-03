# Bugfix audit: story receipts, stories, account isolation

Branch `fix/story-receipts-reliability`, from `main` at `847b0d9` (v0.16.0).
Everything below was checked against the code at that commit, not taken from
the preliminary review. Where the review was right, a test that fails on the old
code is named; where it could not be reproduced or only partly, it says so.

## A. Baseline

| | |
|---|---|
| Initial HEAD | `847b0d90ee459b06ba2b07a0e2f6a4c4d18c6ee4` (`origin/main`, fetched 2026-11-03) |
| Toolchain used | Flutter **3.44.3** / Dart **3.12.2**. The repo pins **3.47.9** / `^3.13.7` (`mise.toml`, `pubspec.yaml`), so `flutter pub get` fails in the repo itself. All commands ran in a mirror of the repo whose `pubspec.yaml` allows `^3.12.2` (otherwise identical, same lock file). |
| Tests at baseline | **681 passed, 0 failed.** |
| Analyzer at baseline | No issues. |
| Build at baseline | `flutter build apk --debug` at `847b0d9`: **succeeded** (Linux, JDK 21; `flutter doctor` nevertheless reports missing cmdline-tools and unknown licences). |

## B. Findings

Severity follows the brief (P0 privacy / data loss, P1 reliability or integrity,
P2 minor). "Red on old code" means the regression test was run against the
unfixed code and failed.

### Confirmed bugs from the preliminary review

| ID | Sev. | Where | Root cause | Fix | Regression tests | Status |
|---|---|---|---|---|---|---|
| R1 | P0 | `StoryViewReporter._send` | `_remember(batch)` ran after the `try`, whatever happened; the `DeliveryReport` was never read, so a refused signer, a relay that said no, no inbox or a timeout all marked the receipt as sent. | `story_receipts.dart`: delivered only when `report.delivered.contains(author)`; otherwise it stays in an account-scoped outbox with a bounded exponential back-off (30 s → 1 h; 5 min → 6 h after a signer failure), 24 h retention. | `story_receipts_test` › *delivery* (all relays refuse, no inbox then inbox, relay silent, one of two relays, signer refuses, seal refused, delivered twice counted once). Red on old code: five throw-away reproductions (R1, R2, R4, R5) failed 5/5 before any change. | Fixed |
| R2 | P0 | `viewed()` / `flush()` / `_send()` | Consent was read once, in `viewed()`. | Checked when noting, before every send and after every signer round trip; `set(false)` empties queue and disk at once; an unreadable setting counts as "no". `PrivateDelivery.send(shouldContinue:)` stops a wrap between signing and publishing. | *consent* group: off before watching, after watching, while the signer works, while a relay answers, after restart, stale outbox on disk, unreadable setting. Red on old code. | Fixed. Boundary: a wrap a relay already accepted cannot be recalled (documented, tested). |
| R3 | P0/P1 | `storyViewReporterProvider` | A plain `Provider` reading the active account dynamically; queue and sent-set were not tied to the account that produced them. | One reporter per pubkey (watches `authProvider`), its queue/outbox/sent-set namespaced by pubkey, `_active` check before every step; `PrivateDelivery.send` refuses a rumor whose author is not the signed-in account; `discard()` on sign-out writes nothing afterwards. | *whose receipt it is*: switch with pending work, late signature after a switch, write-back after sign-out, foreign rumor. | Fixed. Likelihood in practice was low: the UI only reaches another account through sign-out / guest. |
| R4 | P1 | `_send` | `ids.take(30)` and the rest was dropped. | Per-author batches of ≤ 30, one wrap each; a failed batch keeps its stories, delivered ones are not resent. | *batches*: 1, 29, 30, 31, 60, 75 stories, no duplicates, wrap bodies ≤ 30 ids; failed middle batch. Red on old code (30 of 75 arrived). | Fixed |
| R5 | P1 | `flush()` | `if (_flushing) return;` dropped a request made during a send, and the batch was removed from `_pending` before sending. | Single drain loop: a request during a send is served right after, one signer request at a time; nothing is removed until delivered. | *one send at a time* (work during a flush, two authors at once with `maxConcurrent == 1`, failing relay tried once, no spin). Red on old code. | Fixed |
| R6 | P1 | `_pending` in memory | Lost with the app. | Outbox file `story_receipts_<pubkey>.json` (story id, author key, times, attempts only), reloaded at start-up. A local key resends on its own; **Amber / bunker are never prompted from a restart or a timer**, only by an explicit flush. Removed on sign-out. | *across restarts* (resent after restart, Amber not woken, expired dropped, bounded). | Fixed |
| R7 | P1 | `StoryViewerScreen._startStory` | Marked seen and queued the receipt at selection, before any media was shown. | `StoryPlayback` (pure, no clock): the media must be showing for 1 s, not held, not in the background, a video playing and not buffering. Image widgets report a final failure; a story that cannot be shown is skipped uncounted. A video's bar follows its playback position. | `story_playback_test` (16), `story_viewer_test` (9, widget). Viewer tests red on old code (6 of 9; the other 3 are invariants). | Fixed. **Video path verified only at the `StoryPlayback` level, not on a device.** |
| R8 | P1 | `SeenStories` | One global key `mialuna_seen_stories`. | Per-account key (`…_<pubkey>`, `…_guest`); the old key is adopted by the first account that signs in and removed; late loads cannot overwrite newer state; marking before the load keeps both. | `stories_state_test` › *what has been watched…* (6). Red on old code. | Fixed |
| R9 | P1 | `StoriesController` | Follow listener compared lengths; `_running` absorbed a refresh arriving during a load; no reaction to an account change, so Alice's rail stayed in Bob's. | Compares the sets; refresh is queued (newest wins); rebuilds on account change with generation-guarded loads; reloads when relays change. | `stories_state_test` › swap, queued refresh, account carry-over. Red on old code. | Fixed |
| R10 | P1 | `MediaPost.isExpired` for stories | `false` without a valid `expiration`, so a story with none (or a faraway one) stayed forever. | Stories also end 24 h after `created_at`; a valid earlier NIP-40 value still wins; > 10 min in the future is not shown; other posts keep plain NIP-40. The rail drops stories every minute and on returning to the foreground. | `stories_state_test` › *a story lives for a day* (7) and *the rail while the app stays open* (public and close-friends). Existing fixtures that asserted the old behaviour were updated. | Fixed |
| R11 | P1 | `StoryViewsController.ingest` | Any 64-char string was a story id; no check that the story was yours; state pruned only on save. | Only your own live stories count (`ownStoriesProvider`); unknown ids wait in a bounded buffer (600 / 60 per sender / 1 h) and are counted when the story appears; ids must be 64 lowercase hex; time clamped; a viewer counted once; ≤ 2000 viewers per story; held receipts persisted; legacy file read back as unverified; incremental publish, coalesced save. | `story_receipt_ingest_test` › *which receipts count*, *under attack* (1500 senders × 30 ids stay bounded), *kept on the phone*. The existing test that accepted `'a' * 64` was rewritten to use an owned story. | Fixed. A receipt remains self-reported. |
| R12 | P1/P2 | `DmController._process` | `_scheduleSave()` only ran for chat messages; receipts and private content were added to `_seenWraps` and never saved (the first sync's save masked it for the first 2 s). | Every processed wrap schedules a coalesced save (a pending timer is joined, so a stream cannot postpone it forever); `_seenWraps` bounded in memory. | `story_receipt_ingest_test` › *the inbox remembers…* (receipts only, private only, mixed). Red on old code for the first two. | Fixed |
| R13 | P1/P2 | `ComposerController.startStory` | Kept `caption` and `sensitive` despite its comment. | Starts from nothing; only the audience (a standing preference) stays. | `composer_story_test` (8). Red on old code (5). | Fixed |

### Found while auditing the code around them

| ID | Sev. | Where | Finding | Fix / test | Status |
|---|---|---|---|---|---|
| N1 | P1 | `ComposerController.setCaption`, `_restoreDraft`, `publish` | A story's caption was saved under the post draft key (replacing the post draft, restored into the next *public* post); publishing a story deleted that draft; the async draft restore could fill a story already started. | Stories never touch the post draft; restore only fills an empty post composer. `composer_story_test` › *drafts*. Red on old code. | Fixed |
| N2 | P1 | `DmController._process` | The `SignerException` handler had no generation check: after an account switch a refusal for the old account set the error on the new inbox and closed its subscription. | Generation check. `account_isolation_test`. Red on old code. | Fixed |
| N3 | P1 | `FollowListController._load` | The end of a load completed the completers of whichever account was current, so the next account's follow list counted as "loaded" before it was (the signal that stops a follow from publishing a list built on nothing). | Each load holds its own completers. `account_isolation_test`. Red on old code. | Fixed |
| N4 | P2 | `DmController.inboxRelaysOf` | An empty result was cached for the session, so a retry could never see an inbox published later. | Only non-empty results are cached. Covered by *an author with no inbox is retried when they get one*. | Fixed |
| N5 | P2 | `DmController._seenWraps` | Unbounded in memory. | Capped at twice the saved size. | Fixed (no dedicated test) |

### Potential risks, not fixed (see F)

| ID | Sev. | Where | Note |
|---|---|---|---|
| P1 | low | `RelayPool._flushQueue` | When `_verified` is cleared (> 8000 ids), an event already verified by another subscription and queued in the same batch is neither re-verified nor delivered. One lost event for one subscription, once per ~8000 events. |
| P2 | low | moderation / audience preferences | Blocks, mutes, bookmarks and the audience are global `SharedPreferences` keys wiped at sign-out. Safe through the UI (every switch passes through sign-out or guest); not safe against a programmatic account A → B. |
| P3 | low-med | `DmController._addRumor` | Receipts from strangers are not passed through the web of trust (they are counted, but only for your own live stories). |
| P4 | low | `StoryViewsController` | A Sybil flood of many senders can evict legitimate *held* receipts (global cap 600). Receipts for stories published on this phone, or already loaded, never go through the buffer. |
| P5 | info | rumor `created_at` | A retried receipt carries the time it was *sent*, so the author's viewer list can show up to 24 h after the actual view. The event format was deliberately not changed. |

### Product tradeoffs (not changed)

* **Opt-out default.** Left as is, as asked. Recommendation: keep it on (it is
  what story viewers expect, the message is end-to-end encrypted and relays
  learn nothing) **but** explain it once, the first time someone watches a
  story, and consider defaulting to *off* or *ask once* for Amber and bunker
  users, where every sent receipt costs two approval prompts.
* A receipt delivered to a relay cannot be retracted; the UI text now says so.
* Receipts say "the viewer's app reported a view", never that a human watched.

## C. Architecture notes

* **`story_receipts.dart`** (new) holds consent (`StoryViewReceipts`) and the
  sender (`StoryViewReporter`); `story_views.dart` keeps only the receiving side.
* **State machine.** `pending → sending → delivered`, or `→ failed` (kept,
  with `attempts` and `nextAttempt`), or removed (cancelled / expired / account
  gone). `stateOf(storyId)` exposes it. Delivered means *an inbox relay of the
  author accepted the wrap*.
* **Serialisation.** `flush()` joins a drain loop; the loop re-reads the
  requests made while it ran. A signer-side failure ends the round for every
  author (nobody is asked twice); a relay-side failure only for that author.
  A send that outlives two minutes is abandoned and cannot publish afterwards.
* **Identity.** The reporter is built from `authProvider.select(publicKey)`,
  keeps only closures over the container (never `ref` after disposal), and
  checks `_active` (signed-in key == owner) before each step.
* **Time.** `unixClockProvider` (new) is read by the reporter, the stories
  controller and the views controller; tests move it instead of sleeping.
* **Account files.** `LocalCache.accountFiles` gained the outbox; sign-out
  also removes the per-account seen list.
* **Stories.** `StoriesController` rebuilds on account change and uses a
  generation counter instead of a `_disposed` flag. `ownStoriesProvider`
  (derived from the rail) is what receipts are checked against.

## D. Security and privacy

* No receipt is created or kept without consent, none is sent after consent is
  withdrawn, and nothing waiting survives the withdrawal, a restart or a
  sign-out. The only residue is a wrap a relay had already accepted, which no
  client can recall.
* The outbox stores a story id and the author's public key for ≤ 24 h: no
  media, caption, name or message text. It is deleted with the account.
* A receipt cannot be signed by, queued for or written under another account:
  the reporter is per-pubkey, checks identity before each step, and
  `PrivateDelivery` refuses a rumor not authored by the signed-in key.
* Nothing the sender or receiver does depends on trusting a viewer: a receipt
  names stories only the author can validate; unverified ones are bounded in
  number, per sender and in time.
* NIP-44/NIP-59 are untouched: same seal / wrap / ephemeral key, same author
  checks in `GiftWrap.unwrap`, no plaintext fallback; relays still see only a
  throw-away key to the author (asserted: no story id appears in any stored
  event, and no wrap is signed by the viewer or the author).
* No keys or ciphertext are logged: the code base has no logging calls.
* Seen-state and drafts no longer cross accounts or audiences.

## E. Validation

| | Result |
|---|---|
| `flutter test` | **789 passed, 0 failed**, run twice at the final commit (baseline 681). |
| `flutter analyze` | No issues. |
| `dart format` | Changed Dart files are stable under the 3.12 formatter (the repo is formatted with 3.13; the whole tree was deliberately *not* reformatted). Re-run `dart format lib test` with 3.47 before merging. |
| `flutter build apk --debug` | **Succeeded** at the final tree (and at the baseline), in the mirror, Flutter 3.44.3, JDK 21. |
| iOS / release build | Not run (Linux host; no signing). |
| New / extended test files | `story_receipts_test`, `story_receipt_ingest_test`, `stories_state_test`, `story_playback_test`, `story_viewer_test`, `composer_story_test`, `account_isolation_test`, plus harness (`story_harness.dart`) and `FakeRelay` knobs (`rejectWith`, `ignorePublishes`, `acceptLimit`, `publishDelay`, `reqDelay`). Three existing tests changed because they asserted the old behaviour (fabricated story id; story without expiration; 2023 timestamps). |
| Dependabot branches | Open PRs touch only `pubspec.*`, `android/*.kts|properties` or `ci.yml`: **no file overlap** with this branch. Not merged. `flutter_riverpod 3.4.x` is a major bump: `Ref.container`, which the reporter uses, still exists in 3.4.2. |

Remaining platform limits: tests ran on Flutter 3.44.3, not the pinned 3.47.9;
relays are a local fake, signers are real keys behind a scriptable wrapper
(real Amber and bunker were not exercised); no device or emulator was used.

## F. Remaining issues and what needs a real device

| Item | Severity | Recommended next step |
|---|---|---|
| Video viewing on the real player (`isPlaying`, `isBuffering`, `isCompleted`, `hasError` semantics differ per platform) | medium | Check on Android/iOS that a video counts after ~1 s of playback, not while buffering, and ends at its end. |
| Amber (NIP-55) and bunker (NIP-46) | medium | Confirm: no prompt at start-up with pending receipts; one prompt pair when leaving the stories; a dismissed prompt is not repeated within 5 min. |
| Process death / suspend | medium | Kill the app with a receipt pending and confirm it is resent; confirm turning the setting off, then killing the app, leaves no outbox file. |
| Lifecycle in the viewer | low | Home button, notification shade and incoming call must pause the story and its count. |
| `RelayPool` `_verified.clear()` (P1) | low | Deliver `alreadyVerified ∪ verified` from `_flushQueue`. |
| Global moderation / audience keys (P2) | low | Scope them by pubkey if a real account switcher is ever added. |
| Web of trust for receipts (P3) | low | Decide whether strangers' receipts should be hidden when the filter is on. |
| First-use explanation of receipts; default for external signers | product | See *Product tradeoffs*. |
| Merge Dependabot (riverpod 3, go_router 18, permission_handler 13, Android tooling) | — | Separately, each on the pinned 3.47 toolchain. |
