# Contributing to Mialuna

Thanks for your interest! Mialuna is open source (MIT) and welcomes
contributions.

## Ground rules

1. **Media-first**: no text-only posts. Kind 1 never enters the feed.
2. `#mialuna` is applied only to media posts published by Mialuna, through
   `lib/core/branding/mialuna_tag.dart` (single source of truth, covered by
   tests).
3. The official NIPs are authoritative. Do not invent custom kinds or
   protocols without documenting them in `docs/nostr-compatibility.md`.
4. No proprietary dependencies, trackers, analytics or advertising SDKs.

## Workflow

```bash
flutter pub get
flutter analyze   # must stay clean
flutter test      # all tests must pass
```

- One commit per logical change, message in English.
- New protocol features require unit tests.
- Open an issue before large architectural changes.
