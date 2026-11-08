// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Czech (`cs`).
class AppLocalizationsCs extends AppLocalizations {
  AppLocalizationsCs([String locale = 'cs']) : super(locale);

  @override
  String get syncUpToDate => 'Aktuální';

  @override
  String get syncFailed => 'Synchronizace selhala';

  @override
  String get relaysUpdatedFromProfile =>
      'Relays aktualizovány z tvého profilu (NIP-65)';

  @override
  String get relayListPublished => 'Seznam Relay publikován';

  @override
  String get mediaServersUpdatedFromProfile =>
      'Mediální servery aktualizovány z tvého profilu';

  @override
  String get tabHome => 'Home';

  @override
  String get tabDiscover => 'Objevit';

  @override
  String get tabCreate => 'Vytvořit';

  @override
  String get tabReels => 'Reels';

  @override
  String get tabProfile => 'Profil';

  @override
  String get signInToUploadMedia => 'Přihlásit se pro nahrání médií.';

  @override
  String get noMediaServer =>
      'Není nastaven žádný mediální server. Přidej ho v Nastavení.';

  @override
  String serverNoResponse(Object server) {
    return '$server: žádná odpověď';
  }

  @override
  String serverUnreachable(Object server, Object error) {
    return '$server: nedostupný ($error)';
  }

  @override
  String uploadRejected(Object reason) {
    return 'Nahrání odmítnuto — $reason';
  }

  @override
  String noServerAcceptedFile(Object reasons) {
    return 'Žádný server soubor nepřijal — $reasons';
  }

  @override
  String get blossomInvalidResponse => 'neplatná odpověď';

  @override
  String get blossomInvalidFileUrl => 'neplatná adresa souboru';

  @override
  String get blossomServerAlteredFile => 'server soubor změnil';

  @override
  String get blossomBadRequest => 'neplatný požadavek';

  @override
  String get blossomUnauthorized => 'autorizace zamítnuta';

  @override
  String get blossomPaymentRequired => 'vyžadována platba';

  @override
  String get blossomForbidden => 'není povoleno';

  @override
  String get blossomLengthRequired => 'chybí velikost';

  @override
  String get blossomTooLarge => 'soubor je příliš velký';

  @override
  String get blossomUnsupportedType => 'formát není přijat';

  @override
  String get blossomTooManyRequests => 'příliš mnoho požadavků';

  @override
  String get blossomServerError => 'chyba serveru';

  @override
  String get cipherInvalidKey => 'Neplatný klíč';

  @override
  String get cipherTruncated => 'Šifrovaný soubor je zkrácený';

  @override
  String get cipherMismatch =>
      'Soubor neodpovídá klíči: změněný nebo poškozený';

  @override
  String get sanitizeHeifNeedsAsync =>
      'Formát HEIC/AVIF: převod vyžaduje sanitizeAsync';

  @override
  String get sanitizeWebmUnsupported =>
      'Video WebM/MKV není podporováno: použij MP4 nebo MOV, aby šla metadata před nahráním odstranit.';

  @override
  String get sanitizeUnknownFormat =>
      'Nerozpoznaný formát souboru: fotky JPEG/PNG/WebP/GIF nebo videa MP4/MOV.';

  @override
  String sanitizeLeftovers(Object items) {
    return 'Nepodařilo se odstranit všechna metadata ($items): soubor nebyl nahrán.';
  }

  @override
  String sanitizeProcessingFailed(Object error) {
    return 'Soubor se nepodařilo zpracovat: $error';
  }

  @override
  String get sanitizeJpegInvalid => 'Neplatný JPEG';

  @override
  String get sanitizeJpegTruncated => 'Zkrácený JPEG';

  @override
  String get sanitizeJpegNoSize => 'JPEG bez rozměrů';

  @override
  String get sanitizeJpegUndecodable => 'JPEG nelze dekódovat';

  @override
  String get sanitizePngTruncated => 'Zkrácený PNG';

  @override
  String get sanitizePngInvalid => 'Neplatný PNG';

  @override
  String get sanitizeGifInvalid => 'Neplatný GIF';

  @override
  String get sanitizeGifTruncated => 'Zkrácený GIF';

  @override
  String get sanitizeWebpTruncated => 'Zkrácený WebP';

  @override
  String get sanitizeWebpInvalid => 'Neplatný WebP';

  @override
  String get sanitizeMp4Invalid => 'Neplatné video MP4/MOV';

  @override
  String get sanitizeConversionFailed => 'Převod selhal';

  @override
  String get sanitizeHeifUnsupported =>
      'Tento formát (HEIC/AVIF) nelze na tomto zařízení převést. Vyber fotku JPEG nebo PNG.';

  @override
  String get privateMediaNotEncrypted => 'Média nejsou šifrovaná';

  @override
  String serverReplied(Object status) {
    return 'Server odpověděl $status';
  }

  @override
  String get fileTooLarge => 'Soubor je příliš velký';

  @override
  String get serverFileNotOriginal => 'Soubor na serveru není originál';

  @override
  String get contentMismatch => 'Obsah se neshoduje';

  @override
  String get mediaUnreachable => 'Média nedostupná';

  @override
  String get amberInvalidKey => 'Amber vrátil neplatný klíč';

  @override
  String get amberNoKey => 'Amber nevrátil klíč';

  @override
  String get amberRequestRejected => 'Požadavek v Amber zamítnut';

  @override
  String get amberAndroidOnly => 'Amber je dostupný jen na Androidu';

  @override
  String get amberEmptySignature => 'Amber vrátil prázdný podpis';

  @override
  String get amberSignRejected => 'Podpis v Amber zamítnut';

  @override
  String get amberTimeout => 'Amber neodpověděl včas';

  @override
  String get amberEmptyResponse => 'Amber vrátil prázdnou odpověď';

  @override
  String get bunkerInvalidUrl => 'Neplatná bunker URL';

  @override
  String get bunkerNoRelay => 'Tento bunker neuvádí žádný relay';

  @override
  String get bunkerWebAuth =>
      'Tento bunker vyžaduje webovou autorizaci (auth_url není podporováno)';

  @override
  String get bunkerInvalidKey => 'Tento bunker nevrátil platný klíč';

  @override
  String get signerInvalidResponse =>
      'Podepisovač vrátil neplatnou podepsanou událost';

  @override
  String get bunkerTimeout => 'Bunker neodpověděl včas';

  @override
  String get nwcInvalidUri => 'Neplatné NWC URI';

  @override
  String get nwcNoRelay => 'NWC URI neuvádí žádný relay';

  @override
  String get nwcNoSecret => 'NWC URI neobsahuje platné tajemství';

  @override
  String get nwcTimeout => 'Peněženka neodpověděla včas';

  @override
  String get signerNoPrivateMessages =>
      'Tento způsob přihlášení nepodporuje soukromé zprávy';

  @override
  String get zapNotSupported => 'Tato adresa nepodporuje Nostr zaps';

  @override
  String zapAmountOutOfRange(Object min, Object max) {
    return 'Částka mimo rozsah ($min–$max sats)';
  }

  @override
  String get commentNotSent => 'Komentář nebyl odeslán. Zkus to později.';

  @override
  String get comments => 'Komentáře';

  @override
  String get noCommentsYet => 'Zatím žádné komentáře.';

  @override
  String get signInToComment => 'Přihlásit se pro komentář.';

  @override
  String get addComment => 'Přidat komentář…';

  @override
  String get signInToPublish => 'Přihlásit se pro publikování.';

  @override
  String get addMediaFirst =>
      'Před publikováním přidej aspoň jednu fotku nebo video.';

  @override
  String get removingMetadata => 'Odstraňování metadat…';

  @override
  String uploadingProgress(Object current, Object total) {
    return 'Nahrávání $current z $total…';
  }

  @override
  String get creatingPreview => 'Vytváření náhledu…';

  @override
  String uploadFailed(Object error) {
    return 'Nahrání selhalo: $error';
  }

  @override
  String get publishing => 'Publikování…';

  @override
  String noRelayAcceptedPost(Object reason) {
    return 'Žádný relay nepřijal příspěvek$reason. Obsah zůstává v tvých konceptech.';
  }

  @override
  String get privateNeedsKeySigner =>
      'Tento způsob přihlášení nepodporuje soukromý obsah. Použij Amber, bunker nebo místní klíč.';

  @override
  String get closeFriendsListEmptyAddSomeone =>
      'Tvůj seznam blízkých přátel je prázdný: někoho přidej.';

  @override
  String get fileOver100Mb =>
      'Soubor má přes 100 MB: to je limit pro blízké přátele (na telefonu se šifruje celý).';

  @override
  String get encryptingOnPhone => 'Šifrování na tvém telefonu…';

  @override
  String noServerAcceptedEncrypted(Object details) {
    return 'Žádný z tvých mediálních serverů šifrovaný soubor nepřijal. Otevřeně se nepublikuje. V Nastavení přidej server, který šifrované soubory přijímá (například cdn.hzrd149.com). $details';
  }

  @override
  String get sendingToFriends => 'Odesílání přátelům…';

  @override
  String sendingToFriendsProgress(Object done, Object total) {
    return 'Odesílání přátelům $done/$total…';
  }

  @override
  String noFriendReceivedPost(Object reason) {
    return 'Žádný přítel příspěvek nedostal$reason. Obsah zůstává v tvých konceptech.';
  }

  @override
  String sentToCloseFriends(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Odesláno $count blízkým přátelům 🔒',
      one: 'Odesláno 1 blízkému příteli 🔒',
    );
    return '$_temp0';
  }

  @override
  String sentToFriendsWithMisses(int delivered, Object missed) {
    String _temp0 = intl.Intl.pluralLogic(
      delivered,
      locale: localeName,
      other: 'Odesláno $delivered přátelům.',
      one: 'Odesláno 1 příteli.',
    );
    return '$_temp0 $missed to nedostali (soukromé zprávy jsou vypnuté).';
  }

  @override
  String get altText => 'Alternativní text';

  @override
  String get altTextHint => 'Popiš obsah pro lidi, kteří ho nevidí…';

  @override
  String get cancel => 'Zrušit';

  @override
  String get save => 'Uložit';

  @override
  String get momentPublished => 'Okamžik publikován ✨';

  @override
  String get newMoment => 'Nový okamžik';

  @override
  String get publish => 'Publikovat';

  @override
  String get guestMode => 'Režim hosta';

  @override
  String get signInToPostMoments =>
      'Přihlásit se pro publikování svých okamžiků.';

  @override
  String get signIn => 'Přihlásit se';

  @override
  String get kindPhoto => 'Fotka';

  @override
  String get kindVideo => 'Video';

  @override
  String get kindReel => 'Reel';

  @override
  String get kindStory => 'Příběh';

  @override
  String get storyExpiryNote =>
      'Příběhy na relays, které dodržují NIP-40, vyprší po 24 hodinách, ale ostatní je pořád mohou uložit nebo archivovat.';

  @override
  String get fromGallery => 'Z galerie';

  @override
  String get galleryLongPressVideo => 'Galerie (podrž pro video)';

  @override
  String get addVideo => 'Přidat video';

  @override
  String get camera => 'Fotoaparát';

  @override
  String get exifRemovedNote =>
      'Metadata polohy (EXIF) se odstraňují automaticky.';

  @override
  String get writeCaption => 'Napiš popisek…';

  @override
  String get privatePostNote =>
      'Soukromý příspěvek: žádné veřejné hashtagy, přes hledání ho nenajdeš.';

  @override
  String willPublishAs(Object caption) {
    return 'Publikuje se jako: \"$caption\"';
  }

  @override
  String get tapThumbnailForAlt =>
      'Klepni na náhled a přidej alternativní text.';

  @override
  String get sensitiveContent => 'Citlivý obsah';

  @override
  String get sensitiveContentNote =>
      'Příspěvek se skryje za upozornění (NIP-36).';

  @override
  String get uploadingMedia => 'Nahrávání médií…';

  @override
  String get audiencePublic => 'Veřejné';

  @override
  String get closeFriends => 'Blízcí přátelé';

  @override
  String get signerCannotPublishCloseFriends =>
      'S tímto přihlášením nemůžeš publikovat pro blízké přátele: použij Amber, bunker nebo místní klíč.';

  @override
  String get closeFriendsEmptyPrompt =>
      'Tvůj seznam je prázdný: přidej lidi, kteří tento příspěvek uvidí.';

  @override
  String onlyYourCloseFriendsSee(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Uvidí to jen tvých $count blízkých přátel. Fotky a videa se před nahráním šifrují na tvém telefonu.',
      one: 'Uvidí to jen tvůj 1 blízký přítel. Fotky a videa se před nahráním šifrují na tvém telefonu.',
    );
    return '$_temp0';
  }

  @override
  String get addFriends => 'Přidat přátele';

  @override
  String get manageList => 'Spravovat seznam';

  @override
  String get edit => 'Upravit';

  @override
  String get reset => 'Resetovat';

  @override
  String get apply => 'Použít';

  @override
  String get cropFree => 'Volný';

  @override
  String get cropOriginal => 'Původní';

  @override
  String get rotate => 'Otočit';

  @override
  String get flip => 'Překlopit';

  @override
  String get brightness => 'Jas';

  @override
  String get contrast => 'Kontrast';

  @override
  String get saturation => 'Sytost';

  @override
  String postsByAuthor(Object author) {
    return 'Příspěvky od $author…';
  }

  @override
  String get searchHint => 'Hledej lidi, hashtagy nebo slova…';

  @override
  String get clear => 'Vymazat';

  @override
  String get recent => 'Nedávné';

  @override
  String get searchDependsOnRelays =>
      'Hledání závisí na nastavených relays: výsledky mohou být neúplné.';

  @override
  String get recentPostsEverywhere =>
      'Nedávné příspěvky z celé sítě, včetně lidí, které nesleduješ.';

  @override
  String get noResultsOnRelays =>
      'Na nastavených relays nejsou žádné výsledky.';

  @override
  String get noRecentPostsFromFollowed =>
      'Žádné nedávné příspěvky od lidí, které sleduješ.';

  @override
  String get noMomentsFound =>
      'Na relays se nenašly žádné okamžiky. Zkontroluj připojení.';

  @override
  String get loadFailed => 'Načítání selhalo';

  @override
  String get notifications => 'Oznámení';

  @override
  String get messages => 'Zprávy';

  @override
  String get homeEmptyFollowsNobody =>
      'Tady se objevují příspěvky lidí, které sleduješ.\nZatím nikoho nesleduješ: objev zajímavé lidi a profily.';

  @override
  String get discoverPeople => 'Objevit lidi';

  @override
  String get homeEmpty =>
      'Zatím žádné okamžiky.\nPotáhni dolů pro obnovení nebo publikuj svůj první záběr.';

  @override
  String get retry => 'Zkusit znovu';

  @override
  String get seenEverything => 'Zatím máš všechno za sebou ✨';

  @override
  String get discoverMoreProfiles => 'Objevit další profily';

  @override
  String get feedFollowing => 'Sleduji';

  @override
  String get signInToSeeFollowed =>
      'Přihlásit se a uvidíš příspěvky lidí, které sleduješ';

  @override
  String get videoPreview => 'Náhled videa';

  @override
  String get cannotOpenPrivateVideo => 'Soukromé video nelze otevřít';

  @override
  String get cannotPlayVideo => 'Video nelze přehrát';

  @override
  String get pauseVideo => 'Pozastavit video';

  @override
  String get playVideo => 'Přehrát video';

  @override
  String errorTapToRetry(Object error) {
    return '$error — klepni pro opakování';
  }

  @override
  String get soundOn => 'Zapnout zvuk';

  @override
  String get soundOff => 'Vypnout zvuk';

  @override
  String get postImage => 'Obrázek příspěvku';

  @override
  String get imageUnavailable => 'Obrázek není dostupný';

  @override
  String errorTapToRetryNewline(Object message) {
    return '$message\nKlepni pro opakování';
  }

  @override
  String get cannotOpenPrivateContent => 'Tento soukromý obsah nelze otevřít';

  @override
  String get privateImage => 'Soukromý obrázek';

  @override
  String get invalidImage => 'Neplatný obrázek';

  @override
  String get more => 'Více';

  @override
  String get removeFromSaved => 'Odebrat z uložených';

  @override
  String get copyLink => 'Kopírovat odkaz';

  @override
  String get muteAuthor => 'Ztlumit autora';

  @override
  String get blockAuthor => 'Blokovat autora';

  @override
  String get report => 'Nahlásit';

  @override
  String get like => 'Líbí se';

  @override
  String get sendInMessage => 'Poslat ve zprávě';

  @override
  String get zapOptional => 'Zap (volitelné)';

  @override
  String get closeFriendsOnlyNote =>
      'Viditelné jen pro blízké přátele. Líbí se a odpovědi jdou jen autorovi.';

  @override
  String get likeFailed => 'Nepodařilo se odeslat reakci';

  @override
  String get nostrLinkCopied => 'Nostr odkaz zkopírován do schránky';

  @override
  String get authorMuted => 'Autor ztlumen';

  @override
  String get authorBlocked => 'Autor zablokován';

  @override
  String get reportSent => 'Hlášení odesláno (NIP-56)';

  @override
  String get signInToReport => 'Přihlásit se pro nahlášení';

  @override
  String minutesAgo(Object minutes) {
    return 'před $minutes min';
  }

  @override
  String get show => 'Zobrazit';

  @override
  String get chatEmptyHint =>
      'Napiš první zprávu.\nJe šifrovaná: vidíte ji jen vy dva.';

  @override
  String get messageHint => 'Zpráva…';

  @override
  String get send => 'Odeslat';

  @override
  String get notSentSuffix => ' neodesláno';

  @override
  String get contentUnavailable =>
      'Obsah není dostupný (vypršel nebo nebyl na relays nalezen)';

  @override
  String get signInToSendPrivateMessages =>
      'Přihlásit se pro odesílání soukromých zpráv.';

  @override
  String get cannotMessageYourself => 'Sobě psát nejde.';

  @override
  String get recipientNoPrivateMessages =>
      'Tento člověk ještě nemá zapnuté soukromé zprávy.';

  @override
  String noRecipientRelayAccepted(Object reason) {
    return 'Žádný relay příjemce zprávu nepřijal$reason.';
  }

  @override
  String sendFailed(Object error) {
    return 'Odeslání selhalo: $error';
  }

  @override
  String get signInToReadMessages =>
      'Přihlásit se pro čtení a odesílání soukromých zpráv.';

  @override
  String get signerNoPrivateMessagesLong =>
      'S tímto přihlášením nejdou soukromé zprávy. Přihlásit se přes Amber, bunker nebo místní klíč.';

  @override
  String get inboxEmpty =>
      'Žádné konverzace.\nKlepni na tužku a napiš někomu, nebo přepošli okamžik ikonou ✈ pod každým příspěvkem.';

  @override
  String get newMessage => 'Nová zpráva';

  @override
  String get privateMessagesEnabled => 'Soukromé zprávy zapnuty';

  @override
  String get enableMessagesFailed => 'Nepodařilo se je zapnout. Zkus to znovu.';

  @override
  String get enablePrivateMessages => 'Zapnout soukromé zprávy';

  @override
  String enablePrivateMessagesExplain(Object count) {
    return 'Aby ti chodily zprávy, musíš říct, na které relays mají přijít. Publikuje se malý seznam (NIP-17) s $count výchozími relays: později ho můžeš změnit. Zprávy zůstávají šifrované: relays nevidí, kdo píše, ani text.';
  }

  @override
  String get turnOn => 'Zapnout';

  @override
  String get searchByNameOrUsername => 'Hledej jméno nebo přezdívku';

  @override
  String get searching => 'Hledání…';

  @override
  String get noOneWithNameHint =>
      'Nikdo s tímto jménem. Zkus méně písmen nebo adresu jako name@domain.com.';

  @override
  String get sent => 'Odesláno';

  @override
  String sentToPeople(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Odesláno $count lidem',
      one: 'Odesláno 1 člověku',
    );
    return '$_temp0';
  }

  @override
  String sentToPeopleWithFailure(int count, Object failure) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Odesláno $count lidem. $failure',
      one: 'Odesláno 1 člověku. $failure',
    );
    return '$_temp0';
  }

  @override
  String get signerNoPrivateMessagesShort =>
      'S tímto přihlášením nemůžeš používat soukromé zprávy.';

  @override
  String get followToStartOrSearch =>
      'Sleduj někoho na začátek, nebo hledej podle jména.';

  @override
  String get addMessage => 'Přidej zprávu…';

  @override
  String sendWithCount(Object count) {
    return 'Odeslat ($count)';
  }

  @override
  String get linkCopied => 'Odkaz zkopírován do schránky';

  @override
  String get noNotifications => 'Teď žádná oznámení.';

  @override
  String get notificationsDependOnRelays =>
      'Oznámení závisí na relays: mohou být neúplná.';

  @override
  String get reactedToYourMoment => 'reagoval na tvůj okamžik';

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
  String get startedFollowingYou => 'začal tě sledovat';

  @override
  String get amberNotFound => 'Amber nenalezen';

  @override
  String get amberExplain =>
      'Amber je Nostr podepisovač, který drží tvůj soukromý klíč mimo Mialuna. Nainstaluj ho a zkus to znovu.';

  @override
  String get downloadFromFdroid => 'Stáhnout z F-Droid';

  @override
  String get continueWithAmber => 'Pokračovat s Amber';

  @override
  String get amberRecommended =>
      'Doporučeno: tvůj soukromý klíč zůstává v bezpečí v Amber.';

  @override
  String get amberNotDetected =>
      'Amber nedetekován: nainstaluj ho pro doporučené přihlášení.';

  @override
  String get exploreWithoutAccount => 'Prohlížet bez účtu';

  @override
  String get remoteBunker => 'Vzdálený bunker (NIP-46)';

  @override
  String get invalidBunkerUrlDot => 'Neplatná bunker URL.';

  @override
  String get connectBunker => 'Připojit bunker';

  @override
  String get advancedNsec => 'Pokročilé přihlášení (nsec)';

  @override
  String get nsecWarning =>
      'Varování: vložení soukromého klíče je rizikové. Nikdy ho s nikým nesdílej. Na Androidu preferuj Amber.';

  @override
  String get invalidNsec => 'Neplatný nsec klíč.';

  @override
  String get signInWithNsec => 'Přihlásit se pomocí nsec';

  @override
  String get tagline => 'Tvé okamžiky, pod stejným měsícem.';

  @override
  String get skip => 'Přeskočit';

  @override
  String get permissionsAndWallet => 'Oprávnění a peněženka';

  @override
  String get permissionsExplain =>
      'Dovolí jen publikovat a dostávat oznámení. Kdykoli je můžeš změnit v systémovém nastavení.';

  @override
  String get photosAndVideos => 'Fotky a videa';

  @override
  String get toUploadYourMoments => 'Pro nahrání tvých okamžiků';

  @override
  String get allow => 'Povolit';

  @override
  String get reactionsCommentsZaps => 'Reakce, komentáře a zaps';

  @override
  String get lightningWalletOptional => 'Lightning peněženka (volitelné)';

  @override
  String get nwcExplain =>
      'Připoj peněženku Nostr Wallet Connect a posílej zaps bez opuštění aplikace.';

  @override
  String get walletConnected => 'Peněženka připojena';

  @override
  String get disconnect => 'Odpojit';

  @override
  String get connectWallet => 'Připojit peněženku';

  @override
  String get getStarted => 'Začít';

  @override
  String get welcome1 =>
      'Mialuna je vizuální sociální síť: fotky, videa, Reels a příběhy — nikdy jen textové příspěvky.';

  @override
  String get welcome2 =>
      'Běží na Nostr, otevřeném protokolu: tvoje identita je klíč, který vlastníš, ne účet, který ti firma může vzít. Žádné reklamy, žádné trackery, žádné centrální servery.';

  @override
  String get welcome3 =>
      'Sdílej své světlo s lidmi všude, z jakékoli aplikace, která mluví stejným otevřeným jazykem.';

  @override
  String onboardingWot(int min) {
    return 'Síť důvěry je vždy zapnutá. Při prvním otevření Mialuna přečte, koho sleduješ, a z té sítě sestaví přehled Objevit: ty, lidi, které sleduješ, a každého, koho sleduje aspoň $min z nich. Při dalších otevřeních už ten přehled je.';
  }

  @override
  String get publicAndPrivate => 'Veřejné a soukromé';

  @override
  String get publicAndPrivateIntro =>
      'Mialuna stojí na Nostr, otevřené síti. Co publikuješ, je veřejné: příspěvky, fotky a videa zůstanou viditelné pro každého s odkazem, i mimo Mialuna.';

  @override
  String get closeFriendsExplain1 =>
      'Jen lidé na tomto seznamu dostanou tvé příspěvky, příběhy a videa \"Blízcí přátelé\". Seznam je uvnitř příspěvku; nemusíš ho vybírat pokaždé.';

  @override
  String get closeFriendsExplain2 =>
      'Fotky a videa se před nahráním šifrují na tvém telefonu. Souborové servery (Blossom) samy nic nešifrují: proto to dělá Mialuna a server vidí jen nečitelná data. Kdo najde adresu souboru, ten ho neotevře.';

  @override
  String get closeFriendsExplain3 =>
      'Není to absolutní záruka: kdo příspěvek dostane, může udělat snímek obrazovky, a odebrání přítele platí jen pro budoucí příspěvky.';

  @override
  String get closeFriendsExplain4 =>
      'Každý přítel musí používat Mialuna se zapnutými soukromými zprávami. Ostatní Nostr klienti tyto příspěvky nezobrazí.';

  @override
  String get closeFriendsExplain5 =>
      'Veřejné příspěvky zůstávají veřejné: jejich soubory vidí každý s odkazem.';

  @override
  String get closeFriendsExplain6 =>
      'Pokud žádný z tvých serverů nepřijímá šifrované soubory, příspěvek se nepublikuje: nikdy otevřeně.';

  @override
  String get addToCloseFriends => 'Přidat k blízkým přátelům';

  @override
  String maxFriendsReached(Object max, Object added) {
    return 'Limit $max přátel: přidáno $added.';
  }

  @override
  String get add => 'Přidat';

  @override
  String get signInToCreateList => 'Přihlásit se pro vytvoření seznamu.';

  @override
  String get signerNoCloseFriends =>
      'Blízcí přátelé nejdou s tímto přihlášením. Přihlásit se přes Amber, bunker nebo místní klíč.';

  @override
  String peopleOfMax(Object count, Object max) {
    return '$count / $max lidí';
  }

  @override
  String get noOneYet => 'Zatím nikdo.';

  @override
  String get addPeople => 'Přidat lidi';

  @override
  String get friendNoPrivateMessagesWarning =>
      'Nemají zapnuté soukromé zprávy: tvé příspěvky nedostanou';

  @override
  String get removeFromList => 'Odebrat ze seznamu';

  @override
  String get noOneWithThisName => 'Nikdo s tímto jménem.';

  @override
  String get signInToSendPrivateContent =>
      'Přihlásit se pro odeslání soukromého obsahu.';

  @override
  String get reasonNoPrivateMessages => 'nemá zapnuté soukromé zprávy';

  @override
  String get reasonNoRelayAnswered => 'žádný relay neodpověděl';

  @override
  String get profileUpdated => 'Profil aktualizován';

  @override
  String get noRelayAcceptedRetry =>
      'Žádný relay to nepřijal. Zkus to později.';

  @override
  String get editProfile => 'Upravit profil';

  @override
  String get fieldName => 'Jméno';

  @override
  String get fieldBio => 'Bio';

  @override
  String get fieldAvatarUrl => 'URL avataru';

  @override
  String get fieldNip05 => 'NIP-05 (např. you@example.com)';

  @override
  String get browsingAsGuest => 'Prohlížíš jako host';

  @override
  String get signInToInteract =>
      'Přihlásit se pro publikování, sledování a reakce.';

  @override
  String get settings => 'Nastavení';

  @override
  String get signOut => 'Odhlásit se';

  @override
  String get npubCopied => 'npub zkopírován';

  @override
  String get copyNpub => 'Kopírovat npub';

  @override
  String get mute => 'Ztlumit';

  @override
  String get block => 'Blokovat';

  @override
  String get posts => 'Příspěvky';

  @override
  String get saved => 'Uložené';

  @override
  String get nothingPublishedYet => 'Zatím nemáš nic publikováno.';

  @override
  String get noPostsOnRelays => 'Na relays se nenašly žádné příspěvky.';

  @override
  String get noReelsPublished => 'Žádné reels publikovány.';

  @override
  String get noReelsOnRelays => 'Na relays se nenašly žádné reels.';

  @override
  String get noSavedPosts => 'Žádné uložené příspěvky.';

  @override
  String get followingButton => 'Sleduji';

  @override
  String get follow => 'Sledovat';

  @override
  String get messageButton => 'Zpráva';

  @override
  String get loginLocalKey => 'Místní klíč';

  @override
  String get loginGuest => 'Host';

  @override
  String get followUpdateFailed =>
      'Sledované se teď nepodařilo aktualizovat. Zkus to znovu.';

  @override
  String get noReelsComeBack =>
      'Na relays se nenašly žádné reels.\nVrať se brzy!';

  @override
  String get followUpdateFailedShort =>
      'Sledované se teď nepodařilo aktualizovat';

  @override
  String get needOneReadRelay => 'Je nutný aspoň jeden relay ke čtení.';

  @override
  String get listSavedLocally =>
      'Seznam uložen na tomto zařízení, nepublikován.';

  @override
  String get noRelayAcceptedList =>
      'Žádný relay seznam nepřijal: zkusí se to později.';

  @override
  String relayListPublishedTo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Seznam Relay publikován na $count relays',
      one: 'Seznam Relay publikován na 1 relay',
    );
    return '$_temp0';
  }

  @override
  String get mediaServersUpdated => 'Mediální servery aktualizovány';

  @override
  String get appearance => 'Vzhled';

  @override
  String get publishingSettings => 'Publikování';

  @override
  String get addMialunaHashtag => 'Přidat #mialuna';

  @override
  String get addMialunaHashtagNote =>
      'Přidej oficiální hashtag k veřejným příspěvkům a příběhům. Kdykoli to můžeš vypnout.';

  @override
  String get themeLight => 'Světlý';

  @override
  String get themeDark => 'Tmavý';

  @override
  String get themeSystem => 'Systém';

  @override
  String get relays => 'Relays';

  @override
  String get relaysExplainSignedOut =>
      'Relays ukládají a šíří obsah. Přihlásit se pro automatické použití vlastního seznamu (NIP-65).';

  @override
  String get relaysExplainSynced =>
      'Seznam je synchronizovaný s tvým Nostr profilem (NIP-65): každá změna se publikuje a platí pro všechny tvé aplikace.';

  @override
  String get syncing => 'Synchronizace…';

  @override
  String get waitingFirstSync => 'Čeká se na první synchronizaci';

  @override
  String get syncNow => 'Synchronizovat teď';

  @override
  String get addRelay => 'Přidat relay';

  @override
  String get restoreDefaultRelays => 'Obnovit výchozí relays';

  @override
  String get createYourList => 'Vytvořit svůj seznam';

  @override
  String peopleCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count lidí',
      one: '1 člověk',
    );
    return '$_temp0';
  }

  @override
  String get closeFriendsSettingsNote =>
      'Příspěvky, příběhy a videa viditelné jen pro ně, se šifrovanými fotkami a videi.';

  @override
  String get mediaServersBlossom => 'Mediální servery (Blossom)';

  @override
  String get mediaServersExplain =>
      'Fotky a videa se nahrávají jen na tyto servery, v uvedeném pořadí: vyhraje první, který je přijme. EXIF a poloha se před nahráním odstraní.';

  @override
  String get primary => 'Hlavní';

  @override
  String get makePrimary => 'Nastavit jako hlavní';

  @override
  String get remove => 'Odebrat';

  @override
  String get addServer => 'Přidat server';

  @override
  String get moderation => 'Moderace';

  @override
  String get moderationExplain =>
      'Ztlumení autoři a skryté hashtagy se synchronizují přes NIP-51. Blokovaní autoři zůstávají jen na tomto zařízení.';

  @override
  String get mutedAuthors => 'Ztlumení autoři';

  @override
  String get noMutedAuthors => 'Žádní ztlumení autoři';

  @override
  String get blockedAuthors => 'Blokovaní autoři';

  @override
  String get noBlockedAuthors => 'Žádní blokovaní autoři';

  @override
  String get hiddenHashtags => 'Skryté hashtagy';

  @override
  String get noHiddenHashtags => 'Žádné skryté hashtagy';

  @override
  String get hashtagToHide => '#hashtag ke skrytí';

  @override
  String get storage => 'Úložiště';

  @override
  String get clearCache => 'Vymazat cache událostí a koncepty';

  @override
  String get cacheCleared => 'Cache vymazána';

  @override
  String get reviewIntro => 'Znovu zobrazit úvod';

  @override
  String get reviewIntroSubtitle =>
      'Co je veřejné, co soukromé a limity blízkých přátel.';

  @override
  String noLightningWalletCopied(Object address) {
    return 'Lightning peněženka nenalezena: adresa zkopírována ($address)';
  }

  @override
  String get about => 'O aplikaci';

  @override
  String aboutText(Object version) {
    return 'Mialuna $version — Tvé okamžiky, pod stejným měsícem.\nOtevřený zdroj (MIT). github.com/Lwb89dev/mialuna';
  }

  @override
  String get invalidRelayAddress => 'Neplatná adresa: použij wss://…';

  @override
  String get invalidServerAddress => 'Neplatná adresa: použij https://…';

  @override
  String get relayRead => 'Čtení';

  @override
  String get relayWrite => 'Zápis';

  @override
  String get support => 'Podpora';

  @override
  String get supportText =>
      'Mialuna je zdarma, bez reklam a nesleduje tě. Když se ti líbí, můžeš poslat pár sats přes Lightning Network.';

  @override
  String get donateWithLightning => 'Přispět přes Lightning';

  @override
  String get authorNoZaps => 'Tento autor nepřijímá zaps';

  @override
  String get sendZap => 'Poslat zap ⚡';

  @override
  String get amountInSats => 'Částka v sats';

  @override
  String minMaxSats(Object min, Object max) {
    return 'min $min – max $max';
  }

  @override
  String get zap => 'Zap';

  @override
  String get signInToZap => 'Přihlásit se pro posílání zaps';

  @override
  String zapSent(Object sats) {
    return 'Zap $sats sats odeslán ⚡';
  }

  @override
  String nwcPaymentFailed(Object error) {
    return 'Platba NWC selhala: $error';
  }

  @override
  String get noLightningWallet => 'Lightning peněženka nenalezena';

  @override
  String storiesRailLabel(Object state) {
    return 'Příběhy, $state';
  }

  @override
  String get close => 'Zavřít';

  @override
  String hoursAgo(int hours) {
    return 'před $hours h';
  }

  @override
  String daysAgo(int days) {
    return 'před $days d';
  }

  @override
  String get now => 'teď';

  @override
  String get youPrefix => 'Ty: ';

  @override
  String get storiesStateUnseen => 'nové';

  @override
  String get storiesStateSeen => 'viděné';

  @override
  String weekdayShort(String day) {
    String _temp0 = intl.Intl.selectLogic(day, {
      'mon': 'Po',
      'tue': 'Út',
      'wed': 'St',
      'thu': 'Čt',
      'fri': 'Pá',
      'sat': 'So',
      'sun': 'Ne',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get sharedAMoment => 'Sdílený okamžik';

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
  String get cannotEditPhoto => 'Tuhle fotku tady upravit nejde.';

  @override
  String notificationsNew(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count nových oznámení',
      one: '1 nové oznámení',
    );
    return '$_temp0';
  }

  @override
  String messagesUnread(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count nepřečtených zpráv',
      one: '1 nepřečtená zpráva',
    );
    return '$_temp0';
  }

  @override
  String get done => 'Hotovo';

  @override
  String get storyAddText => 'Přidat text';

  @override
  String get storyEditText => 'Upravit text';

  @override
  String get storyTextHint => 'Napiš něco… #hashtags se dají klepnout';

  @override
  String get storyTextsHelp =>
      'Klepni na obrázek a piš. Táhni pro přesun, štípnutím změň velikost a otoč, klepni na text pro úpravu.';

  @override
  String storyTextsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count textů',
      one: '1 text',
      zero: 'Žádný text',
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
  String get storyTextBackground => 'Pozadí textu';

  @override
  String get storyTextColor => 'Barva textu';

  @override
  String storyTextLimit(int max) {
    return 'Můžeš přidat nejvýš $max textů.';
  }

  @override
  String get wotTitle => 'Síť důvěry';

  @override
  String get wotEnable => 'Síť důvěry je vždy zapnutá';

  @override
  String wotExplain(int min) {
    return 'Vždy zapnutá. Objevit ukazuje jen tuto síť: tebe, lidi, které sleduješ, a každého, koho sleduje aspoň $min z nich. Stejná síť skrývá komentáře, oznámení, soukromé příspěvky a zprávy od všech ostatních. Spočítá se na tomto telefonu z veřejných seznamů sledování při prvním otevření; později se znovu použije. Na žádný server se nic neposílá.';
  }

  @override
  String get wotRefresh => 'Obnovit síť teď';

  @override
  String get wotStatusIdle =>
      'Ještě není sestavená. Sestaví se při prvním otevření aplikace.';

  @override
  String get wotBuildingTitle => 'Sestavuje se tvůj přehled Objevit';

  @override
  String get wotBuildingBody =>
      'Čte se, koho sledují lidé, které sleduješ, a připravuje se Objevit.';

  @override
  String get wotDiscoverHint =>
      'Jen tvoje síť důvěry: lidé, které sleduješ, a lidé, které jich sleduje dost.';

  @override
  String get wotDiscoverSignIn =>
      'Objevit ukazuje tvou síť důvěry. Přihlásit se a při prvním otevření Mialuna přečte, koho sleduješ, a sestaví tento přehled. Později ho znovu použije.';

  @override
  String get wotDiscoverEmpty => 'Ze tvé sítě důvěry zatím žádné příspěvky.';

  @override
  String wotStatusDiscovering(int done, int total) {
    return 'Kontrola, koho sledují tví sledovaní… $done z $total';
  }

  @override
  String wotStatusComplete(int direct, int indirect, Object when) {
    return 'Tvoje síť: $direct lidí, které sleduješ, plus $indirect, které jich sleduje dost. Aktualizováno $when.';
  }

  @override
  String wotStatusFailed(Object reason) {
    return 'Síť se nepodařilo spočítat: $reason';
  }

  @override
  String get wotNoFollows => 'zatím nikoho nesleduješ';

  @override
  String get messageRequests => 'Žádosti o zprávu';

  @override
  String messageRequestsSubtitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count konverzací mimo tvou síť důvěry',
      one: '1 konverzace mimo tvou síť důvěry',
    );
    return '$_temp0';
  }

  @override
  String get messageRequestsHint =>
      'Od lidí mimo tvou síť důvěry. Nepočítají se jako nepřečtené. Odpověz a konverzace přejde do schránky.';

  @override
  String get storyViewsSetting => 'Ukazovat, že jsem viděl jejich příběhy';

  @override
  String get storyViewsSettingExplain =>
      'Když sleduješ příběh, autorovi se pošle potvrzení zašifrované tak, že ho přečte jen autor. Je v něm tvé jméno vedle jeho; relays nevidí nic. Když nejde doručit, zůstane uložené a zkusí se později. Vypni to a budeš sledovat bez oznámení: ještě neodeslaná potvrzení se zahodí (už doručené nejde vzít zpět).';

  @override
  String storySeenBy(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Viděno $count lidmi',
      one: 'Viděno 1 člověkem',
      zero: 'Zatím bez zhlédnutí',
    );
    return '$_temp0';
  }

  @override
  String get storyViewsEmpty =>
      'Tento příběh ještě nikdo nesledoval, nebo k tobě jejich potvrzení nedorazila.';

  @override
  String get storyViewsHint =>
      'Potvrzení posílají jen lidé, kteří to dovolí, takže skutečný počet může být vyšší.';

  @override
  String get systemNotifications => 'Systémová oznámení';

  @override
  String get systemNotificationsExplain =>
      'Ukaž na telefonu oznámení, když přijde něco nového a Mialuna je na pozadí. Soukromé zprávy nikdy neukážou text, ani na zamykací obrazovce. Android uspává aplikace, které jsou dlouho na pozadí, takže oznámení chodí, jen dokud Mialuna ještě běží.';

  @override
  String get systemNotificationsBlocked =>
      'Oznámení pro Mialuna jsou v nastavení telefonu vypnutá.';

  @override
  String get systemNotificationsOpenSettings => 'Otevřít nastavení';

  @override
  String get systemNotificationsBattery =>
      'Android uspí aplikace pár minut po zhasnutí obrazovky a oznámení s nimi přestanou. Aby chodila dál, nastav využití baterie Mialuna na “Neomezeno”.';

  @override
  String get systemNotificationsBatteryAction => 'Otevřít nastavení baterie';

  @override
  String get newFollowersSetting => 'Zobrazovat nové sledující';

  @override
  String get newFollowersSettingExplain =>
      'Noví sledující se objeví v Oznámeních a na telefonu. Vypni to, když tě lidé zaplavují sledováním: líbí se, komentáře a zaps se dál zobrazují.';

  @override
  String get systemNotificationMessage => 'poslal ti soukromou zprávu';

  @override
  String get systemNotificationNewMessage => 'Nová soukromá zpráva';

  @override
  String get systemNotificationNew => 'Nové oznámení';

  @override
  String get notificationChannelSocial => 'Reakce, komentáře, zaps a sledující';

  @override
  String get notificationChannelMessages => 'Soukromé zprávy';

  @override
  String get zapInvoiceMismatch =>
      'Faktura neodpovídá zvolené částce. Nic se nezaplatilo.';

  @override
  String get storyYourStory => 'Tvůj příběh';

  @override
  String get storyNew => 'Nový příběh';

  @override
  String get storyAddSemantics => 'Přidat do tvého příběhu';

  @override
  String storyOwnRailLabel(int count, Object state) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count příběhů',
      one: '1 příběh',
    );
    return 'Tvůj příběh, $_temp0, $state';
  }

  @override
  String get storyTextSize => 'Velikost textu';

  @override
  String get storyPickPrompt => 'Vyber fotku nebo video pro svůj příběh';

  @override
  String get storyEditPhoto => 'Upravit fotku';

  @override
  String get storyCaption => 'Popisek';

  @override
  String get storyDiscardTitle => 'Zahodit tento příběh?';

  @override
  String get storyDiscard => 'Zahodit';

  @override
  String get storyShare => 'Sdílet';

  @override
  String get storyShared => 'Příběh sdílen';

  @override
  String get deletePost => 'Smazat';

  @override
  String get deletePostTitle => 'Smazat tento příspěvek?';

  @override
  String get deleteStoryTitle => 'Smazat tento příběh?';

  @override
  String get deletePostBody =>
      'Mialuna požádá tvé relays o smazání a mediální servery o smazání fotek nebo videa. Když relay požadavek ignoruje, nebo když už někdo kopii uložil, pořád ji může mít.';

  @override
  String get deletePrivateBody =>
      'Příspěvek pro blízké přátele nejde z relays stáhnout zpět. Mialuna řekne aplikacím přátel, ať ho odeberou, a požádá mediální server o smazání šifrovaných souborů. Přítel, který už kopii uložil, ji pořád může mít.';

  @override
  String get deletingPost => 'Mazání…';

  @override
  String get postDeleted => 'Smazáno.';

  @override
  String get postWasDeleted => 'Tento příspěvek byl smazán.';

  @override
  String get deleteNotAllowed =>
      'Smazat to může jen účet, který to publikoval.';

  @override
  String deleteFailed(Object reason) {
    return 'Nepodařilo se smazat: $reason';
  }

  @override
  String get deleteNoRelay =>
      'Žádný relay požadavek na smazání nepřijal, takže je to pořád online. Zkontroluj připojení a zkus to znovu.';

  @override
  String deleteMediaLeft(Object servers) {
    return 'Média se nepodařilo odebrat z $servers.';
  }

  @override
  String get deleteMediaNotAuthorized =>
      'Tvůj podepisovač nepovolil odebrání médií, takže soubory jsou pořád na mediálním serveru.';

  @override
  String deleteFriendsMissed(Object count) {
    return '$count z tvých blízkých přátel se nepodařilo uvědomit, takže to může zůstat na jejich telefonech.';
  }

  @override
  String get storyCleanupSetting => 'Smazat moje příběhy po vypršení';

  @override
  String get storyCleanupSettingExplain =>
      'Po 24 hodinách Mialuna požádá tvé relays a mediální servery o smazání tvých příběhů, včetně fotek a videí. Server, který požadavek ignoruje, nebo někdo, kdo si nechal kopii, je pořád může mít.';

  @override
  String storyCleanupWaiting(Object count) {
    return 'Podepisovač musí každé čištění schválit, takže se čeká na tebe. Vypršené příběhy ve frontě: $count.';
  }

  @override
  String get storyCleanupNow => 'Smazat teď';

  @override
  String get storyCleanupDone => 'Vypršené příběhy smazány.';

  @override
  String get storyCleanupPartly =>
      'Některé se ještě nepodařilo smazat; Mialuna to zkusí znovu.';
}
