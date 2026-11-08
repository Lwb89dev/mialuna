// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Lithuanian (`lt`).
class AppLocalizationsLt extends AppLocalizations {
  AppLocalizationsLt([String locale = 'lt']) : super(locale);

  @override
  String get syncUpToDate => 'Atnaujinta';

  @override
  String get syncFailed => 'Sinchronizuoti nepavyko';

  @override
  String get relaysUpdatedFromProfile =>
      'Relays atnaujinti iš tavo profilio (NIP-65)';

  @override
  String get relayListPublished => 'Relay sąrašas paskelbtas';

  @override
  String get mediaServersUpdatedFromProfile =>
      'Medijos serveriai atnaujinti iš tavo profilio';

  @override
  String get tabHome => 'Home';

  @override
  String get tabDiscover => 'Atrask';

  @override
  String get tabCreate => 'Kurti';

  @override
  String get tabReels => 'Reels';

  @override
  String get tabProfile => 'Profilis';

  @override
  String get signInToUploadMedia => 'Prisijunk, kad įkeltum mediją.';

  @override
  String get noMediaServer =>
      'Medijos serveris nenustatytas. Pridėk jį Nustatymuose.';

  @override
  String serverNoResponse(Object server) {
    return '$server: nėra atsakymo';
  }

  @override
  String serverUnreachable(Object server, Object error) {
    return '$server: nepasiekiamas ($error)';
  }

  @override
  String uploadRejected(Object reason) {
    return 'Įkėlimas atmestas — $reason';
  }

  @override
  String noServerAcceptedFile(Object reasons) {
    return 'Joks serveris nepriėmė failo — $reasons';
  }

  @override
  String get blossomInvalidResponse => 'netinkamas atsakymas';

  @override
  String get blossomInvalidFileUrl => 'netinkamas failo adresas';

  @override
  String get blossomServerAlteredFile => 'serveris pakeitė failą';

  @override
  String get blossomBadRequest => 'netinkama užklausa';

  @override
  String get blossomUnauthorized => 'autorizacija atmesta';

  @override
  String get blossomPaymentRequired => 'reikia mokėjimo';

  @override
  String get blossomForbidden => 'neleidžiama';

  @override
  String get blossomLengthRequired => 'nėra dydžio';

  @override
  String get blossomTooLarge => 'failas per didelis';

  @override
  String get blossomUnsupportedType => 'formatas nepriimtas';

  @override
  String get blossomTooManyRequests => 'per daug užklausų';

  @override
  String get blossomServerError => 'serverio klaida';

  @override
  String get cipherInvalidKey => 'Netinkamas raktas';

  @override
  String get cipherTruncated => 'Šifruotas failas nukirstas';

  @override
  String get cipherMismatch =>
      'Failas neatitinka rakto: pakeistas arba sugadintas';

  @override
  String get sanitizeHeifNeedsAsync =>
      'HEIC/AVIF formatas: konversijai reikia sanitizeAsync';

  @override
  String get sanitizeWebmUnsupported =>
      'WebM/MKV vaizdo įrašas nepalaikomas: naudok MP4 arba MOV, kad metaduomenis būtų galima pašalinti prieš įkeliant.';

  @override
  String get sanitizeUnknownFormat =>
      'Neatpažintas failo formatas: JPEG/PNG/WebP/GIF nuotraukos arba MP4/MOV vaizdo įrašai.';

  @override
  String sanitizeLeftovers(Object items) {
    return 'Nepavyko pašalinti visų metaduomenų ($items): failas neįkeltas.';
  }

  @override
  String sanitizeProcessingFailed(Object error) {
    return 'Nepavyko apdoroti failo: $error';
  }

  @override
  String get sanitizeJpegInvalid => 'Netinkamas JPEG';

  @override
  String get sanitizeJpegTruncated => 'Nukirstas JPEG';

  @override
  String get sanitizeJpegNoSize => 'JPEG be matmenų';

  @override
  String get sanitizeJpegUndecodable => 'JPEG nepavyksta dekoduoti';

  @override
  String get sanitizePngTruncated => 'Nukirstas PNG';

  @override
  String get sanitizePngInvalid => 'Netinkamas PNG';

  @override
  String get sanitizeGifInvalid => 'Netinkamas GIF';

  @override
  String get sanitizeGifTruncated => 'Nukirstas GIF';

  @override
  String get sanitizeWebpTruncated => 'Nukirstas WebP';

  @override
  String get sanitizeWebpInvalid => 'Netinkamas WebP';

  @override
  String get sanitizeMp4Invalid => 'Netinkamas MP4/MOV vaizdo įrašas';

  @override
  String get sanitizeConversionFailed => 'Konversija nepavyko';

  @override
  String get sanitizeHeifUnsupported =>
      'Šio formato (HEIC/AVIF) šiame įrenginyje konvertuoti negalima. Pasirink JPEG arba PNG nuotrauką.';

  @override
  String get privateMediaNotEncrypted => 'Medija nešifruota';

  @override
  String serverReplied(Object status) {
    return 'Serveris atsakė $status';
  }

  @override
  String get fileTooLarge => 'Failas per didelis';

  @override
  String get serverFileNotOriginal => 'Failas serveryje nėra originalas';

  @override
  String get contentMismatch => 'Turinys nesutampa';

  @override
  String get mediaUnreachable => 'Medija nepasiekiama';

  @override
  String get amberInvalidKey => 'Amber grąžino netinkamą raktą';

  @override
  String get amberNoKey => 'Amber negrąžino rakto';

  @override
  String get amberRequestRejected => 'Užklausa atmesta Amber';

  @override
  String get amberAndroidOnly => 'Amber veikia tik Android';

  @override
  String get amberEmptySignature => 'Amber grąžino tuščią parašą';

  @override
  String get amberSignRejected => 'Parašas atmestas Amber';

  @override
  String get amberTimeout => 'Amber neatsakė laiku';

  @override
  String get amberEmptyResponse => 'Amber grąžino tuščią atsakymą';

  @override
  String get bunkerInvalidUrl => 'Netinkamas bunker URL';

  @override
  String get bunkerNoRelay => 'bunker nenurodo jokio relay';

  @override
  String get bunkerWebAuth =>
      'bunker reikalauja žiniatinklio autorizacijos (auth_url nepalaikomas)';

  @override
  String get bunkerInvalidKey => 'bunker negrąžino tinkamo rakto';

  @override
  String get signerInvalidResponse =>
      'Pasirašytojas grąžino netinkamą pasirašytą įvykį';

  @override
  String get bunkerTimeout => 'Bunker neatsakė laiku';

  @override
  String get nwcInvalidUri => 'Netinkamas NWC URI';

  @override
  String get nwcNoRelay => 'NWC URI nenurodo jokio relay';

  @override
  String get nwcNoSecret => 'NWC URI neturi tinkamo slapto rakto';

  @override
  String get nwcTimeout => 'Piniginė neatsakė laiku';

  @override
  String get signerNoPrivateMessages =>
      'Šis prisijungimo būdas nepalaiko privačių žinučių';

  @override
  String get zapNotSupported => 'Šis adresas nepalaiko Nostr zaps';

  @override
  String zapAmountOutOfRange(Object min, Object max) {
    return 'Suma ne diapazone ($min–$max sats)';
  }

  @override
  String get commentNotSent => 'Komentaras neišsiųstas. Bandyk vėliau.';

  @override
  String get comments => 'Komentarai';

  @override
  String get noCommentsYet => 'Komentarų dar nėra.';

  @override
  String get signInToComment => 'Prisijunk, kad komentuotum.';

  @override
  String get addComment => 'Pridėk komentarą…';

  @override
  String get signInToPublish => 'Prisijunk, kad paskelbtum.';

  @override
  String get addMediaFirst =>
      'Prieš skelbiant pridėk bent vieną nuotrauką ar vaizdo įrašą.';

  @override
  String get removingMetadata => 'Šalinami metaduomenys…';

  @override
  String uploadingProgress(Object current, Object total) {
    return 'Įkeliama $current iš $total…';
  }

  @override
  String get creatingPreview => 'Kuriama peržiūra…';

  @override
  String uploadFailed(Object error) {
    return 'Įkėlimas nepavyko: $error';
  }

  @override
  String get publishing => 'Skelbiama…';

  @override
  String noRelayAcceptedPost(Object reason) {
    return 'Joks relay nepriėmė įrašo$reason. Turinys lieka juodraščiuose.';
  }

  @override
  String get privateNeedsKeySigner =>
      'Šis prisijungimo būdas nepalaiko privataus turinio. Naudok Amber, bunker arba vietinį raktą.';

  @override
  String get closeFriendsListEmptyAddSomeone =>
      'Tavo artimų draugų sąrašas tuščias: ką nors pridėk.';

  @override
  String get fileOver100Mb =>
      'Failas viršija 100 MB: tokia artimų draugų riba (jis visas šifruojamas tavo telefone).';

  @override
  String get encryptingOnPhone => 'Šifruojama telefone…';

  @override
  String noServerAcceptedEncrypted(Object details) {
    return 'Nė vienas tavo medijos serveris nepriėmė šifruoto failo. Atviru tekstu jis neskelbiamas. Nustatymuose pridėk serverį, kuris priima šifruotus failus (pvz., cdn.hzrd149.com). $details';
  }

  @override
  String get sendingToFriends => 'Siunčiama draugams…';

  @override
  String sendingToFriendsProgress(Object done, Object total) {
    return 'Siunčiama draugams $done/$total…';
  }

  @override
  String noFriendReceivedPost(Object reason) {
    return 'Nė vienas draugas negavo įrašo$reason. Turinys lieka juodraščiuose.';
  }

  @override
  String sentToCloseFriends(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Išsiųsta $count artimiems draugams 🔒',
      one: 'Išsiųsta 1 artimam draugui 🔒',
    );
    return '$_temp0';
  }

  @override
  String sentToFriendsWithMisses(int delivered, Object missed) {
    String _temp0 = intl.Intl.pluralLogic(
      delivered,
      locale: localeName,
      other: 'Išsiųsta $delivered draugams.',
      one: 'Išsiųsta 1 draugui.',
    );
    return '$_temp0 $missed negavo (privačios žinutės išjungtos).';
  }

  @override
  String get altText => 'Alt tekstas';

  @override
  String get altTextHint => 'Aprašyk turinį tiems, kas nemato…';

  @override
  String get cancel => 'Atšaukti';

  @override
  String get save => 'Išsaugoti';

  @override
  String get momentPublished => 'Akimirka paskelbta ✨';

  @override
  String get newMoment => 'Nauja akimirka';

  @override
  String get publish => 'Skelbti';

  @override
  String get guestMode => 'Svečio režimas';

  @override
  String get signInToPostMoments => 'Prisijunk, kad skelbtum savo akimirkas.';

  @override
  String get signIn => 'Prisijungti';

  @override
  String get kindPhoto => 'Nuotrauka';

  @override
  String get kindVideo => 'Vaizdo įrašas';

  @override
  String get kindReel => 'Reel';

  @override
  String get kindStory => 'Istorija';

  @override
  String get storyExpiryNote =>
      'Istorijos baigiasi po 24 valandų tuose relay, kurie laikosi NIP-40, bet kiti vis tiek gali jas išsaugoti ar archyvuoti.';

  @override
  String get fromGallery => 'Iš galerijos';

  @override
  String get galleryLongPressVideo => 'Galerija (ilgas paspaudimas — video)';

  @override
  String get addVideo => 'Pridėti video';

  @override
  String get camera => 'Kamera';

  @override
  String get exifRemovedNote =>
      'Vietos metaduomenys (EXIF) pašalinami automatiškai.';

  @override
  String get writeCaption => 'Rašyk prierašą…';

  @override
  String get privatePostNote =>
      'Privatus įrašas: nėra viešų grotažymių, paieška jo neranda.';

  @override
  String willPublishAs(Object caption) {
    return 'Bus paskelbta kaip: \"$caption\"';
  }

  @override
  String get tapThumbnailForAlt =>
      'Bakstelėk miniatiūrą, kad pridėtum alt tekstą.';

  @override
  String get sensitiveContent => 'Jautrus turinys';

  @override
  String get sensitiveContentNote =>
      'Įrašas bus paslėptas už įspėjimo (NIP-36).';

  @override
  String get uploadingMedia => 'Įkeliama medija…';

  @override
  String get audiencePublic => 'Viešas';

  @override
  String get closeFriends => 'Artimi draugai';

  @override
  String get signerCannotPublishCloseFriends =>
      'Su šiuo prisijungimu negali skelbti artimiems draugams: naudok Amber, bunker arba vietinį raktą.';

  @override
  String get closeFriendsEmptyPrompt =>
      'Tavo sąrašas tuščias: pridėk tuos, kas gali matyti šį įrašą.';

  @override
  String onlyYourCloseFriendsSee(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Tai matys tik tavo $count artimi draugai. Nuotraukos ir video šifruojami telefone prieš įkeliant.',
      one: 'Tai matys tik tavo 1 artimas draugas. Nuotraukos ir video šifruojami telefone prieš įkeliant.',
    );
    return '$_temp0';
  }

  @override
  String get addFriends => 'Pridėti draugus';

  @override
  String get manageList => 'Tvarkyti sąrašą';

  @override
  String get edit => 'Redaguoti';

  @override
  String get reset => 'Atstatyti';

  @override
  String get apply => 'Taikyti';

  @override
  String get cropFree => 'Laisvas';

  @override
  String get cropOriginal => 'Originalas';

  @override
  String get rotate => 'Sukti';

  @override
  String get flip => 'Apversti';

  @override
  String get brightness => 'Šviesumas';

  @override
  String get contrast => 'Kontrastas';

  @override
  String get saturation => 'Sodrumas';

  @override
  String postsByAuthor(Object author) {
    return '$author įrašai…';
  }

  @override
  String get searchHint => 'Ieškok žmonių, grotažymių ar žodžių…';

  @override
  String get clear => 'Išvalyti';

  @override
  String get recent => 'Naujausi';

  @override
  String get searchDependsOnRelays =>
      'Paieška priklauso nuo nustatytų relays: rezultatai gali būti nepilni.';

  @override
  String get recentPostsEverywhere =>
      'Naujausi įrašai iš viso tinklo, taip pat iš tų, kurių neseki.';

  @override
  String get noResultsOnRelays => 'Nustatytuose relays rezultatų nėra.';

  @override
  String get noRecentPostsFromFollowed =>
      'Naujausių įrašų iš žmonių, kuriuos seki, nėra.';

  @override
  String get noMomentsFound => 'Relays akimirkų nerasta. Patikrink ryšį.';

  @override
  String get loadFailed => 'Įkelti nepavyko';

  @override
  String get notifications => 'Pranešimai';

  @override
  String get messages => 'Žinutės';

  @override
  String get homeEmptyFollowsNobody =>
      'Čia rodomi žmonių, kuriuos seki, įrašai.\nDar nieko neseki: atrask įdomius žmones ir profilius.';

  @override
  String get discoverPeople => 'Atrask žmones';

  @override
  String get homeEmpty =>
      'Akimirkų dar nėra.\nPatrauk žemyn, kad atnaujintum, arba paskelbk pirmą kadrą.';

  @override
  String get retry => 'Bandyti dar';

  @override
  String get seenEverything => 'Kol kas matei viską ✨';

  @override
  String get discoverMoreProfiles => 'Atrask daugiau profilių';

  @override
  String get feedFollowing => 'Sekami';

  @override
  String get signInToSeeFollowed =>
      'Prisijunk, kad matytum įrašus iš žmonių, kuriuos seki';

  @override
  String get videoPreview => 'Video peržiūra';

  @override
  String get cannotOpenPrivateVideo => 'Nepavyksta atidaryti privataus video';

  @override
  String get cannotPlayVideo => 'Nepavyksta paleisti video';

  @override
  String get pauseVideo => 'Pristabdyti video';

  @override
  String get playVideo => 'Leisti video';

  @override
  String errorTapToRetry(Object error) {
    return '$error — bakstelėk ir bandyk dar';
  }

  @override
  String get soundOn => 'Įjungti garsą';

  @override
  String get soundOff => 'Išjungti garsą';

  @override
  String get postImage => 'Įrašo nuotrauka';

  @override
  String get imageUnavailable => 'Vaizdas nepasiekiamas';

  @override
  String errorTapToRetryNewline(Object message) {
    return '$message\nBakstelėk ir bandyk dar';
  }

  @override
  String get cannotOpenPrivateContent =>
      'Nepavyksta atidaryti šio privataus turinio';

  @override
  String get privateImage => 'Privatus vaizdas';

  @override
  String get invalidImage => 'Netinkamas vaizdas';

  @override
  String get more => 'Daugiau';

  @override
  String get removeFromSaved => 'Pašalinti iš išsaugotų';

  @override
  String get copyLink => 'Kopijuoti nuorodą';

  @override
  String get muteAuthor => 'Nutildyti autorių';

  @override
  String get blockAuthor => 'Blokuoti autorių';

  @override
  String get report => 'Pranešti';

  @override
  String get like => 'Patinka';

  @override
  String get sendInMessage => 'Siųsti žinute';

  @override
  String get zapOptional => 'Zap (nebūtina)';

  @override
  String get closeFriendsOnlyNote =>
      'Mato tik artimi draugai. Patinka ir atsakymai eina tik autoriui.';

  @override
  String get likeFailed => 'Nepavyko išsiųsti patiktuko';

  @override
  String get nostrLinkCopied => 'Nostr nuoroda nukopijuota į iškarpinę';

  @override
  String get authorMuted => 'Autorius nutildytas';

  @override
  String get authorBlocked => 'Autorius užblokuotas';

  @override
  String get reportSent => 'Pranešimas išsiųstas (NIP-56)';

  @override
  String get signInToReport => 'Prisijunk, kad praneštum';

  @override
  String minutesAgo(Object minutes) {
    return '$minutes min. prieš';
  }

  @override
  String get show => 'Rodyti';

  @override
  String get chatEmptyHint =>
      'Parašyk pirmą žinutę.\nJi šifruota: ją mato tik judu.';

  @override
  String get messageHint => 'Žinutė…';

  @override
  String get send => 'Siųsti';

  @override
  String get notSentSuffix => ' neišsiųsta';

  @override
  String get contentUnavailable =>
      'Turinys nepasiekiamas (pasibaigęs arba nerastas relays)';

  @override
  String get signInToSendPrivateMessages =>
      'Prisijunk, kad siųstum privačias žinutes.';

  @override
  String get cannotMessageYourself => 'Sau rašyti negali.';

  @override
  String get recipientNoPrivateMessages =>
      'Šis žmogus dar neįjungė privačių žinučių.';

  @override
  String noRecipientRelayAccepted(Object reason) {
    return 'Joks gavėjo relay nepriėmė žinutės$reason.';
  }

  @override
  String sendFailed(Object error) {
    return 'Siuntimas nepavyko: $error';
  }

  @override
  String get signInToReadMessages =>
      'Prisijunk, kad skaitytum ir siųstum privačias žinutes.';

  @override
  String get signerNoPrivateMessagesLong =>
      'Su šiuo prisijungimu privačių žinučių naudoti negalima. Prisijunk su Amber, bunker arba vietiniu raktu.';

  @override
  String get inboxEmpty =>
      'Pokalbių nėra.\nBakstelėk pieštuką, kad kam nors parašytum, arba persiųsk akimirką su ✈ piktograma po kiekvienu įrašu.';

  @override
  String get newMessage => 'Nauja žinutė';

  @override
  String get privateMessagesEnabled => 'Privačios žinutės įjungtos';

  @override
  String get enableMessagesFailed => 'Nepavyko jų įjungti. Bandyk dar.';

  @override
  String get enablePrivateMessages => 'Įjungti privačias žinutes';

  @override
  String enablePrivateMessagesExplain(Object count) {
    return 'Kad gautum žinutes, reikia nurodyti, į kuriuos relays jos ateina. Paskelbiamas trumpas sąrašas (NIP-17) su $count numatytaisiais relays: vėliau gali jį keisti. Žinutės lieka šifruotos: relays nemato nei kas rašo, nei teksto.';
  }

  @override
  String get turnOn => 'Įjungti';

  @override
  String get searchByNameOrUsername => 'Ieškok pagal vardą ar slapyvardį';

  @override
  String get searching => 'Ieškoma…';

  @override
  String get noOneWithNameHint =>
      'Nėra žmogaus tokiu vardu. Bandyk mažiau raidžių arba adresą kaip name@domain.com.';

  @override
  String get sent => 'Išsiųsta';

  @override
  String sentToPeople(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Išsiųsta $count žmonėms',
      one: 'Išsiųsta 1 žmogui',
    );
    return '$_temp0';
  }

  @override
  String sentToPeopleWithFailure(int count, Object failure) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Išsiųsta $count žmonėms. $failure',
      one: 'Išsiųsta 1 žmogui. $failure',
    );
    return '$_temp0';
  }

  @override
  String get signerNoPrivateMessagesShort =>
      'Su šiuo prisijungimu privačių žinučių naudoti negali.';

  @override
  String get followToStartOrSearch =>
      'Pirma ką nors sek arba ieškok pagal vardą.';

  @override
  String get addMessage => 'Pridėk žinutę…';

  @override
  String sendWithCount(Object count) {
    return 'Siųsti ($count)';
  }

  @override
  String get linkCopied => 'Nuoroda nukopijuota į iškarpinę';

  @override
  String get noNotifications => 'Pranešimų dabar nėra.';

  @override
  String get notificationsDependOnRelays =>
      'Pranešimai priklauso nuo relays: jų gali trūkti.';

  @override
  String get reactedToYourMoment => 'sureagavo į tavo akimirką';

  @override
  String commentedText(Object text) {
    return 'pakomentavo: $text';
  }

  @override
  String sentYouSats(Object sats, Object comment) {
    return 'atsiuntė tau $sats sats$comment';
  }

  @override
  String get sentYouZap => 'atsiuntė tau zap';

  @override
  String get startedFollowingYou => 'pradėjo tave sekti';

  @override
  String get amberNotFound => 'Amber nerasta';

  @override
  String get amberExplain =>
      'Amber yra Nostr pasirašytojas, kuris laiko tavo privatų raktą už Mialuna ribų. Įdiek ir bandyk dar.';

  @override
  String get downloadFromFdroid => 'Atsisiųsti iš F-Droid';

  @override
  String get continueWithAmber => 'Tęsti su Amber';

  @override
  String get amberRecommended =>
      'Rekomenduojama: privatus raktas saugiai lieka Amber.';

  @override
  String get amberNotDetected =>
      'Amber neaptikta: įdiek ją rekomenduojamam prisijungimui.';

  @override
  String get exploreWithoutAccount => 'Naršyti be paskyros';

  @override
  String get remoteBunker => 'Nuotolinis bunker (NIP-46)';

  @override
  String get invalidBunkerUrlDot => 'Netinkamas bunker URL.';

  @override
  String get connectBunker => 'Jungti bunker';

  @override
  String get advancedNsec => 'Išplėstinis prisijungimas (nsec)';

  @override
  String get nsecWarning =>
      'Įspėjimas: įklijuoti privatų raktą rizikinga. Niekam jo neduok. Android rinkis Amber.';

  @override
  String get invalidNsec => 'Netinkamas nsec raktas.';

  @override
  String get signInWithNsec => 'Prisijungti su nsec';

  @override
  String get tagline => 'Tavo akimirkos, po tuo pačiu mėnuliu.';

  @override
  String get skip => 'Praleisti';

  @override
  String get permissionsAndWallet => 'Leidimai ir piniginė';

  @override
  String get permissionsExplain =>
      'Jie tik leidžia skelbti ir gauti pranešimus. Gali juos bet kada pakeisti sistemos nustatymuose.';

  @override
  String get photosAndVideos => 'Nuotraukos ir video';

  @override
  String get toUploadYourMoments => 'Kad įkeltum savo akimirkas';

  @override
  String get allow => 'Leisti';

  @override
  String get reactionsCommentsZaps => 'Reakcijos, komentarai ir zaps';

  @override
  String get lightningWalletOptional => 'Lightning piniginė (nebūtina)';

  @override
  String get nwcExplain =>
      'Prijunk Nostr Wallet Connect piniginę, kad siųstum zaps neišeidamas iš programėlės.';

  @override
  String get walletConnected => 'Piniginė prijungta';

  @override
  String get disconnect => 'Atjungti';

  @override
  String get connectWallet => 'Prijungti piniginę';

  @override
  String get getStarted => 'Pradėti';

  @override
  String get welcome1 =>
      'Mialuna yra vaizdinis socialinis tinklas: nuotraukos, video, Reels ir istorijos — niekada tik tekstiniai įrašai.';

  @override
  String get welcome2 =>
      'Ji veikia per Nostr, atvirą protokolą: tapatybė yra raktas, kuris priklauso tau, ne paskyra, kurią įmonė gali atimti. Jokių reklamų, jokių sekiklių, jokių centrinių serverių.';

  @override
  String get welcome3 =>
      'Dalinkis savo šviesa su žmonėmis visur, iš bet kurios programėlės, kuri kalba tą pačią atvirą kalbą.';

  @override
  String onboardingWot(int min) {
    return 'Pasitikėjimo tinklas visada įjungtas. Pirmą kartą atidarius Mialuna, ji perskaito, ką seki, ir iš to tinklo sudaro Atrask srautą: tu, žmonės, kuriuos seki, ir tie, kuriuos seka bent $min iš jų. Kitą kartą atidarius programėlę, tas srautas jau yra.';
  }

  @override
  String get publicAndPrivate => 'Vieša ir privatu';

  @override
  String get publicAndPrivateIntro =>
      'Mialuna sukurta ant Nostr, atviro tinklo. Ką paskelbi, yra vieša: įrašus, nuotraukas ir video mato kiekvienas, turintis nuorodą, net už Mialuna ribų.';

  @override
  String get closeFriendsExplain1 =>
      'Tik šio sąrašo žmonės gauna tavo \"Artimi draugai\" įrašus, istorijas ir video. Sąrašas yra pačiame įraše; kiekvieną kartą jo rinkti nereikia.';

  @override
  String get closeFriendsExplain2 =>
      'Nuotraukos ir video šifruojami telefone prieš įkeliant. Failų serveriai (Blossom) patys nieko nešifruoja: todėl tai daro Mialuna, o serveris mato tik neįskaitomus duomenis. Kas randa failo adresą, jo neatidarys.';

  @override
  String get closeFriendsExplain3 =>
      'Tai nėra absoliuti garantija: kas gauna įrašą, gali padaryti ekrano nuotrauką, o draugo pašalinimas galioja tik būsimiems įrašams.';

  @override
  String get closeFriendsExplain4 =>
      'Kiekvienas draugas turi naudoti Mialuna su įjungtomis privačiomis žinutėmis. Kiti Nostr klientai šių įrašų nerodo.';

  @override
  String get closeFriendsExplain5 =>
      'Vieši įrašai lieka vieši: jų failus mato kiekvienas, turintis nuorodą.';

  @override
  String get closeFriendsExplain6 =>
      'Jei nė vienas tavo serveris nepriima šifruotų failų, įrašas neskelbiamas: niekada atviru tekstu.';

  @override
  String get addToCloseFriends => 'Pridėti prie artimų draugų';

  @override
  String maxFriendsReached(Object max, Object added) {
    return 'Riba — $max draugų: pridėta $added.';
  }

  @override
  String get add => 'Pridėti';

  @override
  String get signInToCreateList => 'Prisijunk, kad sukurtum savo sąrašą.';

  @override
  String get signerNoCloseFriends =>
      'Su šiuo prisijungimu artimų draugų naudoti negali. Prisijunk su Amber, bunker arba vietiniu raktu.';

  @override
  String peopleOfMax(Object count, Object max) {
    return '$count / $max žmonių';
  }

  @override
  String get noOneYet => 'Dar nieko nėra.';

  @override
  String get addPeople => 'Pridėti žmonių';

  @override
  String get friendNoPrivateMessagesWarning =>
      'Jie neįjungė privačių žinučių: tavo įrašų negaus';

  @override
  String get removeFromList => 'Pašalinti iš sąrašo';

  @override
  String get noOneWithThisName => 'Nėra žmogaus tokiu vardu.';

  @override
  String get signInToSendPrivateContent =>
      'Prisijunk, kad siųstum privatų turinį.';

  @override
  String get reasonNoPrivateMessages => 'neįjungė privačių žinučių';

  @override
  String get reasonNoRelayAnswered => 'joks relay neatsakė';

  @override
  String get profileUpdated => 'Profilis atnaujintas';

  @override
  String get noRelayAcceptedRetry => 'Joks relay nepriėmė. Bandyk vėliau.';

  @override
  String get editProfile => 'Redaguoti profilį';

  @override
  String get fieldName => 'Vardas';

  @override
  String get fieldBio => 'Aprašas';

  @override
  String get fieldAvatarUrl => 'Avataro URL';

  @override
  String get fieldNip05 => 'NIP-05 (pvz., you@example.com)';

  @override
  String get browsingAsGuest => 'Naršai kaip svečias';

  @override
  String get signInToInteract =>
      'Prisijunk, kad skelbtum, sektum ir bendrautum.';

  @override
  String get settings => 'Nustatymai';

  @override
  String get signOut => 'Atsijungti';

  @override
  String get npubCopied => 'npub nukopijuotas';

  @override
  String get copyNpub => 'Kopijuoti npub';

  @override
  String get mute => 'Nutildyti';

  @override
  String get block => 'Blokuoti';

  @override
  String get posts => 'Įrašai';

  @override
  String get saved => 'Išsaugota';

  @override
  String get nothingPublishedYet => 'Dar nieko nepaskelbei.';

  @override
  String get noPostsOnRelays => 'Relays įrašų nerasta.';

  @override
  String get noReelsPublished => 'Nėra paskelbtų reels.';

  @override
  String get noReelsOnRelays => 'Relays reels nerasta.';

  @override
  String get noSavedPosts => 'Nėra išsaugotų įrašų.';

  @override
  String get followingButton => 'Sekama';

  @override
  String get follow => 'Sekti';

  @override
  String get messageButton => 'Žinutė';

  @override
  String get loginLocalKey => 'Vietinis raktas';

  @override
  String get loginGuest => 'Svečias';

  @override
  String get followUpdateFailed =>
      'Dabar nepavyko atnaujinti tavo sekamų. Bandyk dar.';

  @override
  String get noReelsComeBack => 'Relays reels nerasta.\nUžsuk greitai!';

  @override
  String get followUpdateFailedShort => 'Dabar nepavyko atnaujinti tavo sekamų';

  @override
  String get needOneReadRelay => 'Reikia bent vieno skaitymo relay.';

  @override
  String get listSavedLocally =>
      'Sąrašas išsaugotas šiame įrenginyje, nepaskelbtas.';

  @override
  String get noRelayAcceptedList =>
      'Joks relay nepriėmė sąrašo: bus bandoma vėliau.';

  @override
  String relayListPublishedTo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Relay sąrašas paskelbtas į $count relays',
      one: 'Relay sąrašas paskelbtas į 1 relay',
    );
    return '$_temp0';
  }

  @override
  String get mediaServersUpdated => 'Medijos serveriai atnaujinti';

  @override
  String get appearance => 'Išvaizda';

  @override
  String get publishingSettings => 'Skelbimas';

  @override
  String get addMialunaHashtag => 'Pridėti #mialuna';

  @override
  String get addMialunaHashtagNote =>
      'Pridėk oficialią grotažymę prie viešų įrašų ir istorijų. Bet kada gali tai išjungti.';

  @override
  String get themeLight => 'Šviesi';

  @override
  String get themeDark => 'Tamsi';

  @override
  String get themeSystem => 'Sistemos';

  @override
  String get relays => 'Relays';

  @override
  String get relaysExplainSignedOut =>
      'Relays saugo ir platina turinį. Prisijunk, kad automatiškai naudotum savo sąrašą (NIP-65).';

  @override
  String get relaysExplainSynced =>
      'Sąrašas sinchronizuotas su tavo Nostr profiliu (NIP-65): kiekvienas pakeitimas paskelbiamas ir galioja visose tavo programėlėse.';

  @override
  String get syncing => 'Sinchronizuojama…';

  @override
  String get waitingFirstSync => 'Laukiama pirmos sinchronizacijos';

  @override
  String get syncNow => 'Sinchronizuoti dabar';

  @override
  String get addRelay => 'Pridėti relay';

  @override
  String get restoreDefaultRelays => 'Atkurti numatytuosius relays';

  @override
  String get createYourList => 'Sukurti savo sąrašą';

  @override
  String peopleCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count žmonės',
      one: '1 žmogus',
    );
    return '$_temp0';
  }

  @override
  String get closeFriendsSettingsNote =>
      'Įrašai, istorijos ir video matomi tik jiems, su šifruotomis nuotraukomis ir video.';

  @override
  String get mediaServersBlossom => 'Medijos serveriai (Blossom)';

  @override
  String get mediaServersExplain =>
      'Nuotraukos ir video keliami tik į šiuos serverius, nurodyta tvarka: laimi pirmas, kuris juos priima. EXIF ir vieta pašalinami prieš įkeliant.';

  @override
  String get primary => 'Pagrindinis';

  @override
  String get makePrimary => 'Padaryti pagrindiniu';

  @override
  String get remove => 'Pašalinti';

  @override
  String get addServer => 'Pridėti serverį';

  @override
  String get moderation => 'Moderavimas';

  @override
  String get moderationExplain =>
      'Nutildyti autoriai ir paslėptos grotažymės sinchronizuojami per NIP-51. Užblokuoti autoriai lieka tik šiame įrenginyje.';

  @override
  String get mutedAuthors => 'Nutildyti autoriai';

  @override
  String get noMutedAuthors => 'Nėra nutildytų autorių';

  @override
  String get blockedAuthors => 'Užblokuoti autoriai';

  @override
  String get noBlockedAuthors => 'Nėra užblokuotų autorių';

  @override
  String get hiddenHashtags => 'Paslėptos grotažymės';

  @override
  String get noHiddenHashtags => 'Nėra paslėptų grotažymių';

  @override
  String get hashtagToHide => '#hashtag slėpimui';

  @override
  String get storage => 'Saugykla';

  @override
  String get clearCache => 'Išvalyti įvykių talpyklą ir juodraščius';

  @override
  String get cacheCleared => 'Talpykla išvalyta';

  @override
  String get reviewIntro => 'Peržiūrėti įvadą';

  @override
  String get reviewIntroSubtitle =>
      'Kas vieša, kas privatu ir artimų draugų ribos.';

  @override
  String noLightningWalletCopied(Object address) {
    return 'Lightning piniginė nerasta: adresas nukopijuotas ($address)';
  }

  @override
  String get about => 'Apie';

  @override
  String aboutText(Object version) {
    return 'Mialuna $version — Tavo akimirkos, po tuo pačiu mėnuliu.\nAtviras kodas (MIT). github.com/Lwb89dev/mialuna';
  }

  @override
  String get invalidRelayAddress => 'Netinkamas adresas: naudok wss://…';

  @override
  String get invalidServerAddress => 'Netinkamas adresas: naudok https://…';

  @override
  String get relayRead => 'Skaityti';

  @override
  String get relayWrite => 'Rašyti';

  @override
  String get support => 'Parama';

  @override
  String get supportText =>
      'Mialuna nemokama, be reklamų ir tavęs neseka. Jei patinka, gali nusiųsti kelis sats per Lightning Network.';

  @override
  String get donateWithLightning => 'Paaukoti per Lightning';

  @override
  String get authorNoZaps => 'Šis autorius nepriima zaps';

  @override
  String get sendZap => 'Siųsti zap ⚡';

  @override
  String get amountInSats => 'Suma (sats)';

  @override
  String minMaxSats(Object min, Object max) {
    return 'min $min – max $max';
  }

  @override
  String get zap => 'Zap';

  @override
  String get signInToZap => 'Prisijunk, kad siųstum zaps';

  @override
  String zapSent(Object sats) {
    return 'Zap $sats sats išsiųstas ⚡';
  }

  @override
  String nwcPaymentFailed(Object error) {
    return 'NWC mokėjimas nepavyko: $error';
  }

  @override
  String get noLightningWallet => 'Lightning piniginė nerasta';

  @override
  String storiesRailLabel(Object state) {
    return 'Istorijos, $state';
  }

  @override
  String get close => 'Uždaryti';

  @override
  String hoursAgo(int hours) {
    return '$hours val. prieš';
  }

  @override
  String daysAgo(int days) {
    return '$days d. prieš';
  }

  @override
  String get now => 'dabar';

  @override
  String get youPrefix => 'Tu: ';

  @override
  String get storiesStateUnseen => 'nauja';

  @override
  String get storiesStateSeen => 'matyta';

  @override
  String weekdayShort(String day) {
    String _temp0 = intl.Intl.selectLogic(day, {
      'mon': 'Pr',
      'tue': 'An',
      'wed': 'Tr',
      'thu': 'Kt',
      'fri': 'Pn',
      'sat': 'Št',
      'sun': 'Sk',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get sharedAMoment => 'Pasidalijo akimirka';

  @override
  String get blossomOtherError => 'klaida';

  @override
  String get languageTitle => 'Kalba';

  @override
  String get languageSystem => 'Sistemos';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageItalian => 'Italiano';

  @override
  String get cannotEditPhoto => 'Šios nuotraukos čia redaguoti negalima.';

  @override
  String notificationsNew(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count nauji pranešimai',
      one: '1 naujas pranešimas',
    );
    return '$_temp0';
  }

  @override
  String messagesUnread(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count neskaitytos žinutės',
      one: '1 neskaityta žinutė',
    );
    return '$_temp0';
  }

  @override
  String get done => 'Baigta';

  @override
  String get storyAddText => 'Pridėti tekstą';

  @override
  String get storyEditText => 'Redaguoti tekstą';

  @override
  String get storyTextHint => 'Rašyk ką nors… #hashtags galima spausti';

  @override
  String get storyTextsHelp =>
      'Bakstelėk paveikslą, kad rašytum. Tempk, kad perkeltum, gnybk, kad keistum dydį ir pasuktum, bakstelėk tekstą, kad jį redaguotum.';

  @override
  String storyTextsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tekstai',
      one: '1 tekstas',
      zero: 'Nėra teksto',
    );
    return '$_temp0';
  }

  @override
  String get storyFontClassic => 'Klasika';

  @override
  String get storyFontBold => 'Paryškintas';

  @override
  String get storyFontSerif => 'Serif';

  @override
  String get storyFontMono => 'Mono';

  @override
  String get storyFontItalic => 'Kursyvas';

  @override
  String get storyTextBackground => 'Teksto fonas';

  @override
  String get storyTextColor => 'Teksto spalva';

  @override
  String storyTextLimit(int max) {
    return 'Gali pridėti iki $max tekstų.';
  }

  @override
  String get wotTitle => 'Pasitikėjimo tinklas';

  @override
  String get wotEnable => 'Pasitikėjimo tinklas visada įjungtas';

  @override
  String wotExplain(int min) {
    return 'Visada įjungta. Atrask rodo tik šį tinklą: tave, žmones, kuriuos seki, ir tuos, kuriuos seka bent $min iš jų. Tas pats tinklas slepia kitų komentarus, pranešimus, privačius įrašus ir žinutes. Jis apskaičiuojamas šiame telefone iš viešų sekimo sąrašų, kai pirmą kartą atidarai programėlę; vėliau jis naudojamas iš naujo. Į jokį serverį niekas nesiunčiama.';
  }

  @override
  String get wotRefresh => 'Atnaujinti tinklą dabar';

  @override
  String get wotStatusIdle =>
      'Dar nesudarytas. Jis sudaromas pirmą kartą atidarius programėlę.';

  @override
  String get wotBuildingTitle => 'Kuriamas tavo Atrask srautas';

  @override
  String get wotBuildingBody =>
      'Skaitoma, ką dar seka žmonės, kuriuos seki, ir ruošiamas Atrask.';

  @override
  String get wotDiscoverHint =>
      'Tik tavo pasitikėjimo tinklas: žmonės, kuriuos seki, ir tie, kuriuos seka pakankamai jų.';

  @override
  String get wotDiscoverSignIn =>
      'Atrask rodo tavo pasitikėjimo tinklą. Prisijunk ir pirmą kartą Mialuna perskaitys, ką seki, ir sudarys šį srautą. Vėliau jis naudojamas iš naujo.';

  @override
  String get wotDiscoverEmpty => 'Iš tavo pasitikėjimo tinklo įrašų dar nėra.';

  @override
  String wotStatusDiscovering(int done, int total) {
    return 'Tikrinama, ką seka tavo sekami… $done iš $total';
  }

  @override
  String wotStatusComplete(int direct, int indirect, Object when) {
    return 'Tavo tinklas: $direct žmonės, kuriuos seki, ir $indirect, kuriuos seka pakankamai jų. Atnaujinta $when.';
  }

  @override
  String wotStatusFailed(Object reason) {
    return 'Nepavyko apskaičiuoti tavo tinklo: $reason';
  }

  @override
  String get wotNoFollows => 'dar nieko neseki';

  @override
  String get messageRequests => 'Žinučių užklausos';

  @override
  String messageRequestsSubtitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pokalbiai ne iš tavo pasitikėjimo tinklo',
      one: '1 pokalbis ne iš tavo pasitikėjimo tinklo',
    );
    return '$_temp0';
  }

  @override
  String get messageRequestsHint =>
      'Nuo žmonių už tavo pasitikėjimo tinklo. Kaip neskaitytos neskaičiuojamos. Atsakyk, kad pokalbis keltųsi į dėžutę.';

  @override
  String get storyViewsSetting => 'Leisti matyti, kad peržiūrėjau jų istorijas';

  @override
  String get storyViewsSettingExplain =>
      'Kai žiūri istoriją, autoriui išsiunčiamas patvirtinimas, šifruotas taip, kad skaityti galėtų tik jis. Jame tavo vardas šalia jo; relays nemato nieko. Jei pristatyti nepavyksta, jis paliekamas ir bandoma vėliau. Išjunk, kad žiūrėtum niekam nesakant: dar neišsiųsti patvirtinimai išmetami (jau pristatyto susigrąžinti negalima).';

  @override
  String storySeenBy(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Matė $count žmonės',
      one: 'Matė 1 žmogus',
      zero: 'Peržiūrų dar nėra',
    );
    return '$_temp0';
  }

  @override
  String get storyViewsEmpty =>
      'Šios istorijos dar niekas nežiūrėjo arba jų patvirtinimai tavęs nepasiekė.';

  @override
  String get storyViewsHint =>
      'Patvirtinimą siunčia tik tie, kas tai leidžia, todėl tikras skaičius gali būti didesnis.';

  @override
  String get systemNotifications => 'Sistemos pranešimai';

  @override
  String get systemNotificationsExplain =>
      'Rodyk pranešimą telefone, kai ateina kas nors nauja, o Mialuna yra fone. Privačių žinučių tekstas nerodomas net užrakto ekrane. Android ilgam fone esančias programėles pristabdo, todėl pranešimai ateina, kol Mialuna dar veikia.';

  @override
  String get systemNotificationsBlocked =>
      'Telefono nustatymuose Mialuna pranešimai išjungti.';

  @override
  String get systemNotificationsOpenSettings => 'Atidaryti nustatymus';

  @override
  String get systemNotificationsBattery =>
      'Android užmigdo programėles praėjus kelioms minutėms po ekrano išjungimo, ir pranešimai sustoja kartu. Kad juos gautum toliau, nustatyk Mialuna baterijos naudojimą į „Neribota“.';

  @override
  String get systemNotificationsBatteryAction =>
      'Atidaryti baterijos nustatymus';

  @override
  String get newFollowersSetting => 'Rodyti naujus sekėjus';

  @override
  String get newFollowersSettingExplain =>
      'Nauji sekėjai rodomi Pranešimuose ir telefone. Išjunk, jei žmonės užverčia sekimais: patinka, komentarai ir zaps liks.';

  @override
  String get systemNotificationMessage => 'atsiuntė tau privačią žinutę';

  @override
  String get systemNotificationNewMessage => 'Nauja privati žinutė';

  @override
  String get systemNotificationNew => 'Naujas pranešimas';

  @override
  String get notificationChannelSocial =>
      'Reakcijos, komentarai, zaps ir sekėjai';

  @override
  String get notificationChannelMessages => 'Privačios žinutės';

  @override
  String get zapInvoiceMismatch =>
      'Sąskaita neatitinka pasirinktos sumos. Nieko nesumokėta.';

  @override
  String get storyYourStory => 'Tavo istorija';

  @override
  String get storyNew => 'Nauja istorija';

  @override
  String get storyAddSemantics => 'Pridėti prie tavo istorijos';

  @override
  String storyOwnRailLabel(int count, Object state) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count istorijos',
      one: '1 istorija',
    );
    return 'Tavo istorija, $_temp0, $state';
  }

  @override
  String get storyTextSize => 'Teksto dydis';

  @override
  String get storyPickPrompt => 'Pasirink nuotrauką arba video savo istorijai';

  @override
  String get storyEditPhoto => 'Redaguoti nuotrauką';

  @override
  String get storyCaption => 'Prierašas';

  @override
  String get storyDiscardTitle => 'Atmesti šią istoriją?';

  @override
  String get storyDiscard => 'Atmesti';

  @override
  String get storyShare => 'Dalintis';

  @override
  String get storyShared => 'Istorija pasidalinta';

  @override
  String get deletePost => 'Ištrinti';

  @override
  String get deletePostTitle => 'Ištrinti šį įrašą?';

  @override
  String get deleteStoryTitle => 'Ištrinti šią istoriją?';

  @override
  String get deletePostBody =>
      'Mialuna paprašys tavo relays jį ištrinti ir medijos serverių ištrinti nuotraukas ar video. Relay, kuris prašymą ignoruoja, arba kas jau išsaugojo kopiją, vis dar gali jį turėti.';

  @override
  String get deletePrivateBody =>
      'Artimų draugų įrašo iš relays atšaukti negalima. Mialuna lieps draugų programėlėms jį pašalinti ir paprašys medijos serverio ištrinti šifruotus failus. Draugas, kuris jau išsaugojo kopiją, vis dar gali jį turėti.';

  @override
  String get deletingPost => 'Trinama…';

  @override
  String get postDeleted => 'Ištrinta.';

  @override
  String get postWasDeleted => 'Šis įrašas ištrintas.';

  @override
  String get deleteNotAllowed =>
      'Ištrinti gali tik paskyra, kuri tai paskelbė.';

  @override
  String deleteFailed(Object reason) {
    return 'Nepavyko ištrinti: $reason';
  }

  @override
  String get deleteNoRelay =>
      'Joks relay nepriėmė trynimo prašymo, todėl jis vis dar pasiekiamas. Patikrink ryšį ir bandyk dar.';

  @override
  String deleteMediaLeft(Object servers) {
    return 'Medijos nepavyko pašalinti iš $servers.';
  }

  @override
  String get deleteMediaNotAuthorized =>
      'Tavo pasirašytojas neleido pašalinti medijos, todėl failai tebėra medijos serveryje.';

  @override
  String deleteFriendsMissed(Object count) {
    return '$count tavo artimų draugų nepavyko pasiekti, todėl gali likti jų telefonuose.';
  }

  @override
  String get storyCleanupSetting => 'Trinti mano istorijas, kai jos baigiasi';

  @override
  String get storyCleanupSettingExplain =>
      'Po 24 valandų Mialuna paprašo tavo relays ir medijos serverių ištrinti tavo istorijas kartu su nuotraukomis ir video. Serveris, kuris prašymą ignoruoja, arba kas pasiliko kopiją, vis dar gali jas turėti.';

  @override
  String storyCleanupWaiting(Object count) {
    return 'Tavo pasirašytojas turi patvirtinti kiekvieną valymą, todėl laukiama, kol paprašysi. Laukiančios pasibaigusios istorijos: $count.';
  }

  @override
  String get storyCleanupNow => 'Ištrinti dabar';

  @override
  String get storyCleanupDone => 'Pasibaigusios istorijos ištrintos.';

  @override
  String get storyCleanupPartly =>
      'Kai kurių dar nepavyko ištrinti; Mialuna bandys dar.';
}
