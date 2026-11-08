// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Slovak (`sk`).
class AppLocalizationsSk extends AppLocalizations {
  AppLocalizationsSk([String locale = 'sk']) : super(locale);

  @override
  String get syncUpToDate => 'Aktuálne';

  @override
  String get syncFailed => 'Synchronizácia zlyhala';

  @override
  String get relaysUpdatedFromProfile =>
      'Relays aktualizované z tvojho profilu (NIP-65)';

  @override
  String get relayListPublished => 'Zoznam Relay publikovaný';

  @override
  String get mediaServersUpdatedFromProfile =>
      'Mediálne servery aktualizované z tvojho profilu';

  @override
  String get tabHome => 'Home';

  @override
  String get tabDiscover => 'Objaviť';

  @override
  String get tabCreate => 'Vytvoriť';

  @override
  String get tabReels => 'Reels';

  @override
  String get tabProfile => 'Profil';

  @override
  String get signInToUploadMedia => 'Prihlásiť sa na nahratie médií.';

  @override
  String get noMediaServer =>
      'Nie je nastavený žiadny mediálny server. Pridaj ho v Nastaveniach.';

  @override
  String serverNoResponse(Object server) {
    return '$server: žiadna odpoveď';
  }

  @override
  String serverUnreachable(Object server, Object error) {
    return '$server: nedostupný ($error)';
  }

  @override
  String uploadRejected(Object reason) {
    return 'Nahrávanie odmietnuté — $reason';
  }

  @override
  String noServerAcceptedFile(Object reasons) {
    return 'Žiadny server súbor neprijal — $reasons';
  }

  @override
  String get blossomInvalidResponse => 'neplatná odpoveď';

  @override
  String get blossomInvalidFileUrl => 'neplatná adresa súboru';

  @override
  String get blossomServerAlteredFile => 'server súbor zmenil';

  @override
  String get blossomBadRequest => 'neplatná požiadavka';

  @override
  String get blossomUnauthorized => 'autorizácia zamietnutá';

  @override
  String get blossomPaymentRequired => 'vyžaduje sa platba';

  @override
  String get blossomForbidden => 'nie je povolené';

  @override
  String get blossomLengthRequired => 'chýba veľkosť';

  @override
  String get blossomTooLarge => 'súbor je príliš veľký';

  @override
  String get blossomUnsupportedType => 'formát nie je prijatý';

  @override
  String get blossomTooManyRequests => 'príliš veľa požiadaviek';

  @override
  String get blossomServerError => 'chyba servera';

  @override
  String get cipherInvalidKey => 'Neplatný kľúč';

  @override
  String get cipherTruncated => 'Šifrovaný súbor je skrátený';

  @override
  String get cipherMismatch =>
      'Súbor nezodpovedá kľúču: zmenený alebo poškodený';

  @override
  String get sanitizeHeifNeedsAsync =>
      'Formát HEIC/AVIF: konverzia vyžaduje sanitizeAsync';

  @override
  String get sanitizeWebmUnsupported =>
      'Video WebM/MKV nie je podporované: použi MP4 alebo MOV, aby sa dali metadata pred nahratím odstrániť.';

  @override
  String get sanitizeUnknownFormat =>
      'Nerozpoznaný formát súboru: fotky JPEG/PNG/WebP/GIF alebo videá MP4/MOV.';

  @override
  String sanitizeLeftovers(Object items) {
    return 'Nepodarilo sa odstrániť všetky metadata ($items): súbor nebol nahraný.';
  }

  @override
  String sanitizeProcessingFailed(Object error) {
    return 'Súbor sa nepodarilo spracovať: $error';
  }

  @override
  String get sanitizeJpegInvalid => 'Neplatný JPEG';

  @override
  String get sanitizeJpegTruncated => 'Skrátený JPEG';

  @override
  String get sanitizeJpegNoSize => 'JPEG bez rozmerov';

  @override
  String get sanitizeJpegUndecodable => 'JPEG sa nedá dekódovať';

  @override
  String get sanitizePngTruncated => 'Skrátený PNG';

  @override
  String get sanitizePngInvalid => 'Neplatný PNG';

  @override
  String get sanitizeGifInvalid => 'Neplatný GIF';

  @override
  String get sanitizeGifTruncated => 'Skrátený GIF';

  @override
  String get sanitizeWebpTruncated => 'Skrátený WebP';

  @override
  String get sanitizeWebpInvalid => 'Neplatný WebP';

  @override
  String get sanitizeMp4Invalid => 'Neplatné video MP4/MOV';

  @override
  String get sanitizeConversionFailed => 'Konverzia zlyhala';

  @override
  String get sanitizeHeifUnsupported =>
      'Tento formát (HEIC/AVIF) sa na tomto zariadení nedá konvertovať. Vyber fotku JPEG alebo PNG.';

  @override
  String get privateMediaNotEncrypted => 'Médiá nie sú šifrované';

  @override
  String serverReplied(Object status) {
    return 'Server odpovedal $status';
  }

  @override
  String get fileTooLarge => 'Súbor je príliš veľký';

  @override
  String get serverFileNotOriginal => 'Súbor na serveri nie je originál';

  @override
  String get contentMismatch => 'Obsah sa nezhoduje';

  @override
  String get mediaUnreachable => 'Médiá nedostupné';

  @override
  String get amberInvalidKey => 'Amber vrátil neplatný kľúč';

  @override
  String get amberNoKey => 'Amber nevrátil kľúč';

  @override
  String get amberRequestRejected => 'Požiadavka v Amber zamietnutá';

  @override
  String get amberAndroidOnly => 'Amber je dostupný len na Androide';

  @override
  String get amberEmptySignature => 'Amber vrátil prázdny podpis';

  @override
  String get amberSignRejected => 'Podpis v Amber zamietnutý';

  @override
  String get amberTimeout => 'Amber neodpovedal včas';

  @override
  String get amberEmptyResponse => 'Amber vrátil prázdnu odpoveď';

  @override
  String get bunkerInvalidUrl => 'Neplatná bunker URL';

  @override
  String get bunkerNoRelay => 'Tento bunker neuvádza žiadny relay';

  @override
  String get bunkerWebAuth =>
      'Tento bunker vyžaduje webovú autorizáciu (auth_url nie je podporované)';

  @override
  String get bunkerInvalidKey => 'Tento bunker nevrátil platný kľúč';

  @override
  String get signerInvalidResponse =>
      'Podpisovateľ vrátil neplatnú podpísanú udalosť';

  @override
  String get bunkerTimeout => 'Bunker neodpovedal včas';

  @override
  String get nwcInvalidUri => 'Neplatné NWC URI';

  @override
  String get nwcNoRelay => 'NWC URI neuvádza žiadny relay';

  @override
  String get nwcNoSecret => 'NWC URI neobsahuje platné tajomstvo';

  @override
  String get nwcTimeout => 'Peňaženka neodpovedala včas';

  @override
  String get signerNoPrivateMessages =>
      'Tento spôsob prihlásenia nepodporuje súkromné správy';

  @override
  String get zapNotSupported => 'Táto adresa nepodporuje Nostr zaps';

  @override
  String zapAmountOutOfRange(Object min, Object max) {
    return 'Suma mimo rozsah ($min–$max sats)';
  }

  @override
  String get commentNotSent => 'Komentár nebol odoslaný. Skús to neskôr.';

  @override
  String get comments => 'Komentáre';

  @override
  String get noCommentsYet => 'Zatiaľ žiadne komentáre.';

  @override
  String get signInToComment => 'Prihlásiť sa na komentár.';

  @override
  String get addComment => 'Pridať komentár…';

  @override
  String get signInToPublish => 'Prihlásiť sa na publikovanie.';

  @override
  String get addMediaFirst =>
      'Pred publikovaním pridaj aspoň jednu fotku alebo video.';

  @override
  String get removingMetadata => 'Odstraňovanie metadát…';

  @override
  String uploadingProgress(Object current, Object total) {
    return 'Nahrávanie $current z $total…';
  }

  @override
  String get creatingPreview => 'Vytváranie náhľadu…';

  @override
  String uploadFailed(Object error) {
    return 'Nahrávanie zlyhalo: $error';
  }

  @override
  String get publishing => 'Publikovanie…';

  @override
  String noRelayAcceptedPost(Object reason) {
    return 'Žiadny relay neprijal príspevok$reason. Obsah ostáva v tvojich konceptoch.';
  }

  @override
  String get privateNeedsKeySigner =>
      'Tento spôsob prihlásenia nepodporuje súkromný obsah. Použi Amber, bunker alebo miestny kľúč.';

  @override
  String get closeFriendsListEmptyAddSomeone =>
      'Tvoj zoznam blízkych priateľov je prázdny: niekoho pridaj.';

  @override
  String get fileOver100Mb =>
      'Súbor má viac ako 100 MB: to je limit pre blízkych priateľov (na telefóne sa šifruje celý).';

  @override
  String get encryptingOnPhone => 'Šifrovanie na tvojom telefóne…';

  @override
  String noServerAcceptedEncrypted(Object details) {
    return 'Žiadny z tvojich mediálnych serverov šifrovaný súbor neprijal. Otvorene sa nepublikuje. V Nastaveniach pridaj server, ktorý šifrované súbory prijíma (napríklad cdn.hzrd149.com). $details';
  }

  @override
  String get sendingToFriends => 'Odosielanie priateľom…';

  @override
  String sendingToFriendsProgress(Object done, Object total) {
    return 'Odosielanie priateľom $done/$total…';
  }

  @override
  String noFriendReceivedPost(Object reason) {
    return 'Žiadny priateľ príspevok nedostal$reason. Obsah ostáva v tvojich konceptoch.';
  }

  @override
  String sentToCloseFriends(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Odoslané $count blízkym priateľom 🔒',
      one: 'Odoslané 1 blízkemu priateľovi 🔒',
    );
    return '$_temp0';
  }

  @override
  String sentToFriendsWithMisses(int delivered, Object missed) {
    String _temp0 = intl.Intl.pluralLogic(
      delivered,
      locale: localeName,
      other: 'Odoslané $delivered priateľom.',
      one: 'Odoslané 1 priateľovi.',
    );
    return '$_temp0 $missed to nedostali (súkromné správy sú vypnuté).';
  }

  @override
  String get altText => 'Alternatívny text';

  @override
  String get altTextHint => 'Opíš obsah pre ľudí, ktorí ho nevidia…';

  @override
  String get cancel => 'Zrušiť';

  @override
  String get save => 'Uložiť';

  @override
  String get momentPublished => 'Okamih publikovaný ✨';

  @override
  String get newMoment => 'Nový okamih';

  @override
  String get publish => 'Publikovať';

  @override
  String get guestMode => 'Režim hosťa';

  @override
  String get signInToPostMoments =>
      'Prihlásiť sa na publikovanie svojich okamihov.';

  @override
  String get signIn => 'Prihlásiť sa';

  @override
  String get kindPhoto => 'Fotka';

  @override
  String get kindVideo => 'Video';

  @override
  String get kindReel => 'Reel';

  @override
  String get kindStory => 'Príbeh';

  @override
  String get storyExpiryNote =>
      'Príbehy na relays, ktoré dodržiavajú NIP-40, vypršia po 24 hodinách, ale ostatní ich stále môžu uložiť alebo archivovať.';

  @override
  String get fromGallery => 'Z galérie';

  @override
  String get galleryLongPressVideo => 'Galéria (podrž pre video)';

  @override
  String get addVideo => 'Pridať video';

  @override
  String get camera => 'Fotoaparát';

  @override
  String get exifRemovedNote =>
      'Metadáta polohy (EXIF) sa odstraňujú automaticky.';

  @override
  String get writeCaption => 'Napíš popis…';

  @override
  String get privatePostNote =>
      'Súkromný príspevok: žiadne verejné hashtagy, cez hľadanie ho nenájdeš.';

  @override
  String willPublishAs(Object caption) {
    return 'Publikuje sa ako: \"$caption\"';
  }

  @override
  String get tapThumbnailForAlt =>
      'Ťukni na náhľad a pridaj alternatívny text.';

  @override
  String get sensitiveContent => 'Citlivý obsah';

  @override
  String get sensitiveContentNote =>
      'Príspevok sa skryje za upozornenie (NIP-36).';

  @override
  String get uploadingMedia => 'Nahrávanie médií…';

  @override
  String get audiencePublic => 'Verejné';

  @override
  String get closeFriends => 'Blízki priatelia';

  @override
  String get signerCannotPublishCloseFriends =>
      'S týmto prihlásením nemôžeš publikovať pre blízkych priateľov: použi Amber, bunker alebo miestny kľúč.';

  @override
  String get closeFriendsEmptyPrompt =>
      'Tvoj zoznam je prázdny: pridaj ľudí, ktorí tento príspevok uvidia.';

  @override
  String onlyYourCloseFriendsSee(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Uvidí to len tvojich $count blízkych priateľov. Fotky a videá sa pred nahratím šifrujú na tvojom telefóne.',
      one: 'Uvidí to len tvoj 1 blízky priateľ. Fotky a videá sa pred nahratím šifrujú na tvojom telefóne.',
    );
    return '$_temp0';
  }

  @override
  String get addFriends => 'Pridať priateľov';

  @override
  String get manageList => 'Spravovať zoznam';

  @override
  String get edit => 'Upraviť';

  @override
  String get reset => 'Resetovať';

  @override
  String get apply => 'Použiť';

  @override
  String get cropFree => 'Voľný';

  @override
  String get cropOriginal => 'Pôvodný';

  @override
  String get rotate => 'Otočiť';

  @override
  String get flip => 'Prevrátiť';

  @override
  String get brightness => 'Jas';

  @override
  String get contrast => 'Kontrast';

  @override
  String get saturation => 'Sýtosť';

  @override
  String postsByAuthor(Object author) {
    return 'Príspevky od $author…';
  }

  @override
  String get searchHint => 'Hľadaj ľudí, hashtagy alebo slová…';

  @override
  String get clear => 'Vymazať';

  @override
  String get recent => 'Nedávne';

  @override
  String get searchDependsOnRelays =>
      'Hľadanie závisí od nastavených relays: výsledky môžu byť neúplné.';

  @override
  String get recentPostsEverywhere =>
      'Nedávne príspevky z celej siete, vrátane ľudí, ktorých nesleduješ.';

  @override
  String get noResultsOnRelays =>
      'Na nastavených relays nie sú žiadne výsledky.';

  @override
  String get noRecentPostsFromFollowed =>
      'Žiadne nedávne príspevky od ľudí, ktorých sleduješ.';

  @override
  String get noMomentsFound =>
      'Na relays sa nenašli žiadne okamihy. Skontroluj pripojenie.';

  @override
  String get loadFailed => 'Načítanie zlyhalo';

  @override
  String get notifications => 'Upozornenia';

  @override
  String get messages => 'Správy';

  @override
  String get homeEmptyFollowsNobody =>
      'Tu sa zobrazujú príspevky ľudí, ktorých sleduješ.\nZatiaľ nikoho nesleduješ: objav zaujímavých ľudí a profily.';

  @override
  String get discoverPeople => 'Objaviť ľudí';

  @override
  String get homeEmpty =>
      'Zatiaľ žiadne okamihy.\nPotiahni nadol pre obnovenie alebo publikuj svoj prvý záber.';

  @override
  String get retry => 'Skúsiť znova';

  @override
  String get seenEverything => 'Zatiaľ máš všetko za sebou ✨';

  @override
  String get discoverMoreProfiles => 'Objaviť ďalšie profily';

  @override
  String get feedFollowing => 'Sledujem';

  @override
  String get signInToSeeFollowed =>
      'Prihlásiť sa a uvidíš príspevky ľudí, ktorých sleduješ';

  @override
  String get videoPreview => 'Náhľad videa';

  @override
  String get cannotOpenPrivateVideo => 'Súkromné video sa nedá otvoriť';

  @override
  String get cannotPlayVideo => 'Video sa nedá prehrať';

  @override
  String get pauseVideo => 'Pozastaviť video';

  @override
  String get playVideo => 'Prehrať video';

  @override
  String errorTapToRetry(Object error) {
    return '$error — ťukni pre opakovanie';
  }

  @override
  String get soundOn => 'Zapnúť zvuk';

  @override
  String get soundOff => 'Vypnúť zvuk';

  @override
  String get postImage => 'Obrázok príspevku';

  @override
  String get imageUnavailable => 'Obrázok nie je dostupný';

  @override
  String errorTapToRetryNewline(Object message) {
    return '$message\nŤukni pre opakovanie';
  }

  @override
  String get cannotOpenPrivateContent => 'Tento súkromný obsah sa nedá otvoriť';

  @override
  String get privateImage => 'Súkromný obrázok';

  @override
  String get invalidImage => 'Neplatný obrázok';

  @override
  String get more => 'Viac';

  @override
  String get removeFromSaved => 'Odobrať z uložených';

  @override
  String get copyLink => 'Kopírovať odkaz';

  @override
  String get muteAuthor => 'Stlmiť autora';

  @override
  String get blockAuthor => 'Blokovať autora';

  @override
  String get report => 'Nahlásiť';

  @override
  String get like => 'Páči sa';

  @override
  String get sendInMessage => 'Poslať v správe';

  @override
  String get zapOptional => 'Zap (voliteľné)';

  @override
  String get closeFriendsOnlyNote =>
      'Viditeľné len pre blízkych priateľov. Páči sa a odpovede idú len autorovi.';

  @override
  String get likeFailed => 'Nepodarilo sa odoslať reakciu';

  @override
  String get nostrLinkCopied => 'Nostr odkaz skopírovaný do schránky';

  @override
  String get authorMuted => 'Autor stlmený';

  @override
  String get authorBlocked => 'Autor zablokovaný';

  @override
  String get reportSent => 'Hlásenie odoslané (NIP-56)';

  @override
  String get signInToReport => 'Prihlásiť sa na nahlásenie';

  @override
  String minutesAgo(Object minutes) {
    return 'pred $minutes min';
  }

  @override
  String get show => 'Zobraziť';

  @override
  String get chatEmptyHint =>
      'Napíš prvú správu.\nJe šifrovaná: vidíte ju len vy dvaja.';

  @override
  String get messageHint => 'Správa…';

  @override
  String get send => 'Odoslať';

  @override
  String get notSentSuffix => ' neodoslané';

  @override
  String get contentUnavailable =>
      'Obsah nie je dostupný (vypršal alebo sa na relays nenašiel)';

  @override
  String get signInToSendPrivateMessages =>
      'Prihlásiť sa na odosielanie súkromných správ.';

  @override
  String get cannotMessageYourself => 'Sebe napísať nejde.';

  @override
  String get recipientNoPrivateMessages =>
      'Tento človek ešte nemá zapnuté súkromné správy.';

  @override
  String noRecipientRelayAccepted(Object reason) {
    return 'Žiadny relay príjemcu správu neprijal$reason.';
  }

  @override
  String sendFailed(Object error) {
    return 'Odoslanie zlyhalo: $error';
  }

  @override
  String get signInToReadMessages =>
      'Prihlásiť sa na čítanie a odosielanie súkromných správ.';

  @override
  String get signerNoPrivateMessagesLong =>
      'S týmto prihlásením nejdú súkromné správy. Prihlásiť sa cez Amber, bunker alebo miestny kľúč.';

  @override
  String get inboxEmpty =>
      'Žiadne konverzácie.\nŤukni na ceruzku a napíš niekomu, alebo prepošli okamih ikonou ✈ pod každým príspevkom.';

  @override
  String get newMessage => 'Nová správa';

  @override
  String get privateMessagesEnabled => 'Súkromné správy zapnuté';

  @override
  String get enableMessagesFailed => 'Nepodarilo sa ich zapnúť. Skús to znova.';

  @override
  String get enablePrivateMessages => 'Zapnúť súkromné správy';

  @override
  String enablePrivateMessagesExplain(Object count) {
    return 'Aby ti chodili správy, musíš povedať, na ktoré relays majú prísť. Publikuje sa malý zoznam (NIP-17) s $count predvolenými relays: neskôr ho môžeš zmeniť. Správy ostávajú šifrované: relays nevidia, kto píše, ani text.';
  }

  @override
  String get turnOn => 'Zapnúť';

  @override
  String get searchByNameOrUsername => 'Hľadaj meno alebo prezývku';

  @override
  String get searching => 'Hľadanie…';

  @override
  String get noOneWithNameHint =>
      'Nikto s týmto menom. Skús menej písmen alebo adresu ako name@domain.com.';

  @override
  String get sent => 'Odoslané';

  @override
  String sentToPeople(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Odoslané $count ľuďom',
      one: 'Odoslané 1 človeku',
    );
    return '$_temp0';
  }

  @override
  String sentToPeopleWithFailure(int count, Object failure) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Odoslané $count ľuďom. $failure',
      one: 'Odoslané 1 človeku. $failure',
    );
    return '$_temp0';
  }

  @override
  String get signerNoPrivateMessagesShort =>
      'S týmto prihlásením nemôžeš používať súkromné správy.';

  @override
  String get followToStartOrSearch =>
      'Sleduj niekoho na začiatok, alebo hľadaj podľa mena.';

  @override
  String get addMessage => 'Pridaj správu…';

  @override
  String sendWithCount(Object count) {
    return 'Odoslať ($count)';
  }

  @override
  String get linkCopied => 'Odkaz skopírovaný do schránky';

  @override
  String get noNotifications => 'Teraz žiadne upozornenia.';

  @override
  String get notificationsDependOnRelays =>
      'Upozornenia závisia od relays: môžu byť neúplné.';

  @override
  String get reactedToYourMoment => 'reagoval na tvoj okamih';

  @override
  String commentedText(Object text) {
    return 'komentoval: $text';
  }

  @override
  String sentYouSats(Object sats, Object comment) {
    return 'poslal ti $sats sats$comment';
  }

  @override
  String get sentYouZap => 'poslal ti zap';

  @override
  String get startedFollowingYou => 'začal ťa sledovať';

  @override
  String get amberNotFound => 'Amber nenájdený';

  @override
  String get amberExplain =>
      'Amber je Nostr podpisovateľ, ktorý drží tvoj súkromný kľúč mimo Mialuna. Nainštaluj ho a skús to znova.';

  @override
  String get downloadFromFdroid => 'Stiahnuť z F-Droid';

  @override
  String get continueWithAmber => 'Pokračovať s Amber';

  @override
  String get amberRecommended =>
      'Odporúčané: tvoj súkromný kľúč ostáva v bezpečí v Amber.';

  @override
  String get amberNotDetected =>
      'Amber nedetekovaný: nainštaluj ho pre odporúčané prihlásenie.';

  @override
  String get exploreWithoutAccount => 'Prehliadať bez účtu';

  @override
  String get remoteBunker => 'Vzdialený bunker (NIP-46)';

  @override
  String get invalidBunkerUrlDot => 'Neplatná bunker URL.';

  @override
  String get connectBunker => 'Pripojiť bunker';

  @override
  String get advancedNsec => 'Pokročilé prihlásenie (nsec)';

  @override
  String get nsecWarning =>
      'Varovanie: vloženie súkromného kľúča je rizikové. Nikdy ho s nikým nezdieľaj. Na Androide uprednostni Amber.';

  @override
  String get invalidNsec => 'Neplatný nsec kľúč.';

  @override
  String get signInWithNsec => 'Prihlásiť sa pomocou nsec';

  @override
  String get tagline => 'Tvoje okamihy, pod tým istým mesiacom.';

  @override
  String get skip => 'Preskočiť';

  @override
  String get permissionsAndWallet => 'Povolenia a peňaženka';

  @override
  String get permissionsExplain =>
      'Dovoľujú len publikovať a dostávať upozornenia. Kedykoľvek ich môžeš zmeniť v systémových nastaveniach.';

  @override
  String get photosAndVideos => 'Fotky a videá';

  @override
  String get toUploadYourMoments => 'Na nahratie tvojich okamihov';

  @override
  String get allow => 'Povoliť';

  @override
  String get reactionsCommentsZaps => 'Reakcie, komentáre a zaps';

  @override
  String get lightningWalletOptional => 'Lightning peňaženka (voliteľné)';

  @override
  String get nwcExplain =>
      'Pripoj peňaženku Nostr Wallet Connect a posielaj zaps bez opustenia aplikácie.';

  @override
  String get walletConnected => 'Peňaženka pripojená';

  @override
  String get disconnect => 'Odpojiť';

  @override
  String get connectWallet => 'Pripojiť peňaženku';

  @override
  String get getStarted => 'Začať';

  @override
  String get welcome1 =>
      'Mialuna je vizuálna sociálna sieť: fotky, videá, Reels a príbehy — nikdy len textové príspevky.';

  @override
  String get welcome2 =>
      'Beží na Nostr, otvorenom protokole: tvoja identita je kľúč, ktorý vlastníš, nie účet, ktorý ti firma môže vziať. Žiadne reklamy, žiadne trackery, žiadne centrálne servery.';

  @override
  String get welcome3 =>
      'Zdieľaj svoje svetlo s ľuďmi všade, z akejkoľvek aplikácie, ktorá hovorí rovnakým otvoreným jazykom.';

  @override
  String onboardingWot(int min) {
    return 'Sieť dôvery je vždy zapnutá. Pri prvom otvorení Mialuna prečíta, koho sleduješ, a z tej siete zostaví prehľad Objaviť: ty, ľudí, ktorých sleduješ, a každého, koho sleduje aspoň $min z nich. Pri ďalších otvoreniach už ten prehľad je.';
  }

  @override
  String get publicAndPrivate => 'Verejné a súkromné';

  @override
  String get publicAndPrivateIntro =>
      'Mialuna stojí na Nostr, otvorenej sieti. Čo publikuješ, je verejné: príspevky, fotky a videá ostanú viditeľné pre každého s odkazom, aj mimo Mialuna.';

  @override
  String get closeFriendsExplain1 =>
      'Len ľudia na tomto zozname dostanú tvoje príspevky, príbehy a videá \"Blízki priatelia\". Zoznam je vnútri príspevku; nemusíš ho vyberať zakaždým.';

  @override
  String get closeFriendsExplain2 =>
      'Fotky a videá sa pred nahratím šifrujú na tvojom telefóne. Súborové servery (Blossom) samy nič nešifrujú: preto to robí Mialuna a server vidí len nečitateľné dáta. Kto nájde adresu súboru, ten ho neotvorí.';

  @override
  String get closeFriendsExplain3 =>
      'Nie je to absolútna záruka: kto príspevok dostane, môže urobiť snímku obrazovky, a odobratie priateľa platí len pre budúce príspevky.';

  @override
  String get closeFriendsExplain4 =>
      'Každý priateľ musí používať Mialuna so zapnutými súkromnými správami. Ostatné Nostr aplikácie tieto príspevky nezobrazia.';

  @override
  String get closeFriendsExplain5 =>
      'Verejné príspevky ostávajú verejné: ich súbory vidí každý s odkazom.';

  @override
  String get closeFriendsExplain6 =>
      'Ak žiadny z tvojich serverov neprijíma šifrované súbory, príspevok sa nepublikuje: nikdy otvorene.';

  @override
  String get addToCloseFriends => 'Pridať k blízkym priateľom';

  @override
  String maxFriendsReached(Object max, Object added) {
    return 'Limit $max priateľov: pridané $added.';
  }

  @override
  String get add => 'Pridať';

  @override
  String get signInToCreateList => 'Prihlásiť sa na vytvorenie zoznamu.';

  @override
  String get signerNoCloseFriends =>
      'Blízki priatelia nejdú s týmto prihlásením. Prihlásiť sa cez Amber, bunker alebo miestny kľúč.';

  @override
  String peopleOfMax(Object count, Object max) {
    return '$count / $max ľudí';
  }

  @override
  String get noOneYet => 'Zatiaľ nikto.';

  @override
  String get addPeople => 'Pridať ľudí';

  @override
  String get friendNoPrivateMessagesWarning =>
      'Nemajú zapnuté súkromné správy: tvoje príspevky nedostanú';

  @override
  String get removeFromList => 'Odobrať zo zoznamu';

  @override
  String get noOneWithThisName => 'Nikto s týmto menom.';

  @override
  String get signInToSendPrivateContent =>
      'Prihlásiť sa na odoslanie súkromného obsahu.';

  @override
  String get reasonNoPrivateMessages => 'nemá zapnuté súkromné správy';

  @override
  String get reasonNoRelayAnswered => 'žiadny relay neodpovedal';

  @override
  String get profileUpdated => 'Profil aktualizovaný';

  @override
  String get noRelayAcceptedRetry =>
      'Žiadny relay to neprijal. Skús to neskôr.';

  @override
  String get editProfile => 'Upraviť profil';

  @override
  String get fieldName => 'Meno';

  @override
  String get fieldBio => 'Bio';

  @override
  String get fieldAvatarUrl => 'URL avatara';

  @override
  String get fieldNip05 => 'NIP-05 (napr. you@example.com)';

  @override
  String get browsingAsGuest => 'Prehliadaš ako hosť';

  @override
  String get signInToInteract =>
      'Prihlásiť sa na publikovanie, sledovanie a reakcie.';

  @override
  String get settings => 'Nastavenia';

  @override
  String get signOut => 'Odhlásiť sa';

  @override
  String get npubCopied => 'npub skopírovaný';

  @override
  String get copyNpub => 'Kopírovať npub';

  @override
  String get mute => 'Stlmiť';

  @override
  String get block => 'Blokovať';

  @override
  String get posts => 'Príspevky';

  @override
  String get saved => 'Uložené';

  @override
  String get nothingPublishedYet => 'Zatiaľ nemáš nič publikované.';

  @override
  String get noPostsOnRelays => 'Na relays sa nenašli žiadne príspevky.';

  @override
  String get noReelsPublished => 'Žiadne reels publikované.';

  @override
  String get noReelsOnRelays => 'Na relays sa nenašli žiadne reels.';

  @override
  String get noSavedPosts => 'Žiadne uložené príspevky.';

  @override
  String get followingButton => 'Sledujem';

  @override
  String get follow => 'Sledovať';

  @override
  String get messageButton => 'Správa';

  @override
  String get loginLocalKey => 'Miestny kľúč';

  @override
  String get loginGuest => 'Hosť';

  @override
  String get followUpdateFailed =>
      'Sledovaných sa teraz nepodarilo aktualizovať. Skús to znova.';

  @override
  String get noReelsComeBack =>
      'Na relays sa nenašli žiadne reels.\nVráť sa čoskoro!';

  @override
  String get followUpdateFailedShort =>
      'Sledovaných sa teraz nepodarilo aktualizovať';

  @override
  String get needOneReadRelay => 'Je nutný aspoň jeden relay na čítanie.';

  @override
  String get listSavedLocally =>
      'Zoznam uložený na tomto zariadení, nepublikovaný.';

  @override
  String get noRelayAcceptedList =>
      'Žiadny relay zoznam neprijal: skúsi sa to neskôr.';

  @override
  String relayListPublishedTo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Zoznam Relay publikovaný na $count relays',
      one: 'Zoznam Relay publikovaný na 1 relay',
    );
    return '$_temp0';
  }

  @override
  String get mediaServersUpdated => 'Mediálne servery aktualizované';

  @override
  String get appearance => 'Vzhľad';

  @override
  String get publishingSettings => 'Publikovanie';

  @override
  String get addMialunaHashtag => 'Pridať #mialuna';

  @override
  String get addMialunaHashtagNote =>
      'Pridaj oficiálny hashtag k verejným príspevkom a príbehom. Kedykoľvek to môžeš vypnúť.';

  @override
  String get themeLight => 'Svetlý';

  @override
  String get themeDark => 'Tmavý';

  @override
  String get themeSystem => 'Systém';

  @override
  String get relays => 'Relays';

  @override
  String get relaysExplainSignedOut =>
      'Relays ukladajú a šíria obsah. Prihlásiť sa pre automatické použitie vlastného zoznamu (NIP-65).';

  @override
  String get relaysExplainSynced =>
      'Zoznam je synchronizovaný s tvojím Nostr profilom (NIP-65): každá zmena sa publikuje a platí pre všetky tvoje aplikácie.';

  @override
  String get syncing => 'Synchronizácia…';

  @override
  String get waitingFirstSync => 'Čaká sa na prvú synchronizáciu';

  @override
  String get syncNow => 'Synchronizovať teraz';

  @override
  String get addRelay => 'Pridať relay';

  @override
  String get restoreDefaultRelays => 'Obnoviť predvolené relays';

  @override
  String get createYourList => 'Vytvoriť svoj zoznam';

  @override
  String peopleCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ľudí',
      one: '1 človek',
    );
    return '$_temp0';
  }

  @override
  String get closeFriendsSettingsNote =>
      'Príspevky, príbehy a videá viditeľné len pre nich, so šifrovanými fotkami a videami.';

  @override
  String get mediaServersBlossom => 'Mediálne servery (Blossom)';

  @override
  String get mediaServersExplain =>
      'Fotky a videá sa nahrávajú len na tieto servery, v uvedenom poradí: vyhrá prvý, ktorý ich prijme. EXIF a poloha sa pred nahratím odstránia.';

  @override
  String get primary => 'Hlavný';

  @override
  String get makePrimary => 'Nastaviť ako hlavný';

  @override
  String get remove => 'Odobrať';

  @override
  String get addServer => 'Pridať server';

  @override
  String get moderation => 'Moderácia';

  @override
  String get moderationExplain =>
      'Stlmení autori a skryté hashtagy sa synchronizujú cez NIP-51. Blokovaní autori ostávajú len na tomto zariadení.';

  @override
  String get mutedAuthors => 'Stlmení autori';

  @override
  String get noMutedAuthors => 'Žiadni stlmení autori';

  @override
  String get blockedAuthors => 'Blokovaní autori';

  @override
  String get noBlockedAuthors => 'Žiadni blokovaní autori';

  @override
  String get hiddenHashtags => 'Skryté hashtagy';

  @override
  String get noHiddenHashtags => 'Žiadne skryté hashtagy';

  @override
  String get hashtagToHide => '#hashtag na skrytie';

  @override
  String get storage => 'Úložisko';

  @override
  String get clearCache => 'Vymazať cache udalostí a koncepty';

  @override
  String get cacheCleared => 'Cache vymazaná';

  @override
  String get reviewIntro => 'Znova zobraziť úvod';

  @override
  String get reviewIntroSubtitle =>
      'Čo je verejné, čo súkromné a limity blízkych priateľov.';

  @override
  String noLightningWalletCopied(Object address) {
    return 'Lightning peňaženka nenájdená: adresa skopírovaná ($address)';
  }

  @override
  String get about => 'O aplikácii';

  @override
  String aboutText(Object version) {
    return 'Mialuna $version — Tvoje okamihy, pod tým istým mesiacom.\nOtvorený zdroj (MIT). github.com/Lwb89dev/mialuna';
  }

  @override
  String get invalidRelayAddress => 'Neplatná adresa: použi wss://…';

  @override
  String get invalidServerAddress => 'Neplatná adresa: použi https://…';

  @override
  String get relayRead => 'Čítanie';

  @override
  String get relayWrite => 'Zápis';

  @override
  String get support => 'Podpora';

  @override
  String get supportText =>
      'Mialuna je zadarmo, bez reklám a nesleduje ťa. Keď sa ti páči, môžeš poslať pár sats cez Lightning Network.';

  @override
  String get donateWithLightning => 'Prispieť cez Lightning';

  @override
  String get authorNoZaps => 'Tento autor neprijíma zaps';

  @override
  String get sendZap => 'Poslať zap ⚡';

  @override
  String get amountInSats => 'Suma v sats';

  @override
  String minMaxSats(Object min, Object max) {
    return 'min $min – max $max';
  }

  @override
  String get zap => 'Zap';

  @override
  String get signInToZap => 'Prihlásiť sa na posielanie zaps';

  @override
  String zapSent(Object sats) {
    return 'Zap $sats sats odoslaný ⚡';
  }

  @override
  String nwcPaymentFailed(Object error) {
    return 'Platba NWC zlyhala: $error';
  }

  @override
  String get noLightningWallet => 'Lightning peňaženka nenájdená';

  @override
  String storiesRailLabel(Object state) {
    return 'Príbehy, $state';
  }

  @override
  String get close => 'Zavrieť';

  @override
  String hoursAgo(int hours) {
    return 'pred $hours h';
  }

  @override
  String daysAgo(int days) {
    return 'pred $days d';
  }

  @override
  String get now => 'teraz';

  @override
  String get youPrefix => 'Ty: ';

  @override
  String get storiesStateUnseen => 'nové';

  @override
  String get storiesStateSeen => 'videné';

  @override
  String weekdayShort(String day) {
    String _temp0 = intl.Intl.selectLogic(day, {
      'mon': 'Po',
      'tue': 'Ut',
      'wed': 'St',
      'thu': 'Št',
      'fri': 'Pi',
      'sat': 'So',
      'sun': 'Ne',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get sharedAMoment => 'Zdieľaný okamih';

  @override
  String get blossomOtherError => 'chyba';

  @override
  String get languageTitle => 'Jazyk';

  @override
  String get languageSystem => 'Systém';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageItalian => 'Italiano';

  @override
  String get cannotEditPhoto => 'Túto fotku tu upraviť nejde.';

  @override
  String notificationsNew(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count nových upozornení',
      one: '1 nové upozornenie',
    );
    return '$_temp0';
  }

  @override
  String messagesUnread(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count neprečítaných správ',
      one: '1 neprečítaná správa',
    );
    return '$_temp0';
  }

  @override
  String get done => 'Hotovo';

  @override
  String get storyAddText => 'Pridať text';

  @override
  String get storyEditText => 'Upraviť text';

  @override
  String get storyTextHint => 'Napíš niečo… #hashtags sa dajú ťuknúť';

  @override
  String get storyTextsHelp =>
      'Ťukni na obrázok a píš. Ťahaj pre presun, stisnutím zmeň veľkosť a otoč, ťukni na text pre úpravu.';

  @override
  String storyTextsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count textov',
      one: '1 text',
      zero: 'Žiadny text',
    );
    return '$_temp0';
  }

  @override
  String get storyFontClassic => 'Klasické';

  @override
  String get storyFontBold => 'Tučné';

  @override
  String get storyFontSerif => 'Serif';

  @override
  String get storyFontMono => 'Mono';

  @override
  String get storyFontItalic => 'Kurzíva';

  @override
  String get storyTextBackground => 'Pozadie textu';

  @override
  String get storyTextColor => 'Farba textu';

  @override
  String storyTextLimit(int max) {
    return 'Môžeš pridať najviac $max textov.';
  }

  @override
  String get wotTitle => 'Sieť dôvery';

  @override
  String get wotEnable => 'Sieť dôvery je vždy zapnutá';

  @override
  String wotExplain(int min) {
    return 'Vždy zapnutá. Objaviť ukazuje len túto sieť: teba, ľudí, ktorých sleduješ, a každého, koho sleduje aspoň $min z nich. Rovnaká sieť skrýva komentáre, upozornenia, súkromné príspevky a správy od všetkých ostatných. Spočíta sa na tomto telefóne z verejných zoznamov sledovania pri prvom otvorení; neskôr sa znova použije. Na žiadny server sa nič neposiela.';
  }

  @override
  String get wotRefresh => 'Obnoviť sieť teraz';

  @override
  String get wotStatusIdle =>
      'Ešte nie je zostavená. Zostaví sa pri prvom otvorení aplikácie.';

  @override
  String get wotBuildingTitle => 'Zostavuje sa tvoj prehľad Objaviť';

  @override
  String get wotBuildingBody =>
      'Číta sa, koho sledujú ľudia, ktorých sleduješ, a pripravuje sa Objaviť.';

  @override
  String get wotDiscoverHint =>
      'Len tvoja sieť dôvery: ľudia, ktorých sleduješ, a ľudia, ktorých ich sleduje dosť.';

  @override
  String get wotDiscoverSignIn =>
      'Objaviť ukazuje tvoju sieť dôvery. Prihlásiť sa a pri prvom otvorení Mialuna prečíta, koho sleduješ, a zostaví tento prehľad. Neskôr ho znova použije.';

  @override
  String get wotDiscoverEmpty =>
      'Z tvojej siete dôvery zatiaľ žiadne príspevky.';

  @override
  String wotStatusDiscovering(int done, int total) {
    return 'Kontrola, koho sledujú tvoji sledovaní… $done z $total';
  }

  @override
  String wotStatusComplete(int direct, int indirect, Object when) {
    return 'Tvoja sieť: $direct ľudí, ktorých sleduješ, plus $indirect, ktorých ich sleduje dosť. Aktualizované $when.';
  }

  @override
  String wotStatusFailed(Object reason) {
    return 'Sieť sa nepodarilo spočítať: $reason';
  }

  @override
  String get wotNoFollows => 'zatiaľ nikoho nesleduješ';

  @override
  String get messageRequests => 'Žiadosti o správu';

  @override
  String messageRequestsSubtitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count konverzácií mimo tvoju sieť dôvery',
      one: '1 konverzácia mimo tvoju sieť dôvery',
    );
    return '$_temp0';
  }

  @override
  String get messageRequestsHint =>
      'Od ľudí mimo tvoju sieť dôvery. Nepočítajú sa ako neprečítané. Odpovedz a konverzácia prejde do schránky.';

  @override
  String get storyViewsSetting => 'Ukazovať, že som videl ich príbehy';

  @override
  String get storyViewsSettingExplain =>
      'Keď sleduješ príbeh, autorovi sa pošle potvrdenie zašifrované tak, že ho prečíta len autor. Je v ňom tvoje meno vedľa jeho; relays nevidia nič. Keď nejde doručiť, ostane uložené a skúsi sa neskôr. Vypni to a budeš sledovať bez oznámenia: ešte neodoslané potvrdenia sa zahodia (už doručené nejde vziať späť).';

  @override
  String storySeenBy(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Videné $count ľuďmi',
      one: 'Videné 1 človekom',
      zero: 'Zatiaľ bez zhliadnutia',
    );
    return '$_temp0';
  }

  @override
  String get storyViewsEmpty =>
      'Tento príbeh ešte nikto nesledoval, alebo k tebe ich potvrdenia nedorazili.';

  @override
  String get storyViewsHint =>
      'Potvrdenie posielajú len ľudia, ktorí to dovolia, takže skutočný počet môže byť vyšší.';

  @override
  String get systemNotifications => 'Systémové upozornenia';

  @override
  String get systemNotificationsExplain =>
      'Ukáž na telefóne upozornenie, keď príde niečo nové a Mialuna je na pozadí. Súkromné správy nikdy neukážu text, ani na zamknutej obrazovke. Android uspáva aplikácie, ktoré sú dlho na pozadí, takže upozornenia chodia, len kým Mialuna ešte beží.';

  @override
  String get systemNotificationsBlocked =>
      'Upozornenia pre Mialuna sú v nastaveniach telefónu vypnuté.';

  @override
  String get systemNotificationsOpenSettings => 'Otvoriť nastavenia';

  @override
  String get systemNotificationsBattery =>
      'Android uspí aplikácie pár minút po zhasnutí obrazovky a upozornenia s nimi prestanú. Aby chodili ďalej, nastav využitie batérie Mialuna na “Neobmedzené”.';

  @override
  String get systemNotificationsBatteryAction => 'Otvoriť nastavenia batérie';

  @override
  String get newFollowersSetting => 'Zobrazovať nových sledujúcich';

  @override
  String get newFollowersSettingExplain =>
      'Noví sledujúci sa objavia v Upozorneniach a na telefóne. Vypni to, keď ťa ľudia zaplavujú sledovaním: páči sa, komentáre a zaps sa ďalej zobrazujú.';

  @override
  String get systemNotificationMessage => 'poslal ti súkromnú správu';

  @override
  String get systemNotificationNewMessage => 'Nová súkromná správa';

  @override
  String get systemNotificationNew => 'Nové upozornenie';

  @override
  String get notificationChannelSocial =>
      'Reakcie, komentáre, zaps a sledujúci';

  @override
  String get notificationChannelMessages => 'Súkromné správy';

  @override
  String get zapInvoiceMismatch =>
      'Faktúra nezodpovedá zvolenej sume. Nič sa nezaplatilo.';

  @override
  String get storyYourStory => 'Tvoj príbeh';

  @override
  String get storyNew => 'Nový príbeh';

  @override
  String get storyAddSemantics => 'Pridať do tvojho príbehu';

  @override
  String storyOwnRailLabel(int count, Object state) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count príbehov',
      one: '1 príbeh',
    );
    return 'Tvoj príbeh, $_temp0, $state';
  }

  @override
  String get storyTextSize => 'Veľkosť textu';

  @override
  String get storyPickPrompt => 'Vyber fotku alebo video pre svoj príbeh';

  @override
  String get storyEditPhoto => 'Upraviť fotku';

  @override
  String get storyCaption => 'Popis';

  @override
  String get storyDiscardTitle => 'Zahodiť tento príbeh?';

  @override
  String get storyDiscard => 'Zahodiť';

  @override
  String get storyShare => 'Zdieľať';

  @override
  String get storyShared => 'Príbeh zdieľaný';

  @override
  String get deletePost => 'Zmazať';

  @override
  String get deletePostTitle => 'Zmazať tento príspevok?';

  @override
  String get deleteStoryTitle => 'Zmazať tento príbeh?';

  @override
  String get deletePostBody =>
      'Mialuna požiada tvoje relays o zmazanie a mediálne servery o zmazanie fotiek alebo videa. Ak relay požiadavku ignoruje, alebo ak už niekto kópiu uložil, stále ju môže mať.';

  @override
  String get deletePrivateBody =>
      'Príspevok pre blízkych priateľov nejde z relays stiahnuť späť. Mialuna povie aplikáciám priateľov, nech ho odoberú, a požiada mediálny server o zmazanie šifrovaných súborov. Priateľ, ktorý už kópiu uložil, ju stále môže mať.';

  @override
  String get deletingPost => 'Mazanie…';

  @override
  String get postDeleted => 'Zmazané.';

  @override
  String get postWasDeleted => 'Tento príspevok bol zmazaný.';

  @override
  String get deleteNotAllowed =>
      'Zmazať to môže len účet, ktorý to publikoval.';

  @override
  String deleteFailed(Object reason) {
    return 'Nepodarilo sa zmazať: $reason';
  }

  @override
  String get deleteNoRelay =>
      'Žiadny relay požiadavku na zmazanie neprijal, takže je to stále online. Skontroluj pripojenie a skús to znova.';

  @override
  String deleteMediaLeft(Object servers) {
    return 'Médiá sa nepodarilo odobrať z $servers.';
  }

  @override
  String get deleteMediaNotAuthorized =>
      'Tvoj podpisovateľ nepovolil odobratie médií, takže súbory sú stále na mediálnom serveri.';

  @override
  String deleteFriendsMissed(Object count) {
    return '$count z tvojich blízkych priateľov sa nepodarilo upozorniť, takže to môže ostať na ich telefónoch.';
  }

  @override
  String get storyCleanupSetting => 'Zmazať moje príbehy po vypršaní';

  @override
  String get storyCleanupSettingExplain =>
      'Po 24 hodinách Mialuna požiada tvoje relays a mediálne servery o zmazanie tvojich príbehov, vrátane fotiek a videí. Server, ktorý požiadavku ignoruje, alebo niekto, kto si nechal kópiu, ich stále môže mať.';

  @override
  String storyCleanupWaiting(Object count) {
    return 'Podpisovateľ musí každé čistenie schváliť, takže sa čaká na teba. Vypršané príbehy vo fronte: $count.';
  }

  @override
  String get storyCleanupNow => 'Zmazať teraz';

  @override
  String get storyCleanupDone => 'Vypršané príbehy zmazané.';

  @override
  String get storyCleanupPartly =>
      'Niektoré sa ešte nepodarilo zmazať; Mialuna to skúsi znova.';
}
