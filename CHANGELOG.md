# Changelog

Tutte le modifiche rilevanti a Mialuna sono documentate qui.
Formato basato su [Keep a Changelog](https://keepachangelog.com/).

## [0.3.0] — 2026-11-01 — Fase 3 (Storie e scoperta)

### Aggiunto
- Storie (NIP-40): eventi kind 20/22 con label `mialuna.story` (NIP-32) e
  scadenza a 24 ore; rail circolare sopra il feed raggruppato per autore;
  viewer full-screen con barre di avanzamento, tap avanti/indietro, pressione
  lunga per pausa, swipe tra autori; le Storie scadute spariscono ovunque.
- Composer: modalità Storia (foto o video singolo) con avviso esplicito che
  la scadenza non garantisce la cancellazione.
- Esplora: ricerca universale — hashtag, account via npub (NIP-19), ricerca
  testuale NIP-50 (nei relay che la supportano).
- Filtro Nostr con campo `search` (NIP-50).

### Test
- 7 nuovi test: scadenza Storie, etichette NIP-32, kind 22 per video-Storie,
  serializzazione NIP-50.

## [0.2.0] — 2026-11-01 — Fase 2 (video e Reels)

### Aggiunto
- Player video a schermo intero (`video_player`): controlli, mute, scrubbing,
  indicatore di buffering, retry su errore. Aperto dal feed toccando un video.
- Reels: viewer verticale full-screen con swipe, autoplay del video attivo,
  pausa/reset uscendo dalla pagina, overlay creatore con didascalia
  espandibile e pulsanti like/commento/condivisione/segui.
- Composer: modalità Foto / Video / Reel (selettore), selezione video da
  galleria, pubblicazione kind 21 (video) o kind 22 (reel) con upload Blossom.
- Feed: anteprima video tappabile nelle card.

### Note
- Preload dei reel adiacenti e trim video: iterazione successiva.
- Il caricamento video rispetta i limiti dei server Blossom configurati.

## [0.1.0] — 2026-11-01 — Fase 1 (MVP fotografico, in corso)

### Aggiunto
- Fondamenta Flutter: tema Mialuna (chiaro/scuro), navigazione a 5 tab
  (Home, Esplora, Crea, Reels, Profilo), router con `go_router`.
- Core Nostr: eventi NIP-01, firma BIP-340, NIP-19 (npub/nsec/note),
  pool multi-relay con deduplicazione, backoff esponenziale e verifica firme,
  store in memoria con gestione eventi rimpiazzabili.
- Foto NIP-68 (kind 20): parsing e pubblicazione, caroselli multi-immagine,
  `imeta` con mime/dim/hash/alt, `content-warning` (NIP-36).
- Parsing NIP-71 (kind 21/22/34235/34236) a modello dati.
- Hashtag ufficiale `#mialuna`: applicazione centralizzata, deduplicazione,
  anteprima nel composer (`core/branding`).
- Autenticazione: Amber via NIP-55 (Android, canale nativo Kotlin), nsec con
  storage cifrato e avviso di rischio, modalità ospite read-only.
- Upload Blossom con autorizzazione kind 24242; pubblicazione bloccata se
  un upload fallisce; bozze persistenti offline.
- Esplora: griglia di scoperta e ricerca per hashtag (feed #mialuna).
- Cache locale JSON di eventi e bozze.
- 41 test unitari: NIP-19, bech32, firma/verifica eventi, parsing NIP-68/71,
  hashtag policy, EventStore, filtri, Blossom.

### Noto / limitazioni
- Reels e riproduzione video: Fase 2.
- Storie (NIP-40 UI): Fase 3 (filtro di scadenza già attivo nel feed).
- NIP-46 bunker: interfaccia prevista, implementazione in arrivo.
- NIP-65 relay list, NIP-05, zaps NIP-57, notifiche: Fase 4.
- Cache locale in JSON; migrazione a Drift/SQLite pianificata.
- Build iOS non verificata (serve ambiente Xcode).
