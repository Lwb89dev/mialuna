// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get syncUpToDate => 'Tutto aggiornato';

  @override
  String get syncFailed => 'Sincronizzazione non riuscita';

  @override
  String get relaysUpdatedFromProfile =>
      'Relay aggiornati dal tuo profilo (NIP-65)';

  @override
  String get relayListPublished => 'Lista relay pubblicata';

  @override
  String get mediaServersUpdatedFromProfile =>
      'Server media aggiornati dal tuo profilo';

  @override
  String get tabHome => 'Home';

  @override
  String get tabDiscover => 'Scopri';

  @override
  String get tabCreate => 'Crea';

  @override
  String get tabReels => 'Reels';

  @override
  String get tabProfile => 'Profilo';

  @override
  String get signInToUploadMedia => 'Accedi per caricare i media.';

  @override
  String get noMediaServer =>
      'Nessun server media configurato. Aggiungine uno nelle impostazioni.';

  @override
  String serverNoResponse(Object server) {
    return '$server: nessuna risposta';
  }

  @override
  String serverUnreachable(Object server, Object error) {
    return '$server: non raggiungibile ($error)';
  }

  @override
  String uploadRejected(Object reason) {
    return 'Caricamento rifiutato — $reason';
  }

  @override
  String noServerAcceptedFile(Object reasons) {
    return 'Nessun server ha accettato il file — $reasons';
  }

  @override
  String get blossomInvalidResponse => 'risposta non valida';

  @override
  String get blossomInvalidFileUrl => 'indirizzo del file non valido';

  @override
  String get blossomServerAlteredFile => 'il server ha modificato il file';

  @override
  String get blossomBadRequest => 'richiesta non valida';

  @override
  String get blossomUnauthorized => 'autorizzazione negata';

  @override
  String get blossomPaymentRequired => 'pagamento richiesto';

  @override
  String get blossomForbidden => 'non consentito';

  @override
  String get blossomLengthRequired => 'dimensione mancante';

  @override
  String get blossomTooLarge => 'file troppo grande';

  @override
  String get blossomUnsupportedType => 'formato non accettato';

  @override
  String get blossomTooManyRequests => 'troppe richieste';

  @override
  String get blossomServerError => 'errore del server';

  @override
  String get cipherInvalidKey => 'Chiave non valida';

  @override
  String get cipherTruncated => 'File cifrato troncato';

  @override
  String get cipherMismatch =>
      'Il file non corrisponde alla chiave: modificato o corrotto';

  @override
  String get sanitizeHeifNeedsAsync =>
      'Formato HEIC/AVIF: la conversione richiede sanitizeAsync';

  @override
  String get sanitizeWebmUnsupported =>
      'Video WebM/MKV non supportato: usa MP4 o MOV così posso rimuovere i metadati prima del caricamento.';

  @override
  String get sanitizeUnknownFormat =>
      'Formato file non riconosciuto: foto JPEG/PNG/WebP/GIF o video MP4/MOV.';

  @override
  String sanitizeLeftovers(Object items) {
    return 'Impossibile rimuovere tutti i metadati ($items): file non caricato.';
  }

  @override
  String sanitizeProcessingFailed(Object error) {
    return 'Impossibile elaborare il file: $error';
  }

  @override
  String get sanitizeJpegInvalid => 'JPEG non valido';

  @override
  String get sanitizeJpegTruncated => 'JPEG troncato';

  @override
  String get sanitizeJpegNoSize => 'JPEG senza dimensioni';

  @override
  String get sanitizeJpegUndecodable => 'JPEG non decodificabile';

  @override
  String get sanitizePngTruncated => 'PNG troncato';

  @override
  String get sanitizePngInvalid => 'PNG non valido';

  @override
  String get sanitizeGifInvalid => 'GIF non valido';

  @override
  String get sanitizeGifTruncated => 'GIF troncato';

  @override
  String get sanitizeWebpTruncated => 'WebP troncato';

  @override
  String get sanitizeWebpInvalid => 'WebP non valido';

  @override
  String get sanitizeMp4Invalid => 'Video MP4/MOV non valido';

  @override
  String get sanitizeConversionFailed => 'Conversione fallita';

  @override
  String get sanitizeHeifUnsupported =>
      'Questo formato (HEIC/AVIF) non può essere convertito su questo dispositivo. Scegli una foto JPEG o PNG.';

  @override
  String get privateMediaNotEncrypted => 'Media non cifrato';

  @override
  String serverReplied(Object status) {
    return 'Il server ha risposto $status';
  }

  @override
  String get fileTooLarge => 'File troppo grande';

  @override
  String get serverFileNotOriginal =>
      'Il file sul server non è quello originale';

  @override
  String get contentMismatch => 'Il contenuto non corrisponde';

  @override
  String get mediaUnreachable => 'Media non raggiungibile';

  @override
  String get amberInvalidKey => 'Amber ha restituito una chiave non valida';

  @override
  String get amberNoKey => 'Amber non ha restituito una chiave';

  @override
  String get amberRequestRejected => 'Richiesta rifiutata in Amber';

  @override
  String get amberAndroidOnly => 'Amber è disponibile solo su Android';

  @override
  String get amberEmptySignature => 'Amber ha restituito una firma vuota';

  @override
  String get amberSignRejected => 'Firma rifiutata in Amber';

  @override
  String get amberTimeout => 'Amber non ha risposto in tempo';

  @override
  String get amberEmptyResponse => 'Amber ha restituito una risposta vuota';

  @override
  String get bunkerInvalidUrl => 'URL bunker non valido';

  @override
  String get bunkerNoRelay => 'Il bunker non indica alcun relay';

  @override
  String get bunkerWebAuth =>
      'Il bunker richiede un\'autorizzazione web (auth_url non supportata)';

  @override
  String get bunkerInvalidKey =>
      'Il bunker non ha restituito una chiave valida';

  @override
  String get signerInvalidResponse =>
      'Il firmatario ha restituito un evento firmato non valido';

  @override
  String get bunkerTimeout => 'Timeout dal bunker';

  @override
  String get nwcInvalidUri => 'URI NWC non valido';

  @override
  String get nwcNoRelay => 'L\'URI NWC non indica alcun relay';

  @override
  String get nwcNoSecret => 'L\'URI NWC non contiene un secret valido';

  @override
  String get nwcTimeout => 'Timeout dal wallet';

  @override
  String get signerNoPrivateMessages =>
      'Questo tipo di accesso non supporta i messaggi privati';

  @override
  String get zapNotSupported => 'Questo indirizzo non supporta gli zap Nostr';

  @override
  String zapAmountOutOfRange(Object min, Object max) {
    return 'Importo fuori dai limiti ($min–$max sats)';
  }

  @override
  String get commentNotSent => 'Commento non inviato. Riprova più tardi.';

  @override
  String get comments => 'Commenti';

  @override
  String get noCommentsYet => 'Nessun commento ancora.';

  @override
  String get signInToComment => 'Accedi per commentare.';

  @override
  String get addComment => 'Aggiungi un commento…';

  @override
  String get signInToPublish => 'Accedi per pubblicare.';

  @override
  String get addMediaFirst =>
      'Aggiungi almeno una foto o un video prima di pubblicare.';

  @override
  String get removingMetadata => 'Rimozione dei metadati…';

  @override
  String uploadingProgress(Object current, Object total) {
    return 'Caricamento $current di $total…';
  }

  @override
  String get creatingPreview => 'Creazione dell\'anteprima…';

  @override
  String uploadFailed(Object error) {
    return 'Caricamento non riuscito: $error';
  }

  @override
  String get publishing => 'Pubblicazione…';

  @override
  String noRelayAcceptedPost(Object reason) {
    return 'Nessun relay ha accettato il post$reason. Il contenuto resta in bozze.';
  }

  @override
  String get privateNeedsKeySigner =>
      'Questo tipo di accesso non supporta i contenuti privati. Usa Amber, un bunker o la chiave locale.';

  @override
  String get closeFriendsListEmptyAddSomeone =>
      'La lista degli amici più stretti è vuota: aggiungi qualcuno.';

  @override
  String get fileOver100Mb =>
      'Il file supera 100 MB: per gli amici più stretti è il massimo (viene cifrato per intero sul telefono).';

  @override
  String get encryptingOnPhone => 'Cifratura sul telefono…';

  @override
  String noServerAcceptedEncrypted(Object details) {
    return 'Nessuno dei tuoi server media ha accettato il file cifrato. Non lo pubblico in chiaro. Aggiungi nelle impostazioni un server che accetti file cifrati (ad esempio cdn.hzrd149.com). $details';
  }

  @override
  String get sendingToFriends => 'Invio agli amici…';

  @override
  String sendingToFriendsProgress(Object done, Object total) {
    return 'Invio agli amici $done/$total…';
  }

  @override
  String noFriendReceivedPost(Object reason) {
    return 'Nessun amico ha ricevuto il post$reason. Il contenuto resta in bozze.';
  }

  @override
  String sentToCloseFriends(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Inviato a $count amici più stretti 🔒',
      one: 'Inviato a 1 amico più stretto 🔒',
    );
    return '$_temp0';
  }

  @override
  String sentToFriendsWithMisses(int delivered, Object missed) {
    String _temp0 = intl.Intl.pluralLogic(
      delivered,
      locale: localeName,
      other: 'Inviato a $delivered amici.',
      one: 'Inviato a 1 amico.',
    );
    return '$_temp0 $missed non lo hanno ricevuto (messaggi privati non attivi).';
  }

  @override
  String get altText => 'Testo alternativo';

  @override
  String get altTextHint => 'Descrivi il contenuto per chi non può vederlo…';

  @override
  String get cancel => 'Annulla';

  @override
  String get save => 'Salva';

  @override
  String get momentPublished => 'Momento pubblicato ✨';

  @override
  String get newMoment => 'Nuovo momento';

  @override
  String get publish => 'Pubblica';

  @override
  String get guestMode => 'Modalità ospite';

  @override
  String get signInToPostMoments => 'Accedi per pubblicare i tuoi momenti.';

  @override
  String get signIn => 'Accedi';

  @override
  String get kindPhoto => 'Foto';

  @override
  String get kindVideo => 'Video';

  @override
  String get kindReel => 'Reel';

  @override
  String get kindStory => 'Storia';

  @override
  String get storyExpiryNote =>
      'Le Storie scadono dopo 24 ore sui relay che rispettano NIP-40, ma possono comunque essere salvate o archiviate da altri.';

  @override
  String get fromGallery => 'Dalla galleria';

  @override
  String get galleryLongPressVideo => 'Galleria (tieni premuto per video)';

  @override
  String get addVideo => 'Aggiungi video';

  @override
  String get camera => 'Fotocamera';

  @override
  String get exifRemovedNote =>
      'I metadati di posizione (EXIF) vengono rimossi automaticamente.';

  @override
  String get writeCaption => 'Scrivi una didascalia…';

  @override
  String get privatePostNote =>
      'Post privato: niente hashtag pubblici, non si trova con la ricerca.';

  @override
  String willPublishAs(Object caption) {
    return 'Verrà pubblicato come: \"$caption\"';
  }

  @override
  String get tapThumbnailForAlt =>
      'Tocca una miniatura per aggiungere il testo alternativo.';

  @override
  String get sensitiveContent => 'Contenuto sensibile';

  @override
  String get sensitiveContentNote =>
      'Il post sarà oscurato da un avviso (NIP-36).';

  @override
  String get uploadingMedia => 'Caricamento media…';

  @override
  String get audiencePublic => 'Pubblico';

  @override
  String get closeFriends => 'Amici più stretti';

  @override
  String get signerCannotPublishCloseFriends =>
      'Con questo accesso non puoi pubblicare per gli amici più stretti: usa Amber, un bunker o la chiave locale.';

  @override
  String get closeFriendsEmptyPrompt =>
      'La tua lista è vuota: aggiungi chi può vedere questo post.';

  @override
  String onlyYourCloseFriendsSee(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Lo vedranno solo i tuoi $count amici più stretti. Foto e video vengono cifrati sul telefono prima di essere caricati.',
      one: 'Lo vedrà solo il tuo 1 amico più stretto. Foto e video vengono cifrati sul telefono prima di essere caricati.',
    );
    return '$_temp0';
  }

  @override
  String get addFriends => 'Aggiungi amici';

  @override
  String get manageList => 'Gestisci la lista';

  @override
  String get edit => 'Modifica';

  @override
  String get reset => 'Reimposta';

  @override
  String get apply => 'Applica';

  @override
  String get cropFree => 'Libero';

  @override
  String get cropOriginal => 'Originale';

  @override
  String get rotate => 'Ruota';

  @override
  String get flip => 'Rifletti';

  @override
  String get brightness => 'Luminosità';

  @override
  String get contrast => 'Contrasto';

  @override
  String get saturation => 'Saturazione';

  @override
  String postsByAuthor(Object author) {
    return 'Post di $author…';
  }

  @override
  String get searchHint => 'Cerca persone, hashtag o parole…';

  @override
  String get clear => 'Cancella';

  @override
  String get recent => 'Recenti';

  @override
  String get searchDependsOnRelays =>
      'La ricerca dipende dai relay configurati: i risultati possono essere parziali.';

  @override
  String get recentPostsEverywhere =>
      'Post recenti da tutta la rete, anche da chi non segui.';

  @override
  String get noResultsOnRelays => 'Nessun risultato sui relay configurati.';

  @override
  String get noRecentPostsFromFollowed => 'Nessun post recente da chi segui.';

  @override
  String get noMomentsFound =>
      'Nessun momento trovato sui relay. Controlla la connessione.';

  @override
  String get loadFailed => 'Caricamento non riuscito';

  @override
  String get notifications => 'Notifiche';

  @override
  String get messages => 'Messaggi';

  @override
  String get homeEmptyFollowsNobody =>
      'Qui compaiono i post di chi segui.\nNon segui ancora nessuno: scopri persone e profili interessanti.';

  @override
  String get discoverPeople => 'Scopri persone';

  @override
  String get homeEmpty =>
      'Nessun momento ancora.\nScorri per aggiornare o pubblica il tuo primo scatto.';

  @override
  String get retry => 'Riprova';

  @override
  String get seenEverything => 'Hai visto tutto per ora ✨';

  @override
  String get discoverMoreProfiles => 'Scopri altri profili';

  @override
  String get feedFollowing => 'Seguiti';

  @override
  String get signInToSeeFollowed => 'Accedi per vedere i post di chi segui';

  @override
  String get videoPreview => 'Anteprima del video';

  @override
  String get cannotOpenPrivateVideo => 'Impossibile aprire il video privato';

  @override
  String get cannotPlayVideo => 'Impossibile riprodurre il video';

  @override
  String get pauseVideo => 'Metti in pausa il video';

  @override
  String get playVideo => 'Riproduci il video';

  @override
  String errorTapToRetry(Object error) {
    return '$error — tocca per riprovare';
  }

  @override
  String get soundOn => 'Attiva l\'audio';

  @override
  String get soundOff => 'Disattiva l\'audio';

  @override
  String get postImage => 'Immagine del post';

  @override
  String get imageUnavailable => 'Immagine non disponibile';

  @override
  String errorTapToRetryNewline(Object message) {
    return '$message\nTocca per riprovare';
  }

  @override
  String get cannotOpenPrivateContent =>
      'Non riesco ad aprire questo contenuto privato';

  @override
  String get privateImage => 'Immagine privata';

  @override
  String get invalidImage => 'Immagine non valida';

  @override
  String get more => 'Altro';

  @override
  String get removeFromSaved => 'Rimuovi dai salvati';

  @override
  String get copyLink => 'Copia link';

  @override
  String get muteAuthor => 'Silenzia autore';

  @override
  String get blockAuthor => 'Blocca autore';

  @override
  String get report => 'Segnala';

  @override
  String get like => 'Mi piace';

  @override
  String get sendInMessage => 'Invia in un messaggio';

  @override
  String get zapOptional => 'Zap (opzionale)';

  @override
  String get closeFriendsOnlyNote =>
      'Visibile solo agli amici più stretti. Like e risposte vanno solo all\'autore.';

  @override
  String get likeFailed => 'Non sono riuscito a inviare il like';

  @override
  String get nostrLinkCopied => 'Link Nostr copiato negli appunti';

  @override
  String get authorMuted => 'Autore silenziato';

  @override
  String get authorBlocked => 'Autore bloccato';

  @override
  String get reportSent => 'Segnalazione inviata (NIP-56)';

  @override
  String get signInToReport => 'Accedi per segnalare';

  @override
  String minutesAgo(Object minutes) {
    return '$minutes min fa';
  }

  @override
  String get show => 'Mostra';

  @override
  String get chatEmptyHint =>
      'Scrivi il primo messaggio.\nÈ cifrato: lo vedete solo voi due.';

  @override
  String get messageHint => 'Messaggio…';

  @override
  String get send => 'Invia';

  @override
  String get notSentSuffix => ' non inviato';

  @override
  String get contentUnavailable =>
      'Contenuto non disponibile (scaduto o non trovato sui relay)';

  @override
  String get signInToSendPrivateMessages =>
      'Accedi per inviare messaggi privati.';

  @override
  String get cannotMessageYourself => 'Non puoi scrivere a te stesso.';

  @override
  String get recipientNoPrivateMessages =>
      'Questa persona non ha ancora attivato i messaggi privati.';

  @override
  String noRecipientRelayAccepted(Object reason) {
    return 'Nessun relay del destinatario ha accettato il messaggio$reason.';
  }

  @override
  String sendFailed(Object error) {
    return 'Invio non riuscito: $error';
  }

  @override
  String get signInToReadMessages =>
      'Accedi per leggere e inviare messaggi privati.';

  @override
  String get signerNoPrivateMessagesLong =>
      'Con questo tipo di accesso non è possibile usare i messaggi privati. Accedi con Amber, un bunker o la chiave locale.';

  @override
  String get inboxEmpty =>
      'Nessuna conversazione.\nTocca la matita per scrivere a qualcuno, oppure inoltra un momento con l\'icona ✈ sotto ogni post.';

  @override
  String get newMessage => 'Nuovo messaggio';

  @override
  String get privateMessagesEnabled => 'Messaggi privati attivati';

  @override
  String get enableMessagesFailed => 'Non sono riuscito ad attivarli. Riprova.';

  @override
  String get enablePrivateMessages => 'Attiva i messaggi privati';

  @override
  String enablePrivateMessagesExplain(Object count) {
    return 'Per ricevere messaggi serve indicare a quali relay devono arrivare. Pubblico una piccola lista (NIP-17) con $count relay predefiniti: puoi cambiarla in seguito. I messaggi restano cifrati: i relay non vedono né chi scrive né il testo.';
  }

  @override
  String get turnOn => 'Attiva';

  @override
  String get searchByNameOrUsername => 'Cerca per nome o username';

  @override
  String get searching => 'Cerco…';

  @override
  String get noOneWithNameHint =>
      'Nessuno con questo nome. Prova con meno lettere o con un indirizzo come nome@dominio.it.';

  @override
  String get sent => 'Inviato';

  @override
  String sentToPeople(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Inviato a $count persone',
      one: 'Inviato a 1 persona',
    );
    return '$_temp0';
  }

  @override
  String sentToPeopleWithFailure(int count, Object failure) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Inviato a $count persone. $failure',
      one: 'Inviato a 1 persona. $failure',
    );
    return '$_temp0';
  }

  @override
  String get signerNoPrivateMessagesShort =>
      'Con questo tipo di accesso non puoi usare i messaggi privati.';

  @override
  String get followToStartOrSearch =>
      'Segui qualcuno per iniziare, oppure cerca per nome.';

  @override
  String get addMessage => 'Aggiungi un messaggio…';

  @override
  String sendWithCount(Object count) {
    return 'Invia ($count)';
  }

  @override
  String get linkCopied => 'Link copiato negli appunti';

  @override
  String get noNotifications => 'Nessuna notifica al momento.';

  @override
  String get notificationsDependOnRelays =>
      'Le notifiche dipendono dai relay: potrebbero non essere complete.';

  @override
  String get reactedToYourMoment => 'ha reagito a un tuo momento';

  @override
  String commentedText(Object text) {
    return 'ha commentato: $text';
  }

  @override
  String sentYouSats(Object sats, Object comment) {
    return 'ti ha inviato $sats sats$comment';
  }

  @override
  String get sentYouZap => 'ti ha inviato uno zap';

  @override
  String get startedFollowingYou => 'ha iniziato a seguirti';

  @override
  String get amberNotFound => 'Amber non trovato';

  @override
  String get amberExplain =>
      'Amber è un signer Nostr che custodisce la tua chiave privata fuori da Mialuna. Installalo e riprova.';

  @override
  String get downloadFromFdroid => 'Scarica da F-Droid';

  @override
  String get continueWithAmber => 'Continua con Amber';

  @override
  String get amberRecommended =>
      'Consigliato: la chiave privata resta al sicuro in Amber.';

  @override
  String get amberNotDetected =>
      'Amber non rilevato: installalo per l\'accesso consigliato.';

  @override
  String get exploreWithoutAccount => 'Esplora senza account';

  @override
  String get remoteBunker => 'Bunker remoto (NIP-46)';

  @override
  String get invalidBunkerUrlDot => 'URL bunker non valido.';

  @override
  String get connectBunker => 'Connetti bunker';

  @override
  String get advancedNsec => 'Accesso avanzato (nsec)';

  @override
  String get nsecWarning =>
      'Attenzione: incollare la chiave privata è rischioso. Non condividerla mai con nessuno. Su Android preferisci Amber.';

  @override
  String get invalidNsec => 'Chiave nsec non valida.';

  @override
  String get signInWithNsec => 'Accedi con nsec';

  @override
  String get tagline => 'I tuoi momenti, sotto la stessa luna.';

  @override
  String get skip => 'Salta';

  @override
  String get permissionsAndWallet => 'Permessi e wallet';

  @override
  String get permissionsExplain =>
      'Servono solo a farti pubblicare e ricevere notifiche. Puoi cambiarli in qualsiasi momento dalle impostazioni di sistema.';

  @override
  String get photosAndVideos => 'Foto e video';

  @override
  String get toUploadYourMoments => 'Per caricare i tuoi momenti';

  @override
  String get allow => 'Consenti';

  @override
  String get reactionsCommentsZaps => 'Reazioni, commenti e zap';

  @override
  String get lightningWalletOptional => 'Wallet Lightning (opzionale)';

  @override
  String get nwcExplain =>
      'Collega un wallet Nostr Wallet Connect per inviare zap senza lasciare l\'app.';

  @override
  String get walletConnected => 'Wallet collegato';

  @override
  String get disconnect => 'Scollega';

  @override
  String get connectWallet => 'Collega wallet';

  @override
  String get getStarted => 'Inizia';

  @override
  String get welcome1 =>
      'Mialuna è un social network visivo: foto, video, Reels e Storie — mai solo testo.';

  @override
  String get welcome2 =>
      'Funziona su Nostr, un protocollo aperto: la tua identità è una chiave che possiedi, non un account che un\'azienda può toglierti. Niente pubblicità, niente tracker, nessun server centrale.';

  @override
  String get welcome3 =>
      'Condividi la tua luce con persone ovunque, da qualsiasi app che parli lo stesso linguaggio aperto.';

  @override
  String onboardingWot(int min) {
    return 'La rete di fiducia è sempre attiva. Al primo avvio Mialuna legge chi segui e costruisce il feed di Scopri da quella rete: tu, le persone che segui e chi è seguito da almeno $min di loro. Agli avvii successivi il feed è già pronto.';
  }

  @override
  String get publicAndPrivate => 'Pubblico e privato';

  @override
  String get publicAndPrivateIntro =>
      'Mialuna è costruita su Nostr, una rete aperta. Quello che pubblichi è pubblico: i post, le foto e i video restano visibili a chiunque abbia il link, anche fuori da Mialuna.';

  @override
  String get closeFriendsExplain1 =>
      'Solo le persone di questa lista ricevono i tuoi post, le tue storie e i tuoi video \"Amici più stretti\". La lista è dentro il post, non va scelta ogni volta.';

  @override
  String get closeFriendsExplain2 =>
      'Foto e video vengono cifrati sul tuo telefono prima di essere caricati. I server di file (Blossom) non cifrano nulla da soli: per questo lo fa Mialuna, e il server vede solo dati illeggibili. Chi trova l\'indirizzo del file non può aprirlo.';

  @override
  String get closeFriendsExplain3 =>
      'Non è una garanzia assoluta: chi riceve può fare uno screenshot, e togliere un amico vale solo per i post futuri.';

  @override
  String get closeFriendsExplain4 =>
      'Ogni amico deve usare Mialuna con i messaggi privati attivi. Gli altri client Nostr non mostrano questi post.';

  @override
  String get closeFriendsExplain5 =>
      'I post pubblici restano pubblici: i loro file sono visibili a chiunque abbia il link.';

  @override
  String get closeFriendsExplain6 =>
      'Se nessuno dei tuoi server accetta file cifrati, il post non viene pubblicato: mai in chiaro.';

  @override
  String get addToCloseFriends => 'Aggiungi agli amici più stretti';

  @override
  String maxFriendsReached(Object max, Object added) {
    return 'Massimo $max amici: ne ho aggiunti $added.';
  }

  @override
  String get add => 'Aggiungi';

  @override
  String get signInToCreateList => 'Accedi per creare la tua lista.';

  @override
  String get signerNoCloseFriends =>
      'Con questo tipo di accesso non è possibile usare gli amici più stretti. Accedi con Amber, un bunker o la chiave locale.';

  @override
  String peopleOfMax(Object count, Object max) {
    return '$count / $max persone';
  }

  @override
  String get noOneYet => 'Nessuno ancora.';

  @override
  String get addPeople => 'Aggiungi persone';

  @override
  String get friendNoPrivateMessagesWarning =>
      'Non ha attivato i messaggi privati: non riceverà i tuoi post';

  @override
  String get removeFromList => 'Togli dalla lista';

  @override
  String get noOneWithThisName => 'Nessuno con questo nome.';

  @override
  String get signInToSendPrivateContent =>
      'Accedi per inviare contenuti privati.';

  @override
  String get reasonNoPrivateMessages => 'non ha attivato i messaggi privati';

  @override
  String get reasonNoRelayAnswered => 'nessun relay ha risposto';

  @override
  String get profileUpdated => 'Profilo aggiornato';

  @override
  String get noRelayAcceptedRetry =>
      'Nessun relay ha accettato. Riprova più tardi.';

  @override
  String get editProfile => 'Modifica profilo';

  @override
  String get fieldName => 'Nome';

  @override
  String get fieldBio => 'Bio';

  @override
  String get fieldAvatarUrl => 'URL avatar';

  @override
  String get fieldNip05 => 'NIP-05 (es. tu@esempio.com)';

  @override
  String get browsingAsGuest => 'Stai navigando come ospite';

  @override
  String get signInToInteract => 'Accedi per pubblicare, seguire e interagire.';

  @override
  String get settings => 'Impostazioni';

  @override
  String get signOut => 'Esci';

  @override
  String get npubCopied => 'npub copiato';

  @override
  String get copyNpub => 'Copia npub';

  @override
  String get mute => 'Silenzia';

  @override
  String get block => 'Blocca';

  @override
  String get posts => 'Post';

  @override
  String get saved => 'Salvati';

  @override
  String get nothingPublishedYet => 'Non hai ancora pubblicato nulla.';

  @override
  String get noPostsOnRelays => 'Nessun post trovato sui relay.';

  @override
  String get noReelsPublished => 'Nessun reel pubblicato.';

  @override
  String get noReelsOnRelays => 'Nessun reel trovato sui relay.';

  @override
  String get noSavedPosts => 'Nessun post salvato.';

  @override
  String get followingButton => 'Segui già';

  @override
  String get follow => 'Segui';

  @override
  String get messageButton => 'Messaggio';

  @override
  String get loginLocalKey => 'Chiave locale';

  @override
  String get loginGuest => 'Ospite';

  @override
  String get followUpdateFailed =>
      'Impossibile aggiornare i seguiti ora. Riprova.';

  @override
  String get noReelsComeBack =>
      'Ancora nessun reel da chi segui o dalla tua rete di fiducia.\nTorna presto!';

  @override
  String get followUpdateFailedShort => 'Impossibile aggiornare i seguiti ora';

  @override
  String get needOneReadRelay => 'Serve almeno un relay di lettura.';

  @override
  String get listSavedLocally =>
      'Lista salvata su questo dispositivo, non pubblicata.';

  @override
  String get noRelayAcceptedList =>
      'Nessun relay ha accettato la lista: la riproverò più tardi.';

  @override
  String relayListPublishedTo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Lista relay pubblicata su $count relay',
      one: 'Lista relay pubblicata su 1 relay',
    );
    return '$_temp0';
  }

  @override
  String get mediaServersUpdated => 'Server media aggiornati';

  @override
  String get appearance => 'Aspetto';

  @override
  String get publishingSettings => 'Pubblicazione';

  @override
  String get addMialunaHashtag => 'Aggiungi #mialuna';

  @override
  String get addMialunaHashtagNote =>
      'Aggiungi l\'hashtag ufficiale ai post e alle storie pubbliche. Puoi disattivarlo in qualsiasi momento.';

  @override
  String get themeLight => 'Chiaro';

  @override
  String get themeDark => 'Scuro';

  @override
  String get themeSystem => 'Sistema';

  @override
  String get relays => 'Relay';

  @override
  String get relaysExplainSignedOut =>
      'I relay memorizzano e distribuiscono i contenuti. Accedi per usare automaticamente la tua lista (NIP-65).';

  @override
  String get relaysExplainSynced =>
      'La lista è sincronizzata con il tuo profilo Nostr (NIP-65): ogni modifica viene pubblicata e vale su tutte le tue app.';

  @override
  String get syncing => 'Sincronizzazione in corso…';

  @override
  String get waitingFirstSync => 'In attesa della prima sincronizzazione';

  @override
  String get syncNow => 'Sincronizza ora';

  @override
  String get addRelay => 'Aggiungi relay';

  @override
  String get restoreDefaultRelays => 'Ripristina relay predefiniti';

  @override
  String get createYourList => 'Crea la tua lista';

  @override
  String peopleCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count persone',
      one: '1 persona',
    );
    return '$_temp0';
  }

  @override
  String get closeFriendsSettingsNote =>
      'Post, storie e video visibili solo a loro, con foto e video cifrati.';

  @override
  String get mediaServersBlossom => 'Server media (Blossom)';

  @override
  String get mediaServersExplain =>
      'Foto e video vengono caricati solo su questi server, nell\'ordine indicato: il primo che li accetta vince. Prima del caricamento vengono rimossi EXIF e posizione.';

  @override
  String get primary => 'Principale';

  @override
  String get makePrimary => 'Rendi principale';

  @override
  String get remove => 'Rimuovi';

  @override
  String get addServer => 'Aggiungi server';

  @override
  String get moderation => 'Moderazione';

  @override
  String get moderationExplain =>
      'Silenziati e hashtag nascosti sono sincronizzati via NIP-51. I bloccati restano solo su questo dispositivo.';

  @override
  String get mutedAuthors => 'Autori silenziati';

  @override
  String get noMutedAuthors => 'Nessun autore silenziato';

  @override
  String get blockedAuthors => 'Autori bloccati';

  @override
  String get noBlockedAuthors => 'Nessun autore bloccato';

  @override
  String get hiddenHashtags => 'Hashtag nascosti';

  @override
  String get noHiddenHashtags => 'Nessun hashtag nascosto';

  @override
  String get hashtagToHide => '#hashtag da nascondere';

  @override
  String get storage => 'Archiviazione';

  @override
  String get clearCache => 'Svuota cache eventi e bozze';

  @override
  String get cacheCleared => 'Cache svuotata';

  @override
  String get reviewIntro => 'Rivedi la guida iniziale';

  @override
  String get reviewIntroSubtitle =>
      'Cosa è pubblico, cosa è privato e i limiti degli amici più stretti.';

  @override
  String noLightningWalletCopied(Object address) {
    return 'Nessun wallet Lightning trovato: indirizzo copiato ($address)';
  }

  @override
  String get about => 'Informazioni';

  @override
  String aboutText(Object version) {
    return 'Mialuna $version — I tuoi momenti, sotto la stessa luna.\nOpen source (MIT). github.com/Lwb89dev/mialuna';
  }

  @override
  String get invalidRelayAddress => 'Indirizzo non valido: usa wss://…';

  @override
  String get invalidServerAddress => 'Indirizzo non valido: usa https://…';

  @override
  String get relayRead => 'Lettura';

  @override
  String get relayWrite => 'Scrittura';

  @override
  String get support => 'Supporto';

  @override
  String get supportText =>
      'Mialuna è gratuita, senza pubblicità e non ti traccia. Se ti piace, puoi inviare qualche sat sulla Lightning Network.';

  @override
  String get donateWithLightning => 'Dona con Lightning';

  @override
  String get authorNoZaps => 'Questo autore non accetta zap';

  @override
  String get sendZap => 'Invia uno zap ⚡';

  @override
  String get amountInSats => 'Importo in sat';

  @override
  String minMaxSats(Object min, Object max) {
    return 'min $min – max $max';
  }

  @override
  String get zap => 'Zap';

  @override
  String get signInToZap => 'Accedi per inviare zap';

  @override
  String zapSent(Object sats) {
    return 'Zap da $sats sats inviato ⚡';
  }

  @override
  String nwcPaymentFailed(Object error) {
    return 'Pagamento NWC fallito: $error';
  }

  @override
  String get noLightningWallet => 'Nessun wallet Lightning trovato';

  @override
  String storiesRailLabel(Object state) {
    return 'Storie, $state';
  }

  @override
  String get close => 'Chiudi';

  @override
  String hoursAgo(int hours) {
    return '$hours h fa';
  }

  @override
  String daysAgo(int days) {
    return '$days g fa';
  }

  @override
  String get now => 'adesso';

  @override
  String get youPrefix => 'Tu: ';

  @override
  String get storiesStateUnseen => 'da guardare';

  @override
  String get storiesStateSeen => 'già viste';

  @override
  String weekdayShort(String day) {
    String _temp0 = intl.Intl.selectLogic(day, {
      'mon': 'lun',
      'tue': 'mar',
      'wed': 'mer',
      'thu': 'gio',
      'fri': 'ven',
      'sat': 'sab',
      'sun': 'dom',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get sharedAMoment => 'Ha condiviso un momento';

  @override
  String get blossomOtherError => 'errore';

  @override
  String get languageTitle => 'Lingua';

  @override
  String get languageSystem => 'Sistema';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageItalian => 'Italiano';

  @override
  String get cannotEditPhoto => 'Questa foto non si può modificare qui.';

  @override
  String notificationsNew(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count nuove notifiche',
      one: '1 nuova notifica',
    );
    return '$_temp0';
  }

  @override
  String messagesUnread(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count messaggi non letti',
      one: '1 messaggio non letto',
    );
    return '$_temp0';
  }

  @override
  String get done => 'Fatto';

  @override
  String get storyAddText => 'Aggiungi testo';

  @override
  String get storyEditText => 'Modifica testo';

  @override
  String get storyTextHint => 'Scrivi qualcosa… gli #hashtag sono cliccabili';

  @override
  String get storyTextsHelp =>
      'Tocca la foto per scrivere. Trascina per spostare, pizzica per ingrandire e ruotare, tocca un testo per modificarlo.';

  @override
  String storyTextsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count testi',
      one: '1 testo',
      zero: 'Nessun testo',
    );
    return '$_temp0';
  }

  @override
  String get storyFontClassic => 'Classico';

  @override
  String get storyFontBold => 'Grassetto';

  @override
  String get storyFontSerif => 'Serif';

  @override
  String get storyFontMono => 'Mono';

  @override
  String get storyFontItalic => 'Corsivo';

  @override
  String get storyTextBackground => 'Sfondo del testo';

  @override
  String get storyTextColor => 'Colore del testo';

  @override
  String storyTextLimit(int max) {
    return 'Puoi aggiungere al massimo $max testi.';
  }

  @override
  String get wotTitle => 'Rete di fiducia';

  @override
  String get wotEnable => 'La rete di fiducia è sempre attiva';

  @override
  String wotExplain(int min) {
    return 'Sempre attiva. Scopri mostra solo questa rete: tu, le persone che segui e chi è seguito da almeno $min di loro. La stessa rete nasconde commenti, notifiche, post privati e messaggi di tutti gli altri. Viene calcolata su questo telefono dalle liste dei follow pubbliche al primo avvio; gli avvii successivi la riusano. Non viene inviato nulla a nessun server.';
  }

  @override
  String get wotRefresh => 'Aggiorna la rete ora';

  @override
  String get wotStatusIdle =>
      'Non ancora costruita. Viene calcolata al primo avvio dell\'app.';

  @override
  String get wotBuildingTitle => 'Costruzione del feed di Scopri';

  @override
  String get wotBuildingBody =>
      'Sto leggendo chi seguono le persone che segui, e preparo Scopri.';

  @override
  String get wotDiscoverHint =>
      'Solo la tua rete di fiducia: chi segui e chi è seguito da abbastanza di loro.';

  @override
  String get wotDiscoverSignIn =>
      'Scopri mostra la tua rete di fiducia. Accedi e, la prima volta, Mialuna legge chi segui e costruisce questo feed. Agli avvii successivi lo riusa.';

  @override
  String get wotDiscoverEmpty =>
      'Ancora nessun post dalla tua rete di fiducia.';

  @override
  String wotStatusDiscovering(int done, int total) {
    return 'Controllo chi seguono i tuoi follow… $done di $total';
  }

  @override
  String wotStatusComplete(int direct, int indirect, Object when) {
    return 'La tua rete: $direct persone che segui più $indirect seguite da abbastanza di loro. Aggiornata $when.';
  }

  @override
  String wotStatusFailed(Object reason) {
    return 'Impossibile calcolare la rete: $reason';
  }

  @override
  String get wotNoFollows => 'non segui ancora nessuno';

  @override
  String get messageRequests => 'Richieste di messaggi';

  @override
  String messageRequestsSubtitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count conversazioni da fuori della tua rete di fiducia',
      one: '1 conversazione da fuori della tua rete di fiducia',
    );
    return '$_temp0';
  }

  @override
  String get messageRequestsHint =>
      'Da persone fuori dalla tua rete di fiducia. Non contano come non lette. Rispondi per spostare una conversazione nella posta in arrivo.';

  @override
  String get storyViewsSetting => 'Fai sapere che ho visto le loro storie';

  @override
  String get storyViewsSettingExplain =>
      'Quando guardi una storia, all\'autore arriva una ricevuta cifrata che solo lui può leggere. Riporta il tuo nome accanto al suo; i relay non vedono nulla. Se non può essere consegnata, viene conservata e riprovata più tardi. Disattivalo per guardare senza avvisare nessuno: le ricevute non ancora inviate vengono scartate (una già consegnata non si può ritirare).';

  @override
  String storySeenBy(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Visto da $count persone',
      one: 'Visto da 1 persona',
      zero: 'Nessuna visualizzazione',
    );
    return '$_temp0';
  }

  @override
  String get storyViewsEmpty =>
      'Nessuno ha ancora guardato questa storia, oppure le ricevute non ti sono arrivate.';

  @override
  String get storyViewsHint =>
      'Mandano la ricevuta solo le persone che lo consentono, quindi il numero reale può essere più alto.';

  @override
  String get systemNotifications => 'Notifiche di sistema';

  @override
  String get systemNotificationsExplain =>
      'Mostra una notifica sul telefono quando arriva qualcosa di nuovo mentre Mialuna è in background. I messaggi privati non mostrano mai il testo, nemmeno nella schermata di blocco. Android mette in pausa le app che restano a lungo in background, quindi le notifiche arrivano finché Mialuna è ancora in esecuzione.';

  @override
  String get systemNotificationsBlocked =>
      'Le notifiche sono disattivate per Mialuna nelle impostazioni del telefono.';

  @override
  String get systemNotificationsOpenSettings => 'Apri impostazioni';

  @override
  String get systemNotificationsBattery =>
      'Android mette in pausa le app pochi minuti dopo lo spegnimento dello schermo e le notifiche si fermano con loro. Per continuare a riceverle, imposta la batteria di Mialuna su “Nessuna restrizione”.';

  @override
  String get systemNotificationsBatteryAction => 'Apri impostazioni batteria';

  @override
  String get newFollowersSetting => 'Mostra i nuovi follower';

  @override
  String get newFollowersSettingExplain =>
      'I nuovi follower compaiono nelle notifiche e sul telefono. Disattivalo se qualcuno ti riempie di follow: Mi piace, commenti e zap continuano a comparire.';

  @override
  String get systemNotificationMessage => 'ti ha scritto un messaggio privato';

  @override
  String get systemNotificationNewMessage => 'Nuovo messaggio privato';

  @override
  String get systemNotificationNew => 'Nuova notifica';

  @override
  String get notificationChannelSocial => 'Reazioni, commenti, zap e follower';

  @override
  String get notificationChannelMessages => 'Messaggi privati';

  @override
  String get zapInvoiceMismatch =>
      'La fattura non corrisponde all\'importo scelto. Non è stato pagato nulla.';

  @override
  String get storyYourStory => 'La tua storia';

  @override
  String get storyNew => 'Nuova storia';

  @override
  String get storyAddSemantics => 'Aggiungi alla tua storia';

  @override
  String storyOwnRailLabel(int count, Object state) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count storie',
      one: '1 storia',
    );
    return 'La tua storia, $_temp0, $state';
  }

  @override
  String get storyTextSize => 'Dimensione del testo';

  @override
  String get storyPickPrompt => 'Scegli una foto o un video per la tua storia';

  @override
  String get storyEditPhoto => 'Modifica foto';

  @override
  String get storyCaption => 'Didascalia';

  @override
  String get storyDiscardTitle => 'Scartare questa storia?';

  @override
  String get storyDiscard => 'Scarta';

  @override
  String get storyShare => 'Condividi';

  @override
  String get storyShared => 'Storia condivisa';

  @override
  String get deletePost => 'Elimina';

  @override
  String get deletePostTitle => 'Eliminare questo post?';

  @override
  String get deleteStoryTitle => 'Eliminare questa storia?';

  @override
  String get deletePostBody =>
      'Mialuna chiederà ai tuoi relay di cancellarlo e ai server multimediali di cancellare le sue foto o il suo video. Un relay che ignora la richiesta, o chi ne ha già salvato una copia, potrebbe ancora averlo.';

  @override
  String get deletePrivateBody =>
      'Un post per amici stretti non può essere richiamato dai relay. Mialuna dirà alle app dei tuoi amici di rimuoverlo e chiederà al server multimediale di cancellare i suoi file cifrati. Un amico che ne ha già salvato una copia potrebbe ancora averlo.';

  @override
  String get deletingPost => 'Eliminazione…';

  @override
  String get postDeleted => 'Eliminato.';

  @override
  String get postWasDeleted => 'Questo post è stato eliminato.';

  @override
  String get deleteNotAllowed =>
      'Solo l\'account che l\'ha pubblicato può eliminarlo.';

  @override
  String deleteFailed(Object reason) {
    return 'Impossibile eliminare: $reason';
  }

  @override
  String get deleteNoRelay =>
      'Nessun relay ha accettato la richiesta di cancellazione, quindi è ancora online. Controlla la connessione e riprova.';

  @override
  String deleteMediaLeft(Object servers) {
    return 'Non è stato possibile rimuovere i file da $servers.';
  }

  @override
  String get deleteMediaNotAuthorized =>
      'Il tuo firmatario non ha autorizzato la rimozione dei file, che restano sul server multimediale.';

  @override
  String deleteFriendsMissed(Object count) {
    return '$count dei tuoi amici stretti non sono stati avvisati, quindi potrebbe restare sui loro telefoni.';
  }

  @override
  String get storyCleanupSetting => 'Elimina le mie storie alla scadenza';

  @override
  String get storyCleanupSettingExplain =>
      'Dopo 24 ore Mialuna chiede ai tuoi relay e ai tuoi server multimediali di cancellare le tue storie, foto e video compresi. Un server che ignora la richiesta, o chi ne ha tenuto una copia, potrebbe ancora averle.';

  @override
  String storyCleanupWaiting(Object count) {
    return 'Il tuo firmatario deve approvare ogni pulizia, quindi si aspetta che sia tu a chiederla. Storie scadute in attesa: $count.';
  }

  @override
  String get storyCleanupNow => 'Elimina ora';

  @override
  String get storyCleanupDone => 'Storie scadute eliminate.';

  @override
  String get storyCleanupPartly =>
      'Alcune non si sono ancora potute eliminare; Mialuna riproverà.';
}
