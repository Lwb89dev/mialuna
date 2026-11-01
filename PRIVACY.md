# Privacy in Mialuna

Mialuna non ha server propri, non raccoglie analytics, non include tracker né
SDK pubblicitari.

## Cosa è pubblico

Nostr è un protocollo pubblico. Tutto ciò che pubblichi (foto, video,
didascalie, reazioni, commenti, lista dei seguiti) è inviato ai relay che
scegli e può essere letto, copiato e archiviato da chiunque. Tratta ogni
contenuto come permanentemente pubblico.

## Le Storie non sono veramente effimere

Le Storie usano NIP-40 con scadenza di 24 ore: i relay che rispettano lo
standard smettono di distribuirle dopo la scadenza, ma **non possiamo
garantire la cancellazione** da relay, archivi o server media. Chiunque può
salvare o catturare lo schermo.

## Chiavi

- **Amber (consigliato)**: la chiave privata non entra mai in Mialuna.
- **nsec**: salvata solo nello storage cifrato del dispositivo, mai
  trasmessa né loggata. La cancellazione avviene al logout.

## Media

Gli upload vanno ai server Blossom che configuri tu. I metadati EXIF di
geolocalizzazione vengono rimossi di default prima della pubblicazione.
Eliminare un evento Nostr (kind 5) **non elimina** il file media dal server
Blossom: sono operazioni distinte.

## Dati locali

Cache di eventi e bozze restano sul dispositivo e possono essere eliminate
dalle impostazioni.
