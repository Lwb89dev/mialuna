# Changelog

All notable changes to Mialuna are documented here.
Format based on [Keep a Changelog](https://keepachangelog.com/).

## [Unreleased]

### Added
- **Delete your own posts, reels and stories** (menu of a post, trash button in
  a reel and in your story). Mialuna asks your relays to delete the post
  (NIP-09) and the media servers to delete its photos or video (Blossom
  `DELETE`), then never shows it again on the phone, even if a relay keeps
  serving it. It says what could not be done: a server that refused or did not
  answer is named. A file that another post of yours, or your profile picture,
  still uses is left on the server. Close-friends posts cannot be recalled from
  relays, so your friends' apps are told to remove them and the encrypted files
  are deleted from the server (this needs the one-off upload key, which is kept
  on the phone from now on; older close-friends posts keep their files).

### Changed
- The menu of your own post no longer offers to mute, block or report yourself.

### Fixed
- The top bar of a close-friends story you are watching (yours: viewers, delete,
  "Close friends", close) no longer overflows on a narrow phone or with large
  text: the "Close friends" label gives way.

## [0.17.2] — 2026-11-03 — The caption box follows the composer

### Fixed
- **The caption box could show text the composer no longer had.** The box only
  ever copied the composer's caption into itself when the box was empty. After
  a caption changed elsewhere (a story shared from the Home rail, a reset
  after publishing, a draft that was read late), the box kept the old words
  while the composer was empty, so the next keystroke brought the old text
  back into the post. The box now always shows what the composer holds,
  including an empty caption, and never moves the cursor while you type.
  Covered by three new widget tests (the first one failed before the fix).

## [0.17.1] — 2026-11-03 — Reels no longer crash, notifications explained

Found by testing the 0.17.0 build on a phone and from user reports.

### Fixed
- **Reels crashed the app** (reported as "it keeps crashing on reels" on a Galaxy S21 Ultra, reproduced on a Galaxy S24).
  Swiping quickly through reels started a video player — a hardware decoder and
  its buffers — for every reel, and a reel swiped past only let go of its
  player once its download answered, so players piled up until the app died
  with an `OutOfMemoryError` (reproduced: 20 swipes took the app from 670 MB to
  1.2 GB). Now only the reel being watched has a player, the next one is made
  ready once you stay on a reel for a moment, and everything else lets go at
  once. 100 swipes on the same phone: no crash, flat memory.
- Reels no longer reorder under your finger when new reels arrive while you are
  watching; they are added at the end.
- **Notifications on the phone stopped a few minutes after the screen went
  off.** Android puts the app to sleep and its relay connections with it, so
  the bell filled up on the next visit but nothing appeared in the notification
  shade. Mialuna has no push service and runs no service in the background, so
  Settings → System notifications now says so and opens the phone's battery
  settings, where Mialuna must be set to "Unrestricted". With that, a reaction
  arrived in the shade even with Android forced into deep Doze for 8 minutes.
- "5 min ago" under a post froze while it stayed on screen (a side effect of
  0.17.0 no longer rebuilding unchanged cards); it keeps up with the clock again.
- **Photos could come out sideways** when a PNG or WebP carried an EXIF
  rotation: the tag was stripped without the rotation being applied. They are
  now turned the right way up first (JPEG already was). Every orientation 1–8 is
  checked pixel by pixel.
- Adding a media (Blossom) server that is not `https://` emptied the field
  without a word; it now says "Invalid address: use https://…".

## [0.17.0] — 2026-11-03 — Reliable story receipts, a Home that refreshes

Full audit of the story work: [docs/BUGFIX_AUDIT.md](docs/BUGFIX_AUDIT.md).

### Added
- **Settings → "Show new followers"** (on by default). Off, new followers no
  longer appear in Notifications, in the bell's count or on the phone; likes,
  comments and zaps still do. For whoever gets follow spam.

### Fixed
- **Pull-to-refresh brought nothing new after the phone had slept.** The
  connections to the relays had died without either side noticing, and the
  request went into them; the WebSocket ping only found out tens of seconds
  later. Before a refresh, and when the app returns to the foreground, a relay
  that has been quiet is now asked a question with an instant answer and its
  connection is replaced at once if there is none.
- Home now refreshes when you replace one followed account with another (it
  only noticed a change in their number).
- **Smoother scrolling in Home.** A post with a single picture no longer sits
  in a carousel whose horizontal drag competed with every vertical scroll that
  started on it; a card that scrolls away and back keeps the shape learned
  from its picture instead of starting square and jumping; cards that did not
  change are no longer rebuilt each time a page of posts arrives, and the feed
  no longer re-emits when nothing visible changed.
- **A story view was marked as delivered whatever happened.** A refused
  signer request, a relay that said no or an author with no inbox lost the
  receipt for good. A receipt is now delivered only once the author's inbox
  relay accepted it; otherwise it waits in a small outbox on the phone (story
  id and author only, for at most 24 hours) and is retried with a growing
  pause. Amber and bunker are never asked in the background.
- **Turning "let people see that I viewed their stories" off did not stop
  receipts already waiting.** It now discards them at once, from memory and
  from disk, and a restart does not bring them back. (A receipt a relay already
  accepted cannot be taken back.)
- More than 30 stories to one author were silently cut at 30; they are now
  sent in further messages. A second flush during a first no longer gets
  dropped.
- Receipts and queues are bound to the account that watched: switching or
  signing out cannot have them signed, sent or written for someone else.
- **A story counts as watched only once it was really shown**: a picture that
  never loaded, a swipe past it, a long press, the app in the background or a
  video that is buffering no longer count; a story that cannot be shown is
  skipped.
- Watched stories are remembered **per account** (they were shared by every
  account on the phone); the old list goes to the first account that signs in.
- **Stories disappear after 24 hours** even when their NIP-40 tag is missing,
  malformed or far in the future, and while the app stays open.
- The story rail refreshes when you replace one followed account with another
  (it only noticed a change in their number), when your relays change, and
  when a refresh is asked for during a load.
- **Only receipts for your own live stories are counted.** Anybody could name
  any story id; unknown ones wait in a bounded buffer and are forgotten.
- The inbox saved its checkpoint only after chat messages, so a session that
  received only story receipts or close-friends content opened the same wraps
  again at the next start (a signer prompt each with Amber).
- A new story no longer starts with the caption and sensitive-content flag of
  the last one, and a story's caption no longer replaces the draft of the post
  composer.
- An account switch could carry a signer refusal, or a "follow list loaded"
  signal, over to the next account.

### Changed
- The setting's explanation says what happens when a receipt cannot be
  delivered and when the setting is turned off (English and Italian).
- Stories use `MediaPost.isExpired`, which applies the 24-hour rule; fixtures
  of the story tests now use the current time.

## [0.16.0] — 2026-11-02 — Stories like Instagram, notifications, a security pass

### Added
- **Android notifications.** A reaction, comment, zap, new follower or private
  message that arrives while Mialuna is in the background (but still running)
  is now a system notification; the bell and the paper plane keep their red
  counts. Tapping one opens the right screen — the chat, or Notifications — even
  from a cold start. They need the notification permission (asked in the
  onboarding, with the media one, or from Settings → System notifications,
  which is also the on/off switch), come in two channels (social, messages),
  never show a message's text and read just "New private message" on the lock
  screen, are limited to 5 a minute per channel (then one summary), and are
  cleared when the app opens. No push server, no Google messaging: they are
  made on the phone (see PRIVACY.md).
- **The story button is always in Home.** Your picture with a plus opens the new
  story screen — choose a photo or video, write on it, choose who sees it
  (public or close friends), share. Once you have published, a second circle
  with your picture shows your stories. **Rings are divided into as many equal
  parts as the person has stories from the last 24 hours**, new ones in the
  brand gradient (green for close friends) and watched ones grey. A story you
  publish is in the rail at once.
- Sections of the story screen: crop / rotate the photo, caption, text, and
  Back asks before throwing the story away.
- `Settings → System notifications`, `SECURITY.md` (what the app does to keep
  its attack surface small and what it cannot do), `test/android/manifest_test.dart`
  (fails if permissions, backups, cleartext or exported components change
  unintentionally), Dependabot, and a `Mialuna Debug` build that installs next
  to the real app.
- **Web of trust against spam**, after Outkast's: Settings → Web of trust
  (off by default). Your network is the people you follow plus everyone
  followed by at least 10 of them, worked out on the phone from public follow
  lists, cached per account and refreshed after 12 hours. Only once it has been
  computed does it filter: comments on posts, reactions / comments / zaps in
  Notifications (new followers stay), close-friends posts and stories from
  people outside it, and private messages from strangers, which wait in
  **Message requests** instead of the inbox, do not count as unread, and move
  to the inbox when you answer. Discover and Reels are never filtered.
- **Who watched your stories.** From the note, not from Blossom: the viewer
  sends the author one gift-wrapped receipt per author (kind 1417), listing the
  stories watched, readable only by the author. An eye with the count appears
  in the header of your own stories; tapping it lists the viewers. On by
  default, off with Settings → "Let people see that I viewed their stories"
  (see PRIVACY.md).
- The profile shows the person's **npub** right under the name (tap to copy),
  and a person with no name is shown by their npub instead of raw hex.
- **New app icon.** `assets/icons/icon.png` now has transparent corners (it came
  with black ones); the adaptive Android icon sits on a gradient sampled from
  it and the iOS icon is a full-bleed square (`tool/launcher/`); every
  launcher icon was regenerated.

- **Unread indicators in Home.** The bell shows how many notifications
  (reactions, comments, zaps, new followers) arrived since the notifications
  screen was last opened; the paper plane shows unread private messages. Both
  are red numbers (99+ at most), hidden at zero, and the tooltips say the
  count aloud. The notifications now load for the whole session (they used to
  exist only while the screen was open), remember what was seen per account,
  highlight what is new when the screen opens, and show relative times.
- **Texts over stories, written right on the photo.** Tap the picture (or the
  text button) and the words appear on it, over the dimmed photo, as you type;
  fonts, colours, the pill behind the letters and a size slider sit above the
  keyboard, `#hashtags` are underlined as you write them. Drag, pinch to
  resize and rotate, tap to edit again, drop on the bin to delete; five fonts,
  none / solid / veil background, up to 8 texts.
  The texts are kept as `story-text` tags (see `docs/nostr-compatibility.md`),
  not baked into the picture, so **`#hashtags` in a story text — and in a story
  caption — open the search for that tag**, pausing the story. Works for photos
  and videos, public and close-friends stories (the texts stay inside the
  encrypted post).
- Hashtags in posts opened on their own (from Discover, a message, a profile)
  are tappable too; they used to be highlighted but dead.

### Security and privacy
- Android: `allowBackup=false` and empty backup / device-transfer rules (the
  decrypted messages no longer reach a cloud backup), no cleartext and no
  user-installed CAs in release builds (debug may reach `localhost` only), R8
  shrinking, release signing from `android/key.properties`, a policy test of the
  manifest; the messages screens, the friends list and close-friends stories are
  `FLAG_SECURE` (no screenshots, blank recents preview) and the keyboard is asked
  not to learn from messages and comments.
- Servers that somebody else chose (NIP-05 domains, Lightning addresses, LNURL
  callbacks) are only reached on `https`, public hosts — by name and by what the
  name resolves to — with no redirects and answers cut at 128 KB. The invoice
  a Lightning server returns must match the amount you chose before the wallet
  pays; a Lightning address can no longer smuggle a port, path or credentials.
- Relays: plain `ws://` only to your own network, messages above 6 MB are
  dropped; relay URLs from a bunker or wallet link are filtered the same way.
- A zap receipt only names a sender whose signed zap request it carries, and
  takes the amount from the paid invoice: nobody can put another name or a
  bigger sum on a zap.
- Signing out removes everything the account left behind: wallet link,
  decrypted messages and close-friends posts, the friends list, the web of
  trust, caches, drafts and the account's preferences (they used to survive and
  would have been published with the next account's lists).
- Very long texts of other people's posts, comments, messages and story
  captions are cut at 5000 characters before they are laid out.
- CI: read-only token, actions pinned to a commit, no persisted credentials.

### Changed
- Stories and the story editor open over the whole screen (the bottom bar used
  to stay visible under them).
- Settings → Clear cache says what it clears: the feed caches (messages go when
  you sign out) — PRIVACY.md was wrong about it.
- **Home answers faster.** It no longer starts as a guest (and loads Discover)
  while the saved session is being read; the last session's posts are painted
  before anything is asked of the network (they used to wait for the follow
  list, up to 10 s); the follow list is remembered on the device; the
  pull-to-refresh spinner stops after 4 s even if a relay is slow while the
  load continues; pictures start loading 1500 px ahead, are no longer
  re-encoded to PNG on disk, and a bookmark no longer rebuilds every card.
- Picking a picture for a **story** now uses the system picker's
  single-choice mode instead of multi-select with a limit.

### Fixed
- A person with no name showed their npub twice in the profile.
- The "Seen by" setting and the notification switch could be undone by their
  own late loading (a race at start-up).
- Orphan strings and a stale launcher colour were removed.
- A friend added to the close-friends list right at start-up was undone by the
  list saved on disk loading a moment later.
- The list of stories already reported to their authors is per account, not
  per device.
- Hashtags with accents or non-Latin letters were cut at the first one
  (`#città` became `#citt`) in captions, tags and search.
- Home could show nothing — or stop paging — when a followed account had a
  page of stories in the relays' answer: paging now follows the oldest event
  received, not the oldest post shown, and keeps looking a few pages back.
- Saving a post or muting someone replaced the whole NIP-51 list with only what
  Mialuna knows, erasing other clients' entries (muted words and threads,
  addressable bookmarks, private entries). They are kept now, and nothing is
  republished before the relay copy was read.
- The unread badge of the paper plane flashed a big number during the very
  first sync of a device.
- The photo editor crashed on pictures the `image` package cannot read (HEIC);
  it now says so.
- Concurrent cache writes (a draft is saved at every keystroke) could leave a
  truncated JSON file; operations on a file are now serialised, and a draft
  deleted after publishing cannot come back.
- A late story or reel load could touch a disposed provider.
- Smaller: thumbnails in the composer lost their identity when reordered; the
  private-post store redrew every private card each minute; a provider
  keep-alive leaked on every account/block change; swiping between creators in
  the story viewer started from the first story instead of the first unseen
  one, and "back" on the very first story did nothing.

### Tests
- `FakeRelay` now answers like a real relay (newest first, `limit` honoured).
- New: hashtags, story texts (model, parsing of hostile input, rendering,
  editor gestures, end-to-end public and close-friends publishing), the
  notifications flow, DM unread counting, NIP-51 preservation, paging through
  stories, the Home badges; the layout matrix includes the Home bar.

## [0.15.0] — 2026-11-01 — Close friends, theme, support

### Added
- **English and Italian, ready for more languages.** All text now lives in
  `lib/l10n/app_en.arb` (template) and `app_it.arb`; the app follows the
  phone's language and Settings → Appearance → Language overrides it. Errors
  raised in background isolates carry a code and are translated on the main
  isolate. A test checks that every language has the same keys and
  placeholders and that no Italian is left in the code; the layout test now
  renders every screen in both languages. How to add one: `docs/TRANSLATING.md`.
- The Home bar shows the logo next to the lowercase "mialuna".
- **Amici più stretti (close friends).** A list (NIP-51 private set,
  `kind 30000`, `d=close-friends`, members encrypted to yourself, kept on the
  device too, up to 60 people) and an audience switch in the composer
  (Pubblico / Amici più stretti, remembered): photos, videos, reels and
  stories published for that audience are an unsigned event whose `p` tags
  are the friends — the list is *injected in the post* instead of picked each
  time — gift-wrapped (NIP-59) once per friend and for yourself, and delivered
  only to each friend's inbox relays (like Outkast's private replies). Stories
  carry a NIP-40 expiration on the wrap. Friends see them in Home and in the
  stories rail (green ring, star badge); a reply or like on a private post is
  wrapped to the author only and never touches a public relay.
- **Encrypted media.** Blossom does not encrypt, so a hidden event is not
  enough: every file of a close-friends post (and the cover of a video) is
  cleaned of metadata and then encrypted on the phone with AES-256-GCM (new
  key and nonce per file, key only inside the wrap, ciphertext hash `x`,
  plaintext hash `ox`), uploaded as an opaque blob signed by a **throw-away
  key** (the blob is not linked to the author), and downloaded, verified and
  decrypted on the friends' phones (streamed download capped at 120 MB; videos
  are decrypted to a cache file wiped after a day and at logout). Servers
  that refuse opaque blobs (Primal answers 415) are remembered and tried last.
  **If no server accepts the encrypted file the post is not published; there
  is no unencrypted fallback.**
- **Onboarding page "Pubblico e privato"** (also at the top of the friends
  list and in Settings → "Rivedi la guida iniziale") saying what is public,
  what close friends protects, and what it cannot: screenshots, removed
  friends, other Nostr clients, friends without private messages, servers
  that refuse encrypted files.
- **Theme**: light / dark / follow the system, in Settings.
- **Support**: Lightning address (same as eikon) at the bottom of Settings;
  opens the user's wallet, or copies the address.
- `docs/ROADMAP.md`.

### Changed
- A public event that claims the close-friends audience is dropped by every
  public path (`MediaPost.tryParse(allowPrivate: false)`).
- Private posts have no public id: no save, link, report, zap or forwarding.

### Tests
- 340+ tests: AES-GCM against the NIST vector, tamper and wrong-key cases,
  the full flow between author, friend, non-friend and unreachable friend
  against a fake Blossom server (the server stores only ciphertext, the relay
  only gift wraps, the upload is signed by another key, likes/replies stay
  private, restart without relays, no plaintext fallback), the downloader,
  and layout tests for the new screens.

## [0.14.0] — 2026-11-01 — People search, Following / Discover

### Fixed
- **People could not be found by name** when forwarding a post or starting
  a chat: only profiles that happened to be loaded were searched, and only
  among followed accounts. The whole follow list is now loaded in the
  background (a few batches at a time) and matched on display name,
  username and NIP-05, ignoring accents ("jose" finds "José"). Accounts you
  do not follow are found through NIP-50 search relays
  (`search.nos.today`, `nostr.wine`; your own relays do not support it) and
  `name@domain` addresses are resolved through NIP-05. Pasting an `npub`
  still works but is never needed. Results show the name and the address.
- **Which feed is this?** Home now shows only the people you follow (and
  you), says so with a "Seguiti | Scopri" switch, and has a clear empty
  state when you follow nobody. The everything-from-all-relays stream moved
  to the **Scopri** tab (formerly Esplora), with recent posts, `#mialuna`,
  search by person / hashtag / words, pull-to-refresh and endless scroll.
  Guests, who cannot follow anyone, see Scopri on Home. Stories follow the
  same rule (followed accounts and you).
- Following feed reads the followed accounts in chunks of 80 (relays refuse
  huge `authors` filters), on your relays and on the relays each author
  publishes to (NIP-65 outbox, up to six).
- `EOSE` was reported before events still waiting for signature
  verification were delivered, so a caller that read its result right after
  EOSE (the follow list) could see nothing.
- A refresh while a load was already running returned that older load, which
  had asked the relays before the new posts existed; it now queues a fresh
  load.

### Tests
- 276 tests: people search (local, accents, NIP-05 names, NIP-50 relay,
  ranking), following vs discover feed, refresh merge, empty follow list.

## [0.13.0] — 2026-11-01 — Stable feed, private messages, clean uploads

### Fixed
- **The Home feed stayed on a spinner forever.** The relay pool was rebuilt
  every time the settings emitted a new value (right after start-up and
  after the NIP-65 sync), killing the feed's, the profile's and the
  stories' subscriptions. The pool is now created once and follows the
  settings through `updateRelays`; relays added later join open
  subscriptions.
- **Refresh did nothing.** The pool used to drop every event it had already
  delivered once, so a second subscription (refresh, profile, search) got
  nothing. Deduplication is now per subscription; refreshing merges new
  posts into what is on screen and always completes (EOSE, with a timeout).
- **Profiles retrieved nothing.** Metadata was requested one key at a time,
  a miss was cached forever, an older kind 0 could replace a newer one, and
  post cards never showed name or avatar. Profiles are now loaded in
  batches (also from indexer relays), newest wins, misses are retried and
  the cache is persisted. Every avatar and name in the app resolves through
  it, and any author can be opened as a profile (follow, message, posts,
  reels, NIP-05 really verified, following count).
- **Videos opened full screen.** They now play inline in the card (poster,
  play/pause, mute, progress, one at a time, paused on tab change and when
  the app goes to the background). The full-screen player — source of the
  RenderFlex overflow — is gone.
- **Layout overflows**: fixed-height tiles in Create, the profile header and
  the inbox no longer overflow with large fonts or small screens
  (layout tests at 320×568, 411×923 and 800×1280, text ×1 and ×2).
- **Images that did not load.** Posts pointing at YouTube pages or at
  `127.0.0.1`/LAN addresses are rejected during parsing; photos try `https`
  upgrades and `fallback` mirrors, are decoded at display size, and posts
  whose media is permanently gone (HTTP 4xx, undecodable) disappear from
  the feeds instead of showing broken tiles. Missing dimensions no longer
  crop everything to a square.
- **Blossom rejections.** Uploads now send `X-SHA-256`, accept `409 already
  exists`, read the server's `X-Reason`, verify the returned hash, sign the
  authorization once (a single Amber prompt) and try the servers of the
  user's own list in order. The error shown names every server and why it
  refused. Amber's public key is accepted as hex or `npub`, and Amber is no
  longer launched at every start-up.
- Follow list: a follow can no longer overwrite the list before it has been
  loaded; relay hints, petnames and the legacy `content` are preserved.
- Event deletion/like toggle (NIP-09) and per-card subscriptions replaced by
  one batched request (relays cap concurrent REQs).
- Several `whenComplete(() => map.remove(key))` calls returned the very
  future they completed (self-deadlock) in the outbox resolver, the video
  poster loader and NIP-42 authentication.

### Added
- **Pinch to zoom in place** (Instagram-style): two fingers lift the photo
  above the feed, release springs it back; one finger still scrolls and
  swipes the carousel. Double-tap likes.
- **Tap Home to go back to the top and refresh** (Reels and Explore do the
  same); infinite scroll; skeleton loading; "caption: more".
- **Video posters**: from the event, or extracted from the video with the
  platform decoder (native bridge, no plugin; Swift side untested). New
  videos upload a cover image, dimensions and duration.
- **Metadata removal at upload, fail-closed.** A byte-level sanitizer strips
  EXIF/GPS, XMP, IPTC, comments, text/time chunks, vendor trailers
  (Ultra HDR gain maps) from JPEG/PNG/WebP/GIF without recompressing, bakes
  the EXIF rotation when needed, wipes MP4/MOV location atoms and
  timestamps in place, converts HEIC/AVIF through the platform decoder and
  refuses anything it cannot clean (the old code uploaded the original on
  failure). The result is re-inspected before every upload.
- **NIP-65, automatic.** Read/write roles per relay; on sign-in and when the
  app returns to the foreground the newest kind 10002 (and BUD-03 kind
  10063 Blossom list) is fetched from your relays and indexer relays and
  adopted when newer; manual edits are published back. Authors' own relays
  are used to read their profiles (outbox model).
- **Private messages (NIP-17/NIP-59/NIP-44)**: inbox, chat, unread badge,
  inbox relay setup (kind 10050), NIP-42 AUTH, self-copy for other devices.
  **Forward photos, videos, reels and stories** from Home, Reels or the
  story viewer with the paper-plane button (multi-select, optional note);
  shared posts show as preview cards in the chat. Works with nsec, Amber
  (silent through its content provider once "remember" is set) and bunker.
- Stories: unseen/seen ring stored locally, first unseen story first,
  swipe shows the neighbour creator instead of repeating the current one.
- NIP-19 `nevent` with relay hints; `title`, `published_at`, `duration` and
  `dim` tags on new posts.

### Changed
- Default relays: `relay.nostr.band` (no longer answering) replaced with
  `relay.primal.net`.

### Tests
- 263 tests (from 128): relay pool against real local WebSocket relays
  (dedup, EOSE, roles, publish reports, NIP-42), DM flow between two
  accounts, NIP-59 impersonation checks, byte-level sanitizer fixtures,
  Blossom fallback/409/hash, media validation, outbox planning, pinch zoom,
  and 57 layout tests.

## [0.12.0] — 2026-11-01 — Block, hashtag filters, story sharing

### Added
- Block (local, device-only): blocked authors disappear from feed, reels,
  stories, comments and notifications. Available from the post menu.
- Hashtag muting: posts carrying a muted hashtag are filtered from feed
  and explore. Hashtags travel in the NIP-51 mute list (kind 10000 `t`
  tags) alongside muted authors.
- Settings → Moderazione: manage muted authors, blocked authors and muted
  hashtags (add/remove).
- Stories: share button copies the `nostr:note1…` link (NIP-19/NIP-21).

### Tests
- NIP-51 hashtag round-trip (lowercased), wrong-kind rejection.

## [0.11.0] — 2026-11-01 — NIP-51 list sync

### Added
- Bookmarks (kind 10003) and muted authors (kind 10000) now sync through
  NIP-51: on sign-in the relay lists are merged into the local ones
  (union — nothing local is ever deleted) and every change is published
  back as a replaceable event. Guest mode stays local-only.

### Tests
- NIP-51 tag building and parsing round-trips, wrong-kind rejection.

## [0.10.0] — 2026-11-01 — Photo editor

### Added
- Built-in photo editor in the composer (crop icon on photo thumbnails):
  free and shape-locked crop (original, 1:1, 4:3, 3:2, 16:9) with draggable
  handles, quarter-turn rotation, horizontal flip, brightness, contrast
  and saturation.
- The crop math is ported from eikon-gallery's CropTool (MIT, same
  author), including its test suite; the pixel pipeline runs on the
  `image` package, no new dependencies.

### Tests
- CropTool port: the full eikon-gallery test suite, translated.
- Apply pipeline: crop/rotation geometry, brightness, grayscale, passthrough
  of undecodable bytes.

## [0.9.0] — 2026-11-01 — Profile tabs, alt text, NIP-65 read

### Added
- Profile tabs: Post, Reels (kind 22) and Saved (bookmarked posts resolved
  from the relays by id).
- Composer: alt text per media (tap a thumbnail, ALT badge when set) and a
  sensitive-content toggle publishing the NIP-36 `content-warning` tag.
- NIP-65 read: on sign-in the newest kind 10002 relay list is fetched from
  the bootstrap relays and adopted automatically — unless the user has
  customized relays manually, in which case their choice always wins.

### Tests
- NIP-65 `r`-tag parsing: read/write markers, deduplication, wrong kinds.

## [0.8.0] — 2026-11-01 — Onboarding, Amber fix, Nostr Wallet Connect

### Added
- Three-page first-run onboarding: 1) welcome with app presentation,
  2) sign-in (Amber / bunker / nsec / guest), 3) permissions (photos &
  videos, notifications) and optional NWC wallet link. Shown once,
  persisted locally; /login stays reachable afterwards.
- Nostr Wallet Connect (NIP-47): parse `nostr+walletconnect://` strings,
  pay zap invoices in-app (kind 23194/23195, NIP-44 with NIP-04 fallback),
  connection persisted in encrypted storage. Zaps fall back to the
  external wallet handoff when NWC is not configured or payment fails.
- Amber button is now always visible on Android; when Amber is not
  installed it explains why and links to F-Droid.

### Fixed
- Amber detection on Android 11+: the manifest now declares the signer
  package and `nostrsigner:` scheme in `<queries>` — without it the button
  never appeared even with Amber installed.

### Tests
- NWC: URI parsing/round-trip, NIP-44 and NIP-04 `pay_invoice` request
  payloads decryptable by the wallet side.

## [0.7.0] — 2026-11-01 — NIP-44, zap hardening

### Added
- NIP-44 v2 encryption (`core/nostr/nip44.dart`): secp256k1 ECDH,
  HKDF-SHA256, ChaCha20, HMAC-SHA256, power-of-two padding with extended
  length prefix. Verified against the official test vectors (conversation
  keys, message keys, padding, encrypt/decrypt, invalid payloads).
- Bunker (NIP-46) now prefers NIP-44 and falls back transparently to legacy
  NIP-04 for older remote signers (timeout retry + `?iv=` detection).
- Zap receipts (kind 9735) in notifications: sender, amount in sats and
  comment parsed from the embedded zap request.
- LNURL-pay limits (`minSendable`/`maxSendable`, `commentAllowed`) are
  honored: the zap dialog shows the valid range and invalid amounts are
  rejected before requesting an invoice.

### Tests
- 30 new NIP-44 tests against the official vectors; 9 new zap tests with a
  mocked LNURL endpoint (invoice flow, limits, comments, receipts).

## [0.6.0] — 2026-11-01 — Camera, EXIF, NIP-65, accessibility

### Added
- Composer: camera capture for photos and videos (image_picker), alongside
  gallery selection.
- Automatic EXIF/GPS metadata stripping before every upload
  (`core/media/exif.dart`), with unit tests.
- NIP-65 relay lists (kind 10002): publish your read/write relay set from
  Settings.
- Accessibility: semantics labels on media and interactive elements,
  reduced-motion support honored by Stories and Reels.
- `docs/release.md`: signed release builds, F-Droid/IzzyOnDroid
  preparation; fastlane store metadata.

### Fixed
- EXIF test fixture now produces a real GPS IFD (typed setters).

## [0.5.0] — 2026-11-01 — Extended sign-in, zaps and settings

### Added
- NIP-46 bunker login (legacy NIP-04, the most widely supported by
  bunkers): connect, remote signing, session restore; UI on the login
  screen.
- NIP-57 zaps: lud16/lud06 address from profile, signed kind 9734 zap
  request, BOLT-11 invoice via LNURL, Lightning wallet handoff. Optional.
- Settings: relay management (add/remove, persisted, never silently
  overwritten), configurable Blossom server, cache clearing, app info.
- Profile metadata: lud16/lud06 parsing.
- F-Droid metadata (fastlane, en/it) and THIRD_PARTY_NOTICES.md.

## [0.4.0] — 2026-11-01 — Phase 4 (social polish)

### Added
- NIP-25 likes (kind 7) with live per-post count; NIP-22 comments
  (kind 1111) with bottom sheet, nested reply model and sending.
- Sharing: copy `nostr:note1…` links (NIP-19/NIP-21).
- NIP-02 follows (kind 3): read/write preserving existing tags, Follow
  button in Reels and count on the profile.
- Profile: kind 0 metadata (name, bio, avatar, NIP-05), profile editing,
  grid of your own posts, npub copy.
- Notifications: reactions, comments and new followers (dedicated screen,
  with a warning about relay limits).
- Local bookmarks (saved posts) and locally muted authors; NIP-56 reports
  (kind 1984).
- The feed filters out muted authors.

### Notes
- NIP-57 zaps and NIP-46 bunker landed in 0.5.0.
- NIP-51 sync of bookmarks/mute lists: future iteration (local for now).

## [0.3.0] — 2026-11-01 — Phase 3 (Stories and discovery)

### Added
- Stories (NIP-40): kind 20/22 events with the `mialuna.story` label
  (NIP-32) and 24-hour expiration; circular rail above the feed grouped by
  author; full-screen viewer with progress bars, tap forward/back,
  long-press to pause, swipe between authors; expired Stories disappear
  everywhere.
- Composer: Story mode (single photo or video) with an explicit warning
  that expiration does not guarantee deletion.
- Explore: universal search — hashtags, accounts via npub (NIP-19), NIP-50
  text search (on relays that support it).
- Nostr filter with `search` field (NIP-50).

### Tests
- 7 new tests: Story expiration, NIP-32 labels, kind 22 for video Stories,
  NIP-50 serialization.

## [0.2.0] — 2026-11-01 — Phase 2 (videos and Reels)

### Added
- Full-screen video player (`video_player`): controls, mute, scrubbing,
  buffering indicator, retry on error. Opened from the feed by tapping a
  video.
- Reels: full-screen vertical viewer with swipe, autoplay of the active
  video, pause/reset when leaving the page, creator overlay with expandable
  caption and like/comment/share/follow buttons.
- Composer: Photo / Video / Reel modes (selector), video selection from
  gallery, kind 21 (video) or kind 22 (reel) publishing with Blossom
  upload.
- Feed: tappable video previews in cards.

### Notes
- Adjacent reel preloading and video trimming: future iteration.
- Video uploads respect the limits of the configured Blossom servers.

## [0.1.0] — 2026-11-01 — Phase 1 (photographic MVP)

### Added
- Flutter foundation: Mialuna theme (light/dark), 5-tab navigation
  (Home, Explore, Create, Reels, Profile), router with `go_router`.
- Nostr core: NIP-01 events, BIP-340 signing, NIP-19 (npub/nsec/note),
  multi-relay pool with deduplication, exponential backoff and signature
  verification, in-memory store with replaceable-event handling.
- NIP-68 photos (kind 20): parsing and publishing, multi-image carousels,
  `imeta` with mime/dim/hash/alt, `content-warning` (NIP-36).
- NIP-71 parsing (kind 21/22/34235/34236) at the data-model level.
- Official `#mialuna` hashtag: centralized application, deduplication,
  composer preview (`core/branding`).
- Authentication: Amber via NIP-55 (Android, native Kotlin channel), nsec
  with encrypted storage and risk warning, read-only guest mode.
- Blossom uploads with kind 24242 authorization; publishing blocked when an
  upload fails; persistent offline drafts.
- Explore: discovery grid and hashtag search (#mialuna feed).
- Local JSON cache for events and drafts.
- 41 unit tests: NIP-19, bech32, event signing/verification, NIP-68/71
  parsing, hashtag policy, EventStore, filters, Blossom.

### Known limitations
- Reels and video playback landed in Phase 2 (0.2.0).
- Stories landed in Phase 3 (0.3.0).
- NIP-46 bunker landed in 0.5.0.
- NIP-65 relay lists landed in 0.6.0.
- Local cache is JSON; Drift/SQLite migration planned.
- iOS build not verified (requires an Xcode environment).
