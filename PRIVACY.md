# Privacy in Mialuna

Mialuna has no servers of its own, collects no analytics, and includes no
trackers or advertising SDKs.

## What is public

Nostr is a public protocol. Everything you publish (photos, videos,
captions, reactions, comments, follow list) is sent to the relays you
choose and can be read, copied and archived by anyone. Treat every piece of
content as permanently public.

## Stories are not truly ephemeral

Stories use NIP-40 with a 24-hour expiration: relays that honor the
standard stop distributing them after expiry, but **we cannot guarantee
deletion** from relays, archives or media storage servers. Anyone can save
or screenshot them.

## Keys

- **Amber (recommended)**: the private key never enters Mialuna.
- **nsec**: stored only in the device's encrypted storage, never
  transmitted or logged. Removed on logout.

## Media

Uploads go to the Blossom servers you configure — and only to those, in the
order you set (they are also read from, and published to, your Nostr
profile as a BUD-03 server list). Before every upload Mialuna removes all
metadata from photos and videos — EXIF, GPS location, device model, XMP,
IPTC, comments, creation times — directly in the file's bytes. If a file
cannot be cleaned it is **not uploaded**. Deleting a Nostr event (kind 5)
**does not delete** the media file from the Blossom server: they are
separate operations.

## Close friends

A post, story or video for your close friends is delivered only to them
(NIP-59 gift wraps, to each friend's inbox relays). Its photos and videos are
**encrypted on your phone** (AES-256-GCM) before they are uploaded, so the
Blossom server and anyone who finds the file's address only ever see
unreadable data; the upload is signed with a one-off key, so the file is not
linked to your account. Likes and replies on such a post go to its author only.

What this does **not** do: it cannot stop a friend from taking a screenshot or
sharing what they saw; removing a friend only affects future posts; the
friends list inside a post is visible to the friends; the server still learns
the size and upload time of the blob and the IP address that uploaded it; other
Nostr apps do not show these posts. If none of your media servers accepts an
encrypted file, Mialuna does not publish the post — it never falls back to
unencrypted. **Public posts are public**: their files are readable by anyone
who has the link.

On this device the decrypted posts and the keys of the files are kept in the
app's private storage (so they are not decrypted again at every start), and
decrypted videos are cached as temporary files that are deleted after a day and
when you sign out. Your friends list is stored on the relays as an event only
you can read (NIP-44 to yourself).

## Private messages

Messages use NIP-17 (NIP-44 encryption, NIP-59 gift wrap): relays see
neither who wrote a message, nor its content, nor its real time — only that
something was delivered to the recipient's inbox relay. The people you
write to, and your relays, can still see that your account exists and which
relays you use. A message can be read by whoever holds the recipient's key;
Nostr cannot make a recipient forget what they received.

Decrypted messages are kept in the app's private storage on this device so
they do not have to be decrypted again at every start. They are removed
when you clear the cache and are not synced anywhere by Mialuna. The key
operations stay in Amber / your bunker; with Amber's "remember my choice",
decryption happens silently through Amber's content provider.

## Relay lists

Your relay list (NIP-65) and, if you edit them, your Blossom servers are
published as ordinary Nostr events so your other apps follow. Profile and
relay-list lookups also query the public indexer relays purplepag.es and
indexer.coracle.social (metadata only). When you search people by name, the
text you type is sent to the NIP-50 search relays `search.nos.today` and
`nostr.wine` (profile searches only), and `name@domain` addresses are
looked up on that domain's web server.

## Local data

Event caches, profiles, relay lists of other people, private messages and
drafts stay on the device and can be wiped from the settings.
