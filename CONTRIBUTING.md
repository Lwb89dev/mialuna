# Contribuire a Mialuna

Grazie per l'interesse! Mialuna è open-source (MIT) e accoglie contributi.

## Regole fondamentali

1. **Media-first**: nessun post di solo testo. Kind 1 non entra mai nel feed.
2. `#mialuna` va applicato solo ai post media pubblicati da Mialuna, tramite
   `lib/core/branding/mialuna_tag.dart` (unica fonte di verità, coperta da test).
3. I NIP ufficiali sono la fonte autorevole. Non inventare kind o protocolli
   custom senza documentarli in `docs/nostr-compatibility.md`.
4. Niente dipendenze proprietarie, tracker, analytics o advertising SDK.

## Workflow

```bash
flutter pub get
flutter analyze   # deve restare pulito
flutter test      # tutti i test devono passare
```

- Un commit per cambiamento logico, messaggio in italiano o inglese.
- Le nuove funzionalità di protocollo richiedono test unitari.
- Apri una issue prima di cambiamenti architetturali grandi.
