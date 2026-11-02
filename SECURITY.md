# Security policy

## Reporting vulnerabilities

Please **do not open public issues** for security vulnerabilities.
Contact the maintainers privately (see README) describing:

- affected component and version
- potential impact
- steps to reproduce (if possible)

We aim to respond within 7 days.

## Scope

- Key management: private keys are never logged or transmitted; nsec login
  uses encrypted storage; Amber (NIP-55) keeps the key outside the app
  process. Signing out also unlinks the Nostr Wallet Connect wallet and
  deletes everything the account left on the phone.
- Media uploads: Blossom authorization (kind 24242) has a short expiry.
- Public content: everything published to Nostr relays is public by
  definition of the protocol.

## What the app does to keep its attack surface small

- **Android**: the only permissions are INTERNET, notifications and media
  access; one exported activity (the launcher), no deep links, no other
  component; `allowBackup=false` and empty backup / device-transfer rules (the
  decrypted messages never reach a cloud backup); cleartext traffic and
  user-installed CAs are refused in release builds; R8 shrinking is on; private
  screens (messages, the friends list, close-friends stories) are `FLAG_SECURE`
  (no screenshots, blank app-switcher preview). `test/android/manifest_test.dart`
  fails when any of this changes without a decision.
- **Servers somebody else chose** (a NIP-05 domain, a Lightning address, an
  LNURL callback): only public `https` hosts, checked by name *and* by what the
  name resolves to, no credentials in the URL, no redirects, answers cut at
  128 KB (`lib/core/net/safe_http.dart`). The invoice a Lightning server returns
  is checked against the amount the user chose before anything is paid.
- **Relays**: `wss://` anywhere; plain `ws://` only to the user's own network;
  messages above 6 MB are dropped unread; signatures are verified off the UI
  isolate.
- **Media**: metadata is removed before upload and the upload fails closed;
  close-friends files are encrypted on the phone.
- **CI**: workflow permissions are read-only, third-party actions are pinned to
  a commit, Dependabot proposes updates weekly.

Known limits: a name that resolves differently at connection time than at
the check (DNS rebinding) is not caught by a check done beforehand; images and
videos are fetched from whatever host a post names (that host sees the
reader's IP address, as in every Nostr client); a NIP-57 zap receipt shown in
Notifications is checked for a valid, signed zap request addressed to you (so
nobody can put somebody else's name on a zap) and its amount is the paid
invoice's, but not for having been issued by the recipient's Lightning
provider, so a zap can be claimed by someone who paid nothing; the decrypted
messages kept on the phone rely on Android's file-based encryption and the app
sandbox, not on a second layer of encryption of their own.

## Dependencies

Dependencies are reviewed at every release; preference goes to
MIT/Apache/BSD licenses and actively maintained packages.
