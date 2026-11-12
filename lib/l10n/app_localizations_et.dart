// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Estonian (`et`).
class AppLocalizationsEt extends AppLocalizations {
  AppLocalizationsEt([String locale = 'et']) : super(locale);

  @override
  String get syncUpToDate => 'Ajakohane';

  @override
  String get syncFailed => 'Sünkroonimine ebaõnnestus';

  @override
  String get relaysUpdatedFromProfile =>
      'Relays uuendatud sinu profiilist (NIP-65)';

  @override
  String get relayListPublished => 'Relay nimekiri avaldatud';

  @override
  String get mediaServersUpdatedFromProfile =>
      'Meediaserverid uuendatud sinu profiilist';

  @override
  String get tabHome => 'Home';

  @override
  String get tabDiscover => 'Avasta';

  @override
  String get tabCreate => 'Loo';

  @override
  String get tabReels => 'Reels';

  @override
  String get tabProfile => 'Profiil';

  @override
  String get signInToUploadMedia => 'Logi sisse, et meediat üles laadida.';

  @override
  String get noMediaServer =>
      'Meediaserverit pole seadistatud. Lisa see seadetes.';

  @override
  String serverNoResponse(Object server) {
    return '$server: vastust pole';
  }

  @override
  String serverUnreachable(Object server, Object error) {
    return '$server: kättesaamatu ($error)';
  }

  @override
  String uploadRejected(Object reason) {
    return 'Üleslaadimine tagasi lükatud — $reason';
  }

  @override
  String noServerAcceptedFile(Object reasons) {
    return 'Ükski server ei võtnud faili vastu — $reasons';
  }

  @override
  String get blossomInvalidResponse => 'vigane vastus';

  @override
  String get blossomInvalidFileUrl => 'vigane failiaadress';

  @override
  String get blossomServerAlteredFile => 'server muutis faili';

  @override
  String get blossomBadRequest => 'vigane päring';

  @override
  String get blossomUnauthorized => 'volitus keelatud';

  @override
  String get blossomPaymentRequired => 'nõutav on makse';

  @override
  String get blossomForbidden => 'pole lubatud';

  @override
  String get blossomLengthRequired => 'suurus puudub';

  @override
  String get blossomTooLarge => 'fail on liiga suur';

  @override
  String get blossomUnsupportedType => 'vormingut ei aktsepteerita';

  @override
  String get blossomTooManyRequests => 'liiga palju päringuid';

  @override
  String get blossomServerError => 'serveri viga';

  @override
  String get cipherInvalidKey => 'Vigane võti';

  @override
  String get cipherTruncated => 'Krüptitud fail on kärbitud';

  @override
  String get cipherMismatch => 'Fail ei vasta võtmele: muudetud või rikutud';

  @override
  String get sanitizeHeifNeedsAsync =>
      'Vorming HEIC/AVIF: teisendus nõuab sanitizeAsync';

  @override
  String get sanitizeWebmUnsupported =>
      'Video WebM/MKV ei ole toetatud: kasuta MP4 või MOV, et metaandmed eemaldataks enne üleslaadimist.';

  @override
  String get sanitizeUnknownFormat =>
      'Tundmatu failivorming: fotod JPEG/PNG/WebP/GIF või videod MP4/MOV.';

  @override
  String sanitizeLeftovers(Object items) {
    return 'Kõiki metaandmeid ei õnnestunud eemaldada ($items): faili ei laaditud üles.';
  }

  @override
  String sanitizeProcessingFailed(Object error) {
    return 'Faili ei õnnestunud töödelda: $error';
  }

  @override
  String get sanitizeJpegInvalid => 'Vigane JPEG';

  @override
  String get sanitizeJpegTruncated => 'Kärbitud JPEG';

  @override
  String get sanitizeJpegNoSize => 'JPEG ilma mõõtmeteta';

  @override
  String get sanitizeJpegUndecodable => 'JPEG ei ole dekodeeritav';

  @override
  String get sanitizePngTruncated => 'Kärbitud PNG';

  @override
  String get sanitizePngInvalid => 'Vigane PNG';

  @override
  String get sanitizeGifInvalid => 'Vigane GIF';

  @override
  String get sanitizeGifTruncated => 'Kärbitud GIF';

  @override
  String get sanitizeWebpTruncated => 'Kärbitud WebP';

  @override
  String get sanitizeWebpInvalid => 'Vigane WebP';

  @override
  String get sanitizeMp4Invalid => 'Vigane video MP4/MOV';

  @override
  String get sanitizeConversionFailed => 'Teisendus ebaõnnestus';

  @override
  String get sanitizeHeifUnsupported =>
      'Seda vormingut (HEIC/AVIF) ei saa sellel seadmel teisendada. Vali foto JPEG või PNG.';

  @override
  String get privateMediaNotEncrypted => 'Meedia ei ole krüptitud';

  @override
  String serverReplied(Object status) {
    return 'Server vastas $status';
  }

  @override
  String get fileTooLarge => 'Fail on liiga suur';

  @override
  String get serverFileNotOriginal => 'Serveris olev fail ei ole originaal';

  @override
  String get contentMismatch => 'Sisu ei klapi';

  @override
  String get mediaUnreachable => 'Meedia kättesaamatu';

  @override
  String get amberInvalidKey => 'Amber tagastas vigase võtme';

  @override
  String get amberNoKey => 'Amber ei tagastanud võtit';

  @override
  String get amberRequestRejected => 'Päring tagasi lükatud rakenduses Amber';

  @override
  String get amberAndroidOnly => 'Amber on saadaval ainult Android jaoks';

  @override
  String get amberEmptySignature => 'Amber tagastas tühja allkirja';

  @override
  String get amberSignRejected => 'Allkiri tagasi lükatud rakenduses Amber';

  @override
  String get amberTimeout => 'Amber ei vastanud õigel ajal';

  @override
  String get amberEmptyResponse => 'Amber tagastas tühja vastuse';

  @override
  String get bunkerInvalidUrl => 'Vigane bunker URL';

  @override
  String get bunkerNoRelay => 'bunker ei loetle ühtegi relay';

  @override
  String get bunkerWebAuth =>
      'bunker nõuab veebiautoriseerimist (auth_url ei ole toetatud)';

  @override
  String get bunkerInvalidKey => 'bunker ei tagastanud kehtivat võtit';

  @override
  String get signerInvalidResponse =>
      'Allkirjastaja tagastas vigase allkirjastatud sündmuse';

  @override
  String get bunkerTimeout => 'Bunker aegus';

  @override
  String get nwcInvalidUri => 'Vigane NWC URI';

  @override
  String get nwcNoRelay => 'NWC URI ei loetle ühtegi relay';

  @override
  String get nwcNoSecret => 'NWC URI ei sisalda kehtivat saladust';

  @override
  String get nwcTimeout => 'Rahakott aegus';

  @override
  String get signerNoPrivateMessages =>
      'See sisselogimisviis ei toeta privaatsõnumeid';

  @override
  String get zapNotSupported => 'See aadress ei toeta Nostr zaps';

  @override
  String zapAmountOutOfRange(Object min, Object max) {
    return 'Summa on vahemikust väljas ($min–$max sats)';
  }

  @override
  String get commentNotSent => 'Kommentaari ei saadetud. Proovi hiljem uuesti.';

  @override
  String get comments => 'Kommentaarid';

  @override
  String get noCommentsYet => 'Kommentaare veel pole.';

  @override
  String get signInToComment => 'Logi sisse, et kommenteerida.';

  @override
  String get addComment => 'Lisa kommentaar…';

  @override
  String get signInToPublish => 'Logi sisse, et avaldada.';

  @override
  String get addMediaFirst =>
      'Lisa enne avaldamist vähemalt üks foto või video.';

  @override
  String get removingMetadata => 'Eemaldan metaandmeid…';

  @override
  String uploadingProgress(Object current, Object total) {
    return 'Laadin üles $current / $total…';
  }

  @override
  String get creatingPreview => 'Loon eelvaadet…';

  @override
  String uploadFailed(Object error) {
    return 'Üleslaadimine ebaõnnestus: $error';
  }

  @override
  String get publishing => 'Avaldan…';

  @override
  String noRelayAcceptedPost(Object reason) {
    return 'Ükski relay ei võtnud postitust vastu$reason. Sisu jääb mustanditesse.';
  }

  @override
  String get privateNeedsKeySigner =>
      'See sisselogimisviis ei toeta privaatset sisu. Kasuta Amber, bunker või kohalikku võtit.';

  @override
  String get closeFriendsListEmptyAddSomeone =>
      'Sinu lähedaste sõprade nimekiri on tühi: lisa keegi.';

  @override
  String get fileOver100Mb =>
      'Fail on suurem kui 100 MB: see on piir lähedastele sõpradele (see krüptitakse tervenisti sinu telefonis).';

  @override
  String get encryptingOnPhone => 'Krüptin sinu telefonis…';

  @override
  String noServerAcceptedEncrypted(Object details) {
    return 'Ükski sinu meediaserver ei võtnud krüptitud faili vastu. Seda ei avaldata krüptimata. Lisa seadetes server, mis võtab krüptitud faile vastu (näiteks cdn.hzrd149.com). $details';
  }

  @override
  String get sendingToFriends => 'Saadan sõpradele…';

  @override
  String sendingToFriendsProgress(Object done, Object total) {
    return 'Saadan sõpradele $done/$total…';
  }

  @override
  String noFriendReceivedPost(Object reason) {
    return 'Ükski sõber ei saanud postitust kätte$reason. Sisu jääb mustanditesse.';
  }

  @override
  String sentToCloseFriends(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Saadetud $count lähedasele sõbrale 🔒',
      one: 'Saadetud 1 lähedasele sõbrale 🔒',
    );
    return '$_temp0';
  }

  @override
  String sentToFriendsWithMisses(int delivered, Object missed) {
    String _temp0 = intl.Intl.pluralLogic(
      delivered,
      locale: localeName,
      other: 'Saadetud $delivered sõbrale.',
      one: 'Saadetud 1 sõbrale.',
    );
    return '$_temp0 $missed ei saanud seda kätte (privaatsõnumid on väljas).';
  }

  @override
  String get altText => 'Asendustekst';

  @override
  String get altTextHint => 'Kirjelda sisu neile, kes seda ei näe…';

  @override
  String get cancel => 'Tühista';

  @override
  String get save => 'Salvesta';

  @override
  String get momentPublished => 'Hetk avaldatud ✨';

  @override
  String get newMoment => 'Uus hetk';

  @override
  String get publish => 'Avalda';

  @override
  String get guestMode => 'Külalise režiim';

  @override
  String get signInToPostMoments => 'Logi sisse, et avaldada oma hetki.';

  @override
  String get signIn => 'Logi sisse';

  @override
  String get kindPhoto => 'Foto';

  @override
  String get kindVideo => 'Video';

  @override
  String get kindReel => 'Reel';

  @override
  String get kindStory => 'Lugu';

  @override
  String get storyExpiryNote =>
      'Lood aeguvad 24 tunni pärast relays, mis järgivad NIP-40, kuid teised võivad neid ikka salvestada või arhiveerida.';

  @override
  String get fromGallery => 'Galeriist';

  @override
  String get galleryLongPressVideo => 'Galerii (pikk vajutus video jaoks)';

  @override
  String get addVideo => 'Lisa video';

  @override
  String get camera => 'Kaamera';

  @override
  String get exifRemovedNote =>
      'Asukoha metaandmed (EXIF) eemaldatakse automaatselt.';

  @override
  String get writeCaption => 'Kirjuta pealdis…';

  @override
  String get privatePostNote =>
      'Privaatne postitus: ilma avalike hashtagideta, otsinguga seda ei leia.';

  @override
  String willPublishAs(Object caption) {
    return 'Avaldatakse kujul: \"$caption\"';
  }

  @override
  String get tapThumbnailForAlt => 'Puuduta pisipilti, et lisada asendustekst.';

  @override
  String get sensitiveContent => 'Tundlik sisu';

  @override
  String get sensitiveContentNote =>
      'Postitus peidetakse hoiatuse taha (NIP-36).';

  @override
  String get uploadingMedia => 'Laadin meediat üles…';

  @override
  String get audiencePublic => 'Avalik';

  @override
  String get closeFriends => 'Lähedased sõbrad';

  @override
  String get signerCannotPublishCloseFriends =>
      'Selle sisselogimisviisiga ei saa avaldada lähedastele sõpradele: kasuta Amber, bunker või kohalikku võtit.';

  @override
  String get closeFriendsEmptyPrompt =>
      'Sinu nimekiri on tühi: lisa inimesed, kes seda postitust näha saavad.';

  @override
  String onlyYourCloseFriendsSee(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Seda näevad ainult sinu $count lähedast sõpra. Fotod ja videod krüptitakse sinu telefonis enne üleslaadimist.',
      one: 'Seda näeb ainult sinu 1 lähedane sõber. Fotod ja videod krüptitakse sinu telefonis enne üleslaadimist.',
    );
    return '$_temp0';
  }

  @override
  String get addFriends => 'Lisa sõpru';

  @override
  String get manageList => 'Halda nimekirja';

  @override
  String get edit => 'Muuda';

  @override
  String get reset => 'Lähtesta';

  @override
  String get apply => 'Rakenda';

  @override
  String get cropFree => 'Vaba';

  @override
  String get cropOriginal => 'Originaal';

  @override
  String get rotate => 'Pööra';

  @override
  String get flip => 'Peegelda';

  @override
  String get brightness => 'Heledus';

  @override
  String get contrast => 'Kontrast';

  @override
  String get saturation => 'Küllastus';

  @override
  String postsByAuthor(Object author) {
    return 'Postitused kasutajalt $author…';
  }

  @override
  String get searchHint => 'Otsi inimesi, hashtage või sõnu…';

  @override
  String get clear => 'Tühjenda';

  @override
  String get recent => 'Hiljutised';

  @override
  String get searchDependsOnRelays =>
      'Otsing sõltub seadistatud relays: tulemused võivad olla osalised.';

  @override
  String get recentPostsEverywhere =>
      'Värsked postitused kogu võrgust, ka inimestelt, keda sa ei jälgi.';

  @override
  String get noResultsOnRelays => 'Seadistatud relays peal pole tulemusi.';

  @override
  String get noRecentPostsFromFollowed =>
      'Inimestelt, keda jälgid, pole värskeid postitusi.';

  @override
  String get noMomentsFound =>
      'Hetki ei leitud relays pealt. Kontrolli ühendust.';

  @override
  String get loadFailed => 'Laadimine ebaõnnestus';

  @override
  String get notifications => 'Teavitused';

  @override
  String get messages => 'Sõnumid';

  @override
  String get homeEmptyFollowsNobody =>
      'Siin on postitused inimestelt, keda jälgid.\nSa ei jälgi veel kedagi: avasta huvitavaid inimesi ja profiile.';

  @override
  String get discoverPeople => 'Avasta inimesi';

  @override
  String get homeEmpty =>
      'Hetki veel pole.\nTõmba alla värskendamiseks või avalda oma esimene võte.';

  @override
  String get retry => 'Proovi uuesti';

  @override
  String get seenEverything => 'Oled praeguseks kõike näinud ✨';

  @override
  String get discoverMoreProfiles => 'Avasta veel profiile';

  @override
  String get feedFollowing => 'Jälgid';

  @override
  String get signInToSeeFollowed =>
      'Logi sisse, et näha postitusi inimestelt, keda jälgid';

  @override
  String get videoPreview => 'Video eelvaade';

  @override
  String get cannotOpenPrivateVideo => 'Privaatset videot ei saa avada';

  @override
  String get cannotPlayVideo => 'Videot ei saa esitada';

  @override
  String get pauseVideo => 'Peata video';

  @override
  String get playVideo => 'Esita video';

  @override
  String errorTapToRetry(Object error) {
    return '$error — puuduta, et uuesti proovida';
  }

  @override
  String get soundOn => 'Lülita heli sisse';

  @override
  String get soundOff => 'Lülita heli välja';

  @override
  String get postImage => 'Postituse pilt';

  @override
  String get imageUnavailable => 'Pilt pole saadaval';

  @override
  String errorTapToRetryNewline(Object message) {
    return '$message\nPuuduta, et uuesti proovida';
  }

  @override
  String get cannotOpenPrivateContent => 'Seda privaatset sisu ei saa avada';

  @override
  String get privateImage => 'Privaatne pilt';

  @override
  String get invalidImage => 'Vigane pilt';

  @override
  String get more => 'Veel';

  @override
  String get removeFromSaved => 'Eemalda salvestatutest';

  @override
  String get copyLink => 'Kopeeri link';

  @override
  String get muteAuthor => 'Vaigista autor';

  @override
  String get blockAuthor => 'Blokeeri autor';

  @override
  String get report => 'Teata';

  @override
  String get like => 'Meeldib';

  @override
  String get sendInMessage => 'Saada sõnumiga';

  @override
  String get zapOptional => 'Zap (valikuline)';

  @override
  String get closeFriendsOnlyNote =>
      'Nähtav ainult lähedastele sõpradele. Meeldimised ja vastused lähevad ainult autorile.';

  @override
  String get likeFailed => 'Meeldimist ei saanud saata';

  @override
  String get nostrLinkCopied => 'Nostr link kopeeritud lõikelauale';

  @override
  String get authorMuted => 'Autor vaigistatud';

  @override
  String get authorBlocked => 'Autor blokeeritud';

  @override
  String get reportSent => 'Teade saadetud (NIP-56)';

  @override
  String get signInToReport => 'Logi sisse, et teatada';

  @override
  String minutesAgo(Object minutes) {
    return '$minutes min tagasi';
  }

  @override
  String get show => 'Näita';

  @override
  String get chatEmptyHint =>
      'Kirjuta esimene sõnum.\nSee on krüptitud: ainult sina ja teine näete seda.';

  @override
  String get messageHint => 'Sõnum…';

  @override
  String get send => 'Saada';

  @override
  String get notSentSuffix => ' saatmata';

  @override
  String get contentUnavailable =>
      'Sisu pole saadaval (aegunud või relays pealt ei leitud)';

  @override
  String get signInToSendPrivateMessages =>
      'Logi sisse, et saata privaatsõnumeid.';

  @override
  String get cannotMessageYourself => 'Iseendale kirjutada ei saa.';

  @override
  String get recipientNoPrivateMessages =>
      'See inimene ei ole veel privaatsõnumeid sisse lülitanud.';

  @override
  String noRecipientRelayAccepted(Object reason) {
    return 'Ükski saaja relay ei võtnud sõnumit vastu$reason.';
  }

  @override
  String sendFailed(Object error) {
    return 'Saatmine ebaõnnestus: $error';
  }

  @override
  String get signInToReadMessages =>
      'Logi sisse, et lugeda ja saata privaatsõnumeid.';

  @override
  String get signerNoPrivateMessagesLong =>
      'Privaatsõnumeid ei saa selle sisselogimisviisiga kasutada. Logi sisse valikuga Amber, bunker või kohalik võti.';

  @override
  String get inboxEmpty =>
      'Vestlusi pole.\nPuuduta pliiatsit, et kellelegi kirjutada, või saada hetk edasi ikooniga ✈ iga postituse all.';

  @override
  String get newMessage => 'Uus sõnum';

  @override
  String get privateMessagesEnabled => 'Privaatsõnumid sees';

  @override
  String get enableMessagesFailed =>
      'Ei saanud neid sisse lülitada. Proovi uuesti.';

  @override
  String get enablePrivateMessages => 'Lülita privaatsõnumid sisse';

  @override
  String enablePrivateMessagesExplain(Object count) {
    return 'Sõnumite saamiseks pead ütlema, millistele relays need jõudma peaksid. Avaldatakse väike nimekiri (NIP-17), kus on $count vaikimisi relays: hiljem saad seda muuta. Sõnumid jäävad krüptituks: relays ei näe, kes kirjutab ega ka teksti.';
  }

  @override
  String get turnOn => 'Lülita sisse';

  @override
  String get searchByNameOrUsername => 'Otsi nime või kasutajanime järgi';

  @override
  String get searching => 'Otsin…';

  @override
  String get noOneWithNameHint =>
      'Selle nimega ei ole kedagi. Proovi vähem tähti või aadressi nagu name@domain.com.';

  @override
  String get sent => 'Saadetud';

  @override
  String sentToPeople(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Saadetud $count inimesele',
      one: 'Saadetud 1 inimesele',
    );
    return '$_temp0';
  }

  @override
  String sentToPeopleWithFailure(int count, Object failure) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Saadetud $count inimesele. $failure',
      one: 'Saadetud 1 inimesele. $failure',
    );
    return '$_temp0';
  }

  @override
  String get signerNoPrivateMessagesShort =>
      'Privaatsõnumeid ei saa selle sisselogimisviisiga kasutada.';

  @override
  String get followToStartOrSearch =>
      'Jälgi kedagi, et alustada, või otsi nime järgi.';

  @override
  String get addMessage => 'Lisa sõnum…';

  @override
  String sendWithCount(Object count) {
    return 'Saada ($count)';
  }

  @override
  String get linkCopied => 'Link kopeeritud lõikelauale';

  @override
  String get noNotifications => 'Praegu teavitusi pole.';

  @override
  String get notificationsDependOnRelays =>
      'Teavitused sõltuvad relays: need võivad olla puudulikud.';

  @override
  String get reactedToYourMoment => 'reageeris sinu hetkele';

  @override
  String commentedText(Object text) {
    return 'kommenteeris: $text';
  }

  @override
  String sentYouSats(Object sats, Object comment) {
    return 'saatise sulle $sats sats$comment';
  }

  @override
  String get sentYouZap => 'saatise sulle zap';

  @override
  String get startedFollowingYou => 'hakkas sind jälgima';

  @override
  String get amberNotFound => 'Amber ei leitud';

  @override
  String get amberExplain =>
      'Amber on Nostr allkirjastaja, mis hoiab sinu privaatvõtit väljaspool Mialuna. Paigalda see ja proovi uuesti.';

  @override
  String get downloadFromFdroid => 'Laadi alla saidilt F-Droid';

  @override
  String get continueWithAmber => 'Jätka rakendusega Amber';

  @override
  String get amberRecommended =>
      'Soovitatud: sinu privaatvõti jääb Amber sisse kaitstult.';

  @override
  String get amberNotDetected =>
      'Amber ei ole tuvastatud: paigalda see soovitatud sisselogimiseks.';

  @override
  String get exploreWithoutAccount => 'Uuri ilma kontota';

  @override
  String get remoteBunker => 'Kaugjuhitav bunker (NIP-46)';

  @override
  String get invalidBunkerUrlDot => 'Vigane bunker URL.';

  @override
  String get connectBunker => 'Ühenda bunker';

  @override
  String get advancedNsec => 'Täpsem sisselogimine (nsec)';

  @override
  String get nsecWarning =>
      'Hoiatus: privaatvõtme kleepimine on riskantne. Ära jaga seda kunagi kellegagi. Süsteemis Android eelista Amber.';

  @override
  String get invalidNsec => 'Vigane võti nsec.';

  @override
  String get signInWithNsec => 'Logi sisse võtmega nsec';

  @override
  String get tagline => 'Sinu hetked, sama kuu all.';

  @override
  String get skip => 'Jäta vahele';

  @override
  String get permissionsAndWallet => 'Load ja rahakott';

  @override
  String get permissionsExplain =>
      'Need lasevad sul ainult avaldada ja teavitusi saada. Saad neid igal ajal süsteemi seadetes muuta.';

  @override
  String get photosAndVideos => 'Fotod ja videod';

  @override
  String get toUploadYourMoments => 'Sinu hetkede üleslaadimiseks';

  @override
  String get allow => 'Luba';

  @override
  String get reactionsCommentsZaps => 'Reaktsioonid, kommentaarid ja zaps';

  @override
  String get lightningWalletOptional => 'Lightning rahakott (valikuline)';

  @override
  String get nwcExplain =>
      'Ühenda rahakott Nostr Wallet Connect, et saata zaps rakendusest lahkumata.';

  @override
  String get walletConnected => 'Rahakott ühendatud';

  @override
  String get disconnect => 'Ühenda lahti';

  @override
  String get connectWallet => 'Ühenda rahakott';

  @override
  String get getStarted => 'Alusta';

  @override
  String get welcome1 =>
      'Mialuna on visuaalne sotsiaalvõrk: fotod, videod, Reels ja lood — mitte kunagi ainult tekstipostitused.';

  @override
  String get welcome2 =>
      'See töötab võrgus Nostr, avatud protokollil: sinu identiteet on võti, mis kuulub sulle, mitte konto, mille ettevõte saab ära võtta. Ei reklaame, ei jälgijaid, ei keskservereid.';

  @override
  String get welcome3 =>
      'Jaga oma valgust inimestega kõikjal, ükskõik millisest rakendusest, mis räägib sama avatud keelt.';

  @override
  String onboardingWot(int min) {
    return 'Usaldusvõrk on alati sees. Kui avad Mialuna esimest korda, loeb see, keda jälgid, ja ehitab sellest võrgust voo Avasta: sina, inimesed, keda jälgid, ja igaüks, keda jälgib neist vähemalt $min. Järgmistel avamistel on see voog juba olemas.';
  }

  @override
  String get publicAndPrivate => 'Avalik ja privaatne';

  @override
  String get publicAndPrivateIntro =>
      'Mialuna põhineb avatud võrgul Nostr. See, mida avaldad, on avalik: postitused, fotod ja videod jäävad nähtavaks igaühele, kellel on link, ka väljaspool Mialuna.';

  @override
  String get closeFriendsExplain1 =>
      'Ainult selle nimekirja inimesed saavad sinu postitused, lood ja videod \"Lähedased sõbrad\". Nimekiri on postituse sees; seda ei pea iga kord valima.';

  @override
  String get closeFriendsExplain2 =>
      'Fotod ja videod krüptitakse sinu telefonis enne üleslaadimist. Failiserverid (Blossom) ise midagi ei krüpti: seepärast teeb seda Mialuna ja server näeb ainult loetamatuid andmeid. Kes failiaadressi leiab, ei saa seda avada.';

  @override
  String get closeFriendsExplain3 =>
      'See ei ole täielik garantii: kes postituse saab, võib teha ekraanipildi, ja sõbra eemaldamine kehtib ainult tulevaste postituste kohta.';

  @override
  String get closeFriendsExplain4 =>
      'Iga sõber peab kasutama Mialuna sisselülitatud privaatsõnumitega. Teised Nostr kliendid neid postitusi ei näita.';

  @override
  String get closeFriendsExplain5 =>
      'Avalikud postitused jäävad avalikuks: nende faile näeb igaüks, kellel on link.';

  @override
  String get closeFriendsExplain6 =>
      'Kui ükski sinu server krüptitud faile vastu ei võta, postitust ei avaldata: mitte kunagi krüptimata.';

  @override
  String get addToCloseFriends => 'Lisa lähedaste sõprade hulka';

  @override
  String maxFriendsReached(Object max, Object added) {
    return 'Piirang $max sõpra: lisatud $added.';
  }

  @override
  String get add => 'Lisa';

  @override
  String get signInToCreateList => 'Logi sisse, et luua oma nimekiri.';

  @override
  String get signerNoCloseFriends =>
      'Lähedasi sõpru ei saa selle sisselogimisviisiga kasutada. Logi sisse valikuga Amber, bunker või kohalik võti.';

  @override
  String peopleOfMax(Object count, Object max) {
    return '$count / $max inimest';
  }

  @override
  String get noOneYet => 'Kedagi veel pole.';

  @override
  String get addPeople => 'Lisa inimesi';

  @override
  String get friendNoPrivateMessagesWarning =>
      'Nad ei ole privaatsõnumeid sisse lülitanud: nad ei saa sinu postitusi';

  @override
  String get removeFromList => 'Eemalda nimekirjast';

  @override
  String get noOneWithThisName => 'Selle nimega ei ole kedagi.';

  @override
  String get signInToSendPrivateContent =>
      'Logi sisse, et saata privaatset sisu.';

  @override
  String get reasonNoPrivateMessages =>
      'ei ole privaatsõnumeid sisse lülitanud';

  @override
  String get reasonNoRelayAnswered => 'ükski relay ei vastanud';

  @override
  String get profileUpdated => 'Profiil uuendatud';

  @override
  String get noRelayAcceptedRetry =>
      'Ükski relay ei võtnud vastu. Proovi hiljem uuesti.';

  @override
  String get editProfile => 'Muuda profiili';

  @override
  String get fieldName => 'Nimi';

  @override
  String get fieldBio => 'Bio';

  @override
  String get fieldAvatarUrl => 'Avatari URL';

  @override
  String get fieldNip05 => 'NIP-05 (nt you@example.com)';

  @override
  String get browsingAsGuest => 'Sirvid külalisena';

  @override
  String get signInToInteract => 'Logi sisse, et avaldada, jälgida ja suhelda.';

  @override
  String get settings => 'Seaded';

  @override
  String get signOut => 'Logi välja';

  @override
  String get npubCopied => 'npub kopeeritud';

  @override
  String get copyNpub => 'Kopeeri npub';

  @override
  String get mute => 'Vaigista';

  @override
  String get block => 'Blokeeri';

  @override
  String get posts => 'Postitused';

  @override
  String get saved => 'Salvestatud';

  @override
  String get nothingPublishedYet => 'Sa ei ole veel midagi avaldanud.';

  @override
  String get noPostsOnRelays => 'Postitusi ei leitud relays pealt.';

  @override
  String get noReelsPublished => 'Ühtegi reels ei ole avaldatud.';

  @override
  String get noReelsOnRelays => 'Ühtegi reels ei leitud relays pealt.';

  @override
  String get noSavedPosts => 'Salvestatud postitusi pole.';

  @override
  String get followingButton => 'Jälgid';

  @override
  String get follow => 'Jälgi';

  @override
  String get messageButton => 'Sõnum';

  @override
  String get loginLocalKey => 'Kohalik võti';

  @override
  String get loginGuest => 'Külaline';

  @override
  String get followUpdateFailed =>
      'Sinu jälgimisi ei saanud praegu uuendada. Proovi uuesti.';

  @override
  String get noReelsComeBack =>
      'Ühtegi reels ei leitud relays pealt.\nTule varsti tagasi!';

  @override
  String get followUpdateFailedShort =>
      'Sinu jälgimisi ei saanud praegu uuendada';

  @override
  String get needOneReadRelay => 'Vaja on vähemalt ühte relay lugemiseks.';

  @override
  String get listSavedLocally =>
      'Nimekiri on salvestatud sellesse seadmesse, mitte avaldatud.';

  @override
  String get noRelayAcceptedList =>
      'Ükski relay ei võtnud nimekirja vastu: proovitakse hiljem uuesti.';

  @override
  String relayListPublishedTo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Relay nimekiri avaldatud $count relays peale',
      one: 'Relay nimekiri avaldatud 1 relay peale',
    );
    return '$_temp0';
  }

  @override
  String get mediaServersUpdated => 'Meediaserverid uuendatud';

  @override
  String get appearance => 'Välimus';

  @override
  String get publishingSettings => 'Avaldamine';

  @override
  String get addMialunaHashtag => 'Lisa #mialuna';

  @override
  String get addMialunaHashtagNote =>
      'Lisa ametlik hashtag avalikele postitustele ja lugudele. Saad selle igal ajal välja lülitada.';

  @override
  String get themeLight => 'Hele';

  @override
  String get themeDark => 'Tume';

  @override
  String get themeSystem => 'Süsteem';

  @override
  String get relays => 'Relays';

  @override
  String get relaysExplainSignedOut =>
      'Relays säilitavad ja levitavad sisu. Logi sisse, et kasutada automaatselt oma nimekirja (NIP-65).';

  @override
  String get relaysExplainSynced =>
      'Nimekiri on sünkroonitud sinu profiiliga Nostr (NIP-65): iga muudatus avaldatakse ja kehtib kõigis sinu rakendustes.';

  @override
  String get syncing => 'Sünkroonimine…';

  @override
  String get waitingFirstSync => 'Ootan esimest sünkroonimist';

  @override
  String get syncNow => 'Sünkrooni kohe';

  @override
  String get addRelay => 'Lisa relay';

  @override
  String get restoreDefaultRelays => 'Taasta vaikimisi relays';

  @override
  String get createYourList => 'Loo oma nimekiri';

  @override
  String peopleCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count inimest',
      one: '1 inimene',
    );
    return '$_temp0';
  }

  @override
  String get closeFriendsSettingsNote =>
      'Postitused, lood ja videod, mida näevad ainult nemad, krüptitud fotode ja videotega.';

  @override
  String get mediaServersBlossom => 'Meediaserverid (Blossom)';

  @override
  String get mediaServersExplain =>
      'Fotod ja videod laaditakse üles ainult nendesse serveritesse, näidatud järjekorras: võidab esimene, mis need vastu võtab. EXIF ja asukoht eemaldatakse enne üleslaadimist.';

  @override
  String get primary => 'Peamine';

  @override
  String get makePrimary => 'Määra peamiseks';

  @override
  String get remove => 'Eemalda';

  @override
  String get addServer => 'Lisa server';

  @override
  String get moderation => 'Modereerimine';

  @override
  String get moderationExplain =>
      'Vaigistatud autorid ja peidetud hashtagid sünkroonitakse NIP-51 kaudu. Blokeeritud autorid jäävad ainult sellesse seadmesse.';

  @override
  String get mutedAuthors => 'Vaigistatud autorid';

  @override
  String get noMutedAuthors => 'Vaigistatud autoreid pole';

  @override
  String get blockedAuthors => 'Blokeeritud autorid';

  @override
  String get noBlockedAuthors => 'Blokeeritud autoreid pole';

  @override
  String get hiddenHashtags => 'Peidetud hashtagid';

  @override
  String get noHiddenHashtags => 'Peidetud hashtage pole';

  @override
  String get hashtagToHide => '#hashtag, mida peita';

  @override
  String get storage => 'Salvestus';

  @override
  String get clearCache => 'Tühjenda sündmuste vahemälu ja mustandid';

  @override
  String get cacheCleared => 'Vahemälu tühjendatud';

  @override
  String get reviewIntro => 'Vaata sissejuhatust uuesti';

  @override
  String get reviewIntroSubtitle =>
      'Mis on avalik, mis privaatne ja lähedaste sõprade piirid.';

  @override
  String noLightningWalletCopied(Object address) {
    return 'Lightning rahakotti ei leitud: aadress kopeeritud ($address)';
  }

  @override
  String get about => 'Teave';

  @override
  String aboutText(Object version) {
    return 'Mialuna $version — Sinu hetked, sama kuu all.\nAvatud lähtekood (MIT). github.com/Lwb89dev/mialuna';
  }

  @override
  String get invalidRelayAddress => 'Vigane aadress: kasuta wss://…';

  @override
  String get invalidServerAddress => 'Vigane aadress: kasuta https://…';

  @override
  String get relayRead => 'Lugemine';

  @override
  String get relayWrite => 'Kirjutamine';

  @override
  String get support => 'Tugi';

  @override
  String get supportText =>
      'Mialuna on tasuta, reklaamideta ega jälgi sind. Kui see meeldib, võid saata mõned sats võrgu Lightning kaudu.';

  @override
  String get donateWithLightning => 'Anneta Lightning kaudu';

  @override
  String get authorNoZaps => 'See autor ei võta zaps vastu';

  @override
  String get sendZap => 'Saada zap ⚡';

  @override
  String get amountInSats => 'Summa sats';

  @override
  String minMaxSats(Object min, Object max) {
    return 'min $min – max $max';
  }

  @override
  String get zap => 'Zap';

  @override
  String get signInToZap => 'Logi sisse, et saata zaps';

  @override
  String zapSent(Object sats) {
    return 'Zap $sats sats saadetud ⚡';
  }

  @override
  String nwcPaymentFailed(Object error) {
    return 'NWC makse ebaõnnestus: $error';
  }

  @override
  String get noLightningWallet => 'Lightning rahakotti ei leitud';

  @override
  String storiesRailLabel(Object state) {
    return 'Lood, $state';
  }

  @override
  String get close => 'Sulge';

  @override
  String hoursAgo(int hours) {
    return '$hours h tagasi';
  }

  @override
  String daysAgo(int days) {
    return '$days d tagasi';
  }

  @override
  String get now => 'praegu';

  @override
  String get youPrefix => 'Sina: ';

  @override
  String get storiesStateUnseen => 'uus';

  @override
  String get storiesStateSeen => 'nähtud';

  @override
  String weekdayShort(String day) {
    String _temp0 = intl.Intl.selectLogic(day, {
      'mon': 'E',
      'tue': 'T',
      'wed': 'K',
      'thu': 'N',
      'fri': 'R',
      'sat': 'L',
      'sun': 'P',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get sharedAMoment => 'Jagas hetke';

  @override
  String get blossomOtherError => 'viga';

  @override
  String get languageTitle => 'Keel';

  @override
  String get languageSystem => 'Süsteem';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageItalian => 'Italiano';

  @override
  String get cannotEditPhoto => 'Seda fotot ei saa siin muuta.';

  @override
  String notificationsNew(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count uut teavitust',
      one: '1 uus teavitus',
    );
    return '$_temp0';
  }

  @override
  String messagesUnread(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count lugemata sõnumit',
      one: '1 lugemata sõnum',
    );
    return '$_temp0';
  }

  @override
  String get done => 'Valmis';

  @override
  String get storyAddText => 'Lisa tekst';

  @override
  String get storyEditText => 'Muuda teksti';

  @override
  String get storyTextHint => 'Kirjuta midagi… #hashtags on puudutatavad';

  @override
  String get storyTextsHelp =>
      'Puuduta pilti, et kirjutada. Lohista liigutamiseks, näpista suuruse ja pööramise jaoks, puuduta teksti muutmiseks.';

  @override
  String storyTextsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count teksti',
      one: '1 tekst',
      zero: 'Teksti pole',
    );
    return '$_temp0';
  }

  @override
  String get storyFontClassic => 'Klassikaline';

  @override
  String get storyFontBold => 'Rasvane';

  @override
  String get storyFontSerif => 'Serif';

  @override
  String get storyFontMono => 'Mono';

  @override
  String get storyFontItalic => 'Kaldkiri';

  @override
  String get storyTextBackground => 'Teksti taust';

  @override
  String get storyTextColor => 'Teksti värv';

  @override
  String storyTextLimit(int max) {
    return 'Lisada saad kuni $max teksti.';
  }

  @override
  String get wotTitle => 'Usaldusvõrk';

  @override
  String get wotEnable => 'Usaldusvõrk on alati sees';

  @override
  String wotExplain(int min) {
    return 'Alati sees. Avasta näitab ainult seda võrku: sina, inimesed, keda jälgid, ja igaüks, keda jälgib neist vähemalt $min. Sama võrk peidab kõigi teiste kommentaarid, teavitused, privaatsed postitused ja sõnumid. See arvutatakse selles telefonis avalikest jälgimisnimekirjadest, kui avad rakenduse esimest korda; hilisemad avamised kasutavad seda uuesti. Mitte midagi ei saadeta ühelegi serverile.';
  }

  @override
  String get wotRefresh => 'Värskenda võrku kohe';

  @override
  String get wotStatusIdle =>
      'Pole veel loodud. See luuakse, kui avad rakenduse esimest korda.';

  @override
  String get wotBuildingTitle => 'Ehitan sinu voogu Avasta';

  @override
  String get wotBuildingBody =>
      'Loen, keda jälgivad ka inimesed, keda sina jälgid, ja valmistan ette Avasta.';

  @override
  String get wotDiscoverHint =>
      'Ainult sinu usaldusvõrk: inimesed, keda jälgid, ja inimesed, keda jälgib neist piisavalt.';

  @override
  String get wotDiscoverSignIn =>
      'Avasta näitab sinu usaldusvõrku. Logi sisse ja esimesel korral loeb Mialuna, keda jälgid, ning ehitab selle voo. Hilisemad avamised kasutavad seda uuesti.';

  @override
  String get wotDiscoverEmpty => 'Sinu usaldusvõrgust pole veel postitusi.';

  @override
  String wotStatusDiscovering(int done, int total) {
    return 'Kontrollin, keda sinu jälgitavad jälgivad… $done / $total';
  }

  @override
  String wotStatusComplete(int direct, int indirect, Object when) {
    return 'Sinu võrk: $direct inimest, keda jälgid, pluss $indirect, keda jälgib neist piisavalt. Uuendatud $when.';
  }

  @override
  String wotStatusFailed(Object reason) {
    return 'Sinu võrku ei õnnestunud arvutada: $reason';
  }

  @override
  String get wotNoFollows => 'sa ei jälgi veel kedagi';

  @override
  String get messageRequests => 'Sõnumipalved';

  @override
  String messageRequestsSubtitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count vestlust väljaspool sinu usaldusvõrku',
      one: '1 vestlus väljaspool sinu usaldusvõrku',
    );
    return '$_temp0';
  }

  @override
  String get messageRequestsHint =>
      'Inimestelt väljaspool sinu usaldusvõrku. Need ei loe lugemata sõnumiteks. Vasta, et vestlus liiguks postkasti.';

  @override
  String get storyViewsSetting =>
      'Las inimesed näevad, et vaatasin nende lugusid';

  @override
  String get storyViewsSettingExplain =>
      'Kui vaatad lugu, saadetakse selle autorile kviitung, krüptitult, nii et ainult tema saab seda lugeda. Seal on sinu nimi tema oma kõrval; relays ei näe midagi. Kui seda ei saa kohale toimetada, hoitakse seda alles ja proovitakse hiljem uuesti. Lülita välja, kui tahad vaadata nii, et keegi ei tea: veel saatmata kviitungid hüljatakse (juba kohale jõudnut tagasi võtta ei saa).';

  @override
  String storySeenBy(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Näinud $count inimest',
      one: 'Näinud 1 inimene',
      zero: 'Vaateid veel pole',
    );
    return '$_temp0';
  }

  @override
  String get storyViewsEmpty =>
      'Seda lugu ei ole veel keegi vaadanud või ei ole nende kviitungid sinuni jõudnud.';

  @override
  String get storyViewsHint =>
      'Kviitungi saadavad ainult need, kes seda lubavad, seega võib tegelik arv olla suurem.';

  @override
  String get systemNotifications => 'Süsteemi teavitused';

  @override
  String get systemNotificationsExplain =>
      'Näita telefonis teavitust, kui midagi uut saabub ajal, mil Mialuna on taustal. Privaatsõnumid ei näita kunagi oma teksti, isegi mitte lukustuskuval. Android peatab rakendused, mis jäävad kauaks taustale, seepärast jõuavad teavitused kohale seni, kuni Mialuna veel töötab.';

  @override
  String get systemNotificationsBlocked =>
      'Teavitused on Mialuna jaoks telefoni seadetes välja lülitatud.';

  @override
  String get systemNotificationsOpenSettings => 'Ava seaded';

  @override
  String get systemNotificationsBattery =>
      'Android uinutab rakendused mõni minut pärast ekraani väljalülitumist ja teavitused lõpevad koos nendega. Et neid edasi saada, sea Mialuna akukasutus olekule “Unrestricted”.';

  @override
  String get systemNotificationsBatteryAction => 'Ava aku seaded';

  @override
  String get newFollowersSetting => 'Näita uusi jälgijaid';

  @override
  String get newFollowersSettingExplain =>
      'Uued jälgijad ilmuvad teavitustes ja telefonis. Lülita välja, kui inimesed uputavad sind jälgimistega: meeldimised, kommentaarid ja zaps jäävad nähtavale.';

  @override
  String get systemNotificationMessage => 'saatise sulle privaatsõnumi';

  @override
  String get systemNotificationNewMessage => 'Uus privaatsõnum';

  @override
  String get systemNotificationNew => 'Uus teavitus';

  @override
  String get notificationChannelSocial =>
      'Reaktsioonid, kommentaarid, zaps ja jälgijad';

  @override
  String get notificationChannelMessages => 'Privaatsõnumid';

  @override
  String get zapInvoiceMismatch =>
      'Arve ei vasta valitud summale. Midagi ei makstud.';

  @override
  String get storyYourStory => 'Sinu lugu';

  @override
  String get storyNew => 'Uus lugu';

  @override
  String get storyAddSemantics => 'Lisa oma loole';

  @override
  String storyOwnRailLabel(int count, Object state) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count lugu',
      one: '1 lugu',
    );
    return 'Sinu lugu, $_temp0, $state';
  }

  @override
  String get storyTextSize => 'Teksti suurus';

  @override
  String get storyPickPrompt => 'Vali oma loo jaoks foto või video';

  @override
  String get storyEditPhoto => 'Muuda fotot';

  @override
  String get storyCaption => 'Pealdis';

  @override
  String get storyDiscardTitle => 'Kas hülgad selle loo?';

  @override
  String get storyDiscard => 'Hülga';

  @override
  String get storyShare => 'Jaga';

  @override
  String get storyShared => 'Lugu jagatud';

  @override
  String get deletePost => 'Kustuta';

  @override
  String get deletePostTitle => 'Kas kustutan selle postituse?';

  @override
  String get deleteStoryTitle => 'Kas kustutan selle loo?';

  @override
  String get deletePostBody =>
      'Mialuna palub sinu relays postitus kustutada ja meediaserveritel selle fotod või video kustutada. relay, mis päringut eirab, või keegi, kes koopia juba salvestas, võib selle alles hoida.';

  @override
  String get deletePrivateBody =>
      'Lähedaste sõprade postitust ei saa relays pealt tagasi võtta. Mialuna ütleb sõprade rakendustele, et see eemaldada, ja palub meediaserveril krüptitud failid kustutada. Sõber, kes koopia juba salvestas, võib selle alles hoida.';

  @override
  String get deletingPost => 'Kustutan…';

  @override
  String get postDeleted => 'Kustutatud.';

  @override
  String get postWasDeleted => 'See postitus kustutati.';

  @override
  String get deleteNotAllowed =>
      'Kustutada saab ainult konto, mis selle avaldas.';

  @override
  String deleteFailed(Object reason) {
    return 'Ei saanud kustutada: $reason';
  }

  @override
  String get deleteNoRelay =>
      'Ükski relay ei võtnud kustutamispäringut vastu, seega on see endiselt üleval. Kontrolli ühendust ja proovi uuesti.';

  @override
  String deleteMediaLeft(Object servers) {
    return 'Meediat ei saanud eemaldada: $servers.';
  }

  @override
  String get deleteMediaNotAuthorized =>
      'Sinu allkirjastaja ei lubanud meedia eemaldamist, seega on failid endiselt meediaserveris.';

  @override
  String deleteFriendsMissed(Object count) {
    return '$count sinu lähedast sõpra ei õnnestunud teavitada, seega võib see nende telefonidesse jääda.';
  }

  @override
  String get storyCleanupSetting => 'Kustuta mu lood, kui need aeguvad';

  @override
  String get storyCleanupSettingExplain =>
      '24 tunni pärast palub Mialuna sinu relays ja meediaserveritel sinu lood kustutada, koos fotode ja videotega. Server, mis päringut eirab, või keegi, kes koopia alles hoidis, võib need alles hoida.';

  @override
  String storyCleanupWaiting(Object count) {
    return 'Sinu allkirjastaja peab iga kustutuse kinnitama, seepärast ootab see sinu käsku. Aegunud lugusid ootel: $count.';
  }

  @override
  String get storyCleanupNow => 'Kustuta kohe';

  @override
  String get storyCleanupDone => 'Aegunud lood kustutatud.';

  @override
  String get storyCleanupPartly =>
      'Mõnda ei saanud veel kustutada; Mialuna proovib uuesti.';

  @override
  String get editorPro => 'Pro-redaktor';

  @override
  String get editorModeBasic => 'Põhi';

  @override
  String get editorModePro => 'Pro';

  @override
  String get toolCrop => 'Kärbi';

  @override
  String get toolLight => 'Valgus';

  @override
  String get toolColor => 'Värv';

  @override
  String get toolHsl => 'HSL';

  @override
  String get toolCurves => 'Kõverad';

  @override
  String get toolEffects => 'Efektid';

  @override
  String get straighten => 'Sirgesta';

  @override
  String get exposure => 'Säritus';

  @override
  String get highlights => 'Heledad';

  @override
  String get shadows => 'Varjud';

  @override
  String get whites => 'Valged';

  @override
  String get blacks => 'Mustad';

  @override
  String get temperature => 'Temperatuur';

  @override
  String get tint => 'Toon';

  @override
  String get vibrance => 'Erksus';

  @override
  String get hue => 'Värvitoon';

  @override
  String get luminance => 'Heledus';

  @override
  String get colorRed => 'Punane';

  @override
  String get colorOrange => 'Oranž';

  @override
  String get colorYellow => 'Kollane';

  @override
  String get colorGreen => 'Roheline';

  @override
  String get colorAqua => 'Akvamariin';

  @override
  String get colorBlue => 'Sinine';

  @override
  String get colorPurple => 'Lilla';

  @override
  String get colorMagenta => 'Magenta';

  @override
  String get curveHint =>
      'Lohista punkti, et kõverat kujundada, puuduta lisamiseks, topeltpuuduta eemaldamiseks.';

  @override
  String get sharpen => 'Teravus';

  @override
  String get vignette => 'Vinjett';

  @override
  String get grain => 'Teralisus';

  @override
  String get holdForOriginal =>
      'Hoia fotot all, et võrrelda seda originaaliga.';

  @override
  String get showingOriginal => 'Originaal';

  @override
  String get applyLookToAll => 'Rakenda see välimus kõigile fotodele';

  @override
  String get applyingEdits => 'Fotode töötlemine…';

  @override
  String get choosePhotoToEdit => 'Vali muudetav foto';
}
