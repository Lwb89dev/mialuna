// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Polish (`pl`).
class AppLocalizationsPl extends AppLocalizations {
  AppLocalizationsPl([String locale = 'pl']) : super(locale);

  @override
  String get syncUpToDate => 'Aktualne';

  @override
  String get syncFailed => 'Sync nieudany';

  @override
  String get relaysUpdatedFromProfile =>
      'Relays zaktualizowane z twojego profilu (NIP-65)';

  @override
  String get relayListPublished => 'Lista Relay opublikowana';

  @override
  String get mediaServersUpdatedFromProfile =>
      'Serwery mediów zaktualizowane z twojego profilu';

  @override
  String get tabHome => 'Home';

  @override
  String get tabDiscover => 'Odkrywaj';

  @override
  String get tabCreate => 'Utwórz';

  @override
  String get tabReels => 'Reels';

  @override
  String get tabProfile => 'Profil';

  @override
  String get signInToUploadMedia => 'Zaloguj się, aby przesłać media.';

  @override
  String get noMediaServer =>
      'Nie skonfigurowano serwera mediów. Dodaj go w Ustawieniach.';

  @override
  String serverNoResponse(Object server) {
    return '$server: brak odpowiedzi';
  }

  @override
  String serverUnreachable(Object server, Object error) {
    return '$server: nieosiągalny ($error)';
  }

  @override
  String uploadRejected(Object reason) {
    return 'Przesyłanie odrzucone — $reason';
  }

  @override
  String noServerAcceptedFile(Object reasons) {
    return 'Żaden serwer nie przyjął pliku — $reasons';
  }

  @override
  String get blossomInvalidResponse => 'nieprawidłowa odpowiedź';

  @override
  String get blossomInvalidFileUrl => 'nieprawidłowy adres pliku';

  @override
  String get blossomServerAlteredFile => 'serwer zmienił plik';

  @override
  String get blossomBadRequest => 'nieprawidłowe żądanie';

  @override
  String get blossomUnauthorized => 'autoryzacja odrzucona';

  @override
  String get blossomPaymentRequired => 'wymagana płatność';

  @override
  String get blossomForbidden => 'niedozwolone';

  @override
  String get blossomLengthRequired => 'brak rozmiaru';

  @override
  String get blossomTooLarge => 'plik za duży';

  @override
  String get blossomUnsupportedType => 'format niezaakceptowany';

  @override
  String get blossomTooManyRequests => 'zbyt wiele żądań';

  @override
  String get blossomServerError => 'błąd serwera';

  @override
  String get cipherInvalidKey => 'Nieprawidłowy klucz';

  @override
  String get cipherTruncated => 'Zaszyfrowany plik jest obcięty';

  @override
  String get cipherMismatch =>
      'Plik nie pasuje do klucza: zmieniony lub uszkodzony';

  @override
  String get sanitizeHeifNeedsAsync =>
      'Format HEIC/AVIF: konwersja wymaga sanitizeAsync';

  @override
  String get sanitizeWebmUnsupported =>
      'Wideo WebM/MKV nie jest obsługiwane: użyj MP4 lub MOV, aby metadane dało się usunąć przed przesłaniem.';

  @override
  String get sanitizeUnknownFormat =>
      'Nierozpoznany format pliku: zdjęcia JPEG/PNG/WebP/GIF lub wideo MP4/MOV.';

  @override
  String sanitizeLeftovers(Object items) {
    return 'Nie udało się usunąć wszystkich metadanych ($items): plik nie został przesłany.';
  }

  @override
  String sanitizeProcessingFailed(Object error) {
    return 'Nie udało się przetworzyć pliku: $error';
  }

  @override
  String get sanitizeJpegInvalid => 'Nieprawidłowy JPEG';

  @override
  String get sanitizeJpegTruncated => 'Obcięty JPEG';

  @override
  String get sanitizeJpegNoSize => 'JPEG bez wymiarów';

  @override
  String get sanitizeJpegUndecodable => 'Nie można zdekodować JPEG';

  @override
  String get sanitizePngTruncated => 'Obcięty PNG';

  @override
  String get sanitizePngInvalid => 'Nieprawidłowy PNG';

  @override
  String get sanitizeGifInvalid => 'Nieprawidłowy GIF';

  @override
  String get sanitizeGifTruncated => 'Obcięty GIF';

  @override
  String get sanitizeWebpTruncated => 'Obcięty WebP';

  @override
  String get sanitizeWebpInvalid => 'Nieprawidłowy WebP';

  @override
  String get sanitizeMp4Invalid => 'Nieprawidłowe wideo MP4/MOV';

  @override
  String get sanitizeConversionFailed => 'Konwersja nie powiodła się';

  @override
  String get sanitizeHeifUnsupported =>
      'Tego formatu (HEIC/AVIF) nie da się przekonwertować na tym urządzeniu. Wybierz zdjęcie JPEG lub PNG.';

  @override
  String get privateMediaNotEncrypted => 'Media nie są zaszyfrowane';

  @override
  String serverReplied(Object status) {
    return 'Serwer odpowiedział $status';
  }

  @override
  String get fileTooLarge => 'Plik za duży';

  @override
  String get serverFileNotOriginal => 'Plik na serwerze nie jest oryginałem';

  @override
  String get contentMismatch => 'Treść się nie zgadza';

  @override
  String get mediaUnreachable => 'Media nieosiągalne';

  @override
  String get amberInvalidKey => 'Amber zwrócił nieprawidłowy klucz';

  @override
  String get amberNoKey => 'Amber nie zwrócił klucza';

  @override
  String get amberRequestRejected => 'Żądanie odrzucone w Amber';

  @override
  String get amberAndroidOnly => 'Amber jest dostępny tylko na Androidzie';

  @override
  String get amberEmptySignature => 'Amber zwrócił pusty podpis';

  @override
  String get amberSignRejected => 'Podpis odrzucony w Amber';

  @override
  String get amberTimeout => 'Amber nie odpowiedział na czas';

  @override
  String get amberEmptyResponse => 'Amber zwrócił pustą odpowiedź';

  @override
  String get bunkerInvalidUrl => 'Nieprawidłowy URL bunker';

  @override
  String get bunkerNoRelay => 'Bunker nie podaje żadnego relay';

  @override
  String get bunkerWebAuth =>
      'Bunker wymaga autoryzacji w przeglądarce (auth_url nie jest obsługiwany)';

  @override
  String get bunkerInvalidKey => 'Bunker nie zwrócił prawidłowego klucza';

  @override
  String get signerInvalidResponse =>
      'Podpisujący zwrócił nieprawidłowe podpisane zdarzenie';

  @override
  String get bunkerTimeout => 'Bunker nie odpowiedział na czas';

  @override
  String get nwcInvalidUri => 'Nieprawidłowy URI NWC';

  @override
  String get nwcNoRelay => 'URI NWC nie podaje żadnego relay';

  @override
  String get nwcNoSecret => 'URI NWC nie zawiera prawidłowego sekretu';

  @override
  String get nwcTimeout => 'Portfel nie odpowiedział na czas';

  @override
  String get signerNoPrivateMessages =>
      'Ta metoda logowania nie obsługuje prywatnych wiadomości';

  @override
  String get zapNotSupported => 'Ten adres nie obsługuje Nostr zaps';

  @override
  String zapAmountOutOfRange(Object min, Object max) {
    return 'Kwota poza zakresem ($min–$max sats)';
  }

  @override
  String get commentNotSent =>
      'Komentarz nie został wysłany. Spróbuj ponownie później.';

  @override
  String get comments => 'Komentarze';

  @override
  String get noCommentsYet => 'Brak komentarzy.';

  @override
  String get signInToComment => 'Zaloguj się, aby skomentować.';

  @override
  String get addComment => 'Dodaj komentarz…';

  @override
  String get signInToPublish => 'Zaloguj się, aby opublikować.';

  @override
  String get addMediaFirst =>
      'Dodaj co najmniej jedno zdjęcie lub wideo przed publikacją.';

  @override
  String get removingMetadata => 'Usuwanie metadanych…';

  @override
  String uploadingProgress(Object current, Object total) {
    return 'Przesyłanie $current z $total…';
  }

  @override
  String get creatingPreview => 'Tworzenie podglądu…';

  @override
  String uploadFailed(Object error) {
    return 'Przesyłanie nie powiodło się: $error';
  }

  @override
  String get publishing => 'Publikowanie…';

  @override
  String noRelayAcceptedPost(Object reason) {
    return 'Żaden relay nie przyjął wpisu$reason. Treść zostaje w twoich szkicach.';
  }

  @override
  String get privateNeedsKeySigner =>
      'Ta metoda logowania nie obsługuje prywatnych treści. Użyj Amber, bunker lub klucza lokalnego.';

  @override
  String get closeFriendsListEmptyAddSomeone =>
      'Twoja lista bliskich znajomych jest pusta: dodaj kogoś.';

  @override
  String get fileOver100Mb =>
      'Plik ma ponad 100 MB: to limit dla bliskich znajomych (jest szyfrowany w całości na twoim telefonie).';

  @override
  String get encryptingOnPhone => 'Szyfrowanie na twoim telefonie…';

  @override
  String noServerAcceptedEncrypted(Object details) {
    return 'Żaden z twoich serwerów mediów nie przyjął zaszyfrowanego pliku. Nie zostanie opublikowany jawnie. Dodaj w Ustawieniach serwer, który przyjmuje zaszyfrowane pliki (na przykład cdn.hzrd149.com). $details';
  }

  @override
  String get sendingToFriends => 'Wysyłanie do znajomych…';

  @override
  String sendingToFriendsProgress(Object done, Object total) {
    return 'Wysyłanie do znajomych $done/$total…';
  }

  @override
  String noFriendReceivedPost(Object reason) {
    return 'Żaden znajomy nie otrzymał wpisu$reason. Treść zostaje w twoich szkicach.';
  }

  @override
  String sentToCloseFriends(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Wysłano do $count bliskich znajomych 🔒',
      one: 'Wysłano do 1 bliskiego znajomego 🔒',
    );
    return '$_temp0';
  }

  @override
  String sentToFriendsWithMisses(int delivered, Object missed) {
    String _temp0 = intl.Intl.pluralLogic(
      delivered,
      locale: localeName,
      other: 'Wysłano do $delivered znajomych.',
      one: 'Wysłano do 1 znajomego.',
    );
    return '$_temp0 $missed nie otrzymało tego (prywatne wiadomości są wyłączone).';
  }

  @override
  String get altText => 'Tekst alt';

  @override
  String get altTextHint => 'Opisz treść dla osób, które jej nie widzą…';

  @override
  String get cancel => 'Anuluj';

  @override
  String get save => 'Zapisz';

  @override
  String get momentPublished => 'Moment opublikowany ✨';

  @override
  String get newMoment => 'Nowy moment';

  @override
  String get publish => 'Opublikuj';

  @override
  String get guestMode => 'Tryb gościa';

  @override
  String get signInToPostMoments =>
      'Zaloguj się, aby publikować swoje momenty.';

  @override
  String get signIn => 'Zaloguj się';

  @override
  String get kindPhoto => 'Zdjęcie';

  @override
  String get kindVideo => 'Wideo';

  @override
  String get kindReel => 'Reel';

  @override
  String get kindStory => 'Relacja';

  @override
  String get storyExpiryNote =>
      'Relacje wygasają po 24 godzinach na relays, które honorują NIP-40, ale inni nadal mogą je zapisać lub zarchiwizować.';

  @override
  String get fromGallery => 'Z galerii';

  @override
  String get galleryLongPressVideo => 'Galeria (przytrzymaj, aby wybrać wideo)';

  @override
  String get addVideo => 'Dodaj wideo';

  @override
  String get camera => 'Aparat';

  @override
  String get exifRemovedNote =>
      'Metadane lokalizacji (EXIF) są usuwane automatycznie.';

  @override
  String get writeCaption => 'Napisz podpis…';

  @override
  String get privatePostNote =>
      'Prywatny wpis: bez publicznych hashtagów, nie da się go znaleźć w wyszukiwaniu.';

  @override
  String willPublishAs(Object caption) {
    return 'Zostanie opublikowane jako: \"$caption\"';
  }

  @override
  String get tapThumbnailForAlt => 'Stuknij miniaturę, aby dodać tekst alt.';

  @override
  String get sensitiveContent => 'Wrażliwe treści';

  @override
  String get sensitiveContentNote =>
      'Wpis zostanie ukryty za ostrzeżeniem (NIP-36).';

  @override
  String get uploadingMedia => 'Przesyłanie mediów…';

  @override
  String get audiencePublic => 'Publiczne';

  @override
  String get closeFriends => 'Bliscy znajomi';

  @override
  String get signerCannotPublishCloseFriends =>
      'Przy tej metodzie logowania nie opublikujesz dla bliskich znajomych: użyj Amber, bunker lub klucza lokalnego.';

  @override
  String get closeFriendsEmptyPrompt =>
      'Twoja lista jest pusta: dodaj osoby, które mogą zobaczyć ten wpis.';

  @override
  String onlyYourCloseFriendsSee(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Tylko twoich $count bliskich znajomych to zobaczy. Zdjęcia i wideo są szyfrowane na twoim telefonie przed przesłaniem.',
      one: 'Tylko twój 1 bliski znajomy to zobaczy. Zdjęcia i wideo są szyfrowane na twoim telefonie przed przesłaniem.',
    );
    return '$_temp0';
  }

  @override
  String get addFriends => 'Dodaj znajomych';

  @override
  String get manageList => 'Zarządzaj listą';

  @override
  String get edit => 'Edytuj';

  @override
  String get reset => 'Resetuj';

  @override
  String get apply => 'Zastosuj';

  @override
  String get cropFree => 'Dowolny';

  @override
  String get cropOriginal => 'Oryginał';

  @override
  String get rotate => 'Obróć';

  @override
  String get flip => 'Odbij';

  @override
  String get brightness => 'Jasność';

  @override
  String get contrast => 'Kontrast';

  @override
  String get saturation => 'Nasycenie';

  @override
  String postsByAuthor(Object author) {
    return 'Wpisy $author…';
  }

  @override
  String get searchHint => 'Szukaj osób, hashtagów lub słów…';

  @override
  String get clear => 'Wyczyść';

  @override
  String get recent => 'Ostatnie';

  @override
  String get searchDependsOnRelays =>
      'Wyszukiwanie zależy od skonfigurowanych relays: wyniki mogą być niepełne.';

  @override
  String get recentPostsEverywhere =>
      'Ostatnie wpisy z całej sieci, także osób, których nie obserwujesz.';

  @override
  String get noResultsOnRelays => 'Brak wyników na skonfigurowanych relays.';

  @override
  String get noRecentPostsFromFollowed =>
      'Brak ostatnich wpisów od osób, które obserwujesz.';

  @override
  String get noMomentsFound =>
      'Nie znaleziono momentów na relays. Sprawdź połączenie.';

  @override
  String get loadFailed => 'Wczytywanie nieudane';

  @override
  String get notifications => 'Powiadomienia';

  @override
  String get messages => 'Wiadomości';

  @override
  String get homeEmptyFollowsNobody =>
      'Wpisy osób, które obserwujesz, pojawiają się tutaj.\nNie obserwujesz jeszcze nikogo: odkrywaj ciekawe osoby i profile.';

  @override
  String get discoverPeople => 'Odkrywaj osoby';

  @override
  String get homeEmpty =>
      'Brak momentów.\nPociągnij w dół, aby odświeżyć, lub opublikuj pierwsze ujęcie.';

  @override
  String get retry => 'Spróbuj ponownie';

  @override
  String get seenEverything => 'To na razie wszystko ✨';

  @override
  String get discoverMoreProfiles => 'Odkrywaj więcej profili';

  @override
  String get feedFollowing => 'Obserwujesz';

  @override
  String get signInToSeeFollowed =>
      'Zaloguj się, aby zobaczyć wpisy osób, które obserwujesz';

  @override
  String get videoPreview => 'Podgląd wideo';

  @override
  String get cannotOpenPrivateVideo => 'Nie można otworzyć prywatnego wideo';

  @override
  String get cannotPlayVideo => 'Nie można odtworzyć wideo';

  @override
  String get pauseVideo => 'Wstrzymaj wideo';

  @override
  String get playVideo => 'Odtwórz wideo';

  @override
  String errorTapToRetry(Object error) {
    return '$error — stuknij, aby spróbować ponownie';
  }

  @override
  String get soundOn => 'Włącz dźwięk';

  @override
  String get soundOff => 'Wyłącz dźwięk';

  @override
  String get postImage => 'Obraz wpisu';

  @override
  String get imageUnavailable => 'Obraz niedostępny';

  @override
  String errorTapToRetryNewline(Object message) {
    return '$message\nStuknij, aby spróbować ponownie';
  }

  @override
  String get cannotOpenPrivateContent =>
      'Nie można otworzyć tej prywatnej treści';

  @override
  String get privateImage => 'Prywatny obraz';

  @override
  String get invalidImage => 'Nieprawidłowy obraz';

  @override
  String get more => 'Więcej';

  @override
  String get removeFromSaved => 'Usuń z zapisanych';

  @override
  String get copyLink => 'Kopiuj link';

  @override
  String get muteAuthor => 'Wycisz autora';

  @override
  String get blockAuthor => 'Zablokuj autora';

  @override
  String get report => 'Zgłoś';

  @override
  String get like => 'Lubię';

  @override
  String get sendInMessage => 'Wyślij w wiadomości';

  @override
  String get zapOptional => 'Zap (opcjonalnie)';

  @override
  String get closeFriendsOnlyNote =>
      'Widoczne tylko dla bliskich znajomych. Polubienia i odpowiedzi trafiają tylko do autora.';

  @override
  String get likeFailed => 'Nie udało się wysłać polubienia';

  @override
  String get nostrLinkCopied => 'Link Nostr skopiowany do schowka';

  @override
  String get authorMuted => 'Autor wyciszony';

  @override
  String get authorBlocked => 'Autor zablokowany';

  @override
  String get reportSent => 'Zgłoszenie wysłane (NIP-56)';

  @override
  String get signInToReport => 'Zaloguj się, aby zgłosić';

  @override
  String minutesAgo(Object minutes) {
    return '$minutes min temu';
  }

  @override
  String get show => 'Pokaż';

  @override
  String get chatEmptyHint =>
      'Napisz pierwszą wiadomość.\nJest zaszyfrowana: tylko wy dwoje ją widzicie.';

  @override
  String get messageHint => 'Wiadomość…';

  @override
  String get send => 'Wyślij';

  @override
  String get notSentSuffix => ' nie wysłano';

  @override
  String get contentUnavailable =>
      'Treść niedostępna (wygasła lub nieznaleziona na relays)';

  @override
  String get signInToSendPrivateMessages =>
      'Zaloguj się, aby wysyłać prywatne wiadomości.';

  @override
  String get cannotMessageYourself => 'Nie możesz pisać do siebie.';

  @override
  String get recipientNoPrivateMessages =>
      'Ta osoba nie włączyła jeszcze prywatnych wiadomości.';

  @override
  String noRecipientRelayAccepted(Object reason) {
    return 'Żaden relay odbiorcy nie przyjął wiadomości$reason.';
  }

  @override
  String sendFailed(Object error) {
    return 'Wysyłanie nie powiodło się: $error';
  }

  @override
  String get signInToReadMessages =>
      'Zaloguj się, aby czytać i wysyłać prywatne wiadomości.';

  @override
  String get signerNoPrivateMessagesLong =>
      'Prywatne wiadomości nie działają z tą metodą logowania. Zaloguj się przez Amber, bunker lub klucz lokalny.';

  @override
  String get inboxEmpty =>
      'Brak rozmów.\nStuknij ołówek, aby do kogoś napisać, albo prześlij moment ikoną ✈ pod każdym wpisem.';

  @override
  String get newMessage => 'Nowa wiadomość';

  @override
  String get privateMessagesEnabled => 'Prywatne wiadomości włączone';

  @override
  String get enableMessagesFailed =>
      'Nie udało się ich włączyć. Spróbuj ponownie.';

  @override
  String get enablePrivateMessages => 'Włącz prywatne wiadomości';

  @override
  String enablePrivateMessagesExplain(Object count) {
    return 'Aby otrzymywać wiadomości, wskaż, na które relays mają przychodzić. Publikowana jest krótka lista (NIP-17) z $count domyślnymi relays: możesz ją później zmienić. Wiadomości pozostają zaszyfrowane: relays nie widzą, kto pisze, ani treści.';
  }

  @override
  String get turnOn => 'Włącz';

  @override
  String get searchByNameOrUsername =>
      'Szukaj po nazwie lub nazwie użytkownika';

  @override
  String get searching => 'Szukanie…';

  @override
  String get noOneWithNameHint =>
      'Nikt o tej nazwie. Spróbuj mniej liter albo adresu w rodzaju name@domain.com.';

  @override
  String get sent => 'Wysłano';

  @override
  String sentToPeople(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Wysłano do $count osób',
      one: 'Wysłano do 1 osoby',
    );
    return '$_temp0';
  }

  @override
  String sentToPeopleWithFailure(int count, Object failure) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Wysłano do $count osób. $failure',
      one: 'Wysłano do 1 osoby. $failure',
    );
    return '$_temp0';
  }

  @override
  String get signerNoPrivateMessagesShort =>
      'Nie możesz używać prywatnych wiadomości z tą metodą logowania.';

  @override
  String get followToStartOrSearch =>
      'Obserwuj kogoś, aby zacząć, albo szukaj po nazwie.';

  @override
  String get addMessage => 'Dodaj wiadomość…';

  @override
  String sendWithCount(Object count) {
    return 'Wyślij ($count)';
  }

  @override
  String get linkCopied => 'Link skopiowany do schowka';

  @override
  String get noNotifications => 'Teraz brak powiadomień.';

  @override
  String get notificationsDependOnRelays =>
      'Powiadomienia zależą od relays: mogą być niepełne.';

  @override
  String get reactedToYourMoment => 'zareagował(a) na twój moment';

  @override
  String commentedText(Object text) {
    return 'skomentował(a): $text';
  }

  @override
  String sentYouSats(Object sats, Object comment) {
    return 'wysłał(a) ci $sats sats$comment';
  }

  @override
  String get sentYouZap => 'wysłał(a) ci zap';

  @override
  String get startedFollowingYou => 'zaczął(a) cię obserwować';

  @override
  String get amberNotFound => 'Nie znaleziono Amber';

  @override
  String get amberExplain =>
      'Amber to signer Nostr, który trzyma twój klucz prywatny poza Mialuna. Zainstaluj go i spróbuj ponownie.';

  @override
  String get downloadFromFdroid => 'Pobierz z F-Droid';

  @override
  String get continueWithAmber => 'Kontynuuj z Amber';

  @override
  String get amberRecommended =>
      'Zalecane: twój klucz prywatny zostaje bezpiecznie w Amber.';

  @override
  String get amberNotDetected =>
      'Nie wykryto Amber: zainstaluj, aby logować się w zalecany sposób.';

  @override
  String get exploreWithoutAccount => 'Przeglądaj bez konta';

  @override
  String get remoteBunker => 'Zdalny bunker (NIP-46)';

  @override
  String get invalidBunkerUrlDot => 'Nieprawidłowy URL bunker.';

  @override
  String get connectBunker => 'Połącz bunker';

  @override
  String get advancedNsec => 'Zaawansowane logowanie (nsec)';

  @override
  String get nsecWarning =>
      'Ostrzeżenie: wklejanie klucza prywatnego jest ryzykowne. Nigdy nikomu go nie podawaj. Na Androidzie lepiej użyj Amber.';

  @override
  String get invalidNsec => 'Nieprawidłowy klucz nsec.';

  @override
  String get signInWithNsec => 'Zaloguj się z nsec';

  @override
  String get tagline => 'Twoje momenty, pod tym samym księżycem.';

  @override
  String get skip => 'Pomiń';

  @override
  String get permissionsAndWallet => 'Uprawnienia i portfel';

  @override
  String get permissionsExplain =>
      'Pozwalają tylko publikować i dostawać powiadomienia. Możesz je zawsze zmienić w ustawieniach systemu.';

  @override
  String get photosAndVideos => 'Zdjęcia i wideo';

  @override
  String get toUploadYourMoments => 'Aby przesyłać swoje momenty';

  @override
  String get allow => 'Zezwól';

  @override
  String get reactionsCommentsZaps => 'Reakcje, komentarze i zaps';

  @override
  String get lightningWalletOptional => 'Portfel Lightning (opcjonalnie)';

  @override
  String get nwcExplain =>
      'Połącz portfel Nostr Wallet Connect, aby wysyłać zaps bez opuszczania aplikacji.';

  @override
  String get walletConnected => 'Portfel połączony';

  @override
  String get disconnect => 'Odłącz';

  @override
  String get connectWallet => 'Połącz portfel';

  @override
  String get getStarted => 'Zaczynamy';

  @override
  String get welcome1 =>
      'Mialuna to wizualna sieć społecznościowa: zdjęcia, wideo, Reels i relacje — nigdy wpisy z samym tekstem.';

  @override
  String get welcome2 =>
      'Działa na Nostr, otwartym protokole: twoja tożsamość to klucz, który należy do ciebie, a nie konto, które firma może odebrać. Bez reklam, bez śledzenia, bez centralnych serwerów.';

  @override
  String get welcome3 =>
      'Dziel się swoim światłem z ludźmi wszędzie, z każdej aplikacji, która mówi tym samym otwartym językiem.';

  @override
  String onboardingWot(int min) {
    return 'Sieć zaufania jest zawsze włączona. Przy pierwszym otwarciu Mialuna odczytuje, kogo obserwujesz, i buduje feed Odkrywaj z tej sieci: ty, osoby, które obserwujesz, i każdy, kogo obserwuje co najmniej $min z nich. Przy kolejnych otwarciach ten feed już jest.';
  }

  @override
  String get publicAndPrivate => 'Publiczne i prywatne';

  @override
  String get publicAndPrivateIntro =>
      'Mialuna działa na Nostr, otwartej sieci. To, co publikujesz, jest publiczne: wpisy, zdjęcia i wideo zostają widoczne dla każdego z linkiem, także poza Mialuna.';

  @override
  String get closeFriendsExplain1 =>
      'Tylko osoby z tej listy otrzymują twoje wpisy, relacje i wideo \"Bliscy znajomi\". Lista jest wewnątrz wpisu; nie musisz jej wybierać za każdym razem.';

  @override
  String get closeFriendsExplain2 =>
      'Zdjęcia i wideo są szyfrowane na twoim telefonie przed przesłaniem. Serwery plików (Blossom) same niczego nie szyfrują: dlatego robi to Mialuna, a serwer widzi tylko nieczytelne dane. Kto znajdzie adres pliku, nie otworzy go.';

  @override
  String get closeFriendsExplain3 =>
      'To nie absolutna gwarancja: kto otrzyma wpis, może zrobić zrzut ekranu, a usunięcie znajomego dotyczy tylko przyszłych wpisów.';

  @override
  String get closeFriendsExplain4 =>
      'Każdy znajomy musi używać Mialuna z włączonymi prywatnymi wiadomościami. Inne klienty Nostr nie pokazują tych wpisów.';

  @override
  String get closeFriendsExplain5 =>
      'Publiczne wpisy zostają publiczne: ich pliki widzi każdy, kto ma link.';

  @override
  String get closeFriendsExplain6 =>
      'Jeśli żaden z twoich serwerów nie przyjmuje zaszyfrowanych plików, wpis nie jest publikowany: nigdy jawnie.';

  @override
  String get addToCloseFriends => 'Dodaj do bliskich znajomych';

  @override
  String maxFriendsReached(Object max, Object added) {
    return 'Limit $max znajomych: dodano $added.';
  }

  @override
  String get add => 'Dodaj';

  @override
  String get signInToCreateList => 'Zaloguj się, aby utworzyć swoją listę.';

  @override
  String get signerNoCloseFriends =>
      'Bliscy znajomi nie działają z tą metodą logowania. Zaloguj się przez Amber, bunker lub klucz lokalny.';

  @override
  String peopleOfMax(Object count, Object max) {
    return '$count / $max osób';
  }

  @override
  String get noOneYet => 'Jeszcze nikogo.';

  @override
  String get addPeople => 'Dodaj osoby';

  @override
  String get friendNoPrivateMessagesWarning =>
      'Nie włączyli prywatnych wiadomości: nie dostaną twoich wpisów';

  @override
  String get removeFromList => 'Usuń z listy';

  @override
  String get noOneWithThisName => 'Nikt o tej nazwie.';

  @override
  String get signInToSendPrivateContent =>
      'Zaloguj się, aby wysyłać prywatne treści.';

  @override
  String get reasonNoPrivateMessages =>
      'nie ma włączonych prywatnych wiadomości';

  @override
  String get reasonNoRelayAnswered => 'żaden relay nie odpowiedział';

  @override
  String get profileUpdated => 'Profil zaktualizowany';

  @override
  String get noRelayAcceptedRetry =>
      'Żaden relay tego nie przyjął. Spróbuj ponownie później.';

  @override
  String get editProfile => 'Edytuj profil';

  @override
  String get fieldName => 'Nazwa';

  @override
  String get fieldBio => 'Bio';

  @override
  String get fieldAvatarUrl => 'URL awatara';

  @override
  String get fieldNip05 => 'NIP-05 (np. you@example.com)';

  @override
  String get browsingAsGuest => 'Przeglądasz jako gość';

  @override
  String get signInToInteract =>
      'Zaloguj się, aby publikować, obserwować i reagować.';

  @override
  String get settings => 'Ustawienia';

  @override
  String get signOut => 'Wyloguj się';

  @override
  String get npubCopied => 'npub skopiowany';

  @override
  String get copyNpub => 'Kopiuj npub';

  @override
  String get mute => 'Wycisz';

  @override
  String get block => 'Zablokuj';

  @override
  String get posts => 'Wpisy';

  @override
  String get saved => 'Zapisane';

  @override
  String get nothingPublishedYet => 'Jeszcze nic nie opublikowano.';

  @override
  String get noPostsOnRelays => 'Nie znaleziono wpisów na relays.';

  @override
  String get noReelsPublished => 'Brak opublikowanych reels.';

  @override
  String get noReelsOnRelays => 'Nie znaleziono reels na relays.';

  @override
  String get noSavedPosts => 'Brak zapisanych wpisów.';

  @override
  String get followingButton => 'Obserwujesz';

  @override
  String get follow => 'Obserwuj';

  @override
  String get messageButton => 'Wiadomość';

  @override
  String get loginLocalKey => 'Klucz lokalny';

  @override
  String get loginGuest => 'Gość';

  @override
  String get followUpdateFailed =>
      'Nie udało się teraz zaktualizować obserwowanych. Spróbuj ponownie.';

  @override
  String get noReelsComeBack =>
      'Nie znaleziono reels na relays.\nWróć wkrótce!';

  @override
  String get followUpdateFailedShort =>
      'Nie udało się teraz zaktualizować obserwowanych';

  @override
  String get needOneReadRelay =>
      'Wymagany jest co najmniej jeden relay do odczytu.';

  @override
  String get listSavedLocally =>
      'Lista zapisana na tym urządzeniu, nieopublikowana.';

  @override
  String get noRelayAcceptedList =>
      'Żaden relay nie przyjął listy: spróbujemy później.';

  @override
  String relayListPublishedTo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Lista Relay opublikowana na $count relays',
      one: 'Lista Relay opublikowana na 1 relay',
    );
    return '$_temp0';
  }

  @override
  String get mediaServersUpdated => 'Serwery mediów zaktualizowane';

  @override
  String get appearance => 'Wygląd';

  @override
  String get publishingSettings => 'Publikowanie';

  @override
  String get addMialunaHashtag => 'Dodaj #mialuna';

  @override
  String get addMialunaHashtagNote =>
      'Dodawaj oficjalny hashtag do publicznych wpisów i relacji. Możesz to wyłączyć w każdej chwili.';

  @override
  String get themeLight => 'Jasny';

  @override
  String get themeDark => 'Ciemny';

  @override
  String get themeSystem => 'System';

  @override
  String get relays => 'Relays';

  @override
  String get relaysExplainSignedOut =>
      'Relays przechowują i rozsyłają treści. Zaloguj się, aby automatycznie używać własnej listy (NIP-65).';

  @override
  String get relaysExplainSynced =>
      'Lista jest zsynchronizowana z twoim profilem Nostr (NIP-65): każda zmiana jest publikowana i działa we wszystkich twoich aplikacjach.';

  @override
  String get syncing => 'Synchronizowanie…';

  @override
  String get waitingFirstSync => 'Oczekiwanie na pierwszą synchronizację';

  @override
  String get syncNow => 'Synchronizuj teraz';

  @override
  String get addRelay => 'Dodaj relay';

  @override
  String get restoreDefaultRelays => 'Przywróć domyślne relays';

  @override
  String get createYourList => 'Utwórz swoją listę';

  @override
  String peopleCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count osób',
      one: '1 osoba',
    );
    return '$_temp0';
  }

  @override
  String get closeFriendsSettingsNote =>
      'Wpisy, relacje i wideo widoczne tylko dla nich, z zaszyfrowanymi zdjęciami i wideo.';

  @override
  String get mediaServersBlossom => 'Serwery mediów (Blossom)';

  @override
  String get mediaServersExplain =>
      'Zdjęcia i wideo są przesyłane tylko na te serwery, w podanej kolejności: wygrywa pierwszy, który je przyjmie. EXIF i lokalizacja są usuwane przed przesłaniem.';

  @override
  String get primary => 'Główny';

  @override
  String get makePrimary => 'Ustaw jako główny';

  @override
  String get remove => 'Usuń';

  @override
  String get addServer => 'Dodaj serwer';

  @override
  String get moderation => 'Moderacja';

  @override
  String get moderationExplain =>
      'Wyciszeni autorzy i ukryte hashtagi są synchronizowane przez NIP-51. Zablokowani autorzy zostają tylko na tym urządzeniu.';

  @override
  String get mutedAuthors => 'Wyciszeni autorzy';

  @override
  String get noMutedAuthors => 'Brak wyciszonych autorów';

  @override
  String get blockedAuthors => 'Zablokowani autorzy';

  @override
  String get noBlockedAuthors => 'Brak zablokowanych autorów';

  @override
  String get hiddenHashtags => 'Ukryte hashtagi';

  @override
  String get noHiddenHashtags => 'Brak ukrytych hashtagów';

  @override
  String get hashtagToHide => '#hashtag do ukrycia';

  @override
  String get storage => 'Pamięć';

  @override
  String get clearCache => 'Wyczyść pamięć zdarzeń i szkice';

  @override
  String get cacheCleared => 'Pamięć wyczyszczona';

  @override
  String get reviewIntro => 'Zobacz wprowadzenie ponownie';

  @override
  String get reviewIntroSubtitle =>
      'Co jest publiczne, co prywatne i jakie są granice bliskich znajomych.';

  @override
  String noLightningWalletCopied(Object address) {
    return 'Nie znaleziono portfela Lightning: adres skopiowany ($address)';
  }

  @override
  String get about => 'O aplikacji';

  @override
  String aboutText(Object version) {
    return 'Mialuna $version — Twoje momenty, pod tym samym księżycem.\nOpen source (MIT). github.com/Lwb89dev/mialuna';
  }

  @override
  String get invalidRelayAddress => 'Nieprawidłowy adres: użyj wss://…';

  @override
  String get invalidServerAddress => 'Nieprawidłowy adres: użyj https://…';

  @override
  String get relayRead => 'Odczyt';

  @override
  String get relayWrite => 'Zapis';

  @override
  String get support => 'Wsparcie';

  @override
  String get supportText =>
      'Mialuna jest darmowa, bez reklam i cię nie śledzi. Jeśli ci się podoba, możesz wysłać kilka sats przez Lightning Network.';

  @override
  String get donateWithLightning => 'Przekaż darowiznę przez Lightning';

  @override
  String get authorNoZaps => 'Ten autor nie przyjmuje zaps';

  @override
  String get sendZap => 'Wyślij zap ⚡';

  @override
  String get amountInSats => 'Kwota w sats';

  @override
  String minMaxSats(Object min, Object max) {
    return 'min $min – max $max';
  }

  @override
  String get zap => 'Zap';

  @override
  String get signInToZap => 'Zaloguj się, aby wysyłać zaps';

  @override
  String zapSent(Object sats) {
    return 'Zap $sats sats wysłany ⚡';
  }

  @override
  String nwcPaymentFailed(Object error) {
    return 'Płatność NWC nie powiodła się: $error';
  }

  @override
  String get noLightningWallet => 'Nie znaleziono portfela Lightning';

  @override
  String storiesRailLabel(Object state) {
    return 'Relacje, $state';
  }

  @override
  String get close => 'Zamknij';

  @override
  String hoursAgo(int hours) {
    return '$hours godz. temu';
  }

  @override
  String daysAgo(int days) {
    return '$days d temu';
  }

  @override
  String get now => 'teraz';

  @override
  String get youPrefix => 'Ty: ';

  @override
  String get storiesStateUnseen => 'nowe';

  @override
  String get storiesStateSeen => 'obejrzane';

  @override
  String weekdayShort(String day) {
    String _temp0 = intl.Intl.selectLogic(day, {
      'mon': 'pon',
      'tue': 'wt',
      'wed': 'śr',
      'thu': 'czw',
      'fri': 'pt',
      'sat': 'sob',
      'sun': 'nd',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get sharedAMoment => 'Udostępnił(a) moment';

  @override
  String get blossomOtherError => 'błąd';

  @override
  String get languageTitle => 'Język';

  @override
  String get languageSystem => 'System';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageItalian => 'Italiano';

  @override
  String get cannotEditPhoto => 'Tego zdjęcia nie da się tu edytować.';

  @override
  String notificationsNew(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count nowych powiadomień',
      one: '1 nowe powiadomienie',
    );
    return '$_temp0';
  }

  @override
  String messagesUnread(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count nieprzeczytanych wiadomości',
      one: '1 nieprzeczytana wiadomość',
    );
    return '$_temp0';
  }

  @override
  String get done => 'Gotowe';

  @override
  String get storyAddText => 'Dodaj tekst';

  @override
  String get storyEditText => 'Edytuj tekst';

  @override
  String get storyTextHint => 'Napisz coś… #hashtags można stuknąć';

  @override
  String get storyTextsHelp =>
      'Stuknij zdjęcie, aby pisać. Przeciągnij, aby przesunąć, uszczypnij, aby zmienić rozmiar i obrócić, stuknij tekst, aby go edytować.';

  @override
  String storyTextsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tekstów',
      one: '1 tekst',
      zero: 'Brak tekstu',
    );
    return '$_temp0';
  }

  @override
  String get storyFontClassic => 'Klasyczna';

  @override
  String get storyFontBold => 'Pogrubiona';

  @override
  String get storyFontSerif => 'Serif';

  @override
  String get storyFontMono => 'Mono';

  @override
  String get storyFontItalic => 'Kursywa';

  @override
  String get storyTextBackground => 'Tło tekstu';

  @override
  String get storyTextColor => 'Kolor tekstu';

  @override
  String storyTextLimit(int max) {
    return 'Możesz dodać do $max tekstów.';
  }

  @override
  String get wotTitle => 'Sieć zaufania';

  @override
  String get wotEnable => 'Sieć zaufania jest zawsze włączona';

  @override
  String wotExplain(int min) {
    return 'Zawsze włączona. Odkrywaj pokazuje tylko tę sieć: ty, osoby, które obserwujesz, i każdy, kogo obserwuje co najmniej $min z nich. Ta sama sieć ukrywa komentarze, powiadomienia, prywatne wpisy i wiadomości od wszystkich innych. Jest liczona na tym telefonie z publicznych list obserwowanych przy pierwszym otwarciu aplikacji; kolejne otwarcia z niej korzystają. Nic nie jest wysyłane na żaden serwer.';
  }

  @override
  String get wotRefresh => 'Odśwież sieć teraz';

  @override
  String get wotStatusIdle =>
      'Jeszcze nie zbudowana. Powstaje przy pierwszym otwarciu aplikacji.';

  @override
  String get wotBuildingTitle => 'Budowanie feedu Odkrywaj';

  @override
  String get wotBuildingBody =>
      'Odczyt, kogo obserwują osoby, które obserwujesz, i przygotowanie Odkrywaj.';

  @override
  String get wotDiscoverHint =>
      'Tylko twoja sieć zaufania: osoby, które obserwujesz, i osoby, które obserwuje ich wystarczająco wielu.';

  @override
  String get wotDiscoverSignIn =>
      'Odkrywaj pokazuje twoją sieć zaufania. Zaloguj się, a przy pierwszym razie Mialuna odczyta, kogo obserwujesz, i zbuduje ten feed. Kolejne otwarcia z niego korzystają.';

  @override
  String get wotDiscoverEmpty => 'Brak wpisów z twojej sieci zaufania.';

  @override
  String wotStatusDiscovering(int done, int total) {
    return 'Sprawdzanie, kogo obserwują obserwowani… $done z $total';
  }

  @override
  String wotStatusComplete(int direct, int indirect, Object when) {
    return 'Twoja sieć: $direct osób, które obserwujesz, plus $indirect obserwowanych przez wystarczająco wielu z nich. Zaktualizowano $when.';
  }

  @override
  String wotStatusFailed(Object reason) {
    return 'Nie udało się obliczyć twojej sieci: $reason';
  }

  @override
  String get wotNoFollows => 'nie obserwujesz jeszcze nikogo';

  @override
  String get messageRequests => 'Prośby o wiadomość';

  @override
  String messageRequestsSubtitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count rozmów spoza twojej sieci zaufania',
      one: '1 rozmowa spoza twojej sieci zaufania',
    );
    return '$_temp0';
  }

  @override
  String get messageRequestsHint =>
      'Od osób spoza twojej sieci zaufania. Nie liczą się jako nieprzeczytane. Odpowiedz, aby przenieść rozmowę do skrzynki.';

  @override
  String get storyViewsSetting => 'Pokazuj innym, że obejrzałem ich relacje';

  @override
  String get storyViewsSettingExplain =>
      'Gdy oglądasz relację, do autora idzie potwierdzenie, zaszyfrowane tak, że tylko on może je odczytać. Jest na nim twoje imię obok jego; relays nic nie widzą. Jeśli nie da się go dostarczyć, zostaje i jest ponawiane później. Wyłącz, aby oglądać bez informowania kogokolwiek: jeszcze niewysłane potwierdzenia są usuwane (już dostarczonego nie da się cofnąć).';

  @override
  String storySeenBy(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Widziane przez $count osób',
      one: 'Widziane przez 1 osobę',
      zero: 'Brak wyświetleń',
    );
    return '$_temp0';
  }

  @override
  String get storyViewsEmpty =>
      'Nikt jeszcze nie obejrzał tej relacji albo ich potwierdzenia do ciebie nie dotarły.';

  @override
  String get storyViewsHint =>
      'Potwierdzenie wysyłają tylko osoby, które na to pozwalają, więc prawdziwa liczba może być wyższa.';

  @override
  String get systemNotifications => 'Powiadomienia systemowe';

  @override
  String get systemNotificationsExplain =>
      'Pokaż powiadomienie na telefonie, gdy pojawi się coś nowego, a Mialuna jest w tle. Prywatne wiadomości nigdy nie pokazują treści, nawet na ekranie blokady. Android wstrzymuje aplikacje długo pozostające w tle, więc powiadomienia docierają, dopóki Mialuna jeszcze działa.';

  @override
  String get systemNotificationsBlocked =>
      'Powiadomienia dla Mialuna są wyłączone w ustawieniach telefonu.';

  @override
  String get systemNotificationsOpenSettings => 'Otwórz ustawienia';

  @override
  String get systemNotificationsBattery =>
      'Android usypia aplikacje kilka minut po wyłączeniu ekranu i powiadomienia przestają przychodzić. Aby je nadal dostawać, ustaw zużycie baterii Mialuna na “Bez ograniczeń”.';

  @override
  String get systemNotificationsBatteryAction => 'Otwórz ustawienia baterii';

  @override
  String get newFollowersSetting => 'Pokazuj nowych obserwujących';

  @override
  String get newFollowersSettingExplain =>
      'Nowi obserwujący pojawiają się w Powiadomieniach i na telefonie. Wyłącz to, jeśli ludzie zalewają cię obserwacjami: polubienia, komentarze i zaps zostają.';

  @override
  String get systemNotificationMessage => 'wysłał(a) ci prywatną wiadomość';

  @override
  String get systemNotificationNewMessage => 'Nowa prywatna wiadomość';

  @override
  String get systemNotificationNew => 'Nowe powiadomienie';

  @override
  String get notificationChannelSocial =>
      'Reakcje, komentarze, zaps i obserwujący';

  @override
  String get notificationChannelMessages => 'Prywatne wiadomości';

  @override
  String get zapInvoiceMismatch =>
      'Faktura nie zgadza się z wybraną kwotą. Nic nie zostało zapłacone.';

  @override
  String get storyYourStory => 'Twoja relacja';

  @override
  String get storyNew => 'Nowa relacja';

  @override
  String get storyAddSemantics => 'Dodaj do swojej relacji';

  @override
  String storyOwnRailLabel(int count, Object state) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count relacji',
      one: '1 relacja',
    );
    return 'Twoja relacja, $_temp0, $state';
  }

  @override
  String get storyTextSize => 'Rozmiar tekstu';

  @override
  String get storyPickPrompt => 'Wybierz zdjęcie lub wideo do swojej relacji';

  @override
  String get storyEditPhoto => 'Edytuj zdjęcie';

  @override
  String get storyCaption => 'Podpis';

  @override
  String get storyDiscardTitle => 'Odrzucić tę relację?';

  @override
  String get storyDiscard => 'Odrzuć';

  @override
  String get storyShare => 'Udostępnij';

  @override
  String get storyShared => 'Relacja udostępniona';

  @override
  String get deletePost => 'Usuń';

  @override
  String get deletePostTitle => 'Usunąć ten wpis?';

  @override
  String get deleteStoryTitle => 'Usunąć tę relację?';

  @override
  String get deletePostBody =>
      'Mialuna poprosi twoje relays o usunięcie go i serwery mediów o usunięcie zdjęć lub wideo. Relay, który zignoruje prośbę, albo ktoś, kto już zapisał kopię, może je nadal mieć.';

  @override
  String get deletePrivateBody =>
      'Wpisu dla bliskich znajomych nie da się wycofać z relays. Mialuna powie aplikacjom znajomych, aby go usunęły, i poprosi serwer mediów o usunięcie zaszyfrowanych plików. Znajomy, który już zapisał kopię, może ją nadal mieć.';

  @override
  String get deletingPost => 'Usuwanie…';

  @override
  String get postDeleted => 'Usunięto.';

  @override
  String get postWasDeleted => 'Ten wpis został usunięty.';

  @override
  String get deleteNotAllowed =>
      'Usunąć może tylko konto, które to opublikowało.';

  @override
  String deleteFailed(Object reason) {
    return 'Nie udało się usunąć: $reason';
  }

  @override
  String get deleteNoRelay =>
      'Żaden relay nie przyjął prośby o usunięcie, więc wpis jest nadal online. Sprawdź połączenie i spróbuj ponownie.';

  @override
  String deleteMediaLeft(Object servers) {
    return 'Nie udało się usunąć mediów z $servers.';
  }

  @override
  String get deleteMediaNotAuthorized =>
      'Twój signer nie zezwolił na usunięcie mediów, więc pliki nadal są na serwerze mediów.';

  @override
  String deleteFriendsMissed(Object count) {
    return '$count twoich bliskich znajomych nie udało się powiadomić, więc wpis może zostać na ich telefonach.';
  }

  @override
  String get storyCleanupSetting => 'Usuwaj moje relacje, gdy wygasną';

  @override
  String get storyCleanupSettingExplain =>
      'Po 24 godzinach Mialuna prosi twoje relays i serwery mediów o usunięcie twoich relacji, wraz ze zdjęciami i wideo. Serwer, który zignoruje prośbę, albo ktoś, kto zachował kopię, może je nadal mieć.';

  @override
  String storyCleanupWaiting(Object count) {
    return 'Twój signer musi zatwierdzić każde czyszczenie, więc czeka, aż poprosisz. Wygasłe relacje w kolejce: $count.';
  }

  @override
  String get storyCleanupNow => 'Usuń teraz';

  @override
  String get storyCleanupDone => 'Wygasłe relacje usunięte.';

  @override
  String get storyCleanupPartly =>
      'Niektórych nie udało się jeszcze usunąć; Mialuna spróbuje ponownie.';

  @override
  String get editorPro => 'Edytor Pro';

  @override
  String get editorModeBasic => 'Podstawowy';

  @override
  String get editorModePro => 'Pro';

  @override
  String get toolCrop => 'Kadruj';

  @override
  String get toolLight => 'Światło';

  @override
  String get toolColor => 'Kolor';

  @override
  String get toolHsl => 'HSL';

  @override
  String get toolCurves => 'Krzywe';

  @override
  String get toolEffects => 'Efekty';

  @override
  String get straighten => 'Prostowanie';

  @override
  String get exposure => 'Ekspozycja';

  @override
  String get highlights => 'Światła';

  @override
  String get shadows => 'Cienie';

  @override
  String get whites => 'Biele';

  @override
  String get blacks => 'Czernie';

  @override
  String get temperature => 'Temperatura';

  @override
  String get tint => 'Odcień';

  @override
  String get vibrance => 'Jaskrawość';

  @override
  String get hue => 'Barwa';

  @override
  String get luminance => 'Luminancja';

  @override
  String get colorRed => 'Czerwony';

  @override
  String get colorOrange => 'Pomarańczowy';

  @override
  String get colorYellow => 'Żółty';

  @override
  String get colorGreen => 'Zielony';

  @override
  String get colorAqua => 'Akwamaryna';

  @override
  String get colorBlue => 'Niebieski';

  @override
  String get colorPurple => 'Fioletowy';

  @override
  String get colorMagenta => 'Purpurowy';

  @override
  String get curveHint =>
      'Przeciągnij punkt, aby kształtować krzywą, dotknij, aby dodać, dotknij dwukrotnie, aby usunąć.';

  @override
  String get sharpen => 'Wyostrzanie';

  @override
  String get vignette => 'Winieta';

  @override
  String get grain => 'Ziarno';

  @override
  String get holdForOriginal =>
      'Przytrzymaj zdjęcie, aby porównać je z oryginałem.';

  @override
  String get showingOriginal => 'Oryginał';

  @override
  String get applyLookToAll => 'Zastosuj ten wygląd do wszystkich zdjęć';

  @override
  String get applyingEdits => 'Przetwarzanie zdjęć…';

  @override
  String get choosePhotoToEdit => 'Wybierz zdjęcie do edycji';
}
