// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get syncUpToDate => 'Всё актуально';

  @override
  String get syncFailed => 'Синхронизация не удалась';

  @override
  String get relaysUpdatedFromProfile =>
      'Список Relay обновлён из твоего профиля (NIP-65)';

  @override
  String get relayListPublished => 'Список Relay опубликован';

  @override
  String get mediaServersUpdatedFromProfile =>
      'Медиасерверы обновлены из твоего профиля';

  @override
  String get tabHome => 'Home';

  @override
  String get tabDiscover => 'Обзор';

  @override
  String get tabCreate => 'Создать';

  @override
  String get tabReels => 'Reels';

  @override
  String get tabProfile => 'Профиль';

  @override
  String get signInToUploadMedia => 'Войди, чтобы загрузить медиа.';

  @override
  String get noMediaServer =>
      'Медиасервер не настроен. Добавь его в Настройках.';

  @override
  String serverNoResponse(Object server) {
    return '$server: нет ответа';
  }

  @override
  String serverUnreachable(Object server, Object error) {
    return '$server: недоступен ($error)';
  }

  @override
  String uploadRejected(Object reason) {
    return 'Загрузка отклонена — $reason';
  }

  @override
  String noServerAcceptedFile(Object reasons) {
    return 'Ни один сервер не принял файл — $reasons';
  }

  @override
  String get blossomInvalidResponse => 'неверный ответ';

  @override
  String get blossomInvalidFileUrl => 'неверный адрес файла';

  @override
  String get blossomServerAlteredFile => 'сервер изменил файл';

  @override
  String get blossomBadRequest => 'неверный запрос';

  @override
  String get blossomUnauthorized => 'авторизация отклонена';

  @override
  String get blossomPaymentRequired => 'нужна оплата';

  @override
  String get blossomForbidden => 'не разрешено';

  @override
  String get blossomLengthRequired => 'не указан размер';

  @override
  String get blossomTooLarge => 'файл слишком большой';

  @override
  String get blossomUnsupportedType => 'формат не принимается';

  @override
  String get blossomTooManyRequests => 'слишком много запросов';

  @override
  String get blossomServerError => 'ошибка сервера';

  @override
  String get cipherInvalidKey => 'Неверный ключ';

  @override
  String get cipherTruncated => 'Зашифрованный файл обрезан';

  @override
  String get cipherMismatch =>
      'Файл не совпадает с ключом: изменён или повреждён';

  @override
  String get sanitizeHeifNeedsAsync =>
      'Формат HEIC/AVIF: для конвертации нужен sanitizeAsync';

  @override
  String get sanitizeWebmUnsupported =>
      'Видео WebM/MKV не поддерживается: используй MP4 или MOV, чтобы метаданные можно было удалить перед загрузкой.';

  @override
  String get sanitizeUnknownFormat =>
      'Неизвестный формат файла: фото JPEG/PNG/WebP/GIF или видео MP4/MOV.';

  @override
  String sanitizeLeftovers(Object items) {
    return 'Не удалось удалить все метаданные ($items): файл не загружен.';
  }

  @override
  String sanitizeProcessingFailed(Object error) {
    return 'Не удалось обработать файл: $error';
  }

  @override
  String get sanitizeJpegInvalid => 'Некорректный JPEG';

  @override
  String get sanitizeJpegTruncated => 'Обрезанный JPEG';

  @override
  String get sanitizeJpegNoSize => 'JPEG без размеров';

  @override
  String get sanitizeJpegUndecodable => 'JPEG нельзя декодировать';

  @override
  String get sanitizePngTruncated => 'Обрезанный PNG';

  @override
  String get sanitizePngInvalid => 'Некорректный PNG';

  @override
  String get sanitizeGifInvalid => 'Некорректный GIF';

  @override
  String get sanitizeGifTruncated => 'Обрезанный GIF';

  @override
  String get sanitizeWebpTruncated => 'Обрезанный WebP';

  @override
  String get sanitizeWebpInvalid => 'Некорректный WebP';

  @override
  String get sanitizeMp4Invalid => 'Некорректное видео MP4/MOV';

  @override
  String get sanitizeConversionFailed => 'Конвертация не удалась';

  @override
  String get sanitizeHeifUnsupported =>
      'Этот формат (HEIC/AVIF) нельзя конвертировать на этом устройстве. Выбери фото JPEG или PNG.';

  @override
  String get privateMediaNotEncrypted => 'Медиа не зашифровано';

  @override
  String serverReplied(Object status) {
    return 'Сервер ответил $status';
  }

  @override
  String get fileTooLarge => 'Файл слишком большой';

  @override
  String get serverFileNotOriginal => 'Файл на сервере не является оригиналом';

  @override
  String get contentMismatch => 'Содержимое не совпадает';

  @override
  String get mediaUnreachable => 'Медиа недоступно';

  @override
  String get amberInvalidKey => 'Amber вернул неверный ключ';

  @override
  String get amberNoKey => 'Amber не вернул ключ';

  @override
  String get amberRequestRejected => 'Запрос отклонён в Amber';

  @override
  String get amberAndroidOnly => 'Amber доступен только на Android';

  @override
  String get amberEmptySignature => 'Amber вернул пустую подпись';

  @override
  String get amberSignRejected => 'Подпись отклонена в Amber';

  @override
  String get amberTimeout => 'Amber не ответил вовремя';

  @override
  String get amberEmptyResponse => 'Amber вернул пустой ответ';

  @override
  String get bunkerInvalidUrl => 'Неверный URL bunker';

  @override
  String get bunkerNoRelay => 'В bunker не указан ни один relay';

  @override
  String get bunkerWebAuth =>
      'bunker требует веб-авторизацию (auth_url не поддерживается)';

  @override
  String get bunkerInvalidKey => 'bunker не вернул действительный ключ';

  @override
  String get signerInvalidResponse =>
      'Подписант вернул недействительное подписанное событие';

  @override
  String get bunkerTimeout => 'Bunker не ответил вовремя';

  @override
  String get nwcInvalidUri => 'Неверный URI NWC';

  @override
  String get nwcNoRelay => 'В URI NWC не указан ни один relay';

  @override
  String get nwcNoSecret => 'В URI NWC нет действительного секрета';

  @override
  String get nwcTimeout => 'Кошелёк не ответил вовремя';

  @override
  String get signerNoPrivateMessages =>
      'Этот способ входа не поддерживает личные сообщения';

  @override
  String get zapNotSupported => 'Этот адрес не поддерживает Nostr zap';

  @override
  String zapAmountOutOfRange(Object min, Object max) {
    return 'Сумма вне диапазона ($min–$max sats)';
  }

  @override
  String get commentNotSent => 'Комментарий не отправлен. Попробуй позже.';

  @override
  String get comments => 'Комментарии';

  @override
  String get noCommentsYet => 'Пока нет комментариев.';

  @override
  String get signInToComment => 'Войди, чтобы комментировать.';

  @override
  String get addComment => 'Добавить комментарий…';

  @override
  String get signInToPublish => 'Войди, чтобы опубликовать.';

  @override
  String get addMediaFirst =>
      'Добавь хотя бы одно фото или видео перед публикацией.';

  @override
  String get removingMetadata => 'Удаляем метаданные…';

  @override
  String uploadingProgress(Object current, Object total) {
    return 'Загрузка $current из $total…';
  }

  @override
  String get creatingPreview => 'Создаём превью…';

  @override
  String uploadFailed(Object error) {
    return 'Загрузка не удалась: $error';
  }

  @override
  String get publishing => 'Публикация…';

  @override
  String noRelayAcceptedPost(Object reason) {
    return 'Ни один relay не принял post$reason. Содержимое остаётся в черновиках.';
  }

  @override
  String get privateNeedsKeySigner =>
      'Этот способ входа не поддерживает личный контент. Используй Amber, bunker или локальный ключ.';

  @override
  String get closeFriendsListEmptyAddSomeone =>
      'Список близких друзей пуст: добавь кого-нибудь.';

  @override
  String get fileOver100Mb =>
      'Файл больше 100 МБ: это предел для близких друзей (он целиком шифруется на твоём телефоне).';

  @override
  String get encryptingOnPhone => 'Шифрование на телефоне…';

  @override
  String noServerAcceptedEncrypted(Object details) {
    return 'Ни один из твоих медиасерверов не принял зашифрованный файл. В открытом виде он не публикуется. Добавь в Настройках сервер, который принимает зашифрованные файлы (например, cdn.hzrd149.com). $details';
  }

  @override
  String get sendingToFriends => 'Отправка друзьям…';

  @override
  String sendingToFriendsProgress(Object done, Object total) {
    return 'Отправка друзьям $done/$total…';
  }

  @override
  String noFriendReceivedPost(Object reason) {
    return 'Ни один друг не получил post$reason. Содержимое остаётся в черновиках.';
  }

  @override
  String sentToCloseFriends(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Отправлено $count близким друзьям 🔒',
      one: 'Отправлено 1 близкому другу 🔒',
    );
    return '$_temp0';
  }

  @override
  String sentToFriendsWithMisses(int delivered, Object missed) {
    String _temp0 = intl.Intl.pluralLogic(
      delivered,
      locale: localeName,
      other: 'Отправлено $delivered друзьям.',
      one: 'Отправлено 1 другу.',
    );
    return '$_temp0 $missed не получили его (личные сообщения выключены).';
  }

  @override
  String get altText => 'Альт-текст';

  @override
  String get altTextHint => 'Опиши содержимое для тех, кто его не видит…';

  @override
  String get cancel => 'Отмена';

  @override
  String get save => 'Сохранить';

  @override
  String get momentPublished => 'Момент опубликован ✨';

  @override
  String get newMoment => 'Новый момент';

  @override
  String get publish => 'Опубликовать';

  @override
  String get guestMode => 'Режим гостя';

  @override
  String get signInToPostMoments => 'Войди, чтобы публиковать свои моменты.';

  @override
  String get signIn => 'Войти';

  @override
  String get kindPhoto => 'Фото';

  @override
  String get kindVideo => 'Видео';

  @override
  String get kindReel => 'Reel';

  @override
  String get kindStory => 'История';

  @override
  String get storyExpiryNote =>
      'Истории исчезают через 24 часа на relay, которые соблюдают NIP-40, но другие всё равно могут их сохранить или заархивировать.';

  @override
  String get fromGallery => 'Из галереи';

  @override
  String get galleryLongPressVideo => 'Галерея (долгое нажатие для видео)';

  @override
  String get addVideo => 'Добавить видео';

  @override
  String get camera => 'Камера';

  @override
  String get exifRemovedNote =>
      'Метаданные местоположения (EXIF) удаляются автоматически.';

  @override
  String get writeCaption => 'Напиши подпись…';

  @override
  String get privatePostNote =>
      'Личный пост: без публичных хештегов, через поиск его не найти.';

  @override
  String willPublishAs(Object caption) {
    return 'Будет опубликовано как: \"$caption\"';
  }

  @override
  String get tapThumbnailForAlt =>
      'Нажми на миниатюру, чтобы добавить альтернативный текст.';

  @override
  String get sensitiveContent => 'Чувствительный контент';

  @override
  String get sensitiveContentNote =>
      'Пост будет скрыт за предупреждением (NIP-36).';

  @override
  String get uploadingMedia => 'Загрузка медиа…';

  @override
  String get audiencePublic => 'Публично';

  @override
  String get closeFriends => 'Близкие друзья';

  @override
  String get signerCannotPublishCloseFriends =>
      'С этим способом входа нельзя публиковать для близких друзей: используй Amber, bunker или локальный ключ.';

  @override
  String get closeFriendsEmptyPrompt =>
      'Список пуст: добавь людей, которые смогут видеть этот пост.';

  @override
  String onlyYourCloseFriendsSee(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Это увидят только твои $count близких друзей. Фото и видео шифруются на твоём телефоне перед загрузкой.',
      one: 'Это увидит только 1 твой близкий друг. Фото и видео шифруются на твоём телефоне перед загрузкой.',
    );
    return '$_temp0';
  }

  @override
  String get addFriends => 'Добавить друзей';

  @override
  String get manageList => 'Управлять списком';

  @override
  String get edit => 'Изменить';

  @override
  String get reset => 'Сбросить';

  @override
  String get apply => 'Применить';

  @override
  String get cropFree => 'Свободно';

  @override
  String get cropOriginal => 'Оригинал';

  @override
  String get rotate => 'Повернуть';

  @override
  String get flip => 'Отразить';

  @override
  String get brightness => 'Яркость';

  @override
  String get contrast => 'Контраст';

  @override
  String get saturation => 'Насыщенность';

  @override
  String postsByAuthor(Object author) {
    return 'Посты $author…';
  }

  @override
  String get searchHint => 'Ищи людей, хештеги или слова…';

  @override
  String get clear => 'Очистить';

  @override
  String get recent => 'Недавние';

  @override
  String get searchDependsOnRelays =>
      'Поиск зависит от настроенных relay: результаты могут быть неполными.';

  @override
  String get recentPostsEverywhere =>
      'Недавние посты со всей сети, включая людей, на которых ты не подписан.';

  @override
  String get noResultsOnRelays => 'На настроенных relay нет результатов.';

  @override
  String get noRecentPostsFromFollowed =>
      'Нет недавних постов от людей, на которых ты подписан.';

  @override
  String get noMomentsFound =>
      'На relay не найдено моментов. Проверь соединение.';

  @override
  String get loadFailed => 'Не удалось загрузить';

  @override
  String get notifications => 'Уведомления';

  @override
  String get messages => 'Сообщения';

  @override
  String get homeEmptyFollowsNobody =>
      'Здесь появляются посты людей, на которых ты подписан.\nТы пока ни на кого не подписан: найди интересных людей и профили.';

  @override
  String get discoverPeople => 'Обзор людей';

  @override
  String get homeEmpty =>
      'Пока нет моментов.\nПотяни вниз, чтобы обновить, или опубликуй свой первый кадр.';

  @override
  String get retry => 'Ещё раз';

  @override
  String get seenEverything => 'Пока это всё ✨';

  @override
  String get discoverMoreProfiles => 'Ещё профили в Обзоре';

  @override
  String get feedFollowing => 'Подписки';

  @override
  String get signInToSeeFollowed =>
      'Войди, чтобы видеть посты людей, на которых ты подписан';

  @override
  String get videoPreview => 'Предпросмотр видео';

  @override
  String get cannotOpenPrivateVideo => 'Не удаётся открыть личное видео';

  @override
  String get cannotPlayVideo => 'Не удаётся воспроизвести видео';

  @override
  String get pauseVideo => 'Поставить видео на паузу';

  @override
  String get playVideo => 'Воспроизвести видео';

  @override
  String errorTapToRetry(Object error) {
    return '$error — нажми, чтобы повторить';
  }

  @override
  String get soundOn => 'Включить звук';

  @override
  String get soundOff => 'Выключить звук';

  @override
  String get postImage => 'Изображение поста';

  @override
  String get imageUnavailable => 'Изображение недоступно';

  @override
  String errorTapToRetryNewline(Object message) {
    return '$message\nНажми, чтобы повторить';
  }

  @override
  String get cannotOpenPrivateContent =>
      'Не удаётся открыть этот личный контент';

  @override
  String get privateImage => 'Личное изображение';

  @override
  String get invalidImage => 'Некорректное изображение';

  @override
  String get more => 'Ещё';

  @override
  String get removeFromSaved => 'Убрать из сохранённых';

  @override
  String get copyLink => 'Копировать ссылку';

  @override
  String get muteAuthor => 'Заглушить автора';

  @override
  String get blockAuthor => 'Заблокировать автора';

  @override
  String get report => 'Пожаловаться';

  @override
  String get like => 'Нравится';

  @override
  String get sendInMessage => 'Отправить в сообщении';

  @override
  String get zapOptional => 'Zap (необязательно)';

  @override
  String get closeFriendsOnlyNote =>
      'Видно только близким друзьям. Лайки и ответы уходят только автору.';

  @override
  String get likeFailed => 'Не удалось отправить лайк';

  @override
  String get nostrLinkCopied => 'Ссылка Nostr скопирована в буфер';

  @override
  String get authorMuted => 'Автор заглушен';

  @override
  String get authorBlocked => 'Автор заблокирован';

  @override
  String get reportSent => 'Жалоба отправлена (NIP-56)';

  @override
  String get signInToReport => 'Войди, чтобы пожаловаться';

  @override
  String minutesAgo(Object minutes) {
    return '$minutes мин. назад';
  }

  @override
  String get show => 'Показать';

  @override
  String get chatEmptyHint =>
      'Напиши первое сообщение.\nОно зашифровано: его видят только ты и собеседник.';

  @override
  String get messageHint => 'Сообщение…';

  @override
  String get send => 'Отправить';

  @override
  String get notSentSuffix => ' не отправлено';

  @override
  String get contentUnavailable =>
      'Контент недоступен (истёк или не найден на relay)';

  @override
  String get signInToSendPrivateMessages =>
      'Войди, чтобы отправлять личные сообщения.';

  @override
  String get cannotMessageYourself => 'Себе написать нельзя.';

  @override
  String get recipientNoPrivateMessages =>
      'Этот человек ещё не включил личные сообщения.';

  @override
  String noRecipientRelayAccepted(Object reason) {
    return 'Ни один relay$reason получателя не принял сообщение.';
  }

  @override
  String sendFailed(Object error) {
    return 'Отправка не удалась: $error';
  }

  @override
  String get signInToReadMessages =>
      'Войди, чтобы читать и отправлять личные сообщения.';

  @override
  String get signerNoPrivateMessagesLong =>
      'Личные сообщения нельзя использовать с этим способом входа. Войди через Amber, bunker или локальный ключ.';

  @override
  String get inboxEmpty =>
      'Нет переписок.\nНажми на карандаш, чтобы кому-нибудь написать, или перешли момент значком ✈ под каждым постом.';

  @override
  String get newMessage => 'Новое сообщение';

  @override
  String get privateMessagesEnabled => 'Личные сообщения включены';

  @override
  String get enableMessagesFailed =>
      'Не удалось их включить. Попробуй ещё раз.';

  @override
  String get enablePrivateMessages => 'Включить личные сообщения';

  @override
  String enablePrivateMessagesExplain(Object count) {
    return 'Чтобы получать сообщения, нужно указать, на какие relay они должны приходить. Публикуется небольшой список (NIP-17) с $count relay по умолчанию: его можно изменить позже. Сообщения остаются зашифрованными: relay не видят ни кто пишет, ни текст.';
  }

  @override
  String get turnOn => 'Включить';

  @override
  String get searchByNameOrUsername => 'Поиск по имени или юзернейму';

  @override
  String get searching => 'Поиск…';

  @override
  String get noOneWithNameHint =>
      'Никого с таким именем. Попробуй меньше букв или адрес вроде name@domain.com.';

  @override
  String get sent => 'Отправлено';

  @override
  String sentToPeople(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Отправлено $count людям',
      one: 'Отправлено 1 человеку',
    );
    return '$_temp0';
  }

  @override
  String sentToPeopleWithFailure(int count, Object failure) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Отправлено $count людям. $failure',
      one: 'Отправлено 1 человеку. $failure',
    );
    return '$_temp0';
  }

  @override
  String get signerNoPrivateMessagesShort =>
      'С этим способом входа нельзя пользоваться личными сообщениями.';

  @override
  String get followToStartOrSearch =>
      'Подпишись на кого-нибудь, чтобы начать, или ищи по имени.';

  @override
  String get addMessage => 'Добавить сообщение…';

  @override
  String sendWithCount(Object count) {
    return 'Отправить ($count)';
  }

  @override
  String get linkCopied => 'Ссылка скопирована в буфер';

  @override
  String get noNotifications => 'Сейчас нет уведомлений.';

  @override
  String get notificationsDependOnRelays =>
      'Уведомления зависят от relay: они могут быть неполными.';

  @override
  String get reactedToYourMoment => 'отреагировал на твой момент';

  @override
  String commentedText(Object text) {
    return 'прокомментировал: $text';
  }

  @override
  String sentYouSats(Object sats, Object comment) {
    return 'отправил тебе $sats sats$comment';
  }

  @override
  String get sentYouZap => 'отправил тебе zap';

  @override
  String get startedFollowingYou => 'подписался на тебя';

  @override
  String get amberNotFound => 'Amber не найден';

  @override
  String get amberExplain =>
      'Amber это подписант Nostr, который хранит твой приватный ключ вне Mialuna. Установи его и попробуй снова.';

  @override
  String get downloadFromFdroid => 'Скачать с F-Droid';

  @override
  String get continueWithAmber => 'Продолжить с Amber';

  @override
  String get amberRecommended =>
      'Рекомендуется: твой приватный ключ в безопасности в Amber.';

  @override
  String get amberNotDetected =>
      'Amber не обнаружен: установи его для рекомендуемого входа.';

  @override
  String get exploreWithoutAccount => 'Смотреть без аккаунта';

  @override
  String get remoteBunker => 'Удалённый bunker (NIP-46)';

  @override
  String get invalidBunkerUrlDot => 'Неверный URL bunker.';

  @override
  String get connectBunker => 'Подключить bunker';

  @override
  String get advancedNsec => 'Расширенный вход (nsec)';

  @override
  String get nsecWarning =>
      'Внимание: вставлять приватный ключ рискованно. Никому его не передавай. На Android лучше Amber.';

  @override
  String get invalidNsec => 'Неверный ключ nsec.';

  @override
  String get signInWithNsec => 'Войти с nsec';

  @override
  String get tagline => 'Твои моменты, под одной луной.';

  @override
  String get skip => 'Пропустить';

  @override
  String get permissionsAndWallet => 'Разрешения и кошелёк';

  @override
  String get permissionsExplain =>
      'Они позволяют только публиковать и получать уведомления. В любой момент их можно изменить в системных настройках.';

  @override
  String get photosAndVideos => 'Фото и видео';

  @override
  String get toUploadYourMoments => 'Чтобы загружать твои моменты';

  @override
  String get allow => 'Разрешить';

  @override
  String get reactionsCommentsZaps => 'Реакции, комментарии и zap';

  @override
  String get lightningWalletOptional => 'Кошелёк Lightning (необязательно)';

  @override
  String get nwcExplain =>
      'Подключи кошелёк Nostr Wallet Connect, чтобы отправлять zap, не выходя из приложения.';

  @override
  String get walletConnected => 'Кошелёк подключён';

  @override
  String get disconnect => 'Отключить';

  @override
  String get connectWallet => 'Подключить кошелёк';

  @override
  String get getStarted => 'Начать';

  @override
  String get welcome1 =>
      'Mialuna это визуальная соцсеть: фото, видео, Reels и истории — никогда не посты только из текста.';

  @override
  String get welcome2 =>
      'Она работает на Nostr, открытом протоколе: твоя личность это ключ, который принадлежит тебе, а не аккаунт, который компания может забрать. Без рекламы, без трекеров, без центральных серверов.';

  @override
  String get welcome3 =>
      'Делись своим светом с людьми повсюду, из любого приложения, которое говорит на том же открытом языке.';

  @override
  String onboardingWot(int min) {
    return 'Сеть доверия всегда включена. В первый раз, когда ты открываешь Mialuna, она смотрит, на кого ты подписан, и собирает из этой сети ленту Обзора: ты, люди, на которых ты подписан, и те, на кого подписаны хотя бы $min из них. В следующие разы эта лента уже на месте.';
  }

  @override
  String get publicAndPrivate => 'Публичное и личное';

  @override
  String get publicAndPrivateIntro =>
      'Mialuna построена на Nostr, открытой сети. То, что ты публикуешь, публично: посты, фото и видео остаются видны всем, у кого есть ссылка, даже вне Mialuna.';

  @override
  String get closeFriendsExplain1 =>
      'Только люди из этого списка получают твои посты, истории и видео «Близкие друзья». Список внутри поста; выбирать его каждый раз не нужно.';

  @override
  String get closeFriendsExplain2 =>
      'Фото и видео шифруются на твоём телефоне перед загрузкой. Файловые серверы (Blossom) сами ничего не шифруют: поэтому это делает Mialuna, а сервер видит только нечитаемые данные. Кто найдёт адрес файла, открыть его не сможет.';

  @override
  String get closeFriendsExplain3 =>
      'Это не абсолютная гарантия: кто получил пост, может сделать скриншот, а удаление друга действует только на будущие посты.';

  @override
  String get closeFriendsExplain4 =>
      'Каждый друг должен пользоваться Mialuna с включёнными личными сообщениями. Другие клиенты Nostr эти посты не показывают.';

  @override
  String get closeFriendsExplain5 =>
      'Публичные посты остаются публичными: их файлы видны всем, у кого есть ссылка.';

  @override
  String get closeFriendsExplain6 =>
      'Если ни один из твоих серверов не принимает зашифрованные файлы, пост не публикуется: никогда в открытом виде.';

  @override
  String get addToCloseFriends => 'Добавить в близкие друзья';

  @override
  String maxFriendsReached(Object max, Object added) {
    return 'Лимит $max друзей: добавлено $added.';
  }

  @override
  String get add => 'Добавить';

  @override
  String get signInToCreateList => 'Войди, чтобы создать свой список.';

  @override
  String get signerNoCloseFriends =>
      'Близких друзей нельзя использовать с этим способом входа. Войди через Amber, bunker или локальный ключ.';

  @override
  String peopleOfMax(Object count, Object max) {
    return '$count / $max человек';
  }

  @override
  String get noOneYet => 'Пока никого.';

  @override
  String get addPeople => 'Добавить людей';

  @override
  String get friendNoPrivateMessagesWarning =>
      'Личные сообщения не включены: твои посты доходить не будут';

  @override
  String get removeFromList => 'Убрать из списка';

  @override
  String get noOneWithThisName => 'Никого с таким именем.';

  @override
  String get signInToSendPrivateContent =>
      'Войди, чтобы отправлять личный контент.';

  @override
  String get reasonNoPrivateMessages => 'не включил личные сообщения';

  @override
  String get reasonNoRelayAnswered => 'ни один relay не ответил';

  @override
  String get profileUpdated => 'Профиль обновлён';

  @override
  String get noRelayAcceptedRetry => 'Ни один relay не принял. Попробуй позже.';

  @override
  String get editProfile => 'Изменить профиль';

  @override
  String get fieldName => 'Имя';

  @override
  String get fieldBio => 'О себе';

  @override
  String get fieldAvatarUrl => 'URL аватара';

  @override
  String get fieldNip05 => 'NIP-05 (напр. you@example.com)';

  @override
  String get browsingAsGuest => 'Ты смотришь как гость';

  @override
  String get signInToInteract =>
      'Войди, чтобы публиковать, подписываться и взаимодействовать.';

  @override
  String get settings => 'Настройки';

  @override
  String get signOut => 'Выйти';

  @override
  String get npubCopied => 'npub скопирован';

  @override
  String get copyNpub => 'Копировать npub';

  @override
  String get mute => 'Заглушить';

  @override
  String get block => 'Заблокировать';

  @override
  String get posts => 'Посты';

  @override
  String get saved => 'Сохранённые';

  @override
  String get nothingPublishedYet => 'Ты ещё ничего не опубликовал.';

  @override
  String get noPostsOnRelays => 'На relay постов не найдено.';

  @override
  String get noReelsPublished => 'Нет опубликованных reels.';

  @override
  String get noReelsOnRelays => 'На relay не найдено reels.';

  @override
  String get noSavedPosts => 'Нет сохранённых постов.';

  @override
  String get followingButton => 'Подписки';

  @override
  String get follow => 'Подписаться';

  @override
  String get messageButton => 'Написать';

  @override
  String get loginLocalKey => 'Локальный ключ';

  @override
  String get loginGuest => 'Гость';

  @override
  String get followUpdateFailed =>
      'Не удалось обновить твои подписки прямо сейчас. Попробуй ещё раз.';

  @override
  String get noReelsComeBack => 'На relay не найдено reels.\nЗагляни позже!';

  @override
  String get followUpdateFailedShort =>
      'Не удалось обновить твои подписки прямо сейчас';

  @override
  String get needOneReadRelay => 'Нужен хотя бы один relay для чтения.';

  @override
  String get listSavedLocally =>
      'Список сохранён на этом устройстве, не опубликован.';

  @override
  String get noRelayAcceptedList =>
      'Ни один relay не принял список: повтор будет позже.';

  @override
  String relayListPublishedTo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Список Relay опубликован на $count relay',
      one: 'Список Relay опубликован на 1 relay',
    );
    return '$_temp0';
  }

  @override
  String get mediaServersUpdated => 'Медиасерверы обновлены';

  @override
  String get appearance => 'Оформление';

  @override
  String get publishingSettings => 'Публикация';

  @override
  String get addMialunaHashtag => 'Добавлять #mialuna';

  @override
  String get addMialunaHashtagNote =>
      'Добавлять официальный хештег к публичным постам и историям. Это можно выключить в любой момент.';

  @override
  String get themeLight => 'Светлая';

  @override
  String get themeDark => 'Тёмная';

  @override
  String get themeSystem => 'Системная';

  @override
  String get relays => 'Relay';

  @override
  String get relaysExplainSignedOut =>
      'Relay хранят и распространяют контент. Войди, чтобы автоматически использовать свой список (NIP-65).';

  @override
  String get relaysExplainSynced =>
      'Список синхронизирован с твоим профилем Nostr (NIP-65): каждое изменение публикуется и действует во всех твоих приложениях.';

  @override
  String get syncing => 'Синхронизация…';

  @override
  String get waitingFirstSync => 'Ждём первую синхронизацию';

  @override
  String get syncNow => 'Синхронизировать';

  @override
  String get addRelay => 'Добавить relay';

  @override
  String get restoreDefaultRelays => 'Вернуть relay по умолчанию';

  @override
  String get createYourList => 'Создать свой список';

  @override
  String peopleCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count человек',
      one: '1 человек',
    );
    return '$_temp0';
  }

  @override
  String get closeFriendsSettingsNote =>
      'Посты, истории и видео видны только им, с зашифрованными фото и видео.';

  @override
  String get mediaServersBlossom => 'Медиасерверы (Blossom)';

  @override
  String get mediaServersExplain =>
      'Фото и видео загружаются только на эти серверы, в показанном порядке: побеждает первый, который их примет. EXIF и местоположение удаляются перед загрузкой.';

  @override
  String get primary => 'Основной';

  @override
  String get makePrimary => 'Сделать основным';

  @override
  String get remove => 'Убрать';

  @override
  String get addServer => 'Добавить сервер';

  @override
  String get moderation => 'Модерация';

  @override
  String get moderationExplain =>
      'Заглушенные авторы и скрытые хештеги синхронизируются через NIP-51. Заблокированные авторы остаются только на этом устройстве.';

  @override
  String get mutedAuthors => 'Заглушенные авторы';

  @override
  String get noMutedAuthors => 'Нет заглушенных авторов';

  @override
  String get blockedAuthors => 'Заблокированные авторы';

  @override
  String get noBlockedAuthors => 'Нет заблокированных авторов';

  @override
  String get hiddenHashtags => 'Скрытые хештеги';

  @override
  String get noHiddenHashtags => 'Нет скрытых хештегов';

  @override
  String get hashtagToHide => '#hashtag для скрытия';

  @override
  String get storage => 'Хранилище';

  @override
  String get clearCache => 'Очистить кэш событий и черновики';

  @override
  String get cacheCleared => 'Кэш очищен';

  @override
  String get reviewIntro => 'Посмотреть введение';

  @override
  String get reviewIntroSubtitle =>
      'Что публично, что лично и где пределы близких друзей.';

  @override
  String noLightningWalletCopied(Object address) {
    return 'Кошелёк Lightning не найден: адрес скопирован ($address)';
  }

  @override
  String get about => 'О приложении';

  @override
  String aboutText(Object version) {
    return 'Mialuna $version — Твои моменты, под одной луной.\nОткрытый код (MIT). github.com/Lwb89dev/mialuna';
  }

  @override
  String get invalidRelayAddress => 'Неверный адрес: используй wss://…';

  @override
  String get invalidServerAddress => 'Неверный адрес: используй https://…';

  @override
  String get relayRead => 'Чтение';

  @override
  String get relayWrite => 'Запись';

  @override
  String get support => 'Поддержка';

  @override
  String get supportText =>
      'Mialuna бесплатна, без рекламы и не следит за тобой. Если нравится, можно отправить немного sats через Lightning Network.';

  @override
  String get donateWithLightning => 'Пожертвовать через Lightning';

  @override
  String get authorNoZaps => 'Этот автор не принимает zap';

  @override
  String get sendZap => 'Отправить zap ⚡';

  @override
  String get amountInSats => 'Сумма в sats';

  @override
  String minMaxSats(Object min, Object max) {
    return 'мин. $min – макс. $max';
  }

  @override
  String get zap => 'Zap';

  @override
  String get signInToZap => 'Войди, чтобы отправлять zap';

  @override
  String zapSent(Object sats) {
    return 'Zap на $sats sats отправлен ⚡';
  }

  @override
  String nwcPaymentFailed(Object error) {
    return 'Платёж NWC не удался: $error';
  }

  @override
  String get noLightningWallet => 'Кошелёк Lightning не найден';

  @override
  String storiesRailLabel(Object state) {
    return 'Истории, $state';
  }

  @override
  String get close => 'Закрыть';

  @override
  String hoursAgo(int hours) {
    return '$hours ч назад';
  }

  @override
  String daysAgo(int days) {
    return '$days дн. назад';
  }

  @override
  String get now => 'сейчас';

  @override
  String get youPrefix => 'Ты: ';

  @override
  String get storiesStateUnseen => 'новые';

  @override
  String get storiesStateSeen => 'просмотрено';

  @override
  String weekdayShort(String day) {
    String _temp0 = intl.Intl.selectLogic(day, {
      'mon': 'пн',
      'tue': 'вт',
      'wed': 'ср',
      'thu': 'чт',
      'fri': 'пт',
      'sat': 'сб',
      'sun': 'вс',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get sharedAMoment => 'Поделился моментом';

  @override
  String get blossomOtherError => 'ошибка';

  @override
  String get languageTitle => 'Язык';

  @override
  String get languageSystem => 'Системный';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageItalian => 'Italiano';

  @override
  String get cannotEditPhoto => 'Это фото здесь нельзя изменить.';

  @override
  String notificationsNew(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count новых уведомлений',
      one: '1 новое уведомление',
    );
    return '$_temp0';
  }

  @override
  String messagesUnread(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count непрочитанных сообщений',
      one: '1 непрочитанное сообщение',
    );
    return '$_temp0';
  }

  @override
  String get done => 'Готово';

  @override
  String get storyAddText => 'Добавить текст';

  @override
  String get storyEditText => 'Изменить текст';

  @override
  String get storyTextHint => 'Напиши что-нибудь… #hashtags нажимаются';

  @override
  String get storyTextsHelp =>
      'Нажми на картинку, чтобы написать. Перетащи, чтобы двигать, сведи пальцы, чтобы изменить размер и повернуть, нажми на текст, чтобы изменить его.';

  @override
  String storyTextsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count текстов',
      one: '1 текст',
      zero: 'Нет текста',
    );
    return '$_temp0';
  }

  @override
  String get storyFontClassic => 'Классический';

  @override
  String get storyFontBold => 'Жирный';

  @override
  String get storyFontSerif => 'Serif';

  @override
  String get storyFontMono => 'Mono';

  @override
  String get storyFontItalic => 'Курсив';

  @override
  String get storyTextBackground => 'Фон текста';

  @override
  String get storyTextColor => 'Цвет текста';

  @override
  String storyTextLimit(int max) {
    return 'Можно добавить не больше $max текстов.';
  }

  @override
  String get wotTitle => 'Сеть доверия';

  @override
  String get wotEnable => 'Сеть доверия всегда включена';

  @override
  String wotExplain(int min) {
    return 'Всегда включена. Обзор показывает только эту сеть: ты, люди, на которых ты подписан, и те, на кого подписаны хотя бы $min из них. Та же сеть скрывает комментарии, уведомления, личные посты и сообщения от всех остальных. Она считается на этом телефоне по публичным спискам подписок, когда ты впервые открываешь приложение; потом используется снова. Ничего не отправляется ни на какой сервер.';
  }

  @override
  String get wotRefresh => 'Обновить сеть сейчас';

  @override
  String get wotStatusIdle =>
      'Ещё не построена. Она строится, когда ты впервые открываешь приложение.';

  @override
  String get wotBuildingTitle => 'Собираем ленту Обзора';

  @override
  String get wotBuildingBody =>
      'Смотрим, на кого ещё подписаны люди из твоих подписок, и готовим Обзор.';

  @override
  String get wotDiscoverHint =>
      'Только твоя сеть доверия: люди, на которых ты подписан, и люди, на которых их подписано достаточно.';

  @override
  String get wotDiscoverSignIn =>
      'Обзор показывает твою сеть доверия. Войди, и в первый раз Mialuna посмотрит, на кого ты подписан, и соберёт эту ленту. Потом она открывается уже готовой.';

  @override
  String get wotDiscoverEmpty => 'Пока нет постов из твоей сети доверия.';

  @override
  String wotStatusDiscovering(int done, int total) {
    return 'Проверяем, на кого подписаны твои подписки… $done из $total';
  }

  @override
  String wotStatusComplete(int direct, int indirect, Object when) {
    return 'Твоя сеть: $direct людей, на которых ты подписан, плюс $indirect, на кого их подписано достаточно. Обновлено $when.';
  }

  @override
  String wotStatusFailed(Object reason) {
    return 'Не удалось посчитать твою сеть: $reason';
  }

  @override
  String get wotNoFollows => 'ты ещё ни на кого не подписан';

  @override
  String get messageRequests => 'Запросы на переписку';

  @override
  String messageRequestsSubtitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count переписок вне твоей сети доверия',
      one: '1 переписка вне твоей сети доверия',
    );
    return '$_temp0';
  }

  @override
  String get messageRequestsHint =>
      'От людей вне твоей сети доверия. Они не считаются непрочитанными. Ответь, чтобы перенести переписку во входящие.';

  @override
  String get storyViewsSetting => 'Показывать людям, что я смотрел их истории';

  @override
  String get storyViewsSettingExplain =>
      'Когда ты смотришь историю, автору уходит квитанция, зашифрованная так, что прочитать её может только он. В ней твоё имя рядом с его именем; relay не видят ничего. Если доставить не удаётся, она сохраняется и отправляется снова позже. Выключи, чтобы смотреть и никому не сообщать: ещё не отправленные квитанции сбрасываются (уже доставленную вернуть нельзя).';

  @override
  String storySeenBy(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Посмотрели $count человек',
      one: 'Посмотрел 1 человек',
      zero: 'Пока нет просмотров',
    );
    return '$_temp0';
  }

  @override
  String get storyViewsEmpty =>
      'Эту историю ещё никто не смотрел, или их квитанции до тебя не дошли.';

  @override
  String get storyViewsHint =>
      'Квитанцию присылают только те, кто это разрешил, поэтому реальное число может быть больше.';

  @override
  String get systemNotifications => 'Системные уведомления';

  @override
  String get systemNotificationsExplain =>
      'Показывать уведомление на телефоне, когда приходит что-то новое, пока Mialuna в фоне. Текст личных сообщений не показывается никогда, даже на экране блокировки. Android приостанавливает приложения, которые долго остаются в фоне, поэтому уведомления приходят, пока Mialuna ещё работает.';

  @override
  String get systemNotificationsBlocked =>
      'Уведомления для Mialuna выключены в настройках телефона.';

  @override
  String get systemNotificationsOpenSettings => 'Открыть настройки';

  @override
  String get systemNotificationsBattery =>
      'Android усыпляет приложения через несколько минут после выключения экрана, и уведомления останавливаются вместе с ними. Чтобы продолжать их получать, поставь расход батареи Mialuna на “Unrestricted”.';

  @override
  String get systemNotificationsBatteryAction => 'Открыть настройки батареи';

  @override
  String get newFollowersSetting => 'Показывать новых подписчиков';

  @override
  String get newFollowersSettingExplain =>
      'Новые подписчики появляются в Уведомлениях и на телефоне. Выключи, если подписками заваливают: лайки, комментарии и zap по-прежнему показываются.';

  @override
  String get systemNotificationMessage => 'отправил тебе личное сообщение';

  @override
  String get systemNotificationNewMessage => 'Новое личное сообщение';

  @override
  String get systemNotificationNew => 'Новое уведомление';

  @override
  String get notificationChannelSocial =>
      'Реакции, комментарии, zap и подписчики';

  @override
  String get notificationChannelMessages => 'Личные сообщения';

  @override
  String get zapInvoiceMismatch =>
      'Счёт не совпадает с выбранной суммой. Ничего не оплачено.';

  @override
  String get storyYourStory => 'Твоя история';

  @override
  String get storyNew => 'Новая история';

  @override
  String get storyAddSemantics => 'Добавить в твою историю';

  @override
  String storyOwnRailLabel(int count, Object state) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count историй',
      one: '1 история',
    );
    return 'Твоя история, $_temp0, $state';
  }

  @override
  String get storyTextSize => 'Размер текста';

  @override
  String get storyPickPrompt => 'Выбери фото или видео для своей истории';

  @override
  String get storyEditPhoto => 'Изменить фото';

  @override
  String get storyCaption => 'Подпись';

  @override
  String get storyDiscardTitle => 'Сбросить эту историю?';

  @override
  String get storyDiscard => 'Сбросить';

  @override
  String get storyShare => 'Поделиться';

  @override
  String get storyShared => 'История отправлена';

  @override
  String get deletePost => 'Удалить';

  @override
  String get deletePostTitle => 'Удалить этот пост?';

  @override
  String get deleteStoryTitle => 'Удалить эту историю?';

  @override
  String get deletePostBody =>
      'Mialuna попросит твои relay удалить его и медиасерверы удалить фото или видео. Тот relay, который проигнорирует запрос, или тот, кто уже сохранил копию, всё ещё может его иметь.';

  @override
  String get deletePrivateBody =>
      'Пост для близких друзей нельзя отозвать с relay. Mialuna скажет приложениям друзей убрать его и попросит медиасервер удалить зашифрованные файлы. Друг, который уже сохранил копию, всё ещё может её иметь.';

  @override
  String get deletingPost => 'Удаление…';

  @override
  String get postDeleted => 'Удалено.';

  @override
  String get postWasDeleted => 'Этот пост удалён.';

  @override
  String get deleteNotAllowed =>
      'Удалить может только аккаунт, который это опубликовал.';

  @override
  String deleteFailed(Object reason) {
    return 'Не удалось удалить: $reason';
  }

  @override
  String get deleteNoRelay =>
      'Ни один relay не принял запрос на удаление, поэтому он всё ещё в сети. Проверь соединение и попробуй ещё раз.';

  @override
  String deleteMediaLeft(Object servers) {
    return 'Медиа не удалось удалить с $servers.';
  }

  @override
  String get deleteMediaNotAuthorized =>
      'Твой подписант не разрешил удаление медиа, поэтому файлы всё ещё на медиасервере.';

  @override
  String deleteFriendsMissed(Object count) {
    return 'Не удалось сообщить $count из твоих близких друзей, поэтому пост может остаться на их телефонах.';
  }

  @override
  String get storyCleanupSetting => 'Удалять мои истории, когда они истекают';

  @override
  String get storyCleanupSettingExplain =>
      'Через 24 часа Mialuna просит твои relay и твои медиасерверы удалить твои истории, включая фото и видео. Сервер, который проигнорирует запрос, или тот, кто сохранил копию, всё ещё может их иметь.';

  @override
  String storyCleanupWaiting(Object count) {
    return 'Твой подписант должен одобрить каждую очистку, поэтому она ждёт, пока ты не попросишь. Истёкших историй в ожидании: $count.';
  }

  @override
  String get storyCleanupNow => 'Удалить сейчас';

  @override
  String get storyCleanupDone => 'Истёкшие истории удалены.';

  @override
  String get storyCleanupPartly =>
      'Некоторые пока удалить не удалось; Mialuna попробует снова.';
}
