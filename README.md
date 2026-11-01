# Mialuna

**Your moments, under the same moon.**

Mialuna è un social network visuale, open-source e decentralizzato, costruito
su [Nostr](https://github.com/nostr-protocol/nips). Foto, caroselli, video,
Reels e Storie — con l'esperienza familiare di Instagram e senza piattaforme
centralizzate.

> Mialuna è **media-first**: non esistono post di solo testo.

## Stato del progetto

Fase 1 (MVP fotografico) in sviluppo. Vedi [CHANGELOG.md](CHANGELOG.md) e
[docs/ARCHITECTURE.md](docs/ARCHITECTURE.md).

## Funzionalità (Fase 1)

- Feed fotografico NIP-68 (kind 20), caroselli, didascalie con hashtag cliccabili
- Pubblicazione foto con upload Blossom (kind 24242) e hashtag ufficiale `#mialuna`
- Parsing NIP-71 (kind 21/22) — riproduzione video e Reels in Fase 2
- Accesso: Amber (NIP-55, Android), nsec (fallback avanzato), modalità ospite
- Reazioni NIP-25, commenti NIP-22, follow list NIP-02 (modello dati)
- Cache locale offline e bozze persistenti
- Temi chiaro/scuro con la palette Mialuna

## Build

Requisiti: Flutter 3.47+, Android SDK 36, JDK 21.

```bash
flutter pub get
flutter test
flutter analyze
flutter build apk --debug
```

La toolchain è pinnata con [mise](https://mise.jdx.dev/) (`mise.toml`):
`mise install` installa Flutter e Java. L'Android SDK va configurato a parte
(`flutter config --android-sdk <percorso>`).

## Licenza

MIT — vedi [LICENSE](LICENSE).
