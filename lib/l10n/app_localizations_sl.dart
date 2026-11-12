// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Slovenian (`sl`).
class AppLocalizationsSl extends AppLocalizations {
  AppLocalizationsSl([String locale = 'sl']) : super(locale);

  @override
  String get syncUpToDate => 'Posodobljeno';

  @override
  String get syncFailed => 'Sinhronizacija ni uspela';

  @override
  String get relaysUpdatedFromProfile =>
      'Relays posodobljeni iz tvojega profila (NIP-65)';

  @override
  String get relayListPublished => 'Seznam Relay objavljen';

  @override
  String get mediaServersUpdatedFromProfile =>
      'Medijski strežniki posodobljeni iz tvojega profila';

  @override
  String get tabHome => 'Home';

  @override
  String get tabDiscover => 'Odkrij';

  @override
  String get tabCreate => 'Ustvari';

  @override
  String get tabReels => 'Reels';

  @override
  String get tabProfile => 'Profil';

  @override
  String get signInToUploadMedia => 'Prijavi se za nalaganje medijev.';

  @override
  String get noMediaServer =>
      'Ni nastavljenega medijskega strežnika. Dodaj ga v nastavitvah.';

  @override
  String serverNoResponse(Object server) {
    return '$server: ni odgovora';
  }

  @override
  String serverUnreachable(Object server, Object error) {
    return '$server: nedosegljiv ($error)';
  }

  @override
  String uploadRejected(Object reason) {
    return 'Nalaganje zavrnjeno — $reason';
  }

  @override
  String noServerAcceptedFile(Object reasons) {
    return 'Noben strežnik ni sprejel datoteke — $reasons';
  }

  @override
  String get blossomInvalidResponse => 'neveljaven odgovor';

  @override
  String get blossomInvalidFileUrl => 'neveljaven naslov datoteke';

  @override
  String get blossomServerAlteredFile => 'strežnik je spremenil datoteko';

  @override
  String get blossomBadRequest => 'neveljavna zahteva';

  @override
  String get blossomUnauthorized => 'avtorizacija zavrnjena';

  @override
  String get blossomPaymentRequired => 'potrebno je plačilo';

  @override
  String get blossomForbidden => 'ni dovoljeno';

  @override
  String get blossomLengthRequired => 'manjka velikost';

  @override
  String get blossomTooLarge => 'datoteka je prevelika';

  @override
  String get blossomUnsupportedType => 'format ni sprejet';

  @override
  String get blossomTooManyRequests => 'preveč zahtev';

  @override
  String get blossomServerError => 'napaka strežnika';

  @override
  String get cipherInvalidKey => 'Neveljaven ključ';

  @override
  String get cipherTruncated => 'Šifrirana datoteka je okrnjena';

  @override
  String get cipherMismatch =>
      'Datoteka se ne ujema s ključem: spremenjena ali poškodovana';

  @override
  String get sanitizeHeifNeedsAsync =>
      'Format HEIC/AVIF: pretvorba zahteva sanitizeAsync';

  @override
  String get sanitizeWebmUnsupported =>
      'Video WebM/MKV ni podprt: uporabi MP4 ali MOV, da se metapodatki odstranijo pred nalaganjem.';

  @override
  String get sanitizeUnknownFormat =>
      'Nepoznan format datoteke: fotografije JPEG/PNG/WebP/GIF ali videi MP4/MOV.';

  @override
  String sanitizeLeftovers(Object items) {
    return 'Vseh metapodatkov ni bilo mogoče odstraniti ($items): datoteka ni naložena.';
  }

  @override
  String sanitizeProcessingFailed(Object error) {
    return 'Datoteke ni bilo mogoče obdelati: $error';
  }

  @override
  String get sanitizeJpegInvalid => 'Neveljaven JPEG';

  @override
  String get sanitizeJpegTruncated => 'Okrnjen JPEG';

  @override
  String get sanitizeJpegNoSize => 'JPEG brez mer';

  @override
  String get sanitizeJpegUndecodable => 'JPEG ni mogoče dekodirati';

  @override
  String get sanitizePngTruncated => 'Okrnjen PNG';

  @override
  String get sanitizePngInvalid => 'Neveljaven PNG';

  @override
  String get sanitizeGifInvalid => 'Neveljaven GIF';

  @override
  String get sanitizeGifTruncated => 'Okrnjen GIF';

  @override
  String get sanitizeWebpTruncated => 'Okrnjen WebP';

  @override
  String get sanitizeWebpInvalid => 'Neveljaven WebP';

  @override
  String get sanitizeMp4Invalid => 'Neveljaven video MP4/MOV';

  @override
  String get sanitizeConversionFailed => 'Pretvorba ni uspela';

  @override
  String get sanitizeHeifUnsupported =>
      'Tega formata (HEIC/AVIF) na tej napravi ni mogoče pretvoriti. Izberi fotografijo JPEG ali PNG.';

  @override
  String get privateMediaNotEncrypted => 'Medij ni šifriran';

  @override
  String serverReplied(Object status) {
    return 'Strežnik je odgovoril $status';
  }

  @override
  String get fileTooLarge => 'Datoteka je prevelika';

  @override
  String get serverFileNotOriginal => 'Datoteka na strežniku ni izvirnik';

  @override
  String get contentMismatch => 'Vsebina se ne ujema';

  @override
  String get mediaUnreachable => 'Medij ni dosegljiv';

  @override
  String get amberInvalidKey => 'Amber je vrnil neveljaven ključ';

  @override
  String get amberNoKey => 'Amber ni vrnil ključa';

  @override
  String get amberRequestRejected => 'Zahteva zavrnjena v Amber';

  @override
  String get amberAndroidOnly => 'Amber je na voljo samo za Android';

  @override
  String get amberEmptySignature => 'Amber je vrnil prazen podpis';

  @override
  String get amberSignRejected => 'Podpis zavrnjen v Amber';

  @override
  String get amberTimeout => 'Amber ni odgovoril pravočasno';

  @override
  String get amberEmptyResponse => 'Amber je vrnil prazen odgovor';

  @override
  String get bunkerInvalidUrl => 'Neveljaven URL bunker';

  @override
  String get bunkerNoRelay => 'bunker ne navaja nobenega relay';

  @override
  String get bunkerWebAuth =>
      'bunker zahteva spletno avtorizacijo (auth_url ni podprt)';

  @override
  String get bunkerInvalidKey => 'bunker ni vrnil veljavnega ključa';

  @override
  String get signerInvalidResponse =>
      'Podpisnik je vrnil neveljaven podpisan dogodek';

  @override
  String get bunkerTimeout => 'Bunker je potekel';

  @override
  String get nwcInvalidUri => 'Neveljaven NWC URI';

  @override
  String get nwcNoRelay => 'NWC URI ne navaja nobenega relay';

  @override
  String get nwcNoSecret => 'NWC URI ne vsebuje veljavne skrivnosti';

  @override
  String get nwcTimeout => 'Denarnica je potekla';

  @override
  String get signerNoPrivateMessages =>
      'Ta način prijave ne podpira zasebnih sporočil';

  @override
  String get zapNotSupported => 'Ta naslov ne podpira Nostr zaps';

  @override
  String zapAmountOutOfRange(Object min, Object max) {
    return 'Znesek zunaj obsega ($min–$max sats)';
  }

  @override
  String get commentNotSent => 'Komentar ni poslan. Poskusi znova pozneje.';

  @override
  String get comments => 'Komentarji';

  @override
  String get noCommentsYet => 'Še ni komentarjev.';

  @override
  String get signInToComment => 'Prijavi se za komentar.';

  @override
  String get addComment => 'Dodaj komentar…';

  @override
  String get signInToPublish => 'Prijavi se za objavo.';

  @override
  String get addMediaFirst =>
      'Pred objavo dodaj vsaj eno fotografijo ali video.';

  @override
  String get removingMetadata => 'Odstranjujem metapodatke…';

  @override
  String uploadingProgress(Object current, Object total) {
    return 'Nalagam $current od $total…';
  }

  @override
  String get creatingPreview => 'Ustvarjam predogled…';

  @override
  String uploadFailed(Object error) {
    return 'Nalaganje ni uspelo: $error';
  }

  @override
  String get publishing => 'Objavljam…';

  @override
  String noRelayAcceptedPost(Object reason) {
    return 'Noben relay ni sprejel objave$reason. Vsebina ostane v osnutkih.';
  }

  @override
  String get privateNeedsKeySigner =>
      'Ta način prijave ne podpira zasebne vsebine. Uporabi Amber, bunker ali lokalni ključ.';

  @override
  String get closeFriendsListEmptyAddSomeone =>
      'Seznam bližnjih prijateljev je prazen: nekoga dodaj.';

  @override
  String get fileOver100Mb =>
      'Datoteka je večja od 100 MB: to je omejitev za bližnje prijatelje (v celoti se šifrira na tvojem telefonu).';

  @override
  String get encryptingOnPhone => 'Šifriram na tvojem telefonu…';

  @override
  String noServerAcceptedEncrypted(Object details) {
    return 'Noben tvoj medijski strežnik ni sprejel šifrirane datoteke. Ni objavljena nešifrirana. V nastavitvah dodaj strežnik, ki sprejema šifrirane datoteke (na primer cdn.hzrd149.com). $details';
  }

  @override
  String get sendingToFriends => 'Pošiljam prijateljem…';

  @override
  String sendingToFriendsProgress(Object done, Object total) {
    return 'Pošiljam prijateljem $done/$total…';
  }

  @override
  String noFriendReceivedPost(Object reason) {
    return 'Noben prijatelj ni prejel objave$reason. Vsebina ostane v osnutkih.';
  }

  @override
  String sentToCloseFriends(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Poslano $count bližnjim prijateljem 🔒',
      one: 'Poslano 1 bližnjemu prijatelju 🔒',
    );
    return '$_temp0';
  }

  @override
  String sentToFriendsWithMisses(int delivered, Object missed) {
    String _temp0 = intl.Intl.pluralLogic(
      delivered,
      locale: localeName,
      other: 'Poslano $delivered prijateljem.',
      one: 'Poslano 1 prijatelju.',
    );
    return '$_temp0 $missed tega ni prejelo (zasebna sporočila so izklopljena).';
  }

  @override
  String get altText => 'Nadomestno besedilo';

  @override
  String get altTextHint => 'Opiši vsebino za tiste, ki je ne vidijo…';

  @override
  String get cancel => 'Prekliči';

  @override
  String get save => 'Shrani';

  @override
  String get momentPublished => 'Trenutek objavljen ✨';

  @override
  String get newMoment => 'Nov trenutek';

  @override
  String get publish => 'Objavi';

  @override
  String get guestMode => 'Način gosta';

  @override
  String get signInToPostMoments => 'Prijavi se za objavo svojih trenutkov.';

  @override
  String get signIn => 'Prijava';

  @override
  String get kindPhoto => 'Foto';

  @override
  String get kindVideo => 'Video';

  @override
  String get kindReel => 'Reel';

  @override
  String get kindStory => 'Zgodba';

  @override
  String get storyExpiryNote =>
      'Zgodbe potečejo po 24 urah na relays, ki upoštevajo NIP-40, drugi pa jih lahko še vedno shranijo ali arhivirajo.';

  @override
  String get fromGallery => 'Iz galerije';

  @override
  String get galleryLongPressVideo => 'Galerija (dolg pritisk za video)';

  @override
  String get addVideo => 'Dodaj video';

  @override
  String get camera => 'Kamera';

  @override
  String get exifRemovedNote =>
      'Lokacijski metapodatki (EXIF) se odstranijo samodejno.';

  @override
  String get writeCaption => 'Napiši napis…';

  @override
  String get privatePostNote =>
      'Zasebna objava: brez javnih hashtagov, prek iskanja je ni mogoče najti.';

  @override
  String willPublishAs(Object caption) {
    return 'Objavljeno bo kot: \"$caption\"';
  }

  @override
  String get tapThumbnailForAlt =>
      'Tapni sličico, da dodaš nadomestno besedilo.';

  @override
  String get sensitiveContent => 'Občutljiva vsebina';

  @override
  String get sensitiveContentNote => 'Objava bo skrita za opozorilom (NIP-36).';

  @override
  String get uploadingMedia => 'Nalagam medije…';

  @override
  String get audiencePublic => 'Javno';

  @override
  String get closeFriends => 'Bližnji prijatelji';

  @override
  String get signerCannotPublishCloseFriends =>
      'S tem načinom prijave ne moreš objavljati za bližnje prijatelje: uporabi Amber, bunker ali lokalni ključ.';

  @override
  String get closeFriendsEmptyPrompt =>
      'Tvoj seznam je prazen: dodaj ljudi, ki lahko vidijo to objavo.';

  @override
  String onlyYourCloseFriendsSee(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'To vidi samo tvojih $count bližnjih prijateljev. Fotografije in videi se pred nalaganjem šifrirajo na tvojem telefonu.',
      one: 'To vidi samo tvoj 1 bližnji prijatelj. Fotografije in videi se pred nalaganjem šifrirajo na tvojem telefonu.',
    );
    return '$_temp0';
  }

  @override
  String get addFriends => 'Dodaj prijatelje';

  @override
  String get manageList => 'Upravljaj seznam';

  @override
  String get edit => 'Uredi';

  @override
  String get reset => 'Ponastavi';

  @override
  String get apply => 'Uporabi';

  @override
  String get cropFree => 'Prosto';

  @override
  String get cropOriginal => 'Izvirnik';

  @override
  String get rotate => 'Zavrti';

  @override
  String get flip => 'Obrni';

  @override
  String get brightness => 'Svetlost';

  @override
  String get contrast => 'Kontrast';

  @override
  String get saturation => 'Nasičenost';

  @override
  String postsByAuthor(Object author) {
    return 'Objave od $author…';
  }

  @override
  String get searchHint => 'Išči ljudi, hashtage ali besede…';

  @override
  String get clear => 'Počisti';

  @override
  String get recent => 'Nedavno';

  @override
  String get searchDependsOnRelays =>
      'Iskanje je odvisno od nastavljenih relays: rezultati so lahko delni.';

  @override
  String get recentPostsEverywhere =>
      'Nedavne objave iz celotnega omrežja, tudi od ljudi, ki jim ne slediš.';

  @override
  String get noResultsOnRelays => 'Ni rezultatov na nastavljenih relays.';

  @override
  String get noRecentPostsFromFollowed =>
      'Ni nedavnih objav od ljudi, ki jim slediš.';

  @override
  String get noMomentsFound => 'Na relays ni trenutkov. Preveri povezavo.';

  @override
  String get loadFailed => 'Nalaganje ni uspelo';

  @override
  String get notifications => 'Obvestila';

  @override
  String get messages => 'Sporočila';

  @override
  String get homeEmptyFollowsNobody =>
      'Tu so objave ljudi, ki jim slediš.\nŠe nikomur ne slediš: odkrij zanimive ljudi in profile.';

  @override
  String get discoverPeople => 'Odkrij ljudi';

  @override
  String get homeEmpty =>
      'Še ni trenutkov.\nPovleci navzdol za osvežitev ali objavi svoj prvi posnetek.';

  @override
  String get retry => 'Poskusi znova';

  @override
  String get seenEverything => 'Za zdaj je vse ogledano ✨';

  @override
  String get discoverMoreProfiles => 'Odkrij več profilov';

  @override
  String get feedFollowing => 'Slediš';

  @override
  String get signInToSeeFollowed => 'Prijavi se za objave ljudi, ki jim slediš';

  @override
  String get videoPreview => 'Predogled videa';

  @override
  String get cannotOpenPrivateVideo => 'Zasebnega videa ni mogoče odpreti';

  @override
  String get cannotPlayVideo => 'Videa ni mogoče predvajati';

  @override
  String get pauseVideo => 'Zaustavi video';

  @override
  String get playVideo => 'Predvajaj video';

  @override
  String errorTapToRetry(Object error) {
    return '$error — tapni za ponovitev';
  }

  @override
  String get soundOn => 'Vklopi zvok';

  @override
  String get soundOff => 'Izklopi zvok';

  @override
  String get postImage => 'Slika objave';

  @override
  String get imageUnavailable => 'Slika ni na voljo';

  @override
  String errorTapToRetryNewline(Object message) {
    return '$message\nTapni za ponovitev';
  }

  @override
  String get cannotOpenPrivateContent => 'Te zasebne vsebine ni mogoče odpreti';

  @override
  String get privateImage => 'Zasebna slika';

  @override
  String get invalidImage => 'Neveljavna slika';

  @override
  String get more => 'Več';

  @override
  String get removeFromSaved => 'Odstrani iz shranjenih';

  @override
  String get copyLink => 'Kopiraj povezavo';

  @override
  String get muteAuthor => 'Utišaj avtorja';

  @override
  String get blockAuthor => 'Blokiraj avtorja';

  @override
  String get report => 'Prijavi';

  @override
  String get like => 'Všeč';

  @override
  String get sendInMessage => 'Pošlji v sporočilu';

  @override
  String get zapOptional => 'Zap (neobvezno)';

  @override
  String get closeFriendsOnlyNote =>
      'Vidno samo bližnjim prijateljem. Všečki in odgovori gredo samo avtorju.';

  @override
  String get likeFailed => 'Všečka ni bilo mogoče poslati';

  @override
  String get nostrLinkCopied => 'Povezava Nostr kopirana v odložišče';

  @override
  String get authorMuted => 'Avtor utišan';

  @override
  String get authorBlocked => 'Avtor blokiran';

  @override
  String get reportSent => 'Prijava poslana (NIP-56)';

  @override
  String get signInToReport => 'Prijavi se za oddajo prijave';

  @override
  String minutesAgo(Object minutes) {
    return 'pred $minutes min';
  }

  @override
  String get show => 'Prikaži';

  @override
  String get chatEmptyHint =>
      'Napiši prvo sporočilo.\nŠifrirano je: vidita ga samo vidva.';

  @override
  String get messageHint => 'Sporočilo…';

  @override
  String get send => 'Pošlji';

  @override
  String get notSentSuffix => ' ni poslano';

  @override
  String get contentUnavailable =>
      'Vsebina ni na voljo (potekla ali je ni na relays)';

  @override
  String get signInToSendPrivateMessages =>
      'Prijavi se za pošiljanje zasebnih sporočil.';

  @override
  String get cannotMessageYourself => 'Sebi ne moreš pisati.';

  @override
  String get recipientNoPrivateMessages =>
      'Ta oseba še ni vklopila zasebnih sporočil.';

  @override
  String noRecipientRelayAccepted(Object reason) {
    return 'Noben prejemnikov relay ni sprejel sporočila$reason.';
  }

  @override
  String sendFailed(Object error) {
    return 'Pošiljanje ni uspelo: $error';
  }

  @override
  String get signInToReadMessages =>
      'Prijavi se za branje in pošiljanje zasebnih sporočil.';

  @override
  String get signerNoPrivateMessagesLong =>
      'Zasebnih sporočil s tem načinom prijave ni mogoče uporabljati. Prijavi se z Amber, bunker ali lokalnim ključem.';

  @override
  String get inboxEmpty =>
      'Ni pogovorov.\nTapni svinčnik, da komu napišeš, ali posreduj trenutek z ikono ✈ pod vsako objavo.';

  @override
  String get newMessage => 'Novo sporočilo';

  @override
  String get privateMessagesEnabled => 'Zasebna sporočila vklopljena';

  @override
  String get enableMessagesFailed =>
      'Ni jih bilo mogoče vklopiti. Poskusi znova.';

  @override
  String get enablePrivateMessages => 'Vklopi zasebna sporočila';

  @override
  String enablePrivateMessagesExplain(Object count) {
    return 'Za prejemanje sporočil moraš povedati, na katere relays naj prispejo. Objavi se majhen seznam (NIP-17) s $count privzetimi relays: pozneje ga lahko spremeniš. Sporočila ostanejo šifrirana: relays ne vidijo, kdo piše, niti besedila.';
  }

  @override
  String get turnOn => 'Vklopi';

  @override
  String get searchByNameOrUsername => 'Išči po imenu ali uporabniškem imenu';

  @override
  String get searching => 'Iskanje…';

  @override
  String get noOneWithNameHint =>
      'Nikogar s tem imenom. Poskusi manj črk ali naslov, kot je name@domain.com.';

  @override
  String get sent => 'Poslano';

  @override
  String sentToPeople(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Poslano $count osebam',
      one: 'Poslano 1 osebi',
    );
    return '$_temp0';
  }

  @override
  String sentToPeopleWithFailure(int count, Object failure) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Poslano $count osebam. $failure',
      one: 'Poslano 1 osebi. $failure',
    );
    return '$_temp0';
  }

  @override
  String get signerNoPrivateMessagesShort =>
      'Zasebnih sporočil s tem načinom prijave ne moreš uporabljati.';

  @override
  String get followToStartOrSearch =>
      'Sledi nekomu za začetek ali išči po imenu.';

  @override
  String get addMessage => 'Dodaj sporočilo…';

  @override
  String sendWithCount(Object count) {
    return 'Pošlji ($count)';
  }

  @override
  String get linkCopied => 'Povezava kopirana v odložišče';

  @override
  String get noNotifications => 'Trenutno ni obvestil.';

  @override
  String get notificationsDependOnRelays =>
      'Obvestila so odvisna od relays: lahko so nepopolna.';

  @override
  String get reactedToYourMoment => 'se je odzval na tvoj trenutek';

  @override
  String commentedText(Object text) {
    return 'je komentiral: $text';
  }

  @override
  String sentYouSats(Object sats, Object comment) {
    return 'poslano ti je $sats sats$comment';
  }

  @override
  String get sentYouZap => 'poslan ti je zap';

  @override
  String get startedFollowingYou => 'ti je začel slediti';

  @override
  String get amberNotFound => 'Amber ni najden';

  @override
  String get amberExplain =>
      'Amber je podpisnik Nostr, ki tvoj zasebni ključ hrani zunaj Mialuna. Namesti ga in poskusi znova.';

  @override
  String get downloadFromFdroid => 'Prenesi iz F-Droid';

  @override
  String get continueWithAmber => 'Nadaljuj z Amber';

  @override
  String get amberRecommended =>
      'Priporočeno: tvoj zasebni ključ ostane varen v Amber.';

  @override
  String get amberNotDetected =>
      'Amber ni zaznan: namesti ga za priporočeno prijavo.';

  @override
  String get exploreWithoutAccount => 'Razišči brez računa';

  @override
  String get remoteBunker => 'Oddaljeni bunker (NIP-46)';

  @override
  String get invalidBunkerUrlDot => 'Neveljaven URL bunker.';

  @override
  String get connectBunker => 'Poveži bunker';

  @override
  String get advancedNsec => 'Napredna prijava (nsec)';

  @override
  String get nsecWarning =>
      'Opozorilo: lepljenje zasebnega ključa je tvegano. Nikoli ga ne deli z nikomer. V sistemu Android raje uporabi Amber.';

  @override
  String get invalidNsec => 'Neveljaven ključ nsec.';

  @override
  String get signInWithNsec => 'Prijava z nsec';

  @override
  String get tagline => 'Tvoji trenutki, pod isto luno.';

  @override
  String get skip => 'Preskoči';

  @override
  String get permissionsAndWallet => 'Dovoljenja in denarnica';

  @override
  String get permissionsExplain =>
      'Dovolijo ti samo objavljanje in prejemanje obvestil. Kadarkoli jih lahko spremeniš v sistemskih nastavitvah.';

  @override
  String get photosAndVideos => 'Fotografije in videi';

  @override
  String get toUploadYourMoments => 'Za nalaganje tvojih trenutkov';

  @override
  String get allow => 'Dovoli';

  @override
  String get reactionsCommentsZaps => 'Odzivi, komentarji in zaps';

  @override
  String get lightningWalletOptional => 'Denarnica Lightning (neobvezno)';

  @override
  String get nwcExplain =>
      'Poveži denarnico Nostr Wallet Connect, da pošiljaš zaps, ne da zapustiš aplikacijo.';

  @override
  String get walletConnected => 'Denarnica povezana';

  @override
  String get disconnect => 'Odklopi';

  @override
  String get connectWallet => 'Poveži denarnico';

  @override
  String get getStarted => 'Začni';

  @override
  String get welcome1 =>
      'Mialuna je vizualno družabno omrežje: fotografije, videi, Reels in zgodbe — nikoli samo besedilne objave.';

  @override
  String get welcome2 =>
      'Deluje na Nostr, odprtem protokolu: tvoja identiteta je ključ, ki ga imaš ti, ne račun, ki ti ga lahko vzame podjetje. Brez oglasov, brez sledilnikov, brez osrednjih strežnikov.';

  @override
  String get welcome3 =>
      'Deli svojo svetlobo z ljudmi povsod, iz katere koli aplikacije, ki govori isti odprti jezik.';

  @override
  String onboardingWot(int min) {
    return 'Splet zaupanja je vedno vklopljen. Ko prvič odpreš Mialuna, prebere, komu slediš, in iz tega omrežja zgradi vir Odkrij: ti, ljudje, ki jim slediš, in vsak, ki mu sledi vsaj $min od njih. Ob naslednjih odprtjih je ta vir že pripravljen.';
  }

  @override
  String get publicAndPrivate => 'Javno in zasebno';

  @override
  String get publicAndPrivateIntro =>
      'Mialuna temelji na Nostr, odprtem omrežju. Kar objaviš, je javno: objave, fotografije in videi ostanejo vidni vsakomur s povezavo, tudi zunaj Mialuna.';

  @override
  String get closeFriendsExplain1 =>
      'Samo ljudje na tem seznamu prejmejo tvoje objave, zgodbe in videe \"Bližnji prijatelji\". Seznam je znotraj objave; ni ga treba izbirati vsakič.';

  @override
  String get closeFriendsExplain2 =>
      'Fotografije in videi se pred nalaganjem šifrirajo na tvojem telefonu. Datotečni strežniki (Blossom) sami ne šifrirajo ničesar: zato to naredi Mialuna, strežnik pa vidi samo neberljive podatke. Kdor najde naslov datoteke, je ne more odpreti.';

  @override
  String get closeFriendsExplain3 =>
      'To ni absolutno jamstvo: kdor prejme objavo, lahko naredi posnetek zaslona, odstranitev prijatelja pa velja samo za prihodnje objave.';

  @override
  String get closeFriendsExplain4 =>
      'Vsak prijatelj mora uporabljati Mialuna z vklopljenimi zasebnimi sporočili. Drugi odjemalci Nostr teh objav ne pokažejo.';

  @override
  String get closeFriendsExplain5 =>
      'Javne objave ostanejo javne: njihove datoteke vidi vsak s povezavo.';

  @override
  String get closeFriendsExplain6 =>
      'Če noben tvoj strežnik ne sprejme šifriranih datotek, objava ni objavljena: nikoli nešifrirano.';

  @override
  String get addToCloseFriends => 'Dodaj med bližnje prijatelje';

  @override
  String maxFriendsReached(Object max, Object added) {
    return 'Omejitev $max prijateljev: dodanih $added.';
  }

  @override
  String get add => 'Dodaj';

  @override
  String get signInToCreateList => 'Prijavi se za ustvarjanje svojega seznama.';

  @override
  String get signerNoCloseFriends =>
      'Bližnjih prijateljev s tem načinom prijave ni mogoče uporabljati. Prijavi se z Amber, bunker ali lokalnim ključem.';

  @override
  String peopleOfMax(Object count, Object max) {
    return '$count / $max oseb';
  }

  @override
  String get noOneYet => 'Še nikogar.';

  @override
  String get addPeople => 'Dodaj ljudi';

  @override
  String get friendNoPrivateMessagesWarning =>
      'Niso vklopili zasebnih sporočil: tvojih objav ne bodo prejeli';

  @override
  String get removeFromList => 'Odstrani s seznama';

  @override
  String get noOneWithThisName => 'Nikogar s tem imenom.';

  @override
  String get signInToSendPrivateContent =>
      'Prijavi se za pošiljanje zasebne vsebine.';

  @override
  String get reasonNoPrivateMessages => 'ni vklopil zasebnih sporočil';

  @override
  String get reasonNoRelayAnswered => 'noben relay ni odgovoril';

  @override
  String get profileUpdated => 'Profil posodobljen';

  @override
  String get noRelayAcceptedRetry =>
      'Noben relay ni sprejel. Poskusi znova pozneje.';

  @override
  String get editProfile => 'Uredi profil';

  @override
  String get fieldName => 'Ime';

  @override
  String get fieldBio => 'Bio';

  @override
  String get fieldAvatarUrl => 'URL avatarja';

  @override
  String get fieldNip05 => 'NIP-05 (npr. you@example.com)';

  @override
  String get browsingAsGuest => 'Brskaš kot gost';

  @override
  String get signInToInteract =>
      'Prijavi se za objavljanje, sledenje in sodelovanje.';

  @override
  String get settings => 'Nastavitve';

  @override
  String get signOut => 'Odjava';

  @override
  String get npubCopied => 'npub kopiran';

  @override
  String get copyNpub => 'Kopiraj npub';

  @override
  String get mute => 'Utišaj';

  @override
  String get block => 'Blokiraj';

  @override
  String get posts => 'Objave';

  @override
  String get saved => 'Shranjeno';

  @override
  String get nothingPublishedYet => 'Še ni ničesar objavljenega.';

  @override
  String get noPostsOnRelays => 'Na relays ni objav.';

  @override
  String get noReelsPublished => 'Ni objavljenih reels.';

  @override
  String get noReelsOnRelays => 'Na relays ni reels.';

  @override
  String get noSavedPosts => 'Ni shranjenih objav.';

  @override
  String get followingButton => 'Slediš';

  @override
  String get follow => 'Sledi';

  @override
  String get messageButton => 'Sporočilo';

  @override
  String get loginLocalKey => 'Lokalni ključ';

  @override
  String get loginGuest => 'Gost';

  @override
  String get followUpdateFailed =>
      'Tvojih sledenj trenutno ni bilo mogoče posodobiti. Poskusi znova.';

  @override
  String get noReelsComeBack => 'Na relays ni reels.\nKmalu se vrni!';

  @override
  String get followUpdateFailedShort =>
      'Tvojih sledenj trenutno ni bilo mogoče posodobiti';

  @override
  String get needOneReadRelay => 'Potreben je vsaj en relay za branje.';

  @override
  String get listSavedLocally =>
      'Seznam je shranjen na tej napravi, ni objavljen.';

  @override
  String get noRelayAcceptedList =>
      'Noben relay ni sprejel seznama: poskus bo pozneje.';

  @override
  String relayListPublishedTo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Seznam Relay objavljen na $count relays',
      one: 'Seznam Relay objavljen na 1 relay',
    );
    return '$_temp0';
  }

  @override
  String get mediaServersUpdated => 'Medijski strežniki posodobljeni';

  @override
  String get appearance => 'Videz';

  @override
  String get publishingSettings => 'Objavljanje';

  @override
  String get addMialunaHashtag => 'Dodaj #mialuna';

  @override
  String get addMialunaHashtagNote =>
      'Uradni hashtag dodaj javnim objavam in zgodbam. To lahko kadarkoli izklopiš.';

  @override
  String get themeLight => 'Svetla';

  @override
  String get themeDark => 'Temna';

  @override
  String get themeSystem => 'Sistemska';

  @override
  String get relays => 'Relays';

  @override
  String get relaysExplainSignedOut =>
      'Relays shranjujejo in razpošiljajo vsebino. Prijavi se, da samodejno uporabiš svoj seznam (NIP-65).';

  @override
  String get relaysExplainSynced =>
      'Seznam je sinhroniziran s tvojim profilom Nostr (NIP-65): vsaka sprememba se objavi in velja za vse tvoje aplikacije.';

  @override
  String get syncing => 'Sinhronizacija…';

  @override
  String get waitingFirstSync => 'Čakam na prvo sinhronizacijo';

  @override
  String get syncNow => 'Sinhroniziraj zdaj';

  @override
  String get addRelay => 'Dodaj relay';

  @override
  String get restoreDefaultRelays => 'Obnovi privzete relays';

  @override
  String get createYourList => 'Ustvari svoj seznam';

  @override
  String peopleCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count oseb',
      one: '1 oseba',
    );
    return '$_temp0';
  }

  @override
  String get closeFriendsSettingsNote =>
      'Objave, zgodbe in videi, vidni samo njim, s šifriranimi fotografijami in videi.';

  @override
  String get mediaServersBlossom => 'Medijski strežniki (Blossom)';

  @override
  String get mediaServersExplain =>
      'Fotografije in videi se nalagajo samo na te strežnike, v prikazanem vrstnem redu: zmaga prvi, ki jih sprejme. EXIF in lokacija se pred nalaganjem odstranita.';

  @override
  String get primary => 'Glavni';

  @override
  String get makePrimary => 'Nastavi za glavni';

  @override
  String get remove => 'Odstrani';

  @override
  String get addServer => 'Dodaj strežnik';

  @override
  String get moderation => 'Moderacija';

  @override
  String get moderationExplain =>
      'Utišani avtorji in skriti hashtagi se sinhronizirajo prek NIP-51. Blokirani avtorji ostanejo samo na tej napravi.';

  @override
  String get mutedAuthors => 'Utišani avtorji';

  @override
  String get noMutedAuthors => 'Ni utišanih avtorjev';

  @override
  String get blockedAuthors => 'Blokirani avtorji';

  @override
  String get noBlockedAuthors => 'Ni blokiranih avtorjev';

  @override
  String get hiddenHashtags => 'Skriti hashtagi';

  @override
  String get noHiddenHashtags => 'Ni skritih hashtagov';

  @override
  String get hashtagToHide => '#hashtag za skriti';

  @override
  String get storage => 'Shramba';

  @override
  String get clearCache => 'Počisti predpomnilnik dogodkov in osnutke';

  @override
  String get cacheCleared => 'Predpomnilnik počiščen';

  @override
  String get reviewIntro => 'Ponovno poglej uvod';

  @override
  String get reviewIntroSubtitle =>
      'Kaj je javno, kaj zasebno in meje bližnjih prijateljev.';

  @override
  String noLightningWalletCopied(Object address) {
    return 'Denarnica Lightning ni najdena: naslov kopiran ($address)';
  }

  @override
  String get about => 'O aplikaciji';

  @override
  String aboutText(Object version) {
    return 'Mialuna $version — Tvoji trenutki, pod isto luno.\nOdprta koda (MIT). github.com/Lwb89dev/mialuna';
  }

  @override
  String get invalidRelayAddress => 'Neveljaven naslov: uporabi wss://…';

  @override
  String get invalidServerAddress => 'Neveljaven naslov: uporabi https://…';

  @override
  String get relayRead => 'Branje';

  @override
  String get relayWrite => 'Pisanje';

  @override
  String get support => 'Podpora';

  @override
  String get supportText =>
      'Mialuna je brezplačna, brez oglasov in te ne sledi. Če ti je všeč, lahko pošlješ nekaj sats prek omrežja Lightning.';

  @override
  String get donateWithLightning => 'Doniraj z Lightning';

  @override
  String get authorNoZaps => 'Ta avtor ne sprejema zaps';

  @override
  String get sendZap => 'Pošlji zap ⚡';

  @override
  String get amountInSats => 'Znesek v sats';

  @override
  String minMaxSats(Object min, Object max) {
    return 'min $min – max $max';
  }

  @override
  String get zap => 'Zap';

  @override
  String get signInToZap => 'Prijavi se za pošiljanje zaps';

  @override
  String zapSent(Object sats) {
    return 'Zap $sats sats poslan ⚡';
  }

  @override
  String nwcPaymentFailed(Object error) {
    return 'Plačilo NWC ni uspelo: $error';
  }

  @override
  String get noLightningWallet => 'Denarnica Lightning ni najdena';

  @override
  String storiesRailLabel(Object state) {
    return 'Zgodbe, $state';
  }

  @override
  String get close => 'Zapri';

  @override
  String hoursAgo(int hours) {
    return 'pred $hours h';
  }

  @override
  String daysAgo(int days) {
    return 'pred $days d';
  }

  @override
  String get now => 'zdaj';

  @override
  String get youPrefix => 'Ti: ';

  @override
  String get storiesStateUnseen => 'novo';

  @override
  String get storiesStateSeen => 'videno';

  @override
  String weekdayShort(String day) {
    String _temp0 = intl.Intl.selectLogic(day, {
      'mon': 'pon',
      'tue': 'tor',
      'wed': 'sre',
      'thu': 'čet',
      'fri': 'pet',
      'sat': 'sob',
      'sun': 'ned',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get sharedAMoment => 'Delil trenutek';

  @override
  String get blossomOtherError => 'napaka';

  @override
  String get languageTitle => 'Jezik';

  @override
  String get languageSystem => 'Sistemski';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageItalian => 'Italiano';

  @override
  String get cannotEditPhoto => 'Te fotografije tu ni mogoče urediti.';

  @override
  String notificationsNew(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count novih obvestil',
      one: '1 novo obvestilo',
    );
    return '$_temp0';
  }

  @override
  String messagesUnread(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count neprebranih sporočil',
      one: '1 neprebrano sporočilo',
    );
    return '$_temp0';
  }

  @override
  String get done => 'Končano';

  @override
  String get storyAddText => 'Dodaj besedilo';

  @override
  String get storyEditText => 'Uredi besedilo';

  @override
  String get storyTextHint => 'Napiši nekaj… #hashtags so klikljivi';

  @override
  String get storyTextsHelp =>
      'Tapni sliko za pisanje. Povleci za premik, ščipni za velikost in zasuk, tapni besedilo za urejanje.';

  @override
  String storyTextsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count besedil',
      one: '1 besedilo',
      zero: 'Brez besedila',
    );
    return '$_temp0';
  }

  @override
  String get storyFontClassic => 'Klasična';

  @override
  String get storyFontBold => 'Krepka';

  @override
  String get storyFontSerif => 'Serif';

  @override
  String get storyFontMono => 'Mono';

  @override
  String get storyFontItalic => 'Ležeča';

  @override
  String get storyTextBackground => 'Ozadje besedila';

  @override
  String get storyTextColor => 'Barva besedila';

  @override
  String storyTextLimit(int max) {
    return 'Dodaš lahko največ $max besedil.';
  }

  @override
  String get wotTitle => 'Splet zaupanja';

  @override
  String get wotEnable => 'Splet zaupanja je vedno vklopljen';

  @override
  String wotExplain(int min) {
    return 'Vedno vklopljen. Odkrij prikazuje samo to omrežje: ti, ljudje, ki jim slediš, in vsak, ki mu sledi vsaj $min od njih. Isto omrežje skrije komentarje, obvestila, zasebne objave in sporočila vseh drugih. Izračuna se na tem telefonu iz javnih seznamov sledenja, ko prvič odpreš aplikacijo; poznejša odprtja ga znova uporabijo. Nič se ne pošlje na noben strežnik.';
  }

  @override
  String get wotRefresh => 'Osveži omrežje zdaj';

  @override
  String get wotStatusIdle =>
      'Še ni zgrajen. Zgradi se, ko prvič odpreš aplikacijo.';

  @override
  String get wotBuildingTitle => 'Gradim tvoj vir Odkrij';

  @override
  String get wotBuildingBody =>
      'Berem, komu sledijo tudi ljudje, ki jim slediš, in pripravljam Odkrij.';

  @override
  String get wotDiscoverHint =>
      'Samo tvoj splet zaupanja: ljudje, ki jim slediš, in ljudje, ki jim sledi dovolj njih.';

  @override
  String get wotDiscoverSignIn =>
      'Odkrij prikazuje tvoj splet zaupanja. Prijavi se in Mialuna ob prvem odprtju prebere, komu slediš, ter zgradi ta vir. Poznejša odprtja ga znova uporabijo.';

  @override
  String get wotDiscoverEmpty => 'Iz tvojega spleta zaupanja še ni objav.';

  @override
  String wotStatusDiscovering(int done, int total) {
    return 'Preverjam, komu sledijo tvoji sledeni… $done od $total';
  }

  @override
  String wotStatusComplete(int direct, int indirect, Object when) {
    return 'Tvoje omrežje: $direct ljudi, ki jim slediš, plus $indirect, ki jim sledi dovolj njih. Posodobljeno $when.';
  }

  @override
  String wotStatusFailed(Object reason) {
    return 'Tvojega omrežja ni bilo mogoče izračunati: $reason';
  }

  @override
  String get wotNoFollows => 'še nikomur ne slediš';

  @override
  String get messageRequests => 'Prošnje za sporočila';

  @override
  String messageRequestsSubtitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pogovorov zunaj tvojega spleta zaupanja',
      one: '1 pogovor zunaj tvojega spleta zaupanja',
    );
    return '$_temp0';
  }

  @override
  String get messageRequestsHint =>
      'Od ljudi zunaj tvojega spleta zaupanja. Ne štejejo kot neprebrani. Odgovori, da pogovor premakneš v nabiralnik.';

  @override
  String get storyViewsSetting =>
      'Naj ljudje vidijo, da sem si ogledal njihove zgodbe';

  @override
  String get storyViewsSettingExplain =>
      'Ko gledaš zgodbo, se avtorju pošlje potrdilo, šifrirano tako, da ga lahko prebere samo on. Navede tvoje ime ob njegovem; relays ne vidijo ničesar. Če ga ni mogoče dostaviti, se shrani in poskusi znova pozneje. Izklopi, če želiš gledati, ne da bi komu povedal: še neposlana potrdila se zavržejo (že dostavljenega ni mogoče vzeti nazaj).';

  @override
  String storySeenBy(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Videlo $count oseb',
      one: 'Videla 1 oseba',
      zero: 'Še ni ogledov',
    );
    return '$_temp0';
  }

  @override
  String get storyViewsEmpty =>
      'Te zgodbe še ni gledal nihče ali pa njihova potrdila še niso prispela do tebe.';

  @override
  String get storyViewsHint =>
      'Potrdilo pošljejo samo tisti, ki to dovolijo, zato je lahko pravo število višje.';

  @override
  String get systemNotifications => 'Sistemska obvestila';

  @override
  String get systemNotificationsExplain =>
      'Prikaži obvestilo na telefonu, ko prispe kaj novega, medtem ko je Mialuna v ozadju. Zasebna sporočila nikoli ne pokažejo besedila, niti na zaklenjenem zaslonu. Android zaustavi aplikacije, ki so dolgo v ozadju, zato obvestila prispejo, dokler Mialuna še teče.';

  @override
  String get systemNotificationsBlocked =>
      'Obvestila za Mialuna so v nastavitvah telefona izklopljena.';

  @override
  String get systemNotificationsOpenSettings => 'Odpri nastavitve';

  @override
  String get systemNotificationsBattery =>
      'Android uspava aplikacije nekaj minut po izklopu zaslona in obvestila se ustavijo z njimi. Če jih želiš še naprej prejemati, nastavi porabo baterije za Mialuna na “Unrestricted”.';

  @override
  String get systemNotificationsBatteryAction => 'Odpri nastavitve baterije';

  @override
  String get newFollowersSetting => 'Prikaži nove sledilce';

  @override
  String get newFollowersSettingExplain =>
      'Novi sledilci se pokažejo v obvestilih in na telefonu. Izklopi, če te ljudje zasipajo s sledenji: všečki, komentarji in zaps ostanejo vidni.';

  @override
  String get systemNotificationMessage => 'ti je poslal zasebno sporočilo';

  @override
  String get systemNotificationNewMessage => 'Novo zasebno sporočilo';

  @override
  String get systemNotificationNew => 'Novo obvestilo';

  @override
  String get notificationChannelSocial =>
      'Odzivi, komentarji, zaps in sledilci';

  @override
  String get notificationChannelMessages => 'Zasebna sporočila';

  @override
  String get zapInvoiceMismatch =>
      'Račun se ne ujema z izbranim zneskom. Nič ni bilo plačano.';

  @override
  String get storyYourStory => 'Tvoja zgodba';

  @override
  String get storyNew => 'Nova zgodba';

  @override
  String get storyAddSemantics => 'Dodaj v svojo zgodbo';

  @override
  String storyOwnRailLabel(int count, Object state) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count zgodb',
      one: '1 zgodba',
    );
    return 'Tvoja zgodba, $_temp0, $state';
  }

  @override
  String get storyTextSize => 'Velikost besedila';

  @override
  String get storyPickPrompt => 'Izberi fotografijo ali video za svojo zgodbo';

  @override
  String get storyEditPhoto => 'Uredi fotografijo';

  @override
  String get storyCaption => 'Napis';

  @override
  String get storyDiscardTitle => 'Zavrzi to zgodbo?';

  @override
  String get storyDiscard => 'Zavrzi';

  @override
  String get storyShare => 'Deli';

  @override
  String get storyShared => 'Zgodba deljena';

  @override
  String get deletePost => 'Izbriši';

  @override
  String get deletePostTitle => 'Izbrišem to objavo?';

  @override
  String get deleteStoryTitle => 'Izbrišem to zgodbo?';

  @override
  String get deletePostBody =>
      'Mialuna bo tvoje relays prosila, naj objavo izbrišejo, medijske strežnike pa, naj izbrišejo fotografije ali video. relay, ki zahtevo prezre, ali nekdo, ki je kopijo že shranil, jo lahko še vedno ima.';

  @override
  String get deletePrivateBody =>
      'Objave za bližnje prijatelje ni mogoče umakniti z relays. Mialuna bo aplikacijam prijateljev rekla, naj jo odstranijo, in medijski strežnik prosila, naj izbriše šifrirane datoteke. Prijatelj, ki je kopijo že shranil, jo lahko še vedno ima.';

  @override
  String get deletingPost => 'Brišem…';

  @override
  String get postDeleted => 'Izbrisano.';

  @override
  String get postWasDeleted => 'Ta objava je bila izbrisana.';

  @override
  String get deleteNotAllowed =>
      'Izbrisati jo lahko samo račun, ki jo je objavil.';

  @override
  String deleteFailed(Object reason) {
    return 'Ni bilo mogoče izbrisati: $reason';
  }

  @override
  String get deleteNoRelay =>
      'Noben relay ni sprejel zahteve za izbris, zato je še vedno na spletu. Preveri povezavo in poskusi znova.';

  @override
  String deleteMediaLeft(Object servers) {
    return 'Medija ni bilo mogoče odstraniti s $servers.';
  }

  @override
  String get deleteMediaNotAuthorized =>
      'Tvoj podpisnik ni odobril odstranitve medija, zato so datoteke še vedno na medijskem strežniku.';

  @override
  String deleteFriendsMissed(Object count) {
    return '$count tvojih bližnjih prijateljev ni bilo mogoče obvestiti, zato lahko ostane na njihovih telefonih.';
  }

  @override
  String get storyCleanupSetting => 'Izbriši moje zgodbe, ko potečejo';

  @override
  String get storyCleanupSettingExplain =>
      'Po 24 urah Mialuna tvoje relays in medijske strežnike prosi, naj izbrišejo tvoje zgodbe, skupaj s fotografijami in videi. Strežnik, ki zahtevo prezre, ali nekdo, ki je obdržal kopijo, jih lahko še vedno ima.';

  @override
  String storyCleanupWaiting(Object count) {
    return 'Tvoj podpisnik mora odobriti vsako čiščenje, zato počaka, da to zahtevaš. Čakajoče potekle zgodbe: $count.';
  }

  @override
  String get storyCleanupNow => 'Izbriši zdaj';

  @override
  String get storyCleanupDone => 'Potekle zgodbe izbrisane.';

  @override
  String get storyCleanupPartly =>
      'Nekaterih še ni bilo mogoče izbrisati; Mialuna bo poskusila znova.';

  @override
  String get editorPro => 'Pro urejevalnik';

  @override
  String get editorModeBasic => 'Osnovno';

  @override
  String get editorModePro => 'Pro';

  @override
  String get toolCrop => 'Obreži';

  @override
  String get toolLight => 'Svetloba';

  @override
  String get toolColor => 'Barva';

  @override
  String get toolHsl => 'HSL';

  @override
  String get toolCurves => 'Krivulje';

  @override
  String get toolEffects => 'Učinki';

  @override
  String get straighten => 'Poravnaj';

  @override
  String get exposure => 'Osvetlitev';

  @override
  String get highlights => 'Svetli deli';

  @override
  String get shadows => 'Sence';

  @override
  String get whites => 'Beline';

  @override
  String get blacks => 'Črnine';

  @override
  String get temperature => 'Temperatura';

  @override
  String get tint => 'Ton';

  @override
  String get vibrance => 'Živahnost';

  @override
  String get hue => 'Odtenek';

  @override
  String get luminance => 'Svetlost';

  @override
  String get colorRed => 'Rdeča';

  @override
  String get colorOrange => 'Oranžna';

  @override
  String get colorYellow => 'Rumena';

  @override
  String get colorGreen => 'Zelena';

  @override
  String get colorAqua => 'Akva';

  @override
  String get colorBlue => 'Modra';

  @override
  String get colorPurple => 'Vijolična';

  @override
  String get colorMagenta => 'Magenta';

  @override
  String get curveHint =>
      'Povlecite točko za oblikovanje krivulje, tapnite za dodajanje, dvakrat tapnite za odstranitev.';

  @override
  String get sharpen => 'Ostrenje';

  @override
  String get vignette => 'Vinjeta';

  @override
  String get grain => 'Zrnatost';

  @override
  String get holdForOriginal =>
      'Pridržite fotografijo, da jo primerjate z izvirnikom.';

  @override
  String get showingOriginal => 'Izvirnik';

  @override
  String get applyLookToAll => 'Uporabi ta videz za vse fotografije';

  @override
  String get applyingEdits => 'Obdelava fotografij…';

  @override
  String get choosePhotoToEdit => 'Izberite fotografijo za urejanje';
}
