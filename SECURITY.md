# Politica di sicurezza

## Segnalazione vulnerabilità

Per favore **non aprire issue pubbliche** per vulnerabilità di sicurezza.
Contatta i maintainer in privato (vedi README) descrivendo:

- componente coinvolto e versione
- impatto potenziale
- passi per riprodurre (se possibile)

Ci impegniamo a rispondere entro 7 giorni.

## Ambito

- Gestione delle chiavi: le chiavi private non vengono mai loggate né
  trasmesse; il login nsec usa storage cifrato; Amber (NIP-55) tiene la
  chiave fuori dal processo.
- Upload media: l'autorizzazione Blossom (kind 24242) ha scadenza breve.
- Contenuti pubblici: tutto ciò che è pubblicato su relay Nostr è pubblico
  per definizione del protocollo.

## Dipendenze

Le dipendenze sono riesaminate ad ogni release; preferenza per licenze
MIT/Apache/BSD e pacchetti attivamente mantenuti.
