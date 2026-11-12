// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get syncUpToDate => 'Aktuell';

  @override
  String get syncFailed => 'Sync fehlgeschlagen';

  @override
  String get relaysUpdatedFromProfile =>
      'Relays aus deinem Profil aktualisiert (NIP-65)';

  @override
  String get relayListPublished => 'Relay-Liste veröffentlicht';

  @override
  String get mediaServersUpdatedFromProfile =>
      'Medienserver aus deinem Profil aktualisiert';

  @override
  String get tabHome => 'Home';

  @override
  String get tabDiscover => 'Entdecken';

  @override
  String get tabCreate => 'Erstellen';

  @override
  String get tabReels => 'Reels';

  @override
  String get tabProfile => 'Profil';

  @override
  String get signInToUploadMedia => 'Melde dich an, um Medien hochzuladen.';

  @override
  String get noMediaServer =>
      'Kein Medienserver konfiguriert. Füge einen in den Einstellungen hinzu.';

  @override
  String serverNoResponse(Object server) {
    return '$server: keine Antwort';
  }

  @override
  String serverUnreachable(Object server, Object error) {
    return '$server: nicht erreichbar ($error)';
  }

  @override
  String uploadRejected(Object reason) {
    return 'Upload abgelehnt — $reason';
  }

  @override
  String noServerAcceptedFile(Object reasons) {
    return 'Kein Server hat die Datei angenommen — $reasons';
  }

  @override
  String get blossomInvalidResponse => 'ungültige Antwort';

  @override
  String get blossomInvalidFileUrl => 'ungültige Dateiadresse';

  @override
  String get blossomServerAlteredFile => 'der Server hat die Datei verändert';

  @override
  String get blossomBadRequest => 'ungültige Anfrage';

  @override
  String get blossomUnauthorized => 'Autorisierung verweigert';

  @override
  String get blossomPaymentRequired => 'Zahlung erforderlich';

  @override
  String get blossomForbidden => 'nicht erlaubt';

  @override
  String get blossomLengthRequired => 'Größe fehlt';

  @override
  String get blossomTooLarge => 'Datei zu groß';

  @override
  String get blossomUnsupportedType => 'Format nicht akzeptiert';

  @override
  String get blossomTooManyRequests => 'zu viele Anfragen';

  @override
  String get blossomServerError => 'Serverfehler';

  @override
  String get cipherInvalidKey => 'Ungültiger Schlüssel';

  @override
  String get cipherTruncated => 'Verschlüsselte Datei ist abgeschnitten';

  @override
  String get cipherMismatch =>
      'Die Datei passt nicht zum Schlüssel: verändert oder beschädigt';

  @override
  String get sanitizeHeifNeedsAsync =>
      'Format HEIC/AVIF: Umwandlung braucht sanitizeAsync';

  @override
  String get sanitizeWebmUnsupported =>
      'WebM/MKV-Video wird nicht unterstützt: nutze MP4 oder MOV, damit die Metadaten vor dem Upload entfernt werden können.';

  @override
  String get sanitizeUnknownFormat =>
      'Unbekanntes Dateiformat: Fotos JPEG/PNG/WebP/GIF oder Videos MP4/MOV.';

  @override
  String sanitizeLeftovers(Object items) {
    return 'Nicht alle Metadaten konnten entfernt werden ($items): Datei nicht hochgeladen.';
  }

  @override
  String sanitizeProcessingFailed(Object error) {
    return 'Datei konnte nicht verarbeitet werden: $error';
  }

  @override
  String get sanitizeJpegInvalid => 'Ungültiges JPEG';

  @override
  String get sanitizeJpegTruncated => 'Abgeschnittenes JPEG';

  @override
  String get sanitizeJpegNoSize => 'JPEG ohne Maße';

  @override
  String get sanitizeJpegUndecodable => 'JPEG kann nicht dekodiert werden';

  @override
  String get sanitizePngTruncated => 'Abgeschnittenes PNG';

  @override
  String get sanitizePngInvalid => 'Ungültiges PNG';

  @override
  String get sanitizeGifInvalid => 'Ungültiges GIF';

  @override
  String get sanitizeGifTruncated => 'Abgeschnittenes GIF';

  @override
  String get sanitizeWebpTruncated => 'Abgeschnittenes WebP';

  @override
  String get sanitizeWebpInvalid => 'Ungültiges WebP';

  @override
  String get sanitizeMp4Invalid => 'Ungültiges MP4/MOV-Video';

  @override
  String get sanitizeConversionFailed => 'Umwandlung fehlgeschlagen';

  @override
  String get sanitizeHeifUnsupported =>
      'Dieses Format (HEIC/AVIF) kann auf diesem Gerät nicht umgewandelt werden. Wähle ein JPEG- oder PNG-Foto.';

  @override
  String get privateMediaNotEncrypted => 'Medium ist nicht verschlüsselt';

  @override
  String serverReplied(Object status) {
    return 'Der Server antwortete $status';
  }

  @override
  String get fileTooLarge => 'Datei zu groß';

  @override
  String get serverFileNotOriginal =>
      'Die Datei auf dem Server ist nicht das Original';

  @override
  String get contentMismatch => 'Der Inhalt stimmt nicht überein';

  @override
  String get mediaUnreachable => 'Medium nicht erreichbar';

  @override
  String get amberInvalidKey => 'Amber lieferte einen ungültigen Schlüssel';

  @override
  String get amberNoKey => 'Amber lieferte keinen Schlüssel';

  @override
  String get amberRequestRejected => 'Anfrage in Amber abgelehnt';

  @override
  String get amberAndroidOnly => 'Amber gibt es nur auf Android';

  @override
  String get amberEmptySignature => 'Amber lieferte eine leere Signatur';

  @override
  String get amberSignRejected => 'Signatur in Amber abgelehnt';

  @override
  String get amberTimeout => 'Amber hat nicht rechtzeitig geantwortet';

  @override
  String get amberEmptyResponse => 'Amber lieferte eine leere Antwort';

  @override
  String get bunkerInvalidUrl => 'Ungültige bunker-URL';

  @override
  String get bunkerNoRelay => 'Der bunker nennt keinen relay';

  @override
  String get bunkerWebAuth =>
      'Der bunker verlangt eine Web-Autorisierung (auth_url wird nicht unterstützt)';

  @override
  String get bunkerInvalidKey =>
      'Der bunker lieferte keinen gültigen Schlüssel';

  @override
  String get signerInvalidResponse =>
      'Der Signer lieferte ein ungültiges signiertes Ereignis';

  @override
  String get bunkerTimeout => 'Zeitüberschreitung beim bunker';

  @override
  String get nwcInvalidUri => 'Ungültige NWC-URI';

  @override
  String get nwcNoRelay => 'Die NWC-URI nennt keinen relay';

  @override
  String get nwcNoSecret => 'Die NWC-URI enthält kein gültiges Geheimnis';

  @override
  String get nwcTimeout => 'Zeitüberschreitung der Wallet';

  @override
  String get signerNoPrivateMessages =>
      'Diese Anmeldung unterstützt keine privaten Nachrichten';

  @override
  String get zapNotSupported => 'Diese Adresse unterstützt keine Nostr-zaps';

  @override
  String zapAmountOutOfRange(Object min, Object max) {
    return 'Betrag außerhalb des Bereichs ($min–$max sats)';
  }

  @override
  String get commentNotSent =>
      'Kommentar nicht gesendet. Versuche es später erneut.';

  @override
  String get comments => 'Kommentare';

  @override
  String get noCommentsYet => 'Noch keine Kommentare.';

  @override
  String get signInToComment => 'Melde dich an, um zu kommentieren.';

  @override
  String get addComment => 'Kommentar hinzufügen…';

  @override
  String get signInToPublish => 'Melde dich an, um zu veröffentlichen.';

  @override
  String get addMediaFirst =>
      'Füge vor dem Veröffentlichen mindestens ein Foto oder Video hinzu.';

  @override
  String get removingMetadata => 'Metadaten werden entfernt…';

  @override
  String uploadingProgress(Object current, Object total) {
    return 'Hochladen $current von $total…';
  }

  @override
  String get creatingPreview => 'Vorschau wird erstellt…';

  @override
  String uploadFailed(Object error) {
    return 'Upload fehlgeschlagen: $error';
  }

  @override
  String get publishing => 'Veröffentlichen…';

  @override
  String noRelayAcceptedPost(Object reason) {
    return 'Kein relay hat den Beitrag angenommen$reason. Der Inhalt bleibt in deinen Entwürfen.';
  }

  @override
  String get privateNeedsKeySigner =>
      'Diese Anmeldung unterstützt keine privaten Inhalte. Nutze Amber, einen bunker oder den lokalen Schlüssel.';

  @override
  String get closeFriendsListEmptyAddSomeone =>
      'Deine Liste enger Freunde ist leer: füge jemanden hinzu.';

  @override
  String get fileOver100Mb =>
      'Die Datei ist über 100 MB: das ist das Limit für enge Freunde (sie wird komplett auf deinem Telefon verschlüsselt).';

  @override
  String get encryptingOnPhone => 'Verschlüsseln auf deinem Telefon…';

  @override
  String noServerAcceptedEncrypted(Object details) {
    return 'Keiner deiner Medienserver hat die verschlüsselte Datei angenommen. Sie wird nicht im Klartext veröffentlicht. Füge in den Einstellungen einen Server hinzu, der verschlüsselte Dateien annimmt (zum Beispiel cdn.hzrd149.com). $details';
  }

  @override
  String get sendingToFriends => 'Senden an Freunde…';

  @override
  String sendingToFriendsProgress(Object done, Object total) {
    return 'Senden an Freunde $done/$total…';
  }

  @override
  String noFriendReceivedPost(Object reason) {
    return 'Kein Freund hat den Beitrag erhalten$reason. Der Inhalt bleibt in deinen Entwürfen.';
  }

  @override
  String sentToCloseFriends(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'An $count enge Freunde gesendet 🔒',
      one: 'An 1 engen Freund gesendet 🔒',
    );
    return '$_temp0';
  }

  @override
  String sentToFriendsWithMisses(int delivered, Object missed) {
    String _temp0 = intl.Intl.pluralLogic(
      delivered,
      locale: localeName,
      other: 'An $delivered Freunde gesendet.',
      one: 'An 1 Freund gesendet.',
    );
    return '$_temp0 $missed haben sie nicht erhalten (private Nachrichten sind aus).';
  }

  @override
  String get altText => 'Alt-Text';

  @override
  String get altTextHint =>
      'Beschreibe den Inhalt für alle, die ihn nicht sehen können…';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get save => 'Speichern';

  @override
  String get momentPublished => 'Moment veröffentlicht ✨';

  @override
  String get newMoment => 'Neuer Moment';

  @override
  String get publish => 'Veröffentlichen';

  @override
  String get guestMode => 'Gastmodus';

  @override
  String get signInToPostMoments =>
      'Melde dich an, um deine Momente zu veröffentlichen.';

  @override
  String get signIn => 'Anmelden';

  @override
  String get kindPhoto => 'Foto';

  @override
  String get kindVideo => 'Video';

  @override
  String get kindReel => 'Reel';

  @override
  String get kindStory => 'Story';

  @override
  String get storyExpiryNote =>
      'Stories laufen nach 24 Stunden auf relays ab, die NIP-40 beachten, andere können sie aber speichern oder archivieren.';

  @override
  String get fromGallery => 'Aus der Galerie';

  @override
  String get galleryLongPressVideo => 'Galerie (lang drücken für Video)';

  @override
  String get addVideo => 'Video hinzufügen';

  @override
  String get camera => 'Kamera';

  @override
  String get exifRemovedNote =>
      'Standort-Metadaten (EXIF) werden automatisch entfernt.';

  @override
  String get writeCaption => 'Schreib eine Bildunterschrift…';

  @override
  String get privatePostNote =>
      'Privater Beitrag: keine öffentlichen Hashtags, nicht über die Suche auffindbar.';

  @override
  String willPublishAs(Object caption) {
    return 'Wird so veröffentlicht: \"$caption\"';
  }

  @override
  String get tapThumbnailForAlt =>
      'Tippe auf eine Miniatur, um Alt-Text hinzuzufügen.';

  @override
  String get sensitiveContent => 'Sensibler Inhalt';

  @override
  String get sensitiveContentNote =>
      'Der Beitrag wird hinter einer Warnung verborgen (NIP-36).';

  @override
  String get uploadingMedia => 'Medien werden hochgeladen…';

  @override
  String get audiencePublic => 'Öffentlich';

  @override
  String get closeFriends => 'Enge Freunde';

  @override
  String get signerCannotPublishCloseFriends =>
      'Mit dieser Anmeldung kannst du nicht für enge Freunde veröffentlichen: nutze Amber, einen bunker oder den lokalen Schlüssel.';

  @override
  String get closeFriendsEmptyPrompt =>
      'Deine Liste ist leer: füge die Personen hinzu, die diesen Beitrag sehen dürfen.';

  @override
  String onlyYourCloseFriendsSee(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Nur deine $count engen Freunde sehen das. Fotos und Videos werden auf deinem Telefon verschlüsselt, bevor sie hochgeladen werden.',
      one: 'Nur dein 1 enger Freund sieht das. Fotos und Videos werden auf deinem Telefon verschlüsselt, bevor sie hochgeladen werden.',
    );
    return '$_temp0';
  }

  @override
  String get addFriends => 'Freunde hinzufügen';

  @override
  String get manageList => 'Liste verwalten';

  @override
  String get edit => 'Bearbeiten';

  @override
  String get reset => 'Zurücksetzen';

  @override
  String get apply => 'Anwenden';

  @override
  String get cropFree => 'Frei';

  @override
  String get cropOriginal => 'Original';

  @override
  String get rotate => 'Drehen';

  @override
  String get flip => 'Spiegeln';

  @override
  String get brightness => 'Helligkeit';

  @override
  String get contrast => 'Kontrast';

  @override
  String get saturation => 'Sättigung';

  @override
  String postsByAuthor(Object author) {
    return 'Beiträge von $author…';
  }

  @override
  String get searchHint => 'Personen, Hashtags oder Wörter suchen…';

  @override
  String get clear => 'Leeren';

  @override
  String get recent => 'Neueste';

  @override
  String get searchDependsOnRelays =>
      'Die Suche hängt von den konfigurierten relays ab: Ergebnisse können unvollständig sein.';

  @override
  String get recentPostsEverywhere =>
      'Neueste Beiträge aus dem ganzen Netz, auch von Leuten, denen du nicht folgst.';

  @override
  String get noResultsOnRelays =>
      'Keine Ergebnisse auf den konfigurierten relays.';

  @override
  String get noRecentPostsFromFollowed =>
      'Keine neuen Beiträge von den Personen, denen du folgst.';

  @override
  String get noMomentsFound =>
      'Keine Momente auf den relays gefunden. Prüfe deine Verbindung.';

  @override
  String get loadFailed => 'Laden fehlgeschlagen';

  @override
  String get notifications => 'Mitteilungen';

  @override
  String get messages => 'Nachrichten';

  @override
  String get homeEmptyFollowsNobody =>
      'Beiträge von Personen, denen du folgst, erscheinen hier.\nDu folgst noch niemandem: entdecke interessante Leute und Profile.';

  @override
  String get discoverPeople => 'Leute entdecken';

  @override
  String get homeEmpty =>
      'Noch keine Momente.\nZieh nach unten zum Aktualisieren oder veröffentliche dein erstes Bild.';

  @override
  String get retry => 'Erneut versuchen';

  @override
  String get seenEverything => 'Du hast fürs Erste alles gesehen ✨';

  @override
  String get discoverMoreProfiles => 'Mehr Profile entdecken';

  @override
  String get feedFollowing => 'Folge ich';

  @override
  String get signInToSeeFollowed =>
      'Melde dich an, um Beiträge von Personen zu sehen, denen du folgst';

  @override
  String get videoPreview => 'Videovorschau';

  @override
  String get cannotOpenPrivateVideo =>
      'Privates Video kann nicht geöffnet werden';

  @override
  String get cannotPlayVideo => 'Video kann nicht abgespielt werden';

  @override
  String get pauseVideo => 'Video pausieren';

  @override
  String get playVideo => 'Video abspielen';

  @override
  String errorTapToRetry(Object error) {
    return '$error — tippen zum Wiederholen';
  }

  @override
  String get soundOn => 'Ton einschalten';

  @override
  String get soundOff => 'Ton ausschalten';

  @override
  String get postImage => 'Beitragsbild';

  @override
  String get imageUnavailable => 'Bild nicht verfügbar';

  @override
  String errorTapToRetryNewline(Object message) {
    return '$message\nTippen zum Wiederholen';
  }

  @override
  String get cannotOpenPrivateContent =>
      'Dieser private Inhalt kann nicht geöffnet werden';

  @override
  String get privateImage => 'Privates Bild';

  @override
  String get invalidImage => 'Ungültiges Bild';

  @override
  String get more => 'Mehr';

  @override
  String get removeFromSaved => 'Aus Gespeichert entfernen';

  @override
  String get copyLink => 'Link kopieren';

  @override
  String get muteAuthor => 'Autor stummschalten';

  @override
  String get blockAuthor => 'Autor blockieren';

  @override
  String get report => 'Melden';

  @override
  String get like => 'Gefällt mir';

  @override
  String get sendInMessage => 'In einer Nachricht senden';

  @override
  String get zapOptional => 'Zap (optional)';

  @override
  String get closeFriendsOnlyNote =>
      'Nur für enge Freunde sichtbar. Likes und Antworten gehen nur an den Autor.';

  @override
  String get likeFailed => 'Gefällt mir konnte nicht gesendet werden';

  @override
  String get nostrLinkCopied => 'Nostr-Link in die Zwischenablage kopiert';

  @override
  String get authorMuted => 'Autor stummgeschaltet';

  @override
  String get authorBlocked => 'Autor blockiert';

  @override
  String get reportSent => 'Meldung gesendet (NIP-56)';

  @override
  String get signInToReport => 'Melde dich an, um zu melden';

  @override
  String minutesAgo(Object minutes) {
    return 'vor $minutes Min.';
  }

  @override
  String get show => 'Zeigen';

  @override
  String get chatEmptyHint =>
      'Schreib die erste Nachricht.\nSie ist verschlüsselt: nur ihr zwei könnt sie sehen.';

  @override
  String get messageHint => 'Nachricht…';

  @override
  String get send => 'Senden';

  @override
  String get notSentSuffix => ' nicht gesendet';

  @override
  String get contentUnavailable =>
      'Inhalt nicht verfügbar (abgelaufen oder auf den relays nicht gefunden)';

  @override
  String get signInToSendPrivateMessages =>
      'Melde dich an, um private Nachrichten zu senden.';

  @override
  String get cannotMessageYourself => 'Du kannst dir nicht selbst schreiben.';

  @override
  String get recipientNoPrivateMessages =>
      'Diese Person hat private Nachrichten noch nicht aktiviert.';

  @override
  String noRecipientRelayAccepted(Object reason) {
    return 'Kein relay des Empfängers hat die Nachricht angenommen$reason.';
  }

  @override
  String sendFailed(Object error) {
    return 'Senden fehlgeschlagen: $error';
  }

  @override
  String get signInToReadMessages =>
      'Melde dich an, um private Nachrichten zu lesen und zu senden.';

  @override
  String get signerNoPrivateMessagesLong =>
      'Private Nachrichten gehen mit dieser Anmeldung nicht. Melde dich mit Amber, einem bunker oder dem lokalen Schlüssel an.';

  @override
  String get inboxEmpty =>
      'Keine Unterhaltungen.\nTippe auf den Stift, um jemandem zu schreiben, oder leite einen Moment mit dem ✈-Symbol unter jedem Beitrag weiter.';

  @override
  String get newMessage => 'Neue Nachricht';

  @override
  String get privateMessagesEnabled => 'Private Nachrichten aktiviert';

  @override
  String get enableMessagesFailed =>
      'Einschalten fehlgeschlagen. Versuche es erneut.';

  @override
  String get enablePrivateMessages => 'Private Nachrichten aktivieren';

  @override
  String enablePrivateMessagesExplain(Object count) {
    return 'Um Nachrichten zu empfangen, musst du sagen, auf welchen relays sie ankommen sollen. Eine kleine Liste (NIP-17) wird mit $count Standard-relays veröffentlicht: du kannst sie später ändern. Nachrichten bleiben verschlüsselt: relays sehen weder, wer schreibt, noch den Text.';
  }

  @override
  String get turnOn => 'Aktivieren';

  @override
  String get searchByNameOrUsername => 'Nach Name oder Nutzername suchen';

  @override
  String get searching => 'Suchen…';

  @override
  String get noOneWithNameHint =>
      'Niemand mit diesem Namen. Versuche weniger Buchstaben oder eine Adresse wie name@domain.com.';

  @override
  String get sent => 'Gesendet';

  @override
  String sentToPeople(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'An $count Personen gesendet',
      one: 'An 1 Person gesendet',
    );
    return '$_temp0';
  }

  @override
  String sentToPeopleWithFailure(int count, Object failure) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'An $count Personen gesendet. $failure',
      one: 'An 1 Person gesendet. $failure',
    );
    return '$_temp0';
  }

  @override
  String get signerNoPrivateMessagesShort =>
      'Du kannst private Nachrichten mit dieser Anmeldung nicht nutzen.';

  @override
  String get followToStartOrSearch =>
      'Folge jemandem, um zu starten, oder suche nach Namen.';

  @override
  String get addMessage => 'Nachricht hinzufügen…';

  @override
  String sendWithCount(Object count) {
    return 'Senden ($count)';
  }

  @override
  String get linkCopied => 'Link in die Zwischenablage kopiert';

  @override
  String get noNotifications => 'Gerade keine Mitteilungen.';

  @override
  String get notificationsDependOnRelays =>
      'Mitteilungen hängen von relays ab: sie können unvollständig sein.';

  @override
  String get reactedToYourMoment => 'hat auf deinen Moment reagiert';

  @override
  String commentedText(Object text) {
    return 'hat kommentiert: $text';
  }

  @override
  String sentYouSats(Object sats, Object comment) {
    return 'hat dir $sats sats gesendet$comment';
  }

  @override
  String get sentYouZap => 'hat dir einen zap gesendet';

  @override
  String get startedFollowingYou => 'folgt dir jetzt';

  @override
  String get amberNotFound => 'Amber nicht gefunden';

  @override
  String get amberExplain =>
      'Amber ist ein Nostr-Signer, der deinen privaten Schlüssel außerhalb von Mialuna hält. Installiere ihn und versuche es erneut.';

  @override
  String get downloadFromFdroid => 'Von F-Droid laden';

  @override
  String get continueWithAmber => 'Weiter mit Amber';

  @override
  String get amberRecommended =>
      'Empfohlen: dein privater Schlüssel bleibt sicher in Amber.';

  @override
  String get amberNotDetected =>
      'Amber nicht erkannt: installiere es für die empfohlene Anmeldung.';

  @override
  String get exploreWithoutAccount => 'Ohne Konto erkunden';

  @override
  String get remoteBunker => 'Entfernter bunker (NIP-46)';

  @override
  String get invalidBunkerUrlDot => 'Ungültige bunker-URL.';

  @override
  String get connectBunker => 'bunker verbinden';

  @override
  String get advancedNsec => 'Erweiterte Anmeldung (nsec)';

  @override
  String get nsecWarning =>
      'Achtung: deinen privaten Schlüssel einzufügen ist riskant. Teile ihn niemals. Auf Android lieber Amber.';

  @override
  String get invalidNsec => 'Ungültiger nsec-Schlüssel.';

  @override
  String get signInWithNsec => 'Mit nsec anmelden';

  @override
  String get tagline => 'Deine Momente, unter demselben Mond.';

  @override
  String get skip => 'Überspringen';

  @override
  String get permissionsAndWallet => 'Berechtigungen und Wallet';

  @override
  String get permissionsExplain =>
      'Sie lassen dich nur veröffentlichen und Mitteilungen empfangen. Du kannst sie jederzeit in den Systemeinstellungen ändern.';

  @override
  String get photosAndVideos => 'Fotos und Videos';

  @override
  String get toUploadYourMoments => 'Um deine Momente hochzuladen';

  @override
  String get allow => 'Erlauben';

  @override
  String get reactionsCommentsZaps => 'Reaktionen, Kommentare und zaps';

  @override
  String get lightningWalletOptional => 'Lightning-Wallet (optional)';

  @override
  String get nwcExplain =>
      'Verbinde eine Nostr-Wallet-Connect-Wallet, um zaps zu senden, ohne die App zu verlassen.';

  @override
  String get walletConnected => 'Wallet verbunden';

  @override
  String get disconnect => 'Trennen';

  @override
  String get connectWallet => 'Wallet verbinden';

  @override
  String get getStarted => 'Loslegen';

  @override
  String get welcome1 =>
      'Mialuna ist ein visuelles soziales Netz: Fotos, Videos, Reels und Stories — nie reine Textbeiträge.';

  @override
  String get welcome2 =>
      'Es läuft auf Nostr, einem offenen Protokoll: deine Identität ist ein Schlüssel, den du besitzt, kein Konto, das eine Firma dir nehmen kann. Keine Werbung, keine Tracker, keine zentralen Server.';

  @override
  String get welcome3 =>
      'Teile dein Licht mit Menschen überall, aus jeder App, die dieselbe offene Sprache spricht.';

  @override
  String onboardingWot(int min) {
    return 'Das Vertrauensnetz ist immer an. Beim ersten Öffnen von Mialuna liest es, wem du folgst, und baut den Entdecken-Feed aus diesem Netz: du, die Personen, denen du folgst, und alle, denen mindestens $min von ihnen folgen. Beim nächsten Öffnen ist der Feed schon da.';
  }

  @override
  String get publicAndPrivate => 'Öffentlich und privat';

  @override
  String get publicAndPrivateIntro =>
      'Mialuna baut auf Nostr, einem offenen Netz. Was du veröffentlichst, ist öffentlich: Beiträge, Fotos und Videos bleiben für jeden mit dem Link sichtbar, auch außerhalb von Mialuna.';

  @override
  String get closeFriendsExplain1 =>
      'Nur die Personen auf dieser Liste erhalten deine Beiträge, Stories und Videos für „Enge Freunde“. Die Liste steckt im Beitrag; du musst sie nicht jedes Mal wählen.';

  @override
  String get closeFriendsExplain2 =>
      'Fotos und Videos werden auf deinem Telefon verschlüsselt, bevor sie hochgeladen werden. Dateiserver (Blossom) verschlüsseln selbst nichts: deshalb macht Mialuna das, und der Server sieht nur unlesbare Daten. Wer die Dateiadresse findet, kann sie nicht öffnen.';

  @override
  String get closeFriendsExplain3 =>
      'Das ist keine absolute Garantie: wer einen Beitrag erhält, kann einen Screenshot machen, und einen Freund zu entfernen gilt nur für künftige Beiträge.';

  @override
  String get closeFriendsExplain4 =>
      'Jeder Freund muss Mialuna mit aktivierten privaten Nachrichten nutzen. Andere Nostr-Clients zeigen diese Beiträge nicht.';

  @override
  String get closeFriendsExplain5 =>
      'Öffentliche Beiträge bleiben öffentlich: ihre Dateien sind für jeden mit dem Link sichtbar.';

  @override
  String get closeFriendsExplain6 =>
      'Wenn keiner deiner Server verschlüsselte Dateien annimmt, wird der Beitrag nicht veröffentlicht: nie im Klartext.';

  @override
  String get addToCloseFriends => 'Zu engen Freunden hinzufügen';

  @override
  String maxFriendsReached(Object max, Object added) {
    return 'Limit von $max Freunden: $added hinzugefügt.';
  }

  @override
  String get add => 'Hinzufügen';

  @override
  String get signInToCreateList =>
      'Melde dich an, um deine Liste zu erstellen.';

  @override
  String get signerNoCloseFriends =>
      'Enge Freunde gehen mit dieser Anmeldung nicht. Melde dich mit Amber, einem bunker oder dem lokalen Schlüssel an.';

  @override
  String peopleOfMax(Object count, Object max) {
    return '$count / $max Personen';
  }

  @override
  String get noOneYet => 'Noch niemand.';

  @override
  String get addPeople => 'Personen hinzufügen';

  @override
  String get friendNoPrivateMessagesWarning =>
      'Private Nachrichten sind nicht an: sie erhalten deine Beiträge nicht';

  @override
  String get removeFromList => 'Aus der Liste entfernen';

  @override
  String get noOneWithThisName => 'Niemand mit diesem Namen.';

  @override
  String get signInToSendPrivateContent =>
      'Melde dich an, um private Inhalte zu senden.';

  @override
  String get reasonNoPrivateMessages =>
      'hat private Nachrichten nicht aktiviert';

  @override
  String get reasonNoRelayAnswered => 'kein relay hat geantwortet';

  @override
  String get profileUpdated => 'Profil aktualisiert';

  @override
  String get noRelayAcceptedRetry =>
      'Kein relay hat es angenommen. Versuche es später erneut.';

  @override
  String get editProfile => 'Profil bearbeiten';

  @override
  String get fieldName => 'Name';

  @override
  String get fieldBio => 'Bio';

  @override
  String get fieldAvatarUrl => 'Avatar-URL';

  @override
  String get fieldNip05 => 'NIP-05 (z. B. du@example.com)';

  @override
  String get browsingAsGuest => 'Du bist als Gast unterwegs';

  @override
  String get signInToInteract =>
      'Melde dich an, um zu veröffentlichen, zu folgen und zu interagieren.';

  @override
  String get settings => 'Einstellungen';

  @override
  String get signOut => 'Abmelden';

  @override
  String get npubCopied => 'npub kopiert';

  @override
  String get copyNpub => 'npub kopieren';

  @override
  String get mute => 'Stummschalten';

  @override
  String get block => 'Blockieren';

  @override
  String get posts => 'Beiträge';

  @override
  String get saved => 'Gespeichert';

  @override
  String get nothingPublishedYet => 'Du hast noch nichts veröffentlicht.';

  @override
  String get noPostsOnRelays => 'Keine Beiträge auf den relays gefunden.';

  @override
  String get noReelsPublished => 'Keine Reels veröffentlicht.';

  @override
  String get noReelsOnRelays => 'Keine Reels auf den relays gefunden.';

  @override
  String get noSavedPosts => 'Keine gespeicherten Beiträge.';

  @override
  String get followingButton => 'Gefolgt';

  @override
  String get follow => 'Folgen';

  @override
  String get messageButton => 'Nachricht';

  @override
  String get loginLocalKey => 'Lokaler Schlüssel';

  @override
  String get loginGuest => 'Gast';

  @override
  String get followUpdateFailed =>
      'Deine Folgen konnten gerade nicht aktualisiert werden. Versuche es erneut.';

  @override
  String get noReelsComeBack =>
      'Keine Reels auf den relays gefunden.\nSchau bald wieder vorbei!';

  @override
  String get followUpdateFailedShort =>
      'Deine Folgen konnten gerade nicht aktualisiert werden';

  @override
  String get needOneReadRelay => 'Mindestens ein Lese-relay ist nötig.';

  @override
  String get listSavedLocally =>
      'Liste auf diesem Gerät gespeichert, nicht veröffentlicht.';

  @override
  String get noRelayAcceptedList =>
      'Kein relay hat die Liste angenommen: später wird es erneut versucht.';

  @override
  String relayListPublishedTo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Relay-Liste an $count relays veröffentlicht',
      one: 'Relay-Liste an 1 relay veröffentlicht',
    );
    return '$_temp0';
  }

  @override
  String get mediaServersUpdated => 'Medienserver aktualisiert';

  @override
  String get appearance => 'Erscheinungsbild';

  @override
  String get publishingSettings => 'Veröffentlichen';

  @override
  String get addMialunaHashtag => '#mialuna hinzufügen';

  @override
  String get addMialunaHashtagNote =>
      'Fügt öffentlichen Beiträgen und Stories den offiziellen Hashtag hinzu. Du kannst das jederzeit ausschalten.';

  @override
  String get themeLight => 'Hell';

  @override
  String get themeDark => 'Dunkel';

  @override
  String get themeSystem => 'System';

  @override
  String get relays => 'Relays';

  @override
  String get relaysExplainSignedOut =>
      'Relays speichern und verteilen Inhalte. Melde dich an, um automatisch deine eigene Liste zu nutzen (NIP-65).';

  @override
  String get relaysExplainSynced =>
      'Die Liste ist mit deinem Nostr-Profil synchron (NIP-65): jede Änderung wird veröffentlicht und gilt für alle deine Apps.';

  @override
  String get syncing => 'Synchronisieren…';

  @override
  String get waitingFirstSync => 'Warten auf die erste Synchronisierung';

  @override
  String get syncNow => 'Jetzt synchronisieren';

  @override
  String get addRelay => 'relay hinzufügen';

  @override
  String get restoreDefaultRelays => 'Standard-relays wiederherstellen';

  @override
  String get createYourList => 'Deine Liste erstellen';

  @override
  String peopleCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Personen',
      one: '1 Person',
    );
    return '$_temp0';
  }

  @override
  String get closeFriendsSettingsNote =>
      'Beiträge, Stories und Videos nur für sie sichtbar, mit verschlüsselten Fotos und Videos.';

  @override
  String get mediaServersBlossom => 'Medienserver (Blossom)';

  @override
  String get mediaServersExplain =>
      'Fotos und Videos werden nur auf diese Server hochgeladen, in der gezeigten Reihenfolge: der erste, der sie annimmt, gewinnt. EXIF und Standort werden vor dem Upload entfernt.';

  @override
  String get primary => 'Primär';

  @override
  String get makePrimary => 'Als primär festlegen';

  @override
  String get remove => 'Entfernen';

  @override
  String get addServer => 'Server hinzufügen';

  @override
  String get moderation => 'Moderation';

  @override
  String get moderationExplain =>
      'Stummgeschaltete Autoren und versteckte Hashtags werden über NIP-51 synchronisiert. Blockierte Autoren bleiben nur auf diesem Gerät.';

  @override
  String get mutedAuthors => 'Stummgeschaltete Autoren';

  @override
  String get noMutedAuthors => 'Keine stummgeschalteten Autoren';

  @override
  String get blockedAuthors => 'Blockierte Autoren';

  @override
  String get noBlockedAuthors => 'Keine blockierten Autoren';

  @override
  String get hiddenHashtags => 'Versteckte Hashtags';

  @override
  String get noHiddenHashtags => 'Keine versteckten Hashtags';

  @override
  String get hashtagToHide => '#hashtag zum Verstecken';

  @override
  String get storage => 'Speicher';

  @override
  String get clearCache => 'Ereignis-Cache und Entwürfe leeren';

  @override
  String get cacheCleared => 'Cache geleert';

  @override
  String get reviewIntro => 'Einführung erneut ansehen';

  @override
  String get reviewIntroSubtitle =>
      'Was öffentlich ist, was privat ist, und die Grenzen enger Freunde.';

  @override
  String noLightningWalletCopied(Object address) {
    return 'Keine Lightning-Wallet gefunden: Adresse kopiert ($address)';
  }

  @override
  String get about => 'Info';

  @override
  String aboutText(Object version) {
    return 'Mialuna $version — Deine Momente, unter demselben Mond.\nOpen Source (MIT). github.com/Lwb89dev/mialuna';
  }

  @override
  String get invalidRelayAddress => 'Ungültige Adresse: nutze wss://…';

  @override
  String get invalidServerAddress => 'Ungültige Adresse: nutze https://…';

  @override
  String get relayRead => 'Lesen';

  @override
  String get relayWrite => 'Schreiben';

  @override
  String get support => 'Unterstützen';

  @override
  String get supportText =>
      'Mialuna ist kostenlos, ohne Werbung und verfolgt dich nicht. Wenn es dir gefällt, kannst du ein paar sats über das Lightning Network senden.';

  @override
  String get donateWithLightning => 'Mit Lightning spenden';

  @override
  String get authorNoZaps => 'Dieser Autor akzeptiert keine zaps';

  @override
  String get sendZap => 'Einen zap senden ⚡';

  @override
  String get amountInSats => 'Betrag in sats';

  @override
  String minMaxSats(Object min, Object max) {
    return 'min $min – max $max';
  }

  @override
  String get zap => 'Zap';

  @override
  String get signInToZap => 'Melde dich an, um zaps zu senden';

  @override
  String zapSent(Object sats) {
    return 'Zap über $sats sats gesendet ⚡';
  }

  @override
  String nwcPaymentFailed(Object error) {
    return 'NWC-Zahlung fehlgeschlagen: $error';
  }

  @override
  String get noLightningWallet => 'Keine Lightning-Wallet gefunden';

  @override
  String storiesRailLabel(Object state) {
    return 'Stories, $state';
  }

  @override
  String get close => 'Schließen';

  @override
  String hoursAgo(int hours) {
    return 'vor $hours Std.';
  }

  @override
  String daysAgo(int days) {
    return 'vor $days T.';
  }

  @override
  String get now => 'jetzt';

  @override
  String get youPrefix => 'Du: ';

  @override
  String get storiesStateUnseen => 'neu';

  @override
  String get storiesStateSeen => 'gesehen';

  @override
  String weekdayShort(String day) {
    String _temp0 = intl.Intl.selectLogic(day, {
      'mon': 'Mo',
      'tue': 'Di',
      'wed': 'Mi',
      'thu': 'Do',
      'fri': 'Fr',
      'sat': 'Sa',
      'sun': 'So',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get sharedAMoment => 'Hat einen Moment geteilt';

  @override
  String get blossomOtherError => 'Fehler';

  @override
  String get languageTitle => 'Sprache';

  @override
  String get languageSystem => 'System';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageItalian => 'Italiano';

  @override
  String get cannotEditPhoto =>
      'Dieses Foto kann hier nicht bearbeitet werden.';

  @override
  String notificationsNew(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count neue Mitteilungen',
      one: '1 neue Mitteilung',
    );
    return '$_temp0';
  }

  @override
  String messagesUnread(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ungelesene Nachrichten',
      one: '1 ungelesene Nachricht',
    );
    return '$_temp0';
  }

  @override
  String get done => 'Fertig';

  @override
  String get storyAddText => 'Text hinzufügen';

  @override
  String get storyEditText => 'Text bearbeiten';

  @override
  String get storyTextHint => 'Schreib etwas… #hashtags sind antippbar';

  @override
  String get storyTextsHelp =>
      'Tippe auf das Bild, um zu schreiben. Ziehen zum Verschieben, kneifen zum Skalieren und Drehen, einen Text antippen zum Bearbeiten.';

  @override
  String storyTextsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Texte',
      one: '1 Text',
      zero: 'Kein Text',
    );
    return '$_temp0';
  }

  @override
  String get storyFontClassic => 'Klassisch';

  @override
  String get storyFontBold => 'Fett';

  @override
  String get storyFontSerif => 'Serif';

  @override
  String get storyFontMono => 'Mono';

  @override
  String get storyFontItalic => 'Kursiv';

  @override
  String get storyTextBackground => 'Texthintergrund';

  @override
  String get storyTextColor => 'Textfarbe';

  @override
  String storyTextLimit(int max) {
    return 'Du kannst bis zu $max Texte hinzufügen.';
  }

  @override
  String get wotTitle => 'Vertrauensnetz';

  @override
  String get wotEnable => 'Vertrauensnetz ist immer an';

  @override
  String wotExplain(int min) {
    return 'Immer an. Entdecken zeigt nur dieses Netz: dich, die Personen, denen du folgst, und alle, denen mindestens $min von ihnen folgen. Dasselbe Netz blendet Kommentare, Mitteilungen, private Beiträge und Nachrichten von allen anderen aus. Es wird auf diesem Telefon aus öffentlichen Folgen-Listen berechnet, wenn du die App zum ersten Mal öffnest; spätere Starts nutzen es wieder. Nichts wird an einen Server gesendet.';
  }

  @override
  String get wotRefresh => 'Netz jetzt aktualisieren';

  @override
  String get wotStatusIdle =>
      'Noch nicht aufgebaut. Es wird beim ersten Öffnen der App aufgebaut.';

  @override
  String get wotBuildingTitle => 'Dein Entdecken-Feed wird aufgebaut';

  @override
  String get wotBuildingBody =>
      'Es wird gelesen, wem die Personen, denen du folgst, auch folgen, und Entdecken wird vorbereitet.';

  @override
  String get wotDiscoverHint =>
      'Nur dein Vertrauensnetz: Personen, denen du folgst, und Personen, denen genug von ihnen folgen.';

  @override
  String get wotDiscoverSignIn =>
      'Entdecken zeigt dein Vertrauensnetz. Melde dich an und beim ersten Mal liest Mialuna, wem du folgst, und baut diesen Feed. Spätere Starts nutzen ihn wieder.';

  @override
  String get wotDiscoverEmpty =>
      'Noch keine Beiträge aus deinem Vertrauensnetz.';

  @override
  String wotStatusDiscovering(int done, int total) {
    return 'Prüfen, wem deine Follows folgen… $done von $total';
  }

  @override
  String wotStatusComplete(int direct, int indirect, Object when) {
    return 'Dein Netz: $direct Personen, denen du folgst, plus $indirect, denen genug von ihnen folgen. Aktualisiert $when.';
  }

  @override
  String wotStatusFailed(Object reason) {
    return 'Dein Netz konnte nicht berechnet werden: $reason';
  }

  @override
  String get wotNoFollows => 'du folgst noch niemandem';

  @override
  String get messageRequests => 'Nachrichtenanfragen';

  @override
  String messageRequestsSubtitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Unterhaltungen außerhalb deines Vertrauensnetzes',
      one: '1 Unterhaltung außerhalb deines Vertrauensnetzes',
    );
    return '$_temp0';
  }

  @override
  String get messageRequestsHint =>
      'Von Personen außerhalb deines Vertrauensnetzes. Sie zählen nicht als ungelesen. Antworte, um eine Unterhaltung in deinen Posteingang zu verschieben.';

  @override
  String get storyViewsSetting => 'Zeigen, dass ich ihre Stories gesehen habe';

  @override
  String get storyViewsSettingExplain =>
      'Wenn du eine Story ansiehst, geht eine Quittung an den Autor, verschlüsselt, sodass nur er sie lesen kann. Sie nennt deinen Namen neben seinem; relays sehen nichts. Wenn sie nicht zugestellt werden kann, wird sie behalten und später erneut versucht. Schalte es aus, um zuzusehen, ohne jemandem Bescheid zu sagen: noch nicht gesendete Quittungen werden verworfen (eine schon zugestellte kann nicht zurückgenommen werden).';

  @override
  String storySeenBy(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Von $count Personen gesehen',
      one: 'Von 1 Person gesehen',
      zero: 'Noch keine Aufrufe',
    );
    return '$_temp0';
  }

  @override
  String get storyViewsEmpty =>
      'Noch hat niemand diese Story angesehen, oder ihre Quittungen haben dich nicht erreicht.';

  @override
  String get storyViewsHint =>
      'Nur Personen, die es erlauben, senden eine Quittung, die echte Zahl kann also höher sein.';

  @override
  String get systemNotifications => 'Systemmitteilungen';

  @override
  String get systemNotificationsExplain =>
      'Zeigt eine Mitteilung auf deinem Telefon, wenn etwas Neues ankommt, während Mialuna im Hintergrund ist. Private Nachrichten zeigen nie ihren Text, auch nicht auf dem Sperrbildschirm. Android pausiert Apps, die lange im Hintergrund bleiben, daher kommen Mitteilungen, solange Mialuna noch läuft.';

  @override
  String get systemNotificationsBlocked =>
      'Mitteilungen sind für Mialuna in den Telefoneinstellungen ausgeschaltet.';

  @override
  String get systemNotificationsOpenSettings => 'Einstellungen öffnen';

  @override
  String get systemNotificationsBattery =>
      'Android versetzt Apps wenige Minuten nach dem Ausschalten des Bildschirms in den Schlaf, und die Mitteilungen hören mit auf. Um sie weiter zu erhalten, setze die Akkunutzung von Mialuna auf “Uneingeschränkt”.';

  @override
  String get systemNotificationsBatteryAction => 'Akku-Einstellungen öffnen';

  @override
  String get newFollowersSetting => 'Neue Follower anzeigen';

  @override
  String get newFollowersSettingExplain =>
      'Neue Follower erscheinen in Mitteilungen und auf deinem Telefon. Schalte es aus, wenn dich Folgen überfluten: Likes, Kommentare und zaps bleiben sichtbar.';

  @override
  String get systemNotificationMessage =>
      'hat dir eine private Nachricht gesendet';

  @override
  String get systemNotificationNewMessage => 'Neue private Nachricht';

  @override
  String get systemNotificationNew => 'Neue Mitteilung';

  @override
  String get notificationChannelSocial =>
      'Reaktionen, Kommentare, zaps und Follower';

  @override
  String get notificationChannelMessages => 'Private Nachrichten';

  @override
  String get zapInvoiceMismatch =>
      'Die Rechnung entspricht nicht dem gewählten Betrag. Es wurde nichts bezahlt.';

  @override
  String get storyYourStory => 'Deine Story';

  @override
  String get storyNew => 'Neue Story';

  @override
  String get storyAddSemantics => 'Zu deiner Story hinzufügen';

  @override
  String storyOwnRailLabel(int count, Object state) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Stories',
      one: '1 Story',
    );
    return 'Deine Story, $_temp0, $state';
  }

  @override
  String get storyTextSize => 'Textgröße';

  @override
  String get storyPickPrompt => 'Wähle ein Foto oder ein Video für deine Story';

  @override
  String get storyEditPhoto => 'Foto bearbeiten';

  @override
  String get storyCaption => 'Bildunterschrift';

  @override
  String get storyDiscardTitle => 'Diese Story verwerfen?';

  @override
  String get storyDiscard => 'Verwerfen';

  @override
  String get storyShare => 'Teilen';

  @override
  String get storyShared => 'Story geteilt';

  @override
  String get deletePost => 'Löschen';

  @override
  String get deletePostTitle => 'Diesen Beitrag löschen?';

  @override
  String get deleteStoryTitle => 'Diese Story löschen?';

  @override
  String get deletePostBody =>
      'Mialuna bittet deine relays, ihn zu löschen, und die Medienserver, seine Fotos oder sein Video zu löschen. Ein relay, der die Anfrage ignoriert, oder jemand, der schon eine Kopie gespeichert hat, kann ihn noch haben.';

  @override
  String get deletePrivateBody =>
      'Ein Beitrag für enge Freunde lässt sich nicht von den relays zurückholen. Mialuna sagt den Apps deiner Freunde, ihn zu entfernen, und bittet den Medienserver, die verschlüsselten Dateien zu löschen. Ein Freund, der schon eine Kopie gespeichert hat, kann sie noch haben.';

  @override
  String get deletingPost => 'Löschen…';

  @override
  String get postDeleted => 'Gelöscht.';

  @override
  String get postWasDeleted => 'Dieser Beitrag wurde gelöscht.';

  @override
  String get deleteNotAllowed =>
      'Nur das Konto, das dies veröffentlicht hat, kann es löschen.';

  @override
  String deleteFailed(Object reason) {
    return 'Löschen nicht möglich: $reason';
  }

  @override
  String get deleteNoRelay =>
      'Kein relay hat die Löschanfrage angenommen, er ist also noch online. Prüfe deine Verbindung und versuche es erneut.';

  @override
  String deleteMediaLeft(Object servers) {
    return 'Das Medium konnte nicht von $servers entfernt werden.';
  }

  @override
  String get deleteMediaNotAuthorized =>
      'Dein Signer hat das Entfernen des Mediums nicht erlaubt, die Dateien sind also noch auf dem Medienserver.';

  @override
  String deleteFriendsMissed(Object count) {
    return '$count deiner engen Freunde konnten nicht benachrichtigt werden, daher kann es auf ihren Telefonen bleiben.';
  }

  @override
  String get storyCleanupSetting => 'Meine Stories löschen, wenn sie ablaufen';

  @override
  String get storyCleanupSettingExplain =>
      'Nach 24 Stunden bittet Mialuna deine relays und deine Medienserver, deine Stories zu löschen, einschließlich Fotos und Videos. Ein Server, der die Anfrage ignoriert, oder jemand, der eine Kopie behalten hat, kann sie noch haben.';

  @override
  String storyCleanupWaiting(Object count) {
    return 'Dein Signer muss jedes Aufräumen genehmigen, deshalb wartet es, bis du es verlangst. Abgelaufene Stories in Warteschlange: $count.';
  }

  @override
  String get storyCleanupNow => 'Jetzt löschen';

  @override
  String get storyCleanupDone => 'Abgelaufene Stories gelöscht.';

  @override
  String get storyCleanupPartly =>
      'Einige konnten noch nicht gelöscht werden; Mialuna versucht es erneut.';

  @override
  String get editorPro => 'Profi-Editor';

  @override
  String get editorModeBasic => 'Einfach';

  @override
  String get editorModePro => 'Pro';

  @override
  String get toolCrop => 'Zuschnitt';

  @override
  String get toolLight => 'Licht';

  @override
  String get toolColor => 'Farbe';

  @override
  String get toolHsl => 'HSL';

  @override
  String get toolCurves => 'Kurven';

  @override
  String get toolEffects => 'Effekte';

  @override
  String get straighten => 'Ausrichten';

  @override
  String get exposure => 'Belichtung';

  @override
  String get highlights => 'Lichter';

  @override
  String get shadows => 'Tiefen';

  @override
  String get whites => 'Weiß';

  @override
  String get blacks => 'Schwarz';

  @override
  String get temperature => 'Temperatur';

  @override
  String get tint => 'Tönung';

  @override
  String get vibrance => 'Dynamik';

  @override
  String get hue => 'Farbton';

  @override
  String get luminance => 'Luminanz';

  @override
  String get colorRed => 'Rot';

  @override
  String get colorOrange => 'Orange';

  @override
  String get colorYellow => 'Gelb';

  @override
  String get colorGreen => 'Grün';

  @override
  String get colorAqua => 'Aquamarin';

  @override
  String get colorBlue => 'Blau';

  @override
  String get colorPurple => 'Lila';

  @override
  String get colorMagenta => 'Magenta';

  @override
  String get curveHint =>
      'Ziehe einen Punkt, um die Kurve zu formen, tippe zum Hinzufügen, doppeltippe zum Entfernen.';

  @override
  String get sharpen => 'Schärfe';

  @override
  String get vignette => 'Vignette';

  @override
  String get grain => 'Körnung';

  @override
  String get holdForOriginal =>
      'Halte das Foto gedrückt, um es mit dem Original zu vergleichen.';

  @override
  String get showingOriginal => 'Original';

  @override
  String get applyLookToAll => 'Diesen Look auf alle Fotos anwenden';

  @override
  String get applyingEdits => 'Fotos werden verarbeitet…';

  @override
  String get choosePhotoToEdit => 'Wähle ein Foto zum Bearbeiten';
}
