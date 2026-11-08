// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Finnish (`fi`).
class AppLocalizationsFi extends AppLocalizations {
  AppLocalizationsFi([String locale = 'fi']) : super(locale);

  @override
  String get syncUpToDate => 'Ajan tasalla';

  @override
  String get syncFailed => 'Synkronointi epäonnistui';

  @override
  String get relaysUpdatedFromProfile =>
      'Relays päivitetty profiilistasi (NIP-65)';

  @override
  String get relayListPublished => 'Relay-lista julkaistu';

  @override
  String get mediaServersUpdatedFromProfile =>
      'Mediapalvelimet päivitetty profiilistasi';

  @override
  String get tabHome => 'Home';

  @override
  String get tabDiscover => 'Löydä';

  @override
  String get tabCreate => 'Luo';

  @override
  String get tabReels => 'Reels';

  @override
  String get tabProfile => 'Profiili';

  @override
  String get signInToUploadMedia => 'Kirjaudu ladataksesi mediaa.';

  @override
  String get noMediaServer =>
      'Mediapalvelinta ei ole asetettu. Lisää sellainen asetuksissa.';

  @override
  String serverNoResponse(Object server) {
    return '$server: ei vastausta';
  }

  @override
  String serverUnreachable(Object server, Object error) {
    return '$server: ei tavoitettavissa ($error)';
  }

  @override
  String uploadRejected(Object reason) {
    return 'Lataus hylättiin — $reason';
  }

  @override
  String noServerAcceptedFile(Object reasons) {
    return 'Yksikään palvelin ei hyväksynyt tiedostoa — $reasons';
  }

  @override
  String get blossomInvalidResponse => 'virheellinen vastaus';

  @override
  String get blossomInvalidFileUrl => 'virheellinen tiedosto-osoite';

  @override
  String get blossomServerAlteredFile => 'palvelin muutti tiedostoa';

  @override
  String get blossomBadRequest => 'virheellinen pyyntö';

  @override
  String get blossomUnauthorized => 'valtuutus evätty';

  @override
  String get blossomPaymentRequired => 'maksu vaaditaan';

  @override
  String get blossomForbidden => 'ei sallittu';

  @override
  String get blossomLengthRequired => 'koko puuttuu';

  @override
  String get blossomTooLarge => 'tiedosto liian suuri';

  @override
  String get blossomUnsupportedType => 'muotoa ei hyväksytä';

  @override
  String get blossomTooManyRequests => 'liikaa pyyntöjä';

  @override
  String get blossomServerError => 'palvelinvirhe';

  @override
  String get cipherInvalidKey => 'Virheellinen avain';

  @override
  String get cipherTruncated => 'Salattu tiedosto on katkennut';

  @override
  String get cipherMismatch =>
      'Tiedosto ei vastaa avainta: muutettu tai vioittunut';

  @override
  String get sanitizeHeifNeedsAsync =>
      'HEIC/AVIF-muoto: muunnos vaatii sanitizeAsync';

  @override
  String get sanitizeWebmUnsupported =>
      'WebM/MKV-videota ei tueta: käytä MP4- tai MOV-muotoa, jotta metatiedot voidaan poistaa ennen latausta.';

  @override
  String get sanitizeUnknownFormat =>
      'Tuntematon tiedostomuoto: JPEG/PNG/WebP/GIF-kuvat tai MP4/MOV-videot.';

  @override
  String sanitizeLeftovers(Object items) {
    return 'Kaikkia metatietoja ei voitu poistaa ($items): tiedostoa ei ladattu.';
  }

  @override
  String sanitizeProcessingFailed(Object error) {
    return 'Tiedostoa ei voitu käsitellä: $error';
  }

  @override
  String get sanitizeJpegInvalid => 'Virheellinen JPEG';

  @override
  String get sanitizeJpegTruncated => 'Katkennut JPEG';

  @override
  String get sanitizeJpegNoSize => 'JPEG ilman mittoja';

  @override
  String get sanitizeJpegUndecodable => 'JPEG-kuvaa ei voi purkaa';

  @override
  String get sanitizePngTruncated => 'Katkennut PNG';

  @override
  String get sanitizePngInvalid => 'Virheellinen PNG';

  @override
  String get sanitizeGifInvalid => 'Virheellinen GIF';

  @override
  String get sanitizeGifTruncated => 'Katkennut GIF';

  @override
  String get sanitizeWebpTruncated => 'Katkennut WebP';

  @override
  String get sanitizeWebpInvalid => 'Virheellinen WebP';

  @override
  String get sanitizeMp4Invalid => 'Virheellinen MP4/MOV-video';

  @override
  String get sanitizeConversionFailed => 'Muunnos epäonnistui';

  @override
  String get sanitizeHeifUnsupported =>
      'Tätä muotoa (HEIC/AVIF) ei voi muuntaa tällä laitteella. Valitse JPEG- tai PNG-kuva.';

  @override
  String get privateMediaNotEncrypted => 'Media ei ole salattu';

  @override
  String serverReplied(Object status) {
    return 'Palvelin vastasi $status';
  }

  @override
  String get fileTooLarge => 'Tiedosto liian suuri';

  @override
  String get serverFileNotOriginal => 'Palvelimen tiedosto ei ole alkuperäinen';

  @override
  String get contentMismatch => 'Sisältö ei täsmää';

  @override
  String get mediaUnreachable => 'Media ei tavoitettavissa';

  @override
  String get amberInvalidKey => 'Amber palautti virheellisen avaimen';

  @override
  String get amberNoKey => 'Amber ei palauttanut avainta';

  @override
  String get amberRequestRejected => 'Pyyntö hylättiin Amberissa';

  @override
  String get amberAndroidOnly => 'Amber on vain Androidilla';

  @override
  String get amberEmptySignature => 'Amber palautti tyhjän allekirjoituksen';

  @override
  String get amberSignRejected => 'Allekirjoitus hylättiin Amberissa';

  @override
  String get amberTimeout => 'Amber ei vastannut ajoissa';

  @override
  String get amberEmptyResponse => 'Amber palautti tyhjän vastauksen';

  @override
  String get bunkerInvalidUrl => 'Virheellinen bunker-URL';

  @override
  String get bunkerNoRelay => 'bunker ei listaa yhtään relay-osoitetta';

  @override
  String get bunkerWebAuth =>
      'bunker vaatii verkkoauktorisoinnin (auth_url ei ole tuettu)';

  @override
  String get bunkerInvalidKey => 'bunker ei palauttanut kelvollista avainta';

  @override
  String get signerInvalidResponse =>
      'Allekirjoittaja palautti virheellisen tapahtuman';

  @override
  String get bunkerTimeout => 'Bunker aikakatkaistiin';

  @override
  String get nwcInvalidUri => 'Virheellinen NWC-URI';

  @override
  String get nwcNoRelay => 'NWC-URI ei listaa yhtään relay-osoitetta';

  @override
  String get nwcNoSecret => 'NWC-URI ei sisällä kelvollista salaisuutta';

  @override
  String get nwcTimeout => 'Lompakko aikakatkaistiin';

  @override
  String get signerNoPrivateMessages =>
      'Tämä kirjautumistapa ei tue yksityisviestejä';

  @override
  String get zapNotSupported => 'Tämä osoite ei tue Nostr zaps';

  @override
  String zapAmountOutOfRange(Object min, Object max) {
    return 'Summa alueen ulkopuolella ($min–$max sats)';
  }

  @override
  String get commentNotSent =>
      'Kommenttia ei lähetetty. Yritä myöhemmin uudelleen.';

  @override
  String get comments => 'Kommentit';

  @override
  String get noCommentsYet => 'Ei vielä kommentteja.';

  @override
  String get signInToComment => 'Kirjaudu kommentoidaksesi.';

  @override
  String get addComment => 'Lisää kommentti…';

  @override
  String get signInToPublish => 'Kirjaudu julkaistaksesi.';

  @override
  String get addMediaFirst =>
      'Lisää vähintään yksi kuva tai video ennen julkaisua.';

  @override
  String get removingMetadata => 'Poistetaan metatietoja…';

  @override
  String uploadingProgress(Object current, Object total) {
    return 'Ladataan $current/$total…';
  }

  @override
  String get creatingPreview => 'Luodaan esikatselua…';

  @override
  String uploadFailed(Object error) {
    return 'Lataus epäonnistui: $error';
  }

  @override
  String get publishing => 'Julkaistaan…';

  @override
  String noRelayAcceptedPost(Object reason) {
    return 'Yksikään relay ei hyväksynyt julkaisua$reason. Sisältö jää luonnoksiin.';
  }

  @override
  String get privateNeedsKeySigner =>
      'Tämä kirjautumistapa ei tue yksityistä sisältöä. Käytä Amberia, bunkeria tai paikallista avainta.';

  @override
  String get closeFriendsListEmptyAddSomeone =>
      'Läheisten listasi on tyhjä: lisää joku.';

  @override
  String get fileOver100Mb =>
      'Tiedosto on yli 100 MB: se on läheisten raja (se salataan kokonaan puhelimessasi).';

  @override
  String get encryptingOnPhone => 'Salataan puhelimessasi…';

  @override
  String noServerAcceptedEncrypted(Object details) {
    return 'Yksikään mediapalvelimesi ei hyväksynyt salattua tiedostoa. Sitä ei julkaista selkokielisenä. Lisää asetuksissa palvelin, joka hyväksyy salattuja tiedostoja (esimerkiksi cdn.hzrd149.com). $details';
  }

  @override
  String get sendingToFriends => 'Lähetetään ystäville…';

  @override
  String sendingToFriendsProgress(Object done, Object total) {
    return 'Lähetetään ystäville $done/$total…';
  }

  @override
  String noFriendReceivedPost(Object reason) {
    return 'Yksikään ystävä ei saanut julkaisua$reason. Sisältö jää luonnoksiin.';
  }

  @override
  String sentToCloseFriends(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Lähetetty $count läheiselle 🔒',
      one: 'Lähetetty 1 läheiselle 🔒',
    );
    return '$_temp0';
  }

  @override
  String sentToFriendsWithMisses(int delivered, Object missed) {
    String _temp0 = intl.Intl.pluralLogic(
      delivered,
      locale: localeName,
      other: 'Lähetetty $delivered ystävälle.',
      one: 'Lähetetty 1 ystävälle.',
    );
    return '$_temp0 $missed ei saanut sitä (yksityisviestit ovat pois).';
  }

  @override
  String get altText => 'Alt-teksti';

  @override
  String get altTextHint => 'Kuvaile sisältöä niille, jotka eivät näe sitä…';

  @override
  String get cancel => 'Peruuta';

  @override
  String get save => 'Tallenna';

  @override
  String get momentPublished => 'Hetki julkaistu ✨';

  @override
  String get newMoment => 'Uusi hetki';

  @override
  String get publish => 'Julkaise';

  @override
  String get guestMode => 'Vierastila';

  @override
  String get signInToPostMoments => 'Kirjaudu julkaistaksesi hetkiäsi.';

  @override
  String get signIn => 'Kirjaudu';

  @override
  String get kindPhoto => 'Kuva';

  @override
  String get kindVideo => 'Video';

  @override
  String get kindReel => 'Reel';

  @override
  String get kindStory => 'Tarina';

  @override
  String get storyExpiryNote =>
      'Tarinat vanhenevat 24 tunnissa relays-palvelimilla, jotka noudattavat NIP-40, mutta muut voivat yhä tallentaa tai arkistoida ne.';

  @override
  String get fromGallery => 'Galleriasta';

  @override
  String get galleryLongPressVideo => 'Galleria (paina pitkään videota varten)';

  @override
  String get addVideo => 'Lisää video';

  @override
  String get camera => 'Kamera';

  @override
  String get exifRemovedNote =>
      'Sijaintimetatiedot (EXIF) poistetaan automaattisesti.';

  @override
  String get writeCaption => 'Kirjoita kuvateksti…';

  @override
  String get privatePostNote =>
      'Yksityinen julkaisu: ei julkisia hashtageja, sitä ei löydy haulla.';

  @override
  String willPublishAs(Object caption) {
    return 'Se julkaistaan näin: \"$caption\"';
  }

  @override
  String get tapThumbnailForAlt =>
      'Napauta pikkukuvaa lisätäksesi alt-tekstin.';

  @override
  String get sensitiveContent => 'Arkaluonteinen sisältö';

  @override
  String get sensitiveContentNote =>
      'Julkaisu piilotetaan varoituksen taakse (NIP-36).';

  @override
  String get uploadingMedia => 'Ladataan mediaa…';

  @override
  String get audiencePublic => 'Julkinen';

  @override
  String get closeFriends => 'Läheiset';

  @override
  String get signerCannotPublishCloseFriends =>
      'Tällä kirjautumistavalla et voi julkaista läheisille: käytä Amberia, bunkeria tai paikallista avainta.';

  @override
  String get closeFriendsEmptyPrompt =>
      'Listasi on tyhjä: lisää ihmiset, jotka saavat nähdä tämän julkaisun.';

  @override
  String onlyYourCloseFriendsSee(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Vain $count läheistäsi näkee tämän. Kuvat ja videot salataan puhelimessasi ennen latausta.',
      one: 'Vain 1 läheisesi näkee tämän. Kuvat ja videot salataan puhelimessasi ennen latausta.',
    );
    return '$_temp0';
  }

  @override
  String get addFriends => 'Lisää ystäviä';

  @override
  String get manageList => 'Hallitse listaa';

  @override
  String get edit => 'Muokkaa';

  @override
  String get reset => 'Nollaa';

  @override
  String get apply => 'Käytä';

  @override
  String get cropFree => 'Vapaa';

  @override
  String get cropOriginal => 'Alkuperäinen';

  @override
  String get rotate => 'Kierrä';

  @override
  String get flip => 'Käännä';

  @override
  String get brightness => 'Kirkkaus';

  @override
  String get contrast => 'Kontrasti';

  @override
  String get saturation => 'Kylläisyys';

  @override
  String postsByAuthor(Object author) {
    return 'Julkaisut: $author…';
  }

  @override
  String get searchHint => 'Hae ihmisiä, hashtageja tai sanoja…';

  @override
  String get clear => 'Tyhjennä';

  @override
  String get recent => 'Viimeisimmät';

  @override
  String get searchDependsOnRelays =>
      'Haku riippuu määritetyistä relays: tulokset voivat olla osittaisia.';

  @override
  String get recentPostsEverywhere =>
      'Viimeisimmät julkaisut koko verkosta, myös ihmisiltä joita et seuraa.';

  @override
  String get noResultsOnRelays => 'Ei tuloksia määritetyillä relays.';

  @override
  String get noRecentPostsFromFollowed =>
      'Ei tuoreita julkaisuja ihmisiltä, joita seuraat.';

  @override
  String get noMomentsFound => 'Hetkiä ei löytynyt relays. Tarkista yhteys.';

  @override
  String get loadFailed => 'Lataus epäonnistui';

  @override
  String get notifications => 'Ilmoitukset';

  @override
  String get messages => 'Viestit';

  @override
  String get homeEmptyFollowsNobody =>
      'Seuraamiesi julkaisut näkyvät täällä.\nEt seuraa vielä ketään: löydä kiinnostavia ihmisiä ja profiileja.';

  @override
  String get discoverPeople => 'Löydä ihmisiä';

  @override
  String get homeEmpty =>
      'Ei vielä hetkiä.\nVedä alas päivittääksesi tai julkaise ensimmäinen otoksesi.';

  @override
  String get retry => 'Yritä uudelleen';

  @override
  String get seenEverything => 'Olet nähnyt kaiken toistaiseksi ✨';

  @override
  String get discoverMoreProfiles => 'Löydä lisää profiileja';

  @override
  String get feedFollowing => 'Seurataan';

  @override
  String get signInToSeeFollowed =>
      'Kirjaudu nähdäksesi julkaisut ihmisiltä, joita seuraat';

  @override
  String get videoPreview => 'Videon esikatselu';

  @override
  String get cannotOpenPrivateVideo => 'Yksityistä videota ei voi avata';

  @override
  String get cannotPlayVideo => 'Videota ei voi toistaa';

  @override
  String get pauseVideo => 'Keskeytä video';

  @override
  String get playVideo => 'Toista video';

  @override
  String errorTapToRetry(Object error) {
    return '$error — napauta yrittääksesi uudelleen';
  }

  @override
  String get soundOn => 'Ääni päälle';

  @override
  String get soundOff => 'Ääni pois';

  @override
  String get postImage => 'Julkaisun kuva';

  @override
  String get imageUnavailable => 'Kuva ei saatavilla';

  @override
  String errorTapToRetryNewline(Object message) {
    return '$message\nNapauta yrittääksesi uudelleen';
  }

  @override
  String get cannotOpenPrivateContent =>
      'Tätä yksityistä sisältöä ei voi avata';

  @override
  String get privateImage => 'Yksityinen kuva';

  @override
  String get invalidImage => 'Virheellinen kuva';

  @override
  String get more => 'Enemmän';

  @override
  String get removeFromSaved => 'Poista tallennetuista';

  @override
  String get copyLink => 'Kopioi linkki';

  @override
  String get muteAuthor => 'Mykistä kirjoittaja';

  @override
  String get blockAuthor => 'Estä kirjoittaja';

  @override
  String get report => 'Ilmianna';

  @override
  String get like => 'Tykkää';

  @override
  String get sendInMessage => 'Lähetä viestissä';

  @override
  String get zapOptional => 'Zap (valinnainen)';

  @override
  String get closeFriendsOnlyNote =>
      'Näkyy vain läheisille. Tykkäykset ja vastaukset menevät vain kirjoittajalle.';

  @override
  String get likeFailed => 'Tykkäystä ei voitu lähettää';

  @override
  String get nostrLinkCopied => 'Nostr-linkki kopioitu leikepöydälle';

  @override
  String get authorMuted => 'Kirjoittaja mykistetty';

  @override
  String get authorBlocked => 'Kirjoittaja estetty';

  @override
  String get reportSent => 'Ilmiannus lähetetty (NIP-56)';

  @override
  String get signInToReport => 'Kirjaudu ilmiantaaksesi';

  @override
  String minutesAgo(Object minutes) {
    return '$minutes min sitten';
  }

  @override
  String get show => 'Näytä';

  @override
  String get chatEmptyHint =>
      'Kirjoita ensimmäinen viesti.\nSe on salattu: vain te kaksi näette sen.';

  @override
  String get messageHint => 'Viesti…';

  @override
  String get send => 'Lähetä';

  @override
  String get notSentSuffix => ' ei lähetetty';

  @override
  String get contentUnavailable =>
      'Sisältö ei saatavilla (vanhentunut tai ei löydy relays)';

  @override
  String get signInToSendPrivateMessages =>
      'Kirjaudu lähettääksesi yksityisviestejä.';

  @override
  String get cannotMessageYourself => 'Et voi kirjoittaa itsellesi.';

  @override
  String get recipientNoPrivateMessages =>
      'Tämä henkilö ei ole vielä ottanut yksityisviestejä käyttöön.';

  @override
  String noRecipientRelayAccepted(Object reason) {
    return 'Yksikään vastaanottajan relay$reason ei hyväksynyt viestiä.';
  }

  @override
  String sendFailed(Object error) {
    return 'Lähetys epäonnistui: $error';
  }

  @override
  String get signInToReadMessages =>
      'Kirjaudu lukeaksesi ja lähettääksesi yksityisviestejä.';

  @override
  String get signerNoPrivateMessagesLong =>
      'Yksityisviestejä ei voi käyttää tällä kirjautumistavalla. Kirjaudu Amberilla, bunkerilla tai paikallisella avaimella.';

  @override
  String get inboxEmpty =>
      'Ei keskusteluja.\nNapauta kynää kirjoittaaksesi jollekulle tai välitä hetki ✈-kuvakkeella jokaisen julkaisun alla.';

  @override
  String get newMessage => 'Uusi viesti';

  @override
  String get privateMessagesEnabled => 'Yksityisviestit käytössä';

  @override
  String get enableMessagesFailed =>
      'Käyttöönotto epäonnistui. Yritä uudelleen.';

  @override
  String get enablePrivateMessages => 'Ota yksityisviestit käyttöön';

  @override
  String enablePrivateMessagesExplain(Object count) {
    return 'Jotta saat viestejä, kerro mille relays niiden pitää saapua. Pieni lista (NIP-17) julkaistaan ja siinä on $count oletus-relays: voit muuttaa sitä myöhemmin. Viestit pysyvät salattuina: relays eivät näe kuka kirjoittaa eivätkä tekstiä.';
  }

  @override
  String get turnOn => 'Ota käyttöön';

  @override
  String get searchByNameOrUsername => 'Hae nimellä tai käyttäjänimellä';

  @override
  String get searching => 'Haetaan…';

  @override
  String get noOneWithNameHint =>
      'Ketään tällä nimellä. Kokeile vähemmän kirjaimia tai osoitetta kuten name@domain.com.';

  @override
  String get sent => 'Lähetetty';

  @override
  String sentToPeople(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Lähetetty $count henkilölle',
      one: 'Lähetetty 1 henkilölle',
    );
    return '$_temp0';
  }

  @override
  String sentToPeopleWithFailure(int count, Object failure) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Lähetetty $count henkilölle. $failure',
      one: 'Lähetetty 1 henkilölle. $failure',
    );
    return '$_temp0';
  }

  @override
  String get signerNoPrivateMessagesShort =>
      'Et voi käyttää yksityisviestejä tällä kirjautumistavalla.';

  @override
  String get followToStartOrSearch =>
      'Seuraa jotakuta aloittaaksesi tai hae nimellä.';

  @override
  String get addMessage => 'Lisää viesti…';

  @override
  String sendWithCount(Object count) {
    return 'Lähetä ($count)';
  }

  @override
  String get linkCopied => 'Linkki kopioitu leikepöydälle';

  @override
  String get noNotifications => 'Ei ilmoituksia juuri nyt.';

  @override
  String get notificationsDependOnRelays =>
      'Ilmoitukset riippuvat relays: ne voivat olla puutteellisia.';

  @override
  String get reactedToYourMoment => 'reagoi hetkeesi';

  @override
  String commentedText(Object text) {
    return 'kommentoi: $text';
  }

  @override
  String sentYouSats(Object sats, Object comment) {
    return 'lähetti sinulle $sats sats$comment';
  }

  @override
  String get sentYouZap => 'lähetti sinulle zap';

  @override
  String get startedFollowingYou => 'alkoi seurata sinua';

  @override
  String get amberNotFound => 'Amberia ei löydy';

  @override
  String get amberExplain =>
      'Amber on Nostr-allekirjoittaja, joka pitää yksityisen avaimesi Mialunan ulkopuolella. Asenna se ja yritä uudelleen.';

  @override
  String get downloadFromFdroid => 'Lataa F-Droidista';

  @override
  String get continueWithAmber => 'Jatka Amberilla';

  @override
  String get amberRecommended =>
      'Suositeltu: yksityinen avaimesi pysyy turvassa Amberissa.';

  @override
  String get amberNotDetected =>
      'Amberia ei havaittu: asenna se suositeltua kirjautumista varten.';

  @override
  String get exploreWithoutAccount => 'Selaa ilman tiliä';

  @override
  String get remoteBunker => 'Etä-bunker (NIP-46)';

  @override
  String get invalidBunkerUrlDot => 'Virheellinen bunker-URL.';

  @override
  String get connectBunker => 'Yhdistä bunker';

  @override
  String get advancedNsec => 'Edistynyt kirjautuminen (nsec)';

  @override
  String get nsecWarning =>
      'Varoitus: yksityisen avaimen liittäminen on vaarallista. Älä jaa sitä kenellekään. Androidilla suosi Amberia.';

  @override
  String get invalidNsec => 'Virheellinen nsec-avain.';

  @override
  String get signInWithNsec => 'Kirjaudu nsec-avaimella';

  @override
  String get tagline => 'Hetkesi saman kuun alla.';

  @override
  String get skip => 'Ohita';

  @override
  String get permissionsAndWallet => 'Luvat ja lompakko';

  @override
  String get permissionsExplain =>
      'Ne antavat vain julkaista ja saada ilmoituksia. Voit muuttaa niitä milloin tahansa järjestelmän asetuksissa.';

  @override
  String get photosAndVideos => 'Kuvat ja videot';

  @override
  String get toUploadYourMoments => 'Omien hetkien lataamiseen';

  @override
  String get allow => 'Salli';

  @override
  String get reactionsCommentsZaps => 'Reaktiot, kommentit ja zaps';

  @override
  String get lightningWalletOptional => 'Lightning-lompakko (valinnainen)';

  @override
  String get nwcExplain =>
      'Yhdistä Nostr Wallet Connect -lompakko, niin lähetät zaps poistumatta sovelluksesta.';

  @override
  String get walletConnected => 'Lompakko yhdistetty';

  @override
  String get disconnect => 'Katkaise';

  @override
  String get connectWallet => 'Yhdistä lompakko';

  @override
  String get getStarted => 'Aloita';

  @override
  String get welcome1 =>
      'Mialuna on visuaalinen sosiaalinen verkko: kuvia, videoita, Reels ja tarinoita — ei koskaan pelkkää tekstiä.';

  @override
  String get welcome2 =>
      'Se toimii Nostrilla, avoimella protokollalla: henkilöllisyytesi on avain jonka omistat, ei tili jonka yritys voi viedä. Ei mainoksia, ei seurantaa, ei keskitettyjä palvelimia.';

  @override
  String get welcome3 =>
      'Jaa valoasi ihmisille kaikkialla, mistä tahansa sovelluksesta joka puhuu samaa avointa kieltä.';

  @override
  String onboardingWot(int min) {
    return 'Luottamusverkko on aina päällä. Kun avaat Mialunan ensimmäisen kerran, se lukee ketä seuraat ja rakentaa Löydä-syötteen siitä verkosta: sinä, ihmiset joita seuraat ja kaikki joita vähintään $min heistä seuraa. Seuraavilla kerroilla syöte on jo valmiina.';
  }

  @override
  String get publicAndPrivate => 'Julkinen ja yksityinen';

  @override
  String get publicAndPrivateIntro =>
      'Mialuna rakentuu Nostrin varaan, avoimeen verkkoon. Julkaisemasi on julkista: julkaisut, kuvat ja videot pysyvät näkyvissä kaikille joilla on linkki, myös Mialunan ulkopuolella.';

  @override
  String get closeFriendsExplain1 =>
      'Vain tämän listan ihmiset saavat \"Läheiset\"-julkaisusi, tarinasi ja videosi. Lista on julkaisun sisällä; sitä ei tarvitse valita joka kerta.';

  @override
  String get closeFriendsExplain2 =>
      'Kuvat ja videot salataan puhelimessasi ennen latausta. Tiedostopalvelimet (Blossom) eivät salaa mitään itse: siksi Mialuna tekee sen, ja palvelin näkee vain lukukelvotonta dataa. Tiedoston osoitteen löytänyt ei voi avata sitä.';

  @override
  String get closeFriendsExplain3 =>
      'Se ei ole ehdoton takuu: julkaisun saanut voi ottaa kuvakaappauksen, ja ystävän poistaminen koskee vain tulevia julkaisuja.';

  @override
  String get closeFriendsExplain4 =>
      'Jokaisen ystävän on käytettävä Mialunaa yksityisviestit päällä. Muut Nostr-sovellukset eivät näytä näitä julkaisuja.';

  @override
  String get closeFriendsExplain5 =>
      'Julkiset julkaisut pysyvät julkisina: niiden tiedostot näkyvät kaikille, joilla on linkki.';

  @override
  String get closeFriendsExplain6 =>
      'Jos yksikään palvelimesi ei hyväksy salattuja tiedostoja, julkaisua ei julkaista: ei koskaan selkokielisenä.';

  @override
  String get addToCloseFriends => 'Lisää läheisiin';

  @override
  String maxFriendsReached(Object max, Object added) {
    return 'Raja $max ystävää: $added lisätty.';
  }

  @override
  String get add => 'Lisää';

  @override
  String get signInToCreateList => 'Kirjaudu luodaksesi listan.';

  @override
  String get signerNoCloseFriends =>
      'Läheisiä ei voi käyttää tällä kirjautumistavalla. Kirjaudu Amberilla, bunkerilla tai paikallisella avaimella.';

  @override
  String peopleOfMax(Object count, Object max) {
    return '$count / $max henkilöä';
  }

  @override
  String get noOneYet => 'Ei vielä ketään.';

  @override
  String get addPeople => 'Lisää ihmisiä';

  @override
  String get friendNoPrivateMessagesWarning =>
      'He eivät ole ottaneet yksityisviestejä käyttöön: he eivät saa julkaisujasi';

  @override
  String get removeFromList => 'Poista listalta';

  @override
  String get noOneWithThisName => 'Ketään tällä nimellä.';

  @override
  String get signInToSendPrivateContent =>
      'Kirjaudu lähettääksesi yksityistä sisältöä.';

  @override
  String get reasonNoPrivateMessages =>
      'ei ole ottanut yksityisviestejä käyttöön';

  @override
  String get reasonNoRelayAnswered => 'yksikään relay ei vastannut';

  @override
  String get profileUpdated => 'Profiili päivitetty';

  @override
  String get noRelayAcceptedRetry =>
      'Yksikään relay ei hyväksynyt. Yritä myöhemmin uudelleen.';

  @override
  String get editProfile => 'Muokkaa profiilia';

  @override
  String get fieldName => 'Nimi';

  @override
  String get fieldBio => 'Esittely';

  @override
  String get fieldAvatarUrl => 'Avatarin URL';

  @override
  String get fieldNip05 => 'NIP-05 (esim. you@example.com)';

  @override
  String get browsingAsGuest => 'Selaat vieraana';

  @override
  String get signInToInteract =>
      'Kirjaudu julkaistaksesi, seurataksesi ja osallistuaksesi.';

  @override
  String get settings => 'Asetukset';

  @override
  String get signOut => 'Kirjaudu ulos';

  @override
  String get npubCopied => 'npub kopioitu';

  @override
  String get copyNpub => 'Kopioi npub';

  @override
  String get mute => 'Mykistä';

  @override
  String get block => 'Estä';

  @override
  String get posts => 'Julkaisut';

  @override
  String get saved => 'Tallennetut';

  @override
  String get nothingPublishedYet => 'Et ole vielä julkaissut mitään.';

  @override
  String get noPostsOnRelays => 'Julkaisuja ei löytynyt relays.';

  @override
  String get noReelsPublished => 'Ei julkaistuja reels.';

  @override
  String get noReelsOnRelays => 'Yhtään reels ei löytynyt relays.';

  @override
  String get noSavedPosts => 'Ei tallennettuja julkaisuja.';

  @override
  String get followingButton => 'Seurataan';

  @override
  String get follow => 'Seuraa';

  @override
  String get messageButton => 'Viesti';

  @override
  String get loginLocalKey => 'Paikallinen avain';

  @override
  String get loginGuest => 'Vieras';

  @override
  String get followUpdateFailed =>
      'Seurauksia ei voitu päivittää juuri nyt. Yritä uudelleen.';

  @override
  String get noReelsComeBack => 'Yhtään reels ei löytynyt relays.\nPalaa pian!';

  @override
  String get followUpdateFailedShort =>
      'Seurauksia ei voitu päivittää juuri nyt';

  @override
  String get needOneReadRelay => 'Tarvitaan vähintään yksi luku-relay.';

  @override
  String get listSavedLocally =>
      'Lista tallennettu tälle laitteelle, ei julkaistu.';

  @override
  String get noRelayAcceptedList =>
      'Yksikään relay ei hyväksynyt listaa: yritys toistetaan myöhemmin.';

  @override
  String relayListPublishedTo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Relay-lista julkaistu $count relays',
      one: 'Relay-lista julkaistu 1 relaylle',
    );
    return '$_temp0';
  }

  @override
  String get mediaServersUpdated => 'Mediapalvelimet päivitetty';

  @override
  String get appearance => 'Ulkoasu';

  @override
  String get publishingSettings => 'Julkaisu';

  @override
  String get addMialunaHashtag => 'Lisää #mialuna';

  @override
  String get addMialunaHashtagNote =>
      'Lisää virallinen hashtag julkisiin julkaisuihin ja tarinoihin. Voit poistaa tämän käytöstä milloin tahansa.';

  @override
  String get themeLight => 'Vaalea';

  @override
  String get themeDark => 'Tumma';

  @override
  String get themeSystem => 'Järjestelmä';

  @override
  String get relays => 'Relays';

  @override
  String get relaysExplainSignedOut =>
      'Relays tallentavat ja jakavat sisältöä. Kirjaudu käyttääksesi omaa listaasi automaattisesti (NIP-65).';

  @override
  String get relaysExplainSynced =>
      'Lista synkronoidaan Nostr-profiiliisi (NIP-65): jokainen muutos julkaistaan ja koskee kaikkia sovelluksiasi.';

  @override
  String get syncing => 'Synkronoidaan…';

  @override
  String get waitingFirstSync => 'Odotetaan ensimmäistä synkronointia';

  @override
  String get syncNow => 'Synkronoi nyt';

  @override
  String get addRelay => 'Lisää relay';

  @override
  String get restoreDefaultRelays => 'Palauta oletus-relays';

  @override
  String get createYourList => 'Luo oma listasi';

  @override
  String peopleCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count henkilöä',
      one: '1 henkilö',
    );
    return '$_temp0';
  }

  @override
  String get closeFriendsSettingsNote =>
      'Julkaisut, tarinat ja videot näkyvät vain heille, kuvat ja videot salattuina.';

  @override
  String get mediaServersBlossom => 'Mediapalvelimet (Blossom)';

  @override
  String get mediaServersExplain =>
      'Kuvat ja videot ladataan vain näille palvelimille tässä järjestyksessä: ensimmäinen joka hyväksyy ne voittaa. EXIF ja sijainti poistetaan ennen latausta.';

  @override
  String get primary => 'Ensisijainen';

  @override
  String get makePrimary => 'Aseta ensisijaiseksi';

  @override
  String get remove => 'Poista';

  @override
  String get addServer => 'Lisää palvelin';

  @override
  String get moderation => 'Moderointi';

  @override
  String get moderationExplain =>
      'Mykistetyt kirjoittajat ja piilotetut hashtagit synkronoidaan NIP-51:n kautta. Estetyt kirjoittajat pysyvät vain tällä laitteella.';

  @override
  String get mutedAuthors => 'Mykistetyt kirjoittajat';

  @override
  String get noMutedAuthors => 'Ei mykistettyjä kirjoittajia';

  @override
  String get blockedAuthors => 'Estetyt kirjoittajat';

  @override
  String get noBlockedAuthors => 'Ei estettyjä kirjoittajia';

  @override
  String get hiddenHashtags => 'Piilotetut hashtagit';

  @override
  String get noHiddenHashtags => 'Ei piilotettuja hashtageja';

  @override
  String get hashtagToHide => 'Piilotettava #hashtag';

  @override
  String get storage => 'Tallennustila';

  @override
  String get clearCache => 'Tyhjennä tapahtumavälimuisti ja luonnokset';

  @override
  String get cacheCleared => 'Välimuisti tyhjennetty';

  @override
  String get reviewIntro => 'Katso esittely uudelleen';

  @override
  String get reviewIntroSubtitle =>
      'Mikä on julkista, mikä yksityistä ja läheisten rajat.';

  @override
  String noLightningWalletCopied(Object address) {
    return 'Lightning-lompakkoa ei löytynyt: osoite kopioitu ($address)';
  }

  @override
  String get about => 'Tietoja';

  @override
  String aboutText(Object version) {
    return 'Mialuna $version — Hetkesi saman kuun alla.\nAvoin lähdekoodi (MIT). github.com/Lwb89dev/mialuna';
  }

  @override
  String get invalidRelayAddress => 'Virheellinen osoite: käytä wss://…';

  @override
  String get invalidServerAddress => 'Virheellinen osoite: käytä https://…';

  @override
  String get relayRead => 'Luku';

  @override
  String get relayWrite => 'Kirjoitus';

  @override
  String get support => 'Tuki';

  @override
  String get supportText =>
      'Mialuna on ilmainen, siinä ei ole mainoksia eikä se seuraa sinua. Jos pidät siitä, voit lähettää muutaman sats Lightning-verkossa.';

  @override
  String get donateWithLightning => 'Lahjoita Lightningilla';

  @override
  String get authorNoZaps => 'Tämä kirjoittaja ei vastaanota zaps';

  @override
  String get sendZap => 'Lähetä zap ⚡';

  @override
  String get amountInSats => 'Määrä sats';

  @override
  String minMaxSats(Object min, Object max) {
    return 'min $min – max $max';
  }

  @override
  String get zap => 'Zap';

  @override
  String get signInToZap => 'Kirjaudu lähettääksesi zaps';

  @override
  String zapSent(Object sats) {
    return 'Zap, $sats sats, lähetetty ⚡';
  }

  @override
  String nwcPaymentFailed(Object error) {
    return 'NWC-maksu epäonnistui: $error';
  }

  @override
  String get noLightningWallet => 'Lightning-lompakkoa ei löytynyt';

  @override
  String storiesRailLabel(Object state) {
    return 'Tarinat, $state';
  }

  @override
  String get close => 'Sulje';

  @override
  String hoursAgo(int hours) {
    return '$hours h sitten';
  }

  @override
  String daysAgo(int days) {
    return '$days pv sitten';
  }

  @override
  String get now => 'nyt';

  @override
  String get youPrefix => 'Sinä: ';

  @override
  String get storiesStateUnseen => 'uusi';

  @override
  String get storiesStateSeen => 'nähty';

  @override
  String weekdayShort(String day) {
    String _temp0 = intl.Intl.selectLogic(day, {
      'mon': 'ma',
      'tue': 'ti',
      'wed': 'ke',
      'thu': 'to',
      'fri': 'pe',
      'sat': 'la',
      'sun': 'su',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get sharedAMoment => 'Jako hetken';

  @override
  String get blossomOtherError => 'virhe';

  @override
  String get languageTitle => 'Kieli';

  @override
  String get languageSystem => 'Järjestelmä';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageItalian => 'Italiano';

  @override
  String get cannotEditPhoto => 'Tätä kuvaa ei voi muokata täällä.';

  @override
  String notificationsNew(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count uutta ilmoitusta',
      one: '1 uusi ilmoitus',
    );
    return '$_temp0';
  }

  @override
  String messagesUnread(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count lukematonta viestiä',
      one: '1 lukematon viesti',
    );
    return '$_temp0';
  }

  @override
  String get done => 'Valmis';

  @override
  String get storyAddText => 'Lisää teksti';

  @override
  String get storyEditText => 'Muokkaa tekstiä';

  @override
  String get storyTextHint => 'Kirjoita jotain… #hashtags ovat napautettavia';

  @override
  String get storyTextsHelp =>
      'Napauta kuvaa kirjoittaaksesi. Vedä siirtääksesi, nipistä muuttaaksesi kokoa ja kiertääksesi, napauta tekstiä muokataksesi.';

  @override
  String storyTextsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tekstiä',
      one: '1 teksti',
      zero: 'Ei tekstiä',
    );
    return '$_temp0';
  }

  @override
  String get storyFontClassic => 'Klassinen';

  @override
  String get storyFontBold => 'Lihava';

  @override
  String get storyFontSerif => 'Serif';

  @override
  String get storyFontMono => 'Mono';

  @override
  String get storyFontItalic => 'Kursiivi';

  @override
  String get storyTextBackground => 'Tekstin tausta';

  @override
  String get storyTextColor => 'Tekstin väri';

  @override
  String storyTextLimit(int max) {
    return 'Voit lisätä enintään $max tekstiä.';
  }

  @override
  String get wotTitle => 'Luottamusverkko';

  @override
  String get wotEnable => 'Luottamusverkko on aina päällä';

  @override
  String wotExplain(int min) {
    return 'Aina päällä. Löydä näyttää vain tämän verkon: sinä, ihmiset joita seuraat ja kaikki joita vähintään $min heistä seuraa. Sama verkko piilottaa muiden kommentit, ilmoitukset, yksityiset julkaisut ja viestit. Se lasketaan tällä puhelimella julkisista seurantalistoista ensimmäisellä avauksella; myöhemmät avaukset käyttävät sitä uudelleen. Mitään ei lähetetä millekään palvelimelle.';
  }

  @override
  String get wotRefresh => 'Päivitä verkko nyt';

  @override
  String get wotStatusIdle =>
      'Ei vielä rakennettu. Se rakennetaan, kun avaat sovelluksen ensimmäisen kerran.';

  @override
  String get wotBuildingTitle => 'Rakennetaan Löydä-syötettä';

  @override
  String get wotBuildingBody =>
      'Luetaan ketä seuraamasi seuraavat ja valmistellaan Löydä.';

  @override
  String get wotDiscoverHint =>
      'Vain luottamusverkkosi: seuraamasi ihmiset ja ne, joita heistä tarpeeksi moni seuraa.';

  @override
  String get wotDiscoverSignIn =>
      'Löydä näyttää luottamusverkkosi. Kirjaudu, niin ensimmäisellä kerralla Mialuna lukee ketä seuraat ja rakentaa tämän syötteen. Myöhemmin sitä käytetään uudelleen.';

  @override
  String get wotDiscoverEmpty => 'Ei vielä julkaisuja luottamusverkostasi.';

  @override
  String wotStatusDiscovering(int done, int total) {
    return 'Tarkistetaan ketä seuraamasi seuraavat… $done / $total';
  }

  @override
  String wotStatusComplete(int direct, int indirect, Object when) {
    return 'Verkkosi: $direct seuraamaasi plus $indirect, joita tarpeeksi moni heistä seuraa. Päivitetty $when.';
  }

  @override
  String wotStatusFailed(Object reason) {
    return 'Verkkoa ei voitu laskea: $reason';
  }

  @override
  String get wotNoFollows => 'et seuraa vielä ketään';

  @override
  String get messageRequests => 'Viestipyynnöt';

  @override
  String messageRequestsSubtitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count keskustelua luottamusverkkosi ulkopuolelta',
      one: '1 keskustelu luottamusverkkosi ulkopuolelta',
    );
    return '$_temp0';
  }

  @override
  String get messageRequestsHint =>
      'Luottamusverkon ulkopuolelta. Eivät näy lukemattomina. Vastaa, niin keskustelu siirtyy saapuneisiin.';

  @override
  String get storyViewsSetting =>
      'Näytä muille, että katsoin heidän tarinoitaan';

  @override
  String get storyViewsSettingExplain =>
      'Kun katsot tarinaa, sen tekijälle lähtee kuittaus salattuna niin, että vain hän voi lukea sen. Siinä on nimesi hänen vieressään; relays eivät näe mitään. Jos kuittaus ei mene perille, se säilytetään ja yritetään myöhemmin uudelleen. Poista tämä käytöstä katsoaksesi kertomatta kenellekään: vielä lähettämättömät kuittaukset hylätään (jo toimitettua ei voi perua).';

  @override
  String storySeenBy(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count henkilöä nähnyt',
      one: '1 henkilö nähnyt',
      zero: 'Ei katseluita vielä',
    );
    return '$_temp0';
  }

  @override
  String get storyViewsEmpty =>
      'Kukaan ei ole vielä katsonut tätä tarinaa, tai kuittaukset eivät ole tulleet perille.';

  @override
  String get storyViewsHint =>
      'Vain luvan antaneet lähettävät kuittauksen, joten oikea määrä voi olla suurempi.';

  @override
  String get systemNotifications => 'Järjestelmäilmoitukset';

  @override
  String get systemNotificationsExplain =>
      'Näytä ilmoitus puhelimessa, kun jotain uutta saapuu Mialunan ollessa taustalla. Yksityisviestien teksti ei näy koskaan, ei edes lukitusnäytöllä. Android pysäyttää pitkään taustalla olevat sovellukset, joten ilmoitukset tulevat vain kun Mialuna on yhä käynnissä.';

  @override
  String get systemNotificationsBlocked =>
      'Ilmoitukset on poistettu Mialunalta puhelimen asetuksissa.';

  @override
  String get systemNotificationsOpenSettings => 'Avaa asetukset';

  @override
  String get systemNotificationsBattery =>
      'Android laittaa sovellukset lepotilaan muutaman minuutin kuluttua näytön sammuttua, ja ilmoitukset lakkaavat niiden mukana. Jotta saat ne yhä, aseta Mialunan akunkäyttö tilaan “Unrestricted”.';

  @override
  String get systemNotificationsBatteryAction => 'Avaa akun asetukset';

  @override
  String get newFollowersSetting => 'Näytä uudet seuraajat';

  @override
  String get newFollowersSettingExplain =>
      'Uudet seuraajat näkyvät ilmoituksissa ja puhelimessasi. Poista käytöstä, jos seuraukset tulvivat: tykkäykset, kommentit ja zaps näkyvät silti.';

  @override
  String get systemNotificationMessage => 'lähetti sinulle yksityisviestin';

  @override
  String get systemNotificationNewMessage => 'Uusi yksityisviesti';

  @override
  String get systemNotificationNew => 'Uusi ilmoitus';

  @override
  String get notificationChannelSocial =>
      'Reaktiot, kommentit, zaps ja seuraajat';

  @override
  String get notificationChannelMessages => 'Yksityisviestit';

  @override
  String get zapInvoiceMismatch =>
      'Lasku ei vastaa valitsemaasi summaa. Mitään ei maksettu.';

  @override
  String get storyYourStory => 'Sinun tarinasi';

  @override
  String get storyNew => 'Uusi tarina';

  @override
  String get storyAddSemantics => 'Lisää tarinaasi';

  @override
  String storyOwnRailLabel(int count, Object state) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tarinaa',
      one: '1 tarina',
    );
    return 'Tarinasi, $_temp0, $state';
  }

  @override
  String get storyTextSize => 'Tekstin koko';

  @override
  String get storyPickPrompt => 'Valitse kuva tai video tarinaasi';

  @override
  String get storyEditPhoto => 'Muokkaa kuvaa';

  @override
  String get storyCaption => 'Kuvateksti';

  @override
  String get storyDiscardTitle => 'Hylätäänkö tämä tarina?';

  @override
  String get storyDiscard => 'Hylkää';

  @override
  String get storyShare => 'Jaa';

  @override
  String get storyShared => 'Tarina jaettu';

  @override
  String get deletePost => 'Poista';

  @override
  String get deletePostTitle => 'Poistetaanko tämä julkaisu?';

  @override
  String get deleteStoryTitle => 'Poistetaanko tämä tarina?';

  @override
  String get deletePostBody =>
      'Mialuna pyytää relays poistamaan julkaisun ja mediapalvelimia poistamaan sen kuvat tai videon. Jos jokin relay sivuuttaa pyynnön, tai joku on jo tallentanut kopion, se voi jäädä hänelle.';

  @override
  String get deletePrivateBody =>
      'Läheisten julkaisua ei voi vetää takaisin relays. Mialuna pyytää ystäviesi sovelluksia poistamaan sen ja mediapalvelinta poistamaan salatut tiedostot. Ystävä joka on jo tallentanut kopion voi yhä pitää sen.';

  @override
  String get deletingPost => 'Poistetaan…';

  @override
  String get postDeleted => 'Poistettu.';

  @override
  String get postWasDeleted => 'Tämä julkaisu poistettiin.';

  @override
  String get deleteNotAllowed => 'Vain julkaissut tili voi poistaa tämän.';

  @override
  String deleteFailed(Object reason) {
    return 'Poisto epäonnistui: $reason';
  }

  @override
  String get deleteNoRelay =>
      'Yksikään relay ei hyväksynyt poistopyyntöä, joten se on yhä julki. Tarkista yhteys ja yritä uudelleen.';

  @override
  String deleteMediaLeft(Object servers) {
    return 'Mediaa ei voitu poistaa kohteesta $servers.';
  }

  @override
  String get deleteMediaNotAuthorized =>
      'Allekirjoittajasi ei valtuuttanut median poistoa, joten tiedostot ovat yhä mediapalvelimella.';

  @override
  String deleteFriendsMissed(Object count) {
    return '$count läheisistäsi ei saanut tietoa, joten se voi jäädä heidän puhelimiinsa.';
  }

  @override
  String get storyCleanupSetting => 'Poista tarinani niiden vanhentuessa';

  @override
  String get storyCleanupSettingExplain =>
      '24 tunnin jälkeen Mialuna pyytää relays ja mediapalvelimiasi poistamaan tarinasi, kuvat ja videot mukaan lukien. Palvelin joka sivuuttaa pyynnön, tai joku joka piti kopion, voi yhä pitää ne.';

  @override
  String storyCleanupWaiting(Object count) {
    return 'Allekirjoittajasi täytyy hyväksyä jokainen siivous, joten se odottaa pyyntöäsi. Vanhentuneita tarinoita jonossa: $count.';
  }

  @override
  String get storyCleanupNow => 'Poista nyt';

  @override
  String get storyCleanupDone => 'Vanhentuneet tarinat poistettu.';

  @override
  String get storyCleanupPartly =>
      'Joitakin ei voitu vielä poistaa; Mialuna yrittää uudelleen.';
}
