# Roadmap

Legend: [x] done and covered by tests/build, [~] done but only checkable on a
device (or another platform), [>] being worked on now, [ ] not started.

## Phase 1 — Foundation and photography

- [x] Flutter scaffold, design system, five-tab navigation (Home, Scopri, Crea, Reels, Profilo)
- [x] Relay pool, Amber (NIP-55), bunker (NIP-46), nsec, read-only guest mode
- [x] NIP-68 photos (kind 20): feed, carousels, composer, alt text, content warning
- [x] Blossom uploads, profiles, follows, likes, comments (NIP-22), local cache

## Phase 2 — Videos and Reels

- [x] NIP-71 (kind 21/22): publish, playback, vertical Reels viewer
- [x] Inline video in the feed card (one at a time, paused on tab change)
- [x] Video posters (from the event or extracted from the file) and cover upload

## Phase 3 — Stories and discovery

- [x] Stories (kind 20/22 + NIP-40 + `mialuna.story` label), viewer, seen/unseen ring
- [x] Discover tab (Scopri): global media grid, hashtag / words search, `#mialuna`
- [x] People search by name (local profiles, NIP-50 relays, NIP-05)

## Phase 4 — Polish and social

- [x] Notifications, zaps (NIP-57, NWC), bookmarks and mute lists (NIP-51), block, reports
- [x] Photo editor (crop, rotate, flip, light), alt text
- [x] Light / dark / follow-system theme (Settings), Lightning support button

## Phase 5 — Reliable networking (0.13)

- [x] One relay pool for the whole app, dynamic relay set, per-subscription dedup, EOSE
- [x] NIP-65 synced automatically (read/write roles, outbox model), BUD-03 server list
- [x] NIP-42 AUTH, signature verification off the UI isolate
- [x] Profiles loaded in batches with a persistent cache; any author opens as a profile
- [x] Home = people you follow; Discover = everything else

## Phase 6 — Privacy

- [x] Metadata removed from every photo and video before upload, fail-closed (`MediaSanitizer`)
- [x] Private messages (NIP-17 / NIP-59 / NIP-44), inbox relays, unread badge
- [x] Forward posts, reels and stories to one or more people as a message
- [>] **Close friends (private posts)** — see below

### Close friends: private posts with encrypted media — *done in 0.15, being validated*

What it is: a list of "close friends"; a post, story or video published for
that audience is delivered only to them. The list is *injected into the post*
(its `p` tags) instead of being picked every time, following the shape of
Outkast's private replies (Amethyst's `createNoteNIP17`): the post is an
unsigned event wrapped (NIP-59) once per friend and published only to each
friend's inbox relays.

**Known limit that shaped the work: Blossom does not encrypt.** Files on a
Blossom server are public to anyone who has (or lists) the URL, so hiding the
Nostr event is not enough. Close-friends media is therefore encrypted on the
device (AES-256-GCM, a new key per file, the key travels only inside the
encrypted post) before it is uploaded as an opaque blob. Consequences that
are part of the design and are told to the user (onboarding, friends list):

- the upload is signed with a throw-away key, so the blob is not linked to
  the author's account;
- not every server accepts opaque blobs (Primal answers 415; `cdn.hzrd149.com`,
  `blossom.yakihonne.com` and `nostr.download` accept them): the ordered
  server list is tried and refusals are remembered; if none accepts, the post
  is **not** published — never in the clear;
- other Nostr clients will not show these posts; recipients need Mialuna and
  private messages turned on (the list warns about friends who have not);
- removing a friend only affects future posts; anyone can still screenshot;
- public posts stay public: their files are visible to anyone with the link.

Steps:

- [x] 1. Roadmap entry and the limit above
- [x] 2. The list: NIP-51 private set (`d=close-friends`, members encrypted to yourself), local-first, search by name, warning for friends without an inbox
- [x] 3. Composer: audience switch (Pubblico / Amici più stretti, remembered), encrypted upload, wrap per friend and for yourself, delivery report, story expiration on the wrap
- [x] 4. Receiving: private posts and stories in Home and in the stories rail (green ring), decrypted on demand, persisted
- [x] 5. Private replies and likes: wrapped to the author only; the author sees them on the post
- [~] 6. Checked on a real device: video posts (encrypt/upload/decrypt-to-file/playback), delivery to a second real account, Amber's prompts with 60 friends (each friend costs one NIP-44 encryption and one signature; tick "remember" in Amber)

Not planned for the first version: close-friends posts on your own profile
grid, forwarding a private post, audiences other than the one list, hiding
the friends list from the friends themselves (the `p` tags show it to them,
like Outkast's), resumable uploads of large private videos (the whole file is
encrypted in memory, limited to 120 MB).

## Next

- [ ] Resumable / chunked uploads and a foreground service for big videos
- [ ] Drift/SQLite instead of the JSON cache
- [ ] Notifications while the app is closed (needs a relay-side push or a foreground service)
- [ ] Publishing to NIP-96 servers as a fallback
- [~] iOS: the Swift video-cover bridge and Amber-less flows have never been compiled or run

## Not done, and why

- Followers count: no relay can answer it exactly (NIP-45 `COUNT` is rarely supported); the app does not fake it.
- Moderation beyond mute/block/report: Nostr has no global moderator; see [PRIVACY.md](../PRIVACY.md).
- Music library, filters marketplace and anything that needs a proprietary service.
