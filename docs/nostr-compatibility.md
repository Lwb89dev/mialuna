# Compatibilità Nostr di Mialuna

I NIP ufficiali sono la fonte autorevole. Questa tabella descrive cosa
Mialuna implementa e con quali convenzioni.

| NIP | Argomento | Stato | Note |
|---|---|---|---|
| NIP-01 | Eventi, filtri, relay | ✅ | Pool multi-relay, dedup, backoff, verifica firme BIP-340 |
| NIP-02 | Follow list (kind 3) | 🔶 | Modello dati; UI in Fase 4 |
| NIP-19 | npub/nsec/note | ✅ | Codec bech32 interno, testato su vettori noti |
| NIP-22 | Commenti (kind 1111) | 🔶 | Modello dati; UI in Fase 4 |
| NIP-25 | Reazioni (kind 7) | 🔶 | Modello dati; UI in Fase 4 |
| NIP-36 | Content warning | ✅ | Overlay "contenuto sensibile" nel feed |
| NIP-40 | Expiration | ✅ | Eventi scaduti filtrati ovunque; base delle Storie |
| NIP-32 | Label (Storie) | ✅ | `mialuna.story` per identificare le Storie |
| NIP-55 | Amber signer | ✅ | Android, intent `nostrsigner:` |
| NIP-46 | Bunker | ⏳ | Previsto dall'astrazione `Signer` |
| NIP-68 | Foto (kind 20) | ✅ | Lettura + pubblicazione, caroselli, `imeta` |
| NIP-71 | Video (kind 21/22) | ✅ | Lettura + pubblicazione (kind 21/22), player e Reels viewer |
| NIP-65 | Relay list | ⏳ | Fase 4 |
| NIP-50 | Search | ✅ | Ricerca testuale in Esplora (dipende dal supporto dei relay) |
| NIP-57 | Zaps | ⏳ | Opzionale, Fase 4 |
| Blossom | Media server | ✅ | PUT /upload, auth kind 24242, indirizzamento sha256 |

✅ implementato · 🔶 parziale · ⏳ pianificato

## Convenzioni Mialuna

- **Media-first**: il feed richiede solo kind 20/21/22/34235/34236. I kind 1
  non vengono mai richiesti né renderizzati come post.
- **#mialuna**: i post media creati in Mialuna portano `["t","mialuna"]` e il
  suffisso `#mialuna` nella didascalia (mai nei commenti o nelle reazioni).
  I post di altri client senza hashtag restano visibili.
- **Storie** (Fase 3): kind 20/22 con NIP-40 a 24h e label NIP-32
  `["L","mialuna.story"]` / `["l","story","mialuna.story"]`. Convenzione
  documentata qui in attesa di standard più ampi; i client che non la
  conoscono vedono normali eventi media con scadenza.
