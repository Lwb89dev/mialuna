# Changelog

All notable changes to Mialuna are documented here.
Format based on [Keep a Changelog](https://keepachangelog.com/).

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
