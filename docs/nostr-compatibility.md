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
- **Texts over stories** (Instagram-style text stickers): a story may carry up
  to 8 tags `["story-text", "<json>"]`. They are *not* baked into the picture,
  so the `#hashtags` in them stay tappable. The JSON is
  `{"t": text, "x": 0.5, "y": 0.4, "s": 1, "r": 0, "c": "ffffff",
  "f": "bold", "b": "solid"}`:
  `t` the text (max 200 characters), `x`/`y` its centre as a fraction (0–1) of
  the picture's width/height, `s` the size (1 = 6.2 % of the picture's width,
  0.4–5), `r` the rotation in radians, `c` the colour as `rrggbb`, `f` the font
  (`classic`, `bold`, `serif`, `mono`, `italic`) and `b` the background
  (`none`, `solid`, `veil`). Readers clamp every number and fall back to the
  default for unknown fonts; a tag that is not valid JSON or has no text is
  ignored. The hashtags of the texts are also published as `t` tags. Other
  clients ignore the tag and show the plain picture.
- **Hashtags** are `#` followed by letters, marks, digits or `_` of any script
  (`#città`, `#東京`), not glued to a previous word. Published as lower-case
  `t` tags.
- **Lists shared with other clients** (mute list 10000, bookmarks 10003) are
  republished keeping every tag Mialuna does not manage (`word`, `e`, `a`,
  `r`…) and the event's `content` (private entries are never read nor
  rewritten), and only after the relay copy has been read.

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
- History older than the first sync on a device is not counted as unread —
  not even briefly while the inbox is still loading.
- The number on the paper plane of Home is the count of unread messages; the
  bell counts notifications (reactions, comments, zaps, new followers) newer
  than the last time the notifications screen was open. A follower's updated
  follow list is not a new follower, and a `-` reaction is not a notification.

## Story views

Who watched a story is not asked of Blossom (a media server cannot know it);
it lives in a message from the viewer to the author. The viewer sends a rumor
of kind `1417` (Mialuna convention), `content` empty, with one `["e",
<story id>]` tag per story watched (at most 30; more are sent as further
messages) and `["p", <author>]`, gift-wrapped (NIP-59) **to the author only**
and published to the author's inbox relays (kind 10050, or NIP-65 read relays).
One message per author (per 30 stories) when the viewer leaves that author's
stories. The viewer's pubkey is the seal's. A story counts as watched once its
media was on screen for a second (not paused, not in the background, a video
playing). Off with Settings → "Let people see that I viewed their stories"; on
by default.

*Sending.* A receipt is delivered when at least one inbox relay of the author
accepted the wrap (`OK true`); otherwise it stays in a per-account outbox and is
retried with a doubling back-off (30 s up to an hour; 5 minutes up to 6 hours
after a refused signer request) for 24 hours. Amber and bunker are not asked
in the background. A retry is a new rumor; the author counts a viewer once per
story, so a second copy changes nothing. A wrap already accepted by a relay
cannot be recalled when the setting is turned off.

*Receiving.* Authors ignore receipts not addressed to them, from themselves,
from blocked or muted accounts, with a malformed (not 64 lowercase hex digits)
story id, older than three days, or listing more than 30 stories. A receipt is
self-reported: it is counted only for a story the author knows to be their own
and still live (public or close-friends); one that names a story not yet known
(the rail is still loading) is held for up to an hour in a bounded buffer —
600 in all, 60 per sender — and counted when the story appears, otherwise it is
forgotten. Time is clamped to the story's publication and to now, a viewer is
listed once per story with their latest time, and a story lists at most 2000
viewers. Other clients ignore the unknown rumor kind.

*Story lifetime.* A story is shown for 24 hours from `created_at`, whatever its
NIP-40 `expiration` says: a valid earlier expiration ends it earlier, a missing,
malformed or later one does not extend it, and one dated more than ten minutes
in the future is not shown. For other posts NIP-40 is applied as written. The
tag is a promise to relays, not proof that the media is deleted.

## Zap receipts (NIP-57) and notifications

A receipt (kind 9735) is shown as "X zapped you N sats" only when its
`description` holds a kind 9734 zap request whose **signature verifies** (so
the sender it names really made it), whose `p` tag is the same as the
receipt's, and — for the amount — the receipt's own `bolt11` invoice is read
(the request's `amount` tag is the fallback). Anything else is shown as a
plain notification from the receipt's author, with no amount. Mialuna does not
check that the receipt was issued by the recipient's Lightning provider
(`nostrPubkey` of their LNURL), so a receipt proves who *claims* to have paid,
not that a payment happened.

The Android notifications of the app (reaction, comment, zap, follower,
private message) are produced on the device from these same events: there is
no push service. A private-message notification carries only the sender.

## Web of trust

After Outkast's: the network is your follows plus every account followed by at
least 10 of them (kind 3 of each follow read in chunks of 50, newest per
author), computed on the device, cached per account, refreshed after 12 hours
and on demand, opt-in, and only active once a network was computed. It filters
what strangers can push at you — comments on posts, reactions/comments/zaps in
Notifications (new followers stay visible), close-friends posts and stories,
and private messages (kept as "message requests", not counted as unread, until
you answer). Discover and Reels are never filtered.

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
