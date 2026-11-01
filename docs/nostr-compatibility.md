# Mialuna Nostr compatibility

The official NIPs are the authoritative source. This table describes what
Mialuna implements and with which conventions.

| NIP | Topic | Status | Notes |
|---|---|---|---|
| NIP-01 | Events, filters, relays | ✅ | Multi-relay pool, dedup, backoff, BIP-340 signature verification |
| NIP-02 | Follow lists (kind 3) | ✅ | Read/write, preserves existing tags |
| NIP-19 | npub/nsec/note | ✅ | Internal bech32 codec, tested against known vectors |
| NIP-22 | Comments (kind 1111) | ✅ | Bottom-sheet threads, nested replies |
| NIP-25 | Reactions (kind 7) | ✅ | Likes with live count |
| NIP-36/56 | Content warning, reports | ✅ | Sensitive-content overlay; kind 1984 reports |
| NIP-40 | Expiration | ✅ | Expired events filtered everywhere; basis of Stories |
| NIP-32 | Labels (Stories) | ✅ | `mialuna.story` to identify Stories |
| NIP-55 | Amber signer | ✅ | Android, `nostrsigner:` intents |
| NIP-46 | Bunker | ✅ | Login + remote signing; NIP-44 preferred, NIP-04 fallback |
| NIP-47 | Nostr Wallet Connect | ✅ | pay_invoice in-app for zaps; NIP-44 preferred, NIP-04 fallback |
| NIP-68 | Photos (kind 20) | ✅ | Read + publish, carousels, `imeta` |
| NIP-71 | Videos (kind 21/22) | ✅ | Read + publish (kind 21/22), player and Reels viewer |
| NIP-44 | Encrypted payloads v2 | ✅ | Used for NIP-46 bunker RPC; official test vectors |
| NIP-65 | Relay lists (kind 10002) | ✅ | Publish from Settings; auto-adopted on sign-in unless customized |
| NIP-50 | Search | ✅ | Text search in Explore (depends on relay support) |
| NIP-57 | Zaps | ✅ | Zap request kind 9734, receipts kind 9735, LNURL limits, wallet handoff |
| Blossom | Media servers | ✅ | PUT /upload, kind 24242 auth, sha256 addressing |

✅ implemented · 🔶 partial · ⏳ planned

## Mialuna conventions

- **Media-first**: the feed requests only kinds 20/21/22/34235/34236.
  Kind 1 events are never requested or rendered as posts.
- **#mialuna**: media posts created in Mialuna carry `["t","mialuna"]` and
  the `#mialuna` suffix in the caption (never in comments or reactions).
  Posts from other clients without the hashtag remain visible.
- **Stories**: kind 20/22 with NIP-40 24h expiration and NIP-32 label
  `["L","mialuna.story"]` / `["l","story","mialuna.story"]`. Convention
  documented here until broader standards emerge; clients that do not know
  it see ordinary expiring media events.
