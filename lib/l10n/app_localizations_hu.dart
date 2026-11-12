// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hungarian (`hu`).
class AppLocalizationsHu extends AppLocalizations {
  AppLocalizationsHu([String locale = 'hu']) : super(locale);

  @override
  String get syncUpToDate => 'Naprakész';

  @override
  String get syncFailed => 'A szinkron sikertelen';

  @override
  String get relaysUpdatedFromProfile =>
      'Relays frissítve a profilodból (NIP-65)';

  @override
  String get relayListPublished => 'Relay lista közzétéve';

  @override
  String get mediaServersUpdatedFromProfile =>
      'A médiaszerverek frissültek a profilodból';

  @override
  String get tabHome => 'Home';

  @override
  String get tabDiscover => 'Felfedezés';

  @override
  String get tabCreate => 'Létrehozás';

  @override
  String get tabReels => 'Reels';

  @override
  String get tabProfile => 'Profil';

  @override
  String get signInToUploadMedia => 'Belépés a média feltöltéséhez.';

  @override
  String get noMediaServer =>
      'Nincs médiaszerver beállítva. Adj hozzá egyet a Beállításokban.';

  @override
  String serverNoResponse(Object server) {
    return '$server: nincs válasz';
  }

  @override
  String serverUnreachable(Object server, Object error) {
    return '$server: nem elérhető ($error)';
  }

  @override
  String uploadRejected(Object reason) {
    return 'Feltöltés elutasítva — $reason';
  }

  @override
  String noServerAcceptedFile(Object reasons) {
    return 'Egy szerver sem fogadta a fájlt — $reasons';
  }

  @override
  String get blossomInvalidResponse => 'érvénytelen válasz';

  @override
  String get blossomInvalidFileUrl => 'érvénytelen fájlcím';

  @override
  String get blossomServerAlteredFile => 'a szerver módosította a fájlt';

  @override
  String get blossomBadRequest => 'érvénytelen kérés';

  @override
  String get blossomUnauthorized => 'engedély megtagadva';

  @override
  String get blossomPaymentRequired => 'fizetés szükséges';

  @override
  String get blossomForbidden => 'nem engedélyezett';

  @override
  String get blossomLengthRequired => 'hiányzó méret';

  @override
  String get blossomTooLarge => 'túl nagy fájl';

  @override
  String get blossomUnsupportedType => 'a formátum nem fogadott';

  @override
  String get blossomTooManyRequests => 'túl sok kérés';

  @override
  String get blossomServerError => 'szerverhiba';

  @override
  String get cipherInvalidKey => 'Érvénytelen kulcs';

  @override
  String get cipherTruncated => 'A titkosított fájl csonka';

  @override
  String get cipherMismatch =>
      'A fájl nem egyezik a kulccsal: módosított vagy sérült';

  @override
  String get sanitizeHeifNeedsAsync =>
      'HEIC/AVIF formátum: a konverzióhoz sanitizeAsync kell';

  @override
  String get sanitizeWebmUnsupported =>
      'A WebM/MKV videó nem támogatott: használj MP4 vagy MOV fájlt, hogy a metaadat feltöltés előtt eltávolítható legyen.';

  @override
  String get sanitizeUnknownFormat =>
      'Ismeretlen fájlformátum: JPEG/PNG/WebP/GIF fotó vagy MP4/MOV videó.';

  @override
  String sanitizeLeftovers(Object items) {
    return 'Nem sikerült minden metaadatot eltávolítani ($items): a fájl nem lett feltöltve.';
  }

  @override
  String sanitizeProcessingFailed(Object error) {
    return 'A fájl feldolgozása nem sikerült: $error';
  }

  @override
  String get sanitizeJpegInvalid => 'Érvénytelen JPEG';

  @override
  String get sanitizeJpegTruncated => 'Csonka JPEG';

  @override
  String get sanitizeJpegNoSize => 'JPEG méret nélkül';

  @override
  String get sanitizeJpegUndecodable => 'A JPEG nem dekódolható';

  @override
  String get sanitizePngTruncated => 'Csonka PNG';

  @override
  String get sanitizePngInvalid => 'Érvénytelen PNG';

  @override
  String get sanitizeGifInvalid => 'Érvénytelen GIF';

  @override
  String get sanitizeGifTruncated => 'Csonka GIF';

  @override
  String get sanitizeWebpTruncated => 'Csonka WebP';

  @override
  String get sanitizeWebpInvalid => 'Érvénytelen WebP';

  @override
  String get sanitizeMp4Invalid => 'Érvénytelen MP4/MOV videó';

  @override
  String get sanitizeConversionFailed => 'A konverzió sikertelen';

  @override
  String get sanitizeHeifUnsupported =>
      'Ez a formátum (HEIC/AVIF) ezen az eszközön nem konvertálható. Válassz JPEG vagy PNG fotót.';

  @override
  String get privateMediaNotEncrypted => 'A média nincs titkosítva';

  @override
  String serverReplied(Object status) {
    return 'A szerver ezt válaszolta: $status';
  }

  @override
  String get fileTooLarge => 'Túl nagy fájl';

  @override
  String get serverFileNotOriginal => 'A szerveren lévő fájl nem az eredeti';

  @override
  String get contentMismatch => 'A tartalom nem egyezik';

  @override
  String get mediaUnreachable => 'A média nem elérhető';

  @override
  String get amberInvalidKey => 'Az Amber érvénytelen kulcsot adott vissza';

  @override
  String get amberNoKey => 'Az Amber nem adott vissza kulcsot';

  @override
  String get amberRequestRejected => 'A kérés elutasítva az Amberben';

  @override
  String get amberAndroidOnly => 'Az Amber csak Androidon érhető el';

  @override
  String get amberEmptySignature => 'Az Amber üres aláírást adott vissza';

  @override
  String get amberSignRejected => 'Az aláírás elutasítva az Amberben';

  @override
  String get amberTimeout => 'Az Amber nem válaszolt időben';

  @override
  String get amberEmptyResponse => 'Az Amber üres választ adott vissza';

  @override
  String get bunkerInvalidUrl => 'Érvénytelen bunker URL';

  @override
  String get bunkerNoRelay => 'A bunker nem sorol fel egy relay-t sem';

  @override
  String get bunkerWebAuth =>
      'A bunker webes engedélyt kér (az auth_url nem támogatott)';

  @override
  String get bunkerInvalidKey => 'A bunker nem adott vissza érvényes kulcsot';

  @override
  String get signerInvalidResponse =>
      'Az aláíró érvénytelen aláírt eseményt adott vissza';

  @override
  String get bunkerTimeout => 'Bunker időtúllépés';

  @override
  String get nwcInvalidUri => 'Érvénytelen NWC URI';

  @override
  String get nwcNoRelay => 'Az NWC URI nem sorol fel egy relay-t sem';

  @override
  String get nwcNoSecret => 'Az NWC URI nem tartalmaz érvényes titkot';

  @override
  String get nwcTimeout => 'A tárca időtúllépése';

  @override
  String get signerNoPrivateMessages =>
      'Ez a belépési mód nem támogatja a privát üzeneteket';

  @override
  String get zapNotSupported => 'Ez a cím nem támogatja a Nostr zap küldést';

  @override
  String zapAmountOutOfRange(Object min, Object max) {
    return 'Az összeg a tartományon kívül van ($min–$max sats)';
  }

  @override
  String get commentNotSent =>
      'A hozzászólás nem ment el. Próbáld újra később.';

  @override
  String get comments => 'Hozzászólások';

  @override
  String get noCommentsYet => 'Még nincs hozzászólás.';

  @override
  String get signInToComment => 'Belépés a hozzászóláshoz.';

  @override
  String get addComment => 'Hozzászólás…';

  @override
  String get signInToPublish => 'Belépés a közzétételhez.';

  @override
  String get addMediaFirst =>
      'Tegyél hozzá legalább egy fotót vagy videót a közzététel előtt.';

  @override
  String get removingMetadata => 'Metaadatok eltávolítása…';

  @override
  String uploadingProgress(Object current, Object total) {
    return 'Feltöltés: $current / $total…';
  }

  @override
  String get creatingPreview => 'Előnézet készítése…';

  @override
  String uploadFailed(Object error) {
    return 'A feltöltés sikertelen: $error';
  }

  @override
  String get publishing => 'Közzététel…';

  @override
  String noRelayAcceptedPost(Object reason) {
    return 'Egy relay sem fogadta el a bejegyzést$reason. A tartalom a piszkozatokban marad.';
  }

  @override
  String get privateNeedsKeySigner =>
      'Ez a belépési mód nem támogatja a privát tartalmat. Használj Amber-t, bunker-t vagy a helyi kulcsot.';

  @override
  String get closeFriendsListEmptyAddSomeone =>
      'A szűk barátok listád üres: adj hozzá valakit.';

  @override
  String get fileOver100Mb =>
      'A fájl 100 MB feletti: ez a szűk barátok korlátja (a telefonodon titkosítjuk, egészben).';

  @override
  String get encryptingOnPhone => 'Titkosítás a telefonodon…';

  @override
  String noServerAcceptedEncrypted(Object details) {
    return 'Egyik médiaszervered sem fogadta el a titkosított fájlt. Nem tesszük közzé nyíltan. Adj hozzá a Beállításokban egy szervert, amely elfogad titkosított fájlokat (például cdn.hzrd149.com). $details';
  }

  @override
  String get sendingToFriends => 'Küldés a barátoknak…';

  @override
  String sendingToFriendsProgress(Object done, Object total) {
    return 'Küldés a barátoknak $done/$total…';
  }

  @override
  String noFriendReceivedPost(Object reason) {
    return 'Egy barát sem kapta meg a bejegyzést$reason. A tartalom a piszkozatokban marad.';
  }

  @override
  String sentToCloseFriends(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Elküldve $count szűk barátnak 🔒',
      one: 'Elküldve 1 szűk barátnak 🔒',
    );
    return '$_temp0';
  }

  @override
  String sentToFriendsWithMisses(int delivered, Object missed) {
    String _temp0 = intl.Intl.pluralLogic(
      delivered,
      locale: localeName,
      other: 'Elküldve $delivered barátnak.',
      one: 'Elküldve 1 barátnak.',
    );
    return '$_temp0 $missed nem kapta meg (a privát üzenetek ki vannak kapcsolva).';
  }

  @override
  String get altText => 'Alt szöveg';

  @override
  String get altTextHint => 'Írd le a tartalmat azoknak, akik nem látják…';

  @override
  String get cancel => 'Mégse';

  @override
  String get save => 'Mentés';

  @override
  String get momentPublished => 'Pillanat közzétéve ✨';

  @override
  String get newMoment => 'Új pillanat';

  @override
  String get publish => 'Közzététel';

  @override
  String get guestMode => 'Vendég mód';

  @override
  String get signInToPostMoments => 'Belépés a pillanataid közzétételéhez.';

  @override
  String get signIn => 'Belépés';

  @override
  String get kindPhoto => 'Fotó';

  @override
  String get kindVideo => 'Videó';

  @override
  String get kindReel => 'Reel';

  @override
  String get kindStory => 'Történet';

  @override
  String get storyExpiryNote =>
      'A történetek 24 óra után lejárnak azokon a relays kiszolgálókon, amelyek betartják a NIP-40-et, de mások így is elmenthetik vagy archiválhatják őket.';

  @override
  String get fromGallery => 'Galériából';

  @override
  String get galleryLongPressVideo => 'Galéria (hosszan nyomva: videó)';

  @override
  String get addVideo => 'Videó hozzáadása';

  @override
  String get camera => 'Kamera';

  @override
  String get exifRemovedNote => 'A helyadat (EXIF) automatikusan törlődik.';

  @override
  String get writeCaption => 'Írj képaláírást…';

  @override
  String get privatePostNote =>
      'Privát bejegyzés: nincs nyilvános hashtag, kereséssel nem található.';

  @override
  String willPublishAs(Object caption) {
    return 'Így lesz közzétéve: \"$caption\"';
  }

  @override
  String get tapThumbnailForAlt => 'Koppints a bélyegképre az alt szöveghez.';

  @override
  String get sensitiveContent => 'Érzékeny tartalom';

  @override
  String get sensitiveContentNote =>
      'A bejegyzés figyelmeztetés mögé kerül (NIP-36).';

  @override
  String get uploadingMedia => 'Média feltöltése…';

  @override
  String get audiencePublic => 'Nyilvános';

  @override
  String get closeFriends => 'Szűk barátok';

  @override
  String get signerCannotPublishCloseFriends =>
      'Ezzel a belépéssel nem tehetsz közzé szűk barátoknak: használj Amber-t, bunker-t vagy a helyi kulcsot.';

  @override
  String get closeFriendsEmptyPrompt =>
      'A listád üres: add hozzá, kik láthatják ezt a bejegyzést.';

  @override
  String onlyYourCloseFriendsSee(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Csak a $count szűk barátod látja ezt. A fotók és videók a telefonodon titkosítva kerülnek feltöltésre.',
      one: 'Csak 1 szűk barátod látja ezt. A fotók és videók a telefonodon titkosítva kerülnek feltöltésre.',
    );
    return '$_temp0';
  }

  @override
  String get addFriends => 'Barátok hozzáadása';

  @override
  String get manageList => 'Lista kezelése';

  @override
  String get edit => 'Szerkesztés';

  @override
  String get reset => 'Visszaállítás';

  @override
  String get apply => 'Alkalmaz';

  @override
  String get cropFree => 'Szabad';

  @override
  String get cropOriginal => 'Eredeti';

  @override
  String get rotate => 'Forgatás';

  @override
  String get flip => 'Tükrözés';

  @override
  String get brightness => 'Fényerő';

  @override
  String get contrast => 'Kontraszt';

  @override
  String get saturation => 'Telítettség';

  @override
  String postsByAuthor(Object author) {
    return '$author bejegyzései…';
  }

  @override
  String get searchHint => 'Keress embereket, hashtageket vagy szavakat…';

  @override
  String get clear => 'Töröl';

  @override
  String get recent => 'Friss';

  @override
  String get searchDependsOnRelays =>
      'A keresés a beállított relays listától függ: az eredmény részleges lehet.';

  @override
  String get recentPostsEverywhere =>
      'Friss bejegyzések az egész hálózatról, olyanoktól is, akiket nem követsz.';

  @override
  String get noResultsOnRelays => 'Nincs találat a beállított relays listán.';

  @override
  String get noRecentPostsFromFollowed =>
      'Nincs friss bejegyzés azoktól, akiket követsz.';

  @override
  String get noMomentsFound =>
      'Nincs pillanat a relays listán. Ellenőrizd a kapcsolatot.';

  @override
  String get loadFailed => 'A betöltés sikertelen';

  @override
  String get notifications => 'Értesítések';

  @override
  String get messages => 'Üzenetek';

  @override
  String get homeEmptyFollowsNobody =>
      'Itt jelennek meg azok bejegyzései, akiket követsz.\nMég senkit sem követsz: a Felfedezésben találsz érdekes embereket és profilokat.';

  @override
  String get discoverPeople => 'Felfedezés';

  @override
  String get homeEmpty =>
      'Még nincs pillanat.\nHúzd le a frissítéshez, vagy tedd közzé az első képed.';

  @override
  String get retry => 'Újra';

  @override
  String get seenEverything => 'Egyelőre mindent láttál ✨';

  @override
  String get discoverMoreProfiles => 'Több profil a Felfedezésben';

  @override
  String get feedFollowing => 'Követettek';

  @override
  String get signInToSeeFollowed =>
      'Belépés, hogy lásd azok bejegyzéseit, akiket követsz';

  @override
  String get videoPreview => 'Videó-előnézet';

  @override
  String get cannotOpenPrivateVideo => 'A privát videó nem nyitható meg';

  @override
  String get cannotPlayVideo => 'A videó nem játszható le';

  @override
  String get pauseVideo => 'Videó szüneteltetése';

  @override
  String get playVideo => 'Videó lejátszása';

  @override
  String errorTapToRetry(Object error) {
    return '$error — koppints az újrapróbáláshoz';
  }

  @override
  String get soundOn => 'Hang be';

  @override
  String get soundOff => 'Hang ki';

  @override
  String get postImage => 'A bejegyzés képe';

  @override
  String get imageUnavailable => 'A kép nem elérhető';

  @override
  String errorTapToRetryNewline(Object message) {
    return '$message\nKoppints az újrapróbáláshoz';
  }

  @override
  String get cannotOpenPrivateContent =>
      'Ez a privát tartalom nem nyitható meg';

  @override
  String get privateImage => 'Privát kép';

  @override
  String get invalidImage => 'Érvénytelen kép';

  @override
  String get more => 'Több';

  @override
  String get removeFromSaved => 'Eltávolítás a mentettekből';

  @override
  String get copyLink => 'Link másolása';

  @override
  String get muteAuthor => 'Szerző némítása';

  @override
  String get blockAuthor => 'Szerző tiltása';

  @override
  String get report => 'Jelentés';

  @override
  String get like => 'Tetszik';

  @override
  String get sendInMessage => 'Küldés üzenetben';

  @override
  String get zapOptional => 'Zap (nem kötelező)';

  @override
  String get closeFriendsOnlyNote =>
      'Csak a szűk barátok látják. A kedvelések és a válaszok csak a szerzőhöz mennek.';

  @override
  String get likeFailed => 'A kedvelés nem ment el';

  @override
  String get nostrLinkCopied => 'A Nostr link a vágólapra másolva';

  @override
  String get authorMuted => 'Szerző némítva';

  @override
  String get authorBlocked => 'Szerző tiltva';

  @override
  String get reportSent => 'Jelentés elküldve (NIP-56)';

  @override
  String get signInToReport => 'Belépés a jelentéshez';

  @override
  String minutesAgo(Object minutes) {
    return '$minutes perce';
  }

  @override
  String get show => 'Mutat';

  @override
  String get chatEmptyHint =>
      'Írd meg az első üzenetet.\nTitkosított: csak ti ketten látjátok.';

  @override
  String get messageHint => 'Üzenet…';

  @override
  String get send => 'Küldés';

  @override
  String get notSentSuffix => ' nem ment el';

  @override
  String get contentUnavailable =>
      'A tartalom nem elérhető (lejárt, vagy nincs a relays listán)';

  @override
  String get signInToSendPrivateMessages =>
      'Belépés privát üzenetek küldéséhez.';

  @override
  String get cannotMessageYourself => 'Magadnak nem írhatsz.';

  @override
  String get recipientNoPrivateMessages =>
      'Ez a személy még nem kapcsolta be a privát üzeneteket.';

  @override
  String noRecipientRelayAccepted(Object reason) {
    return 'A címzett egy relay-e sem fogadta el az üzenetet$reason.';
  }

  @override
  String sendFailed(Object error) {
    return 'A küldés sikertelen: $error';
  }

  @override
  String get signInToReadMessages =>
      'Belépés a privát üzenetek olvasásához és küldéséhez.';

  @override
  String get signerNoPrivateMessagesLong =>
      'A privát üzenetek ezzel a belépéssel nem használhatók. Belépés Amberrel, bunkerrel vagy a helyi kulccsal.';

  @override
  String get inboxEmpty =>
      'Nincs beszélgetés.\nKoppints a ceruzára, hogy írj valakinek, vagy továbbíts egy pillanatot a ✈ ikonnal minden bejegyzés alatt.';

  @override
  String get newMessage => 'Új üzenet';

  @override
  String get privateMessagesEnabled => 'Privát üzenetek bekapcsolva';

  @override
  String get enableMessagesFailed => 'Nem sikerült bekapcsolni. Próbáld újra.';

  @override
  String get enablePrivateMessages => 'Privát üzenetek bekapcsolása';

  @override
  String enablePrivateMessagesExplain(Object count) {
    return 'Az üzenetek fogadásához meg kell mondanod, mely relays címekre érkezzenek. Egy kis lista (NIP-17) jelenik meg $count alapértelmezett relays bejegyzéssel: később módosíthatod. Az üzenetek titkosak maradnak: a relays nem látja, ki ír, sem a szöveget.';
  }

  @override
  String get turnOn => 'Bekapcsolás';

  @override
  String get searchByNameOrUsername =>
      'Keresés név vagy felhasználónév szerint';

  @override
  String get searching => 'Keresés…';

  @override
  String get noOneWithNameHint =>
      'Nincs ilyen nevű. Próbálj kevesebb betűt, vagy egy címet, mint name@domain.com.';

  @override
  String get sent => 'Elküldve';

  @override
  String sentToPeople(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Elküldve $count személynek',
      one: 'Elküldve 1 személynek',
    );
    return '$_temp0';
  }

  @override
  String sentToPeopleWithFailure(int count, Object failure) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Elküldve $count személynek. $failure',
      one: 'Elküldve 1 személynek. $failure',
    );
    return '$_temp0';
  }

  @override
  String get signerNoPrivateMessagesShort =>
      'Ezzel a belépéssel nem használhatsz privát üzeneteket.';

  @override
  String get followToStartOrSearch =>
      'Követés: kövess valakit a kezdéshez, vagy keress név szerint.';

  @override
  String get addMessage => 'Üzenet hozzáadása…';

  @override
  String sendWithCount(Object count) {
    return 'Küldés ($count)';
  }

  @override
  String get linkCopied => 'A link a vágólapra másolva';

  @override
  String get noNotifications => 'Most nincs értesítés.';

  @override
  String get notificationsDependOnRelays =>
      'Az értesítések a relays listától függenek: hiányosak lehetnek.';

  @override
  String get reactedToYourMoment => 'reagált a pillanatodra';

  @override
  String commentedText(Object text) {
    return 'hozzászólt: $text';
  }

  @override
  String sentYouSats(Object sats, Object comment) {
    return 'küldött neked $sats sats$comment';
  }

  @override
  String get sentYouZap => 'küldött neked egy zap-et';

  @override
  String get startedFollowingYou => 'követni kezdett';

  @override
  String get amberNotFound => 'Az Amber nem található';

  @override
  String get amberExplain =>
      'Az Amber egy Nostr aláíró, amely a privát kulcsodat a Mialuna alkalmazáson kívül tartja. Telepítsd, és próbáld újra.';

  @override
  String get downloadFromFdroid => 'Letöltés az F-Droidról';

  @override
  String get continueWithAmber => 'Tovább az Amberrel';

  @override
  String get amberRecommended =>
      'Ajánlott: a privát kulcsod az Amberben marad biztonságban.';

  @override
  String get amberNotDetected =>
      'Az Amber nem észlelhető: telepítsd az ajánlott belépéshez.';

  @override
  String get exploreWithoutAccount => 'Felfedezés fiók nélkül';

  @override
  String get remoteBunker => 'Távoli bunker (NIP-46)';

  @override
  String get invalidBunkerUrlDot => 'Érvénytelen bunker URL.';

  @override
  String get connectBunker => 'Csatlakozás a bunkerhez';

  @override
  String get advancedNsec => 'Haladó belépés (nsec)';

  @override
  String get nsecWarning =>
      'Figyelem: a privát kulcs beillesztése kockázatos. Soha ne oszd meg senkivel. Androidon inkább az Amber.';

  @override
  String get invalidNsec => 'Érvénytelen nsec kulcs.';

  @override
  String get signInWithNsec => 'Belépés nsec-kel';

  @override
  String get tagline => 'A pillanataid, ugyanazon hold alatt.';

  @override
  String get skip => 'Kihagyás';

  @override
  String get permissionsAndWallet => 'Engedélyek és tárca';

  @override
  String get permissionsExplain =>
      'Csak a közzétételt és az értesítések fogadását engedik. Bármikor módosíthatod őket a rendszerbeállításokban.';

  @override
  String get photosAndVideos => 'Fotók és videók';

  @override
  String get toUploadYourMoments => 'A pillanataid feltöltéséhez';

  @override
  String get allow => 'Engedélyezés';

  @override
  String get reactionsCommentsZaps => 'Reakciók, hozzászólások és zap';

  @override
  String get lightningWalletOptional => 'Lightning tárca (nem kötelező)';

  @override
  String get nwcExplain =>
      'Csatlakoztass egy Nostr Wallet Connect tárcát, hogy zap küldéséhez ne kelljen kilépned az appból.';

  @override
  String get walletConnected => 'Tárca csatlakoztatva';

  @override
  String get disconnect => 'Leválasztás';

  @override
  String get connectWallet => 'Tárca csatlakoztatása';

  @override
  String get getStarted => 'Kezdd el';

  @override
  String get welcome1 =>
      'A Mialuna vizuális közösségi háló: fotók, videók, Reels és történetek — soha nem csak szöveges bejegyzések.';

  @override
  String get welcome2 =>
      'Nostron fut, egy nyílt protokollon: az identitásod egy kulcs, ami a tiéd, nem egy fiók, amit egy cég elvehet. Nincs hirdetés, nincs nyomkövető, nincs központi szerver.';

  @override
  String get welcome3 =>
      'Oszd meg a fényed emberekkel mindenhol, bármely appból, amely ugyanazt a nyílt nyelvet beszéli.';

  @override
  String onboardingWot(int min) {
    return 'A bizalmi háló mindig be van kapcsolva. Amikor először nyitod meg a Mialuna appot, beolvassa, kiket követsz, és ebből építi a Felfedezés hírfolyamot: te, akiket követsz, és akit közülük legalább $min követ. A következő megnyitáskor ez a hírfolyam már kész.';
  }

  @override
  String get publicAndPrivate => 'Nyilvános és privát';

  @override
  String get publicAndPrivateIntro =>
      'A Mialuna a Nostrra épül, egy nyílt hálózatra. Amit közzéteszel, nyilvános: a bejegyzések, fotók és videók a link birtokában bárki számára láthatók, a Mialunán kívül is.';

  @override
  String get closeFriendsExplain1 =>
      'Csak a listán lévők kapják a \"szűk barátok\" bejegyzéseidet, történeteidet és videóidat. A lista a bejegyzésben van; nem kell minden alkalommal kiválasztanod.';

  @override
  String get closeFriendsExplain2 =>
      'A fotók és videók a telefonodon titkosítva kerülnek feltöltésre. A fájlszerverek (Blossom) maguktól nem titkosítanak: ezért teszi a Mialuna, és a szerver csak olvashatatlan adatot lát. Aki megtalálja a fájl címét, nem tudja megnyitni.';

  @override
  String get closeFriendsExplain3 =>
      'Ez nem abszolút garancia: aki megkap egy bejegyzést, képernyőképet készíthet, és egy barát eltávolítása csak a későbbi bejegyzésekre vonatkozik.';

  @override
  String get closeFriendsExplain4 =>
      'Minden barátnak a Mialuna appot kell használnia, bekapcsolt privát üzenetekkel. Más Nostr kliensek nem mutatják ezeket a bejegyzéseket.';

  @override
  String get closeFriendsExplain5 =>
      'A nyilvános bejegyzések nyilvánosak maradnak: a fájljaik a link birtokában bárki számára láthatók.';

  @override
  String get closeFriendsExplain6 =>
      'Ha egyik szervered sem fogad el titkosított fájlokat, a bejegyzés nem jelenik meg: soha nem nyíltan.';

  @override
  String get addToCloseFriends => 'Hozzáadás a szűk barátokhoz';

  @override
  String maxFriendsReached(Object max, Object added) {
    return 'Legfeljebb $max barát: $added hozzáadva.';
  }

  @override
  String get add => 'Hozzáadás';

  @override
  String get signInToCreateList => 'Belépés a listád létrehozásához.';

  @override
  String get signerNoCloseFriends =>
      'A szűk barátok ezzel a belépéssel nem használhatók. Belépés Amberrel, bunkerrel vagy a helyi kulccsal.';

  @override
  String peopleOfMax(Object count, Object max) {
    return '$count / $max ember';
  }

  @override
  String get noOneYet => 'Még senki.';

  @override
  String get addPeople => 'Emberek hozzáadása';

  @override
  String get friendNoPrivateMessagesWarning =>
      'Még nem kapcsolták be a privát üzeneteket: nem kapják meg a bejegyzéseidet';

  @override
  String get removeFromList => 'Eltávolítás a listáról';

  @override
  String get noOneWithThisName => 'Nincs ilyen nevű.';

  @override
  String get signInToSendPrivateContent =>
      'Belépés privát tartalom küldéséhez.';

  @override
  String get reasonNoPrivateMessages => 'nem kapcsolta be a privát üzeneteket';

  @override
  String get reasonNoRelayAnswered => 'egy relay sem válaszolt';

  @override
  String get profileUpdated => 'Profil frissítve';

  @override
  String get noRelayAcceptedRetry =>
      'Egy relay sem fogadta el. Próbáld újra később.';

  @override
  String get editProfile => 'Profil szerkesztése';

  @override
  String get fieldName => 'Név';

  @override
  String get fieldBio => 'Bio';

  @override
  String get fieldAvatarUrl => 'Avatar URL';

  @override
  String get fieldNip05 => 'NIP-05 (pl. te@example.com)';

  @override
  String get browsingAsGuest => 'Vendégként böngészel';

  @override
  String get signInToInteract =>
      'Belépés a közzétételhez, a követéshez és az interakcióhoz.';

  @override
  String get settings => 'Beállítások';

  @override
  String get signOut => 'Kilépés';

  @override
  String get npubCopied => 'npub másolva';

  @override
  String get copyNpub => 'npub másolása';

  @override
  String get mute => 'Némítás';

  @override
  String get block => 'Tiltás';

  @override
  String get posts => 'Bejegyzések';

  @override
  String get saved => 'Mentett';

  @override
  String get nothingPublishedYet => 'Még nem tettél közzé semmit.';

  @override
  String get noPostsOnRelays => 'Nincs bejegyzés a relays listán.';

  @override
  String get noReelsPublished => 'Nincs közzétett reels.';

  @override
  String get noReelsOnRelays => 'Nincs reels a relays listán.';

  @override
  String get noSavedPosts => 'Nincs mentett bejegyzés.';

  @override
  String get followingButton => 'Követve';

  @override
  String get follow => 'Követés';

  @override
  String get messageButton => 'Üzenet';

  @override
  String get loginLocalKey => 'Helyi kulcs';

  @override
  String get loginGuest => 'Vendég';

  @override
  String get followUpdateFailed =>
      'A követéseid most nem frissíthetők. Próbáld újra.';

  @override
  String get noReelsComeBack =>
      'Nincs reels a relays listán.\nNézz vissza hamarosan!';

  @override
  String get followUpdateFailedShort => 'A követéseid most nem frissíthetők';

  @override
  String get needOneReadRelay => 'Legalább egy olvasási relay szükséges.';

  @override
  String get listSavedLocally =>
      'A lista ezen az eszközön mentve, nincs közzétéve.';

  @override
  String get noRelayAcceptedList =>
      'Egy relay sem fogadta el a listát: később újrapróbáljuk.';

  @override
  String relayListPublishedTo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Relay lista közzétéve $count relays felé',
      one: 'Relay lista közzétéve 1 relay felé',
    );
    return '$_temp0';
  }

  @override
  String get mediaServersUpdated => 'Médiaszerverek frissítve';

  @override
  String get appearance => 'Megjelenés';

  @override
  String get publishingSettings => 'Közzététel';

  @override
  String get addMialunaHashtag => '#mialuna hozzáadása';

  @override
  String get addMialunaHashtagNote =>
      'A hivatalos hashtag hozzáadása a nyilvános bejegyzésekhez és történetekhez. Bármikor kikapcsolhatod.';

  @override
  String get themeLight => 'Világos';

  @override
  String get themeDark => 'Sötét';

  @override
  String get themeSystem => 'Rendszer';

  @override
  String get relays => 'Relays';

  @override
  String get relaysExplainSignedOut =>
      'A Relays tárolják és terjesztik a tartalmat. Belépés a saját listád automatikus használatához (NIP-65).';

  @override
  String get relaysExplainSynced =>
      'A lista szinkronban van a Nostr profiloddal (NIP-65): minden változás közzétételre kerül, és minden appodra érvényes.';

  @override
  String get syncing => 'Szinkronizálás…';

  @override
  String get waitingFirstSync => 'Várakozás az első szinkronra';

  @override
  String get syncNow => 'Szinkron most';

  @override
  String get addRelay => 'relay hozzáadása';

  @override
  String get restoreDefaultRelays => 'Alapértelmezett relays visszaállítása';

  @override
  String get createYourList => 'Saját lista létrehozása';

  @override
  String peopleCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count személy',
      one: '1 személy',
    );
    return '$_temp0';
  }

  @override
  String get closeFriendsSettingsNote =>
      'Bejegyzések, történetek és videók, amelyeket csak ők látnak, titkosított fotókkal és videókkal.';

  @override
  String get mediaServersBlossom => 'Médiaszerverek (Blossom)';

  @override
  String get mediaServersExplain =>
      'A fotók és videók csak ezekre a szerverekre kerülnek, a mutatott sorrendben: az első, amelyik elfogadja, nyer. Az EXIF és a hely feltöltés előtt törlődik.';

  @override
  String get primary => 'Elsődleges';

  @override
  String get makePrimary => 'Legyen elsődleges';

  @override
  String get remove => 'Eltávolítás';

  @override
  String get addServer => 'Szerver hozzáadása';

  @override
  String get moderation => 'Moderálás';

  @override
  String get moderationExplain =>
      'A némított szerzők és a rejtett hashtagek a NIP-51 szerint szinkronizálódnak. A tiltott szerzők csak ezen az eszközön maradnak.';

  @override
  String get mutedAuthors => 'Némított szerzők';

  @override
  String get noMutedAuthors => 'Nincs némított szerző';

  @override
  String get blockedAuthors => 'Tiltott szerzők';

  @override
  String get noBlockedAuthors => 'Nincs tiltott szerző';

  @override
  String get hiddenHashtags => 'Rejtett hashtagek';

  @override
  String get noHiddenHashtags => 'Nincs rejtett hashtag';

  @override
  String get hashtagToHide => 'Rejtendő #hashtag';

  @override
  String get storage => 'Tárhely';

  @override
  String get clearCache => 'Esemény-gyorsítótár és piszkozatok törlése';

  @override
  String get cacheCleared => 'Gyorsítótár törölve';

  @override
  String get reviewIntro => 'Bevezető újranézése';

  @override
  String get reviewIntroSubtitle =>
      'Mi nyilvános, mi privát, és a szűk barátok korlátai.';

  @override
  String noLightningWalletCopied(Object address) {
    return 'Nincs Lightning tárca: a cím másolva ($address)';
  }

  @override
  String get about => 'Névjegy';

  @override
  String aboutText(Object version) {
    return 'Mialuna $version — A pillanataid, ugyanazon hold alatt.\nNyílt forrás (MIT). github.com/Lwb89dev/mialuna';
  }

  @override
  String get invalidRelayAddress =>
      'Érvénytelen cím: használd a wss://… formát';

  @override
  String get invalidServerAddress =>
      'Érvénytelen cím: használd a https://… formát';

  @override
  String get relayRead => 'Olvasás';

  @override
  String get relayWrite => 'Írás';

  @override
  String get support => 'Támogatás';

  @override
  String get supportText =>
      'A Mialuna ingyenes, nincs benne hirdetés, és nem követ téged. Ha tetszik, küldhetsz néhány sats-ot a Lightning Networkön.';

  @override
  String get donateWithLightning => 'Adomány Lightninggel';

  @override
  String get authorNoZaps => 'Ez a szerző nem fogad zap küldést';

  @override
  String get sendZap => 'zap küldése ⚡';

  @override
  String get amountInSats => 'Összeg sats-ban';

  @override
  String minMaxSats(Object min, Object max) {
    return 'min $min – max $max';
  }

  @override
  String get zap => 'Zap';

  @override
  String get signInToZap => 'Belépés a zap küldéséhez';

  @override
  String zapSent(Object sats) {
    return 'Zap elküldve: $sats sats ⚡';
  }

  @override
  String nwcPaymentFailed(Object error) {
    return 'Az NWC fizetés sikertelen: $error';
  }

  @override
  String get noLightningWallet => 'Nincs Lightning tárca';

  @override
  String storiesRailLabel(Object state) {
    return 'Történetek, $state';
  }

  @override
  String get close => 'Bezárás';

  @override
  String hoursAgo(int hours) {
    return '$hours órája';
  }

  @override
  String daysAgo(int days) {
    return '$days napja';
  }

  @override
  String get now => 'most';

  @override
  String get youPrefix => 'Te: ';

  @override
  String get storiesStateUnseen => 'új';

  @override
  String get storiesStateSeen => 'látva';

  @override
  String weekdayShort(String day) {
    String _temp0 = intl.Intl.selectLogic(day, {
      'mon': 'H',
      'tue': 'K',
      'wed': 'Sze',
      'thu': 'Cs',
      'fri': 'P',
      'sat': 'Szo',
      'sun': 'V',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get sharedAMoment => 'Megosztott egy pillanatot';

  @override
  String get blossomOtherError => 'hiba';

  @override
  String get languageTitle => 'Nyelv';

  @override
  String get languageSystem => 'Rendszer';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageItalian => 'Italiano';

  @override
  String get cannotEditPhoto => 'Ez a fotó itt nem szerkeszthető.';

  @override
  String notificationsNew(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count új értesítés',
      one: '1 új értesítés',
    );
    return '$_temp0';
  }

  @override
  String messagesUnread(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count olvasatlan üzenet',
      one: '1 olvasatlan üzenet',
    );
    return '$_temp0';
  }

  @override
  String get done => 'Kész';

  @override
  String get storyAddText => 'Szöveg hozzáadása';

  @override
  String get storyEditText => 'Szöveg szerkesztése';

  @override
  String get storyTextHint => 'Írj valamit… a #hashtag koppintható';

  @override
  String get storyTextsHelp =>
      'Koppints a képre az íráshoz. Húzd az áthelyezéshez, csippents az átméretezéshez és a forgatáshoz, koppints a szövegre a szerkesztéshez.';

  @override
  String storyTextsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count szöveg',
      one: '1 szöveg',
      zero: 'Nincs szöveg',
    );
    return '$_temp0';
  }

  @override
  String get storyFontClassic => 'Klasszikus';

  @override
  String get storyFontBold => 'Félkövér';

  @override
  String get storyFontSerif => 'Serif';

  @override
  String get storyFontMono => 'Mono';

  @override
  String get storyFontItalic => 'Dőlt';

  @override
  String get storyTextBackground => 'Szöveg háttere';

  @override
  String get storyTextColor => 'Szöveg színe';

  @override
  String storyTextLimit(int max) {
    return 'Legfeljebb $max szöveget adhatsz hozzá.';
  }

  @override
  String get wotTitle => 'Bizalmi háló';

  @override
  String get wotEnable => 'A bizalmi háló mindig be van kapcsolva';

  @override
  String wotExplain(int min) {
    return 'Mindig be van kapcsolva. A Felfedezés csak ezt a hálózatot mutatja: téged, akiket követsz, és akit közülük legalább $min követ. Ugyanez a bizalmi háló elrejti mások hozzászólásait, értesítéseit, privát bejegyzéseit és üzeneteit. Ezen a telefonon készül a nyilvános követési listákból, amikor először nyitod meg az appot; később azt használja újra. Semmi sem megy szerverre.';
  }

  @override
  String get wotRefresh => 'Hálózat frissítése most';

  @override
  String get wotStatusIdle =>
      'Még nincs felépítve. Az app első megnyitásakor készül el.';

  @override
  String get wotBuildingTitle => 'A Felfedezés hírfolyam épül';

  @override
  String get wotBuildingBody =>
      'Beolvassuk, kiket követnek azok, akiket te követsz, és előkészítjük a Felfedezést.';

  @override
  String get wotDiscoverHint =>
      'Csak a bizalmi hálód: akiket követsz, és akiket közülük elegen követnek.';

  @override
  String get wotDiscoverSignIn =>
      'A Felfedezés a bizalmi hálódat mutatja. Belépés után először a Mialuna beolvassa, kiket követsz, és felépíti ezt a hírfolyamot. Később azt használja újra.';

  @override
  String get wotDiscoverEmpty => 'Még nincs bejegyzés a bizalmi hálódból.';

  @override
  String wotStatusDiscovering(int done, int total) {
    return 'Ellenőrizzük, kiket követnek a követéseid… $done / $total';
  }

  @override
  String wotStatusComplete(int direct, int indirect, Object when) {
    return 'A hálózatod: $direct ember, akit követsz, plusz $indirect, akit közülük elegen követnek. Frissítve: $when.';
  }

  @override
  String wotStatusFailed(Object reason) {
    return 'A hálózatod nem számítható ki: $reason';
  }

  @override
  String get wotNoFollows => 'még senkit sem követsz';

  @override
  String get messageRequests => 'Üzenetkérések';

  @override
  String messageRequestsSubtitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count beszélgetés a bizalmi hálón kívülről',
      one: '1 beszélgetés a bizalmi hálón kívülről',
    );
    return '$_temp0';
  }

  @override
  String get messageRequestsHint =>
      'A bizalmi hálón kívüli emberektől. Nem számítanak olvasatlannak. Válaszolj, hogy a beszélgetés a bejövőbe kerüljön.';

  @override
  String get storyViewsSetting => 'Mások lássák, hogy megnéztem a történetüket';

  @override
  String get storyViewsSettingExplain =>
      'Ha megnézel egy történetet, nyugta megy a szerzőjének, titkosítva, hogy csak ő olvashassa. A nevedet írja az övé mellé; a relays semmit sem lát. Ha nem kézbesíthető, megőrizzük, és később újrapróbáljuk. Kapcsold ki, ha úgy nézed, hogy senki se tudja: a még el nem küldött nyugták eldobódnak (a már kézbesítettet nem lehet visszavonni).';

  @override
  String storySeenBy(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count személy látta',
      one: '1 személy látta',
      zero: 'Még nincs megtekintés',
    );
    return '$_temp0';
  }

  @override
  String get storyViewsEmpty =>
      'Még senki sem nézte meg ezt a történetet, vagy a nyugták még nem értek el hozzád.';

  @override
  String get storyViewsHint =>
      'Csak azok küldenek nyugtát, akik engedik, ezért a valós szám magasabb lehet.';

  @override
  String get systemNotifications => 'Rendszerértesítések';

  @override
  String get systemNotificationsExplain =>
      'Értesítés a telefonodon, ha valami új érkezik, miközben a Mialuna a háttérben van. A privát üzenetek szövege sosem látszik, a zárképernyőn sem. Az Android hosszú háttérben tartás után szünetelteti az appokat, ezért az értesítések akkor jönnek, amíg a Mialuna még fut.';

  @override
  String get systemNotificationsBlocked =>
      'A Mialuna értesítései ki vannak kapcsolva a telefon beállításaiban.';

  @override
  String get systemNotificationsOpenSettings => 'Beállítások megnyitása';

  @override
  String get systemNotificationsBattery =>
      'Az Android néhány perccel a képernyő kikapcsolása után elaltatja az appokat, és az értesítések is leállnak. Hogy továbbra is megkapd őket, állítsd a Mialuna akkuhasználatát „Korlátlan” értékre.';

  @override
  String get systemNotificationsBatteryAction => 'Akku beállítások megnyitása';

  @override
  String get newFollowersSetting => 'Új követők mutatása';

  @override
  String get newFollowersSettingExplain =>
      'Az új követők megjelennek az Értesítésekben és a telefonodon. Kapcsold ki, ha elárasztanak követésekkel: a kedvelések, a hozzászólások és a zap továbbra is látszanak.';

  @override
  String get systemNotificationMessage => 'privát üzenetet küldött neked';

  @override
  String get systemNotificationNewMessage => 'Új privát üzenet';

  @override
  String get systemNotificationNew => 'Új értesítés';

  @override
  String get notificationChannelSocial =>
      'Reakciók, hozzászólások, zap és követők';

  @override
  String get notificationChannelMessages => 'Privát üzenetek';

  @override
  String get zapInvoiceMismatch =>
      'A számla nem egyezik a választott összeggel. Semmi sem lett kifizetve.';

  @override
  String get storyYourStory => 'A történeted';

  @override
  String get storyNew => 'Új történet';

  @override
  String get storyAddSemantics => 'Hozzáadás a történetedhez';

  @override
  String storyOwnRailLabel(int count, Object state) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count történet',
      one: '1 történet',
    );
    return 'A történeted, $_temp0, $state';
  }

  @override
  String get storyTextSize => 'Szövegméret';

  @override
  String get storyPickPrompt => 'Válassz fotót vagy videót a történetedhez';

  @override
  String get storyEditPhoto => 'Fotó szerkesztése';

  @override
  String get storyCaption => 'Képaláírás';

  @override
  String get storyDiscardTitle => 'Elveted ezt a történetet?';

  @override
  String get storyDiscard => 'Elvetés';

  @override
  String get storyShare => 'Megosztás';

  @override
  String get storyShared => 'Történet megosztva';

  @override
  String get deletePost => 'Törlés';

  @override
  String get deletePostTitle => 'Törlöd ezt a bejegyzést?';

  @override
  String get deleteStoryTitle => 'Törlöd ezt a történetet?';

  @override
  String get deletePostBody =>
      'A Mialuna megkéri a relays listát a törlésre és a médiaszervereket a fotók vagy a videó törlésére. Egy relay, amely figyelmen kívül hagyja a kérést, vagy aki már mentett egy másolatot, még megőrizheti.';

  @override
  String get deletePrivateBody =>
      'Egy szűk barátok bejegyzés nem vonható vissza a relays listáról. A Mialuna szól a barátaid appjainak, hogy vegyék le, és kéri a médiaszervert a titkosított fájlok törlésére. Egy barát, aki már mentett másolatot, még megőrizheti.';

  @override
  String get deletingPost => 'Törlés…';

  @override
  String get postDeleted => 'Törölve.';

  @override
  String get postWasDeleted => 'Ez a bejegyzés törölve lett.';

  @override
  String get deleteNotAllowed =>
      'Csak az a fiók törölheti, amelyik közzétette.';

  @override
  String deleteFailed(Object reason) {
    return 'Nem sikerült törölni: $reason';
  }

  @override
  String get deleteNoRelay =>
      'Egy relay sem fogadta el a törlési kérést, ezért még online van. Ellenőrizd a kapcsolatot, és próbáld újra.';

  @override
  String deleteMediaLeft(Object servers) {
    return 'A média nem távolítható el innen: $servers.';
  }

  @override
  String get deleteMediaNotAuthorized =>
      'Az aláíród nem engedélyezte a média eltávolítását, ezért a fájlok még a médiaszerveren vannak.';

  @override
  String deleteFriendsMissed(Object count) {
    return 'A szűk barátaid közül $count nem értesíthető, ezért a telefonjukon megmaradhat.';
  }

  @override
  String get storyCleanupSetting => 'Történeteim törlése lejáratkor';

  @override
  String get storyCleanupSettingExplain =>
      '24 óra után a Mialuna megkéri a relays listádat és a médiaszervereidet, hogy töröljék a történeteidet, a fotókkal és a videókkal együtt. Egy szerver, amely figyelmen kívül hagyja a kérést, vagy aki megőrzött egy másolatot, még birtokolhatja őket.';

  @override
  String storyCleanupWaiting(Object count) {
    return 'Az aláíródnak minden takarítást jóvá kell hagynia, ezért megvárja, amíg kéred. Lejárt történetek várakoznak: $count.';
  }

  @override
  String get storyCleanupNow => 'Törlés most';

  @override
  String get storyCleanupDone => 'A lejárt történetek törölve.';

  @override
  String get storyCleanupPartly =>
      'Néhányat még nem sikerült törölni; a Mialuna újra megpróbálja.';

  @override
  String get editorPro => 'Pro szerkesztő';

  @override
  String get editorModeBasic => 'Alap';

  @override
  String get editorModePro => 'Pro';

  @override
  String get toolCrop => 'Vágás';

  @override
  String get toolLight => 'Fény';

  @override
  String get toolColor => 'Szín';

  @override
  String get toolHsl => 'HSL';

  @override
  String get toolCurves => 'Görbék';

  @override
  String get toolEffects => 'Effektek';

  @override
  String get straighten => 'Kiegyenesítés';

  @override
  String get exposure => 'Expozíció';

  @override
  String get highlights => 'Csúcsfények';

  @override
  String get shadows => 'Árnyékok';

  @override
  String get whites => 'Fehérek';

  @override
  String get blacks => 'Feketék';

  @override
  String get temperature => 'Színhőmérséklet';

  @override
  String get tint => 'Árnyalat';

  @override
  String get vibrance => 'Élénkség';

  @override
  String get hue => 'Színezet';

  @override
  String get luminance => 'Fénysűrűség';

  @override
  String get colorRed => 'Piros';

  @override
  String get colorOrange => 'Narancs';

  @override
  String get colorYellow => 'Sárga';

  @override
  String get colorGreen => 'Zöld';

  @override
  String get colorAqua => 'Akvamarin';

  @override
  String get colorBlue => 'Kék';

  @override
  String get colorPurple => 'Lila';

  @override
  String get colorMagenta => 'Bíbor';

  @override
  String get curveHint =>
      'Húzz egy pontot a görbe alakításához, koppints új pontért, dupla koppintással törölheted.';

  @override
  String get sharpen => 'Élesítés';

  @override
  String get vignette => 'Vignettálás';

  @override
  String get grain => 'Szemcse';

  @override
  String get holdForOriginal =>
      'Tartsd lenyomva a fotót az eredetivel való összevetéshez.';

  @override
  String get showingOriginal => 'Eredeti';

  @override
  String get applyLookToAll => 'Ez a stílus minden fotóra';

  @override
  String get applyingEdits => 'Fotók feldolgozása…';

  @override
  String get choosePhotoToEdit => 'Válaszd ki a szerkesztendő fotót';
}
