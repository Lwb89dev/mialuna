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
  process.
- Media uploads: Blossom authorization (kind 24242) has a short expiry.
- Public content: everything published to Nostr relays is public by
  definition of the protocol.

## Dependencies

Dependencies are reviewed at every release; preference goes to
MIT/Apache/BSD licenses and actively maintained packages.
