// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Swedish (`sv`).
class AppLocalizationsSv extends AppLocalizations {
  AppLocalizationsSv([String locale = 'sv']) : super(locale);

  @override
  String get syncUpToDate => 'Uppdaterat';

  @override
  String get syncFailed => 'Synk misslyckades';

  @override
  String get relaysUpdatedFromProfile =>
      'Relays uppdaterade från din profil (NIP-65)';

  @override
  String get relayListPublished => 'Relay-lista publicerad';

  @override
  String get mediaServersUpdatedFromProfile =>
      'Mediaservrar uppdaterade från din profil';

  @override
  String get tabHome => 'Home';

  @override
  String get tabDiscover => 'Upptäck';

  @override
  String get tabCreate => 'Skapa';

  @override
  String get tabReels => 'Reels';

  @override
  String get tabProfile => 'Profil';

  @override
  String get signInToUploadMedia => 'Logga in för att ladda upp media.';

  @override
  String get noMediaServer =>
      'Ingen mediaserver inställd. Lägg till en i Inställningar.';

  @override
  String serverNoResponse(Object server) {
    return '$server: inget svar';
  }

  @override
  String serverUnreachable(Object server, Object error) {
    return '$server: går inte att nå ($error)';
  }

  @override
  String uploadRejected(Object reason) {
    return 'Uppladdning avvisad — $reason';
  }

  @override
  String noServerAcceptedFile(Object reasons) {
    return 'Ingen server tog emot filen — $reasons';
  }

  @override
  String get blossomInvalidResponse => 'ogiltigt svar';

  @override
  String get blossomInvalidFileUrl => 'ogiltig filadress';

  @override
  String get blossomServerAlteredFile => 'servern ändrade filen';

  @override
  String get blossomBadRequest => 'ogiltig begäran';

  @override
  String get blossomUnauthorized => 'åtkomst nekad';

  @override
  String get blossomPaymentRequired => 'betalning krävs';

  @override
  String get blossomForbidden => 'inte tillåtet';

  @override
  String get blossomLengthRequired => 'storlek saknas';

  @override
  String get blossomTooLarge => 'filen är för stor';

  @override
  String get blossomUnsupportedType => 'formatet accepteras inte';

  @override
  String get blossomTooManyRequests => 'för många förfrågningar';

  @override
  String get blossomServerError => 'serverfel';

  @override
  String get cipherInvalidKey => 'Ogiltig nyckel';

  @override
  String get cipherTruncated => 'Den krypterade filen är avkortad';

  @override
  String get cipherMismatch =>
      'Filen matchar inte nyckeln: ändrad eller skadad';

  @override
  String get sanitizeHeifNeedsAsync =>
      'HEIC/AVIF-format: konvertering kräver sanitizeAsync';

  @override
  String get sanitizeWebmUnsupported =>
      'WebM/MKV-video stöds inte: använd MP4 eller MOV så metadata kan tas bort före uppladdning.';

  @override
  String get sanitizeUnknownFormat =>
      'Okänt filformat: JPEG/PNG/WebP/GIF-foton eller MP4/MOV-videor.';

  @override
  String sanitizeLeftovers(Object items) {
    return 'Kunde inte ta bort all metadata ($items): filen laddades inte upp.';
  }

  @override
  String sanitizeProcessingFailed(Object error) {
    return 'Kunde inte bearbeta filen: $error';
  }

  @override
  String get sanitizeJpegInvalid => 'Ogiltig JPEG';

  @override
  String get sanitizeJpegTruncated => 'Avkortad JPEG';

  @override
  String get sanitizeJpegNoSize => 'JPEG utan mått';

  @override
  String get sanitizeJpegUndecodable => 'JPEG kan inte avkodas';

  @override
  String get sanitizePngTruncated => 'Avkortad PNG';

  @override
  String get sanitizePngInvalid => 'Ogiltig PNG';

  @override
  String get sanitizeGifInvalid => 'Ogiltig GIF';

  @override
  String get sanitizeGifTruncated => 'Avkortad GIF';

  @override
  String get sanitizeWebpTruncated => 'Avkortad WebP';

  @override
  String get sanitizeWebpInvalid => 'Ogiltig WebP';

  @override
  String get sanitizeMp4Invalid => 'Ogiltig MP4/MOV-video';

  @override
  String get sanitizeConversionFailed => 'Konvertering misslyckades';

  @override
  String get sanitizeHeifUnsupported =>
      'Det här formatet (HEIC/AVIF) kan inte konverteras på den här enheten. Välj ett JPEG- eller PNG-foto.';

  @override
  String get privateMediaNotEncrypted => 'Media är inte krypterat';

  @override
  String serverReplied(Object status) {
    return 'Servern svarade $status';
  }

  @override
  String get fileTooLarge => 'Filen är för stor';

  @override
  String get serverFileNotOriginal => 'Filen på servern är inte originalet';

  @override
  String get contentMismatch => 'Innehållet stämmer inte';

  @override
  String get mediaUnreachable => 'Media går inte att nå';

  @override
  String get amberInvalidKey => 'Amber returnerade en ogiltig nyckel';

  @override
  String get amberNoKey => 'Amber returnerade ingen nyckel';

  @override
  String get amberRequestRejected => 'Begäran avvisad i Amber';

  @override
  String get amberAndroidOnly => 'Amber finns bara på Android';

  @override
  String get amberEmptySignature => 'Amber returnerade en tom signatur';

  @override
  String get amberSignRejected => 'Signatur avvisad i Amber';

  @override
  String get amberTimeout => 'Amber svarade inte i tid';

  @override
  String get amberEmptyResponse => 'Amber returnerade ett tomt svar';

  @override
  String get bunkerInvalidUrl => 'Ogiltig bunker-URL';

  @override
  String get bunkerNoRelay => 'Denna bunker listar ingen relay';

  @override
  String get bunkerWebAuth =>
      'Denna bunker kräver webbauktorisering (auth_url stöds inte)';

  @override
  String get bunkerInvalidKey => 'Denna bunker returnerade ingen giltig nyckel';

  @override
  String get signerInvalidResponse =>
      'Signeraren returnerade en ogiltig signerad händelse';

  @override
  String get bunkerTimeout => 'Bunker svarade inte i tid';

  @override
  String get nwcInvalidUri => 'Ogiltig NWC-URI';

  @override
  String get nwcNoRelay => 'NWC-URI:n listar ingen relay';

  @override
  String get nwcNoSecret => 'NWC-URI:n innehåller ingen giltig hemlighet';

  @override
  String get nwcTimeout => 'Plånboken svarade inte i tid';

  @override
  String get signerNoPrivateMessages =>
      'Den här inloggningen stöder inte privata meddelanden';

  @override
  String get zapNotSupported => 'Den här adressen stöder inte Nostr zaps';

  @override
  String zapAmountOutOfRange(Object min, Object max) {
    return 'Beloppet är utanför intervallet ($min–$max sats)';
  }

  @override
  String get commentNotSent =>
      'Kommentaren skickades inte. Försök igen senare.';

  @override
  String get comments => 'Kommentarer';

  @override
  String get noCommentsYet => 'Inga kommentarer än.';

  @override
  String get signInToComment => 'Logga in för att kommentera.';

  @override
  String get addComment => 'Skriv en kommentar…';

  @override
  String get signInToPublish => 'Logga in för att publicera.';

  @override
  String get addMediaFirst =>
      'Lägg till minst ett foto eller en video innan du publicerar.';

  @override
  String get removingMetadata => 'Tar bort metadata…';

  @override
  String uploadingProgress(Object current, Object total) {
    return 'Laddar upp $current av $total…';
  }

  @override
  String get creatingPreview => 'Skapar förhandsvisning…';

  @override
  String uploadFailed(Object error) {
    return 'Uppladdning misslyckades: $error';
  }

  @override
  String get publishing => 'Publicerar…';

  @override
  String noRelayAcceptedPost(Object reason) {
    return 'Ingen relay tog emot inlägget$reason. Innehållet ligger kvar i dina utkast.';
  }

  @override
  String get privateNeedsKeySigner =>
      'Den här inloggningen stöder inte privat innehåll. Använd Amber, en bunker eller den lokala nyckeln.';

  @override
  String get closeFriendsListEmptyAddSomeone =>
      'Din lista med nära vänner är tom: lägg till någon.';

  @override
  String get fileOver100Mb =>
      'Filen är över 100 MB: det är gränsen för nära vänner (den krypteras hel på din telefon).';

  @override
  String get encryptingOnPhone => 'Krypterar på din telefon…';

  @override
  String noServerAcceptedEncrypted(Object details) {
    return 'Ingen av dina mediaservrar tog emot den krypterade filen. Den publiceras inte i klartext. Lägg till en server som tar emot krypterade filer i Inställningar (till exempel cdn.hzrd149.com). $details';
  }

  @override
  String get sendingToFriends => 'Skickar till vänner…';

  @override
  String sendingToFriendsProgress(Object done, Object total) {
    return 'Skickar till vänner $done/$total…';
  }

  @override
  String noFriendReceivedPost(Object reason) {
    return 'Ingen vän fick inlägget$reason. Innehållet ligger kvar i dina utkast.';
  }

  @override
  String sentToCloseFriends(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Skickat till $count nära vänner 🔒',
      one: 'Skickat till 1 nära vän 🔒',
    );
    return '$_temp0';
  }

  @override
  String sentToFriendsWithMisses(int delivered, Object missed) {
    String _temp0 = intl.Intl.pluralLogic(
      delivered,
      locale: localeName,
      other: 'Skickat till $delivered vänner.',
      one: 'Skickat till 1 vän.',
    );
    return '$_temp0 $missed fick det inte (privata meddelanden är av).';
  }

  @override
  String get altText => 'Alt-text';

  @override
  String get altTextHint => 'Beskriv innehållet för den som inte kan se det…';

  @override
  String get cancel => 'Avbryt';

  @override
  String get save => 'Spara';

  @override
  String get momentPublished => 'Ögonblick publicerat ✨';

  @override
  String get newMoment => 'Nytt ögonblick';

  @override
  String get publish => 'Publicera';

  @override
  String get guestMode => 'Gästläge';

  @override
  String get signInToPostMoments =>
      'Logga in för att publicera dina ögonblick.';

  @override
  String get signIn => 'Logga in';

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
      'Stories går ut efter 24 timmar på relays som respekterar NIP-40, men andra kan ändå spara eller arkivera dem.';

  @override
  String get fromGallery => 'Från galleriet';

  @override
  String get galleryLongPressVideo => 'Galleri (långtryck för video)';

  @override
  String get addVideo => 'Lägg till video';

  @override
  String get camera => 'Kamera';

  @override
  String get exifRemovedNote => 'Platsdata (EXIF) tas bort automatiskt.';

  @override
  String get writeCaption => 'Skriv en bildtext…';

  @override
  String get privatePostNote =>
      'Privat inlägg: inga offentliga hashtaggar, det går inte att hitta via sökning.';

  @override
  String willPublishAs(Object caption) {
    return 'Det publiceras som: \"$caption\"';
  }

  @override
  String get tapThumbnailForAlt =>
      'Tryck på en miniatyr för att lägga till alt-text.';

  @override
  String get sensitiveContent => 'Känsligt innehåll';

  @override
  String get sensitiveContentNote =>
      'Inlägget döljs bakom en varning (NIP-36).';

  @override
  String get uploadingMedia => 'Laddar upp media…';

  @override
  String get audiencePublic => 'Offentligt';

  @override
  String get closeFriends => 'Nära vänner';

  @override
  String get signerCannotPublishCloseFriends =>
      'Med den här inloggningen kan du inte publicera för nära vänner: använd Amber, en bunker eller den lokala nyckeln.';

  @override
  String get closeFriendsEmptyPrompt =>
      'Din lista är tom: lägg till dem som får se det här inlägget.';

  @override
  String onlyYourCloseFriendsSee(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Bara dina $count nära vänner ser det här. Foton och videor krypteras på din telefon innan de laddas upp.',
      one: 'Bara din 1 nära vän ser det här. Foton och videor krypteras på din telefon innan de laddas upp.',
    );
    return '$_temp0';
  }

  @override
  String get addFriends => 'Lägg till vänner';

  @override
  String get manageList => 'Hantera listan';

  @override
  String get edit => 'Redigera';

  @override
  String get reset => 'Återställ';

  @override
  String get apply => 'Tillämpa';

  @override
  String get cropFree => 'Fri';

  @override
  String get cropOriginal => 'Original';

  @override
  String get rotate => 'Rotera';

  @override
  String get flip => 'Vänd';

  @override
  String get brightness => 'Ljusstyrka';

  @override
  String get contrast => 'Kontrast';

  @override
  String get saturation => 'Mättnad';

  @override
  String postsByAuthor(Object author) {
    return 'Inlägg av $author…';
  }

  @override
  String get searchHint => 'Sök personer, hashtaggar eller ord…';

  @override
  String get clear => 'Rensa';

  @override
  String get recent => 'Senaste';

  @override
  String get searchDependsOnRelays =>
      'Sökningen beror på inställda relays: resultaten kan vara ofullständiga.';

  @override
  String get recentPostsEverywhere =>
      'Senaste inlägg från hela nätverket, även från personer du inte följer.';

  @override
  String get noResultsOnRelays => 'Inga resultat på de inställda relays.';

  @override
  String get noRecentPostsFromFollowed =>
      'Inga nya inlägg från personer du följer.';

  @override
  String get noMomentsFound =>
      'Inga ögonblick hittades på relays. Kontrollera din anslutning.';

  @override
  String get loadFailed => 'Inläsning misslyckades';

  @override
  String get notifications => 'Notiser';

  @override
  String get messages => 'Meddelanden';

  @override
  String get homeEmptyFollowsNobody =>
      'Inlägg från personer du följer visas här.\nDu följer ingen än: upptäck intressanta personer och profiler.';

  @override
  String get discoverPeople => 'Upptäck personer';

  @override
  String get homeEmpty =>
      'Inga ögonblick än.\nDra nedåt för att uppdatera eller publicera din första bild.';

  @override
  String get retry => 'Försök igen';

  @override
  String get seenEverything => 'Du har sett allt för nu ✨';

  @override
  String get discoverMoreProfiles => 'Upptäck fler profiler';

  @override
  String get feedFollowing => 'Följer';

  @override
  String get signInToSeeFollowed =>
      'Logga in för att se inlägg från personer du följer';

  @override
  String get videoPreview => 'Förhandsvisa video';

  @override
  String get cannotOpenPrivateVideo => 'Kan inte öppna den privata videon';

  @override
  String get cannotPlayVideo => 'Kan inte spela videon';

  @override
  String get pauseVideo => 'Pausa videon';

  @override
  String get playVideo => 'Spela videon';

  @override
  String errorTapToRetry(Object error) {
    return '$error — tryck för att försöka igen';
  }

  @override
  String get soundOn => 'Slå på ljudet';

  @override
  String get soundOff => 'Stäng av ljudet';

  @override
  String get postImage => 'Inläggsbild';

  @override
  String get imageUnavailable => 'Bilden är inte tillgänglig';

  @override
  String errorTapToRetryNewline(Object message) {
    return '$message\nTryck för att försöka igen';
  }

  @override
  String get cannotOpenPrivateContent =>
      'Kan inte öppna det här privata innehållet';

  @override
  String get privateImage => 'Privat bild';

  @override
  String get invalidImage => 'Ogiltig bild';

  @override
  String get more => 'Mer';

  @override
  String get removeFromSaved => 'Ta bort från sparade';

  @override
  String get copyLink => 'Kopiera länk';

  @override
  String get muteAuthor => 'Tysta författaren';

  @override
  String get blockAuthor => 'Blockera författaren';

  @override
  String get report => 'Rapportera';

  @override
  String get like => 'Gilla';

  @override
  String get sendInMessage => 'Skicka i ett meddelande';

  @override
  String get zapOptional => 'Zap (valfritt)';

  @override
  String get closeFriendsOnlyNote =>
      'Syns bara för nära vänner. Gilla-markeringar och svar går bara till författaren.';

  @override
  String get likeFailed => 'Kunde inte skicka gilla-markeringen';

  @override
  String get nostrLinkCopied => 'Nostr-länk kopierad till urklipp';

  @override
  String get authorMuted => 'Författaren tystad';

  @override
  String get authorBlocked => 'Författaren blockerad';

  @override
  String get reportSent => 'Rapport skickad (NIP-56)';

  @override
  String get signInToReport => 'Logga in för att rapportera';

  @override
  String minutesAgo(Object minutes) {
    return '$minutes min sedan';
  }

  @override
  String get show => 'Visa';

  @override
  String get chatEmptyHint =>
      'Skriv det första meddelandet.\nDet är krypterat: bara ni två kan se det.';

  @override
  String get messageHint => 'Meddelande…';

  @override
  String get send => 'Skicka';

  @override
  String get notSentSuffix => ' inte skickat';

  @override
  String get contentUnavailable =>
      'Innehållet finns inte (utgånget eller hittades inte på relays)';

  @override
  String get signInToSendPrivateMessages =>
      'Logga in för att skicka privata meddelanden.';

  @override
  String get cannotMessageYourself => 'Du kan inte skriva till dig själv.';

  @override
  String get recipientNoPrivateMessages =>
      'Den här personen har inte slagit på privata meddelanden än.';

  @override
  String noRecipientRelayAccepted(Object reason) {
    return 'Ingen mottagar-relay tog emot meddelandet$reason.';
  }

  @override
  String sendFailed(Object error) {
    return 'Sändning misslyckades: $error';
  }

  @override
  String get signInToReadMessages =>
      'Logga in för att läsa och skicka privata meddelanden.';

  @override
  String get signerNoPrivateMessagesLong =>
      'Privata meddelanden fungerar inte med den här inloggningen. Logga in med Amber, en bunker eller den lokala nyckeln.';

  @override
  String get inboxEmpty =>
      'Inga konversationer.\nTryck på pennan för att skriva till någon, eller vidarebefordra ett ögonblick med ✈-ikonen under varje inlägg.';

  @override
  String get newMessage => 'Nytt meddelande';

  @override
  String get privateMessagesEnabled => 'Privata meddelanden påslagna';

  @override
  String get enableMessagesFailed => 'Kunde inte slå på dem. Försök igen.';

  @override
  String get enablePrivateMessages => 'Slå på privata meddelanden';

  @override
  String enablePrivateMessagesExplain(Object count) {
    return 'För att ta emot meddelanden måste du ange vilka relays de ska komma till. En liten lista (NIP-17) publiceras med $count standardrelays: du kan ändra den senare. Meddelanden förblir krypterade: relays ser varken vem som skriver eller texten.';
  }

  @override
  String get turnOn => 'Slå på';

  @override
  String get searchByNameOrUsername => 'Sök på namn eller användarnamn';

  @override
  String get searching => 'Söker…';

  @override
  String get noOneWithNameHint =>
      'Ingen med det namnet. Prova färre bokstäver eller en adress som name@domain.com.';

  @override
  String get sent => 'Skickat';

  @override
  String sentToPeople(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Skickat till $count personer',
      one: 'Skickat till 1 person',
    );
    return '$_temp0';
  }

  @override
  String sentToPeopleWithFailure(int count, Object failure) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Skickat till $count personer. $failure',
      one: 'Skickat till 1 person. $failure',
    );
    return '$_temp0';
  }

  @override
  String get signerNoPrivateMessagesShort =>
      'Du kan inte använda privata meddelanden med den här inloggningen.';

  @override
  String get followToStartOrSearch =>
      'Följ någon för att börja, eller sök på namn.';

  @override
  String get addMessage => 'Lägg till ett meddelande…';

  @override
  String sendWithCount(Object count) {
    return 'Skicka ($count)';
  }

  @override
  String get linkCopied => 'Länk kopierad till urklipp';

  @override
  String get noNotifications => 'Inga notiser just nu.';

  @override
  String get notificationsDependOnRelays =>
      'Notiser beror på relays: de kan vara ofullständiga.';

  @override
  String get reactedToYourMoment => 'reagerade på ditt ögonblick';

  @override
  String commentedText(Object text) {
    return 'kommenterade: $text';
  }

  @override
  String sentYouSats(Object sats, Object comment) {
    return 'skickade dig $sats sats$comment';
  }

  @override
  String get sentYouZap => 'skickade en zap till dig';

  @override
  String get startedFollowingYou => 'började följa dig';

  @override
  String get amberNotFound => 'Amber hittades inte';

  @override
  String get amberExplain =>
      'Amber är en Nostr-signerare som håller din privata nyckel utanför Mialuna. Installera den och försök igen.';

  @override
  String get downloadFromFdroid => 'Ladda ner från F-Droid';

  @override
  String get continueWithAmber => 'Fortsätt med Amber';

  @override
  String get amberRecommended =>
      'Rekommenderas: din privata nyckel är säker i Amber.';

  @override
  String get amberNotDetected =>
      'Amber hittades inte: installera den för den rekommenderade inloggningen.';

  @override
  String get exploreWithoutAccount => 'Utforska utan konto';

  @override
  String get remoteBunker => 'Fjärrbunker (NIP-46)';

  @override
  String get invalidBunkerUrlDot => 'Ogiltig bunker-URL.';

  @override
  String get connectBunker => 'Anslut bunker';

  @override
  String get advancedNsec => 'Avancerad inloggning (nsec)';

  @override
  String get nsecWarning =>
      'Varning: att klistra in din privata nyckel är riskabelt. Dela den aldrig med någon. På Android är Amber bättre.';

  @override
  String get invalidNsec => 'Ogiltig nsec-nyckel.';

  @override
  String get signInWithNsec => 'Logga in med nsec';

  @override
  String get tagline => 'Dina ögonblick, under samma måne.';

  @override
  String get skip => 'Hoppa över';

  @override
  String get permissionsAndWallet => 'Behörigheter och plånbok';

  @override
  String get permissionsExplain =>
      'De låter dig bara publicera och ta emot notiser. Du kan ändra dem när som helst i systeminställningarna.';

  @override
  String get photosAndVideos => 'Foton och videor';

  @override
  String get toUploadYourMoments => 'För att ladda upp dina ögonblick';

  @override
  String get allow => 'Tillåt';

  @override
  String get reactionsCommentsZaps => 'Reaktioner, kommentarer och zaps';

  @override
  String get lightningWalletOptional => 'Lightning-plånbok (valfritt)';

  @override
  String get nwcExplain =>
      'Anslut en Nostr Wallet Connect-plånbok för att skicka zaps utan att lämna appen.';

  @override
  String get walletConnected => 'Plånbok ansluten';

  @override
  String get disconnect => 'Koppla från';

  @override
  String get connectWallet => 'Anslut plånbok';

  @override
  String get getStarted => 'Kom igång';

  @override
  String get welcome1 =>
      'Mialuna är ett visuellt socialt nätverk: foton, videor, Reels och Stories — aldrig rena textinlägg.';

  @override
  String get welcome2 =>
      'Det körs på Nostr, ett öppet protokoll: din identitet är en nyckel du äger, inte ett konto ett företag kan ta ifrån dig. Ingen reklam, inga spårare, inga centrala servrar.';

  @override
  String get welcome3 =>
      'Dela ditt ljus med människor överallt, från vilken app som helst som talar samma öppna språk.';

  @override
  String onboardingWot(int min) {
    return 'Förtroendenät är alltid på. Första gången du öppnar Mialuna läser den vem du följer och bygger flödet Upptäck från det nätverket: du, personerna du följer och den som minst $min av dem följer. Nästa gånger du öppnar appen finns flödet redan där.';
  }

  @override
  String get publicAndPrivate => 'Offentligt och privat';

  @override
  String get publicAndPrivateIntro =>
      'Mialuna bygger på Nostr, ett öppet nätverk. Det du publicerar är offentligt: inlägg, foton och videor syns för alla med länken, även utanför Mialuna.';

  @override
  String get closeFriendsExplain1 =>
      'Bara personerna på den här listan får dina inlägg, stories och videor för \"nära vänner\". Listan ligger i inlägget; du behöver inte välja den varje gång.';

  @override
  String get closeFriendsExplain2 =>
      'Foton och videor krypteras på din telefon innan de laddas upp. Filservrar (Blossom) krypterar inget själva: därför gör Mialuna det, och servern ser bara oläsbar data. Den som hittar filadressen kan inte öppna den.';

  @override
  String get closeFriendsExplain3 =>
      'Det är ingen absolut garanti: den som får ett inlägg kan ta en skärmbild, och att ta bort en vän gäller bara framtida inlägg.';

  @override
  String get closeFriendsExplain4 =>
      'Varje vän måste använda Mialuna med privata meddelanden påslagna. Andra Nostr-klienter visar inte de här inläggen.';

  @override
  String get closeFriendsExplain5 =>
      'Offentliga inlägg förblir offentliga: filerna syns för alla med länken.';

  @override
  String get closeFriendsExplain6 =>
      'Om ingen av dina servrar tar emot krypterade filer publiceras inte inlägget: aldrig i klartext.';

  @override
  String get addToCloseFriends => 'Lägg till i nära vänner';

  @override
  String maxFriendsReached(Object max, Object added) {
    return 'Gräns på $max vänner: $added tillagda.';
  }

  @override
  String get add => 'Lägg till';

  @override
  String get signInToCreateList => 'Logga in för att skapa din lista.';

  @override
  String get signerNoCloseFriends =>
      'Nära vänner fungerar inte med den här inloggningen. Logga in med Amber, en bunker eller den lokala nyckeln.';

  @override
  String peopleOfMax(Object count, Object max) {
    return '$count / $max personer';
  }

  @override
  String get noOneYet => 'Ingen än.';

  @override
  String get addPeople => 'Lägg till personer';

  @override
  String get friendNoPrivateMessagesWarning =>
      'De har inte slagit på privata meddelanden: de får inte dina inlägg';

  @override
  String get removeFromList => 'Ta bort från listan';

  @override
  String get noOneWithThisName => 'Ingen med det namnet.';

  @override
  String get signInToSendPrivateContent =>
      'Logga in för att skicka privat innehåll.';

  @override
  String get reasonNoPrivateMessages =>
      'har inte slagit på privata meddelanden';

  @override
  String get reasonNoRelayAnswered => 'ingen relay svarade';

  @override
  String get profileUpdated => 'Profil uppdaterad';

  @override
  String get noRelayAcceptedRetry =>
      'Ingen relay tog emot det. Försök igen senare.';

  @override
  String get editProfile => 'Redigera profil';

  @override
  String get fieldName => 'Namn';

  @override
  String get fieldBio => 'Bio';

  @override
  String get fieldAvatarUrl => 'Avatar-URL';

  @override
  String get fieldNip05 => 'NIP-05 (t.ex. you@example.com)';

  @override
  String get browsingAsGuest => 'Du surfar som gäst';

  @override
  String get signInToInteract =>
      'Logga in för att publicera, följa och interagera.';

  @override
  String get settings => 'Inställningar';

  @override
  String get signOut => 'Logga ut';

  @override
  String get npubCopied => 'npub kopierad';

  @override
  String get copyNpub => 'Kopiera npub';

  @override
  String get mute => 'Tysta';

  @override
  String get block => 'Blockera';

  @override
  String get posts => 'Inlägg';

  @override
  String get saved => 'Sparade';

  @override
  String get nothingPublishedYet => 'Du har inte publicerat något än.';

  @override
  String get noPostsOnRelays => 'Inga inlägg hittades på relays.';

  @override
  String get noReelsPublished => 'Inga reels publicerade.';

  @override
  String get noReelsOnRelays => 'Inga reels hittades på relays.';

  @override
  String get noSavedPosts => 'Inga sparade inlägg.';

  @override
  String get followingButton => 'Följer';

  @override
  String get follow => 'Följ';

  @override
  String get messageButton => 'Meddelande';

  @override
  String get loginLocalKey => 'Lokal nyckel';

  @override
  String get loginGuest => 'Gäst';

  @override
  String get followUpdateFailed =>
      'Kunde inte uppdatera vilka du följer just nu. Försök igen.';

  @override
  String get noReelsComeBack =>
      'Inga reels hittades på relays.\nKom tillbaka snart!';

  @override
  String get followUpdateFailedShort =>
      'Kunde inte uppdatera vilka du följer just nu';

  @override
  String get needOneReadRelay => 'Minst en läs-relay krävs.';

  @override
  String get listSavedLocally =>
      'Listan sparad på den här enheten, inte publicerad.';

  @override
  String get noRelayAcceptedList =>
      'Ingen relay tog emot listan: nytt försök görs senare.';

  @override
  String relayListPublishedTo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Relay-lista publicerad till $count relays',
      one: 'Relay-lista publicerad till 1 relay',
    );
    return '$_temp0';
  }

  @override
  String get mediaServersUpdated => 'Mediaservrar uppdaterade';

  @override
  String get appearance => 'Utseende';

  @override
  String get publishingSettings => 'Publicering';

  @override
  String get addMialunaHashtag => 'Lägg till #mialuna';

  @override
  String get addMialunaHashtagNote =>
      'Lägg till den officiella hashtaggen i offentliga inlägg och stories. Du kan stänga av det när som helst.';

  @override
  String get themeLight => 'Ljust';

  @override
  String get themeDark => 'Mörkt';

  @override
  String get themeSystem => 'System';

  @override
  String get relays => 'Relays';

  @override
  String get relaysExplainSignedOut =>
      'Relays lagrar och sprider innehåll. Logga in för att använda din egen lista automatiskt (NIP-65).';

  @override
  String get relaysExplainSynced =>
      'Listan synkas med din Nostr-profil (NIP-65): varje ändring publiceras och gäller alla dina appar.';

  @override
  String get syncing => 'Synkar…';

  @override
  String get waitingFirstSync => 'Väntar på första synken';

  @override
  String get syncNow => 'Synka nu';

  @override
  String get addRelay => 'Lägg till relay';

  @override
  String get restoreDefaultRelays => 'Återställ standardrelays';

  @override
  String get createYourList => 'Skapa din lista';

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
      'Inlägg, stories och videor syns bara för dem, med krypterade foton och videor.';

  @override
  String get mediaServersBlossom => 'Mediaservrar (Blossom)';

  @override
  String get mediaServersExplain =>
      'Foton och videor laddas bara upp till de här servrarna, i visad ordning: den första som tar emot dem vinner. EXIF och plats tas bort före uppladdning.';

  @override
  String get primary => 'Primär';

  @override
  String get makePrimary => 'Gör primär';

  @override
  String get remove => 'Ta bort';

  @override
  String get addServer => 'Lägg till server';

  @override
  String get moderation => 'Moderering';

  @override
  String get moderationExplain =>
      'Tystade författare och dolda hashtaggar synkas via NIP-51. Blockerade författare finns bara på den här enheten.';

  @override
  String get mutedAuthors => 'Tystade författare';

  @override
  String get noMutedAuthors => 'Inga tystade författare';

  @override
  String get blockedAuthors => 'Blockerade författare';

  @override
  String get noBlockedAuthors => 'Inga blockerade författare';

  @override
  String get hiddenHashtags => 'Dolda hashtaggar';

  @override
  String get noHiddenHashtags => 'Inga dolda hashtaggar';

  @override
  String get hashtagToHide => '#hashtag att dölja';

  @override
  String get storage => 'Lagring';

  @override
  String get clearCache => 'Rensa eventcache och utkast';

  @override
  String get cacheCleared => 'Cache rensad';

  @override
  String get reviewIntro => 'Visa introduktionen igen';

  @override
  String get reviewIntroSubtitle =>
      'Vad som är offentligt, vad som är privat och gränserna för nära vänner.';

  @override
  String noLightningWalletCopied(Object address) {
    return 'Ingen Lightning-plånbok hittades: adressen kopierad ($address)';
  }

  @override
  String get about => 'Om';

  @override
  String aboutText(Object version) {
    return 'Mialuna $version — Dina ögonblick, under samma måne.\nÖppen källkod (MIT). github.com/Lwb89dev/mialuna';
  }

  @override
  String get invalidRelayAddress => 'Ogiltig adress: använd wss://…';

  @override
  String get invalidServerAddress => 'Ogiltig adress: använd https://…';

  @override
  String get relayRead => 'Läs';

  @override
  String get relayWrite => 'Skriv';

  @override
  String get support => 'Stöd';

  @override
  String get supportText =>
      'Mialuna är gratis, har ingen reklam och spårar dig inte. Om du gillar den kan du skicka några sats via Lightning Network.';

  @override
  String get donateWithLightning => 'Donera med Lightning';

  @override
  String get authorNoZaps => 'Den här författaren tar inte emot zaps';

  @override
  String get sendZap => 'Skicka en zap ⚡';

  @override
  String get amountInSats => 'Belopp i sats';

  @override
  String minMaxSats(Object min, Object max) {
    return 'min $min – max $max';
  }

  @override
  String get zap => 'Zap';

  @override
  String get signInToZap => 'Logga in för att skicka zaps';

  @override
  String zapSent(Object sats) {
    return 'Zap på $sats sats skickad ⚡';
  }

  @override
  String nwcPaymentFailed(Object error) {
    return 'NWC-betalning misslyckades: $error';
  }

  @override
  String get noLightningWallet => 'Ingen Lightning-plånbok hittades';

  @override
  String storiesRailLabel(Object state) {
    return 'Stories, $state';
  }

  @override
  String get close => 'Stäng';

  @override
  String hoursAgo(int hours) {
    return '$hours h sedan';
  }

  @override
  String daysAgo(int days) {
    return '$days d sedan';
  }

  @override
  String get now => 'nu';

  @override
  String get youPrefix => 'Du: ';

  @override
  String get storiesStateUnseen => 'ny';

  @override
  String get storiesStateSeen => 'sedd';

  @override
  String weekdayShort(String day) {
    String _temp0 = intl.Intl.selectLogic(day, {
      'mon': 'mån',
      'tue': 'tis',
      'wed': 'ons',
      'thu': 'tor',
      'fri': 'fre',
      'sat': 'lör',
      'sun': 'sön',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get sharedAMoment => 'Delade ett ögonblick';

  @override
  String get blossomOtherError => 'fel';

  @override
  String get languageTitle => 'Språk';

  @override
  String get languageSystem => 'System';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageItalian => 'Italiano';

  @override
  String get cannotEditPhoto => 'Det här fotot kan inte redigeras här.';

  @override
  String notificationsNew(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count nya notiser',
      one: '1 ny notis',
    );
    return '$_temp0';
  }

  @override
  String messagesUnread(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count olästa meddelanden',
      one: '1 oläst meddelande',
    );
    return '$_temp0';
  }

  @override
  String get done => 'Klar';

  @override
  String get storyAddText => 'Lägg till text';

  @override
  String get storyEditText => 'Redigera text';

  @override
  String get storyTextHint => 'Skriv något… #hashtags går att trycka på';

  @override
  String get storyTextsHelp =>
      'Tryck på bilden för att skriva. Dra för att flytta, nyp för att ändra storlek och rotera, tryck på en text för att redigera den.';

  @override
  String storyTextsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count texter',
      one: '1 text',
      zero: 'Ingen text',
    );
    return '$_temp0';
  }

  @override
  String get storyFontClassic => 'Klassisk';

  @override
  String get storyFontBold => 'Fet';

  @override
  String get storyFontSerif => 'Serif';

  @override
  String get storyFontMono => 'Mono';

  @override
  String get storyFontItalic => 'Kursiv';

  @override
  String get storyTextBackground => 'Textbakgrund';

  @override
  String get storyTextColor => 'Textfärg';

  @override
  String storyTextLimit(int max) {
    return 'Du kan lägga till högst $max texter.';
  }

  @override
  String get wotTitle => 'Förtroendenät';

  @override
  String get wotEnable => 'Förtroendenät är alltid på';

  @override
  String wotExplain(int min) {
    return 'Alltid på. Upptäck visar bara det här nätverket: du, personerna du följer och den som följs av minst $min av dem. Samma nätverk döljer kommentarer, notiser, privata inlägg och meddelanden från alla andra. Det räknas ut på den här telefonen från offentliga följlistor första gången du öppnar appen; senare öppningar återanvänder det. Inget skickas till någon server.';
  }

  @override
  String get wotRefresh => 'Uppdatera nätverket nu';

  @override
  String get wotStatusIdle =>
      'Inte byggt än. Det byggs första gången du öppnar appen.';

  @override
  String get wotBuildingTitle => 'Bygger ditt Upptäck-flöde';

  @override
  String get wotBuildingBody =>
      'Läser vilka personerna du följer också följer, och förbereder Upptäck.';

  @override
  String get wotDiscoverHint =>
      'Bara ditt förtroendenät: personer du följer, och personer som tillräckligt många av dem följer.';

  @override
  String get wotDiscoverSignIn =>
      'Upptäck visar ditt förtroendenät. Logga in så läser Mialuna första gången vem du följer och bygger det här flödet. Senare öppningar återanvänder det.';

  @override
  String get wotDiscoverEmpty => 'Inga inlägg från ditt förtroendenät än.';

  @override
  String wotStatusDiscovering(int done, int total) {
    return 'Kollar vilka de du följer också följer… $done av $total';
  }

  @override
  String wotStatusComplete(int direct, int indirect, Object when) {
    return 'Ditt nätverk: $direct personer du följer plus $indirect som tillräckligt många av dem följer. Uppdaterat $when.';
  }

  @override
  String wotStatusFailed(Object reason) {
    return 'Kunde inte räkna ut ditt nätverk: $reason';
  }

  @override
  String get wotNoFollows => 'du följer ingen än';

  @override
  String get messageRequests => 'Meddelandeförfrågningar';

  @override
  String messageRequestsSubtitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count konversationer utanför ditt förtroendenät',
      one: '1 konversation utanför ditt förtroendenät',
    );
    return '$_temp0';
  }

  @override
  String get messageRequestsHint =>
      'Från personer utanför ditt förtroendenät. De räknas inte som olästa. Svara för att flytta en konversation till inkorgen.';

  @override
  String get storyViewsSetting =>
      'Låt andra se att jag tittat på deras stories';

  @override
  String get storyViewsSettingExplain =>
      'När du tittar på en story skickas ett kvitto till författaren, krypterat så att bara den personen kan läsa det. Det visar ditt namn bredvid hens; relays ser ingenting. Om det inte kan levereras sparas det och försöks igen senare. Stäng av för att titta utan att berätta för någon: kvitton som inte skickats än slängs (ett som redan levererats kan inte tas tillbaka).';

  @override
  String storySeenBy(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Sedd av $count personer',
      one: 'Sedd av 1 person',
      zero: 'Inga visningar än',
    );
    return '$_temp0';
  }

  @override
  String get storyViewsEmpty =>
      'Ingen har tittat på den här storyn än, eller så har deras kvitton inte nått dig.';

  @override
  String get storyViewsHint =>
      'Bara de som tillåter det skickar ett kvitto, så det verkliga antalet kan vara högre.';

  @override
  String get systemNotifications => 'Systemnotiser';

  @override
  String get systemNotificationsExplain =>
      'Visa en notis på telefonen när något nytt kommer medan Mialuna är i bakgrunden. Privata meddelanden visar aldrig sin text, inte ens på låsskärmen. Android pausar appar som ligger länge i bakgrunden, så notiser kommer medan Mialuna fortfarande kör.';

  @override
  String get systemNotificationsBlocked =>
      'Notiser är avstängda för Mialuna i telefonens inställningar.';

  @override
  String get systemNotificationsOpenSettings => 'Öppna inställningar';

  @override
  String get systemNotificationsBattery =>
      'Android försätter appar i vila några minuter efter att skärmen släcks, och notiserna slutar med dem. För att fortsätta få dem, sätt Mialunas batterianvändning till “Obegränsad”.';

  @override
  String get systemNotificationsBatteryAction => 'Öppna batteriinställningar';

  @override
  String get newFollowersSetting => 'Visa nya följare';

  @override
  String get newFollowersSettingExplain =>
      'Nya följare visas i Notiser och på telefonen. Stäng av om folk översvämmar dig med följningar: gilla-markeringar, kommentarer och zaps visas fortfarande.';

  @override
  String get systemNotificationMessage =>
      'skickade ett privat meddelande till dig';

  @override
  String get systemNotificationNewMessage => 'Nytt privat meddelande';

  @override
  String get systemNotificationNew => 'Ny notis';

  @override
  String get notificationChannelSocial =>
      'Reaktioner, kommentarer, zaps och följare';

  @override
  String get notificationChannelMessages => 'Privata meddelanden';

  @override
  String get zapInvoiceMismatch =>
      'Fakturan matchar inte beloppet du valde. Ingenting betalades.';

  @override
  String get storyYourStory => 'Din story';

  @override
  String get storyNew => 'Ny story';

  @override
  String get storyAddSemantics => 'Lägg till i din story';

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
  String get storyTextSize => 'Textstorlek';

  @override
  String get storyPickPrompt => 'Välj ett foto eller en video till din story';

  @override
  String get storyEditPhoto => 'Redigera foto';

  @override
  String get storyCaption => 'Bildtext';

  @override
  String get storyDiscardTitle => 'Släng den här storyn?';

  @override
  String get storyDiscard => 'Släng';

  @override
  String get storyShare => 'Dela';

  @override
  String get storyShared => 'Story delad';

  @override
  String get deletePost => 'Radera';

  @override
  String get deletePostTitle => 'Radera det här inlägget?';

  @override
  String get deleteStoryTitle => 'Radera den här storyn?';

  @override
  String get deletePostBody =>
      'Mialuna ber dina relays att radera det och mediaservrarna att radera dess foton eller video. En relay som struntar i begäran, eller någon som redan sparat en kopia, kan fortfarande ha det.';

  @override
  String get deletePrivateBody =>
      'Ett inlägg för nära vänner kan inte tas tillbaka från relays. Mialuna säger åt dina vänners appar att ta bort det och ber mediaservern att radera dess krypterade filer. En vän som redan sparat en kopia kan fortfarande ha det.';

  @override
  String get deletingPost => 'Raderar…';

  @override
  String get postDeleted => 'Raderat.';

  @override
  String get postWasDeleted => 'Det här inlägget raderades.';

  @override
  String get deleteNotAllowed =>
      'Bara kontot som publicerade det kan radera det.';

  @override
  String deleteFailed(Object reason) {
    return 'Kunde inte radera: $reason';
  }

  @override
  String get deleteNoRelay =>
      'Ingen relay tog emot raderingsbegäran, så det ligger kvar online. Kontrollera din anslutning och försök igen.';

  @override
  String deleteMediaLeft(Object servers) {
    return 'Media kunde inte tas bort från $servers.';
  }

  @override
  String get deleteMediaNotAuthorized =>
      'Din signerare godkände inte att media togs bort, så filerna ligger kvar på mediaservern.';

  @override
  String deleteFriendsMissed(Object count) {
    return '$count av dina nära vänner kunde inte meddelas, så det kan ligga kvar på deras telefoner.';
  }

  @override
  String get storyCleanupSetting => 'Radera mina stories när de går ut';

  @override
  String get storyCleanupSettingExplain =>
      'Efter 24 timmar ber Mialuna dina relays och dina mediaservrar att radera dina stories, inklusive deras foton och videor. En server som struntar i begäran, eller någon som behållit en kopia, kan fortfarande ha dem.';

  @override
  String storyCleanupWaiting(Object count) {
    return 'Din signerare måste godkänna varje städning, så den väntar tills du ber om det. Utgångna stories som väntar: $count.';
  }

  @override
  String get storyCleanupNow => 'Radera nu';

  @override
  String get storyCleanupDone => 'Utgångna stories raderade.';

  @override
  String get storyCleanupPartly =>
      'Vissa kunde inte raderas än; Mialuna försöker igen.';

  @override
  String get editorPro => 'Proredigerare';

  @override
  String get editorModeBasic => 'Bas';

  @override
  String get editorModePro => 'Pro';

  @override
  String get toolCrop => 'Beskär';

  @override
  String get toolLight => 'Ljus';

  @override
  String get toolColor => 'Färg';

  @override
  String get toolHsl => 'HSL';

  @override
  String get toolCurves => 'Kurvor';

  @override
  String get toolEffects => 'Effekter';

  @override
  String get straighten => 'Räta upp';

  @override
  String get exposure => 'Exponering';

  @override
  String get highlights => 'Högdagrar';

  @override
  String get shadows => 'Skuggor';

  @override
  String get whites => 'Vita';

  @override
  String get blacks => 'Svärta';

  @override
  String get temperature => 'Temperatur';

  @override
  String get tint => 'Ton';

  @override
  String get vibrance => 'Lyster';

  @override
  String get hue => 'Nyans';

  @override
  String get luminance => 'Luminans';

  @override
  String get colorRed => 'Röd';

  @override
  String get colorOrange => 'Orange';

  @override
  String get colorYellow => 'Gul';

  @override
  String get colorGreen => 'Grön';

  @override
  String get colorAqua => 'Akva';

  @override
  String get colorBlue => 'Blå';

  @override
  String get colorPurple => 'Lila';

  @override
  String get colorMagenta => 'Magenta';

  @override
  String get curveHint =>
      'Dra en punkt för att forma kurvan, tryck för att lägga till en, dubbeltryck för att ta bort den.';

  @override
  String get sharpen => 'Skärpa';

  @override
  String get vignette => 'Vinjett';

  @override
  String get grain => 'Korn';

  @override
  String get holdForOriginal =>
      'Håll ned fotot för att jämföra med originalet.';

  @override
  String get showingOriginal => 'Original';

  @override
  String get applyLookToAll => 'Använd den här looken på alla foton';

  @override
  String get applyingEdits => 'Bearbetar foton…';

  @override
  String get choosePhotoToEdit => 'Välj ett foto att redigera';
}
