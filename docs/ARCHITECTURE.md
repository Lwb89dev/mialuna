# Mialuna — Architecture

## Stack

- Flutter 3.47 (Dart 3.13), Material 3, `flutter_riverpod`, `go_router`.
- No backend. Nostr relays over WebSocket (`web_socket_channel`), media on
  Blossom servers (`http`). Native code only where Flutter has no answer: the
  NIP-55 (Amber) bridge and video-frame extraction (Kotlin; Swift untested).
- Local persistence: JSON files in the app's private storage (`LocalCache`),
  preferences in `shared_preferences`, secrets in `flutter_secure_storage`.

## Layers

```text
lib/
  app/        providers (one relay pool, profiles, outbox, signals), router,
              relay/blossom list sync
  core/
    nostr/    event, filter, relay, relay_pool, signer(+amber, bunker),
              nip19/44/59/65/05/51, outbox, profile_repository, models/
    media/    media_sanitizer (metadata removal), media_cipher (AES-GCM),
              private_media (download + decrypt), blossom, video_frames
    storage/  local_cache
    net/      safe_http (the only way to reach a server somebody else chose)
    notify/   system_notifier (the Android notification bridge)
    platform/ secure_window (FLAG_SECURE for private screens)
    text/     hashtags (the one definition), clip (display cap)
    trust/    the web of trust
    branding/ the optional #mialuna rule
    theme/
  features/
    feed/ stories/ reels/ explore/(Scopri) profile/ create/ comments/
    messages/ (NIP-17 inbox, chat, forwarding)
    private/  (close friends: list, delivery, private posts store, screens)
    search/ settings/ social/ notifications/ onboarding/
```

Rules that keep it testable: networking lives in `core/nostr` and the
controllers; widgets only watch providers; every relay conversation can be
replayed against `test/support/fake_relay.dart` (a real local WebSocket relay)
and every upload against `test/support/fake_blossom.dart`.

## Decisions worth knowing

- **One `RelayPool`** for the whole app, never recreated: settings changes go
  through `updateRelays`, subscriptions are deduplicated per subscription,
  EOSE is reported only after queued events were verified and delivered, and
  signatures are verified off the UI isolate.
- **NIP-65 both ways**: the user's list (read/write) is adopted when newer and
  edits are published back; other authors are read from *their* write relays
  (outbox model).
- **Home vs Discover**: Home is the people you follow (queried in chunks, on
  your relays and theirs) plus private posts addressed to you. Discover is
  only the web of trust (you, the people you follow, and whoever enough of
  them follow). Guests, who have no follow list, see the open network on Home.
- **Fail closed**: nothing is uploaded unless metadata was removed and, for
  close-friends posts, the bytes are encrypted.
- **Private store**: gift-wrapped rumors (messages, posts, likes, replies) are
  decrypted once by the inbox pump and kept locally; the signer does the NIP-44
  (Amber requests are serialised and use its content provider first).
- Kind 1 is never requested or rendered as a post.
- **Stories**: `stories_controller` groups the last 24 hours by creator;
  `stories_rail` shows the story button, your own circle and the others, each
  ring (`story_ring`) divided into one part per story; `story_composer_screen`
  is where a story is made and `story_canvas_editor` is the picture with its
  texts, written in place — both drive the same `composerProvider` as the Create
  tab. Texts travel as `story-text` tags, not pixels, so hashtags stay links.
- **Story receipts**: `story_receipts` is the sending side of "who watched your
  stories": one `StoryViewReporter` per signed-in account (rebuilt on a switch,
  it refuses to sign for anybody else) with a small outbox on disk
  (`story_receipts_<pubkey>.json`), a back-off, serialised flushes and a consent
  check before every send. Delivery means the author's inbox relay accepted the
  wrap, nothing less. `story_playback` decides when a story counts as watched;
  `story_views` receives receipts and counts only those for your own live
  stories. Time-dependent code reads `unixClockProvider` so tests move the
  clock instead of sleeping.
- **Notifications**: the controllers (`notifications_controller`,
  `dm_controller`) call `SystemNotifications.post` for what arrives live;
  the Android side is `NotifyBridge.kt`. Nothing is posted while the app is in
  the foreground, for history, for message requests or for your own messages.
- **Account data** is listed in `LocalCache.accountFiles` and removed by
  `signOutProvider`: a new file kept per account must be added there.

See [nostr-compatibility.md](nostr-compatibility.md) for the NIPs and Mialuna's
own conventions, [ROADMAP.md](ROADMAP.md) for what is done and what is not,
and [release.md](release.md) for builds.
