# Mialuna

<p align="center">
  <img src="assets/icons/icon.png" width="160" alt="Mialuna icon">
</p>

**Your moments, under the same moon.**

Mialuna is an open-source, decentralized visual social network built on
[Nostr](https://github.com/nostr-protocol/nips). Photos, carousels, videos,
Reels and Stories — with the familiar feel of Instagram, without any
centralized platform.

> Mialuna is **media-first**: text-only posts do not exist. Every post
> contains at least one photo or video.

## Features

- **Photography** — NIP-68 (kind 20) feed, multi-image carousels, captions
  with clickable hashtags, alt text, built-in photo editor (crop, rotate,
  adjustments)
- **Videos & Reels** — NIP-71 publishing (kind 21/22), full-screen vertical
  Reels viewer with autoplay and preloading
- **Stories** — 24-hour visual moments via NIP-40 expiration, grouped by
  creator, with a full-screen viewer
- **Explore** — media grid, hashtag search, account search, official
  `#mialuna` feed, optional NIP-50 relay search
- **Social** — NIP-25 reactions, NIP-22 comments with nested replies,
  NIP-02 follow lists, bookmarks, NIP-57 Lightning zaps, notifications
- **Authentication** — Amber (NIP-55, Android), remote signers (NIP-46
  bunker), nsec advanced fallback, read-only guest mode
- **Media uploads** — Blossom (kind 24242 authorization, SHA-256 content
  addressing), NIP-96 alternative, automatic EXIF/GPS stripping
- **Relays** — multi-relay pool with reconnect/backoff, NIP-65 relay lists
  (kind 10002), partial publication reporting, offline cache
- **Privacy & moderation** — mute, block, sensitive-content warnings (NIP-36),
  reporting, secure credential storage
- **Branding** — every post published from Mialuna carries `#mialuna`,
  without rejecting external posts that lack it

## Project status

All four roadmap phases are implemented: photographic MVP, videos and Reels,
Stories and discovery, social polish. See [CHANGELOG.md](CHANGELOG.md),
[docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) and
[docs/nostr-compatibility.md](docs/nostr-compatibility.md) for details and
known limitations.

## Build

Requirements: Flutter 3.47+, Android SDK 36, JDK 21.

```bash
flutter pub get
flutter test
flutter analyze
flutter build apk --debug
```

The toolchain is pinned with [mise](https://mise.jdx.dev/) (`mise.toml`):
`mise install` installs Flutter and Java. The Android SDK must be configured
separately (`flutter config --android-sdk <path>`).

For signed release builds and store preparation see
[docs/release.md](docs/release.md).

## Repository layout

```text
lib/
  app/       app shell, providers, routing
  core/      auth, nostr, media, storage, theme, branding
  features/  feed, explore, create, reels, stories, profile,
             comments, notifications, settings, onboarding, social
docs/        architecture, Nostr compatibility, release guide
```

## Contributing

Contributions are welcome — see [CONTRIBUTING.md](CONTRIBUTING.md). Security
reports: [SECURITY.md](SECURITY.md). Privacy notes are in
[PRIVACY.md](PRIVACY.md); third-party attributions in
[THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md).

## License

MIT — see [LICENSE](LICENSE).
