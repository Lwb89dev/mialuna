// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Bulgarian (`bg`).
class AppLocalizationsBg extends AppLocalizations {
  AppLocalizationsBg([String locale = 'bg']) : super(locale);

  @override
  String get syncUpToDate => 'Актуално';

  @override
  String get syncFailed => 'Синхронът не успя';

  @override
  String get relaysUpdatedFromProfile =>
      'Relays са обновени от профила ти (NIP-65)';

  @override
  String get relayListPublished => 'Relay списъкът е публикуван';

  @override
  String get mediaServersUpdatedFromProfile =>
      'Медийните сървъри са обновени от профила ти';

  @override
  String get tabHome => 'Home';

  @override
  String get tabDiscover => 'Открий';

  @override
  String get tabCreate => 'Създай';

  @override
  String get tabReels => 'Reels';

  @override
  String get tabProfile => 'Профил';

  @override
  String get signInToUploadMedia => 'Влез, за да качиш медия.';

  @override
  String get noMediaServer =>
      'Няма настроен медиен сървър. Добави го в Настройки.';

  @override
  String serverNoResponse(Object server) {
    return '$server: няма отговор';
  }

  @override
  String serverUnreachable(Object server, Object error) {
    return '$server: недостъпен ($error)';
  }

  @override
  String uploadRejected(Object reason) {
    return 'Качването е отказано — $reason';
  }

  @override
  String noServerAcceptedFile(Object reasons) {
    return 'Никой сървър не прие файла — $reasons';
  }

  @override
  String get blossomInvalidResponse => 'невалиден отговор';

  @override
  String get blossomInvalidFileUrl => 'невалиден адрес на файла';

  @override
  String get blossomServerAlteredFile => 'сървърът е променил файла';

  @override
  String get blossomBadRequest => 'невалидна заявка';

  @override
  String get blossomUnauthorized => 'отказано упълномощаване';

  @override
  String get blossomPaymentRequired => 'изисква се плащане';

  @override
  String get blossomForbidden => 'не е позволено';

  @override
  String get blossomLengthRequired => 'липсва размер';

  @override
  String get blossomTooLarge => 'файлът е твърде голям';

  @override
  String get blossomUnsupportedType => 'форматът не се приема';

  @override
  String get blossomTooManyRequests => 'твърде много заявки';

  @override
  String get blossomServerError => 'грешка на сървъра';

  @override
  String get cipherInvalidKey => 'Невалиден ключ';

  @override
  String get cipherTruncated => 'Криптираният файл е непълен';

  @override
  String get cipherMismatch =>
      'Файлът не съвпада с ключа: променен или повреден';

  @override
  String get sanitizeHeifNeedsAsync =>
      'Формат HEIC/AVIF: преобразуването изисква sanitizeAsync';

  @override
  String get sanitizeWebmUnsupported =>
      'Видео WebM/MKV не се поддържа: използвай MP4 или MOV, за да се махнат метаданните преди качване.';

  @override
  String get sanitizeUnknownFormat =>
      'Непознат формат: снимки JPEG/PNG/WebP/GIF или видеа MP4/MOV.';

  @override
  String sanitizeLeftovers(Object items) {
    return 'Не се махнаха всички метаданни ($items): файлът не е качен.';
  }

  @override
  String sanitizeProcessingFailed(Object error) {
    return 'Файлът не можа да се обработи: $error';
  }

  @override
  String get sanitizeJpegInvalid => 'Невалиден JPEG';

  @override
  String get sanitizeJpegTruncated => 'Непълен JPEG';

  @override
  String get sanitizeJpegNoSize => 'JPEG без размери';

  @override
  String get sanitizeJpegUndecodable => 'JPEG не може да се декодира';

  @override
  String get sanitizePngTruncated => 'Непълен PNG';

  @override
  String get sanitizePngInvalid => 'Невалиден PNG';

  @override
  String get sanitizeGifInvalid => 'Невалиден GIF';

  @override
  String get sanitizeGifTruncated => 'Непълен GIF';

  @override
  String get sanitizeWebpTruncated => 'Непълен WebP';

  @override
  String get sanitizeWebpInvalid => 'Невалиден WebP';

  @override
  String get sanitizeMp4Invalid => 'Невалидно видео MP4/MOV';

  @override
  String get sanitizeConversionFailed => 'Преобразуването не успя';

  @override
  String get sanitizeHeifUnsupported =>
      'Този формат (HEIC/AVIF) не може да се преобразува на това устройство. Избери снимка JPEG или PNG.';

  @override
  String get privateMediaNotEncrypted => 'Медията не е криптирана';

  @override
  String serverReplied(Object status) {
    return 'Сървърът отговори $status';
  }

  @override
  String get fileTooLarge => 'Файлът е твърде голям';

  @override
  String get serverFileNotOriginal => 'Файлът на сървъра не е оригиналният';

  @override
  String get contentMismatch => 'Съдържанието не съвпада';

  @override
  String get mediaUnreachable => 'Медията е недостъпна';

  @override
  String get amberInvalidKey => 'Amber върна невалиден ключ';

  @override
  String get amberNoKey => 'Amber не върна ключ';

  @override
  String get amberRequestRejected => 'Заявката е отказана в Amber';

  @override
  String get amberAndroidOnly => 'Amber е наличен само за Android';

  @override
  String get amberEmptySignature => 'Amber върна празен подпис';

  @override
  String get amberSignRejected => 'Подписът е отказан в Amber';

  @override
  String get amberTimeout => 'Amber не отговори навреме';

  @override
  String get amberEmptyResponse => 'Amber върна празен отговор';

  @override
  String get bunkerInvalidUrl => 'Невалиден bunker URL';

  @override
  String get bunkerNoRelay => 'bunker не посочва нито един relay';

  @override
  String get bunkerWebAuth =>
      'bunker изисква уеб упълномощаване (auth_url не се поддържа)';

  @override
  String get bunkerInvalidKey => 'bunker не върна валиден ключ';

  @override
  String get signerInvalidResponse =>
      'Подписващият върна невалидно подписано събитие';

  @override
  String get bunkerTimeout => 'Времето на bunker изтече';

  @override
  String get nwcInvalidUri => 'Невалиден NWC URI';

  @override
  String get nwcNoRelay => 'NWC URI не посочва нито един relay';

  @override
  String get nwcNoSecret => 'NWC URI не съдържа валидна тайна';

  @override
  String get nwcTimeout => 'Портфейлът не отговори навреме';

  @override
  String get signerNoPrivateMessages =>
      'Този начин на вход не поддържа лични съобщения';

  @override
  String get zapNotSupported => 'Този адрес не поддържа Nostr zap';

  @override
  String zapAmountOutOfRange(Object min, Object max) {
    return 'Сумата е извън обхвата ($min–$max sats)';
  }

  @override
  String get commentNotSent => 'Коментарът не е изпратен. Опитай по-късно.';

  @override
  String get comments => 'Коментари';

  @override
  String get noCommentsYet => 'Още няма коментари.';

  @override
  String get signInToComment => 'Влез, за да коментираш.';

  @override
  String get addComment => 'Добави коментар…';

  @override
  String get signInToPublish => 'Влез, за да публикуваш.';

  @override
  String get addMediaFirst =>
      'Добави поне една снимка или видео преди публикуване.';

  @override
  String get removingMetadata => 'Махам метаданните…';

  @override
  String uploadingProgress(Object current, Object total) {
    return 'Качвам $current от $total…';
  }

  @override
  String get creatingPreview => 'Създавам прегледа…';

  @override
  String uploadFailed(Object error) {
    return 'Качването не успя: $error';
  }

  @override
  String get publishing => 'Публикувам…';

  @override
  String noRelayAcceptedPost(Object reason) {
    return 'Нито един relay$reason не прие публикацията. Съдържанието остава в черновите ти.';
  }

  @override
  String get privateNeedsKeySigner =>
      'Този начин на вход не поддържа лично съдържание. Използвай Amber, bunker или локалния ключ.';

  @override
  String get closeFriendsListEmptyAddSomeone =>
      'Списъкът ти с близки приятели е празен: добави някого.';

  @override
  String get fileOver100Mb =>
      'Файлът е над 100 MB: това е лимитът за близки приятели (криптира се цял на телефона ти).';

  @override
  String get encryptingOnPhone => 'Криптирам на телефона ти…';

  @override
  String noServerAcceptedEncrypted(Object details) {
    return 'Нито един от медийните ти сървъри не прие криптирания файл. Не се публикува в явен вид. Добави в Настройки сървър, който приема криптирани файлове (например cdn.hzrd149.com). $details';
  }

  @override
  String get sendingToFriends => 'Изпращам на приятели…';

  @override
  String sendingToFriendsProgress(Object done, Object total) {
    return 'Изпращам на приятели $done/$total…';
  }

  @override
  String noFriendReceivedPost(Object reason) {
    return 'Нито един приятел не получи post$reason. Съдържанието остава в черновите ти.';
  }

  @override
  String sentToCloseFriends(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Изпратено до $count близки приятели 🔒',
      one: 'Изпратено до 1 близък приятел 🔒',
    );
    return '$_temp0';
  }

  @override
  String sentToFriendsWithMisses(int delivered, Object missed) {
    String _temp0 = intl.Intl.pluralLogic(
      delivered,
      locale: localeName,
      other: 'Изпратено до $delivered приятели.',
      one: 'Изпратено до 1 приятел.',
    );
    return '$_temp0 $missed не го получи (личните съобщения са изключени).';
  }

  @override
  String get altText => 'Alt текст';

  @override
  String get altTextHint => 'Опиши съдържанието за хора, които не го виждат…';

  @override
  String get cancel => 'Отказ';

  @override
  String get save => 'Запази';

  @override
  String get momentPublished => 'Моментът е публикуван ✨';

  @override
  String get newMoment => 'Нов момент';

  @override
  String get publish => 'Публикувай';

  @override
  String get guestMode => 'Режим Гост';

  @override
  String get signInToPostMoments => 'Влез, за да публикуваш моментите си.';

  @override
  String get signIn => 'Вход';

  @override
  String get kindPhoto => 'Снимка';

  @override
  String get kindVideo => 'Видео';

  @override
  String get kindReel => 'Reel';

  @override
  String get kindStory => 'История';

  @override
  String get storyExpiryNote =>
      'Историите изтичат след 24 часа при relay, които спазват NIP-40, но други пак могат да ги запазят или архивират.';

  @override
  String get fromGallery => 'От галерията';

  @override
  String get galleryLongPressVideo => 'Галерия (задръж за видео)';

  @override
  String get addVideo => 'Добави видео';

  @override
  String get camera => 'Камера';

  @override
  String get exifRemovedNote =>
      'Метаданните за местоположение (EXIF) се махат автоматично.';

  @override
  String get writeCaption => 'Напиши описание…';

  @override
  String get privatePostNote =>
      'Лична публикация: без публични хаштагове, не се намира чрез търсене.';

  @override
  String willPublishAs(Object caption) {
    return 'Ще се публикува като: \"$caption\"';
  }

  @override
  String get tapThumbnailForAlt =>
      'Докосни миниатюра, за да добавиш alt текст.';

  @override
  String get sensitiveContent => 'Чувствително съдържание';

  @override
  String get sensitiveContentNote =>
      'Публикацията ще е скрита зад предупреждение (NIP-36).';

  @override
  String get uploadingMedia => 'Качвам медия…';

  @override
  String get audiencePublic => 'Публично';

  @override
  String get closeFriends => 'Близки приятели';

  @override
  String get signerCannotPublishCloseFriends =>
      'С този начин на вход не можеш да публикуваш за близки приятели: използвай Amber, bunker или локалния ключ.';

  @override
  String get closeFriendsEmptyPrompt =>
      'Списъкът ти е празен: добави хората, които могат да видят тази публикация.';

  @override
  String onlyYourCloseFriendsSee(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Само твоите $count близки приятели ще видят това. Снимките и видеата се криптират на телефона ти преди качване.',
      one: 'Само 1 твой близък приятел ще види това. Снимките и видеата се криптират на телефона ти преди качване.',
    );
    return '$_temp0';
  }

  @override
  String get addFriends => 'Добави приятели';

  @override
  String get manageList => 'Управлявай списъка';

  @override
  String get edit => 'Редактирай';

  @override
  String get reset => 'Нулирай';

  @override
  String get apply => 'Приложи';

  @override
  String get cropFree => 'Свободно';

  @override
  String get cropOriginal => 'Оригинал';

  @override
  String get rotate => 'Завърти';

  @override
  String get flip => 'Обърни';

  @override
  String get brightness => 'Яркост';

  @override
  String get contrast => 'Контраст';

  @override
  String get saturation => 'Наситеност';

  @override
  String postsByAuthor(Object author) {
    return 'Публикации от $author…';
  }

  @override
  String get searchHint => 'Търси хора, хаштагове или думи…';

  @override
  String get clear => 'Изчисти';

  @override
  String get recent => 'Скорошни';

  @override
  String get searchDependsOnRelays =>
      'Търсенето зависи от настроените relay: резултатите може да са частични.';

  @override
  String get recentPostsEverywhere =>
      'Скорошни публикации от цялата мрежа, включително хора, които не следваш.';

  @override
  String get noResultsOnRelays => 'Няма резултати при настроените relay.';

  @override
  String get noRecentPostsFromFollowed =>
      'Няма скорошни публикации от хората, които следваш.';

  @override
  String get noMomentsFound =>
      'Няма намерени моменти по relay. Провери връзката.';

  @override
  String get loadFailed => 'Зареждането не успя';

  @override
  String get notifications => 'Известия';

  @override
  String get messages => 'Съобщения';

  @override
  String get homeEmptyFollowsNobody =>
      'Тук са публикациите от хората, които следваш.\nОще не следваш никого: открий интересни хора и профили.';

  @override
  String get discoverPeople => 'Открий хора';

  @override
  String get homeEmpty =>
      'Още няма моменти.\nДръпни надолу за опресняване или публикувай първия си кадър.';

  @override
  String get retry => 'Опитай пак';

  @override
  String get seenEverything => 'Това е всичко засега ✨';

  @override
  String get discoverMoreProfiles => 'Открий още профили';

  @override
  String get feedFollowing => 'Следване';

  @override
  String get signInToSeeFollowed =>
      'Влез, за да виждаш публикации от хората, които следваш';

  @override
  String get videoPreview => 'Преглед на видео';

  @override
  String get cannotOpenPrivateVideo => 'Личното видео не се отваря';

  @override
  String get cannotPlayVideo => 'Видеото не може да се пусне';

  @override
  String get pauseVideo => 'Пауза на видеото';

  @override
  String get playVideo => 'Пусни видеото';

  @override
  String errorTapToRetry(Object error) {
    return '$error — докосни за нов опит';
  }

  @override
  String get soundOn => 'Включи звука';

  @override
  String get soundOff => 'Изключи звука';

  @override
  String get postImage => 'Изображение на публикацията';

  @override
  String get imageUnavailable => 'Изображението липсва';

  @override
  String errorTapToRetryNewline(Object message) {
    return '$message\nДокосни за нов опит';
  }

  @override
  String get cannotOpenPrivateContent => 'Това лично съдържание не се отваря';

  @override
  String get privateImage => 'Лично изображение';

  @override
  String get invalidImage => 'Невалидно изображение';

  @override
  String get more => 'Още';

  @override
  String get removeFromSaved => 'Махни от запазените';

  @override
  String get copyLink => 'Копирай връзката';

  @override
  String get muteAuthor => 'Заглуши автора';

  @override
  String get blockAuthor => 'Блокирай автора';

  @override
  String get report => 'Докладвай';

  @override
  String get like => 'Харесай';

  @override
  String get sendInMessage => 'Изпрати в съобщение';

  @override
  String get zapOptional => 'Zap (по избор)';

  @override
  String get closeFriendsOnlyNote =>
      'Видимо само за близки приятели. Харесванията и отговорите отиват само при автора.';

  @override
  String get likeFailed => 'Харесването не бе изпратено';

  @override
  String get nostrLinkCopied => 'Nostr връзката е копирана';

  @override
  String get authorMuted => 'Авторът е заглушен';

  @override
  String get authorBlocked => 'Авторът е блокиран';

  @override
  String get reportSent => 'Докладът е изпратен (NIP-56)';

  @override
  String get signInToReport => 'Влез, за да докладваш';

  @override
  String minutesAgo(Object minutes) {
    return 'преди $minutes мин';
  }

  @override
  String get show => 'Покажи';

  @override
  String get chatEmptyHint =>
      'Напиши първото съобщение.\nКриптирано е: никой друг не го вижда.';

  @override
  String get messageHint => 'Съобщение…';

  @override
  String get send => 'Изпрати';

  @override
  String get notSentSuffix => ' не е изпратено';

  @override
  String get contentUnavailable =>
      'Съдържанието липсва (изтекло или не е намерено по relay)';

  @override
  String get signInToSendPrivateMessages =>
      'Влез, за да пращаш лични съобщения.';

  @override
  String get cannotMessageYourself => 'Не можеш да пишеш на себе си.';

  @override
  String get recipientNoPrivateMessages =>
      'Този човек още не е включил личните съобщения.';

  @override
  String noRecipientRelayAccepted(Object reason) {
    return 'Нито един relay$reason на получателя не прие съобщението.';
  }

  @override
  String sendFailed(Object error) {
    return 'Изпращането не успя: $error';
  }

  @override
  String get signInToReadMessages =>
      'Влез, за да четеш и пращаш лични съобщения.';

  @override
  String get signerNoPrivateMessagesLong =>
      'Личните съобщения не работят с този начин на вход. Влез с Amber, bunker или локалния ключ.';

  @override
  String get inboxEmpty =>
      'Няма разговори.\nДокосни молива, за да пишеш някому, или препрати момент с иконата ✈ под всяка публикация.';

  @override
  String get newMessage => 'Ново съобщение';

  @override
  String get privateMessagesEnabled => 'Личните съобщения са включени';

  @override
  String get enableMessagesFailed => 'Не успяха да се включат. Опитай пак.';

  @override
  String get enablePrivateMessages => 'Включи личните съобщения';

  @override
  String enablePrivateMessagesExplain(Object count) {
    return 'За да получаваш съобщения, посочи на кои relay да пристигат. Публикува се малък списък (NIP-17) с $count relay по подразбиране: можеш да го промениш после. Съобщенията остават криптирани: relay не виждат нито кой пише, нито текста.';
  }

  @override
  String get turnOn => 'Включи';

  @override
  String get searchByNameOrUsername => 'Търси по име или потребител';

  @override
  String get searching => 'Търсене…';

  @override
  String get noOneWithNameHint =>
      'Никой с това име. Опитай с по-малко букви или адрес като name@domain.com.';

  @override
  String get sent => 'Изпратено';

  @override
  String sentToPeople(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Изпратено до $count души',
      one: 'Изпратено до 1 човек',
    );
    return '$_temp0';
  }

  @override
  String sentToPeopleWithFailure(int count, Object failure) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Изпратено до $count души. $failure',
      one: 'Изпратено до 1 човек. $failure',
    );
    return '$_temp0';
  }

  @override
  String get signerNoPrivateMessagesShort =>
      'Не можеш да ползваш лични съобщения с този начин на вход.';

  @override
  String get followToStartOrSearch =>
      'Последвай някого, за да започнеш, или търси по име.';

  @override
  String get addMessage => 'Добави съобщение…';

  @override
  String sendWithCount(Object count) {
    return 'Изпрати ($count)';
  }

  @override
  String get linkCopied => 'Връзката е копирана';

  @override
  String get noNotifications => 'Няма известия в момента.';

  @override
  String get notificationsDependOnRelays =>
      'Известията зависят от relay: може да са непълни.';

  @override
  String get reactedToYourMoment => 'реагира на момента ти';

  @override
  String commentedText(Object text) {
    return 'коментира: $text';
  }

  @override
  String sentYouSats(Object sats, Object comment) {
    return 'ти изпрати $sats sats$comment';
  }

  @override
  String get sentYouZap => 'ти изпрати zap';

  @override
  String get startedFollowingYou => 'започна да те следва';

  @override
  String get amberNotFound => 'Amber не е намерен';

  @override
  String get amberExplain =>
      'Amber е Nostr подписвач, който държи личния ти ключ извън Mialuna. Инсталирай го и опитай пак.';

  @override
  String get downloadFromFdroid => 'Изтегли от F-Droid';

  @override
  String get continueWithAmber => 'Продължи с Amber';

  @override
  String get amberRecommended =>
      'Препоръчано: личният ти ключ остава на сигурно в Amber.';

  @override
  String get amberNotDetected =>
      'Amber не е открит: инсталирай го за препоръчания вход.';

  @override
  String get exploreWithoutAccount => 'Разгледай без профил';

  @override
  String get remoteBunker => 'Отдалечен bunker (NIP-46)';

  @override
  String get invalidBunkerUrlDot => 'Невалиден bunker URL.';

  @override
  String get connectBunker => 'Свържи bunker';

  @override
  String get advancedNsec => 'Разширен вход (nsec)';

  @override
  String get nsecWarning =>
      'Внимание: поставянето на личния ти ключ е рисковано. Не го споделяй с никого. На Android предпочитай Amber.';

  @override
  String get invalidNsec => 'Невалиден nsec ключ.';

  @override
  String get signInWithNsec => 'Вход с nsec';

  @override
  String get tagline => 'Твоите моменти, под същата луна.';

  @override
  String get skip => 'Пропусни';

  @override
  String get permissionsAndWallet => 'Разрешения и портфейл';

  @override
  String get permissionsExplain =>
      'Позволяват само да публикуваш и да получаваш известия. Можеш да ги промениш по всяко време в системните настройки.';

  @override
  String get photosAndVideos => 'Снимки и видеа';

  @override
  String get toUploadYourMoments => 'За да качваш моментите си';

  @override
  String get allow => 'Разреши';

  @override
  String get reactionsCommentsZaps => 'Реакции, коментари и zap';

  @override
  String get lightningWalletOptional => 'Lightning портфейл (по избор)';

  @override
  String get nwcExplain =>
      'Свържи портфейл Nostr Wallet Connect, за да пращаш zap, без да излизаш от приложението.';

  @override
  String get walletConnected => 'Портфейлът е свързан';

  @override
  String get disconnect => 'Прекъсни';

  @override
  String get connectWallet => 'Свържи портфейл';

  @override
  String get getStarted => 'Започни';

  @override
  String get welcome1 =>
      'Mialuna е визуална социална мрежа: снимки, видеа, Reels и истории — никога публикации само с текст.';

  @override
  String get welcome2 =>
      'Работи върху Nostr, отворен протокол: самоличността ти е ключ, който притежаваш, а не профил, който фирма може да ти вземе. Без реклами, без тракери, без централни сървъри.';

  @override
  String get welcome3 =>
      'Сподели светлината си с хора навсякъде, от всяко приложение, което говори същия отворен език.';

  @override
  String onboardingWot(int min) {
    return 'Твоята мрежа на доверие е винаги включена. Първия път, когато отвориш Mialuna, тя чете кого следваш и изгражда емисията Открий от тази мрежа: ти, хората, които следваш, и всеки, когото следват поне $min от тях. Следващите пъти емисията вече е готова.';
  }

  @override
  String get publicAndPrivate => 'Публично и лично';

  @override
  String get publicAndPrivateIntro =>
      'Mialuna е върху Nostr, отворена мрежа. Публикуваното е публично: публикации, снимки и видеа остават видими за всеки с връзката, дори извън Mialuna.';

  @override
  String get closeFriendsExplain1 =>
      'Само хората в този списък получават твоите публикации, истории и видеа „Близки приятели“. Списъкът е вътре в публикацията; не го избираш всеки път.';

  @override
  String get closeFriendsExplain2 =>
      'Снимките и видеата се криптират на телефона ти преди качване. Файловите сървъри (Blossom) сами не криптират нищо: затова Mialuna го прави, а сървърът вижда само нечетими данни. Който намери адреса на файла, не може да го отвори.';

  @override
  String get closeFriendsExplain3 =>
      'Не е абсолютна гаранция: който получи публикация, може да снима екрана, а махането на приятел важи само за бъдещи публикации.';

  @override
  String get closeFriendsExplain4 =>
      'Всеки приятел трябва да ползва Mialuna с включени лични съобщения. Други Nostr клиенти не показват тези публикации.';

  @override
  String get closeFriendsExplain5 =>
      'Публичните публикации остават публични: файловете им се виждат от всеки с връзката.';

  @override
  String get closeFriendsExplain6 =>
      'Ако никой твой сървър не приема криптирани файлове, публикацията не се публикува: никога в явен вид.';

  @override
  String get addToCloseFriends => 'Добави в близки приятели';

  @override
  String maxFriendsReached(Object max, Object added) {
    return 'Лимит от $max приятели: добавени са $added.';
  }

  @override
  String get add => 'Добави';

  @override
  String get signInToCreateList => 'Влез, за да създадеш списъка си.';

  @override
  String get signerNoCloseFriends =>
      'Близките приятели не работят с този начин на вход. Влез с Amber, bunker или локалния ключ.';

  @override
  String peopleOfMax(Object count, Object max) {
    return '$count / $max души';
  }

  @override
  String get noOneYet => 'Още няма никого.';

  @override
  String get addPeople => 'Добави хора';

  @override
  String get friendNoPrivateMessagesWarning =>
      'Не са включили лични съобщения: няма да получават публикациите ти';

  @override
  String get removeFromList => 'Махни от списъка';

  @override
  String get noOneWithThisName => 'Никой с това име.';

  @override
  String get signInToSendPrivateContent =>
      'Влез, за да пращаш лично съдържание.';

  @override
  String get reasonNoPrivateMessages => 'няма включени лични съобщения';

  @override
  String get reasonNoRelayAnswered => 'нито един relay не отговори';

  @override
  String get profileUpdated => 'Профилът е обновен';

  @override
  String get noRelayAcceptedRetry =>
      'Нито един relay не го прие. Опитай по-късно.';

  @override
  String get editProfile => 'Редактирай профила';

  @override
  String get fieldName => 'Име';

  @override
  String get fieldBio => 'Био';

  @override
  String get fieldAvatarUrl => 'URL на аватар';

  @override
  String get fieldNip05 => 'NIP-05 (напр. you@example.com)';

  @override
  String get browsingAsGuest => 'Разглеждаш като гост';

  @override
  String get signInToInteract =>
      'Влез, за да публикуваш, последваш и взаимодействаш.';

  @override
  String get settings => 'Настройки';

  @override
  String get signOut => 'Изход';

  @override
  String get npubCopied => 'npub е копиран';

  @override
  String get copyNpub => 'Копирай npub';

  @override
  String get mute => 'Заглуши';

  @override
  String get block => 'Блокирай';

  @override
  String get posts => 'Публикации';

  @override
  String get saved => 'Запазени';

  @override
  String get nothingPublishedYet => 'Още нямаш публикации.';

  @override
  String get noPostsOnRelays => 'Няма намерени публикации по relay.';

  @override
  String get noReelsPublished => 'Няма публикувани reels.';

  @override
  String get noReelsOnRelays => 'Няма намерени reels по relay.';

  @override
  String get noSavedPosts => 'Няма запазени публикации.';

  @override
  String get followingButton => 'Следваш';

  @override
  String get follow => 'Последвай';

  @override
  String get messageButton => 'Съобщение';

  @override
  String get loginLocalKey => 'Локален ключ';

  @override
  String get loginGuest => 'Гост';

  @override
  String get followUpdateFailed =>
      'Следванията не се обновиха сега. Опитай пак.';

  @override
  String get noReelsComeBack =>
      'Няма намерени reels по relay.\nВърни се скоро!';

  @override
  String get followUpdateFailedShort => 'Следванията не се обновиха сега';

  @override
  String get needOneReadRelay => 'Нужен е поне един relay за четене.';

  @override
  String get listSavedLocally =>
      'Списъкът е запазен на това устройство, не е публикуван.';

  @override
  String get noRelayAcceptedList =>
      'Нито един relay не прие списъка: ще се опита пак по-късно.';

  @override
  String relayListPublishedTo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Relay списъкът е публикуван към $count relay',
      one: 'Relay списъкът е публикуван към 1 relay',
    );
    return '$_temp0';
  }

  @override
  String get mediaServersUpdated => 'Медийните сървъри са обновени';

  @override
  String get appearance => 'Изглед';

  @override
  String get publishingSettings => 'Публикуване';

  @override
  String get addMialunaHashtag => 'Добави #mialuna';

  @override
  String get addMialunaHashtagNote =>
      'Добавя официалния хаштаг към публични публикации и истории. Можеш да го изключиш по всяко време.';

  @override
  String get themeLight => 'Светла';

  @override
  String get themeDark => 'Тъмна';

  @override
  String get themeSystem => 'Система';

  @override
  String get relays => 'Relays';

  @override
  String get relaysExplainSignedOut =>
      'Relays съхраняват и разпространяват съдържание. Влез, за да ползваш автоматично своя списък (NIP-65).';

  @override
  String get relaysExplainSynced =>
      'Списъкът е синхронизиран с Nostr профила ти (NIP-65): всяка промяна се публикува и важи за всичките ти приложения.';

  @override
  String get syncing => 'Синхронизиране…';

  @override
  String get waitingFirstSync => 'Чакам първия синхрон';

  @override
  String get syncNow => 'Синхронизирай сега';

  @override
  String get addRelay => 'Добави relay';

  @override
  String get restoreDefaultRelays => 'Възстанови стандартните relay';

  @override
  String get createYourList => 'Създай списъка си';

  @override
  String peopleCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count души',
      one: '1 човек',
    );
    return '$_temp0';
  }

  @override
  String get closeFriendsSettingsNote =>
      'Публикации, истории и видеа, видими само за тях, с криптирани снимки и видеа.';

  @override
  String get mediaServersBlossom => 'Медийни сървъри (Blossom)';

  @override
  String get mediaServersExplain =>
      'Снимките и видеата се качват само на тези сървъри, в показания ред: първият, който ги приеме, печели. EXIF и местоположението се махат преди качване.';

  @override
  String get primary => 'Основен';

  @override
  String get makePrimary => 'Направи основен';

  @override
  String get remove => 'Премахни';

  @override
  String get addServer => 'Добави сървър';

  @override
  String get moderation => 'Модерация';

  @override
  String get moderationExplain =>
      'Заглушените автори и скритите хаштагове се синхронизират чрез NIP-51. Блокираните автори остават само на това устройство.';

  @override
  String get mutedAuthors => 'Заглушени автори';

  @override
  String get noMutedAuthors => 'Няма заглушени автори';

  @override
  String get blockedAuthors => 'Блокирани автори';

  @override
  String get noBlockedAuthors => 'Няма блокирани автори';

  @override
  String get hiddenHashtags => 'Скрити хаштагове';

  @override
  String get noHiddenHashtags => 'Няма скрити хаштагове';

  @override
  String get hashtagToHide => '#hashtag за скриване';

  @override
  String get storage => 'Памет';

  @override
  String get clearCache => 'Изчисти кеша на събитията и черновите';

  @override
  String get cacheCleared => 'Кешът е изчистен';

  @override
  String get reviewIntro => 'Прегледай въведението';

  @override
  String get reviewIntroSubtitle =>
      'Какво е публично, какво е лично и лимитите за близки приятели.';

  @override
  String noLightningWalletCopied(Object address) {
    return 'Няма намерен Lightning портфейл: адресът е копиран ($address)';
  }

  @override
  String get about => 'За приложението';

  @override
  String aboutText(Object version) {
    return 'Mialuna $version — Твоите моменти, под същата луна.\nОтворен код (MIT). github.com/Lwb89dev/mialuna';
  }

  @override
  String get invalidRelayAddress => 'Невалиден адрес: използвай wss://…';

  @override
  String get invalidServerAddress => 'Невалиден адрес: използвай https://…';

  @override
  String get relayRead => 'Четене';

  @override
  String get relayWrite => 'Писане';

  @override
  String get support => 'Подкрепа';

  @override
  String get supportText =>
      'Mialuna е безплатна, без реклами и не те следи. Ако ти харесва, можеш да изпратиш няколко sats през Lightning Network.';

  @override
  String get donateWithLightning => 'Дари с Lightning';

  @override
  String get authorNoZaps => 'Този автор не приема zap';

  @override
  String get sendZap => 'Изпрати zap ⚡';

  @override
  String get amountInSats => 'Сума в sats';

  @override
  String minMaxSats(Object min, Object max) {
    return 'мин $min – макс $max';
  }

  @override
  String get zap => 'Zap';

  @override
  String get signInToZap => 'Влез, за да пращаш zap';

  @override
  String zapSent(Object sats) {
    return 'Zap от $sats sats е изпратен ⚡';
  }

  @override
  String nwcPaymentFailed(Object error) {
    return 'NWC плащането не успя: $error';
  }

  @override
  String get noLightningWallet => 'Няма намерен Lightning портфейл';

  @override
  String storiesRailLabel(Object state) {
    return 'Истории, $state';
  }

  @override
  String get close => 'Затвори';

  @override
  String hoursAgo(int hours) {
    return 'преди $hours ч';
  }

  @override
  String daysAgo(int days) {
    return 'преди $days д';
  }

  @override
  String get now => 'сега';

  @override
  String get youPrefix => 'Ти: ';

  @override
  String get storiesStateUnseen => 'ново';

  @override
  String get storiesStateSeen => 'видяно';

  @override
  String weekdayShort(String day) {
    String _temp0 = intl.Intl.selectLogic(day, {
      'mon': 'пн',
      'tue': 'вт',
      'wed': 'ср',
      'thu': 'чт',
      'fri': 'пт',
      'sat': 'сб',
      'sun': 'нд',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get sharedAMoment => 'Сподели момент';

  @override
  String get blossomOtherError => 'грешка';

  @override
  String get languageTitle => 'Език';

  @override
  String get languageSystem => 'Система';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageItalian => 'Italiano';

  @override
  String get cannotEditPhoto => 'Тази снимка не може да се редактира тук.';

  @override
  String notificationsNew(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count нови известия',
      one: '1 ново известие',
    );
    return '$_temp0';
  }

  @override
  String messagesUnread(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count непрочетени съобщения',
      one: '1 непрочетено съобщение',
    );
    return '$_temp0';
  }

  @override
  String get done => 'Готово';

  @override
  String get storyAddText => 'Добави текст';

  @override
  String get storyEditText => 'Редактирай текста';

  @override
  String get storyTextHint => 'Напиши нещо… #hashtags се докосват';

  @override
  String get storyTextsHelp =>
      'Докосни снимката, за да пишеш. Влачи за местене, щипни за размер и завъртане, докосни текст, за да го редактираш.';

  @override
  String storyTextsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count текста',
      one: '1 текст',
      zero: 'Няма текст',
    );
    return '$_temp0';
  }

  @override
  String get storyFontClassic => 'Класически';

  @override
  String get storyFontBold => 'Удебелен';

  @override
  String get storyFontSerif => 'Serif';

  @override
  String get storyFontMono => 'Mono';

  @override
  String get storyFontItalic => 'Курсив';

  @override
  String get storyTextBackground => 'Фон на текста';

  @override
  String get storyTextColor => 'Цвят на текста';

  @override
  String storyTextLimit(int max) {
    return 'Можеш да добавиш до $max текста.';
  }

  @override
  String get wotTitle => 'Мрежа на доверие';

  @override
  String get wotEnable => 'Твоята мрежа на доверие е винаги включена';

  @override
  String wotExplain(int min) {
    return 'Винаги включена. Открий показва само тази мрежа на доверие: ти, хората, които следваш, и всеки, следван от поне $min от тях. Същата мрежа на доверие скрива коментари, известия, лични публикации и съобщения от всички останали. Смята се на този телефон от публичните списъци със следвания при първото отваряне; после се ползва наготово. Нищо не се праща към сървър.';
  }

  @override
  String get wotRefresh => 'Обнови мрежата сега';

  @override
  String get wotStatusIdle =>
      'Още не е изградена. Изгражда се първия път, когато отвориш приложението.';

  @override
  String get wotBuildingTitle => 'Подготвям емисията Открий';

  @override
  String get wotBuildingBody =>
      'Чета кого следват хората, които следваш, и подготвям Открий.';

  @override
  String get wotDiscoverHint =>
      'Само твоята мрежа на доверие: хора, които следваш, и хора, които достатъчно от тях следват.';

  @override
  String get wotDiscoverSignIn =>
      'Открий показва твоята мрежа на доверие. Влез и първия път Mialuna чете кого следваш и изгражда тази емисия. После я ползва наготово.';

  @override
  String get wotDiscoverEmpty =>
      'Още няма публикации от твоята мрежа на доверие.';

  @override
  String wotStatusDiscovering(int done, int total) {
    return 'Проверявам кого следват следванията ти… $done от $total';
  }

  @override
  String wotStatusComplete(int direct, int indirect, Object when) {
    return 'Твоята мрежа: $direct души, които следваш, плюс $indirect, следвани от достатъчно от тях. Обновено $when.';
  }

  @override
  String wotStatusFailed(Object reason) {
    return 'Мрежата не можа да се изчисли: $reason';
  }

  @override
  String get wotNoFollows => 'още не следваш никого';

  @override
  String get messageRequests => 'Заявки за съобщения';

  @override
  String messageRequestsSubtitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count разговора извън твоята мрежа на доверие',
      one: '1 разговор извън твоята мрежа на доверие',
    );
    return '$_temp0';
  }

  @override
  String get messageRequestsHint =>
      'От хора извън твоята мрежа на доверие. Не се броят като непрочетени. Отговори, за да преместиш разговора във входящите.';

  @override
  String get storyViewsSetting =>
      'Нека хората виждат, че съм гледал историите им';

  @override
  String get storyViewsSettingExplain =>
      'Когато гледаш история, на автора се праща разписка, криптирана така, че само авторът да я прочете. В нея е твоето име до името на автора; relay не виждат нищо. Ако не може да се достави, пази се и се пробва по-късно. Изключи, за да гледаш, без да казваш на никого: още неизпратените разписки се махат (вече доставена не може да се върне).';

  @override
  String storySeenBy(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Видяна от $count души',
      one: 'Видяна от 1 човек',
      zero: 'Още няма гледания',
    );
    return '$_temp0';
  }

  @override
  String get storyViewsEmpty =>
      'Никой още не е гледал тази история или разписките им не са стигнали до теб.';

  @override
  String get storyViewsHint =>
      'Само хората, които го позволяват, пращат разписка, затова реалният брой може да е по-голям.';

  @override
  String get systemNotifications => 'Системни известия';

  @override
  String get systemNotificationsExplain =>
      'Показвай известие на телефона, когато пристигне нещо ново, докато Mialuna е на заден план. Личните съобщения никога не показват текста си, дори на заключения екран. Android спира приложения, които дълго стоят на заден план, затова известията идват, докато Mialuna още работи.';

  @override
  String get systemNotificationsBlocked =>
      'Известията за Mialuna са изключени в настройките на телефона.';

  @override
  String get systemNotificationsOpenSettings => 'Отвори настройките';

  @override
  String get systemNotificationsBattery =>
      'Android приспива приложенията няколко минути след изключване на екрана и известията спират с тях. За да ги получаваш и после, задай батерията на Mialuna на “Неограничено”.';

  @override
  String get systemNotificationsBatteryAction =>
      'Отвори настройките на батерията';

  @override
  String get newFollowersSetting => 'Показвай нови последователи';

  @override
  String get newFollowersSettingExplain =>
      'Новите последователи се появяват в Известия и на телефона. Изключи, ако те заливат със следвания: харесванията, коментарите и zap остават.';

  @override
  String get systemNotificationMessage => 'ти изпрати лично съобщение';

  @override
  String get systemNotificationNewMessage => 'Ново лично съобщение';

  @override
  String get systemNotificationNew => 'Ново известие';

  @override
  String get notificationChannelSocial =>
      'Реакции, коментари, zap и последователи';

  @override
  String get notificationChannelMessages => 'Лични съобщения';

  @override
  String get zapInvoiceMismatch =>
      'Фактурата не съвпада със сумата, която избра. Нищо не е платено.';

  @override
  String get storyYourStory => 'Твоята история';

  @override
  String get storyNew => 'Нова история';

  @override
  String get storyAddSemantics => 'Добави към историята си';

  @override
  String storyOwnRailLabel(int count, Object state) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count истории',
      one: '1 история',
    );
    return 'Твоята история, $_temp0, $state';
  }

  @override
  String get storyTextSize => 'Размер на текста';

  @override
  String get storyPickPrompt => 'Избери снимка или видео за историята си';

  @override
  String get storyEditPhoto => 'Редактирай снимката';

  @override
  String get storyCaption => 'Описание';

  @override
  String get storyDiscardTitle => 'Да отхвърля ли тази история?';

  @override
  String get storyDiscard => 'Отхвърли';

  @override
  String get storyShare => 'Сподели';

  @override
  String get storyShared => 'Историята е споделена';

  @override
  String get deletePost => 'Изтрий';

  @override
  String get deletePostTitle => 'Да изтрия ли тази публикация?';

  @override
  String get deleteStoryTitle => 'Да изтрия ли тази история?';

  @override
  String get deletePostBody =>
      'Mialuna ще помоли relay да я изтрият и медийните сървъри да изтрият снимките или видеото. relay, който пренебрегне заявката, или някой със запазено копие, може още да я има.';

  @override
  String get deletePrivateBody =>
      'Публикация за близки приятели не може да се изтегли от relay. Mialuna ще каже на приложенията на приятелите ти да я махнат и ще помоли медийния сървър да изтрие криптираните файлове. Приятел, който вече е запазил копие, може още да я има.';

  @override
  String get deletingPost => 'Изтривам…';

  @override
  String get postDeleted => 'Изтрито.';

  @override
  String get postWasDeleted => 'Тази публикация е изтрита.';

  @override
  String get deleteNotAllowed =>
      'Само профилът, който я е публикувал, може да я изтрие.';

  @override
  String deleteFailed(Object reason) {
    return 'Не можа да се изтрие: $reason';
  }

  @override
  String get deleteNoRelay =>
      'Нито един relay не прие заявката за изтриване, затова още е онлайн. Провери връзката и опитай пак.';

  @override
  String deleteMediaLeft(Object servers) {
    return 'Медията не можа да се махне от $servers.';
  }

  @override
  String get deleteMediaNotAuthorized =>
      'Подписващият не разреши махането на медията, затова файловете още са на медийния сървър.';

  @override
  String deleteFriendsMissed(Object count) {
    return '$count от твоите близки приятели не можаха да бъдат уведомени, затова може да остане на телефоните им.';
  }

  @override
  String get storyCleanupSetting => 'Изтривай историите ми, когато изтекат';

  @override
  String get storyCleanupSettingExplain =>
      'След 24 часа Mialuna моли relay и медийните сървъри да изтрият историите ти, заедно със снимките и видеата. Сървър, който пренебрегне заявката, или някой със запазено копие, може още да ги има.';

  @override
  String storyCleanupWaiting(Object count) {
    return 'Подписващият трябва да одобри всяко почистване, затова се чака, докато го поискаш. Изтекли истории в очакване: $count.';
  }

  @override
  String get storyCleanupNow => 'Изтрий сега';

  @override
  String get storyCleanupDone => 'Изтеклите истории са изтрити.';

  @override
  String get storyCleanupPartly =>
      'Някои още не можаха да се изтрият; Mialuna ще опита пак.';

  @override
  String get editorPro => 'Про редактор';

  @override
  String get editorModeBasic => 'Основно';

  @override
  String get editorModePro => 'Pro';

  @override
  String get toolCrop => 'Изрязване';

  @override
  String get toolLight => 'Светлина';

  @override
  String get toolColor => 'Цвят';

  @override
  String get toolHsl => 'HSL';

  @override
  String get toolCurves => 'Криви';

  @override
  String get toolEffects => 'Ефекти';

  @override
  String get straighten => 'Изправяне';

  @override
  String get exposure => 'Експозиция';

  @override
  String get highlights => 'Светли тонове';

  @override
  String get shadows => 'Сенки';

  @override
  String get whites => 'Бели';

  @override
  String get blacks => 'Черни';

  @override
  String get temperature => 'Температура';

  @override
  String get tint => 'Нюанс';

  @override
  String get vibrance => 'Живост';

  @override
  String get hue => 'Цветови тон';

  @override
  String get luminance => 'Яркост';

  @override
  String get colorRed => 'Червено';

  @override
  String get colorOrange => 'Оранжево';

  @override
  String get colorYellow => 'Жълто';

  @override
  String get colorGreen => 'Зелено';

  @override
  String get colorAqua => 'Аквамарин';

  @override
  String get colorBlue => 'Синьо';

  @override
  String get colorPurple => 'Лилаво';

  @override
  String get colorMagenta => 'Пурпурно';

  @override
  String get curveHint =>
      'Плъзнете точка, за да оформите кривата; докоснете, за да добавите; докоснете двукратно, за да премахнете.';

  @override
  String get sharpen => 'Острота';

  @override
  String get vignette => 'Винетка';

  @override
  String get grain => 'Зърно';

  @override
  String get holdForOriginal =>
      'Задръжте снимката, за да я сравните с оригинала.';

  @override
  String get showingOriginal => 'Оригинал';

  @override
  String get applyLookToAll => 'Приложи този вид към всички снимки';

  @override
  String get applyingEdits => 'Обработване на снимките…';

  @override
  String get choosePhotoToEdit => 'Изберете снимка за редактиране';
}
