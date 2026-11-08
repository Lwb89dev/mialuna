// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Danish (`da`).
class AppLocalizationsDa extends AppLocalizations {
  AppLocalizationsDa([String locale = 'da']) : super(locale);

  @override
  String get syncUpToDate => 'Opdateret';

  @override
  String get syncFailed => 'Synk mislykkedes';

  @override
  String get relaysUpdatedFromProfile =>
      'Relays opdateret fra din profil (NIP-65)';

  @override
  String get relayListPublished => 'Relay-liste publiceret';

  @override
  String get mediaServersUpdatedFromProfile =>
      'Medieservere opdateret fra din profil';

  @override
  String get tabHome => 'Home';

  @override
  String get tabDiscover => 'Opdag';

  @override
  String get tabCreate => 'Opret';

  @override
  String get tabReels => 'Reels';

  @override
  String get tabProfile => 'Profil';

  @override
  String get signInToUploadMedia => 'Log ind for at uploade medier.';

  @override
  String get noMediaServer =>
      'Ingen medieserver sat op. Tilføj en under Indstillinger.';

  @override
  String serverNoResponse(Object server) {
    return '$server: intet svar';
  }

  @override
  String serverUnreachable(Object server, Object error) {
    return '$server: kan ikke nås ($error)';
  }

  @override
  String uploadRejected(Object reason) {
    return 'Upload afvist — $reason';
  }

  @override
  String noServerAcceptedFile(Object reasons) {
    return 'Ingen server tog imod filen — $reasons';
  }

  @override
  String get blossomInvalidResponse => 'ugyldigt svar';

  @override
  String get blossomInvalidFileUrl => 'ugyldig filadresse';

  @override
  String get blossomServerAlteredFile => 'serveren ændrede filen';

  @override
  String get blossomBadRequest => 'ugyldig anmodning';

  @override
  String get blossomUnauthorized => 'adgang nægtet';

  @override
  String get blossomPaymentRequired => 'betaling kræves';

  @override
  String get blossomForbidden => 'ikke tilladt';

  @override
  String get blossomLengthRequired => 'størrelse mangler';

  @override
  String get blossomTooLarge => 'filen er for stor';

  @override
  String get blossomUnsupportedType => 'formatet accepteres ikke';

  @override
  String get blossomTooManyRequests => 'for mange anmodninger';

  @override
  String get blossomServerError => 'serverfejl';

  @override
  String get cipherInvalidKey => 'Ugyldig nøgle';

  @override
  String get cipherTruncated => 'Den krypterede fil er afkortet';

  @override
  String get cipherMismatch =>
      'Filen matcher ikke nøglen: ændret eller beskadiget';

  @override
  String get sanitizeHeifNeedsAsync =>
      'HEIC/AVIF-format: konvertering kræver sanitizeAsync';

  @override
  String get sanitizeWebmUnsupported =>
      'WebM/MKV-video understøttes ikke: brug MP4 eller MOV, så metadata kan fjernes før upload.';

  @override
  String get sanitizeUnknownFormat =>
      'Ukendt filformat: JPEG/PNG/WebP/GIF-fotos eller MP4/MOV-videoer.';

  @override
  String sanitizeLeftovers(Object items) {
    return 'Kunne ikke fjerne alle metadata ($items): filen blev ikke uploadet.';
  }

  @override
  String sanitizeProcessingFailed(Object error) {
    return 'Kunne ikke behandle filen: $error';
  }

  @override
  String get sanitizeJpegInvalid => 'Ugyldig JPEG';

  @override
  String get sanitizeJpegTruncated => 'Afkortet JPEG';

  @override
  String get sanitizeJpegNoSize => 'JPEG uden mål';

  @override
  String get sanitizeJpegUndecodable => 'JPEG kan ikke afkodes';

  @override
  String get sanitizePngTruncated => 'Afkortet PNG';

  @override
  String get sanitizePngInvalid => 'Ugyldig PNG';

  @override
  String get sanitizeGifInvalid => 'Ugyldig GIF';

  @override
  String get sanitizeGifTruncated => 'Afkortet GIF';

  @override
  String get sanitizeWebpTruncated => 'Afkortet WebP';

  @override
  String get sanitizeWebpInvalid => 'Ugyldig WebP';

  @override
  String get sanitizeMp4Invalid => 'Ugyldig MP4/MOV-video';

  @override
  String get sanitizeConversionFailed => 'Konvertering mislykkedes';

  @override
  String get sanitizeHeifUnsupported =>
      'Dette format (HEIC/AVIF) kan ikke konverteres på denne enhed. Vælg et JPEG- eller PNG-foto.';

  @override
  String get privateMediaNotEncrypted => 'Mediet er ikke krypteret';

  @override
  String serverReplied(Object status) {
    return 'Serveren svarede $status';
  }

  @override
  String get fileTooLarge => 'Filen er for stor';

  @override
  String get serverFileNotOriginal => 'Filen på serveren er ikke originalen';

  @override
  String get contentMismatch => 'Indholdet stemmer ikke';

  @override
  String get mediaUnreachable => 'Medie kan ikke nås';

  @override
  String get amberInvalidKey => 'Amber returnerede en ugyldig nøgle';

  @override
  String get amberNoKey => 'Amber returnerede ingen nøgle';

  @override
  String get amberRequestRejected => 'Anmodning afvist i Amber';

  @override
  String get amberAndroidOnly => 'Amber findes kun på Android';

  @override
  String get amberEmptySignature => 'Amber returnerede en tom signatur';

  @override
  String get amberSignRejected => 'Signatur afvist i Amber';

  @override
  String get amberTimeout => 'Amber svarede ikke i tide';

  @override
  String get amberEmptyResponse => 'Amber returnerede et tomt svar';

  @override
  String get bunkerInvalidUrl => 'Ugyldig bunker-URL';

  @override
  String get bunkerNoRelay => 'Denne bunker angiver ingen relay';

  @override
  String get bunkerWebAuth =>
      'Denne bunker kræver webgodkendelse (auth_url understøttes ikke)';

  @override
  String get bunkerInvalidKey => 'Denne bunker returnerede ingen gyldig nøgle';

  @override
  String get signerInvalidResponse =>
      'Signeren returnerede en ugyldig signeret hændelse';

  @override
  String get bunkerTimeout => 'Bunker svarede ikke i tide';

  @override
  String get nwcInvalidUri => 'Ugyldig NWC-URI';

  @override
  String get nwcNoRelay => 'NWC-URI\'en angiver ingen relay';

  @override
  String get nwcNoSecret => 'NWC-URI\'en indeholder ingen gyldig hemmelighed';

  @override
  String get nwcTimeout => 'Pungen svarede ikke i tide';

  @override
  String get signerNoPrivateMessages =>
      'Denne loginmetode understøtter ikke private beskeder';

  @override
  String get zapNotSupported => 'Denne adresse understøtter ikke Nostr zaps';

  @override
  String zapAmountOutOfRange(Object min, Object max) {
    return 'Beløbet er uden for intervallet ($min–$max sats)';
  }

  @override
  String get commentNotSent => 'Kommentaren blev ikke sendt. Prøv igen senere.';

  @override
  String get comments => 'Kommentarer';

  @override
  String get noCommentsYet => 'Ingen kommentarer endnu.';

  @override
  String get signInToComment => 'Log ind for at kommentere.';

  @override
  String get addComment => 'Skriv en kommentar…';

  @override
  String get signInToPublish => 'Log ind for at udgive.';

  @override
  String get addMediaFirst =>
      'Tilføj mindst ét foto eller en video, før du udgiver.';

  @override
  String get removingMetadata => 'Fjerner metadata…';

  @override
  String uploadingProgress(Object current, Object total) {
    return 'Uploader $current af $total…';
  }

  @override
  String get creatingPreview => 'Opretter forhåndsvisning…';

  @override
  String uploadFailed(Object error) {
    return 'Upload mislykkedes: $error';
  }

  @override
  String get publishing => 'Udgiver…';

  @override
  String noRelayAcceptedPost(Object reason) {
    return 'Ingen relay tog imod opslaget$reason. Indholdet bliver i dine kladder.';
  }

  @override
  String get privateNeedsKeySigner =>
      'Denne loginmetode understøtter ikke privat indhold. Brug Amber, en bunker eller den lokale nøgle.';

  @override
  String get closeFriendsListEmptyAddSomeone =>
      'Din liste med nære venner er tom: tilføj nogen.';

  @override
  String get fileOver100Mb =>
      'Filen er over 100 MB: det er grænsen for nære venner (den krypteres hel på din telefon).';

  @override
  String get encryptingOnPhone => 'Krypterer på din telefon…';

  @override
  String noServerAcceptedEncrypted(Object details) {
    return 'Ingen af dine medieservere tog imod den krypterede fil. Den udgives ikke i klartekst. Tilføj en server, der tager imod krypterede filer, under Indstillinger (for eksempel cdn.hzrd149.com). $details';
  }

  @override
  String get sendingToFriends => 'Sender til venner…';

  @override
  String sendingToFriendsProgress(Object done, Object total) {
    return 'Sender til venner $done/$total…';
  }

  @override
  String noFriendReceivedPost(Object reason) {
    return 'Ingen ven modtog opslaget$reason. Indholdet bliver i dine kladder.';
  }

  @override
  String sentToCloseFriends(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Sendt til $count nære venner 🔒',
      one: 'Sendt til 1 nær ven 🔒',
    );
    return '$_temp0';
  }

  @override
  String sentToFriendsWithMisses(int delivered, Object missed) {
    String _temp0 = intl.Intl.pluralLogic(
      delivered,
      locale: localeName,
      other: 'Sendt til $delivered venner.',
      one: 'Sendt til 1 ven.',
    );
    return '$_temp0 $missed modtog det ikke (private beskeder er slået fra).';
  }

  @override
  String get altText => 'Alt-tekst';

  @override
  String get altTextHint => 'Beskriv indholdet for dem, der ikke kan se det…';

  @override
  String get cancel => 'Annuller';

  @override
  String get save => 'Gem';

  @override
  String get momentPublished => 'Øjeblik udgivet ✨';

  @override
  String get newMoment => 'Nyt øjeblik';

  @override
  String get publish => 'Udgiv';

  @override
  String get guestMode => 'Gæstetilstand';

  @override
  String get signInToPostMoments => 'Log ind for at udgive dine øjeblikke.';

  @override
  String get signIn => 'Log ind';

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
      'Stories udløber efter 24 timer på relays, der respekterer NIP-40, men andre kan stadig gemme eller arkivere dem.';

  @override
  String get fromGallery => 'Fra galleriet';

  @override
  String get galleryLongPressVideo => 'Galleri (langt tryk for video)';

  @override
  String get addVideo => 'Tilføj video';

  @override
  String get camera => 'Kamera';

  @override
  String get exifRemovedNote => 'Placeringsdata (EXIF) fjernes automatisk.';

  @override
  String get writeCaption => 'Skriv en billedtekst…';

  @override
  String get privatePostNote =>
      'Privat opslag: ingen offentlige hashtags, det kan ikke findes via søgning.';

  @override
  String willPublishAs(Object caption) {
    return 'Det udgives som: \"$caption\"';
  }

  @override
  String get tapThumbnailForAlt =>
      'Tryk på en miniature for at tilføje alt-tekst.';

  @override
  String get sensitiveContent => 'Følsomt indhold';

  @override
  String get sensitiveContentNote =>
      'Opslaget skjules bag en advarsel (NIP-36).';

  @override
  String get uploadingMedia => 'Uploader medier…';

  @override
  String get audiencePublic => 'Offentligt';

  @override
  String get closeFriends => 'Nære venner';

  @override
  String get signerCannotPublishCloseFriends =>
      'Med denne loginmetode kan du ikke udgive til nære venner: brug Amber, en bunker eller den lokale nøgle.';

  @override
  String get closeFriendsEmptyPrompt =>
      'Din liste er tom: tilføj dem, der må se dette opslag.';

  @override
  String onlyYourCloseFriendsSee(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Kun dine $count nære venner ser dette. Fotos og videoer krypteres på din telefon, før de uploades.',
      one: 'Kun din 1 nære ven ser dette. Fotos og videoer krypteres på din telefon, før de uploades.',
    );
    return '$_temp0';
  }

  @override
  String get addFriends => 'Tilføj venner';

  @override
  String get manageList => 'Administrer listen';

  @override
  String get edit => 'Rediger';

  @override
  String get reset => 'Nulstil';

  @override
  String get apply => 'Anvend';

  @override
  String get cropFree => 'Fri';

  @override
  String get cropOriginal => 'Original';

  @override
  String get rotate => 'Roter';

  @override
  String get flip => 'Vend';

  @override
  String get brightness => 'Lysstyrke';

  @override
  String get contrast => 'Kontrast';

  @override
  String get saturation => 'Mætning';

  @override
  String postsByAuthor(Object author) {
    return 'Opslag af $author…';
  }

  @override
  String get searchHint => 'Søg personer, hashtags eller ord…';

  @override
  String get clear => 'Ryd';

  @override
  String get recent => 'Seneste';

  @override
  String get searchDependsOnRelays =>
      'Søgningen afhænger af de valgte relays: resultaterne kan være ufuldstændige.';

  @override
  String get recentPostsEverywhere =>
      'Seneste opslag fra hele netværket, også fra personer du ikke følger.';

  @override
  String get noResultsOnRelays => 'Ingen resultater på de valgte relays.';

  @override
  String get noRecentPostsFromFollowed =>
      'Ingen nye opslag fra personer, du følger.';

  @override
  String get noMomentsFound =>
      'Ingen øjeblikke fundet på relays. Tjek din forbindelse.';

  @override
  String get loadFailed => 'Indlæsning mislykkedes';

  @override
  String get notifications => 'Notifikationer';

  @override
  String get messages => 'Beskeder';

  @override
  String get homeEmptyFollowsNobody =>
      'Opslag fra personer, du følger, vises her.\nDu følger ingen endnu: opdag interessante personer og profiler.';

  @override
  String get discoverPeople => 'Opdag personer';

  @override
  String get homeEmpty =>
      'Ingen øjeblikke endnu.\nTræk ned for at opdatere, eller udgiv dit første billede.';

  @override
  String get retry => 'Prøv igen';

  @override
  String get seenEverything => 'Du har set alt for nu ✨';

  @override
  String get discoverMoreProfiles => 'Opdag flere profiler';

  @override
  String get feedFollowing => 'Følger';

  @override
  String get signInToSeeFollowed =>
      'Log ind for at se opslag fra personer, du følger';

  @override
  String get videoPreview => 'Videoforhåndsvisning';

  @override
  String get cannotOpenPrivateVideo => 'Kan ikke åbne den private video';

  @override
  String get cannotPlayVideo => 'Kan ikke afspille videoen';

  @override
  String get pauseVideo => 'Sæt videoen på pause';

  @override
  String get playVideo => 'Afspil videoen';

  @override
  String errorTapToRetry(Object error) {
    return '$error — tryk for at prøve igen';
  }

  @override
  String get soundOn => 'Slå lyden til';

  @override
  String get soundOff => 'Slå lyden fra';

  @override
  String get postImage => 'Opslagsbillede';

  @override
  String get imageUnavailable => 'Billedet er ikke tilgængeligt';

  @override
  String errorTapToRetryNewline(Object message) {
    return '$message\nTryk for at prøve igen';
  }

  @override
  String get cannotOpenPrivateContent => 'Kan ikke åbne dette private indhold';

  @override
  String get privateImage => 'Privat billede';

  @override
  String get invalidImage => 'Ugyldigt billede';

  @override
  String get more => 'Mere';

  @override
  String get removeFromSaved => 'Fjern fra gemte';

  @override
  String get copyLink => 'Kopiér link';

  @override
  String get muteAuthor => 'Skjul forfatteren';

  @override
  String get blockAuthor => 'Bloker forfatteren';

  @override
  String get report => 'Rapportér';

  @override
  String get like => 'Synes om';

  @override
  String get sendInMessage => 'Send i en besked';

  @override
  String get zapOptional => 'Zap (valgfrit)';

  @override
  String get closeFriendsOnlyNote =>
      'Kun synlig for nære venner. Likes og svar går kun til forfatteren.';

  @override
  String get likeFailed => 'Kunne ikke sende liket';

  @override
  String get nostrLinkCopied => 'Nostr-link kopieret til udklipsholderen';

  @override
  String get authorMuted => 'Forfatteren skjult';

  @override
  String get authorBlocked => 'Forfatteren blokeret';

  @override
  String get reportSent => 'Rapport sendt (NIP-56)';

  @override
  String get signInToReport => 'Log ind for at rapportere';

  @override
  String minutesAgo(Object minutes) {
    return '$minutes min siden';
  }

  @override
  String get show => 'Vis';

  @override
  String get chatEmptyHint =>
      'Skriv den første besked.\nDen er krypteret: kun I to kan se den.';

  @override
  String get messageHint => 'Besked…';

  @override
  String get send => 'Send';

  @override
  String get notSentSuffix => ' ikke sendt';

  @override
  String get contentUnavailable =>
      'Indholdet er ikke tilgængeligt (udløbet eller ikke fundet på relays)';

  @override
  String get signInToSendPrivateMessages =>
      'Log ind for at sende private beskeder.';

  @override
  String get cannotMessageYourself => 'Du kan ikke skrive til dig selv.';

  @override
  String get recipientNoPrivateMessages =>
      'Denne person har ikke slået private beskeder til endnu.';

  @override
  String noRecipientRelayAccepted(Object reason) {
    return 'Ingen modtager-relay tog imod beskeden$reason.';
  }

  @override
  String sendFailed(Object error) {
    return 'Afsendelse mislykkedes: $error';
  }

  @override
  String get signInToReadMessages =>
      'Log ind for at læse og sende private beskeder.';

  @override
  String get signerNoPrivateMessagesLong =>
      'Private beskeder kan ikke bruges med denne loginmetode. Log ind med Amber, en bunker eller den lokale nøgle.';

  @override
  String get inboxEmpty =>
      'Ingen samtaler.\nTryk på blyanten for at skrive til nogen, eller videresend et øjeblik med ✈-ikonen under hvert opslag.';

  @override
  String get newMessage => 'Ny besked';

  @override
  String get privateMessagesEnabled => 'Private beskeder slået til';

  @override
  String get enableMessagesFailed => 'Kunne ikke slå dem til. Prøv igen.';

  @override
  String get enablePrivateMessages => 'Slå private beskeder til';

  @override
  String enablePrivateMessagesExplain(Object count) {
    return 'For at modtage beskeder skal du angive, hvilke relays de skal komme til. En lille liste (NIP-17) udgives med $count standardrelays: du kan ændre den senere. Beskeder forbliver krypterede: relays ser hverken, hvem der skriver, eller teksten.';
  }

  @override
  String get turnOn => 'Slå til';

  @override
  String get searchByNameOrUsername => 'Søg på navn eller brugernavn';

  @override
  String get searching => 'Søger…';

  @override
  String get noOneWithNameHint =>
      'Ingen med det navn. Prøv færre bogstaver eller en adresse som name@domain.com.';

  @override
  String get sent => 'Sendt';

  @override
  String sentToPeople(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Sendt til $count personer',
      one: 'Sendt til 1 person',
    );
    return '$_temp0';
  }

  @override
  String sentToPeopleWithFailure(int count, Object failure) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Sendt til $count personer. $failure',
      one: 'Sendt til 1 person. $failure',
    );
    return '$_temp0';
  }

  @override
  String get signerNoPrivateMessagesShort =>
      'Du kan ikke bruge private beskeder med denne loginmetode.';

  @override
  String get followToStartOrSearch =>
      'Følg nogen for at komme i gang, eller søg på navn.';

  @override
  String get addMessage => 'Tilføj en besked…';

  @override
  String sendWithCount(Object count) {
    return 'Send ($count)';
  }

  @override
  String get linkCopied => 'Link kopieret til udklipsholderen';

  @override
  String get noNotifications => 'Ingen notifikationer lige nu.';

  @override
  String get notificationsDependOnRelays =>
      'Notifikationer afhænger af relays: de kan være ufuldstændige.';

  @override
  String get reactedToYourMoment => 'reagerede på dit øjeblik';

  @override
  String commentedText(Object text) {
    return 'kommenterede: $text';
  }

  @override
  String sentYouSats(Object sats, Object comment) {
    return 'sendte dig $sats sats$comment';
  }

  @override
  String get sentYouZap => 'sendte dig en zap';

  @override
  String get startedFollowingYou => 'begyndte at følge dig';

  @override
  String get amberNotFound => 'Amber blev ikke fundet';

  @override
  String get amberExplain =>
      'Amber er en Nostr-signer, der holder din private nøgle uden for Mialuna. Installer den, og prøv igen.';

  @override
  String get downloadFromFdroid => 'Download fra F-Droid';

  @override
  String get continueWithAmber => 'Fortsæt med Amber';

  @override
  String get amberRecommended =>
      'Anbefalet: din private nøgle er sikker i Amber.';

  @override
  String get amberNotDetected =>
      'Amber blev ikke fundet: installer den til den anbefalede login.';

  @override
  String get exploreWithoutAccount => 'Udforsk uden konto';

  @override
  String get remoteBunker => 'Fjernbunker (NIP-46)';

  @override
  String get invalidBunkerUrlDot => 'Ugyldig bunker-URL.';

  @override
  String get connectBunker => 'Forbind bunker';

  @override
  String get advancedNsec => 'Avanceret login (nsec)';

  @override
  String get nsecWarning =>
      'Advarsel: at indsætte din private nøgle er risikabelt. Del den aldrig med nogen. På Android er Amber bedre.';

  @override
  String get invalidNsec => 'Ugyldig nsec-nøgle.';

  @override
  String get signInWithNsec => 'Log ind med nsec';

  @override
  String get tagline => 'Dine øjeblikke, under den samme måne.';

  @override
  String get skip => 'Spring over';

  @override
  String get permissionsAndWallet => 'Tilladelser og pung';

  @override
  String get permissionsExplain =>
      'De lader dig kun udgive og modtage notifikationer. Du kan ændre dem når som helst i systemindstillingerne.';

  @override
  String get photosAndVideos => 'Fotos og videoer';

  @override
  String get toUploadYourMoments => 'For at uploade dine øjeblikke';

  @override
  String get allow => 'Tillad';

  @override
  String get reactionsCommentsZaps => 'Reaktioner, kommentarer og zaps';

  @override
  String get lightningWalletOptional => 'Lightning-pung (valgfrit)';

  @override
  String get nwcExplain =>
      'Forbind en Nostr Wallet Connect-pung for at sende zaps uden at forlade appen.';

  @override
  String get walletConnected => 'Pung forbundet';

  @override
  String get disconnect => 'Afbryd';

  @override
  String get connectWallet => 'Forbind pung';

  @override
  String get getStarted => 'Kom i gang';

  @override
  String get welcome1 =>
      'Mialuna er et visuelt socialt netværk: fotos, videoer, Reels og Stories — aldrig opslag med kun tekst.';

  @override
  String get welcome2 =>
      'Det kører på Nostr, en åben protokol: din identitet er en nøgle, du ejer, ikke en konto, en virksomhed kan tage fra dig. Ingen reklamer, ingen trackere, ingen centrale servere.';

  @override
  String get welcome3 =>
      'Del dit lys med mennesker overalt, fra enhver app, der taler det samme åbne sprog.';

  @override
  String onboardingWot(int min) {
    return 'Tillidsnetværk er altid slået til. Første gang du åbner Mialuna, læser den, hvem du følger, og bygger Opdag-feedet ud fra det netværk: dig, personerne du følger, og den som mindst $min af dem følger. De næste gange du åbner appen, er feedet der allerede.';
  }

  @override
  String get publicAndPrivate => 'Offentligt og privat';

  @override
  String get publicAndPrivateIntro =>
      'Mialuna bygger på Nostr, et åbent netværk. Det, du udgiver, er offentligt: opslag, fotos og videoer forbliver synlige for alle med linket, også uden for Mialuna.';

  @override
  String get closeFriendsExplain1 =>
      'Kun personerne på denne liste får dine opslag, stories og videoer til \"nære venner\". Listen ligger i opslaget; du behøver ikke vælge den hver gang.';

  @override
  String get closeFriendsExplain2 =>
      'Fotos og videoer krypteres på din telefon, før de uploades. Filservere (Blossom) krypterer ikke noget selv: derfor gør Mialuna det, og serveren ser kun ulæselige data. Den, der finder filadressen, kan ikke åbne den.';

  @override
  String get closeFriendsExplain3 =>
      'Det er ingen absolut garanti: den, der modtager et opslag, kan tage et skærmbillede, og at fjerne en ven gælder kun fremtidige opslag.';

  @override
  String get closeFriendsExplain4 =>
      'Hver ven skal bruge Mialuna med private beskeder slået til. Andre Nostr-klienter viser ikke disse opslag.';

  @override
  String get closeFriendsExplain5 =>
      'Offentlige opslag forbliver offentlige: deres filer er synlige for alle med linket.';

  @override
  String get closeFriendsExplain6 =>
      'Hvis ingen af dine servere tager imod krypterede filer, udgives opslaget ikke: aldrig i klartekst.';

  @override
  String get addToCloseFriends => 'Tilføj til nære venner';

  @override
  String maxFriendsReached(Object max, Object added) {
    return 'Grænse på $max venner: $added tilføjet.';
  }

  @override
  String get add => 'Tilføj';

  @override
  String get signInToCreateList => 'Log ind for at oprette din liste.';

  @override
  String get signerNoCloseFriends =>
      'Nære venner kan ikke bruges med denne loginmetode. Log ind med Amber, en bunker eller den lokale nøgle.';

  @override
  String peopleOfMax(Object count, Object max) {
    return '$count / $max personer';
  }

  @override
  String get noOneYet => 'Ingen endnu.';

  @override
  String get addPeople => 'Tilføj personer';

  @override
  String get friendNoPrivateMessagesWarning =>
      'De har ikke slået private beskeder til: de modtager ikke dine opslag';

  @override
  String get removeFromList => 'Fjern fra listen';

  @override
  String get noOneWithThisName => 'Ingen med det navn.';

  @override
  String get signInToSendPrivateContent =>
      'Log ind for at sende privat indhold.';

  @override
  String get reasonNoPrivateMessages => 'har ikke slået private beskeder til';

  @override
  String get reasonNoRelayAnswered => 'ingen relay svarede';

  @override
  String get profileUpdated => 'Profil opdateret';

  @override
  String get noRelayAcceptedRetry =>
      'Ingen relay tog imod det. Prøv igen senere.';

  @override
  String get editProfile => 'Rediger profil';

  @override
  String get fieldName => 'Navn';

  @override
  String get fieldBio => 'Bio';

  @override
  String get fieldAvatarUrl => 'Avatar-URL';

  @override
  String get fieldNip05 => 'NIP-05 (f.eks. you@example.com)';

  @override
  String get browsingAsGuest => 'Du kigger som gæst';

  @override
  String get signInToInteract => 'Log ind for at udgive, følge og interagere.';

  @override
  String get settings => 'Indstillinger';

  @override
  String get signOut => 'Log ud';

  @override
  String get npubCopied => 'npub kopieret';

  @override
  String get copyNpub => 'Kopiér npub';

  @override
  String get mute => 'Skjul';

  @override
  String get block => 'Bloker';

  @override
  String get posts => 'Opslag';

  @override
  String get saved => 'Gemte';

  @override
  String get nothingPublishedYet => 'Du har ikke udgivet noget endnu.';

  @override
  String get noPostsOnRelays => 'Ingen opslag fundet på relays.';

  @override
  String get noReelsPublished => 'Ingen reels udgivet.';

  @override
  String get noReelsOnRelays => 'Ingen reels fundet på relays.';

  @override
  String get noSavedPosts => 'Ingen gemte opslag.';

  @override
  String get followingButton => 'Følger';

  @override
  String get follow => 'Følg';

  @override
  String get messageButton => 'Besked';

  @override
  String get loginLocalKey => 'Lokal nøgle';

  @override
  String get loginGuest => 'Gæst';

  @override
  String get followUpdateFailed =>
      'Kunne ikke opdatere dem, du følger, lige nu. Prøv igen.';

  @override
  String get noReelsComeBack =>
      'Ingen reels fundet på relays.\nKom snart tilbage!';

  @override
  String get followUpdateFailedShort =>
      'Kunne ikke opdatere dem, du følger, lige nu';

  @override
  String get needOneReadRelay => 'Mindst én læse-relay kræves.';

  @override
  String get listSavedLocally => 'Listen gemt på denne enhed, ikke udgivet.';

  @override
  String get noRelayAcceptedList =>
      'Ingen relay tog imod listen: der prøves igen senere.';

  @override
  String relayListPublishedTo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Relay-liste publiceret til $count relays',
      one: 'Relay-liste publiceret til 1 relay',
    );
    return '$_temp0';
  }

  @override
  String get mediaServersUpdated => 'Medieservere opdateret';

  @override
  String get appearance => 'Udseende';

  @override
  String get publishingSettings => 'Udgivelse';

  @override
  String get addMialunaHashtag => 'Tilføj #mialuna';

  @override
  String get addMialunaHashtagNote =>
      'Tilføj det officielle hashtag til offentlige opslag og stories. Du kan slå det fra når som helst.';

  @override
  String get themeLight => 'Lyst';

  @override
  String get themeDark => 'Mørkt';

  @override
  String get themeSystem => 'System';

  @override
  String get relays => 'Relays';

  @override
  String get relaysExplainSignedOut =>
      'Relays gemmer og fordeler indhold. Log ind for at bruge din egen liste automatisk (NIP-65).';

  @override
  String get relaysExplainSynced =>
      'Listen synkroniseres med din Nostr-profil (NIP-65): hver ændring udgives og gælder alle dine apps.';

  @override
  String get syncing => 'Synkroniserer…';

  @override
  String get waitingFirstSync => 'Venter på den første synk';

  @override
  String get syncNow => 'Synk nu';

  @override
  String get addRelay => 'Tilføj relay';

  @override
  String get restoreDefaultRelays => 'Gendan standardrelays';

  @override
  String get createYourList => 'Opret din liste';

  @override
  String peopleCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count personer',
      one: '1 person',
    );
    return '$_temp0';
  }

  @override
  String get closeFriendsSettingsNote =>
      'Opslag, stories og videoer er kun synlige for dem, med krypterede fotos og videoer.';

  @override
  String get mediaServersBlossom => 'Medieservere (Blossom)';

  @override
  String get mediaServersExplain =>
      'Fotos og videoer uploades kun til disse servere, i den viste rækkefølge: den første, der tager imod dem, vinder. EXIF og placering fjernes før upload.';

  @override
  String get primary => 'Primær';

  @override
  String get makePrimary => 'Gør primær';

  @override
  String get remove => 'Fjern';

  @override
  String get addServer => 'Tilføj server';

  @override
  String get moderation => 'Moderation';

  @override
  String get moderationExplain =>
      'Skjulte forfattere og skjulte hashtags synkroniseres via NIP-51. Blokerede forfattere bliver kun på denne enhed.';

  @override
  String get mutedAuthors => 'Skjulte forfattere';

  @override
  String get noMutedAuthors => 'Ingen skjulte forfattere';

  @override
  String get blockedAuthors => 'Blokerede forfattere';

  @override
  String get noBlockedAuthors => 'Ingen blokerede forfattere';

  @override
  String get hiddenHashtags => 'Skjulte hashtags';

  @override
  String get noHiddenHashtags => 'Ingen skjulte hashtags';

  @override
  String get hashtagToHide => '#hashtag at skjule';

  @override
  String get storage => 'Lager';

  @override
  String get clearCache => 'Ryd eventcache og kladder';

  @override
  String get cacheCleared => 'Cache ryddet';

  @override
  String get reviewIntro => 'Se introduktionen igen';

  @override
  String get reviewIntroSubtitle =>
      'Hvad der er offentligt, hvad der er privat, og grænserne for nære venner.';

  @override
  String noLightningWalletCopied(Object address) {
    return 'Ingen Lightning-pung fundet: adresse kopieret ($address)';
  }

  @override
  String get about => 'Om';

  @override
  String aboutText(Object version) {
    return 'Mialuna $version — Dine øjeblikke, under den samme måne.\nÅben kildekode (MIT). github.com/Lwb89dev/mialuna';
  }

  @override
  String get invalidRelayAddress => 'Ugyldig adresse: brug wss://…';

  @override
  String get invalidServerAddress => 'Ugyldig adresse: brug https://…';

  @override
  String get relayRead => 'Læs';

  @override
  String get relayWrite => 'Skriv';

  @override
  String get support => 'Støtte';

  @override
  String get supportText =>
      'Mialuna er gratis, har ingen reklamer og sporer dig ikke. Hvis du kan lide den, kan du sende nogle sats via Lightning Network.';

  @override
  String get donateWithLightning => 'Donér med Lightning';

  @override
  String get authorNoZaps => 'Denne forfatter tager ikke imod zaps';

  @override
  String get sendZap => 'Send en zap ⚡';

  @override
  String get amountInSats => 'Beløb i sats';

  @override
  String minMaxSats(Object min, Object max) {
    return 'min $min – max $max';
  }

  @override
  String get zap => 'Zap';

  @override
  String get signInToZap => 'Log ind for at sende zaps';

  @override
  String zapSent(Object sats) {
    return 'Zap på $sats sats sendt ⚡';
  }

  @override
  String nwcPaymentFailed(Object error) {
    return 'NWC-betaling mislykkedes: $error';
  }

  @override
  String get noLightningWallet => 'Ingen Lightning-pung fundet';

  @override
  String storiesRailLabel(Object state) {
    return 'Stories, $state';
  }

  @override
  String get close => 'Luk';

  @override
  String hoursAgo(int hours) {
    return '$hours t siden';
  }

  @override
  String daysAgo(int days) {
    return '$days d siden';
  }

  @override
  String get now => 'nu';

  @override
  String get youPrefix => 'Du: ';

  @override
  String get storiesStateUnseen => 'ny';

  @override
  String get storiesStateSeen => 'set';

  @override
  String weekdayShort(String day) {
    String _temp0 = intl.Intl.selectLogic(day, {
      'mon': 'man',
      'tue': 'tir',
      'wed': 'ons',
      'thu': 'tor',
      'fri': 'fre',
      'sat': 'lør',
      'sun': 'søn',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get sharedAMoment => 'Delte et øjeblik';

  @override
  String get blossomOtherError => 'fejl';

  @override
  String get languageTitle => 'Sprog';

  @override
  String get languageSystem => 'System';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageItalian => 'Italiano';

  @override
  String get cannotEditPhoto => 'Dette foto kan ikke redigeres her.';

  @override
  String notificationsNew(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count nye notifikationer',
      one: '1 ny notifikation',
    );
    return '$_temp0';
  }

  @override
  String messagesUnread(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ulæste beskeder',
      one: '1 ulæst besked',
    );
    return '$_temp0';
  }

  @override
  String get done => 'Færdig';

  @override
  String get storyAddText => 'Tilføj tekst';

  @override
  String get storyEditText => 'Rediger tekst';

  @override
  String get storyTextHint => 'Skriv noget… #hashtags kan trykkes på';

  @override
  String get storyTextsHelp =>
      'Tryk på billedet for at skrive. Træk for at flytte, knib for at ændre størrelse og rotere, tryk på en tekst for at redigere den.';

  @override
  String storyTextsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tekster',
      one: '1 tekst',
      zero: 'Ingen tekst',
    );
    return '$_temp0';
  }

  @override
  String get storyFontClassic => 'Klassisk';

  @override
  String get storyFontBold => 'Fed';

  @override
  String get storyFontSerif => 'Serif';

  @override
  String get storyFontMono => 'Mono';

  @override
  String get storyFontItalic => 'Kursiv';

  @override
  String get storyTextBackground => 'Tekstbaggrund';

  @override
  String get storyTextColor => 'Tekstfarve';

  @override
  String storyTextLimit(int max) {
    return 'Du kan tilføje op til $max tekster.';
  }

  @override
  String get wotTitle => 'Tillidsnetværk';

  @override
  String get wotEnable => 'Tillidsnetværk er altid slået til';

  @override
  String wotExplain(int min) {
    return 'Altid slået til. Opdag viser kun dette netværk: dig, personerne du følger, og den som følges af mindst $min af dem. Det samme netværk skjuler kommentarer, notifikationer, private opslag og beskeder fra alle andre. Det regnes ud på denne telefon ud fra offentlige følgelister, første gang du åbner appen; senere åbninger genbruger det. Intet sendes til nogen server.';
  }

  @override
  String get wotRefresh => 'Opdater netværket nu';

  @override
  String get wotStatusIdle =>
      'Ikke bygget endnu. Det bygges, første gang du åbner appen.';

  @override
  String get wotBuildingTitle => 'Bygger dit Opdag-feed';

  @override
  String get wotBuildingBody =>
      'Læser, hvem personerne du følger også følger, og forbereder Opdag.';

  @override
  String get wotDiscoverHint =>
      'Kun dit tillidsnetværk: personer du følger, og personer som nok af dem følger.';

  @override
  String get wotDiscoverSignIn =>
      'Opdag viser dit tillidsnetværk. Log ind, så læser Mialuna første gang, hvem du følger, og bygger dette feed. Senere åbninger genbruger det.';

  @override
  String get wotDiscoverEmpty => 'Ingen opslag fra dit tillidsnetværk endnu.';

  @override
  String wotStatusDiscovering(int done, int total) {
    return 'Tjekker, hvem dem du følger følger… $done af $total';
  }

  @override
  String wotStatusComplete(int direct, int indirect, Object when) {
    return 'Dit netværk: $direct personer du følger plus $indirect, som nok af dem følger. Opdateret $when.';
  }

  @override
  String wotStatusFailed(Object reason) {
    return 'Kunne ikke beregne dit netværk: $reason';
  }

  @override
  String get wotNoFollows => 'du følger ingen endnu';

  @override
  String get messageRequests => 'Beskedanmodninger';

  @override
  String messageRequestsSubtitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count samtaler uden for dit tillidsnetværk',
      one: '1 samtale uden for dit tillidsnetværk',
    );
    return '$_temp0';
  }

  @override
  String get messageRequestsHint =>
      'Fra personer uden for dit tillidsnetværk. De tæller ikke som ulæste. Svar for at flytte en samtale til indbakken.';

  @override
  String get storyViewsSetting => 'Lad andre se, at jeg har set deres stories';

  @override
  String get storyViewsSettingExplain =>
      'Når du ser en story, sendes en kvittering til forfatteren, krypteret så kun vedkommende kan læse den. Den viser dit navn ved siden af deres; relays ser ingenting. Hvis den ikke kan leveres, gemmes den og prøves igen senere. Slå det fra for at se uden at fortælle nogen: kvitteringer, der ikke er sendt endnu, kasseres (en der allerede er leveret kan ikke trækkes tilbage).';

  @override
  String storySeenBy(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Set af $count personer',
      one: 'Set af 1 person',
      zero: 'Ingen visninger endnu',
    );
    return '$_temp0';
  }

  @override
  String get storyViewsEmpty =>
      'Ingen har set denne story endnu, eller deres kvitteringer er ikke nået frem til dig.';

  @override
  String get storyViewsHint =>
      'Kun personer, der tillader det, sender en kvittering, så det reelle tal kan være højere.';

  @override
  String get systemNotifications => 'Systemnotifikationer';

  @override
  String get systemNotificationsExplain =>
      'Vis en notifikation på telefonen, når noget nyt kommer, mens Mialuna er i baggrunden. Private beskeder viser aldrig deres tekst, heller ikke på låseskærmen. Android sætter apps på pause, der bliver længe i baggrunden, så notifikationer kommer, mens Mialuna stadig kører.';

  @override
  String get systemNotificationsBlocked =>
      'Notifikationer er slået fra for Mialuna i telefonens indstillinger.';

  @override
  String get systemNotificationsOpenSettings => 'Åbn indstillinger';

  @override
  String get systemNotificationsBattery =>
      'Android sætter apps i dvale få minutter efter, at skærmen slukker, og notifikationerne stopper med dem. For at blive ved med at få dem, sæt Mialunas batteriforbrug til “Ubegrænset”.';

  @override
  String get systemNotificationsBatteryAction => 'Åbn batteriindstillinger';

  @override
  String get newFollowersSetting => 'Vis nye følgere';

  @override
  String get newFollowersSettingExplain =>
      'Nye følgere vises i Notifikationer og på telefonen. Slå det fra, hvis folk oversvømmer dig med følgerier: likes, kommentarer og zaps vises stadig.';

  @override
  String get systemNotificationMessage => 'sendte dig en privat besked';

  @override
  String get systemNotificationNewMessage => 'Ny privat besked';

  @override
  String get systemNotificationNew => 'Ny notifikation';

  @override
  String get notificationChannelSocial =>
      'Reaktioner, kommentarer, zaps og følgere';

  @override
  String get notificationChannelMessages => 'Private beskeder';

  @override
  String get zapInvoiceMismatch =>
      'Fakturaen matcher ikke det beløb, du valgte. Intet blev betalt.';

  @override
  String get storyYourStory => 'Din story';

  @override
  String get storyNew => 'Ny story';

  @override
  String get storyAddSemantics => 'Tilføj til din story';

  @override
  String storyOwnRailLabel(int count, Object state) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count stories',
      one: '1 story',
    );
    return 'Din story, $_temp0, $state';
  }

  @override
  String get storyTextSize => 'Tekststørrelse';

  @override
  String get storyPickPrompt => 'Vælg et foto eller en video til din story';

  @override
  String get storyEditPhoto => 'Rediger foto';

  @override
  String get storyCaption => 'Billedtekst';

  @override
  String get storyDiscardTitle => 'Kassér denne story?';

  @override
  String get storyDiscard => 'Kassér';

  @override
  String get storyShare => 'Del';

  @override
  String get storyShared => 'Story delt';

  @override
  String get deletePost => 'Slet';

  @override
  String get deletePostTitle => 'Slet dette opslag?';

  @override
  String get deleteStoryTitle => 'Slet denne story?';

  @override
  String get deletePostBody =>
      'Mialuna beder dine relays om at slette det og medieserverne om at slette dets fotos eller video. En relay, der ignorerer anmodningen, eller nogen, der allerede har gemt en kopi, kan stadig have det.';

  @override
  String get deletePrivateBody =>
      'Et opslag til nære venner kan ikke trækkes tilbage fra relays. Mialuna beder dine venners apps om at fjerne det og medieserveren om at slette dets krypterede filer. En ven, der allerede har gemt en kopi, kan stadig have det.';

  @override
  String get deletingPost => 'Sletter…';

  @override
  String get postDeleted => 'Slettet.';

  @override
  String get postWasDeleted => 'Dette opslag blev slettet.';

  @override
  String get deleteNotAllowed => 'Kun kontoen, der udgav det, kan slette det.';

  @override
  String deleteFailed(Object reason) {
    return 'Kunne ikke slette: $reason';
  }

  @override
  String get deleteNoRelay =>
      'Ingen relay tog imod sletteanmodningen, så det er stadig online. Tjek din forbindelse, og prøv igen.';

  @override
  String deleteMediaLeft(Object servers) {
    return 'Mediet kunne ikke fjernes fra $servers.';
  }

  @override
  String get deleteMediaNotAuthorized =>
      'Din signer godkendte ikke at fjerne mediet, så filerne ligger stadig på medieserveren.';

  @override
  String deleteFriendsMissed(Object count) {
    return '$count af dine nære venner kunne ikke få besked, så det kan blive på deres telefoner.';
  }

  @override
  String get storyCleanupSetting => 'Slet mine stories, når de udløber';

  @override
  String get storyCleanupSettingExplain =>
      'Efter 24 timer beder Mialuna dine relays og dine medieservere om at slette dine stories, deres fotos og videoer medregnet. En server, der ignorerer anmodningen, eller nogen, der har beholdt en kopi, kan stadig have dem.';

  @override
  String storyCleanupWaiting(Object count) {
    return 'Din signer skal godkende hver oprydning, så den venter, til du beder om det. Udløbne stories, der venter: $count.';
  }

  @override
  String get storyCleanupNow => 'Slet nu';

  @override
  String get storyCleanupDone => 'Udløbne stories slettet.';

  @override
  String get storyCleanupPartly =>
      'Nogle kunne ikke slettes endnu; Mialuna prøver igen.';
}
