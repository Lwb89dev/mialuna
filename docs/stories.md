# Stories (kind 1418)

A Mialuna convention, not (yet) a NIP. It is written so that another client can
implement it from this page alone.

## Why a kind of its own

Kinds 20 and 22 are what picture and short-video clients put in their feeds. A
story published as one of them showed up there as an ordinary post, label or
not. A separate kind is not requested by those feeds, so a story stays with the
clients that know what a story is.

Kind 1418 is in the regular range (NIP-01): relays store it like any note.

## Event

```json
{
  "kind": 1418,
  "content": "caption, may be empty",
  "tags": [
    ["imeta", "url https://…", "m image/jpeg", "x <sha256>", "dim 1080x1920"],
    ["L", "mialuna.story"],
    ["l", "story", "mialuna.story"],
    ["expiration", "<created_at + 86400>"]
  ]
}
```

* **One story is one event with one photo or one video.** The `m` field of
  `imeta` says which. A video's `imeta` carries its poster in `image`.
* `expiration` (NIP-40) is required: 24 hours after `created_at`, or earlier.
* The `L`/`l` labels (NIP-32) are required: readers filter on `#L`.
* Optional: `title`, `published_at`, `duration` (seconds), `t` (hashtags),
  `content-warning` (NIP-36) and `story-text` (texts laid over the picture, see
  [nostr-compatibility.md](nostr-compatibility.md)).

## Reading

```json
{"kinds": [1418], "#L": ["mialuna.story"], "authors": ["…"], "since": <now - 86400>}
```

* A story is shown for 24 hours from `created_at`, whatever `expiration` says:
  an earlier one ends it earlier, a missing, malformed or later one does not
  extend it. One dated more than ten minutes in the future is not shown.
* A story is only shown as a story: not in feeds, profile grids or search.

## Deleting

NIP-40 only works on relays that honour it. Once a story has expired, the
author's client should send a NIP-09 request (`e` = the story, `k` = `1418`)
and delete its files from the media servers (BUD-02). See
[PRIVACY.md](../PRIVACY.md) for when Mialuna does this and what it cannot
guarantee.

## Related

* A story for close friends only is the same event as an unsigned rumor inside a
  NIP-59 gift wrap (see "Close-friends posts" in
  [nostr-compatibility.md](nostr-compatibility.md)).
* "Who watched my story" is a gift-wrapped rumor of kind `1417` (see "Story
  views" there).

## Older versions

Mialuna 0.25 and earlier published stories as kind 20 (photo) and 22 (video)
with the same labels. Mialuna still reads those; it no longer writes them.
Those versions cannot see kind 1418 stories until they are updated.

## Limits

This keeps stories out of other clients' feeds; it does not make them secret. A
public story is a public event: any client or relay can read it, and one that
chooses to show every kind will show it. Deletion is a request.
