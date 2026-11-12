// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Dutch Flemish (`nl`).
class AppLocalizationsNl extends AppLocalizations {
  AppLocalizationsNl([String locale = 'nl']) : super(locale);

  @override
  String get syncUpToDate => 'Bijgewerkt';

  @override
  String get syncFailed => 'Sync mislukt';

  @override
  String get relaysUpdatedFromProfile =>
      'Relays bijgewerkt vanuit je profiel (NIP-65)';

  @override
  String get relayListPublished => 'Relay-lijst gepubliceerd';

  @override
  String get mediaServersUpdatedFromProfile =>
      'Mediaservers bijgewerkt vanuit je profiel';

  @override
  String get tabHome => 'Home';

  @override
  String get tabDiscover => 'Ontdekken';

  @override
  String get tabCreate => 'Maken';

  @override
  String get tabReels => 'Reels';

  @override
  String get tabProfile => 'Profiel';

  @override
  String get signInToUploadMedia => 'Inloggen om media te uploaden.';

  @override
  String get noMediaServer =>
      'Geen mediaserver ingesteld. Voeg er een toe in Instellingen.';

  @override
  String serverNoResponse(Object server) {
    return '$server: geen antwoord';
  }

  @override
  String serverUnreachable(Object server, Object error) {
    return '$server: onbereikbaar ($error)';
  }

  @override
  String uploadRejected(Object reason) {
    return 'Upload geweigerd — $reason';
  }

  @override
  String noServerAcceptedFile(Object reasons) {
    return 'Geen server accepteerde het bestand — $reasons';
  }

  @override
  String get blossomInvalidResponse => 'ongeldig antwoord';

  @override
  String get blossomInvalidFileUrl => 'ongeldig bestandsadres';

  @override
  String get blossomServerAlteredFile => 'de server wijzigde het bestand';

  @override
  String get blossomBadRequest => 'ongeldig verzoek';

  @override
  String get blossomUnauthorized => 'autorisatie geweigerd';

  @override
  String get blossomPaymentRequired => 'betaling vereist';

  @override
  String get blossomForbidden => 'niet toegestaan';

  @override
  String get blossomLengthRequired => 'grootte ontbreekt';

  @override
  String get blossomTooLarge => 'bestand te groot';

  @override
  String get blossomUnsupportedType => 'formaat niet geaccepteerd';

  @override
  String get blossomTooManyRequests => 'te veel verzoeken';

  @override
  String get blossomServerError => 'serverfout';

  @override
  String get cipherInvalidKey => 'Ongeldige sleutel';

  @override
  String get cipherTruncated => 'Versleuteld bestand is afgekapt';

  @override
  String get cipherMismatch =>
      'Het bestand past niet bij de sleutel: gewijzigd of beschadigd';

  @override
  String get sanitizeHeifNeedsAsync =>
      'HEIC/AVIF-formaat: conversie vereist sanitizeAsync';

  @override
  String get sanitizeWebmUnsupported =>
      'WebM/MKV-video wordt niet ondersteund: gebruik MP4 of MOV zodat de metadata vóór het uploaden verwijderd kunnen worden.';

  @override
  String get sanitizeUnknownFormat =>
      'Onbekend bestandsformaat: foto\'s JPEG/PNG/WebP/GIF of video\'s MP4/MOV.';

  @override
  String sanitizeLeftovers(Object items) {
    return 'Niet alle metadata verwijderd ($items): bestand niet geüpload.';
  }

  @override
  String sanitizeProcessingFailed(Object error) {
    return 'Bestand verwerken mislukt: $error';
  }

  @override
  String get sanitizeJpegInvalid => 'Ongeldige JPEG';

  @override
  String get sanitizeJpegTruncated => 'Afgekapte JPEG';

  @override
  String get sanitizeJpegNoSize => 'JPEG zonder afmetingen';

  @override
  String get sanitizeJpegUndecodable => 'JPEG kan niet worden gedecodeerd';

  @override
  String get sanitizePngTruncated => 'Afgekapte PNG';

  @override
  String get sanitizePngInvalid => 'Ongeldige PNG';

  @override
  String get sanitizeGifInvalid => 'Ongeldige GIF';

  @override
  String get sanitizeGifTruncated => 'Afgekapte GIF';

  @override
  String get sanitizeWebpTruncated => 'Afgekapte WebP';

  @override
  String get sanitizeWebpInvalid => 'Ongeldige WebP';

  @override
  String get sanitizeMp4Invalid => 'Ongeldige video MP4/MOV';

  @override
  String get sanitizeConversionFailed => 'Conversie mislukt';

  @override
  String get sanitizeHeifUnsupported =>
      'Dit formaat (HEIC/AVIF) kan op dit apparaat niet worden omgezet. Kies een foto JPEG of PNG.';

  @override
  String get privateMediaNotEncrypted => 'Media zijn niet versleuteld';

  @override
  String serverReplied(Object status) {
    return 'De server antwoordde $status';
  }

  @override
  String get fileTooLarge => 'Bestand te groot';

  @override
  String get serverFileNotOriginal =>
      'Het bestand op de server is niet het origineel';

  @override
  String get contentMismatch => 'De inhoud komt niet overeen';

  @override
  String get mediaUnreachable => 'Media onbereikbaar';

  @override
  String get amberInvalidKey => 'Amber gaf een ongeldige sleutel terug';

  @override
  String get amberNoKey => 'Amber gaf geen sleutel terug';

  @override
  String get amberRequestRejected => 'Verzoek geweigerd in Amber';

  @override
  String get amberAndroidOnly => 'Amber is alleen beschikbaar op Android';

  @override
  String get amberEmptySignature => 'Amber gaf een lege handtekening terug';

  @override
  String get amberSignRejected => 'Handtekening geweigerd in Amber';

  @override
  String get amberTimeout => 'Amber antwoordde niet op tijd';

  @override
  String get amberEmptyResponse => 'Amber gaf een leeg antwoord terug';

  @override
  String get bunkerInvalidUrl => 'Ongeldige bunker-URL';

  @override
  String get bunkerNoRelay => 'De bunker vermeldt geen enkele relay';

  @override
  String get bunkerWebAuth =>
      'De bunker vereist webautorisatie (auth_url wordt niet ondersteund)';

  @override
  String get bunkerInvalidKey => 'De bunker gaf geen geldige sleutel terug';

  @override
  String get signerInvalidResponse =>
      'De ondertekenaar gaf een ongeldig ondertekend event terug';

  @override
  String get bunkerTimeout => 'Bunker time-out';

  @override
  String get nwcInvalidUri => 'Ongeldige NWC-URI';

  @override
  String get nwcNoRelay => 'De NWC-URI vermeldt geen enkele relay';

  @override
  String get nwcNoSecret => 'De NWC-URI bevat geen geldig geheim';

  @override
  String get nwcTimeout => 'Wallet time-out';

  @override
  String get signerNoPrivateMessages =>
      'Deze inlogmethode ondersteunt geen privéberichten';

  @override
  String get zapNotSupported => 'Dit adres ondersteunt geen Nostr zaps';

  @override
  String zapAmountOutOfRange(Object min, Object max) {
    return 'Bedrag buiten bereik ($min–$max sats)';
  }

  @override
  String get commentNotSent =>
      'Reactie niet verstuurd. Probeer het later opnieuw.';

  @override
  String get comments => 'Reacties';

  @override
  String get noCommentsYet => 'Nog geen reacties.';

  @override
  String get signInToComment => 'Inloggen om te reageren.';

  @override
  String get addComment => 'Schrijf een reactie…';

  @override
  String get signInToPublish => 'Inloggen om te publiceren.';

  @override
  String get addMediaFirst =>
      'Voeg minstens één foto of video toe voor je publiceert.';

  @override
  String get removingMetadata => 'Metadata verwijderen…';

  @override
  String uploadingProgress(Object current, Object total) {
    return 'Uploaden $current van $total…';
  }

  @override
  String get creatingPreview => 'Voorbeeld maken…';

  @override
  String uploadFailed(Object error) {
    return 'Upload mislukt: $error';
  }

  @override
  String get publishing => 'Publiceren…';

  @override
  String noRelayAcceptedPost(Object reason) {
    return 'Geen relay accepteerde het bericht$reason. De inhoud blijft in je concepten.';
  }

  @override
  String get privateNeedsKeySigner =>
      'Deze inlogmethode ondersteunt geen privé-inhoud. Gebruik Amber, een bunker of de lokale sleutel.';

  @override
  String get closeFriendsListEmptyAddSomeone =>
      'Je lijst met goede vrienden is leeg: voeg iemand toe.';

  @override
  String get fileOver100Mb =>
      'Het bestand is groter dan 100 MB: dat is de limiet voor goede vrienden (het wordt volledig versleuteld op je telefoon).';

  @override
  String get encryptingOnPhone => 'Versleutelen op je telefoon…';

  @override
  String noServerAcceptedEncrypted(Object details) {
    return 'Geen van je mediaservers accepteerde het versleutelde bestand. Het wordt niet openbaar gepubliceerd. Voeg in Instellingen een server toe die versleutelde bestanden accepteert (bijvoorbeeld cdn.hzrd149.com). $details';
  }

  @override
  String get sendingToFriends => 'Versturen naar vrienden…';

  @override
  String sendingToFriendsProgress(Object done, Object total) {
    return 'Versturen naar vrienden $done/$total…';
  }

  @override
  String noFriendReceivedPost(Object reason) {
    return 'Geen vriend ontving het bericht$reason. De inhoud blijft in je concepten.';
  }

  @override
  String sentToCloseFriends(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Verstuurd naar $count goede vrienden 🔒',
      one: 'Verstuurd naar 1 goede vriend 🔒',
    );
    return '$_temp0';
  }

  @override
  String sentToFriendsWithMisses(int delivered, Object missed) {
    String _temp0 = intl.Intl.pluralLogic(
      delivered,
      locale: localeName,
      other: 'Verstuurd naar $delivered vrienden.',
      one: 'Verstuurd naar 1 vriend.',
    );
    return '$_temp0 $missed ontvingen het niet (privéberichten staan uit).';
  }

  @override
  String get altText => 'Alt-tekst';

  @override
  String get altTextHint => 'Beschrijf de inhoud voor wie het niet kan zien…';

  @override
  String get cancel => 'Annuleren';

  @override
  String get save => 'Opslaan';

  @override
  String get momentPublished => 'Moment gepubliceerd ✨';

  @override
  String get newMoment => 'Nieuw moment';

  @override
  String get publish => 'Publiceren';

  @override
  String get guestMode => 'Gastmodus';

  @override
  String get signInToPostMoments => 'Inloggen om je momenten te publiceren.';

  @override
  String get signIn => 'Inloggen';

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
      'Story\'s verlopen na 24 uur op relays die NIP-40 respecteren, maar anderen kunnen ze nog steeds opslaan of archiveren.';

  @override
  String get fromGallery => 'Uit galerij';

  @override
  String get galleryLongPressVideo => 'Galerij (lang indrukken voor video)';

  @override
  String get addVideo => 'Video toevoegen';

  @override
  String get camera => 'Camera';

  @override
  String get exifRemovedNote =>
      'Locatiemetadata (EXIF) worden automatisch verwijderd.';

  @override
  String get writeCaption => 'Schrijf een bijschrift…';

  @override
  String get privatePostNote =>
      'Privébericht: geen openbare hashtags, niet vindbaar via zoeken.';

  @override
  String willPublishAs(Object caption) {
    return 'Het wordt gepubliceerd als: \"$caption\"';
  }

  @override
  String get tapThumbnailForAlt =>
      'Tik een miniatuur aan om alt-tekst toe te voegen.';

  @override
  String get sensitiveContent => 'Gevoelige inhoud';

  @override
  String get sensitiveContentNote =>
      'Het bericht wordt verborgen achter een waarschuwing (NIP-36).';

  @override
  String get uploadingMedia => 'Media uploaden…';

  @override
  String get audiencePublic => 'Openbaar';

  @override
  String get closeFriends => 'Goede vrienden';

  @override
  String get signerCannotPublishCloseFriends =>
      'Met deze inlogmethode kun je niet publiceren voor goede vrienden: gebruik Amber, een bunker of de lokale sleutel.';

  @override
  String get closeFriendsEmptyPrompt =>
      'Je lijst is leeg: voeg de mensen toe die dit bericht mogen zien.';

  @override
  String onlyYourCloseFriendsSee(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Alleen je $count goede vrienden zien dit. Foto\'s en video\'s worden op je telefoon versleuteld voor ze worden geüpload.',
      one: 'Alleen je 1 goede vriend ziet dit. Foto\'s en video\'s worden op je telefoon versleuteld voor ze worden geüpload.',
    );
    return '$_temp0';
  }

  @override
  String get addFriends => 'Vrienden toevoegen';

  @override
  String get manageList => 'Lijst beheren';

  @override
  String get edit => 'Bewerken';

  @override
  String get reset => 'Reset';

  @override
  String get apply => 'Toepassen';

  @override
  String get cropFree => 'Vrij';

  @override
  String get cropOriginal => 'Origineel';

  @override
  String get rotate => 'Draaien';

  @override
  String get flip => 'Spiegelen';

  @override
  String get brightness => 'Helderheid';

  @override
  String get contrast => 'Contrast';

  @override
  String get saturation => 'Verzadiging';

  @override
  String postsByAuthor(Object author) {
    return 'Berichten van $author…';
  }

  @override
  String get searchHint => 'Zoek mensen, hashtags of woorden…';

  @override
  String get clear => 'Wissen';

  @override
  String get recent => 'Recent';

  @override
  String get searchDependsOnRelays =>
      'Zoeken hangt af van de ingestelde relays: resultaten kunnen onvolledig zijn.';

  @override
  String get recentPostsEverywhere =>
      'Recente berichten van het hele netwerk, ook van mensen die je niet volgt.';

  @override
  String get noResultsOnRelays => 'Geen resultaten op de ingestelde relays.';

  @override
  String get noRecentPostsFromFollowed =>
      'Geen recente berichten van mensen die je volgt.';

  @override
  String get noMomentsFound =>
      'Geen momenten gevonden op de relays. Controleer je verbinding.';

  @override
  String get loadFailed => 'Laden mislukt';

  @override
  String get notifications => 'Meldingen';

  @override
  String get messages => 'Berichten';

  @override
  String get homeEmptyFollowsNobody =>
      'Berichten van mensen die je volgt verschijnen hier.\nJe volgt nog niemand: ontdek interessante mensen en profielen.';

  @override
  String get discoverPeople => 'Ontdek mensen';

  @override
  String get homeEmpty =>
      'Nog geen momenten.\nTrek omlaag om te vernieuwen of publiceer je eerste foto.';

  @override
  String get retry => 'Opnieuw proberen';

  @override
  String get seenEverything => 'Je hebt voorlopig alles gezien ✨';

  @override
  String get discoverMoreProfiles => 'Ontdek meer profielen';

  @override
  String get feedFollowing => 'Volgend';

  @override
  String get signInToSeeFollowed =>
      'Inloggen om berichten te zien van mensen die je volgt';

  @override
  String get videoPreview => 'Videovoorbeeld';

  @override
  String get cannotOpenPrivateVideo => 'Kan de privévideo niet openen';

  @override
  String get cannotPlayVideo => 'Kan de video niet afspelen';

  @override
  String get pauseVideo => 'Video pauzeren';

  @override
  String get playVideo => 'Video afspelen';

  @override
  String errorTapToRetry(Object error) {
    return '$error — tik om opnieuw te proberen';
  }

  @override
  String get soundOn => 'Geluid aanzetten';

  @override
  String get soundOff => 'Geluid uitzetten';

  @override
  String get postImage => 'Berichtafbeelding';

  @override
  String get imageUnavailable => 'Afbeelding niet beschikbaar';

  @override
  String errorTapToRetryNewline(Object message) {
    return '$message\nTik om opnieuw te proberen';
  }

  @override
  String get cannotOpenPrivateContent => 'Kan deze privé-inhoud niet openen';

  @override
  String get privateImage => 'Privéafbeelding';

  @override
  String get invalidImage => 'Ongeldige afbeelding';

  @override
  String get more => 'Meer';

  @override
  String get removeFromSaved => 'Verwijderen uit opgeslagen';

  @override
  String get copyLink => 'Link kopiëren';

  @override
  String get muteAuthor => 'Auteur dempen';

  @override
  String get blockAuthor => 'Auteur blokkeren';

  @override
  String get report => 'Rapporteren';

  @override
  String get like => 'Leuk';

  @override
  String get sendInMessage => 'Versturen in een bericht';

  @override
  String get zapOptional => 'Zap (optioneel)';

  @override
  String get closeFriendsOnlyNote =>
      'Alleen zichtbaar voor goede vrienden. Likes en reacties gaan alleen naar de auteur.';

  @override
  String get likeFailed => 'Like versturen mislukt';

  @override
  String get nostrLinkCopied => 'Nostr-link gekopieerd naar het klembord';

  @override
  String get authorMuted => 'Auteur gedempt';

  @override
  String get authorBlocked => 'Auteur geblokkeerd';

  @override
  String get reportSent => 'Melding verstuurd (NIP-56)';

  @override
  String get signInToReport => 'Inloggen om te rapporteren';

  @override
  String minutesAgo(Object minutes) {
    return '$minutes min geleden';
  }

  @override
  String get show => 'Tonen';

  @override
  String get chatEmptyHint =>
      'Schrijf het eerste bericht.\nHet is versleuteld: alleen jullie twee kunnen het zien.';

  @override
  String get messageHint => 'Bericht…';

  @override
  String get send => 'Versturen';

  @override
  String get notSentSuffix => ' niet verstuurd';

  @override
  String get contentUnavailable =>
      'Inhoud niet beschikbaar (verlopen of niet gevonden op de relays)';

  @override
  String get signInToSendPrivateMessages =>
      'Inloggen om privéberichten te versturen.';

  @override
  String get cannotMessageYourself => 'Je kunt niet naar jezelf schrijven.';

  @override
  String get recipientNoPrivateMessages =>
      'Deze persoon heeft privéberichten nog niet aangezet.';

  @override
  String noRecipientRelayAccepted(Object reason) {
    return 'Geen relay van de ontvanger accepteerde het bericht$reason.';
  }

  @override
  String sendFailed(Object error) {
    return 'Versturen mislukt: $error';
  }

  @override
  String get signInToReadMessages =>
      'Inloggen om privéberichten te lezen en te versturen.';

  @override
  String get signerNoPrivateMessagesLong =>
      'Privéberichten werken niet met deze inlogmethode. Log in met Amber, een bunker of de lokale sleutel.';

  @override
  String get inboxEmpty =>
      'Geen gesprekken.\nTik op het potlood om iemand te schrijven, of stuur een moment door met het ✈-pictogram onder elk bericht.';

  @override
  String get newMessage => 'Nieuw bericht';

  @override
  String get privateMessagesEnabled => 'Privéberichten aangezet';

  @override
  String get enableMessagesFailed => 'Aanzetten mislukt. Probeer opnieuw.';

  @override
  String get enablePrivateMessages => 'Privéberichten aanzetten';

  @override
  String enablePrivateMessagesExplain(Object count) {
    return 'Om berichten te ontvangen moet je aangeven op welke relays ze binnenkomen. Er wordt een korte lijst (NIP-17) gepubliceerd met $count standaard relays: je kunt die later wijzigen. Berichten blijven versleuteld: relays zien niet wie schrijft en ook niet de tekst.';
  }

  @override
  String get turnOn => 'Aanzetten';

  @override
  String get searchByNameOrUsername => 'Zoek op naam of gebruikersnaam';

  @override
  String get searching => 'Zoeken…';

  @override
  String get noOneWithNameHint =>
      'Niemand met deze naam. Probeer minder letters of een adres zoals name@domain.com.';

  @override
  String get sent => 'Verstuurd';

  @override
  String sentToPeople(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Verstuurd naar $count personen',
      one: 'Verstuurd naar 1 persoon',
    );
    return '$_temp0';
  }

  @override
  String sentToPeopleWithFailure(int count, Object failure) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Verstuurd naar $count personen. $failure',
      one: 'Verstuurd naar 1 persoon. $failure',
    );
    return '$_temp0';
  }

  @override
  String get signerNoPrivateMessagesShort =>
      'Je kunt geen privéberichten gebruiken met deze inlogmethode.';

  @override
  String get followToStartOrSearch =>
      'Volg iemand om te beginnen, of zoek op naam.';

  @override
  String get addMessage => 'Voeg een bericht toe…';

  @override
  String sendWithCount(Object count) {
    return 'Versturen ($count)';
  }

  @override
  String get linkCopied => 'Link gekopieerd naar het klembord';

  @override
  String get noNotifications => 'Nu geen meldingen.';

  @override
  String get notificationsDependOnRelays =>
      'Meldingen hangen af van relays: ze kunnen onvolledig zijn.';

  @override
  String get reactedToYourMoment => 'reageerde op je moment';

  @override
  String commentedText(Object text) {
    return 'reageerde: $text';
  }

  @override
  String sentYouSats(Object sats, Object comment) {
    return 'stuurde je $sats sats$comment';
  }

  @override
  String get sentYouZap => 'stuurde je een zap';

  @override
  String get startedFollowingYou => 'volgt je nu';

  @override
  String get amberNotFound => 'Amber niet gevonden';

  @override
  String get amberExplain =>
      'Amber is een Nostr-signer die je privésleutel buiten Mialuna houdt. Installeer de app en probeer opnieuw.';

  @override
  String get downloadFromFdroid => 'Downloaden van F-Droid';

  @override
  String get continueWithAmber => 'Doorgaan met Amber';

  @override
  String get amberRecommended =>
      'Aanbevolen: je privésleutel blijft veilig in Amber.';

  @override
  String get amberNotDetected =>
      'Amber niet gevonden: installeer de app voor de aanbevolen manier van inloggen.';

  @override
  String get exploreWithoutAccount => 'Ontdekken zonder account';

  @override
  String get remoteBunker => 'Externe bunker (NIP-46)';

  @override
  String get invalidBunkerUrlDot => 'Ongeldige bunker-URL.';

  @override
  String get connectBunker => 'Bunker verbinden';

  @override
  String get advancedNsec => 'Geavanceerd inloggen (nsec)';

  @override
  String get nsecWarning =>
      'Waarschuwing: je privésleutel plakken is riskant. Deel die nooit met iemand. Op Android heeft Amber de voorkeur.';

  @override
  String get invalidNsec => 'Ongeldige nsec-sleutel.';

  @override
  String get signInWithNsec => 'Inloggen met nsec';

  @override
  String get tagline => 'Je momenten, onder dezelfde maan.';

  @override
  String get skip => 'Overslaan';

  @override
  String get permissionsAndWallet => 'Rechten en wallet';

  @override
  String get permissionsExplain =>
      'Ze laten je alleen publiceren en meldingen ontvangen. Je kunt ze altijd wijzigen in de systeeminstellingen.';

  @override
  String get photosAndVideos => 'Foto\'s en video\'s';

  @override
  String get toUploadYourMoments => 'Om je momenten te uploaden';

  @override
  String get allow => 'Toestaan';

  @override
  String get reactionsCommentsZaps => 'Reacties, opmerkingen en zaps';

  @override
  String get lightningWalletOptional => 'Lightning-wallet (optioneel)';

  @override
  String get nwcExplain =>
      'Koppel een Nostr Wallet Connect-wallet om zaps te sturen zonder de app te verlaten.';

  @override
  String get walletConnected => 'Wallet gekoppeld';

  @override
  String get disconnect => 'Ontkoppelen';

  @override
  String get connectWallet => 'Wallet koppelen';

  @override
  String get getStarted => 'Aan de slag';

  @override
  String get welcome1 =>
      'Mialuna is een visueel sociaal netwerk: foto\'s, video\'s, Reels en story\'s — nooit alleen tekst.';

  @override
  String get welcome2 =>
      'Het draait op Nostr, een open protocol: je identiteit is een sleutel die van jou is, geen account dat een bedrijf kan afpakken. Geen advertenties, geen trackers, geen centrale servers.';

  @override
  String get welcome3 =>
      'Deel je licht met mensen overal, vanuit elke app die dezelfde open taal spreekt.';

  @override
  String onboardingWot(int min) {
    return 'Het vertrouwensnetwerk staat altijd aan. De eerste keer dat je Mialuna opent, leest de app wie je volgt en bouwt de feed Ontdekken vanuit dat netwerk: jij, de mensen die je volgt, en wie minstens $min van hen volgen. De volgende keren dat je de app opent, staat die feed er al.';
  }

  @override
  String get publicAndPrivate => 'Openbaar en privé';

  @override
  String get publicAndPrivateIntro =>
      'Mialuna is gebouwd op Nostr, een open netwerk. Wat je publiceert is openbaar: berichten, foto\'s en video\'s blijven zichtbaar voor iedereen met de link, ook buiten Mialuna.';

  @override
  String get closeFriendsExplain1 =>
      'Alleen de mensen op deze lijst ontvangen je berichten, story\'s en video\'s voor \"Goede vrienden\". De lijst zit in het bericht; je hoeft die niet elke keer te kiezen.';

  @override
  String get closeFriendsExplain2 =>
      'Foto\'s en video\'s worden op je telefoon versleuteld voor ze worden geüpload. Bestandsservers (Blossom) versleutelen zelf niets: daarom doet Mialuna dat, en de server ziet alleen onleesbare data. Wie het bestandsadres vindt, kan het niet openen.';

  @override
  String get closeFriendsExplain3 =>
      'Het is geen absolute garantie: wie een bericht ontvangt, kan een schermafbeelding maken, en een vriend verwijderen geldt alleen voor toekomstige berichten.';

  @override
  String get closeFriendsExplain4 =>
      'Elke vriend moet Mialuna gebruiken met privéberichten aan. Andere Nostr-clients tonen deze berichten niet.';

  @override
  String get closeFriendsExplain5 =>
      'Openbare berichten blijven openbaar: hun bestanden zijn zichtbaar voor iedereen met de link.';

  @override
  String get closeFriendsExplain6 =>
      'Als geen van je servers versleutelde bestanden accepteert, wordt het bericht niet gepubliceerd: nooit leesbaar.';

  @override
  String get addToCloseFriends => 'Toevoegen aan goede vrienden';

  @override
  String maxFriendsReached(Object max, Object added) {
    return 'Limiet van $max vrienden: $added toegevoegd.';
  }

  @override
  String get add => 'Toevoegen';

  @override
  String get signInToCreateList => 'Inloggen om je lijst te maken.';

  @override
  String get signerNoCloseFriends =>
      'Goede vrienden werken niet met deze inlogmethode. Log in met Amber, een bunker of de lokale sleutel.';

  @override
  String peopleOfMax(Object count, Object max) {
    return '$count / $max personen';
  }

  @override
  String get noOneYet => 'Nog niemand.';

  @override
  String get addPeople => 'Mensen toevoegen';

  @override
  String get friendNoPrivateMessagesWarning =>
      'Ze hebben privéberichten niet aangezet: ze ontvangen je berichten niet';

  @override
  String get removeFromList => 'Verwijderen uit de lijst';

  @override
  String get noOneWithThisName => 'Niemand met deze naam.';

  @override
  String get signInToSendPrivateContent =>
      'Inloggen om privé-inhoud te versturen.';

  @override
  String get reasonNoPrivateMessages => 'heeft privéberichten niet aangezet';

  @override
  String get reasonNoRelayAnswered => 'geen relay antwoordde';

  @override
  String get profileUpdated => 'Profiel bijgewerkt';

  @override
  String get noRelayAcceptedRetry =>
      'Geen relay accepteerde het. Probeer het later opnieuw.';

  @override
  String get editProfile => 'Profiel bewerken';

  @override
  String get fieldName => 'Naam';

  @override
  String get fieldBio => 'Bio';

  @override
  String get fieldAvatarUrl => 'Avatar-URL';

  @override
  String get fieldNip05 => 'NIP-05 (bijv. you@example.com)';

  @override
  String get browsingAsGuest => 'Je bladert als gast';

  @override
  String get signInToInteract =>
      'Inloggen om te publiceren, te volgen en te reageren.';

  @override
  String get settings => 'Instellingen';

  @override
  String get signOut => 'Uitloggen';

  @override
  String get npubCopied => 'npub gekopieerd';

  @override
  String get copyNpub => 'npub kopiëren';

  @override
  String get mute => 'Dempen';

  @override
  String get block => 'Blokkeren';

  @override
  String get posts => 'Berichten';

  @override
  String get saved => 'Opgeslagen';

  @override
  String get nothingPublishedYet => 'Je hebt nog niets gepubliceerd.';

  @override
  String get noPostsOnRelays => 'Geen berichten gevonden op de relays.';

  @override
  String get noReelsPublished => 'Geen reels gepubliceerd.';

  @override
  String get noReelsOnRelays => 'Geen reels gevonden op de relays.';

  @override
  String get noSavedPosts => 'Geen opgeslagen berichten.';

  @override
  String get followingButton => 'Volgend';

  @override
  String get follow => 'Volgen';

  @override
  String get messageButton => 'Bericht';

  @override
  String get loginLocalKey => 'Lokale sleutel';

  @override
  String get loginGuest => 'Gast';

  @override
  String get followUpdateFailed =>
      'Je gevolgde accounts konden nu niet worden bijgewerkt. Probeer opnieuw.';

  @override
  String get noReelsComeBack =>
      'Geen reels gevonden op de relays.\nKom snel terug!';

  @override
  String get followUpdateFailedShort =>
      'Je gevolgde accounts konden nu niet worden bijgewerkt';

  @override
  String get needOneReadRelay => 'Minstens één lees-relay is vereist.';

  @override
  String get listSavedLocally =>
      'Lijst opgeslagen op dit apparaat, niet gepubliceerd.';

  @override
  String get noRelayAcceptedList =>
      'Geen relay accepteerde de lijst: het wordt later opnieuw geprobeerd.';

  @override
  String relayListPublishedTo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Relay-lijst gepubliceerd naar $count relays',
      one: 'Relay-lijst gepubliceerd naar 1 relay',
    );
    return '$_temp0';
  }

  @override
  String get mediaServersUpdated => 'Mediaservers bijgewerkt';

  @override
  String get appearance => 'Weergave';

  @override
  String get publishingSettings => 'Publiceren';

  @override
  String get addMialunaHashtag => '#mialuna toevoegen';

  @override
  String get addMialunaHashtagNote =>
      'Voeg de officiële hashtag toe aan openbare berichten en story\'s. Je kunt dit altijd uitzetten.';

  @override
  String get themeLight => 'Licht';

  @override
  String get themeDark => 'Donker';

  @override
  String get themeSystem => 'Systeem';

  @override
  String get relays => 'Relays';

  @override
  String get relaysExplainSignedOut =>
      'Relays bewaren en verspreiden inhoud. Inloggen om automatisch je eigen lijst te gebruiken (NIP-65).';

  @override
  String get relaysExplainSynced =>
      'De lijst is gesynchroniseerd met je Nostr-profiel (NIP-65): elke wijziging wordt gepubliceerd en geldt voor al je apps.';

  @override
  String get syncing => 'Synchroniseren…';

  @override
  String get waitingFirstSync => 'Wachten op de eerste sync';

  @override
  String get syncNow => 'Nu synchroniseren';

  @override
  String get addRelay => 'relay toevoegen';

  @override
  String get restoreDefaultRelays => 'Standaard relays herstellen';

  @override
  String get createYourList => 'Maak je lijst';

  @override
  String peopleCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count personen',
      one: '1 persoon',
    );
    return '$_temp0';
  }

  @override
  String get closeFriendsSettingsNote =>
      'Berichten, story\'s en video\'s alleen voor hen zichtbaar, met versleutelde foto\'s en video\'s.';

  @override
  String get mediaServersBlossom => 'Mediaservers (Blossom)';

  @override
  String get mediaServersExplain =>
      'Foto\'s en video\'s worden alleen naar deze servers geüpload, in de getoonde volgorde: de eerste die ze accepteert, wint. EXIF en locatie worden voor het uploaden verwijderd.';

  @override
  String get primary => 'Primair';

  @override
  String get makePrimary => 'Primair maken';

  @override
  String get remove => 'Verwijderen';

  @override
  String get addServer => 'Server toevoegen';

  @override
  String get moderation => 'Moderatie';

  @override
  String get moderationExplain =>
      'Gedempte auteurs en verborgen hashtags worden gesynchroniseerd via NIP-51. Geblokkeerde auteurs blijven alleen op dit apparaat.';

  @override
  String get mutedAuthors => 'Gedempte auteurs';

  @override
  String get noMutedAuthors => 'Geen gedempte auteurs';

  @override
  String get blockedAuthors => 'Geblokkeerde auteurs';

  @override
  String get noBlockedAuthors => 'Geen geblokkeerde auteurs';

  @override
  String get hiddenHashtags => 'Verborgen hashtags';

  @override
  String get noHiddenHashtags => 'Geen verborgen hashtags';

  @override
  String get hashtagToHide => '#hashtag om te verbergen';

  @override
  String get storage => 'Opslag';

  @override
  String get clearCache => 'Eventcache en concepten wissen';

  @override
  String get cacheCleared => 'Cache gewist';

  @override
  String get reviewIntro => 'Introductie opnieuw bekijken';

  @override
  String get reviewIntroSubtitle =>
      'Wat openbaar is, wat privé is, en de grenzen van goede vrienden.';

  @override
  String noLightningWalletCopied(Object address) {
    return 'Geen Lightning-wallet gevonden: adres gekopieerd ($address)';
  }

  @override
  String get about => 'Over';

  @override
  String aboutText(Object version) {
    return 'Mialuna $version — Je momenten, onder dezelfde maan.\nOpen source (MIT). github.com/Lwb89dev/mialuna';
  }

  @override
  String get invalidRelayAddress => 'Ongeldig adres: gebruik wss://…';

  @override
  String get invalidServerAddress => 'Ongeldig adres: gebruik https://…';

  @override
  String get relayRead => 'Lezen';

  @override
  String get relayWrite => 'Schrijven';

  @override
  String get support => 'Steun';

  @override
  String get supportText =>
      'Mialuna is gratis, heeft geen advertenties en volgt je niet. Als je het fijn vindt, kun je een paar sats sturen via het Lightning Network.';

  @override
  String get donateWithLightning => 'Doneren met Lightning';

  @override
  String get authorNoZaps => 'Deze auteur accepteert geen zaps';

  @override
  String get sendZap => 'Stuur een zap ⚡';

  @override
  String get amountInSats => 'Bedrag in sats';

  @override
  String minMaxSats(Object min, Object max) {
    return 'min $min – max $max';
  }

  @override
  String get zap => 'Zap';

  @override
  String get signInToZap => 'Inloggen om zaps te sturen';

  @override
  String zapSent(Object sats) {
    return 'Zap van $sats sats verstuurd ⚡';
  }

  @override
  String nwcPaymentFailed(Object error) {
    return 'NWC-betaling mislukt: $error';
  }

  @override
  String get noLightningWallet => 'Geen Lightning-wallet gevonden';

  @override
  String storiesRailLabel(Object state) {
    return 'Story\'s, $state';
  }

  @override
  String get close => 'Sluiten';

  @override
  String hoursAgo(int hours) {
    return '$hours u geleden';
  }

  @override
  String daysAgo(int days) {
    return '$days d geleden';
  }

  @override
  String get now => 'nu';

  @override
  String get youPrefix => 'Je: ';

  @override
  String get storiesStateUnseen => 'nieuw';

  @override
  String get storiesStateSeen => 'gezien';

  @override
  String weekdayShort(String day) {
    String _temp0 = intl.Intl.selectLogic(day, {
      'mon': 'ma',
      'tue': 'di',
      'wed': 'wo',
      'thu': 'do',
      'fri': 'vr',
      'sat': 'za',
      'sun': 'zo',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get sharedAMoment => 'Deelde een moment';

  @override
  String get blossomOtherError => 'fout';

  @override
  String get languageTitle => 'Taal';

  @override
  String get languageSystem => 'Systeem';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageItalian => 'Italiano';

  @override
  String get cannotEditPhoto => 'Deze foto kan hier niet worden bewerkt.';

  @override
  String notificationsNew(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count nieuwe meldingen',
      one: '1 nieuwe melding',
    );
    return '$_temp0';
  }

  @override
  String messagesUnread(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ongelezen berichten',
      one: '1 ongelezen bericht',
    );
    return '$_temp0';
  }

  @override
  String get done => 'Klaar';

  @override
  String get storyAddText => 'Tekst toevoegen';

  @override
  String get storyEditText => 'Tekst bewerken';

  @override
  String get storyTextHint => 'Schrijf iets… #hashtags zijn tikbaar';

  @override
  String get storyTextsHelp =>
      'Tik op de foto om te schrijven. Sleep om te verplaatsen, knijp om te schalen en te draaien, tik een tekst aan om die te bewerken.';

  @override
  String storyTextsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count teksten',
      one: '1 tekst',
      zero: 'Geen tekst',
    );
    return '$_temp0';
  }

  @override
  String get storyFontClassic => 'Klassiek';

  @override
  String get storyFontBold => 'Vet';

  @override
  String get storyFontSerif => 'Serif';

  @override
  String get storyFontMono => 'Mono';

  @override
  String get storyFontItalic => 'Cursief';

  @override
  String get storyTextBackground => 'Tekstachtergrond';

  @override
  String get storyTextColor => 'Tekstkleur';

  @override
  String storyTextLimit(int max) {
    return 'Je kunt maximaal $max teksten toevoegen.';
  }

  @override
  String get wotTitle => 'Vertrouwensnetwerk';

  @override
  String get wotEnable => 'Vertrouwensnetwerk staat altijd aan';

  @override
  String wotExplain(int min) {
    return 'Altijd aan. Ontdekken toont alleen dit netwerk: jij, de mensen die je volgt, en wie door minstens $min van hen wordt gevolgd. Hetzelfde netwerk verbergt reacties, meldingen, privéberichten en berichten van alle anderen. Het wordt op deze telefoon berekend uit openbare volglijsten de eerste keer dat je de app opent; latere keren wordt dat hergebruikt. Er wordt niets naar een server gestuurd.';
  }

  @override
  String get wotRefresh => 'Netwerk nu verversen';

  @override
  String get wotStatusIdle =>
      'Nog niet opgebouwd. Dat gebeurt de eerste keer dat je de app opent.';

  @override
  String get wotBuildingTitle => 'Feed Ontdekken opbouwen';

  @override
  String get wotBuildingBody =>
      'Lezen wie de mensen die je volgt ook volgen, en Ontdekken voorbereiden.';

  @override
  String get wotDiscoverHint =>
      'Alleen je vertrouwensnetwerk: mensen die je volgt, en mensen die genoeg van hen volgen.';

  @override
  String get wotDiscoverSignIn =>
      'Ontdekken toont je vertrouwensnetwerk. Log in en de eerste keer leest Mialuna wie je volgt en bouwt deze feed. Latere keren wordt die hergebruikt.';

  @override
  String get wotDiscoverEmpty =>
      'Nog geen berichten uit je vertrouwensnetwerk.';

  @override
  String wotStatusDiscovering(int done, int total) {
    return 'Controleren wie je gevolgde accounts volgen… $done van $total';
  }

  @override
  String wotStatusComplete(int direct, int indirect, Object when) {
    return 'Je netwerk: $direct mensen die je volgt plus $indirect die genoeg van hen volgen. Bijgewerkt $when.';
  }

  @override
  String wotStatusFailed(Object reason) {
    return 'Je netwerk kon niet worden berekend: $reason';
  }

  @override
  String get wotNoFollows => 'je volgt nog niemand';

  @override
  String get messageRequests => 'Berichtverzoeken';

  @override
  String messageRequestsSubtitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count gesprekken van buiten je vertrouwensnetwerk',
      one: '1 gesprek van buiten je vertrouwensnetwerk',
    );
    return '$_temp0';
  }

  @override
  String get messageRequestsHint =>
      'Van mensen buiten je vertrouwensnetwerk. Ze tellen niet als ongelezen. Antwoord om een gesprek naar je inbox te verplaatsen.';

  @override
  String get storyViewsSetting =>
      'Laat mensen zien dat ik hun story\'s heb bekeken';

  @override
  String get storyViewsSettingExplain =>
      'Als je een story bekijkt, gaat er een ontvangstbevestiging naar de auteur, versleuteld zodat alleen diegene die kan lezen. Je naam staat naast die van hen; relays zien niets. Lukt de bezorging niet, dan blijft die bewaard en wordt het later opnieuw geprobeerd. Zet het uit om te kijken zonder het iemand te vertellen: nog niet verstuurde bevestigingen worden verwijderd (een al bezorgde kun je niet terugnemen).';

  @override
  String storySeenBy(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Gezien door $count personen',
      one: 'Gezien door 1 persoon',
      zero: 'Nog geen weergaven',
    );
    return '$_temp0';
  }

  @override
  String get storyViewsEmpty =>
      'Nog niemand heeft deze story bekeken, of hun bevestigingen hebben je niet bereikt.';

  @override
  String get storyViewsHint =>
      'Alleen mensen die het toestaan sturen een bevestiging, dus het echte aantal kan hoger zijn.';

  @override
  String get systemNotifications => 'Systeemmeldingen';

  @override
  String get systemNotificationsExplain =>
      'Toon een melding op je telefoon als er iets nieuws binnenkomt terwijl Mialuna op de achtergrond staat. Privéberichten tonen nooit hun tekst, ook niet op het vergrendelscherm. Android pauzeert apps die lang op de achtergrond blijven, dus meldingen komen binnen zolang Mialuna nog draait.';

  @override
  String get systemNotificationsBlocked =>
      'Meldingen voor Mialuna staan uit in de instellingen van de telefoon.';

  @override
  String get systemNotificationsOpenSettings => 'Instellingen openen';

  @override
  String get systemNotificationsBattery =>
      'Android zet apps een paar minuten na het uitzetten van het scherm in slaap, en de meldingen stoppen mee. Om ze te blijven ontvangen, zet het batterijgebruik van Mialuna op “Onbeperkt”.';

  @override
  String get systemNotificationsBatteryAction => 'Batterij-instellingen openen';

  @override
  String get newFollowersSetting => 'Nieuwe volgers tonen';

  @override
  String get newFollowersSettingExplain =>
      'Nieuwe volgers verschijnen in Meldingen en op je telefoon. Zet het uit als mensen je overspoelen met volgen: likes, reacties en zaps blijven zichtbaar.';

  @override
  String get systemNotificationMessage => 'stuurde je een privébericht';

  @override
  String get systemNotificationNewMessage => 'Nieuw privébericht';

  @override
  String get systemNotificationNew => 'Nieuwe melding';

  @override
  String get notificationChannelSocial =>
      'Reacties, opmerkingen, zaps en volgers';

  @override
  String get notificationChannelMessages => 'Privéberichten';

  @override
  String get zapInvoiceMismatch =>
      'De factuur komt niet overeen met het gekozen bedrag. Er is niets betaald.';

  @override
  String get storyYourStory => 'Je story';

  @override
  String get storyNew => 'Nieuwe story';

  @override
  String get storyAddSemantics => 'Toevoegen aan je story';

  @override
  String storyOwnRailLabel(int count, Object state) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count story\'s',
      one: '1 story',
    );
    return 'Je story, $_temp0, $state';
  }

  @override
  String get storyTextSize => 'Tekstgrootte';

  @override
  String get storyPickPrompt => 'Kies een foto of video voor je story';

  @override
  String get storyEditPhoto => 'Foto bewerken';

  @override
  String get storyCaption => 'Bijschrift';

  @override
  String get storyDiscardTitle => 'Deze story weggooien?';

  @override
  String get storyDiscard => 'Weggooien';

  @override
  String get storyShare => 'Delen';

  @override
  String get storyShared => 'Story gedeeld';

  @override
  String get deletePost => 'Verwijderen';

  @override
  String get deletePostTitle => 'Dit bericht verwijderen?';

  @override
  String get deleteStoryTitle => 'Deze story verwijderen?';

  @override
  String get deletePostBody =>
      'Mialuna vraagt je relays het te verwijderen en de mediaservers de foto\'s of video te verwijderen. Een relay die het verzoek negeert, of iemand die al een kopie heeft opgeslagen, kan het nog hebben.';

  @override
  String get deletePrivateBody =>
      'Een bericht voor goede vrienden kan niet worden teruggehaald van de relays. Mialuna vraagt de apps van je vrienden het te verwijderen en de mediaserver de versleutelde bestanden te wissen. Een vriend die al een kopie heeft opgeslagen, kan die nog hebben.';

  @override
  String get deletingPost => 'Verwijderen…';

  @override
  String get postDeleted => 'Verwijderd.';

  @override
  String get postWasDeleted => 'Dit bericht is verwijderd.';

  @override
  String get deleteNotAllowed =>
      'Alleen het account dat dit publiceerde, kan het verwijderen.';

  @override
  String deleteFailed(Object reason) {
    return 'Verwijderen mislukt: $reason';
  }

  @override
  String get deleteNoRelay =>
      'Geen relay accepteerde het verwijderverzoek, dus het staat nog online. Controleer je verbinding en probeer opnieuw.';

  @override
  String deleteMediaLeft(Object servers) {
    return 'De media konden niet worden verwijderd van $servers.';
  }

  @override
  String get deleteMediaNotAuthorized =>
      'Je signer heeft het verwijderen van de media niet toegestaan, dus de bestanden staan nog op de mediaserver.';

  @override
  String deleteFriendsMissed(Object count) {
    return '$count van je goede vrienden konden niet worden bereikt, dus het kan op hun telefoon blijven staan.';
  }

  @override
  String get storyCleanupSetting => 'Verwijder mijn story\'s als ze verlopen';

  @override
  String get storyCleanupSettingExplain =>
      'Na 24 uur vraagt Mialuna je relays en je mediaservers je story\'s te verwijderen, inclusief foto\'s en video\'s. Een server die het verzoek negeert, of iemand die een kopie bewaarde, kan ze nog hebben.';

  @override
  String storyCleanupWaiting(Object count) {
    return 'Je signer moet elke opruiming goedkeuren, dus die wacht tot je het vraagt. Verlopen story\'s in de wacht: $count.';
  }

  @override
  String get storyCleanupNow => 'Nu verwijderen';

  @override
  String get storyCleanupDone => 'Verlopen story\'s verwijderd.';

  @override
  String get storyCleanupPartly =>
      'Sommige konden nog niet worden verwijderd; Mialuna probeert het opnieuw.';

  @override
  String get editorPro => 'Pro-editor';

  @override
  String get editorModeBasic => 'Basis';

  @override
  String get editorModePro => 'Pro';

  @override
  String get toolCrop => 'Bijsnijden';

  @override
  String get toolLight => 'Licht';

  @override
  String get toolColor => 'Kleur';

  @override
  String get toolHsl => 'HSL';

  @override
  String get toolCurves => 'Curven';

  @override
  String get toolEffects => 'Effecten';

  @override
  String get straighten => 'Rechtzetten';

  @override
  String get exposure => 'Belichting';

  @override
  String get highlights => 'Hoge lichten';

  @override
  String get shadows => 'Schaduwen';

  @override
  String get whites => 'Witten';

  @override
  String get blacks => 'Zwarten';

  @override
  String get temperature => 'Temperatuur';

  @override
  String get tint => 'Tint';

  @override
  String get vibrance => 'Levendigheid';

  @override
  String get hue => 'Kleurtoon';

  @override
  String get luminance => 'Luminantie';

  @override
  String get colorRed => 'Rood';

  @override
  String get colorOrange => 'Oranje';

  @override
  String get colorYellow => 'Geel';

  @override
  String get colorGreen => 'Groen';

  @override
  String get colorAqua => 'Aqua';

  @override
  String get colorBlue => 'Blauw';

  @override
  String get colorPurple => 'Paars';

  @override
  String get colorMagenta => 'Magenta';

  @override
  String get curveHint =>
      'Sleep een punt om de curve te vormen, tik om er een toe te voegen, dubbeltik om het te verwijderen.';

  @override
  String get sharpen => 'Verscherpen';

  @override
  String get vignette => 'Vignet';

  @override
  String get grain => 'Korrel';

  @override
  String get holdForOriginal =>
      'Houd de foto ingedrukt om te vergelijken met het origineel.';

  @override
  String get showingOriginal => 'Origineel';

  @override
  String get applyLookToAll => 'Deze look op alle foto\'s toepassen';

  @override
  String get applyingEdits => 'Foto\'s verwerken…';

  @override
  String get choosePhotoToEdit => 'Kies een foto om te bewerken';
}
