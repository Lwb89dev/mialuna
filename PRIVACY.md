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

## Who watched your stories

When you watch a story, Mialuna can tell its author. It does so with one
private message per author (NIP-17/NIP-59 gift wrap, like private likes and
replies): it lists the stories you watched, is encrypted so that only the
author can read it, and is published only to the author's inbox relays. Relays
see a message from a throw-away key to the author, not who watched nor what.
Nothing is asked of, or sent to, any media server. The author sees your name
in the list of viewers of their own story, nobody else does.

It is on by default and **Settings → "Let people see that I viewed their
stories"** turns it off.

* **When it counts.** A story is watched, and reported, only once its picture
  or video has really been on screen for a second, not held, not in the
  background and, for a video, actually playing. Swiping past it, or a picture
  that never loaded, is not a view.
* **If it cannot be delivered.** A receipt is delivered when the author's inbox
  relay accepted it; that says the relay took it, not that the author read it.
  Until then it waits on your phone — just the id of the story and the author's
  public key, nothing of the story itself — for at most 24 hours, and is tried
  again with growing pauses. A local key does this by itself; with Amber or a
  bunker nothing is attempted in the background, only when you leave the
  stories (when they would ask you to approve). Signing out deletes it.
* **Turning it off** discards whatever is waiting, at once, and nothing is sent
  or kept afterwards, not even after a restart. A receipt a relay has already
  accepted cannot be taken back.
* A story you already reported is not reported again. Which stories you have
  watched is kept on this device, separately for each account.
* **Receipts that reach you** are kept on this device for three days. A receipt
  is the viewer's own statement, not proof that they watched anything, so it is
  counted only for your own stories that are still live; one naming any other
  story is ignored. No server ever counts the views.

## Web of trust (optional)

Settings → Web of trust is off by default. When on, Mialuna works out on this
phone whom to trust — the people you follow, and whoever is followed by at
least ten of them — by reading the follow lists (kind 3) that relays already
publish, and hides comments, notifications, private posts and messages from
everyone else (messages wait in "message requests"; Discover is never
filtered). The result is kept on this device; nothing is sent to any server
and no third-party scoring service is used. Asking relays for the follow lists
of the people you follow does reveal, to those relays, whose lists you asked
for.

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
cannot be cleaned it is **not uploaded**.

## Deleting a post

*Delete* in the menu of your own post, reel or story does two separate things:
it sends your relays a deletion request (NIP-09, kind 5) and asks the media
servers that hold its photos and videos to delete them (Blossom `DELETE`,
signed with your key). Both are **requests**: a relay may ignore the first,
and anyone who already saved a copy keeps it. Whatever happens, the post is
never shown on your phone again.

A file that another post of yours (or your profile picture) still uses is left
on the server, since a file is addressed by its content and deleting it would
break that post as well. If a media server refuses or cannot be reached,
Mialuna tells you which one still holds the file. A server that says "deleted"
is taken at its word: some are only a front for another storage or a cache,
and a copy there can outlive the answer (seen with `blossom.band`, whose files
are also served from `image.nostr.build`).

Mialuna does not read other people's deletion requests: a post its author
deleted disappears for you when your relays stop serving it.

## Close friends

A post, story or video for your close friends is delivered only to them
(NIP-59 gift wraps, to each friend's inbox relays). Its photos and videos are
**encrypted on your phone** (AES-256-GCM) before they are uploaded, so the
Blossom server and anyone who finds the file's address only ever see
unreadable data; the upload is signed with a one-off key, so the file is not
linked to your account. Likes and replies on such a post go to its author only.

That one-off key is kept on your phone (next to the post, not inside it, so
your friends never hold it) and used once more: to ask the server to delete
the file when you delete the post. Relays cannot be asked to delete such a
post, since each copy is signed by a throw-away key; instead Mialuna tells
your friends' apps, in a gift wrap of its own, to remove it. Posts made before
this version have no kept key: their files stay on the server (encrypted).

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
they do not have to be decrypted again at every start. They are removed when
you **sign out** (Settings → Clear cache only empties the feed caches, not
your messages), are excluded from Android's cloud backup and device-to-device
transfer, and are not synced anywhere by Mialuna. The key operations stay in
Amber / your bunker; with Amber's "remember my choice", decryption happens
silently through Amber's content provider.

The messages screens and the close-friends list are marked secure: Android
blocks screenshots and screen recordings of them and shows a blank preview in
the recent-apps list. The keyboard is asked not to learn from what you type in
messages and comments (incognito mode, where the keyboard supports it).

## Notifications on your phone

Mialuna shows an Android notification when a reaction, comment, zap, follower
or private message arrives while the app is in the background but still
running. They are made on the phone from the events it receives from your
relays: **there is no push server, no Firebase / Google messaging and no
Mialuna account that learns anything**. A message notification never contains
the message — only who wrote — and on the lock screen it reads just "New
private message". Notifications are limited to a handful per minute, are
cleared when you open the app, and can be turned off in Settings → System
notifications or in Android's settings. Because Android stops apps that sit
idle for long, they arrive only while Mialuna is still alive.

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
drafts stay on the device. **Settings → Clear cache** empties the feed caches.
**Signing out** removes everything the account left on the phone: the key, the
wallet link (a Nostr Wallet Connect secret is the right to spend), decrypted
messages and close-friends posts, the friends list, the web of trust, every
cache and draft, and the account's own preferences (saved posts, muted people,
blocks, watched stories). Nothing is included in Android backups.

## What other servers learn

Every image and video is fetched from the host a post names, which therefore
sees your IP address and the time, as with any Nostr client; Mialuna only
fetches `http(s)` addresses of public hosts. Opening a profile whose name is
`name@domain` makes one request to that domain to verify it (no redirects, no
credentials, nothing but the answer is read). Zaps ask the recipient's Lightning
server for an invoice; the invoice amount is checked against the one you chose
before the wallet is asked to pay.
