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
| NIP-51 | Lists | ✅ | Bookmarks (10003) and mute list (10000), merged union on sign-in |
| NIP-47 | Nostr Wallet Connect | ✅ | pay_invoice in-app for zaps; NIP-44 preferred, NIP-04 fallback |
| NIP-68 | Photos (kind 20) | ✅ | Read + publish, carousels, `imeta` |
| NIP-71 | Videos (kind 21/22) | ✅ | Read + publish (kind 21/22), player and Reels viewer |
| NIP-44 | Encrypted payloads v2 | ✅ | NIP-46 bunker RPC and private messages; official test vectors; via Amber (`nip44_encrypt/decrypt`) and bunker |
| NIP-17 | Private direct messages | ✅ | Kind 14 chat messages, 1:1 only; kind 10050 inbox relays (fallback: recipient's NIP-65 read relays); sender copy |
| NIP-59 | Gift wrap | ✅ | Rumor → seal (13) → wrap (1059) with throw-away key, timestamps randomised up to 2 days; seal/rumor author check |
| NIP-42 | Relay AUTH | ✅ | Only answered when a relay demands it (private messages) |
| NIP-51 (30000) | Categorised people list | ✅ | Close-friends list: `d=close-friends`, members as NIP-44-encrypted `p` tags in `content` |
| NIP-09 | Deletion | 🔶 | Used to take a like back; posts/comments deletion not exposed yet |
| NIP-65 | Relay lists (kind 10002) | ✅ | Read/write roles; adopted automatically when newer, edits are published back; outbox model for reading other authors |
| NIP-50 | Search | ✅ | Posts in Discover (depends on relay support) and **profile search by name** on dedicated relays (`search.nos.today`, `nostr.wine`) |
| NIP-05 | DNS identifiers | ✅ | Verification badge on profiles; `name@domain` lookup in people search |
| NIP-57 | Zaps | ✅ | Zap request kind 9734, receipts kind 9735, LNURL limits, wallet handoff |
| Blossom | Media servers | ✅ | PUT /upload with `X-SHA-256`, kind 24242 auth signed once, 409 = already stored, ordered fallback across the user's servers, BUD-03 list (kind 10063) synced |

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

## Private messages (NIP-17)

- A message is a kind 14 rumor (`["p", <recipient>]`, plain text content)
  sealed and gift-wrapped for the recipient and, separately, for the sender.
- Wraps are published **only** to the recipient's inbox relays (kind 10050,
  or their NIP-65 read relays when they never published one). If neither
  exists the app says the person has not enabled private messages — it never
  falls back to public relays.
- A shared photo, video, reel or story is sent as a `nostr:nevent1…`
  reference (relay hints, author and kind included) in the message text.
  Other NIP-17 clients show it as a link; Mialuna renders a preview card.
- Group chats (several `p` tags) are ignored for now.
- History older than the first sync on a device is not counted as unread.

## Media hygiene

Before any upload the sanitizer removes EXIF/GPS, XMP, IPTC, comments, text
chunks, MP4 `udta`/`meta`/`uuid` atoms (zeroed in place) and creation times.
It never falls back to uploading the original. Unsupported containers
(WebM/MKV) are refused with an explanation.

Incoming media is validated: only http(s) URLs on public hosts that are not
web pages (YouTube, Vimeo, …); `imeta` `image`/`thumb` give the poster,
`fallback` mirrors are tried in order.

## Close-friends posts (Mialuna convention)

Built on NIP-17/NIP-59; not a standard other clients understand.

- **Post**: an unsigned event (rumor) of kind 20/21/22 with the usual
  `imeta`/`title`/`published_at` tags plus `["audience","close-friends"]` and
  one `["p", <friend>]` per friend (the list is injected in the post). Stories
  add the usual `L`/`l` labels and `expiration`; the gift wrap also carries the
  `expiration` so relays can forget it. No `#mialuna` hashtag: private posts are
  not discoverable.
- **Media**: each file is an opaque AES-256-GCM blob (ciphertext ‖ 16-byte tag)
  on a Blossom server. `imeta` carries `url` (the blob), `m` (the original MIME
  type), `x` (SHA-256 of the blob), `ox` (SHA-256 of the original),
  `encryption-algorithm aes-gcm`, `decryption-key <hex>`,
  `decryption-nonce <hex>`; a video's cover is another encrypted blob
  (`image`, `image-decryption-key`, `image-decryption-nonce`). This mirrors the
  file fields of NIP-17 kind 15. The upload is authorised by a throw-away key.
- **Delivery**: seal (kind 13) and wrap (kind 1059) per friend and one for the
  author, published only to each recipient's kind 10050 relays (fallback: NIP-65
  read relays). Friends without an inbox are reported, never sent to public relays.
- **Likes and replies**: kind 7 / kind 1111 (NIP-22 tags) rumors wrapped to the
  post's author (and the person answered) only.
- A *public* event carrying the `audience` tag is ignored by every public path.
