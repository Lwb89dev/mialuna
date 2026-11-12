// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Romanian Moldavian Moldovan (`ro`).
class AppLocalizationsRo extends AppLocalizations {
  AppLocalizationsRo([String locale = 'ro']) : super(locale);

  @override
  String get syncUpToDate => 'La zi';

  @override
  String get syncFailed => 'Sincronizarea a eșuat';

  @override
  String get relaysUpdatedFromProfile =>
      'Relays actualizate din profilul tău (NIP-65)';

  @override
  String get relayListPublished => 'Listă Relay publicată';

  @override
  String get mediaServersUpdatedFromProfile =>
      'Serverele media au fost actualizate din profilul tău';

  @override
  String get tabHome => 'Home';

  @override
  String get tabDiscover => 'Descoperă';

  @override
  String get tabCreate => 'Creează';

  @override
  String get tabReels => 'Reels';

  @override
  String get tabProfile => 'Profil';

  @override
  String get signInToUploadMedia => 'Conectează-te ca să încarci media.';

  @override
  String get noMediaServer =>
      'Niciun server media configurat. Adaugă unul în Setări.';

  @override
  String serverNoResponse(Object server) {
    return '$server: niciun răspuns';
  }

  @override
  String serverUnreachable(Object server, Object error) {
    return '$server: inaccesibil ($error)';
  }

  @override
  String uploadRejected(Object reason) {
    return 'Încărcare respinsă — $reason';
  }

  @override
  String noServerAcceptedFile(Object reasons) {
    return 'Niciun server nu a acceptat fișierul — $reasons';
  }

  @override
  String get blossomInvalidResponse => 'răspuns nevalid';

  @override
  String get blossomInvalidFileUrl => 'adresă de fișier nevalidă';

  @override
  String get blossomServerAlteredFile => 'serverul a modificat fișierul';

  @override
  String get blossomBadRequest => 'cerere nevalidă';

  @override
  String get blossomUnauthorized => 'autorizare refuzată';

  @override
  String get blossomPaymentRequired => 'plată necesară';

  @override
  String get blossomForbidden => 'nepermis';

  @override
  String get blossomLengthRequired => 'lipsește dimensiunea';

  @override
  String get blossomTooLarge => 'fișier prea mare';

  @override
  String get blossomUnsupportedType => 'format neacceptat';

  @override
  String get blossomTooManyRequests => 'prea multe cereri';

  @override
  String get blossomServerError => 'eroare de server';

  @override
  String get cipherInvalidKey => 'Cheie nevalidă';

  @override
  String get cipherTruncated => 'Fișierul criptat este trunchiat';

  @override
  String get cipherMismatch =>
      'Fișierul nu corespunde cheii: modificat sau corupt';

  @override
  String get sanitizeHeifNeedsAsync =>
      'Format HEIC/AVIF: conversia necesită sanitizeAsync';

  @override
  String get sanitizeWebmUnsupported =>
      'Videoclipul WebM/MKV nu este acceptat: folosește MP4 sau MOV ca să poată fi eliminate metadatele înainte de încărcare.';

  @override
  String get sanitizeUnknownFormat =>
      'Format de fișier nerecunoscut: fotografii JPEG/PNG/WebP/GIF sau videoclipuri MP4/MOV.';

  @override
  String sanitizeLeftovers(Object items) {
    return 'Nu s-au putut elimina toate metadatele ($items): fișierul nu a fost încărcat.';
  }

  @override
  String sanitizeProcessingFailed(Object error) {
    return 'Fișierul nu a putut fi procesat: $error';
  }

  @override
  String get sanitizeJpegInvalid => 'JPEG nevalid';

  @override
  String get sanitizeJpegTruncated => 'JPEG trunchiat';

  @override
  String get sanitizeJpegNoSize => 'JPEG fără dimensiuni';

  @override
  String get sanitizeJpegUndecodable => 'JPEG-ul nu poate fi decodat';

  @override
  String get sanitizePngTruncated => 'PNG trunchiat';

  @override
  String get sanitizePngInvalid => 'PNG nevalid';

  @override
  String get sanitizeGifInvalid => 'GIF nevalid';

  @override
  String get sanitizeGifTruncated => 'GIF trunchiat';

  @override
  String get sanitizeWebpTruncated => 'WebP trunchiat';

  @override
  String get sanitizeWebpInvalid => 'WebP nevalid';

  @override
  String get sanitizeMp4Invalid => 'Videoclip MP4/MOV nevalid';

  @override
  String get sanitizeConversionFailed => 'Conversia a eșuat';

  @override
  String get sanitizeHeifUnsupported =>
      'Acest format (HEIC/AVIF) nu poate fi convertit pe acest dispozitiv. Alege o fotografie JPEG sau PNG.';

  @override
  String get privateMediaNotEncrypted => 'Media nu este criptat';

  @override
  String serverReplied(Object status) {
    return 'Serverul a răspuns $status';
  }

  @override
  String get fileTooLarge => 'Fișier prea mare';

  @override
  String get serverFileNotOriginal =>
      'Fișierul de pe server nu este originalul';

  @override
  String get contentMismatch => 'Conținutul nu corespunde';

  @override
  String get mediaUnreachable => 'Media inaccesibil';

  @override
  String get amberInvalidKey => 'Amber a returnat o cheie nevalidă';

  @override
  String get amberNoKey => 'Amber nu a returnat o cheie';

  @override
  String get amberRequestRejected => 'Cerere respinsă în Amber';

  @override
  String get amberAndroidOnly => 'Amber este disponibil doar pe Android';

  @override
  String get amberEmptySignature => 'Amber a returnat o semnătură goală';

  @override
  String get amberSignRejected => 'Semnătură respinsă în Amber';

  @override
  String get amberTimeout => 'Amber nu a răspuns la timp';

  @override
  String get amberEmptyResponse => 'Amber a returnat un răspuns gol';

  @override
  String get bunkerInvalidUrl => 'URL bunker nevalid';

  @override
  String get bunkerNoRelay => 'bunker-ul nu listează niciun relay';

  @override
  String get bunkerWebAuth =>
      'bunker-ul cere autorizare web (auth_url nu este acceptat)';

  @override
  String get bunkerInvalidKey => 'bunker-ul nu a returnat o cheie validă';

  @override
  String get signerInvalidResponse =>
      'Semnatarul a returnat un eveniment semnat nevalid';

  @override
  String get bunkerTimeout => 'Bunker nu a răspuns la timp';

  @override
  String get nwcInvalidUri => 'URI NWC nevalid';

  @override
  String get nwcNoRelay => 'URI-ul NWC nu listează niciun relay';

  @override
  String get nwcNoSecret => 'URI-ul NWC nu conține un secret valid';

  @override
  String get nwcTimeout => 'Portofelul nu a răspuns la timp';

  @override
  String get signerNoPrivateMessages =>
      'Această metodă de conectare nu acceptă mesaje private';

  @override
  String get zapNotSupported => 'Această adresă nu acceptă zap Nostr';

  @override
  String zapAmountOutOfRange(Object min, Object max) {
    return 'Sumă în afara intervalului ($min–$max sats)';
  }

  @override
  String get commentNotSent =>
      'Comentariul nu a fost trimis. Încearcă mai târziu.';

  @override
  String get comments => 'Comentarii';

  @override
  String get noCommentsYet => 'Niciun comentariu încă.';

  @override
  String get signInToComment => 'Conectează-te ca să comentezi.';

  @override
  String get addComment => 'Adaugă un comentariu…';

  @override
  String get signInToPublish => 'Conectează-te ca să publici.';

  @override
  String get addMediaFirst =>
      'Adaugă cel puțin o fotografie sau un videoclip înainte să publici.';

  @override
  String get removingMetadata => 'Se elimină metadatele…';

  @override
  String uploadingProgress(Object current, Object total) {
    return 'Se încarcă $current din $total…';
  }

  @override
  String get creatingPreview => 'Se creează previzualizarea…';

  @override
  String uploadFailed(Object error) {
    return 'Încărcarea a eșuat: $error';
  }

  @override
  String get publishing => 'Se publică…';

  @override
  String noRelayAcceptedPost(Object reason) {
    return 'Niciun relay nu a acceptat postarea$reason. Conținutul rămâne în ciorne.';
  }

  @override
  String get privateNeedsKeySigner =>
      'Această metodă de conectare nu acceptă conținut privat. Folosește Amber, un bunker sau cheia locală.';

  @override
  String get closeFriendsListEmptyAddSomeone =>
      'Lista ta de prieteni apropiați este goală: adaugă pe cineva.';

  @override
  String get fileOver100Mb =>
      'Fișierul depășește 100 MB: aceasta este limita pentru prieteni apropiați (este criptat integral pe telefonul tău).';

  @override
  String get encryptingOnPhone => 'Se criptează pe telefonul tău…';

  @override
  String noServerAcceptedEncrypted(Object details) {
    return 'Niciunul dintre serverele tale media nu a acceptat fișierul criptat. Nu este publicat în clar. Adaugă în Setări un server care acceptă fișiere criptate (de exemplu cdn.hzrd149.com). $details';
  }

  @override
  String get sendingToFriends => 'Se trimite prietenilor…';

  @override
  String sendingToFriendsProgress(Object done, Object total) {
    return 'Se trimite prietenilor $done/$total…';
  }

  @override
  String noFriendReceivedPost(Object reason) {
    return 'Niciun prieten nu a primit postarea$reason. Conținutul rămâne în ciorne.';
  }

  @override
  String sentToCloseFriends(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Trimis către $count prieteni apropiați 🔒',
      one: 'Trimis către 1 prieten apropiat 🔒',
    );
    return '$_temp0';
  }

  @override
  String sentToFriendsWithMisses(int delivered, Object missed) {
    String _temp0 = intl.Intl.pluralLogic(
      delivered,
      locale: localeName,
      other: 'Trimis către $delivered prieteni.',
      one: 'Trimis către 1 prieten.',
    );
    return '$_temp0 $missed nu l-au primit (mesajele private sunt oprite).';
  }

  @override
  String get altText => 'Text alternativ';

  @override
  String get altTextHint => 'Descrie conținutul pentru cine nu îl poate vedea…';

  @override
  String get cancel => 'Anulează';

  @override
  String get save => 'Salvează';

  @override
  String get momentPublished => 'Moment publicat ✨';

  @override
  String get newMoment => 'Moment nou';

  @override
  String get publish => 'Publică';

  @override
  String get guestMode => 'Mod oaspete';

  @override
  String get signInToPostMoments =>
      'Conectează-te ca să îți publici momentele.';

  @override
  String get signIn => 'Conectează-te';

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
      'Story-urile expiră după 24 de ore pe relays care respectă NIP-40, dar alții le pot salva sau arhiva.';

  @override
  String get fromGallery => 'Din galerie';

  @override
  String get galleryLongPressVideo => 'Galerie (apasă lung pentru video)';

  @override
  String get addVideo => 'Adaugă video';

  @override
  String get camera => 'Cameră';

  @override
  String get exifRemovedNote =>
      'Metadatele de locație (EXIF) sunt eliminate automat.';

  @override
  String get writeCaption => 'Scrie o legendă…';

  @override
  String get privatePostNote =>
      'Postare privată: fără hashtag-uri publice, nu poate fi găsită prin căutare.';

  @override
  String willPublishAs(Object caption) {
    return 'Va fi publicat ca: \"$caption\"';
  }

  @override
  String get tapThumbnailForAlt =>
      'Atinge o miniatură ca să adaugi text alternativ.';

  @override
  String get sensitiveContent => 'Conținut sensibil';

  @override
  String get sensitiveContentNote =>
      'Postarea va fi ascunsă în spatele unui avertisment (NIP-36).';

  @override
  String get uploadingMedia => 'Se încarcă media…';

  @override
  String get audiencePublic => 'Public';

  @override
  String get closeFriends => 'Prieteni apropiați';

  @override
  String get signerCannotPublishCloseFriends =>
      'Cu această metodă de conectare nu poți publica pentru prieteni apropiați: folosește Amber, un bunker sau cheia locală.';

  @override
  String get closeFriendsEmptyPrompt =>
      'Lista ta este goală: adaugă persoanele care pot vedea această postare.';

  @override
  String onlyYourCloseFriendsSee(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Doar cei $count prieteni apropiați ai tăi vor vedea asta. Fotografiile și videoclipurile sunt criptate pe telefonul tău înainte să fie încărcate.',
      one: 'Doar 1 prieten apropiat al tău va vedea asta. Fotografiile și videoclipurile sunt criptate pe telefonul tău înainte să fie încărcate.',
    );
    return '$_temp0';
  }

  @override
  String get addFriends => 'Adaugă prieteni';

  @override
  String get manageList => 'Gestionează lista';

  @override
  String get edit => 'Editează';

  @override
  String get reset => 'Resetează';

  @override
  String get apply => 'Aplică';

  @override
  String get cropFree => 'Liber';

  @override
  String get cropOriginal => 'Original';

  @override
  String get rotate => 'Rotește';

  @override
  String get flip => 'Întoarce';

  @override
  String get brightness => 'Luminozitate';

  @override
  String get contrast => 'Contrast';

  @override
  String get saturation => 'Saturație';

  @override
  String postsByAuthor(Object author) {
    return 'Postări de $author…';
  }

  @override
  String get searchHint => 'Caută persoane, hashtag-uri sau cuvinte…';

  @override
  String get clear => 'Golește';

  @override
  String get recent => 'Recente';

  @override
  String get searchDependsOnRelays =>
      'Căutarea depinde de relays configurate: rezultatele pot fi parțiale.';

  @override
  String get recentPostsEverywhere =>
      'Postări recente din toată rețeaua, inclusiv de la persoane pe care nu le urmărești.';

  @override
  String get noResultsOnRelays => 'Niciun rezultat pe relays configurate.';

  @override
  String get noRecentPostsFromFollowed =>
      'Nicio postare recentă de la persoanele pe care le urmărești.';

  @override
  String get noMomentsFound =>
      'Niciun moment găsit pe relays. Verifică conexiunea.';

  @override
  String get loadFailed => 'Încărcarea a eșuat';

  @override
  String get notifications => 'Notificări';

  @override
  String get messages => 'Mesaje';

  @override
  String get homeEmptyFollowsNobody =>
      'Postările persoanelor pe care le urmărești apar aici.\nNu urmărești pe nimeni încă: Descoperă persoane și profiluri interesante.';

  @override
  String get discoverPeople => 'Descoperă persoane';

  @override
  String get homeEmpty =>
      'Niciun moment încă.\nTrage în jos ca să reîmprospătezi sau publică prima ta fotografie.';

  @override
  String get retry => 'Încearcă din nou';

  @override
  String get seenEverything => 'Ai văzut totul deocamdată ✨';

  @override
  String get discoverMoreProfiles => 'Descoperă mai multe profiluri';

  @override
  String get feedFollowing => 'Urmărite';

  @override
  String get signInToSeeFollowed =>
      'Conectează-te ca să vezi postările persoanelor pe care le urmărești';

  @override
  String get videoPreview => 'Previzualizare video';

  @override
  String get cannotOpenPrivateVideo =>
      'Nu se poate deschide videoclipul privat';

  @override
  String get cannotPlayVideo => 'Nu se poate reda videoclipul';

  @override
  String get pauseVideo => 'Pune videoclipul pe pauză';

  @override
  String get playVideo => 'Redă videoclipul';

  @override
  String errorTapToRetry(Object error) {
    return '$error — atinge ca să reîncerci';
  }

  @override
  String get soundOn => 'Pornește sunetul';

  @override
  String get soundOff => 'Oprește sunetul';

  @override
  String get postImage => 'Imaginea postării';

  @override
  String get imageUnavailable => 'Imagine indisponibilă';

  @override
  String errorTapToRetryNewline(Object message) {
    return '$message\nAtinge ca să reîncerci';
  }

  @override
  String get cannotOpenPrivateContent =>
      'Nu se poate deschide acest conținut privat';

  @override
  String get privateImage => 'Imagine privată';

  @override
  String get invalidImage => 'Imagine nevalidă';

  @override
  String get more => 'Mai mult';

  @override
  String get removeFromSaved => 'Elimină din salvate';

  @override
  String get copyLink => 'Copiază linkul';

  @override
  String get muteAuthor => 'Pune autorul pe mut';

  @override
  String get blockAuthor => 'Blochează autorul';

  @override
  String get report => 'Raportează';

  @override
  String get like => 'Îmi place';

  @override
  String get sendInMessage => 'Trimite într-un mesaj';

  @override
  String get zapOptional => 'Zap (opțional)';

  @override
  String get closeFriendsOnlyNote =>
      'Vizibil doar pentru prieteni apropiați. Aprecierile și răspunsurile merg doar la autor.';

  @override
  String get likeFailed => 'Aprecierea nu a putut fi trimisă';

  @override
  String get nostrLinkCopied => 'Linkul Nostr a fost copiat în clipboard';

  @override
  String get authorMuted => 'Autor pus pe mut';

  @override
  String get authorBlocked => 'Autor blocat';

  @override
  String get reportSent => 'Raport trimis (NIP-56)';

  @override
  String get signInToReport => 'Conectează-te ca să raportezi';

  @override
  String minutesAgo(Object minutes) {
    return 'acum $minutes min';
  }

  @override
  String get show => 'Arată';

  @override
  String get chatEmptyHint =>
      'Scrie primul mesaj.\nEste criptat: doar voi doi îl puteți vedea.';

  @override
  String get messageHint => 'Mesaj…';

  @override
  String get send => 'Trimite';

  @override
  String get notSentSuffix => ' netrimis';

  @override
  String get contentUnavailable =>
      'Conținut indisponibil (expirat sau negăsit pe relays)';

  @override
  String get signInToSendPrivateMessages =>
      'Conectează-te ca să trimiți mesaje private.';

  @override
  String get cannotMessageYourself => 'Nu îți poți scrie ție.';

  @override
  String get recipientNoPrivateMessages =>
      'Această persoană nu a activat încă mesajele private.';

  @override
  String noRecipientRelayAccepted(Object reason) {
    return 'Niciun relay al destinatarului nu a acceptat mesajul$reason.';
  }

  @override
  String sendFailed(Object error) {
    return 'Trimiterea a eșuat: $error';
  }

  @override
  String get signInToReadMessages =>
      'Conectează-te ca să citești și să trimiți mesaje private.';

  @override
  String get signerNoPrivateMessagesLong =>
      'Mesajele private nu pot fi folosite cu această metodă de conectare. Conectează-te cu Amber, un bunker sau cheia locală.';

  @override
  String get inboxEmpty =>
      'Nicio conversație.\nAtinge creionul ca să scrii cuiva sau redirecționează un moment cu iconița ✈ de sub fiecare postare.';

  @override
  String get newMessage => 'Mesaj nou';

  @override
  String get privateMessagesEnabled => 'Mesaje private activate';

  @override
  String get enableMessagesFailed => 'Nu s-au putut activa. Încearcă din nou.';

  @override
  String get enablePrivateMessages => 'Activează mesajele private';

  @override
  String enablePrivateMessagesExplain(Object count) {
    return 'Ca să primești mesaje, trebuie să spui pe care relays să ajungă. Se publică o listă mică (NIP-17) cu $count relays implicite: o poți schimba mai târziu. Mesajele rămân criptate: relays nu văd nici cine scrie, nici textul.';
  }

  @override
  String get turnOn => 'Activează';

  @override
  String get searchByNameOrUsername => 'Caută după nume sau nume de utilizator';

  @override
  String get searching => 'Se caută…';

  @override
  String get noOneWithNameHint =>
      'Nimeni cu acest nume. Încearcă mai puține litere sau o adresă ca name@domain.com.';

  @override
  String get sent => 'Trimis';

  @override
  String sentToPeople(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Trimis către $count persoane',
      one: 'Trimis către 1 persoană',
    );
    return '$_temp0';
  }

  @override
  String sentToPeopleWithFailure(int count, Object failure) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Trimis către $count persoane. $failure',
      one: 'Trimis către 1 persoană. $failure',
    );
    return '$_temp0';
  }

  @override
  String get signerNoPrivateMessagesShort =>
      'Nu poți folosi mesaje private cu această metodă de conectare.';

  @override
  String get followToStartOrSearch =>
      'Urmărește pe cineva ca să începi sau caută după nume.';

  @override
  String get addMessage => 'Adaugă un mesaj…';

  @override
  String sendWithCount(Object count) {
    return 'Trimite ($count)';
  }

  @override
  String get linkCopied => 'Link copiat în clipboard';

  @override
  String get noNotifications => 'Nicio notificare acum.';

  @override
  String get notificationsDependOnRelays =>
      'Notificările depind de relays: pot fi incomplete.';

  @override
  String get reactedToYourMoment => 'a reacționat la momentul tău';

  @override
  String commentedText(Object text) {
    return 'a comentat: $text';
  }

  @override
  String sentYouSats(Object sats, Object comment) {
    return 'ți-a trimis $sats sats$comment';
  }

  @override
  String get sentYouZap => 'ți-a trimis un zap';

  @override
  String get startedFollowingYou => 'a început să te urmărească';

  @override
  String get amberNotFound => 'Amber nu a fost găsit';

  @override
  String get amberExplain =>
      'Amber este un semnatar Nostr care îți ține cheia privată în afara Mialuna. Instalează-l și încearcă din nou.';

  @override
  String get downloadFromFdroid => 'Descarcă de pe F-Droid';

  @override
  String get continueWithAmber => 'Continuă cu Amber';

  @override
  String get amberRecommended =>
      'Recomandat: cheia ta privată rămâne în siguranță în Amber.';

  @override
  String get amberNotDetected =>
      'Amber nu a fost detectat: instalează-l pentru conectarea recomandată.';

  @override
  String get exploreWithoutAccount => 'Explorează fără cont';

  @override
  String get remoteBunker => 'bunker la distanță (NIP-46)';

  @override
  String get invalidBunkerUrlDot => 'URL bunker nevalid.';

  @override
  String get connectBunker => 'Conectează bunker';

  @override
  String get advancedNsec => 'Conectare avansată (nsec)';

  @override
  String get nsecWarning =>
      'Atenție: lipirea cheii private este riscantă. Nu o împărtăși cu nimeni. Pe Android preferă Amber.';

  @override
  String get invalidNsec => 'Cheie nsec nevalidă.';

  @override
  String get signInWithNsec => 'Conectează-te cu nsec';

  @override
  String get tagline => 'Momentele tale, sub aceeași lună.';

  @override
  String get skip => 'Omite';

  @override
  String get permissionsAndWallet => 'Permisiuni și portofel';

  @override
  String get permissionsExplain =>
      'Îți permit doar să publici și să primești notificări. Le poți schimba oricând în setările sistemului.';

  @override
  String get photosAndVideos => 'Fotografii și videoclipuri';

  @override
  String get toUploadYourMoments => 'Ca să îți încarci momentele';

  @override
  String get allow => 'Permite';

  @override
  String get reactionsCommentsZaps => 'Reacții, comentarii și zap';

  @override
  String get lightningWalletOptional => 'Portofel Lightning (opțional)';

  @override
  String get nwcExplain =>
      'Conectează un portofel Nostr Wallet Connect ca să trimiți zap fără să părăsești aplicația.';

  @override
  String get walletConnected => 'Portofel conectat';

  @override
  String get disconnect => 'Deconectează';

  @override
  String get connectWallet => 'Conectează portofelul';

  @override
  String get getStarted => 'Începe';

  @override
  String get welcome1 =>
      'Mialuna este o rețea socială vizuală: fotografii, videoclipuri, Reels și story-uri — niciodată postări doar cu text.';

  @override
  String get welcome2 =>
      'Rulează pe Nostr, un protocol deschis: identitatea ta este o cheie pe care o deții, nu un cont pe care o companie îl poate lua. Fără reclame, fără trackere, fără servere centrale.';

  @override
  String get welcome3 =>
      'Împărtășește-ți lumina cu oameni de pretutindeni, din orice aplicație care vorbește aceeași limbă deschisă.';

  @override
  String onboardingWot(int min) {
    return 'Rețeaua de încredere este mereu pornită. Prima dată când deschizi Mialuna, citește pe cine urmărești și construiește fluxul Descoperă din acea rețea: tu, persoanele pe care le urmărești și oricine este urmărit de cel puțin $min dintre ele. Data viitoare când deschizi aplicația, fluxul este deja acolo.';
  }

  @override
  String get publicAndPrivate => 'Public și privat';

  @override
  String get publicAndPrivateIntro =>
      'Mialuna este construită pe Nostr, o rețea deschisă. Ce publici este public: postările, fotografiile și videoclipurile rămân vizibile oricui are linkul, chiar în afara Mialuna.';

  @override
  String get closeFriendsExplain1 =>
      'Doar persoanele de pe această listă primesc postările, story-urile și videoclipurile tale \"prieteni apropiați\". Lista este în postare; nu trebuie să o alegi de fiecare dată.';

  @override
  String get closeFriendsExplain2 =>
      'Fotografiile și videoclipurile sunt criptate pe telefonul tău înainte să fie încărcate. Serverele de fișiere (Blossom) nu criptează nimic singure: de aceea o face Mialuna, iar serverul vede doar date ilizibile. Cine găsește adresa fișierului nu îl poate deschide.';

  @override
  String get closeFriendsExplain3 =>
      'Nu este o garanție absolută: cine primește o postare poate face o captură de ecran, iar scoaterea unui prieten se aplică doar postărilor viitoare.';

  @override
  String get closeFriendsExplain4 =>
      'Fiecare prieten trebuie să folosească Mialuna cu mesajele private activate. Alte aplicații Nostr nu arată aceste postări.';

  @override
  String get closeFriendsExplain5 =>
      'Postările publice rămân publice: fișierele lor sunt vizibile oricui are linkul.';

  @override
  String get closeFriendsExplain6 =>
      'Dacă niciunul dintre serverele tale nu acceptă fișiere criptate, postarea nu este publicată: niciodată în clar.';

  @override
  String get addToCloseFriends => 'Adaugă la prieteni apropiați';

  @override
  String maxFriendsReached(Object max, Object added) {
    return 'Limita de $max prieteni: $added adăugați.';
  }

  @override
  String get add => 'Adaugă';

  @override
  String get signInToCreateList => 'Conectează-te ca să îți creezi lista.';

  @override
  String get signerNoCloseFriends =>
      'Prietenii apropiați nu pot fi folosiți cu această metodă de conectare. Conectează-te cu Amber, un bunker sau cheia locală.';

  @override
  String peopleOfMax(Object count, Object max) {
    return '$count / $max persoane';
  }

  @override
  String get noOneYet => 'Nimeni încă.';

  @override
  String get addPeople => 'Adaugă persoane';

  @override
  String get friendNoPrivateMessagesWarning =>
      'Nu au activat mesajele private: nu vor primi postările tale';

  @override
  String get removeFromList => 'Elimină din listă';

  @override
  String get noOneWithThisName => 'Nimeni cu acest nume.';

  @override
  String get signInToSendPrivateContent =>
      'Conectează-te ca să trimiți conținut privat.';

  @override
  String get reasonNoPrivateMessages => 'nu a activat mesajele private';

  @override
  String get reasonNoRelayAnswered => 'niciun relay nu a răspuns';

  @override
  String get profileUpdated => 'Profil actualizat';

  @override
  String get noRelayAcceptedRetry =>
      'Niciun relay nu a acceptat. Încearcă mai târziu.';

  @override
  String get editProfile => 'Editează profilul';

  @override
  String get fieldName => 'Nume';

  @override
  String get fieldBio => 'Bio';

  @override
  String get fieldAvatarUrl => 'URL avatar';

  @override
  String get fieldNip05 => 'NIP-05 (ex. tu@example.com)';

  @override
  String get browsingAsGuest => 'Navighezi ca Oaspete';

  @override
  String get signInToInteract =>
      'Conectează-te ca să publici, să urmărești și să interacționezi.';

  @override
  String get settings => 'Setări';

  @override
  String get signOut => 'Deconectează-te';

  @override
  String get npubCopied => 'npub copiat';

  @override
  String get copyNpub => 'Copiază npub';

  @override
  String get mute => 'Mut';

  @override
  String get block => 'Blochează';

  @override
  String get posts => 'Postări';

  @override
  String get saved => 'Salvate';

  @override
  String get nothingPublishedYet => 'Nu ai publicat încă nimic.';

  @override
  String get noPostsOnRelays => 'Nicio postare găsită pe relays.';

  @override
  String get noReelsPublished => 'Niciun reels publicat.';

  @override
  String get noReelsOnRelays => 'Niciun reels găsit pe relays.';

  @override
  String get noSavedPosts => 'Nicio postare salvată.';

  @override
  String get followingButton => 'Urmărești';

  @override
  String get follow => 'Urmărește';

  @override
  String get messageButton => 'Mesaj';

  @override
  String get loginLocalKey => 'Cheie locală';

  @override
  String get loginGuest => 'Oaspete';

  @override
  String get followUpdateFailed =>
      'Urmăririle tale nu au putut fi actualizate acum. Încearcă din nou.';

  @override
  String get noReelsComeBack => 'Niciun reels găsit pe relays.\nRevino curând!';

  @override
  String get followUpdateFailedShort =>
      'Urmăririle tale nu au putut fi actualizate acum';

  @override
  String get needOneReadRelay => 'Este necesar cel puțin un relay de citire.';

  @override
  String get listSavedLocally =>
      'Listă salvată pe acest dispozitiv, nepublicată.';

  @override
  String get noRelayAcceptedList =>
      'Niciun relay nu a acceptat lista: se va reîncerca mai târziu.';

  @override
  String relayListPublishedTo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Listă Relay publicată către $count relays',
      one: 'Listă Relay publicată către 1 relay',
    );
    return '$_temp0';
  }

  @override
  String get mediaServersUpdated => 'Servere media actualizate';

  @override
  String get appearance => 'Aspect';

  @override
  String get publishingSettings => 'Publicare';

  @override
  String get addMialunaHashtag => 'Adaugă #mialuna';

  @override
  String get addMialunaHashtagNote =>
      'Adaugă hashtag-ul oficial la postările și story-urile publice. Poți dezactiva oricând.';

  @override
  String get themeLight => 'Luminos';

  @override
  String get themeDark => 'Întunecat';

  @override
  String get themeSystem => 'Sistem';

  @override
  String get relays => 'Relays';

  @override
  String get relaysExplainSignedOut =>
      'Relays stochează și distribuie conținutul. Conectează-te ca să folosești automat lista ta (NIP-65).';

  @override
  String get relaysExplainSynced =>
      'Lista este sincronizată cu profilul tău Nostr (NIP-65): fiecare schimbare este publicată și se aplică tuturor aplicațiilor tale.';

  @override
  String get syncing => 'Se sincronizează…';

  @override
  String get waitingFirstSync => 'Se așteaptă prima sincronizare';

  @override
  String get syncNow => 'Sincronizează acum';

  @override
  String get addRelay => 'Adaugă relay';

  @override
  String get restoreDefaultRelays => 'Restaurează relays implicite';

  @override
  String get createYourList => 'Creează-ți lista';

  @override
  String peopleCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count persoane',
      one: '1 persoană',
    );
    return '$_temp0';
  }

  @override
  String get closeFriendsSettingsNote =>
      'Postări, story-uri și videoclipuri vizibile doar pentru ei, cu fotografii și videoclipuri criptate.';

  @override
  String get mediaServersBlossom => 'Servere media (Blossom)';

  @override
  String get mediaServersExplain =>
      'Fotografiile și videoclipurile se încarcă doar pe aceste servere, în ordinea afișată: primul care le acceptă câștigă. EXIF și locația sunt eliminate înainte de încărcare.';

  @override
  String get primary => 'Principal';

  @override
  String get makePrimary => 'Fă principal';

  @override
  String get remove => 'Elimină';

  @override
  String get addServer => 'Adaugă server';

  @override
  String get moderation => 'Moderare';

  @override
  String get moderationExplain =>
      'Autorii puși pe mut și hashtag-urile ascunse se sincronizează prin NIP-51. Autorii blocați rămân doar pe acest dispozitiv.';

  @override
  String get mutedAuthors => 'Autori puși pe mut';

  @override
  String get noMutedAuthors => 'Niciun autor pus pe mut';

  @override
  String get blockedAuthors => 'Autori blocați';

  @override
  String get noBlockedAuthors => 'Niciun autor blocat';

  @override
  String get hiddenHashtags => 'Hashtag-uri ascunse';

  @override
  String get noHiddenHashtags => 'Niciun hashtag ascuns';

  @override
  String get hashtagToHide => '#hashtag de ascuns';

  @override
  String get storage => 'Stocare';

  @override
  String get clearCache => 'Șterge cache-ul de evenimente și ciornele';

  @override
  String get cacheCleared => 'Cache șters';

  @override
  String get reviewIntro => 'Revezi introducerea';

  @override
  String get reviewIntroSubtitle =>
      'Ce este public, ce este privat și limitele prietenilor apropiați.';

  @override
  String noLightningWalletCopied(Object address) {
    return 'Niciun portofel Lightning găsit: adresă copiată ($address)';
  }

  @override
  String get about => 'Despre';

  @override
  String aboutText(Object version) {
    return 'Mialuna $version — Momentele tale, sub aceeași lună.\nSursă deschisă (MIT). github.com/Lwb89dev/mialuna';
  }

  @override
  String get invalidRelayAddress => 'Adresă nevalidă: folosește wss://…';

  @override
  String get invalidServerAddress => 'Adresă nevalidă: folosește https://…';

  @override
  String get relayRead => 'Citire';

  @override
  String get relayWrite => 'Scriere';

  @override
  String get support => 'Sprijin';

  @override
  String get supportText =>
      'Mialuna este gratuită, nu are reclame și nu te urmărește. Dacă îți place, poți trimite câțiva sats prin Lightning Network.';

  @override
  String get donateWithLightning => 'Donează cu Lightning';

  @override
  String get authorNoZaps => 'Acest autor nu acceptă zap';

  @override
  String get sendZap => 'Trimite un zap ⚡';

  @override
  String get amountInSats => 'Sumă în sats';

  @override
  String minMaxSats(Object min, Object max) {
    return 'min $min – max $max';
  }

  @override
  String get zap => 'Zap';

  @override
  String get signInToZap => 'Conectează-te ca să trimiți zap';

  @override
  String zapSent(Object sats) {
    return 'Zap de $sats sats trimis ⚡';
  }

  @override
  String nwcPaymentFailed(Object error) {
    return 'Plata NWC a eșuat: $error';
  }

  @override
  String get noLightningWallet => 'Niciun portofel Lightning găsit';

  @override
  String storiesRailLabel(Object state) {
    return 'Story-uri, $state';
  }

  @override
  String get close => 'Închide';

  @override
  String hoursAgo(int hours) {
    return 'acum $hours h';
  }

  @override
  String daysAgo(int days) {
    return 'acum $days z';
  }

  @override
  String get now => 'acum';

  @override
  String get youPrefix => 'Tu: ';

  @override
  String get storiesStateUnseen => 'nou';

  @override
  String get storiesStateSeen => 'văzut';

  @override
  String weekdayShort(String day) {
    String _temp0 = intl.Intl.selectLogic(day, {
      'mon': 'Lu',
      'tue': 'Ma',
      'wed': 'Mi',
      'thu': 'Jo',
      'fri': 'Vi',
      'sat': 'Sâ',
      'sun': 'Du',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get sharedAMoment => 'A distribuit un moment';

  @override
  String get blossomOtherError => 'eroare';

  @override
  String get languageTitle => 'Limbă';

  @override
  String get languageSystem => 'Sistem';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageItalian => 'Italiano';

  @override
  String get cannotEditPhoto => 'Această fotografie nu poate fi editată aici.';

  @override
  String notificationsNew(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count notificări noi',
      one: '1 notificare nouă',
    );
    return '$_temp0';
  }

  @override
  String messagesUnread(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mesaje necitite',
      one: '1 mesaj necitit',
    );
    return '$_temp0';
  }

  @override
  String get done => 'Gata';

  @override
  String get storyAddText => 'Adaugă text';

  @override
  String get storyEditText => 'Editează textul';

  @override
  String get storyTextHint => 'Scrie ceva… #hashtag se poate atinge';

  @override
  String get storyTextsHelp =>
      'Atinge imaginea ca să scrii. Trage ca să muți, ciupește ca să redimensionezi și să rotești, atinge un text ca să îl editezi.';

  @override
  String storyTextsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count texte',
      one: '1 text',
      zero: 'Niciun text',
    );
    return '$_temp0';
  }

  @override
  String get storyFontClassic => 'Clasic';

  @override
  String get storyFontBold => 'Aldin';

  @override
  String get storyFontSerif => 'Serif';

  @override
  String get storyFontMono => 'Mono';

  @override
  String get storyFontItalic => 'Cursiv';

  @override
  String get storyTextBackground => 'Fundal text';

  @override
  String get storyTextColor => 'Culoare text';

  @override
  String storyTextLimit(int max) {
    return 'Poți adăuga până la $max texte.';
  }

  @override
  String get wotTitle => 'Rețea de încredere';

  @override
  String get wotEnable => 'Rețeaua de încredere este mereu pornită';

  @override
  String wotExplain(int min) {
    return 'Mereu pornită. Descoperă arată doar această rețea: tu, persoanele pe care le urmărești și oricine este urmărit de cel puțin $min dintre ele. Aceeași rețea de încredere ascunde comentariile, notificările, postările private și mesajele de la toți ceilalți. Se calculează pe acest telefon din listele publice de urmărire la prima deschidere a aplicației; deschiderile următoare o refolosesc. Nu se trimite nimic către vreun server.';
  }

  @override
  String get wotRefresh => 'Reîmprospătează rețeaua acum';

  @override
  String get wotStatusIdle =>
      'Încă neconstruită. Se construiește prima dată când deschizi aplicația.';

  @override
  String get wotBuildingTitle => 'Se construiește fluxul tău Descoperă';

  @override
  String get wotBuildingBody =>
      'Se citește pe cine mai urmăresc persoanele pe care le urmărești și se pregătește Descoperă.';

  @override
  String get wotDiscoverHint =>
      'Doar rețeaua ta de încredere: persoane pe care le urmărești și persoane urmărite de destui dintre ei.';

  @override
  String get wotDiscoverSignIn =>
      'Descoperă arată rețeaua ta de încredere. Conectează-te și, prima dată, Mialuna citește pe cine urmărești și construiește acest flux. Deschiderile următoare îl refolosesc.';

  @override
  String get wotDiscoverEmpty =>
      'Încă nicio postare din rețeaua ta de încredere.';

  @override
  String wotStatusDiscovering(int done, int total) {
    return 'Se verifică pe cine urmăresc urmăririle tale… $done din $total';
  }

  @override
  String wotStatusComplete(int direct, int indirect, Object when) {
    return 'Rețeaua ta: $direct persoane pe care le urmărești plus $indirect urmărite de destui dintre ei. Actualizat $when.';
  }

  @override
  String wotStatusFailed(Object reason) {
    return 'Nu s-a putut calcula rețeaua ta: $reason';
  }

  @override
  String get wotNoFollows => 'încă nu urmărești pe nimeni';

  @override
  String get messageRequests => 'Cereri de mesaje';

  @override
  String messageRequestsSubtitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count conversații din afara rețelei tale de încredere',
      one: '1 conversație din afara rețelei tale de încredere',
    );
    return '$_temp0';
  }

  @override
  String get messageRequestsHint =>
      'De la persoane din afara rețelei tale de încredere. Nu contează ca necitite. Răspunde ca să muți o conversație în inbox.';

  @override
  String get storyViewsSetting =>
      'Lasă-i pe oameni să vadă că le-am văzut story-urile';

  @override
  String get storyViewsSettingExplain =>
      'Când te uiți la un story, o confirmare este trimisă autorului, criptată astfel încât doar el să o poată citi. Îți pune numele lângă al lui; relays nu văd nimic. Dacă nu poate fi livrată, este păstrată și reîncercată mai târziu. Oprește opțiunea ca să te uiți fără să spui nimănui: confirmările încă netrimise sunt eliminate (una deja livrată nu poate fi retrasă).';

  @override
  String storySeenBy(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Văzut de $count persoane',
      one: 'Văzut de 1 persoană',
      zero: 'Nicio vizualizare încă',
    );
    return '$_temp0';
  }

  @override
  String get storyViewsEmpty =>
      'Nimeni nu a văzut încă acest story sau confirmările lor nu au ajuns la tine.';

  @override
  String get storyViewsHint =>
      'Doar persoanele care permit trimit o confirmare, deci numărul real poate fi mai mare.';

  @override
  String get systemNotifications => 'Notificări de sistem';

  @override
  String get systemNotificationsExplain =>
      'Arată o notificare pe telefon când sosește ceva nou cât timp Mialuna este în fundal. Mesajele private nu își arată niciodată textul, nici măcar pe ecranul de blocare. Android pune pe pauză aplicațiile care stau mult în fundal, așa că notificările sosesc cât timp Mialuna încă rulează.';

  @override
  String get systemNotificationsBlocked =>
      'Notificările sunt oprite pentru Mialuna în setările telefonului.';

  @override
  String get systemNotificationsOpenSettings => 'Deschide setările';

  @override
  String get systemNotificationsBattery =>
      'Android adoarme aplicațiile la câteva minute după ce ecranul se stinge, iar notificările se opresc odată cu ele. Ca să le primești în continuare, setează utilizarea bateriei pentru Mialuna la „Nerestricționat”.';

  @override
  String get systemNotificationsBatteryAction => 'Deschide setările bateriei';

  @override
  String get newFollowersSetting => 'Arată urmăritorii noi';

  @override
  String get newFollowersSettingExplain =>
      'Urmăritorii noi apar în Notificări și pe telefon. Oprește dacă te inundă cu urmăriri: aprecierile, comentariile și zap rămân vizibile.';

  @override
  String get systemNotificationMessage => 'ți-a trimis un mesaj privat';

  @override
  String get systemNotificationNewMessage => 'Mesaj privat nou';

  @override
  String get systemNotificationNew => 'Notificare nouă';

  @override
  String get notificationChannelSocial =>
      'Reacții, comentarii, zap și urmăritori';

  @override
  String get notificationChannelMessages => 'Mesaje private';

  @override
  String get zapInvoiceMismatch =>
      'Factura nu corespunde sumei alese. Nu s-a plătit nimic.';

  @override
  String get storyYourStory => 'Story-ul tău';

  @override
  String get storyNew => 'Story nou';

  @override
  String get storyAddSemantics => 'Adaugă la story-ul tău';

  @override
  String storyOwnRailLabel(int count, Object state) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count story-uri',
      one: '1 story',
    );
    return 'Story-ul tău, $_temp0, $state';
  }

  @override
  String get storyTextSize => 'Mărime text';

  @override
  String get storyPickPrompt =>
      'Alege o fotografie sau un videoclip pentru story-ul tău';

  @override
  String get storyEditPhoto => 'Editează fotografia';

  @override
  String get storyCaption => 'Legendă';

  @override
  String get storyDiscardTitle => 'Renunți la acest story?';

  @override
  String get storyDiscard => 'Renunță';

  @override
  String get storyShare => 'Distribuie';

  @override
  String get storyShared => 'Story distribuit';

  @override
  String get deletePost => 'Șterge';

  @override
  String get deletePostTitle => 'Ștergi această postare?';

  @override
  String get deleteStoryTitle => 'Ștergi acest story?';

  @override
  String get deletePostBody =>
      'Mialuna va cere relays să o șteargă și serverelor media să șteargă fotografiile sau videoclipul. Un relay care ignoră cererea, sau cineva care a salvat deja o copie, o poate avea în continuare.';

  @override
  String get deletePrivateBody =>
      'O postare pentru prieteni apropiați nu poate fi retrasă de pe relays. Mialuna va spune aplicațiilor prietenilor tăi să o elimine și va cere serverului media să șteargă fișierele criptate. Un prieten care a salvat deja o copie o poate avea în continuare.';

  @override
  String get deletingPost => 'Se șterge…';

  @override
  String get postDeleted => 'Șters.';

  @override
  String get postWasDeleted => 'Această postare a fost ștearsă.';

  @override
  String get deleteNotAllowed =>
      'Doar contul care a publicat asta o poate șterge.';

  @override
  String deleteFailed(Object reason) {
    return 'Nu s-a putut șterge: $reason';
  }

  @override
  String get deleteNoRelay =>
      'Niciun relay nu a acceptat cererea de ștergere, deci este încă online. Verifică conexiunea și încearcă din nou.';

  @override
  String deleteMediaLeft(Object servers) {
    return 'Media nu a putut fi eliminat de pe $servers.';
  }

  @override
  String get deleteMediaNotAuthorized =>
      'Semnatarul tău nu a autorizat eliminarea media, deci fișierele sunt încă pe serverul media.';

  @override
  String deleteFriendsMissed(Object count) {
    return '$count dintre prietenii tăi apropiați nu au putut fi anunțați, deci poate rămâne pe telefoanele lor.';
  }

  @override
  String get storyCleanupSetting => 'Șterge story-urile mele când expiră';

  @override
  String get storyCleanupSettingExplain =>
      'După 24 de ore Mialuna cere relays și serverelor tale media să șteargă story-urile tale, inclusiv fotografiile și videoclipurile. Un server care ignoră cererea, sau cineva care a păstrat o copie, le poate avea în continuare.';

  @override
  String storyCleanupWaiting(Object count) {
    return 'Semnatarul tău trebuie să aprobe fiecare curățare, așa că așteaptă până ceri. Story-uri expirate în așteptare: $count.';
  }

  @override
  String get storyCleanupNow => 'Șterge acum';

  @override
  String get storyCleanupDone => 'Story-urile expirate au fost șterse.';

  @override
  String get storyCleanupPartly =>
      'Unele nu au putut fi șterse încă; Mialuna va încerca din nou.';

  @override
  String get editorPro => 'Editor Pro';

  @override
  String get editorModeBasic => 'De bază';

  @override
  String get editorModePro => 'Pro';

  @override
  String get toolCrop => 'Decupare';

  @override
  String get toolLight => 'Lumină';

  @override
  String get toolColor => 'Culoare';

  @override
  String get toolHsl => 'HSL';

  @override
  String get toolCurves => 'Curbe';

  @override
  String get toolEffects => 'Efecte';

  @override
  String get straighten => 'Îndreptare';

  @override
  String get exposure => 'Expunere';

  @override
  String get highlights => 'Lumini';

  @override
  String get shadows => 'Umbre';

  @override
  String get whites => 'Albe';

  @override
  String get blacks => 'Negre';

  @override
  String get temperature => 'Temperatură';

  @override
  String get tint => 'Tentă';

  @override
  String get vibrance => 'Vibranță';

  @override
  String get hue => 'Nuanță';

  @override
  String get luminance => 'Luminanță';

  @override
  String get colorRed => 'Roșu';

  @override
  String get colorOrange => 'Portocaliu';

  @override
  String get colorYellow => 'Galben';

  @override
  String get colorGreen => 'Verde';

  @override
  String get colorAqua => 'Turcoaz';

  @override
  String get colorBlue => 'Albastru';

  @override
  String get colorPurple => 'Mov';

  @override
  String get colorMagenta => 'Magenta';

  @override
  String get curveHint =>
      'Trage un punct pentru a modela curba, atinge pentru a adăuga unul, atinge de două ori pentru a-l elimina.';

  @override
  String get sharpen => 'Claritate';

  @override
  String get vignette => 'Vignetare';

  @override
  String get grain => 'Granulație';

  @override
  String get holdForOriginal =>
      'Ține apăsat pe fotografie pentru a o compara cu originalul.';

  @override
  String get showingOriginal => 'Original';

  @override
  String get applyLookToAll => 'Aplică acest aspect tuturor fotografiilor';

  @override
  String get applyingEdits => 'Se procesează fotografiile…';

  @override
  String get choosePhotoToEdit => 'Alege o fotografie de editat';
}
