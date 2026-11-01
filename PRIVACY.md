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

Uploads go to the Blossom servers you configure. Geolocation EXIF metadata
is stripped by default before publishing. Deleting a Nostr event (kind 5)
**does not delete** the media file from the Blossom server: they are
separate operations.

## Local data

Event caches and drafts stay on the device and can be wiped from the
settings.
