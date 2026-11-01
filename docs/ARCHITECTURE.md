# Mialuna — Architecture & Compatibility Plan

## Stack

- Flutter 3.47 (Dart 3.13), Material 3, `flutter_riverpod` for state, `go_router` for navigation.
- No centralized backend. Nostr relays over WebSocket (`web_socket_channel`), media on Blossom servers (`http`).
- Local persistence: JSON file cache (`path_provider`) for events/profiles in Phase 1; Drift/SQLite is the planned replacement when query complexity grows (tracked in CHANGELOG).

## Module map

```
lib/
  app/            MaterialApp, router (5 tabs via StatefulShellRoute), theme wiring
  core/
    nostr/        event, keys+NIP-19 (bech32), signer abstraction, filter,
                  relay (single socket), relay_pool (dedup/backoff/publish),
                  event_store (in-memory dedup), models/ (NIP-68/71 parsing+building)
    branding/     #mialuna hashtag policy (single source of truth, unit-tested)
    media/        blossom client (kind 24242 auth, sha256 addressing, progress)
    auth/         session controller, nsec secure storage, guest mode
    theme/        Mialuna palette, light/dark ThemeData
    routing/      go_router config
  features/
    onboarding/   login (Amber / bunker / nsec / guest)
    feed/         Home: stories rail (Phase 3), kind 20/21 feed, likes/comments
    explore/      discovery grid, #mialuna feed, hashtag search
    create/       unified composer (photo/carousel/video/reel/story)
    reels/        vertical viewer (Phase 2 placeholder)
    stories/      (Phase 3)
    profile/      profile page, edit, follow lists
    comments/     NIP-22 threads
    settings/     relays, blossom servers, signer, storage
```

## Protocol coverage (Phase 1)

- NIP-01 events, filters, subscriptions; BIP-340 signing via `bip340` (pure Dart).
- NIP-19 npub/nsec/note encode-decode (own bech32 implementation, tested against vectors).
- NIP-68 kind 20 (pictures + carousels) — read & publish.
- NIP-71 kind 21/22 — parsing model now, playback/publish UI in Phase 2.
- NIP-02 kind 3 follow lists (read/write, preserve unknown entries).
- NIP-25 kind 7 reactions, NIP-22 kind 1111 comments.
- NIP-40 expiration tags (used by Stories in Phase 3; filtering honored now).
- Blossom: PUT /upload with kind 24242 authorization, sha256 addressing.
- Signing: `Signer` interface → `NsecSigner` (local), `AmberSigner` (NIP-55 intent,
  Android), `BunkerSigner` (NIP-46). Guest mode = read-only pubkey-less session.

## Key decisions

- **Media-first filter**: every feed query uses `kinds: [20, 21, 22, 34235, 34236]`.
  Kind 1 is never requested nor rendered as a post.
- **#mialuna policy** lives in `core/branding/mialuna_tag.dart`, applied at publish
  time only (caption + `t` tag), never to comments/reactions.
- **External content** from other clients is accepted without Mialuna metadata.
- **Drafts** are kept in memory + local cache; failed uploads block publishing.
- Relay set defaults: `wss://relay.damus.io`, `wss://nos.lol`, `wss://relay.nostr.band`,
  `wss://nostr.mom`. User overrides are never silently replaced.
