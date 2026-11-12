// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Croatian (`hr`).
class AppLocalizationsHr extends AppLocalizations {
  AppLocalizationsHr([String locale = 'hr']) : super(locale);

  @override
  String get syncUpToDate => 'Ažurno';

  @override
  String get syncFailed => 'Sinkronizacija nije uspjela';

  @override
  String get relaysUpdatedFromProfile =>
      'Relays su ažurirani iz tvog profila (NIP-65)';

  @override
  String get relayListPublished => 'Relay popis je objavljen';

  @override
  String get mediaServersUpdatedFromProfile =>
      'Medijski poslužitelji su ažurirani iz tvog profila';

  @override
  String get tabHome => 'Home';

  @override
  String get tabDiscover => 'Otkrij';

  @override
  String get tabCreate => 'Stvori';

  @override
  String get tabReels => 'Reels';

  @override
  String get tabProfile => 'Profil';

  @override
  String get signInToUploadMedia => 'Prijavi se da učitaš medij.';

  @override
  String get noMediaServer =>
      'Nije postavljen medijski poslužitelj. Dodaj ga u Postavkama.';

  @override
  String serverNoResponse(Object server) {
    return '$server: nema odgovora';
  }

  @override
  String serverUnreachable(Object server, Object error) {
    return '$server: nedostupan ($error)';
  }

  @override
  String uploadRejected(Object reason) {
    return 'Učitavanje odbijeno — $reason';
  }

  @override
  String noServerAcceptedFile(Object reasons) {
    return 'Niti jedan poslužitelj nije prihvatio datoteku — $reasons';
  }

  @override
  String get blossomInvalidResponse => 'nevaljan odgovor';

  @override
  String get blossomInvalidFileUrl => 'nevaljana adresa datoteke';

  @override
  String get blossomServerAlteredFile => 'poslužitelj je izmijenio datoteku';

  @override
  String get blossomBadRequest => 'nevaljan zahtjev';

  @override
  String get blossomUnauthorized => 'autorizacija odbijena';

  @override
  String get blossomPaymentRequired => 'potrebno je plaćanje';

  @override
  String get blossomForbidden => 'nije dopušteno';

  @override
  String get blossomLengthRequired => 'nedostaje veličina';

  @override
  String get blossomTooLarge => 'datoteka je prevelika';

  @override
  String get blossomUnsupportedType => 'format nije prihvaćen';

  @override
  String get blossomTooManyRequests => 'previše zahtjeva';

  @override
  String get blossomServerError => 'pogreška poslužitelja';

  @override
  String get cipherInvalidKey => 'Nevaljan ključ';

  @override
  String get cipherTruncated => 'Šifrirana datoteka je skraćena';

  @override
  String get cipherMismatch =>
      'Datoteka ne odgovara ključu: izmijenjena je ili oštećena';

  @override
  String get sanitizeHeifNeedsAsync =>
      'Format HEIC/AVIF: pretvorba traži sanitizeAsync';

  @override
  String get sanitizeWebmUnsupported =>
      'Video WebM/MKV nije podržan: koristi MP4 ili MOV da se metapodaci uklone prije učitavanja.';

  @override
  String get sanitizeUnknownFormat =>
      'Nepoznat format: fotografije JPEG/PNG/WebP/GIF ili video MP4/MOV.';

  @override
  String sanitizeLeftovers(Object items) {
    return 'Nije bilo moguće ukloniti sve metapodatke ($items): datoteka nije učitana.';
  }

  @override
  String sanitizeProcessingFailed(Object error) {
    return 'Datoteku nije bilo moguće obraditi: $error';
  }

  @override
  String get sanitizeJpegInvalid => 'Nevaljan JPEG';

  @override
  String get sanitizeJpegTruncated => 'Skraćen JPEG';

  @override
  String get sanitizeJpegNoSize => 'JPEG bez dimenzija';

  @override
  String get sanitizeJpegUndecodable => 'JPEG se ne može dekodirati';

  @override
  String get sanitizePngTruncated => 'Skraćen PNG';

  @override
  String get sanitizePngInvalid => 'Nevaljan PNG';

  @override
  String get sanitizeGifInvalid => 'Nevaljan GIF';

  @override
  String get sanitizeGifTruncated => 'Skraćen GIF';

  @override
  String get sanitizeWebpTruncated => 'Skraćen WebP';

  @override
  String get sanitizeWebpInvalid => 'Nevaljan WebP';

  @override
  String get sanitizeMp4Invalid => 'Nevaljan video MP4/MOV';

  @override
  String get sanitizeConversionFailed => 'Pretvorba nije uspjela';

  @override
  String get sanitizeHeifUnsupported =>
      'Ovaj format (HEIC/AVIF) ne može se pretvoriti na ovom uređaju. Odaberi fotografiju JPEG ili PNG.';

  @override
  String get privateMediaNotEncrypted => 'Medij nije šifriran';

  @override
  String serverReplied(Object status) {
    return 'Poslužitelj je odgovorio $status';
  }

  @override
  String get fileTooLarge => 'Datoteka je prevelika';

  @override
  String get serverFileNotOriginal => 'Datoteka na poslužitelju nije izvornik';

  @override
  String get contentMismatch => 'Sadržaj se ne podudara';

  @override
  String get mediaUnreachable => 'Medij je nedostupan';

  @override
  String get amberInvalidKey => 'Amber je vratio nevaljan ključ';

  @override
  String get amberNoKey => 'Amber nije vratio ključ';

  @override
  String get amberRequestRejected => 'Zahtjev je odbijen u Amberu';

  @override
  String get amberAndroidOnly => 'Amber je dostupan samo na Androidu';

  @override
  String get amberEmptySignature => 'Amber je vratio prazan potpis';

  @override
  String get amberSignRejected => 'Potpis je odbijen u Amberu';

  @override
  String get amberTimeout => 'Amber nije odgovorio na vrijeme';

  @override
  String get amberEmptyResponse => 'Amber je vratio prazan odgovor';

  @override
  String get bunkerInvalidUrl => 'Nevaljan bunker URL';

  @override
  String get bunkerNoRelay => 'bunker ne navodi niti jedan relay';

  @override
  String get bunkerWebAuth =>
      'bunker traži web autorizaciju (auth_url nije podržan)';

  @override
  String get bunkerInvalidKey => 'bunker nije vratio valjan ključ';

  @override
  String get signerInvalidResponse =>
      'Potpisnik je vratio nevaljan potpisan događaj';

  @override
  String get bunkerTimeout => 'Vrijeme za bunker je isteklo';

  @override
  String get nwcInvalidUri => 'Nevaljan NWC URI';

  @override
  String get nwcNoRelay => 'NWC URI ne navodi niti jedan relay';

  @override
  String get nwcNoSecret => 'NWC URI ne sadrži valjanu tajnu';

  @override
  String get nwcTimeout => 'Novčanik nije odgovorio na vrijeme';

  @override
  String get signerNoPrivateMessages =>
      'Ovaj način prijave ne podržava privatne poruke';

  @override
  String get zapNotSupported => 'Ova adresa ne podržava Nostr zap';

  @override
  String zapAmountOutOfRange(Object min, Object max) {
    return 'Iznos je izvan raspona ($min–$max sats)';
  }

  @override
  String get commentNotSent => 'Komentar nije poslan. Pokušaj kasnije.';

  @override
  String get comments => 'Komentari';

  @override
  String get noCommentsYet => 'Još nema komentara.';

  @override
  String get signInToComment => 'Prijavi se da komentiraš.';

  @override
  String get addComment => 'Dodaj komentar…';

  @override
  String get signInToPublish => 'Prijavi se da objaviš.';

  @override
  String get addMediaFirst =>
      'Dodaj barem jednu fotografiju ili video prije objave.';

  @override
  String get removingMetadata => 'Uklanjam metapodatke…';

  @override
  String uploadingProgress(Object current, Object total) {
    return 'Učitavam $current od $total…';
  }

  @override
  String get creatingPreview => 'Stvaram pretpregled…';

  @override
  String uploadFailed(Object error) {
    return 'Učitavanje nije uspjelo: $error';
  }

  @override
  String get publishing => 'Objavljujem…';

  @override
  String noRelayAcceptedPost(Object reason) {
    return 'Niti jedan relay nije prihvatio objavu$reason. Sadržaj ostaje u skicama.';
  }

  @override
  String get privateNeedsKeySigner =>
      'Ovaj način prijave ne podržava privatni sadržaj. Koristi Amber, bunker ili lokalni ključ.';

  @override
  String get closeFriendsListEmptyAddSomeone =>
      'Tvoj popis bliskih prijatelja je prazan: dodaj nekoga.';

  @override
  String get fileOver100Mb =>
      'Datoteka je veća od 100 MB: to je granica za bliske prijatelje (šifrira se cijela na tvom telefonu).';

  @override
  String get encryptingOnPhone => 'Šifriram na tvom telefonu…';

  @override
  String noServerAcceptedEncrypted(Object details) {
    return 'Niti jedan tvoj medijski poslužitelj nije prihvatio šifriranu datoteku. Ne objavljuje se u čitljivom obliku. U Postavkama dodaj poslužitelj koji prima šifrirane datoteke (na primjer cdn.hzrd149.com). $details';
  }

  @override
  String get sendingToFriends => 'Šaljem prijateljima…';

  @override
  String sendingToFriendsProgress(Object done, Object total) {
    return 'Šaljem prijateljima $done/$total…';
  }

  @override
  String noFriendReceivedPost(Object reason) {
    return 'Niti jedan prijatelj nije primio objavu$reason. Sadržaj ostaje u skicama.';
  }

  @override
  String sentToCloseFriends(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Poslano $count bliskim prijateljima 🔒',
      one: 'Poslano 1 bliskom prijatelju 🔒',
    );
    return '$_temp0';
  }

  @override
  String sentToFriendsWithMisses(int delivered, Object missed) {
    String _temp0 = intl.Intl.pluralLogic(
      delivered,
      locale: localeName,
      other: 'Poslano $delivered prijateljima.',
      one: 'Poslano 1 prijatelju.',
    );
    return '$_temp0 $missed nije primilo (privatne poruke su isključene).';
  }

  @override
  String get altText => 'Alt tekst';

  @override
  String get altTextHint => 'Opiši sadržaj ljudima koji ga ne vide…';

  @override
  String get cancel => 'Odustani';

  @override
  String get save => 'Spremi';

  @override
  String get momentPublished => 'Trenutak je objavljen ✨';

  @override
  String get newMoment => 'Novi trenutak';

  @override
  String get publish => 'Objavi';

  @override
  String get guestMode => 'Način Gost';

  @override
  String get signInToPostMoments => 'Prijavi se da objaviš svoje trenutke.';

  @override
  String get signIn => 'Prijava';

  @override
  String get kindPhoto => 'Fotografija';

  @override
  String get kindVideo => 'Video';

  @override
  String get kindReel => 'Reel';

  @override
  String get kindStory => 'Priča';

  @override
  String get storyExpiryNote =>
      'Priče istječu nakon 24 sata na relayima koji poštuju NIP-40, ali drugi ih i dalje mogu spremiti ili arhivirati.';

  @override
  String get fromGallery => 'Iz galerije';

  @override
  String get galleryLongPressVideo => 'Galerija (dugi pritisak za video)';

  @override
  String get addVideo => 'Dodaj video';

  @override
  String get camera => 'Kamera';

  @override
  String get exifRemovedNote =>
      'Metapodaci o lokaciji (EXIF) uklanjaju se automatski.';

  @override
  String get writeCaption => 'Napiši natpis…';

  @override
  String get privatePostNote =>
      'Privatna objava: nema javnih hashtagova i ne može se naći pretragom.';

  @override
  String willPublishAs(Object caption) {
    return 'Objavit će se kao: \"$caption\"';
  }

  @override
  String get tapThumbnailForAlt => 'Dodirni sličicu da dodaš alt tekst.';

  @override
  String get sensitiveContent => 'Osjetljiv sadržaj';

  @override
  String get sensitiveContentNote =>
      'Objava će biti skrivena iza upozorenja (NIP-36).';

  @override
  String get uploadingMedia => 'Učitavam medij…';

  @override
  String get audiencePublic => 'Javno';

  @override
  String get closeFriends => 'Bliski prijatelji';

  @override
  String get signerCannotPublishCloseFriends =>
      'Ovim načinom prijave ne možeš objavljivati za bliske prijatelje: koristi Amber, bunker ili lokalni ključ.';

  @override
  String get closeFriendsEmptyPrompt =>
      'Tvoj popis je prazan: dodaj ljude koji smiju vidjeti ovu objavu.';

  @override
  String onlyYourCloseFriendsSee(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Samo tvojih $count bliskih prijatelja će ovo vidjeti. Fotografije i videi šifriraju se na tvom telefonu prije učitavanja.',
      one: 'Samo 1 tvoj bliski prijatelj će ovo vidjeti. Fotografije i videi šifriraju se na tvom telefonu prije učitavanja.',
    );
    return '$_temp0';
  }

  @override
  String get addFriends => 'Dodaj prijatelje';

  @override
  String get manageList => 'Uredi popis';

  @override
  String get edit => 'Uredi';

  @override
  String get reset => 'Poništi';

  @override
  String get apply => 'Primijeni';

  @override
  String get cropFree => 'Slobodno';

  @override
  String get cropOriginal => 'Izvorno';

  @override
  String get rotate => 'Rotiraj';

  @override
  String get flip => 'Zrcali';

  @override
  String get brightness => 'Svjetlina';

  @override
  String get contrast => 'Kontrast';

  @override
  String get saturation => 'Zasićenje';

  @override
  String postsByAuthor(Object author) {
    return 'Objave od $author…';
  }

  @override
  String get searchHint => 'Traži ljude, hashtagove ili riječi…';

  @override
  String get clear => 'Očisti';

  @override
  String get recent => 'Nedavno';

  @override
  String get searchDependsOnRelays =>
      'Pretraga ovisi o postavljenim relayima: rezultati mogu biti djelomični.';

  @override
  String get recentPostsEverywhere =>
      'Nedavne objave iz cijele mreže, uključujući ljude koje ne pratiš.';

  @override
  String get noResultsOnRelays => 'Nema rezultata na postavljenim relayima.';

  @override
  String get noRecentPostsFromFollowed =>
      'Nema nedavnih objava ljudi koje pratiš.';

  @override
  String get noMomentsFound => 'Nema trenutaka na relayima. Provjeri vezu.';

  @override
  String get loadFailed => 'Učitavanje nije uspjelo';

  @override
  String get notifications => 'Obavijesti';

  @override
  String get messages => 'Poruke';

  @override
  String get homeEmptyFollowsNobody =>
      'Ovdje se pojavljuju objave ljudi koje pratiš.\nJoš nikoga ne pratiš: otkrij zanimljive ljude i profile.';

  @override
  String get discoverPeople => 'Otkrij ljude';

  @override
  String get homeEmpty =>
      'Još nema trenutaka.\nPovuci prema dolje za osvježavanje ili objavi prvi kadar.';

  @override
  String get retry => 'Pokušaj ponovo';

  @override
  String get seenEverything => 'To je sve za sada ✨';

  @override
  String get discoverMoreProfiles => 'Otkrij još profila';

  @override
  String get feedFollowing => 'Pratim';

  @override
  String get signInToSeeFollowed =>
      'Prijavi se da vidiš objave ljudi koje pratiš';

  @override
  String get videoPreview => 'Pretpregled videa';

  @override
  String get cannotOpenPrivateVideo => 'Ne mogu otvoriti privatni video';

  @override
  String get cannotPlayVideo => 'Ne mogu reproducirati video';

  @override
  String get pauseVideo => 'Pauziraj video';

  @override
  String get playVideo => 'Reproduciraj video';

  @override
  String errorTapToRetry(Object error) {
    return '$error — dodirni za ponovni pokušaj';
  }

  @override
  String get soundOn => 'Uključi zvuk';

  @override
  String get soundOff => 'Isključi zvuk';

  @override
  String get postImage => 'Slika objave';

  @override
  String get imageUnavailable => 'Slika nije dostupna';

  @override
  String errorTapToRetryNewline(Object message) {
    return '$message\nDodirni za ponovni pokušaj';
  }

  @override
  String get cannotOpenPrivateContent =>
      'Ne mogu otvoriti ovaj privatni sadržaj';

  @override
  String get privateImage => 'Privatna slika';

  @override
  String get invalidImage => 'Nevaljana slika';

  @override
  String get more => 'Više';

  @override
  String get removeFromSaved => 'Ukloni iz spremljenog';

  @override
  String get copyLink => 'Kopiraj poveznicu';

  @override
  String get muteAuthor => 'Utišaj autora';

  @override
  String get blockAuthor => 'Blokiraj autora';

  @override
  String get report => 'Prijavi';

  @override
  String get like => 'Sviđa mi se';

  @override
  String get sendInMessage => 'Pošalji u poruci';

  @override
  String get zapOptional => 'Zap (neobavezno)';

  @override
  String get closeFriendsOnlyNote =>
      'Vidljivo samo bliskim prijateljima. Sviđanja i odgovori idu samo autoru.';

  @override
  String get likeFailed => 'Sviđanje nije poslano';

  @override
  String get nostrLinkCopied => 'Nostr poveznica je kopirana';

  @override
  String get authorMuted => 'Autor je utišan';

  @override
  String get authorBlocked => 'Autor je blokiran';

  @override
  String get reportSent => 'Prijava je poslana (NIP-56)';

  @override
  String get signInToReport => 'Prijavi se da pošalješ prijavu';

  @override
  String minutesAgo(Object minutes) {
    return 'prije $minutes min';
  }

  @override
  String get show => 'Prikaži';

  @override
  String get chatEmptyHint =>
      'Napiši prvu poruku.\nŠifrirana je: nitko drugi je ne vidi.';

  @override
  String get messageHint => 'Poruka…';

  @override
  String get send => 'Pošalji';

  @override
  String get notSentSuffix => ' nije poslano';

  @override
  String get contentUnavailable =>
      'Sadržaj nije dostupan (istekao je ili nije nađen na relayima)';

  @override
  String get signInToSendPrivateMessages =>
      'Prijavi se da šalješ privatne poruke.';

  @override
  String get cannotMessageYourself => 'Ne možeš pisati samom sebi.';

  @override
  String get recipientNoPrivateMessages =>
      'Ova osoba još nije uključila privatne poruke.';

  @override
  String noRecipientRelayAccepted(Object reason) {
    return 'Niti jedan relay primatelja nije prihvatio poruku$reason.';
  }

  @override
  String sendFailed(Object error) {
    return 'Slanje nije uspjelo: $error';
  }

  @override
  String get signInToReadMessages =>
      'Prijavi se da čitaš i šalješ privatne poruke.';

  @override
  String get signerNoPrivateMessagesLong =>
      'Privatne poruke ne rade s ovim načinom prijave. Prijavi se s Amberom, bunkerom ili lokalnim ključem.';

  @override
  String get inboxEmpty =>
      'Nema razgovora.\nDodirni olovku da pišeš nekome ili proslijedi trenutak ikonom ✈ ispod svake objave.';

  @override
  String get newMessage => 'Nova poruka';

  @override
  String get privateMessagesEnabled => 'Privatne poruke su uključene';

  @override
  String get enableMessagesFailed =>
      'Nije ih bilo moguće uključiti. Pokušaj ponovo.';

  @override
  String get enablePrivateMessages => 'Uključi privatne poruke';

  @override
  String enablePrivateMessagesExplain(Object count) {
    return 'Da primaš poruke, reci na koje relaye stižu. Objavljuje se mali popis (NIP-17) sa $count zadanih relaya: možeš ga kasnije promijeniti. Poruke ostaju šifrirane: relayi ne vide ni tko piše ni tekst.';
  }

  @override
  String get turnOn => 'Uključi';

  @override
  String get searchByNameOrUsername => 'Traži po imenu ili korisničkom imenu';

  @override
  String get searching => 'Tražim…';

  @override
  String get noOneWithNameHint =>
      'Nitko s tim imenom. Pokušaj s manje slova ili adresom poput name@domain.com.';

  @override
  String get sent => 'Poslano';

  @override
  String sentToPeople(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Poslano $count osoba',
      one: 'Poslano 1 osobi',
    );
    return '$_temp0';
  }

  @override
  String sentToPeopleWithFailure(int count, Object failure) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Poslano $count osoba. $failure',
      one: 'Poslano 1 osobi. $failure',
    );
    return '$_temp0';
  }

  @override
  String get signerNoPrivateMessagesShort =>
      'Ne možeš koristiti privatne poruke s ovim načinom prijave.';

  @override
  String get followToStartOrSearch =>
      'Prati nekoga da počneš ili traži po imenu.';

  @override
  String get addMessage => 'Dodaj poruku…';

  @override
  String sendWithCount(Object count) {
    return 'Pošalji ($count)';
  }

  @override
  String get linkCopied => 'Poveznica je kopirana';

  @override
  String get noNotifications => 'Trenutačno nema obavijesti.';

  @override
  String get notificationsDependOnRelays =>
      'Obavijesti ovise o relayima: mogu biti nepotpune.';

  @override
  String get reactedToYourMoment => 'reagira na tvoj trenutak';

  @override
  String commentedText(Object text) {
    return 'komentira: $text';
  }

  @override
  String sentYouSats(Object sats, Object comment) {
    return 'ti šalje $sats sats$comment';
  }

  @override
  String get sentYouZap => 'ti šalje zap';

  @override
  String get startedFollowingYou => 'sad te prati';

  @override
  String get amberNotFound => 'Amber nije pronađen';

  @override
  String get amberExplain =>
      'Amber je Nostr potpisnik koji drži tvoj privatni ključ izvan Mialuna. Instaliraj ga i pokušaj ponovo.';

  @override
  String get downloadFromFdroid => 'Preuzmi s F-Droid';

  @override
  String get continueWithAmber => 'Nastavi s Amberom';

  @override
  String get amberRecommended =>
      'Preporučeno: tvoj privatni ključ ostaje siguran u Amberu.';

  @override
  String get amberNotDetected =>
      'Amber nije otkriven: instaliraj ga za preporučenu prijavu.';

  @override
  String get exploreWithoutAccount => 'Istraži bez računa';

  @override
  String get remoteBunker => 'Udaljeni bunker (NIP-46)';

  @override
  String get invalidBunkerUrlDot => 'Nevaljan bunker URL.';

  @override
  String get connectBunker => 'Poveži bunker';

  @override
  String get advancedNsec => 'Napredna prijava (nsec)';

  @override
  String get nsecWarning =>
      'Upozorenje: lijepljenje privatnog ključa je rizično. Ne dijeli ga ni s kim. Na Androidu radije Amber.';

  @override
  String get invalidNsec => 'Nevaljan nsec ključ.';

  @override
  String get signInWithNsec => 'Prijava s nsec';

  @override
  String get tagline => 'Tvoji trenuci, pod istim mjesecom.';

  @override
  String get skip => 'Preskoči';

  @override
  String get permissionsAndWallet => 'Dozvole i novčanik';

  @override
  String get permissionsExplain =>
      'Služe samo da objavljuješ i primaš obavijesti. Možeš ih promijeniti u bilo kojem trenutku u postavkama sustava.';

  @override
  String get photosAndVideos => 'Fotografije i videi';

  @override
  String get toUploadYourMoments => 'Da učitaš svoje trenutke';

  @override
  String get allow => 'Dopusti';

  @override
  String get reactionsCommentsZaps => 'Reakcije, komentari i zap';

  @override
  String get lightningWalletOptional => 'Lightning novčanik (neobavezno)';

  @override
  String get nwcExplain =>
      'Poveži novčanik Nostr Wallet Connect da šalješ zap bez izlaska iz aplikacije.';

  @override
  String get walletConnected => 'Novčanik je povezan';

  @override
  String get disconnect => 'Odspoji';

  @override
  String get connectWallet => 'Poveži novčanik';

  @override
  String get getStarted => 'Kreni';

  @override
  String get welcome1 =>
      'Mialuna je vizualna društvena mreža: fotografije, videi, Reels i priče — nikad objave samo s tekstom.';

  @override
  String get welcome2 =>
      'Radi na Nostru, otvorenom protokolu: tvoj identitet je ključ koji posjeduješ, a ne račun koji ti tvrtka može oduzeti. Bez oglasa, bez trackera, bez središnjih poslužitelja.';

  @override
  String get welcome3 =>
      'Podijeli svoje svjetlo s ljudima svugdje, iz svake aplikacije koja govori isti otvoreni jezik.';

  @override
  String onboardingWot(int min) {
    return 'Tvoja mreža povjerenja je uvijek uključena. Prvi put kad otvoriš Mialuna, čita koga pratiš i od te mreže gradi feed Otkrij: ti, ljudi koje pratiš i svi koje prati barem $min njih. Sljedeći put kad otvoriš aplikaciju, taj feed je već tu.';
  }

  @override
  String get publicAndPrivate => 'Javno i privatno';

  @override
  String get publicAndPrivateIntro =>
      'Mialuna je na Nostru, otvorenoj mreži. Što objaviš, javno je: objave, fotografije i videi ostaju vidljivi svakome s poveznicom, čak i izvan Mialuna.';

  @override
  String get closeFriendsExplain1 =>
      'Samo ljudi s ovog popisa primaju tvoje objave, priče i videe „Bliski prijatelji“. Popis je unutar objave; ne moraš ga birati svaki put.';

  @override
  String get closeFriendsExplain2 =>
      'Fotografije i videi šifriraju se na tvom telefonu prije učitavanja. Datotečni poslužitelji (Blossom) sami ne šifriraju ništa: zato to radi Mialuna, a poslužitelj vidi samo nečitljive podatke. Tko nađe adresu datoteke, ne može je otvoriti.';

  @override
  String get closeFriendsExplain3 =>
      'Nije apsolutno jamstvo: tko primi objavu može snimiti zaslon, a uklanjanje prijatelja vrijedi samo za buduće objave.';

  @override
  String get closeFriendsExplain4 =>
      'Svaki prijatelj mora koristiti Mialuna s uključenim privatnim porukama. Drugi Nostr klijenti ne prikazuju ove objave.';

  @override
  String get closeFriendsExplain5 =>
      'Javne objave ostaju javne: njihove datoteke vidi svatko s poveznicom.';

  @override
  String get closeFriendsExplain6 =>
      'Ako niti jedan tvoj poslužitelj ne prima šifrirane datoteke, objava se ne objavljuje: nikad u čitljivom obliku.';

  @override
  String get addToCloseFriends => 'Dodaj u bliske prijatelje';

  @override
  String maxFriendsReached(Object max, Object added) {
    return 'Granica od $max prijatelja: dodano $added.';
  }

  @override
  String get add => 'Dodaj';

  @override
  String get signInToCreateList => 'Prijavi se da stvoriš svoj popis.';

  @override
  String get signerNoCloseFriends =>
      'Bliski prijatelji ne rade s ovim načinom prijave. Prijavi se s Amberom, bunkerom ili lokalnim ključem.';

  @override
  String peopleOfMax(Object count, Object max) {
    return '$count / $max osoba';
  }

  @override
  String get noOneYet => 'Još nema nikoga.';

  @override
  String get addPeople => 'Dodaj ljude';

  @override
  String get friendNoPrivateMessagesWarning =>
      'Nisu uključili privatne poruke: neće primati tvoje objave';

  @override
  String get removeFromList => 'Ukloni s popisa';

  @override
  String get noOneWithThisName => 'Nitko s tim imenom.';

  @override
  String get signInToSendPrivateContent =>
      'Prijavi se da šalješ privatni sadržaj.';

  @override
  String get reasonNoPrivateMessages => 'nema uključene privatne poruke';

  @override
  String get reasonNoRelayAnswered => 'niti jedan relay nije odgovorio';

  @override
  String get profileUpdated => 'Profil je ažuriran';

  @override
  String get noRelayAcceptedRetry =>
      'Niti jedan relay nije prihvatio. Pokušaj kasnije.';

  @override
  String get editProfile => 'Uredi profil';

  @override
  String get fieldName => 'Ime';

  @override
  String get fieldBio => 'Bio';

  @override
  String get fieldAvatarUrl => 'URL avatara';

  @override
  String get fieldNip05 => 'NIP-05 (npr. you@example.com)';

  @override
  String get browsingAsGuest => 'Pregledavaš kao gost';

  @override
  String get signInToInteract =>
      'Prijavi se da objavljuješ, pratiš i sudjeluješ.';

  @override
  String get settings => 'Postavke';

  @override
  String get signOut => 'Odjava';

  @override
  String get npubCopied => 'npub je kopiran';

  @override
  String get copyNpub => 'Kopiraj npub';

  @override
  String get mute => 'Utišaj';

  @override
  String get block => 'Blokiraj';

  @override
  String get posts => 'Objave';

  @override
  String get saved => 'Spremljeno';

  @override
  String get nothingPublishedYet => 'Još nemaš objava.';

  @override
  String get noPostsOnRelays => 'Nema objava na relayima.';

  @override
  String get noReelsPublished => 'Nema objavljenih reelsa.';

  @override
  String get noReelsOnRelays => 'Nema reelsa na relayima.';

  @override
  String get noSavedPosts => 'Nema spremljenih objava.';

  @override
  String get followingButton => 'Pratiš';

  @override
  String get follow => 'Prati';

  @override
  String get messageButton => 'Poruka';

  @override
  String get loginLocalKey => 'Lokalni ključ';

  @override
  String get loginGuest => 'Gost';

  @override
  String get followUpdateFailed =>
      'Praćenja se trenutačno ne mogu ažurirati. Pokušaj ponovo.';

  @override
  String get noReelsComeBack => 'Nema reelsa na relayima.\nVrati se uskoro!';

  @override
  String get followUpdateFailedShort =>
      'Praćenja se trenutačno ne mogu ažurirati';

  @override
  String get needOneReadRelay => 'Potreban je barem jedan relay za čitanje.';

  @override
  String get listSavedLocally =>
      'Popis je spremljen na ovom uređaju, nije objavljen.';

  @override
  String get noRelayAcceptedList =>
      'Niti jedan relay nije prihvatio popis: pokušat će se kasnije.';

  @override
  String relayListPublishedTo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Relay popis je objavljen na $count relaya',
      one: 'Relay popis je objavljen na 1 relay',
    );
    return '$_temp0';
  }

  @override
  String get mediaServersUpdated => 'Medijski poslužitelji su ažurirani';

  @override
  String get appearance => 'Izgled';

  @override
  String get publishingSettings => 'Objavljivanje';

  @override
  String get addMialunaHashtag => 'Dodaj #mialuna';

  @override
  String get addMialunaHashtagNote =>
      'Dodaje službeni hashtag javnim objavama i pričama. Možeš to isključiti u bilo kojem trenutku.';

  @override
  String get themeLight => 'Svijetla';

  @override
  String get themeDark => 'Tamna';

  @override
  String get themeSystem => 'Sustav';

  @override
  String get relays => 'Relays';

  @override
  String get relaysExplainSignedOut =>
      'Relays pohranjuju i dijele sadržaj. Prijavi se da automatski koristiš vlastiti popis (NIP-65).';

  @override
  String get relaysExplainSynced =>
      'Popis je usklađen s tvojim Nostr profilom (NIP-65): svaka promjena se objavljuje i vrijedi za sve tvoje aplikacije.';

  @override
  String get syncing => 'Sinkronizacija…';

  @override
  String get waitingFirstSync => 'Čekam prvu sinkronizaciju';

  @override
  String get syncNow => 'Sinkroniziraj sada';

  @override
  String get addRelay => 'Dodaj relay';

  @override
  String get restoreDefaultRelays => 'Vrati zadane relaye';

  @override
  String get createYourList => 'Stvori svoj popis';

  @override
  String peopleCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count osoba',
      one: '1 osoba',
    );
    return '$_temp0';
  }

  @override
  String get closeFriendsSettingsNote =>
      'Objave, priče i videi vidljivi samo njima, sa šifriranim fotografijama i videima.';

  @override
  String get mediaServersBlossom => 'Medijski poslužitelji (Blossom)';

  @override
  String get mediaServersExplain =>
      'Fotografije i videi učitavaju se samo na ove poslužitelje, redom kako su prikazani: prvi koji ih prihvati, dobiva ih. EXIF i lokacija uklanjaju se prije učitavanja.';

  @override
  String get primary => 'Glavni';

  @override
  String get makePrimary => 'Postavi kao glavni';

  @override
  String get remove => 'Ukloni';

  @override
  String get addServer => 'Dodaj poslužitelj';

  @override
  String get moderation => 'Moderacija';

  @override
  String get moderationExplain =>
      'Utišani autori i skriveni hashtagovi sinkroniziraju se preko NIP-51. Blokirani autori ostaju samo na ovom uređaju.';

  @override
  String get mutedAuthors => 'Utišani autori';

  @override
  String get noMutedAuthors => 'Nema utišanih autora';

  @override
  String get blockedAuthors => 'Blokirani autori';

  @override
  String get noBlockedAuthors => 'Nema blokiranih autora';

  @override
  String get hiddenHashtags => 'Skriveni hashtagovi';

  @override
  String get noHiddenHashtags => 'Nema skrivenih hashtagova';

  @override
  String get hashtagToHide => '#hashtag za skrivanje';

  @override
  String get storage => 'Pohrana';

  @override
  String get clearCache => 'Očisti predmemoriju događaja i skice';

  @override
  String get cacheCleared => 'Predmemorija je očišćena';

  @override
  String get reviewIntro => 'Pogledaj uvod';

  @override
  String get reviewIntroSubtitle =>
      'Što je javno, što je privatno i granice bliskih prijatelja.';

  @override
  String noLightningWalletCopied(Object address) {
    return 'Nije pronađen Lightning novčanik: adresa je kopirana ($address)';
  }

  @override
  String get about => 'O aplikaciji';

  @override
  String aboutText(Object version) {
    return 'Mialuna $version — Tvoji trenuci, pod istim mjesecom.\nOtvoreni kod (MIT). github.com/Lwb89dev/mialuna';
  }

  @override
  String get invalidRelayAddress => 'Nevaljana adresa: koristi wss://…';

  @override
  String get invalidServerAddress => 'Nevaljana adresa: koristi https://…';

  @override
  String get relayRead => 'Čitanje';

  @override
  String get relayWrite => 'Pisanje';

  @override
  String get support => 'Podrška';

  @override
  String get supportText =>
      'Mialuna je besplatna, nema oglasa i ne prati te. Ako ti se sviđa, možeš poslati nekoliko sats preko Lightning Networka.';

  @override
  String get donateWithLightning => 'Doniraj preko Lightninga';

  @override
  String get authorNoZaps => 'Ovaj autor ne prima zap';

  @override
  String get sendZap => 'Pošalji zap ⚡';

  @override
  String get amountInSats => 'Iznos u sats';

  @override
  String minMaxSats(Object min, Object max) {
    return 'min $min – max $max';
  }

  @override
  String get zap => 'Zap';

  @override
  String get signInToZap => 'Prijavi se da šalješ zap';

  @override
  String zapSent(Object sats) {
    return 'Zap od $sats sats je poslan ⚡';
  }

  @override
  String nwcPaymentFailed(Object error) {
    return 'NWC plaćanje nije uspjelo: $error';
  }

  @override
  String get noLightningWallet => 'Nije pronađen Lightning novčanik';

  @override
  String storiesRailLabel(Object state) {
    return 'Priče, $state';
  }

  @override
  String get close => 'Zatvori';

  @override
  String hoursAgo(int hours) {
    return 'prije $hours h';
  }

  @override
  String daysAgo(int days) {
    return 'prije $days d';
  }

  @override
  String get now => 'sad';

  @override
  String get youPrefix => 'Ti: ';

  @override
  String get storiesStateUnseen => 'novo';

  @override
  String get storiesStateSeen => 'viđeno';

  @override
  String weekdayShort(String day) {
    String _temp0 = intl.Intl.selectLogic(day, {
      'mon': 'pon',
      'tue': 'uto',
      'wed': 'sri',
      'thu': 'čet',
      'fri': 'pet',
      'sat': 'sub',
      'sun': 'ned',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get sharedAMoment => 'Dijeli trenutak';

  @override
  String get blossomOtherError => 'pogreška';

  @override
  String get languageTitle => 'Jezik';

  @override
  String get languageSystem => 'Sustav';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageItalian => 'Italiano';

  @override
  String get cannotEditPhoto => 'Ova fotografija se ovdje ne može urediti.';

  @override
  String notificationsNew(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count novih obavijesti',
      one: '1 nova obavijest',
    );
    return '$_temp0';
  }

  @override
  String messagesUnread(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count nepročitanih poruka',
      one: '1 nepročitana poruka',
    );
    return '$_temp0';
  }

  @override
  String get done => 'Gotovo';

  @override
  String get storyAddText => 'Dodaj tekst';

  @override
  String get storyEditText => 'Uredi tekst';

  @override
  String get storyTextHint => 'Napiši nešto… #hashtags se mogu dodirnuti';

  @override
  String get storyTextsHelp =>
      'Dodirni sliku da pišeš. Povuci za pomicanje, stisni za veličinu i rotaciju, dodirni tekst da ga urediš.';

  @override
  String storyTextsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count teksta',
      one: '1 tekst',
      zero: 'Nema teksta',
    );
    return '$_temp0';
  }

  @override
  String get storyFontClassic => 'Klasično';

  @override
  String get storyFontBold => 'Podebljano';

  @override
  String get storyFontSerif => 'Serif';

  @override
  String get storyFontMono => 'Mono';

  @override
  String get storyFontItalic => 'Kurziv';

  @override
  String get storyTextBackground => 'Pozadina teksta';

  @override
  String get storyTextColor => 'Boja teksta';

  @override
  String storyTextLimit(int max) {
    return 'Možeš dodati najviše $max tekstova.';
  }

  @override
  String get wotTitle => 'Mreža povjerenja';

  @override
  String get wotEnable => 'Tvoja mreža povjerenja je uvijek uključena';

  @override
  String wotExplain(int min) {
    return 'Uvijek uključena. Otkrij pokazuje samo ovu mrežu povjerenja: ti, ljudi koje pratiš i svi koje prati barem $min njih. Ista mreža povjerenja skriva komentare, obavijesti, privatne objave i poruke od svih ostalih. Računa se na ovom telefonu iz javnih popisa praćenja prvi put kad otvoriš aplikaciju; kasnija otvaranja je ponovno koriste. Ništa se ne šalje ni na jedan poslužitelj.';
  }

  @override
  String get wotRefresh => 'Osvježi mrežu sada';

  @override
  String get wotStatusIdle =>
      'Još nije izgrađena. Gradi se prvi put kad otvoriš aplikaciju.';

  @override
  String get wotBuildingTitle => 'Gradim tvoj feed Otkrij';

  @override
  String get wotBuildingBody =>
      'Čitam koga prate ljudi koje pratiš i pripremam Otkrij.';

  @override
  String get wotDiscoverHint =>
      'Samo tvoja mreža povjerenja: ljudi koje pratiš i ljudi koje ih dovoljno prati.';

  @override
  String get wotDiscoverSignIn =>
      'Otkrij pokazuje tvoju mrežu povjerenja. Prijavi se i prvi put Mialuna čita koga pratiš i gradi ovaj feed. Kasnija otvaranja ga ponovno koriste.';

  @override
  String get wotDiscoverEmpty => 'Još nema objava iz tvoje mreže povjerenja.';

  @override
  String wotStatusDiscovering(int done, int total) {
    return 'Provjeravam koga prate ljudi koje pratiš… $done od $total';
  }

  @override
  String wotStatusComplete(int direct, int indirect, Object when) {
    return 'Tvoja mreža: $direct osoba koje pratiš plus $indirect koje ih dovoljno prati. Ažurirano $when.';
  }

  @override
  String wotStatusFailed(Object reason) {
    return 'Mrežu nije bilo moguće izračunati: $reason';
  }

  @override
  String get wotNoFollows => 'još nikoga ne pratiš';

  @override
  String get messageRequests => 'Zahtjevi za poruke';

  @override
  String messageRequestsSubtitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count razgovora izvan tvoje mreže povjerenja',
      one: '1 razgovor izvan tvoje mreže povjerenja',
    );
    return '$_temp0';
  }

  @override
  String get messageRequestsHint =>
      'Od ljudi izvan tvoje mreže povjerenja. Ne broje se kao nepročitane. Odgovori da razgovor prebaciš u pristiglu poštu.';

  @override
  String get storyViewsSetting => 'Neka ljudi vide moj pregled njihovih priča';

  @override
  String get storyViewsSettingExplain =>
      'Kad gledaš priču, autoru se šalje potvrda, šifrirana tako da je samo autor može pročitati. Navodi tvoje ime uz ime autora; relayi ne vide ništa. Ako se ne može isporučiti, čuva se i pokušava kasnije. Isključi da gledaš a da nitko ne sazna: potvrde koje još nisu poslane se odbacuju (već isporučenu nije moguće povući).';

  @override
  String storySeenBy(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Vidjelo je $count osoba',
      one: 'Vidjela je 1 osoba',
      zero: 'Još nema pregleda',
    );
    return '$_temp0';
  }

  @override
  String get storyViewsEmpty =>
      'Još nitko nije pogledao ovu priču ili njihove potvrde nisu stigle do tebe.';

  @override
  String get storyViewsHint =>
      'Samo ljudi koji to dopuštaju šalju potvrdu, pa stvarni broj može biti veći.';

  @override
  String get systemNotifications => 'Obavijesti sustava';

  @override
  String get systemNotificationsExplain =>
      'Prikaži obavijest na telefonu kad stigne nešto novo dok je Mialuna u pozadini. Privatne poruke nikad ne pokazuju tekst, čak ni na zaključanom zaslonu. Android pauzira aplikacije koje dugo ostanu u pozadini, pa obavijesti stižu dok Mialuna još radi.';

  @override
  String get systemNotificationsBlocked =>
      'Obavijesti za Mialuna su isključene u postavkama telefona.';

  @override
  String get systemNotificationsOpenSettings => 'Otvori postavke';

  @override
  String get systemNotificationsBattery =>
      'Android uspavljuje aplikacije nekoliko minuta nakon što se zaslon ugasi, a obavijesti stanu s njima. Da ih i dalje primaš, postavi potrošnju baterije za Mialuna na “Neograničeno”.';

  @override
  String get systemNotificationsBatteryAction => 'Otvori postavke baterije';

  @override
  String get newFollowersSetting => 'Prikazuj nove pratitelje';

  @override
  String get newFollowersSettingExplain =>
      'Novi pratitelji se pojavljuju u Obavijestima i na telefonu. Isključi ako te zasipaju praćenjima: sviđanja, komentari i zap ostaju.';

  @override
  String get systemNotificationMessage => 'ti šalje privatnu poruku';

  @override
  String get systemNotificationNewMessage => 'Nova privatna poruka';

  @override
  String get systemNotificationNew => 'Nova obavijest';

  @override
  String get notificationChannelSocial =>
      'Reakcije, komentari, zap i pratitelji';

  @override
  String get notificationChannelMessages => 'Privatne poruke';

  @override
  String get zapInvoiceMismatch =>
      'Račun ne odgovara odabranom iznosu. Ništa nije plaćeno.';

  @override
  String get storyYourStory => 'Tvoja priča';

  @override
  String get storyNew => 'Nova priča';

  @override
  String get storyAddSemantics => 'Dodaj na svoju priču';

  @override
  String storyOwnRailLabel(int count, Object state) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count priča',
      one: '1 priča',
    );
    return 'Tvoja priča, $_temp0, $state';
  }

  @override
  String get storyTextSize => 'Veličina teksta';

  @override
  String get storyPickPrompt => 'Odaberi fotografiju ili video za svoju priču';

  @override
  String get storyEditPhoto => 'Uredi fotografiju';

  @override
  String get storyCaption => 'Natpis';

  @override
  String get storyDiscardTitle => 'Odbaciti ovu priču?';

  @override
  String get storyDiscard => 'Odbaci';

  @override
  String get storyShare => 'Podijeli';

  @override
  String get storyShared => 'Priča je podijeljena';

  @override
  String get deletePost => 'Izbriši';

  @override
  String get deletePostTitle => 'Izbrisati ovu objavu?';

  @override
  String get deleteStoryTitle => 'Izbrisati ovu priču?';

  @override
  String get deletePostBody =>
      'Mialuna će zamoliti tvoje relaye da je izbrišu i medijske poslužitelje da izbrišu fotografije ili video. relay koji zanemari zahtjev, ili netko tko je već spremio kopiju, može je i dalje imati.';

  @override
  String get deletePrivateBody =>
      'Objavu za bliske prijatelje nije moguće povući s relaya. Mialuna će reći aplikacijama prijatelja da je uklone i zamoliti medijski poslužitelj da izbriše šifrirane datoteke. Prijatelj koji je već spremio kopiju može je i dalje imati.';

  @override
  String get deletingPost => 'Brišem…';

  @override
  String get postDeleted => 'Izbrisano.';

  @override
  String get postWasDeleted => 'Ova objava je izbrisana.';

  @override
  String get deleteNotAllowed =>
      'Samo račun koji je ovo objavio može to izbrisati.';

  @override
  String deleteFailed(Object reason) {
    return 'Nije bilo moguće izbrisati: $reason';
  }

  @override
  String get deleteNoRelay =>
      'Niti jedan relay nije prihvatio zahtjev za brisanje, pa je i dalje online. Provjeri vezu i pokušaj ponovo.';

  @override
  String deleteMediaLeft(Object servers) {
    return 'Medij nije bilo moguće ukloniti sa $servers.';
  }

  @override
  String get deleteMediaNotAuthorized =>
      'Tvoj potpisnik nije odobrio uklanjanje medija, pa su datoteke i dalje na medijskom poslužitelju.';

  @override
  String deleteFriendsMissed(Object count) {
    return '$count tvojih bliskih prijatelja nije bilo moguće obavijestiti, pa može ostati na njihovim telefonima.';
  }

  @override
  String get storyCleanupSetting => 'Briši moje priče kad isteknu';

  @override
  String get storyCleanupSettingExplain =>
      'Nakon 24 sata Mialuna moli tvoje relaye i medijske poslužitelje da izbrišu tvoje priče, uključujući fotografije i videe. Poslužitelj koji zanemari zahtjev, ili netko tko je zadržao kopiju, može ih i dalje imati.';

  @override
  String storyCleanupWaiting(Object count) {
    return 'Potpisnik mora odobriti svako čišćenje, pa se čeka dok to ne zatražiš. Istekle priče na čekanju: $count.';
  }

  @override
  String get storyCleanupNow => 'Izbriši sada';

  @override
  String get storyCleanupDone => 'Istekle priče su izbrisane.';

  @override
  String get storyCleanupPartly =>
      'Neke još nije bilo moguće izbrisati; Mialuna će pokušati ponovo.';

  @override
  String get editorPro => 'Pro uređivač';

  @override
  String get editorModeBasic => 'Osnovno';

  @override
  String get editorModePro => 'Pro';

  @override
  String get toolCrop => 'Obreži';

  @override
  String get toolLight => 'Svjetlo';

  @override
  String get toolColor => 'Boja';

  @override
  String get toolHsl => 'HSL';

  @override
  String get toolCurves => 'Krivulje';

  @override
  String get toolEffects => 'Efekti';

  @override
  String get straighten => 'Izravnaj';

  @override
  String get exposure => 'Ekspozicija';

  @override
  String get highlights => 'Svjetla';

  @override
  String get shadows => 'Sjene';

  @override
  String get whites => 'Bijele';

  @override
  String get blacks => 'Crne';

  @override
  String get temperature => 'Temperatura';

  @override
  String get tint => 'Ton';

  @override
  String get vibrance => 'Živost';

  @override
  String get hue => 'Nijansa';

  @override
  String get luminance => 'Svjetlina';

  @override
  String get colorRed => 'Crvena';

  @override
  String get colorOrange => 'Narančasta';

  @override
  String get colorYellow => 'Žuta';

  @override
  String get colorGreen => 'Zelena';

  @override
  String get colorAqua => 'Tirkizna';

  @override
  String get colorBlue => 'Plava';

  @override
  String get colorPurple => 'Ljubičasta';

  @override
  String get colorMagenta => 'Magenta';

  @override
  String get curveHint =>
      'Povucite točku za oblikovanje krivulje, dodirnite za dodavanje, dvaput dodirnite za uklanjanje.';

  @override
  String get sharpen => 'Izoštravanje';

  @override
  String get vignette => 'Vinjeta';

  @override
  String get grain => 'Zrno';

  @override
  String get holdForOriginal =>
      'Držite fotografiju da je usporedite s izvornikom.';

  @override
  String get showingOriginal => 'Izvornik';

  @override
  String get applyLookToAll => 'Primijeni ovaj izgled na sve fotografije';

  @override
  String get applyingEdits => 'Obrada fotografija…';

  @override
  String get choosePhotoToEdit => 'Odaberite fotografiju za uređivanje';
}
