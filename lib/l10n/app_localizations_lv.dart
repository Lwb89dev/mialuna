// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Latvian (`lv`).
class AppLocalizationsLv extends AppLocalizations {
  AppLocalizationsLv([String locale = 'lv']) : super(locale);

  @override
  String get syncUpToDate => 'Atjaunināts';

  @override
  String get syncFailed => 'Sinhronizēt neizdevās';

  @override
  String get relaysUpdatedFromProfile =>
      'Relays atjaunināti no tava profila (NIP-65)';

  @override
  String get relayListPublished => 'Relay saraksts publicēts';

  @override
  String get mediaServersUpdatedFromProfile =>
      'Multivides serveri atjaunināti no tava profila';

  @override
  String get tabHome => 'Home';

  @override
  String get tabDiscover => 'Atklāj';

  @override
  String get tabCreate => 'Veidot';

  @override
  String get tabReels => 'Reels';

  @override
  String get tabProfile => 'Profils';

  @override
  String get signInToUploadMedia => 'Piesakies, lai augšupielādētu multividi.';

  @override
  String get noMediaServer =>
      'Nav iestatīts multivides serveris. Pievieno to Iestatījumos.';

  @override
  String serverNoResponse(Object server) {
    return '$server: nav atbildes';
  }

  @override
  String serverUnreachable(Object server, Object error) {
    return '$server: nesasniedzams ($error)';
  }

  @override
  String uploadRejected(Object reason) {
    return 'Augšupielāde noraidīta — $reason';
  }

  @override
  String noServerAcceptedFile(Object reasons) {
    return 'Neviens serveris nepieņēma failu — $reasons';
  }

  @override
  String get blossomInvalidResponse => 'nederīga atbilde';

  @override
  String get blossomInvalidFileUrl => 'nederīga faila adrese';

  @override
  String get blossomServerAlteredFile => 'serveris izmainīja failu';

  @override
  String get blossomBadRequest => 'nederīgs pieprasījums';

  @override
  String get blossomUnauthorized => 'autorizācija liegta';

  @override
  String get blossomPaymentRequired => 'nepieciešams maksājums';

  @override
  String get blossomForbidden => 'nav atļauts';

  @override
  String get blossomLengthRequired => 'trūkst izmēra';

  @override
  String get blossomTooLarge => 'fails par lielu';

  @override
  String get blossomUnsupportedType => 'formāts nav pieņemts';

  @override
  String get blossomTooManyRequests => 'pārāk daudz pieprasījumu';

  @override
  String get blossomServerError => 'servera kļūda';

  @override
  String get cipherInvalidKey => 'Nederīga atslēga';

  @override
  String get cipherTruncated => 'Šifrētais fails ir aprauts';

  @override
  String get cipherMismatch => 'Fails neatbilst atslēgai: izmainīts vai bojāts';

  @override
  String get sanitizeHeifNeedsAsync =>
      'HEIC/AVIF formāts: konvertēšanai vajag sanitizeAsync';

  @override
  String get sanitizeWebmUnsupported =>
      'WebM/MKV video netiek atbalstīts: lieto MP4 vai MOV, lai metadatus varētu noņemt pirms augšupielādes.';

  @override
  String get sanitizeUnknownFormat =>
      'Neatpazīts faila formāts: JPEG/PNG/WebP/GIF foto vai MP4/MOV video.';

  @override
  String sanitizeLeftovers(Object items) {
    return 'Neizdevās noņemt visus metadatus ($items): fails nav augšupielādēts.';
  }

  @override
  String sanitizeProcessingFailed(Object error) {
    return 'Neizdevās apstrādāt failu: $error';
  }

  @override
  String get sanitizeJpegInvalid => 'Nederīgs JPEG';

  @override
  String get sanitizeJpegTruncated => 'Aprauts JPEG';

  @override
  String get sanitizeJpegNoSize => 'JPEG bez izmēriem';

  @override
  String get sanitizeJpegUndecodable => 'JPEG nevar atkodēt';

  @override
  String get sanitizePngTruncated => 'Aprauts PNG';

  @override
  String get sanitizePngInvalid => 'Nederīgs PNG';

  @override
  String get sanitizeGifInvalid => 'Nederīgs GIF';

  @override
  String get sanitizeGifTruncated => 'Aprauts GIF';

  @override
  String get sanitizeWebpTruncated => 'Aprauts WebP';

  @override
  String get sanitizeWebpInvalid => 'Nederīgs WebP';

  @override
  String get sanitizeMp4Invalid => 'Nederīgs MP4/MOV video';

  @override
  String get sanitizeConversionFailed => 'Konvertēšana neizdevās';

  @override
  String get sanitizeHeifUnsupported =>
      'Šo formātu (HEIC/AVIF) šajā ierīcē nevar konvertēt. Izvēlies JPEG vai PNG foto.';

  @override
  String get privateMediaNotEncrypted => 'Multivide nav šifrēta';

  @override
  String serverReplied(Object status) {
    return 'Serveris atbildēja $status';
  }

  @override
  String get fileTooLarge => 'Fails par lielu';

  @override
  String get serverFileNotOriginal => 'Fails serverī nav oriģināls';

  @override
  String get contentMismatch => 'Saturs nesakrīt';

  @override
  String get mediaUnreachable => 'Multivide nesasniedzama';

  @override
  String get amberInvalidKey => 'Amber atgrieza nederīgu atslēgu';

  @override
  String get amberNoKey => 'Amber neatgrieza atslēgu';

  @override
  String get amberRequestRejected => 'Pieprasījums noraidīts Amber';

  @override
  String get amberAndroidOnly => 'Amber pieejams tikai Android';

  @override
  String get amberEmptySignature => 'Amber atgrieza tukšu parakstu';

  @override
  String get amberSignRejected => 'Paraksts noraidīts Amber';

  @override
  String get amberTimeout => 'Amber neatbildēja laikā';

  @override
  String get amberEmptyResponse => 'Amber atgrieza tukšu atbildi';

  @override
  String get bunkerInvalidUrl => 'Nederīgs bunker URL';

  @override
  String get bunkerNoRelay => 'bunker nenorāda nevienu relay';

  @override
  String get bunkerWebAuth =>
      'bunker prasa tīmekļa autorizāciju (auth_url netiek atbalstīts)';

  @override
  String get bunkerInvalidKey => 'bunker neatgrieza derīgu atslēgu';

  @override
  String get signerInvalidResponse =>
      'Parakstītājs atgrieza nederīgu parakstītu notikumu';

  @override
  String get bunkerTimeout => 'Bunker neatbildēja laikā';

  @override
  String get nwcInvalidUri => 'Nederīgs NWC URI';

  @override
  String get nwcNoRelay => 'NWC URI nenorāda nevienu relay';

  @override
  String get nwcNoSecret => 'NWC URI nesatur derīgu slepenu atslēgu';

  @override
  String get nwcTimeout => 'Maks neatbildēja laikā';

  @override
  String get signerNoPrivateMessages =>
      'Šis pieteikšanās veids neatbalsta privātās ziņas';

  @override
  String get zapNotSupported => 'Šī adrese neatbalsta Nostr zaps';

  @override
  String zapAmountOutOfRange(Object min, Object max) {
    return 'Summa ārpus diapazona ($min–$max sats)';
  }

  @override
  String get commentNotSent => 'Komentārs nav nosūtīts. Mēģini vēlāk.';

  @override
  String get comments => 'Komentāri';

  @override
  String get noCommentsYet => 'Komentāru vēl nav.';

  @override
  String get signInToComment => 'Piesakies, lai komentētu.';

  @override
  String get addComment => 'Pievieno komentāru…';

  @override
  String get signInToPublish => 'Piesakies, lai publicētu.';

  @override
  String get addMediaFirst =>
      'Pirms publicēšanas pievieno vismaz vienu foto vai video.';

  @override
  String get removingMetadata => 'Noņem metadatus…';

  @override
  String uploadingProgress(Object current, Object total) {
    return 'Augšupielādē $current no $total…';
  }

  @override
  String get creatingPreview => 'Veido priekšskatījumu…';

  @override
  String uploadFailed(Object error) {
    return 'Augšupielāde neizdevās: $error';
  }

  @override
  String get publishing => 'Publicē…';

  @override
  String noRelayAcceptedPost(Object reason) {
    return 'Neviens relay nepieņēma ierakstu$reason. Saturs paliek melnrakstos.';
  }

  @override
  String get privateNeedsKeySigner =>
      'Šis pieteikšanās veids neatbalsta privātu saturu. Lieto Amber, bunker vai vietējo atslēgu.';

  @override
  String get closeFriendsListEmptyAddSomeone =>
      'Tavs tuvo draugu saraksts ir tukšs: kādu pievieno.';

  @override
  String get fileOver100Mb =>
      'Fails pārsniedz 100 MB: tā ir tuvo draugu robeža (viss tiek šifrēts tavā tālrunī).';

  @override
  String get encryptingOnPhone => 'Šifrē tālrunī…';

  @override
  String noServerAcceptedEncrypted(Object details) {
    return 'Neviens tavs multivides serveris nepieņēma šifrēto failu. Atklātā veidā tas netiek publicēts. Iestatījumos pievieno serveri, kas pieņem šifrētus failus (piemēram, cdn.hzrd149.com). $details';
  }

  @override
  String get sendingToFriends => 'Sūta draugiem…';

  @override
  String sendingToFriendsProgress(Object done, Object total) {
    return 'Sūta draugiem $done/$total…';
  }

  @override
  String noFriendReceivedPost(Object reason) {
    return 'Neviens draugs nesaņēma ierakstu$reason. Saturs paliek melnrakstos.';
  }

  @override
  String sentToCloseFriends(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Nosūtīts $count tuviem draugiem 🔒',
      one: 'Nosūtīts 1 tuvam draugam 🔒',
    );
    return '$_temp0';
  }

  @override
  String sentToFriendsWithMisses(int delivered, Object missed) {
    String _temp0 = intl.Intl.pluralLogic(
      delivered,
      locale: localeName,
      other: 'Nosūtīts $delivered draugiem.',
      one: 'Nosūtīts 1 draugam.',
    );
    return '$_temp0 $missed nesaņēma (privātās ziņas ir izslēgtas).';
  }

  @override
  String get altText => 'Alt teksts';

  @override
  String get altTextHint => 'Apraksti saturu tiem, kas to neredz…';

  @override
  String get cancel => 'Atcelt';

  @override
  String get save => 'Saglabāt';

  @override
  String get momentPublished => 'Mirklis publicēts ✨';

  @override
  String get newMoment => 'Jauns mirklis';

  @override
  String get publish => 'Publicēt';

  @override
  String get guestMode => 'Viesa režīms';

  @override
  String get signInToPostMoments => 'Piesakies, lai publicētu savus mirkļus.';

  @override
  String get signIn => 'Pieteikties';

  @override
  String get kindPhoto => 'Foto';

  @override
  String get kindVideo => 'Video';

  @override
  String get kindReel => 'Reel';

  @override
  String get kindStory => 'Stāsts';

  @override
  String get storyExpiryNote =>
      'Stāsti beidzas pēc 24 stundām tajos relay, kas ievēro NIP-40, bet citi tos joprojām var saglabāt vai arhivēt.';

  @override
  String get fromGallery => 'No galerijas';

  @override
  String get galleryLongPressVideo => 'Galerija (ilgs spiediens — video)';

  @override
  String get addVideo => 'Pievienot video';

  @override
  String get camera => 'Kamera';

  @override
  String get exifRemovedNote =>
      'Atrašanās vietas metadati (EXIF) tiek noņemti automātiski.';

  @override
  String get writeCaption => 'Raksti parakstu…';

  @override
  String get privatePostNote =>
      'Privāts ieraksts: nav publisku tēmturu, meklēšanā to neatrast.';

  @override
  String willPublishAs(Object caption) {
    return 'Tiks publicēts kā: \"$caption\"';
  }

  @override
  String get tapThumbnailForAlt =>
      'Pieskaries sīktēlam, lai pievienotu alt tekstu.';

  @override
  String get sensitiveContent => 'Jutīgs saturs';

  @override
  String get sensitiveContentNote =>
      'Ieraksts būs paslēpts aiz brīdinājuma (NIP-36).';

  @override
  String get uploadingMedia => 'Augšupielādē multividi…';

  @override
  String get audiencePublic => 'Publisks';

  @override
  String get closeFriends => 'Tuvi draugi';

  @override
  String get signerCannotPublishCloseFriends =>
      'Ar šo pieteikšanos nevari publicēt tuviem draugiem: lieto Amber, bunker vai vietējo atslēgu.';

  @override
  String get closeFriendsEmptyPrompt =>
      'Tavs saraksts ir tukšs: pievieno tos, kas var redzēt šo ierakstu.';

  @override
  String onlyYourCloseFriendsSee(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'To redzēs tikai tavi $count tuvi draugi. Foto un video tiek šifrēti tālrunī pirms augšupielādes.',
      one: 'To redzēs tikai tavs 1 tuvs draugs. Foto un video tiek šifrēti tālrunī pirms augšupielādes.',
    );
    return '$_temp0';
  }

  @override
  String get addFriends => 'Pievienot draugus';

  @override
  String get manageList => 'Pārvaldīt sarakstu';

  @override
  String get edit => 'Rediģēt';

  @override
  String get reset => 'Atiestatīt';

  @override
  String get apply => 'Pielietot';

  @override
  String get cropFree => 'Brīvs';

  @override
  String get cropOriginal => 'Oriģināls';

  @override
  String get rotate => 'Pagriezt';

  @override
  String get flip => 'Apvērst';

  @override
  String get brightness => 'Gaišums';

  @override
  String get contrast => 'Kontrasts';

  @override
  String get saturation => 'Piesātinājums';

  @override
  String postsByAuthor(Object author) {
    return '$author ieraksti…';
  }

  @override
  String get searchHint => 'Meklē cilvēkus, tēmturus vai vārdus…';

  @override
  String get clear => 'Notīrīt';

  @override
  String get recent => 'Jaunākie';

  @override
  String get searchDependsOnRelays =>
      'Meklēšana ir atkarīga no iestatītajiem relays: rezultāti var būt nepilnīgi.';

  @override
  String get recentPostsEverywhere =>
      'Jaunākie ieraksti no visa tīkla, arī no tiem, kam neseko.';

  @override
  String get noResultsOnRelays => 'Iestatītajos relays rezultātu nav.';

  @override
  String get noRecentPostsFromFollowed =>
      'Nav jaunāku ierakstu no cilvēkiem, kam seko.';

  @override
  String get noMomentsFound =>
      'Relays nav atrasti mirkļi. Pārbaudi savienojumu.';

  @override
  String get loadFailed => 'Ielāde neizdevās';

  @override
  String get notifications => 'Paziņojumi';

  @override
  String get messages => 'Ziņas';

  @override
  String get homeEmptyFollowsNobody =>
      'Šeit parādās ieraksti no cilvēkiem, kam seko.\nTu vēl nevienam neseko: atklāj interesantus cilvēkus un profilus.';

  @override
  String get discoverPeople => 'Atklāj cilvēkus';

  @override
  String get homeEmpty =>
      'Vēl nav mirkļu.\nPavelc uz leju, lai atsvaidzinātu, vai publicē savu pirmo kadru.';

  @override
  String get retry => 'Mēģināt vēl';

  @override
  String get seenEverything => 'Pagaidām viss ir redzēts ✨';

  @override
  String get discoverMoreProfiles => 'Atklāj vairāk profilu';

  @override
  String get feedFollowing => 'Sekotie';

  @override
  String get signInToSeeFollowed =>
      'Piesakies, lai redzētu ierakstus no cilvēkiem, kam seko';

  @override
  String get videoPreview => 'Video priekšskatījums';

  @override
  String get cannotOpenPrivateVideo => 'Nevar atvērt privāto video';

  @override
  String get cannotPlayVideo => 'Nevar atskaņot video';

  @override
  String get pauseVideo => 'Pauzēt video';

  @override
  String get playVideo => 'Atskaņot video';

  @override
  String errorTapToRetry(Object error) {
    return '$error — pieskaries, lai mēģinātu vēl';
  }

  @override
  String get soundOn => 'Ieslēgt skaņu';

  @override
  String get soundOff => 'Izslēgt skaņu';

  @override
  String get postImage => 'Ieraksta attēls';

  @override
  String get imageUnavailable => 'Attēls nav pieejams';

  @override
  String errorTapToRetryNewline(Object message) {
    return '$message\nPieskaries, lai mēģinātu vēl';
  }

  @override
  String get cannotOpenPrivateContent => 'Nevar atvērt šo privāto saturu';

  @override
  String get privateImage => 'Privāts attēls';

  @override
  String get invalidImage => 'Nederīgs attēls';

  @override
  String get more => 'Vairāk';

  @override
  String get removeFromSaved => 'Noņemt no saglabātajiem';

  @override
  String get copyLink => 'Kopēt saiti';

  @override
  String get muteAuthor => 'Apklusināt autoru';

  @override
  String get blockAuthor => 'Bloķēt autoru';

  @override
  String get report => 'Ziņot';

  @override
  String get like => 'Patīk';

  @override
  String get sendInMessage => 'Sūtīt ziņā';

  @override
  String get zapOptional => 'Zap (neobligāti)';

  @override
  String get closeFriendsOnlyNote =>
      'Redz tikai tuvi draugi. Patīk un atbildes nonāk tikai pie autora.';

  @override
  String get likeFailed => 'Neizdevās nosūtīt patīk';

  @override
  String get nostrLinkCopied => 'Nostr saite nokopēta starpliktuvē';

  @override
  String get authorMuted => 'Autors apklusināts';

  @override
  String get authorBlocked => 'Autors nobloķēts';

  @override
  String get reportSent => 'Ziņojums nosūtīts (NIP-56)';

  @override
  String get signInToReport => 'Piesakies, lai ziņotu';

  @override
  String minutesAgo(Object minutes) {
    return '$minutes min atpakaļ';
  }

  @override
  String get show => 'Rādīt';

  @override
  String get chatEmptyHint =>
      'Uzraksti pirmo ziņu.\nTā ir šifrēta: to redz tikai tu un otrs.';

  @override
  String get messageHint => 'Ziņa…';

  @override
  String get send => 'Sūtīt';

  @override
  String get notSentSuffix => ' nav nosūtīta';

  @override
  String get contentUnavailable =>
      'Saturs nav pieejams (beidzies vai nav atrasts relays)';

  @override
  String get signInToSendPrivateMessages =>
      'Piesakies, lai sūtītu privātās ziņas.';

  @override
  String get cannotMessageYourself => 'Sev rakstīt nevari.';

  @override
  String get recipientNoPrivateMessages =>
      'Šis cilvēks vēl nav ieslēdzis privātās ziņas.';

  @override
  String noRecipientRelayAccepted(Object reason) {
    return 'Neviens saņēmēja relay nepieņēma ziņu$reason.';
  }

  @override
  String sendFailed(Object error) {
    return 'Sūtīšana neizdevās: $error';
  }

  @override
  String get signInToReadMessages =>
      'Piesakies, lai lasītu un sūtītu privātās ziņas.';

  @override
  String get signerNoPrivateMessagesLong =>
      'Ar šo pieteikšanos privātās ziņas nevar lietot. Piesakies ar Amber, bunker vai vietējo atslēgu.';

  @override
  String get inboxEmpty =>
      'Sarunu nav.\nPieskaries zīmulim, lai kādam rakstītu, vai pārsūti mirkli ar ✈ ikonu zem katra ieraksta.';

  @override
  String get newMessage => 'Jauna ziņa';

  @override
  String get privateMessagesEnabled => 'Privātās ziņas ir ieslēgtas';

  @override
  String get enableMessagesFailed => 'Neizdevās tās ieslēgt. Mēģini vēl.';

  @override
  String get enablePrivateMessages => 'Ieslēgt privātās ziņas';

  @override
  String enablePrivateMessagesExplain(Object count) {
    return 'Lai saņemtu ziņas, jānorāda, uz kuriem relays tām jānonāk. Tiek publicēts īss saraksts (NIP-17) ar $count noklusējuma relays: vēlāk vari to mainīt. Ziņas paliek šifrētas: relays neredz ne to, kas raksta, ne tekstu.';
  }

  @override
  String get turnOn => 'Ieslēgt';

  @override
  String get searchByNameOrUsername => 'Meklē pēc vārda vai lietotājvārda';

  @override
  String get searching => 'Meklē…';

  @override
  String get noOneWithNameHint =>
      'Nav neviena ar šādu vārdu. Mēģini mazāk burtu vai adresi kā name@domain.com.';

  @override
  String get sent => 'Nosūtīts';

  @override
  String sentToPeople(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Nosūtīts $count cilvēkiem',
      one: 'Nosūtīts 1 cilvēkam',
    );
    return '$_temp0';
  }

  @override
  String sentToPeopleWithFailure(int count, Object failure) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Nosūtīts $count cilvēkiem. $failure',
      one: 'Nosūtīts 1 cilvēkam. $failure',
    );
    return '$_temp0';
  }

  @override
  String get signerNoPrivateMessagesShort =>
      'Ar šo pieteikšanos privātās ziņas lietot nevari.';

  @override
  String get followToStartOrSearch =>
      'Vispirms kādam seko vai meklē pēc vārda.';

  @override
  String get addMessage => 'Pievieno ziņu…';

  @override
  String sendWithCount(Object count) {
    return 'Sūtīt ($count)';
  }

  @override
  String get linkCopied => 'Saite nokopēta starpliktuvē';

  @override
  String get noNotifications => 'Paziņojumu pašlaik nav.';

  @override
  String get notificationsDependOnRelays =>
      'Paziņojumi ir atkarīgi no relays: tie var būt nepilnīgi.';

  @override
  String get reactedToYourMoment => 'reaģēja uz tavu mirkli';

  @override
  String commentedText(Object text) {
    return 'komentēja: $text';
  }

  @override
  String sentYouSats(Object sats, Object comment) {
    return 'nosūtīja tev $sats sats$comment';
  }

  @override
  String get sentYouZap => 'nosūtīja tev zap';

  @override
  String get startedFollowingYou => 'sāka tev sekot';

  @override
  String get amberNotFound => 'Amber nav atrasts';

  @override
  String get amberExplain =>
      'Amber ir Nostr parakstītājs, kas glabā tavu privāto atslēgu ārpus Mialuna. Instalē to un mēģini vēl.';

  @override
  String get downloadFromFdroid => 'Lejupielādēt no F-Droid';

  @override
  String get continueWithAmber => 'Turpināt ar Amber';

  @override
  String get amberRecommended =>
      'Ieteicams: tava privātā atslēga paliek drošībā Amber.';

  @override
  String get amberNotDetected =>
      'Amber nav atrasts: instalē to ieteiktajai pieteikšanai.';

  @override
  String get exploreWithoutAccount => 'Pārlūkot bez konta';

  @override
  String get remoteBunker => 'Attālināts bunker (NIP-46)';

  @override
  String get invalidBunkerUrlDot => 'Nederīgs bunker URL.';

  @override
  String get connectBunker => 'Savienot bunker';

  @override
  String get advancedNsec => 'Paplašināta pieteikšanās (nsec)';

  @override
  String get nsecWarning =>
      'Brīdinājums: privātās atslēgas ielīmēšana ir riskanta. Nekad to nevienam nedod. Android izvēlies Amber.';

  @override
  String get invalidNsec => 'Nederīga nsec atslēga.';

  @override
  String get signInWithNsec => 'Pieteikties ar nsec';

  @override
  String get tagline => 'Tavi mirkļi, zem tā paša mēness.';

  @override
  String get skip => 'Izlaist';

  @override
  String get permissionsAndWallet => 'Atļaujas un maks';

  @override
  String get permissionsExplain =>
      'Tās tikai ļauj publicēt un saņemt paziņojumus. Vari tās jebkurā laikā mainīt sistēmas iestatījumos.';

  @override
  String get photosAndVideos => 'Foto un video';

  @override
  String get toUploadYourMoments => 'Lai augšupielādētu savus mirkļus';

  @override
  String get allow => 'Atļaut';

  @override
  String get reactionsCommentsZaps => 'Reakcijas, komentāri un zaps';

  @override
  String get lightningWalletOptional => 'Lightning maks (neobligāti)';

  @override
  String get nwcExplain =>
      'Pievieno Nostr Wallet Connect maku, lai sūtītu zaps, neizejot no lietotnes.';

  @override
  String get walletConnected => 'Maks pievienots';

  @override
  String get disconnect => 'Atvienot';

  @override
  String get connectWallet => 'Pievienot maku';

  @override
  String get getStarted => 'Sākt';

  @override
  String get welcome1 =>
      'Mialuna ir vizuāls sociālais tīkls: foto, video, Reels un stāsti — nekad tikai teksta ieraksti.';

  @override
  String get welcome2 =>
      'Tā darbojas ar Nostr, atvērtu protokolu: tava identitāte ir atslēga, kas pieder tev, ne konts, ko uzņēmums var atņemt. Nav reklāmu, nav izsekotāju, nav centrālo serveru.';

  @override
  String get welcome3 =>
      'Dalies ar savu gaismu ar cilvēkiem visur, no jebkuras lietotnes, kas runā tajā pašā atvērtajā valodā.';

  @override
  String onboardingWot(int min) {
    return 'Uzticības tīkls vienmēr ir ieslēgts. Pirmo reizi atverot Mialuna, tā nolasa, kam tu seko, un no tā tīkla veido Atklāj plūsmu: tu, cilvēki, kam seko, un tie, kam seko vismaz $min no tiem. Nākamajās reizēs, atverot lietotni, šī plūsma jau ir gatava.';
  }

  @override
  String get publicAndPrivate => 'Publiskais un privātais';

  @override
  String get publicAndPrivateIntro =>
      'Mialuna ir veidota uz Nostr, atvērta tīkla. Ko publicē, ir publisks: ieraksti, foto un video paliek redzami ikvienam ar saiti, arī ārpus Mialuna.';

  @override
  String get closeFriendsExplain1 =>
      'Tikai cilvēki šajā sarakstā saņem tavus \"Tuvi draugi\" ierakstus, stāstus un video. Saraksts ir ierakstā; katru reizi to nav jāizvēlas.';

  @override
  String get closeFriendsExplain2 =>
      'Foto un video tiek šifrēti tālrunī pirms augšupielādes. Failu serveri (Blossom) paši neko nešifrē: tāpēc to dara Mialuna, un serveris redz tikai nelasāmus datus. Kas atrod faila adresi, to nevar atvērt.';

  @override
  String get closeFriendsExplain3 =>
      'Tā nav absolūta garantija: kas saņem ierakstu, var uzņemt ekrānuzņēmumu, un drauga noņemšana attiecas tikai uz turpmākajiem ierakstiem.';

  @override
  String get closeFriendsExplain4 =>
      'Katram draugam jālieto Mialuna ar ieslēgtām privātajām ziņām. Citi Nostr klienti šos ierakstus nerāda.';

  @override
  String get closeFriendsExplain5 =>
      'Publiski ieraksti paliek publiski: to failus redz ikviens ar saiti.';

  @override
  String get closeFriendsExplain6 =>
      'Ja neviens tavs serveris nepieņem šifrētus failus, ieraksts netiek publicēts: nekad atklātā veidā.';

  @override
  String get addToCloseFriends => 'Pievienot tuviem draugiem';

  @override
  String maxFriendsReached(Object max, Object added) {
    return 'Robeža — $max draugi: pievienoti $added.';
  }

  @override
  String get add => 'Pievienot';

  @override
  String get signInToCreateList => 'Piesakies, lai izveidotu savu sarakstu.';

  @override
  String get signerNoCloseFriends =>
      'Ar šo pieteikšanos tuvus draugus lietot nevari. Piesakies ar Amber, bunker vai vietējo atslēgu.';

  @override
  String peopleOfMax(Object count, Object max) {
    return '$count / $max cilvēku';
  }

  @override
  String get noOneYet => 'Vēl neviena nav.';

  @override
  String get addPeople => 'Pievienot cilvēkus';

  @override
  String get friendNoPrivateMessagesWarning =>
      'Viņi nav ieslēguši privātās ziņas: tavi ieraksti viņiem nepienāks';

  @override
  String get removeFromList => 'Noņemt no saraksta';

  @override
  String get noOneWithThisName => 'Nav neviena ar šādu vārdu.';

  @override
  String get signInToSendPrivateContent =>
      'Piesakies, lai sūtītu privātu saturu.';

  @override
  String get reasonNoPrivateMessages => 'nav ieslēdzis privātās ziņas';

  @override
  String get reasonNoRelayAnswered => 'neviens relay neatbildēja';

  @override
  String get profileUpdated => 'Profils atjaunināts';

  @override
  String get noRelayAcceptedRetry => 'Neviens relay nepieņēma. Mēģini vēlāk.';

  @override
  String get editProfile => 'Rediģēt profilu';

  @override
  String get fieldName => 'Vārds';

  @override
  String get fieldBio => 'Apraksts';

  @override
  String get fieldAvatarUrl => 'Avatara URL';

  @override
  String get fieldNip05 => 'NIP-05 (piem., you@example.com)';

  @override
  String get browsingAsGuest => 'Tu pārlūko kā viesis';

  @override
  String get signInToInteract =>
      'Piesakies, lai publicētu, sekotu un sazinātos.';

  @override
  String get settings => 'Iestatījumi';

  @override
  String get signOut => 'Izrakstīties';

  @override
  String get npubCopied => 'npub nokopēts';

  @override
  String get copyNpub => 'Kopēt npub';

  @override
  String get mute => 'Apklusināt';

  @override
  String get block => 'Bloķēt';

  @override
  String get posts => 'Ieraksti';

  @override
  String get saved => 'Saglabātie';

  @override
  String get nothingPublishedYet => 'Vēl nekas nav publicēts.';

  @override
  String get noPostsOnRelays => 'Relays ieraksti nav atrasti.';

  @override
  String get noReelsPublished => 'Nav publicētu reels.';

  @override
  String get noReelsOnRelays => 'Relays reels nav atrasti.';

  @override
  String get noSavedPosts => 'Nav saglabātu ierakstu.';

  @override
  String get followingButton => 'Seko';

  @override
  String get follow => 'Sekot';

  @override
  String get messageButton => 'Ziņa';

  @override
  String get loginLocalKey => 'Vietējā atslēga';

  @override
  String get loginGuest => 'Viesis';

  @override
  String get followUpdateFailed =>
      'Pašlaik neizdevās atjaunināt tos, kam seko. Mēģini vēl.';

  @override
  String get noReelsComeBack => 'Relays reels nav atrasti.\nAtnāc drīz!';

  @override
  String get followUpdateFailedShort =>
      'Pašlaik neizdevās atjaunināt tos, kam seko';

  @override
  String get needOneReadRelay => 'Vajag vismaz vienu lasīšanas relay.';

  @override
  String get listSavedLocally =>
      'Saraksts saglabāts šajā ierīcē, nav publicēts.';

  @override
  String get noRelayAcceptedList =>
      'Neviens relay nepieņēma sarakstu: vēlāk mēģinās vēlreiz.';

  @override
  String relayListPublishedTo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Relay saraksts publicēts $count relays',
      one: 'Relay saraksts publicēts 1 relay',
    );
    return '$_temp0';
  }

  @override
  String get mediaServersUpdated => 'Multivides serveri atjaunināti';

  @override
  String get appearance => 'Izskats';

  @override
  String get publishingSettings => 'Publicēšana';

  @override
  String get addMialunaHashtag => 'Pievienot #mialuna';

  @override
  String get addMialunaHashtagNote =>
      'Pievieno oficiālo tēmturi publiskiem ierakstiem un stāstiem. Vari to jebkurā laikā izslēgt.';

  @override
  String get themeLight => 'Gaiša';

  @override
  String get themeDark => 'Tumša';

  @override
  String get themeSystem => 'Sistēmas';

  @override
  String get relays => 'Relays';

  @override
  String get relaysExplainSignedOut =>
      'Relays glabā un izplata saturu. Piesakies, lai automātiski lietotu savu sarakstu (NIP-65).';

  @override
  String get relaysExplainSynced =>
      'Saraksts ir sinhronizēts ar tavu Nostr profilu (NIP-65): katra izmaiņa tiek publicēta un darbojas visās tavās lietotnēs.';

  @override
  String get syncing => 'Sinhronizē…';

  @override
  String get waitingFirstSync => 'Gaida pirmo sinhronizāciju';

  @override
  String get syncNow => 'Sinhronizēt tagad';

  @override
  String get addRelay => 'Pievienot relay';

  @override
  String get restoreDefaultRelays => 'Atjaunot noklusējuma relays';

  @override
  String get createYourList => 'Izveidot savu sarakstu';

  @override
  String peopleCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cilvēki',
      one: '1 cilvēks',
    );
    return '$_temp0';
  }

  @override
  String get closeFriendsSettingsNote =>
      'Ieraksti, stāsti un video redzami tikai viņiem, ar šifrētiem foto un video.';

  @override
  String get mediaServersBlossom => 'Multivides serveri (Blossom)';

  @override
  String get mediaServersExplain =>
      'Foto un video tiek augšupielādēti tikai šajos serveros, norādītajā secībā: uzvar pirmais, kas tos pieņem. EXIF un atrašanās vieta tiek noņemti pirms augšupielādes.';

  @override
  String get primary => 'Galvenais';

  @override
  String get makePrimary => 'Padarīt par galveno';

  @override
  String get remove => 'Noņemt';

  @override
  String get addServer => 'Pievienot serveri';

  @override
  String get moderation => 'Moderēšana';

  @override
  String get moderationExplain =>
      'Apklusinātie autori un paslēptie tēmturi tiek sinhronizēti ar NIP-51. Bloķētie autori paliek tikai šajā ierīcē.';

  @override
  String get mutedAuthors => 'Apklusinātie autori';

  @override
  String get noMutedAuthors => 'Nav apklusinātu autoru';

  @override
  String get blockedAuthors => 'Bloķētie autori';

  @override
  String get noBlockedAuthors => 'Nav bloķētu autoru';

  @override
  String get hiddenHashtags => 'Paslēptie tēmturi';

  @override
  String get noHiddenHashtags => 'Nav paslēptu tēmturu';

  @override
  String get hashtagToHide => '#hashtag slēpšanai';

  @override
  String get storage => 'Krātuve';

  @override
  String get clearCache => 'Notīrīt notikumu kešatmiņu un melnrakstus';

  @override
  String get cacheCleared => 'Kešatmiņa notīrīta';

  @override
  String get reviewIntro => 'Pārskatīt ievadu';

  @override
  String get reviewIntroSubtitle =>
      'Kas ir publisks, kas privāts un tuvo draugu robežas.';

  @override
  String noLightningWalletCopied(Object address) {
    return 'Lightning maks nav atrasts: adrese nokopēta ($address)';
  }

  @override
  String get about => 'Par';

  @override
  String aboutText(Object version) {
    return 'Mialuna $version — Tavi mirkļi, zem tā paša mēness.\nAtvērts kods (MIT). github.com/Lwb89dev/mialuna';
  }

  @override
  String get invalidRelayAddress => 'Nederīga adrese: lieto wss://…';

  @override
  String get invalidServerAddress => 'Nederīga adrese: lieto https://…';

  @override
  String get relayRead => 'Lasīt';

  @override
  String get relayWrite => 'Rakstīt';

  @override
  String get support => 'Atbalsts';

  @override
  String get supportText =>
      'Mialuna ir bezmaksas, bez reklāmām un tevi neizseko. Ja patīk, vari nosūtīt dažus sats caur Lightning Network.';

  @override
  String get donateWithLightning => 'Ziedot ar Lightning';

  @override
  String get authorNoZaps => 'Šis autors nepieņem zaps';

  @override
  String get sendZap => 'Sūtīt zap ⚡';

  @override
  String get amountInSats => 'Summa (sats)';

  @override
  String minMaxSats(Object min, Object max) {
    return 'min $min – max $max';
  }

  @override
  String get zap => 'Zap';

  @override
  String get signInToZap => 'Piesakies, lai sūtītu zaps';

  @override
  String zapSent(Object sats) {
    return 'Zap $sats sats nosūtīts ⚡';
  }

  @override
  String nwcPaymentFailed(Object error) {
    return 'NWC maksājums neizdevās: $error';
  }

  @override
  String get noLightningWallet => 'Lightning maks nav atrasts';

  @override
  String storiesRailLabel(Object state) {
    return 'Stāsti, $state';
  }

  @override
  String get close => 'Aizvērt';

  @override
  String hoursAgo(int hours) {
    return '$hours st. atpakaļ';
  }

  @override
  String daysAgo(int days) {
    return '$days d. atpakaļ';
  }

  @override
  String get now => 'tagad';

  @override
  String get youPrefix => 'Tu: ';

  @override
  String get storiesStateUnseen => 'jauns';

  @override
  String get storiesStateSeen => 'redzēts';

  @override
  String weekdayShort(String day) {
    String _temp0 = intl.Intl.selectLogic(day, {
      'mon': 'Pr',
      'tue': 'Ot',
      'wed': 'Tr',
      'thu': 'Ce',
      'fri': 'Pk',
      'sat': 'Se',
      'sun': 'Sv',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get sharedAMoment => 'Padalījās ar mirkli';

  @override
  String get blossomOtherError => 'kļūda';

  @override
  String get languageTitle => 'Valoda';

  @override
  String get languageSystem => 'Sistēmas';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageItalian => 'Italiano';

  @override
  String get cannotEditPhoto => 'Šo foto šeit nevar rediģēt.';

  @override
  String notificationsNew(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count jauni paziņojumi',
      one: '1 jauns paziņojums',
    );
    return '$_temp0';
  }

  @override
  String messagesUnread(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count nelasītas ziņas',
      one: '1 nelasīta ziņa',
    );
    return '$_temp0';
  }

  @override
  String get done => 'Gatavs';

  @override
  String get storyAddText => 'Pievienot tekstu';

  @override
  String get storyEditText => 'Rediģēt tekstu';

  @override
  String get storyTextHint => 'Raksti kaut ko… #hashtags var nospiest';

  @override
  String get storyTextsHelp =>
      'Pieskaries attēlam, lai rakstītu. Velc, lai pārvietotu, savelc, lai mainītu izmēru un pagrieztu, pieskaries tekstam, lai to rediģētu.';

  @override
  String storyTextsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count teksti',
      one: '1 teksts',
      zero: 'Nav teksta',
    );
    return '$_temp0';
  }

  @override
  String get storyFontClassic => 'Klasika';

  @override
  String get storyFontBold => 'Treknais';

  @override
  String get storyFontSerif => 'Serif';

  @override
  String get storyFontMono => 'Mono';

  @override
  String get storyFontItalic => 'Kursīvs';

  @override
  String get storyTextBackground => 'Teksta fons';

  @override
  String get storyTextColor => 'Teksta krāsa';

  @override
  String storyTextLimit(int max) {
    return 'Vari pievienot līdz $max tekstiem.';
  }

  @override
  String get wotTitle => 'Uzticības tīkls';

  @override
  String get wotEnable => 'Uzticības tīkls vienmēr ir ieslēgts';

  @override
  String wotExplain(int min) {
    return 'Vienmēr ieslēgts. Atklāj rāda tikai šo tīklu: tevi, cilvēkus, kam seko, un tos, kam seko vismaz $min no tiem. Tas pats tīkls slēpj citu komentārus, paziņojumus, privātos ierakstus un ziņas. Tas tiek aprēķināts šajā tālrunī no publiskajiem sekošanas sarakstiem, pirmo reizi atverot lietotni; vēlāk tas tiek lietots atkārtoti. Uz serveri nekas netiek sūtīts.';
  }

  @override
  String get wotRefresh => 'Atsvaidzināt tīklu tagad';

  @override
  String get wotStatusIdle =>
      'Vēl nav izveidots. Tas tiek izveidots, pirmo reizi atverot lietotni.';

  @override
  String get wotBuildingTitle => 'Veido tavu Atklāj plūsmu';

  @override
  String get wotBuildingBody =>
      'Lasa, kam vēl seko cilvēki, kam tu seko, un gatavo Atklāj.';

  @override
  String get wotDiscoverHint =>
      'Tikai tavs uzticības tīkls: cilvēki, kam seko, un cilvēki, kam seko pietiekami daudzi no tiem.';

  @override
  String get wotDiscoverSignIn =>
      'Atklāj rāda tavu uzticības tīklu. Piesakies, un pirmo reizi Mialuna nolasīs, kam seko, un izveidos šo plūsmu. Vēlāk tas tiek lietots atkārtoti.';

  @override
  String get wotDiscoverEmpty => 'No tava uzticības tīkla vēl nav ierakstu.';

  @override
  String wotStatusDiscovering(int done, int total) {
    return 'Pārbauda, kam seko cilvēki, kam tu seko… $done no $total';
  }

  @override
  String wotStatusComplete(int direct, int indirect, Object when) {
    return 'Tavs tīkls: $direct cilvēki, kam tu seko, un $indirect, kam seko pietiekami daudzi no tiem. Atjaunināts $when.';
  }

  @override
  String wotStatusFailed(Object reason) {
    return 'Neizdevās aprēķināt tavu tīklu: $reason';
  }

  @override
  String get wotNoFollows => 'tu vēl nevienam neseko';

  @override
  String get messageRequests => 'Ziņu pieprasījumi';

  @override
  String messageRequestsSubtitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sarunas ārpus tava uzticības tīkla',
      one: '1 saruna ārpus tava uzticības tīkla',
    );
    return '$_temp0';
  }

  @override
  String get messageRequestsHint =>
      'No cilvēkiem ārpus tava uzticības tīkla. Kā nelasītas tās neskaita. Atbildi, lai saruna nonāktu iesūtnē.';

  @override
  String get storyViewsSetting => 'Ļaut redzēt, ka skatīju viņu stāstus';

  @override
  String get storyViewsSettingExplain =>
      'Kad skaties stāstu, tā autoram tiek nosūtīta kvīts, šifrēta tā, lai to varētu lasīt tikai autors. Tajā tavs vārds ir līdzās autora vārdam; relays neredz neko. Ja to nevar piegādāt, tā tiek paturēta un sūtīta vēlāk. Izslēdz, lai skatītos nevienam nesakot: vēl nenosūtītās kvītis tiek izmestas (jau piegādātu atsaukt nevar).';

  @override
  String storySeenBy(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Redzēja $count cilvēki',
      one: 'Redzēja 1 cilvēks',
      zero: 'Skatījumu vēl nav',
    );
    return '$_temp0';
  }

  @override
  String get storyViewsEmpty =>
      'Šo stāstu vēl neviens nav skatījies, vai arī viņu kvītis tevi nav sasniegušas.';

  @override
  String get storyViewsHint =>
      'Kvīti sūta tikai tie, kas to atļauj, tāpēc patiesais skaits var būt lielāks.';

  @override
  String get systemNotifications => 'Sistēmas paziņojumi';

  @override
  String get systemNotificationsExplain =>
      'Rādi paziņojumu tālrunī, kad pienāk kas jauns, kamēr Mialuna ir fonā. Privāto ziņu teksts netiek rādīts pat bloķēšanas ekrānā. Android aptur lietotnes, kas ilgi paliek fonā, tāpēc paziņojumi pienāk, kamēr Mialuna vēl darbojas.';

  @override
  String get systemNotificationsBlocked =>
      'Tālruņa iestatījumos Mialuna paziņojumi ir izslēgti.';

  @override
  String get systemNotificationsOpenSettings => 'Atvērt iestatījumus';

  @override
  String get systemNotificationsBattery =>
      'Android iemidzina lietotnes dažas minūtes pēc ekrāna izslēgšanas, un paziņojumi apstājas līdz ar tām. Lai turpinātu tos saņemt, iestati Mialuna baterijas lietojumu uz “Neierobežots”.';

  @override
  String get systemNotificationsBatteryAction =>
      'Atvērt baterijas iestatījumus';

  @override
  String get newFollowersSetting => 'Rādīt jaunus sekotājus';

  @override
  String get newFollowersSettingExplain =>
      'Jaunie sekotāji parādās Paziņojumos un tālrunī. Izslēdz, ja cilvēki tevi aplej ar sekošanām: patīk, komentāri un zaps paliek.';

  @override
  String get systemNotificationMessage => 'nosūtīja tev privātu ziņu';

  @override
  String get systemNotificationNewMessage => 'Jauna privāta ziņa';

  @override
  String get systemNotificationNew => 'Jauns paziņojums';

  @override
  String get notificationChannelSocial =>
      'Reakcijas, komentāri, zaps un sekotāji';

  @override
  String get notificationChannelMessages => 'Privātās ziņas';

  @override
  String get zapInvoiceMismatch =>
      'Rēķins neatbilst izvēlētajai summai. Nekas netika samaksāts.';

  @override
  String get storyYourStory => 'Tavs stāsts';

  @override
  String get storyNew => 'Jauns stāsts';

  @override
  String get storyAddSemantics => 'Pievienot tavam stāstam';

  @override
  String storyOwnRailLabel(int count, Object state) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count stāsti',
      one: '1 stāsts',
    );
    return 'Tavs stāsts, $_temp0, $state';
  }

  @override
  String get storyTextSize => 'Teksta izmērs';

  @override
  String get storyPickPrompt => 'Izvēlies foto vai video savam stāstam';

  @override
  String get storyEditPhoto => 'Rediģēt foto';

  @override
  String get storyCaption => 'Paraksts';

  @override
  String get storyDiscardTitle => 'Atmest šo stāstu?';

  @override
  String get storyDiscard => 'Atmest';

  @override
  String get storyShare => 'Dalīties';

  @override
  String get storyShared => 'Stāsts padalīts';

  @override
  String get deletePost => 'Dzēst';

  @override
  String get deletePostTitle => 'Dzēst šo ierakstu?';

  @override
  String get deleteStoryTitle => 'Dzēst šo stāstu?';

  @override
  String get deletePostBody =>
      'Mialuna lūgs taviem relays to dzēst un multivides serveriem dzēst tā foto vai video. Relay, kas pieprasījumu ignorē, vai kāds, kas jau saglabāja kopiju, to joprojām var saglabāt.';

  @override
  String get deletePrivateBody =>
      'Tuvo draugu ierakstu no relays nevar atsaukt. Mialuna liks draugu lietotnēm to noņemt un lūgs multivides serverim dzēst tā šifrētos failus. Draugs, kas jau saglabāja kopiju, to joprojām var paturēt.';

  @override
  String get deletingPost => 'Dzēš…';

  @override
  String get postDeleted => 'Dzēsts.';

  @override
  String get postWasDeleted => 'Šis ieraksts ir dzēsts.';

  @override
  String get deleteNotAllowed => 'Dzēst var tikai konts, kas to publicēja.';

  @override
  String deleteFailed(Object reason) {
    return 'Neizdevās dzēst: $reason';
  }

  @override
  String get deleteNoRelay =>
      'Neviens relay nepieņēma dzēšanas pieprasījumu, tāpēc tas joprojām ir tiešsaistē. Pārbaudi savienojumu un mēģini vēl.';

  @override
  String deleteMediaLeft(Object servers) {
    return 'Multividi neizdevās noņemt no $servers.';
  }

  @override
  String get deleteMediaNotAuthorized =>
      'Tavs parakstītājs neatļāva noņemt multividi, tāpēc faili joprojām ir multivides serverī.';

  @override
  String deleteFriendsMissed(Object count) {
    return '$count tavus tuvus draugus neizdevās sasniegt, tāpēc tas var palikt viņu tālruņos.';
  }

  @override
  String get storyCleanupSetting => 'Dzēst manus stāstus, kad tie beidzas';

  @override
  String get storyCleanupSettingExplain =>
      'Pēc 24 stundām Mialuna lūdz tavus relays un multivides serverus dzēst tavus stāstus kopā ar foto un video. Serveris, kas pieprasījumu ignorē, vai kāds, kas paturēja kopiju, tos joprojām var saglabāt.';

  @override
  String storyCleanupWaiting(Object count) {
    return 'Tavam parakstītājam jāapstiprina katra tīrīšana, tāpēc tas gaida, kamēr tu palūgsi. Beigušies stāsti, kas gaida: $count.';
  }

  @override
  String get storyCleanupNow => 'Dzēst tagad';

  @override
  String get storyCleanupDone => 'Beigušies stāsti ir dzēsti.';

  @override
  String get storyCleanupPartly =>
      'Dažus vēl neizdevās dzēst; Mialuna mēģinās vēlreiz.';
}
