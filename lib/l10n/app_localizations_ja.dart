// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get syncUpToDate => '最新の状態';

  @override
  String get syncFailed => '同期に失敗しました';

  @override
  String get relaysUpdatedFromProfile => 'プロフィールから Relays を更新しました（NIP-65）';

  @override
  String get relayListPublished => 'Relay リストを公開しました';

  @override
  String get mediaServersUpdatedFromProfile => 'プロフィールからメディアサーバーを更新しました';

  @override
  String get tabHome => 'Home';

  @override
  String get tabDiscover => '見つける';

  @override
  String get tabCreate => '作成';

  @override
  String get tabReels => 'Reels';

  @override
  String get tabProfile => 'プロフィール';

  @override
  String get signInToUploadMedia => 'メディアをアップロードするにはログインしてください。';

  @override
  String get noMediaServer => 'メディアサーバーが設定されていません。設定で追加してください。';

  @override
  String serverNoResponse(Object server) {
    return '$server: 応答なし';
  }

  @override
  String serverUnreachable(Object server, Object error) {
    return '$server: 到達できません（$error）';
  }

  @override
  String uploadRejected(Object reason) {
    return 'アップロードが拒否されました — $reason';
  }

  @override
  String noServerAcceptedFile(Object reasons) {
    return 'どのサーバーもファイルを受け付けませんでした — $reasons';
  }

  @override
  String get blossomInvalidResponse => '無効な応答';

  @override
  String get blossomInvalidFileUrl => '無効なファイルアドレス';

  @override
  String get blossomServerAlteredFile => 'サーバーがファイルを改変しました';

  @override
  String get blossomBadRequest => '無効なリクエスト';

  @override
  String get blossomUnauthorized => '認可が拒否されました';

  @override
  String get blossomPaymentRequired => '支払いが必要です';

  @override
  String get blossomForbidden => '許可されていません';

  @override
  String get blossomLengthRequired => 'サイズがありません';

  @override
  String get blossomTooLarge => 'ファイルが大きすぎます';

  @override
  String get blossomUnsupportedType => 'この形式は受け付けられません';

  @override
  String get blossomTooManyRequests => 'リクエストが多すぎます';

  @override
  String get blossomServerError => 'サーバーエラー';

  @override
  String get cipherInvalidKey => '無効な鍵';

  @override
  String get cipherTruncated => '暗号化ファイルが途切れています';

  @override
  String get cipherMismatch => 'ファイルが鍵と一致しません：改変または破損しています';

  @override
  String get sanitizeHeifNeedsAsync => 'HEIC/AVIF 形式：変換には sanitizeAsync が必要です';

  @override
  String get sanitizeWebmUnsupported =>
      'WebM/MKV 動画はサポートされていません：アップロード前にメタデータを削除できるよう、MP4 または MOV を使ってください。';

  @override
  String get sanitizeUnknownFormat =>
      '認識できないファイル形式：JPEG/PNG/WebP/GIF の写真、または MP4/MOV の動画。';

  @override
  String sanitizeLeftovers(Object items) {
    return 'メタデータをすべて削除できませんでした（$items）：ファイルはアップロードされていません。';
  }

  @override
  String sanitizeProcessingFailed(Object error) {
    return 'ファイルを処理できませんでした：$error';
  }

  @override
  String get sanitizeJpegInvalid => '無効な JPEG';

  @override
  String get sanitizeJpegTruncated => '途切れた JPEG';

  @override
  String get sanitizeJpegNoSize => '寸法のない JPEG';

  @override
  String get sanitizeJpegUndecodable => 'JPEG をデコードできません';

  @override
  String get sanitizePngTruncated => '途切れた PNG';

  @override
  String get sanitizePngInvalid => '無効な PNG';

  @override
  String get sanitizeGifInvalid => '無効な GIF';

  @override
  String get sanitizeGifTruncated => '途切れた GIF';

  @override
  String get sanitizeWebpTruncated => '途切れた WebP';

  @override
  String get sanitizeWebpInvalid => '無効な WebP';

  @override
  String get sanitizeMp4Invalid => '無効な MP4/MOV 動画';

  @override
  String get sanitizeConversionFailed => '変換に失敗しました';

  @override
  String get sanitizeHeifUnsupported =>
      'この形式（HEIC/AVIF）はこの端末では変換できません。JPEG または PNG の写真を選んでください。';

  @override
  String get privateMediaNotEncrypted => 'メディアが暗号化されていません';

  @override
  String serverReplied(Object status) {
    return 'サーバーの応答は $status です';
  }

  @override
  String get fileTooLarge => 'ファイルが大きすぎます';

  @override
  String get serverFileNotOriginal => 'サーバー上のファイルは元のファイルではありません';

  @override
  String get contentMismatch => '内容が一致しません';

  @override
  String get mediaUnreachable => 'メディアに到達できません';

  @override
  String get amberInvalidKey => 'Amber が無効な鍵を返しました';

  @override
  String get amberNoKey => 'Amber が鍵を返しませんでした';

  @override
  String get amberRequestRejected => 'Amber でリクエストが拒否されました';

  @override
  String get amberAndroidOnly => 'Amber は Android でのみ利用できます';

  @override
  String get amberEmptySignature => 'Amber が空の署名を返しました';

  @override
  String get amberSignRejected => 'Amber で署名が拒否されました';

  @override
  String get amberTimeout => 'Amber が時間内に応答しませんでした';

  @override
  String get amberEmptyResponse => 'Amber が空の応答を返しました';

  @override
  String get bunkerInvalidUrl => '無効な bunker URL';

  @override
  String get bunkerNoRelay => 'この bunker は relay を一つも列挙していません';

  @override
  String get bunkerWebAuth => 'この bunker はウェブ認可が必要です（auth_url はサポートされていません）';

  @override
  String get bunkerInvalidKey => 'この bunker は有効な鍵を返しませんでした';

  @override
  String get signerInvalidResponse => '署名ツールが無効な署名済みイベントを返しました';

  @override
  String get bunkerTimeout => 'Bunker がタイムアウトしました';

  @override
  String get nwcInvalidUri => '無効な NWC URI';

  @override
  String get nwcNoRelay => 'この NWC URI は relay を一つも列挙していません';

  @override
  String get nwcNoSecret => 'この NWC URI に有効なシークレットが含まれていません';

  @override
  String get nwcTimeout => 'ウォレットがタイムアウトしました';

  @override
  String get signerNoPrivateMessages => 'このログイン方法はプライベートメッセージに対応していません';

  @override
  String get zapNotSupported => 'このアドレスは Nostr zaps に対応していません';

  @override
  String zapAmountOutOfRange(Object min, Object max) {
    return '金額が範囲外です（$min–$max sats）';
  }

  @override
  String get commentNotSent => 'コメントは送信されませんでした。あとでもう一度お試しください。';

  @override
  String get comments => 'コメント';

  @override
  String get noCommentsYet => 'まだコメントはありません。';

  @override
  String get signInToComment => 'コメントするにはログインしてください。';

  @override
  String get addComment => 'コメントを追加…';

  @override
  String get signInToPublish => '公開するにはログインしてください。';

  @override
  String get addMediaFirst => '公開する前に、写真か動画を少なくとも1つ追加してください。';

  @override
  String get removingMetadata => 'メタデータを削除しています…';

  @override
  String uploadingProgress(Object current, Object total) {
    return '$current/$total 件をアップロードしています…';
  }

  @override
  String get creatingPreview => 'プレビューを作成しています…';

  @override
  String uploadFailed(Object error) {
    return 'アップロードに失敗しました：$error';
  }

  @override
  String get publishing => '公開しています…';

  @override
  String noRelayAcceptedPost(Object reason) {
    return 'どの relay$reason も投稿を受け付けませんでした。内容は下書きに残ります。';
  }

  @override
  String get privateNeedsKeySigner =>
      'このログイン方法は非公開コンテンツに対応していません。Amber、bunker、またはローカルの鍵を使ってください。';

  @override
  String get closeFriendsListEmptyAddSomeone => '親しい友達のリストは空です：誰かを追加してください。';

  @override
  String get fileOver100Mb =>
      'ファイルが 100 MB を超えています：親しい友達の上限です（端末上でファイル全体が暗号化されます）。';

  @override
  String get encryptingOnPhone => '端末上で暗号化しています…';

  @override
  String noServerAcceptedEncrypted(Object details) {
    return 'どのメディアサーバーも暗号化ファイルを受け付けませんでした。平文では公開されません。設定で、暗号化ファイルを受け付けるサーバーを追加してください（例：cdn.hzrd149.com）。$details';
  }

  @override
  String get sendingToFriends => '友達に送信しています…';

  @override
  String sendingToFriendsProgress(Object done, Object total) {
    return '友達に送信しています $done/$total…';
  }

  @override
  String noFriendReceivedPost(Object reason) {
    return 'どの友達も post$reason を受け取りませんでした。内容は下書きに残ります。';
  }

  @override
  String sentToCloseFriends(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '親しい友達 $count 人に送信しました 🔒',
      one: '親しい友達 1 人に送信しました 🔒',
    );
    return '$_temp0';
  }

  @override
  String sentToFriendsWithMisses(int delivered, Object missed) {
    String _temp0 = intl.Intl.pluralLogic(
      delivered,
      locale: localeName,
      other: '友達 $delivered 人に送信しました。',
      one: '友達 1 人に送信しました。',
    );
    return '$_temp0 $missed は受け取りませんでした（プライベートメッセージがオフです）。';
  }

  @override
  String get altText => '代替テキスト';

  @override
  String get altTextHint => '見えない人のために内容を説明…';

  @override
  String get cancel => 'キャンセル';

  @override
  String get save => '保存';

  @override
  String get momentPublished => 'モーメントを公開しました ✨';

  @override
  String get newMoment => '新しいモーメント';

  @override
  String get publish => '公開';

  @override
  String get guestMode => 'ゲストモード';

  @override
  String get signInToPostMoments => 'モーメントを公開するにはログインしてください。';

  @override
  String get signIn => 'ログイン';

  @override
  String get kindPhoto => '写真';

  @override
  String get kindVideo => '動画';

  @override
  String get kindReel => 'Reel';

  @override
  String get kindStory => 'ストーリー';

  @override
  String get storyExpiryNote =>
      'NIP-40 に従う relays では、ストーリーは 24 時間で期限切れになりますが、他の人は保存やアーカイブができます。';

  @override
  String get fromGallery => 'ギャラリーから';

  @override
  String get galleryLongPressVideo => 'ギャラリー（長押しで動画）';

  @override
  String get addVideo => '動画を追加';

  @override
  String get camera => 'カメラ';

  @override
  String get exifRemovedNote => '位置情報のメタデータ（EXIF）は自動的に削除されます。';

  @override
  String get writeCaption => 'キャプションを書く…';

  @override
  String get privatePostNote => '非公開の投稿：公開ハッシュタグはなく、検索では見つかりません。';

  @override
  String willPublishAs(Object caption) {
    return '次のように公開されます：「$caption」';
  }

  @override
  String get tapThumbnailForAlt => 'サムネイルをタップして代替テキストを追加します。';

  @override
  String get sensitiveContent => 'センシティブな内容';

  @override
  String get sensitiveContentNote => '投稿は警告の後ろに隠れます（NIP-36）。';

  @override
  String get uploadingMedia => 'メディアをアップロードしています…';

  @override
  String get audiencePublic => '公開';

  @override
  String get closeFriends => '親しい友達';

  @override
  String get signerCannotPublishCloseFriends =>
      'このログイン方法では親しい友達向けに公開できません：Amber、bunker、またはローカルの鍵を使ってください。';

  @override
  String get closeFriendsEmptyPrompt => 'リストは空です：この投稿を見られる人を追加してください。';

  @override
  String onlyYourCloseFriendsSee(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '親しい友達 $count 人だけが見られます。写真と動画はアップロード前に端末上で暗号化されます。',
      one: '親しい友達 1 人だけが見られます。写真と動画はアップロード前に端末上で暗号化されます。',
    );
    return '$_temp0';
  }

  @override
  String get addFriends => '友達を追加';

  @override
  String get manageList => 'リストを管理';

  @override
  String get edit => '編集';

  @override
  String get reset => 'リセット';

  @override
  String get apply => '適用';

  @override
  String get cropFree => '自由';

  @override
  String get cropOriginal => '元の比率';

  @override
  String get rotate => '回転';

  @override
  String get flip => '反転';

  @override
  String get brightness => '明るさ';

  @override
  String get contrast => 'コントラスト';

  @override
  String get saturation => '彩度';

  @override
  String postsByAuthor(Object author) {
    return '$author の投稿…';
  }

  @override
  String get searchHint => '人、ハッシュタグ、言葉を検索…';

  @override
  String get clear => 'クリア';

  @override
  String get recent => '最近';

  @override
  String get searchDependsOnRelays => '検索は設定済みの relays に依存します：結果は一部だけのことがあります。';

  @override
  String get recentPostsEverywhere => 'ネットワーク全体の最近の投稿です。フォローしていない人も含まれます。';

  @override
  String get noResultsOnRelays => '設定済みの relays に結果はありません。';

  @override
  String get noRecentPostsFromFollowed => 'フォローしている人の最近の投稿はありません。';

  @override
  String get noMomentsFound => 'relays でモーメントが見つかりません。接続を確認してください。';

  @override
  String get loadFailed => '読み込みに失敗しました';

  @override
  String get notifications => '通知';

  @override
  String get messages => 'メッセージ';

  @override
  String get homeEmptyFollowsNobody =>
      'フォローしている人の投稿がここに表示されます。\nまだ誰もフォローしていません：面白い人とプロフィールを見つけてください。';

  @override
  String get discoverPeople => '人を見つける';

  @override
  String get homeEmpty => 'まだモーメントはありません。\n引き下げて更新するか、最初の一枚を公開してください。';

  @override
  String get retry => 'もう一度';

  @override
  String get seenEverything => '今のところ全部見ました ✨';

  @override
  String get discoverMoreProfiles => 'もっとプロフィールを見つける';

  @override
  String get feedFollowing => 'フォロー中';

  @override
  String get signInToSeeFollowed => 'フォローしている人の投稿を見るにはログインしてください';

  @override
  String get videoPreview => '動画プレビュー';

  @override
  String get cannotOpenPrivateVideo => '非公開の動画を開けません';

  @override
  String get cannotPlayVideo => '動画を再生できません';

  @override
  String get pauseVideo => '動画を一時停止';

  @override
  String get playVideo => '動画を再生';

  @override
  String errorTapToRetry(Object error) {
    return '$error — タップしてもう一度';
  }

  @override
  String get soundOn => '音をオン';

  @override
  String get soundOff => '音をオフ';

  @override
  String get postImage => '投稿画像';

  @override
  String get imageUnavailable => '画像を利用できません';

  @override
  String errorTapToRetryNewline(Object message) {
    return '$message\nタップしてもう一度';
  }

  @override
  String get cannotOpenPrivateContent => 'この非公開コンテンツを開けません';

  @override
  String get privateImage => '非公開の画像';

  @override
  String get invalidImage => '無効な画像';

  @override
  String get more => 'その他';

  @override
  String get removeFromSaved => '保存済みから外す';

  @override
  String get copyLink => 'リンクをコピー';

  @override
  String get muteAuthor => '投稿者をミュート';

  @override
  String get blockAuthor => '投稿者をブロック';

  @override
  String get report => '報告';

  @override
  String get like => 'いいね';

  @override
  String get sendInMessage => 'メッセージで送る';

  @override
  String get zapOptional => 'Zap（任意）';

  @override
  String get closeFriendsOnlyNote => '親しい友達だけに表示されます。いいねと返信は投稿者だけに届きます。';

  @override
  String get likeFailed => 'いいねを送れませんでした';

  @override
  String get nostrLinkCopied => 'Nostr リンクをクリップボードにコピーしました';

  @override
  String get authorMuted => '投稿者をミュートしました';

  @override
  String get authorBlocked => '投稿者をブロックしました';

  @override
  String get reportSent => '報告を送信しました（NIP-56）';

  @override
  String get signInToReport => '報告するにはログインしてください';

  @override
  String minutesAgo(Object minutes) {
    return '$minutes 分前';
  }

  @override
  String get show => '表示';

  @override
  String get chatEmptyHint => '最初のメッセージを書いてください。\n暗号化されています：見えるのは二人だけです。';

  @override
  String get messageHint => 'メッセージ…';

  @override
  String get send => '送信';

  @override
  String get notSentSuffix => ' 未送信';

  @override
  String get contentUnavailable => '内容を利用できません（期限切れ、または relays で見つかりません）';

  @override
  String get signInToSendPrivateMessages => 'プライベートメッセージを送るにはログインしてください。';

  @override
  String get cannotMessageYourself => '自分自身には書けません。';

  @override
  String get recipientNoPrivateMessages => 'この人はまだプライベートメッセージをオンにしていません。';

  @override
  String noRecipientRelayAccepted(Object reason) {
    return '受信側の relay$reason がメッセージを受け付けませんでした。';
  }

  @override
  String sendFailed(Object error) {
    return '送信に失敗しました：$error';
  }

  @override
  String get signInToReadMessages => 'プライベートメッセージの閲覧と送信にはログインしてください。';

  @override
  String get signerNoPrivateMessagesLong =>
      'このログイン方法ではプライベートメッセージを使えません。Amber、bunker、またはローカルの鍵でログインしてください。';

  @override
  String get inboxEmpty =>
      '会話はありません。\n鉛筆をタップして誰かに書くか、各投稿の下の ✈ アイコンでモーメントを転送してください。';

  @override
  String get newMessage => '新しいメッセージ';

  @override
  String get privateMessagesEnabled => 'プライベートメッセージをオンにしました';

  @override
  String get enableMessagesFailed => 'オンにできませんでした。もう一度お試しください。';

  @override
  String get enablePrivateMessages => 'プライベートメッセージをオンにする';

  @override
  String enablePrivateMessagesExplain(Object count) {
    return 'メッセージを受け取るには、どの relays に届けるかを示す必要があります。$count 個の既定 relays を含む小さなリスト（NIP-17）が公開されます：あとから変更できます。メッセージは暗号化されたままです：relays には、誰が書いているかも本文も見えません。';
  }

  @override
  String get turnOn => 'オンにする';

  @override
  String get searchByNameOrUsername => '名前またはユーザー名で検索';

  @override
  String get searching => '検索しています…';

  @override
  String get noOneWithNameHint =>
      'この名前の人はいません。文字を減らすか、name@domain.com のようなアドレスを試してください。';

  @override
  String get sent => '送信済み';

  @override
  String sentToPeople(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 人に送信しました',
      one: '1 人に送信しました',
    );
    return '$_temp0';
  }

  @override
  String sentToPeopleWithFailure(int count, Object failure) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 人に送信しました。$failure',
      one: '1 人に送信しました。$failure',
    );
    return '$_temp0';
  }

  @override
  String get signerNoPrivateMessagesShort => 'このログイン方法ではプライベートメッセージを使えません。';

  @override
  String get followToStartOrSearch => '始めるには誰かをフォローするか、名前で検索してください。';

  @override
  String get addMessage => 'メッセージを追加…';

  @override
  String sendWithCount(Object count) {
    return '送信（$count）';
  }

  @override
  String get linkCopied => 'リンクをクリップボードにコピーしました';

  @override
  String get noNotifications => '今は通知はありません。';

  @override
  String get notificationsDependOnRelays => '通知は relays に依存します：不完全なことがあります。';

  @override
  String get reactedToYourMoment => 'あなたのモーメントにリアクションしました';

  @override
  String commentedText(Object text) {
    return 'コメントしました：$text';
  }

  @override
  String sentYouSats(Object sats, Object comment) {
    return 'あなたに $sats sats$comment を送りました';
  }

  @override
  String get sentYouZap => 'あなたに zap を送りました';

  @override
  String get startedFollowingYou => 'あなたをフォローし始めました';

  @override
  String get amberNotFound => 'Amber が見つかりません';

  @override
  String get amberExplain =>
      'Amber は秘密鍵を Mialuna の外に保管する Nostr の署名ツールです。インストールしてもう一度お試しください。';

  @override
  String get downloadFromFdroid => 'F-Droid からダウンロード';

  @override
  String get continueWithAmber => 'Amber で続ける';

  @override
  String get amberRecommended => 'おすすめ：秘密鍵は Amber で安全に保管されます。';

  @override
  String get amberNotDetected => 'Amber が検出されません：おすすめのログインのためにインストールしてください。';

  @override
  String get exploreWithoutAccount => 'アカウントなしで見てみる';

  @override
  String get remoteBunker => 'リモート bunker（NIP-46）';

  @override
  String get invalidBunkerUrlDot => '無効な bunker URL。';

  @override
  String get connectBunker => 'bunker を接続';

  @override
  String get advancedNsec => '高度なログイン（nsec）';

  @override
  String get nsecWarning =>
      '警告：秘密鍵の貼り付けは危険です。誰とも共有しないでください。Android では Amber を優先してください。';

  @override
  String get invalidNsec => '無効な nsec 鍵です。';

  @override
  String get signInWithNsec => 'nsec でログイン';

  @override
  String get tagline => 'あなたのモーメントを、同じ月の下で。';

  @override
  String get skip => 'スキップ';

  @override
  String get permissionsAndWallet => '権限とウォレット';

  @override
  String get permissionsExplain => '公開と通知の受信だけに使います。システムの設定でいつでも変更できます。';

  @override
  String get photosAndVideos => '写真と動画';

  @override
  String get toUploadYourMoments => 'モーメントをアップロードするため';

  @override
  String get allow => '許可';

  @override
  String get reactionsCommentsZaps => 'リアクション、コメント、zaps';

  @override
  String get lightningWalletOptional => 'Lightning ウォレット（任意）';

  @override
  String get nwcExplain =>
      'Nostr Wallet Connect のウォレットを接続すると、アプリを離れずに zaps を送れます。';

  @override
  String get walletConnected => 'ウォレットを接続しました';

  @override
  String get disconnect => '切断';

  @override
  String get connectWallet => 'ウォレットを接続';

  @override
  String get getStarted => 'はじめる';

  @override
  String get welcome1 =>
      'Mialuna はビジュアルなソーシャルネットワークです：写真、動画、Reels、ストーリー — テキストだけの投稿はありません。';

  @override
  String get welcome2 =>
      'Nostr というオープンなプロトコルで動きます：あなたの身元は自分が持つ鍵であり、企業が取り上げられるアカウントではありません。広告もトラッカーも中央サーバーもありません。';

  @override
  String get welcome3 => '同じオープンな言葉を話すどのアプリからでも、世界中の人とあなたの光を分かち合いましょう。';

  @override
  String onboardingWot(int min) {
    return '信頼ネットワークは常にオンです。初めて Mialuna を開くと、フォローしている人を読み取り、そのネットワークから見つけるフィードを作ります：あなた、フォローしている人、そしてそのうち少なくとも $min 人がフォローしている人です。次にアプリを開くときは、そのフィードはすでにあります。';
  }

  @override
  String get publicAndPrivate => '公開と非公開';

  @override
  String get publicAndPrivateIntro =>
      'Mialuna はオープンなネットワーク Nostr の上に作られています。公開したものは公開です：投稿、写真、動画は、リンクを持つ誰からでも、Mialuna の外からでも見えます。';

  @override
  String get closeFriendsExplain1 =>
      'このリストの人だけが、あなたの「親しい友達」の投稿、ストーリー、動画を受け取ります。リストは投稿の中にあります。毎回選ぶ必要はありません。';

  @override
  String get closeFriendsExplain2 =>
      '写真と動画はアップロード前に端末上で暗号化されます。ファイルサーバー（Blossom）は自分では何も暗号化しません：だから Mialuna が行い、サーバーが見るのは読めないデータだけです。ファイルのアドレスを見つけても開けません。';

  @override
  String get closeFriendsExplain3 =>
      '絶対の保証ではありません：投稿を受け取った人はスクリーンショットを撮れます。友達を外しても、それ以降の投稿にだけ効きます。';

  @override
  String get closeFriendsExplain4 =>
      '友達は全員、プライベートメッセージをオンにした Mialuna を使う必要があります。他の Nostr クライアントはこれらの投稿を表示しません。';

  @override
  String get closeFriendsExplain5 => '公開の投稿は公開のままです：ファイルはリンクを持つ誰からでも見えます。';

  @override
  String get closeFriendsExplain6 =>
      'どのサーバーも暗号化ファイルを受け付けない場合、投稿は公開されません：決して平文では公開しません。';

  @override
  String get addToCloseFriends => '親しい友達に追加';

  @override
  String maxFriendsReached(Object max, Object added) {
    return '友達の上限は $max 人です：$added 人追加しました。';
  }

  @override
  String get add => '追加';

  @override
  String get signInToCreateList => 'リストを作るにはログインしてください。';

  @override
  String get signerNoCloseFriends =>
      'このログイン方法では親しい友達を使えません。Amber、bunker、またはローカルの鍵でログインしてください。';

  @override
  String peopleOfMax(Object count, Object max) {
    return '$count / $max 人';
  }

  @override
  String get noOneYet => 'まだ誰もいません。';

  @override
  String get addPeople => '人を追加';

  @override
  String get friendNoPrivateMessagesWarning =>
      'プライベートメッセージをオンにしていないため、投稿を受け取れません';

  @override
  String get removeFromList => 'リストから外す';

  @override
  String get noOneWithThisName => 'この名前の人はいません。';

  @override
  String get signInToSendPrivateContent => '非公開コンテンツを送るにはログインしてください。';

  @override
  String get reasonNoPrivateMessages => 'プライベートメッセージをオンにしていません';

  @override
  String get reasonNoRelayAnswered => 'どの relay も応答しませんでした';

  @override
  String get profileUpdated => 'プロフィールを更新しました';

  @override
  String get noRelayAcceptedRetry => 'どの relay も受け付けませんでした。あとでもう一度お試しください。';

  @override
  String get editProfile => 'プロフィールを編集';

  @override
  String get fieldName => '名前';

  @override
  String get fieldBio => '自己紹介';

  @override
  String get fieldAvatarUrl => 'アバター URL';

  @override
  String get fieldNip05 => 'NIP-05（例：you@example.com）';

  @override
  String get browsingAsGuest => 'ゲストとして閲覧しています';

  @override
  String get signInToInteract => '公開、フォロー、やり取りをするにはログインしてください。';

  @override
  String get settings => '設定';

  @override
  String get signOut => 'ログアウト';

  @override
  String get npubCopied => 'npub をコピーしました';

  @override
  String get copyNpub => 'npub をコピー';

  @override
  String get mute => 'ミュート';

  @override
  String get block => 'ブロック';

  @override
  String get posts => '投稿';

  @override
  String get saved => '保存済み';

  @override
  String get nothingPublishedYet => 'まだ何も公開していません。';

  @override
  String get noPostsOnRelays => 'relays で投稿が見つかりません。';

  @override
  String get noReelsPublished => '公開された reels はありません。';

  @override
  String get noReelsOnRelays => 'relays で reels が見つかりません。';

  @override
  String get noSavedPosts => '保存した投稿はありません。';

  @override
  String get followingButton => 'フォロー中';

  @override
  String get follow => 'フォロー';

  @override
  String get messageButton => 'メッセージ';

  @override
  String get loginLocalKey => 'ローカルの鍵';

  @override
  String get loginGuest => 'ゲスト';

  @override
  String get followUpdateFailed => '今はフォローを更新できませんでした。もう一度お試しください。';

  @override
  String get noReelsComeBack => 'relays で reels が見つかりません。\nまたすぐ来てください！';

  @override
  String get followUpdateFailedShort => '今はフォローを更新できませんでした';

  @override
  String get needOneReadRelay => '読み取り用の relay が少なくとも1つ必要です。';

  @override
  String get listSavedLocally => 'リストはこの端末に保存され、公開されていません。';

  @override
  String get noRelayAcceptedList => 'どの relay もリストを受け付けませんでした：あとで再試行します。';

  @override
  String relayListPublishedTo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Relay リストを $count 個の relays に公開しました',
      one: 'Relay リストを 1 個の relay に公開しました',
    );
    return '$_temp0';
  }

  @override
  String get mediaServersUpdated => 'メディアサーバーを更新しました';

  @override
  String get appearance => '外観';

  @override
  String get publishingSettings => '公開';

  @override
  String get addMialunaHashtag => '#mialuna を追加';

  @override
  String get addMialunaHashtagNote =>
      '公式のハッシュタグを公開の投稿とストーリーに追加します。いつでもオフにできます。';

  @override
  String get themeLight => 'ライト';

  @override
  String get themeDark => 'ダーク';

  @override
  String get themeSystem => 'システム';

  @override
  String get relays => 'Relays';

  @override
  String get relaysExplainSignedOut =>
      'Relays は内容を保存して配信します。ログインすると、自分のリストを自動で使います（NIP-65）。';

  @override
  String get relaysExplainSynced =>
      'リストはあなたの Nostr プロフィールと同期されます（NIP-65）：変更は毎回公開され、すべてのアプリに適用されます。';

  @override
  String get syncing => '同期しています…';

  @override
  String get waitingFirstSync => '最初の同期を待っています';

  @override
  String get syncNow => '今すぐ同期';

  @override
  String get addRelay => 'relay を追加';

  @override
  String get restoreDefaultRelays => '既定の relays を復元';

  @override
  String get createYourList => '自分のリストを作る';

  @override
  String peopleCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 人',
      one: '1 人',
    );
    return '$_temp0';
  }

  @override
  String get closeFriendsSettingsNote => '投稿、ストーリー、動画は彼らだけに表示され、写真と動画は暗号化されます。';

  @override
  String get mediaServersBlossom => 'メディアサーバー（Blossom）';

  @override
  String get mediaServersExplain =>
      '写真と動画は、表示されている順にこれらのサーバーだけへアップロードされます：最初に受け付けたものが使われます。EXIF と位置情報はアップロード前に削除されます。';

  @override
  String get primary => '優先';

  @override
  String get makePrimary => '優先にする';

  @override
  String get remove => '削除';

  @override
  String get addServer => 'サーバーを追加';

  @override
  String get moderation => 'モデレーション';

  @override
  String get moderationExplain =>
      'ミュートした投稿者と非表示のハッシュタグは NIP-51 で同期されます。ブロックした投稿者はこの端末だけに残ります。';

  @override
  String get mutedAuthors => 'ミュートした投稿者';

  @override
  String get noMutedAuthors => 'ミュートした投稿者はいません';

  @override
  String get blockedAuthors => 'ブロックした投稿者';

  @override
  String get noBlockedAuthors => 'ブロックした投稿者はいません';

  @override
  String get hiddenHashtags => '非表示のハッシュタグ';

  @override
  String get noHiddenHashtags => '非表示のハッシュタグはありません';

  @override
  String get hashtagToHide => '非表示にする #hashtag';

  @override
  String get storage => 'ストレージ';

  @override
  String get clearCache => 'イベントのキャッシュと下書きを消去';

  @override
  String get cacheCleared => 'キャッシュを消去しました';

  @override
  String get reviewIntro => '紹介を見直す';

  @override
  String get reviewIntroSubtitle => '何が公開で、何が非公開か、そして親しい友達の限界。';

  @override
  String noLightningWalletCopied(Object address) {
    return 'Lightning ウォレットが見つかりません：アドレスをコピーしました（$address）';
  }

  @override
  String get about => 'このアプリについて';

  @override
  String aboutText(Object version) {
    return 'Mialuna $version — あなたのモーメントを、同じ月の下で。\nオープンソース（MIT）。github.com/Lwb89dev/mialuna';
  }

  @override
  String get invalidRelayAddress => '無効なアドレス：wss://… を使ってください';

  @override
  String get invalidServerAddress => '無効なアドレス：https://… を使ってください';

  @override
  String get relayRead => '読み取り';

  @override
  String get relayWrite => '書き込み';

  @override
  String get support => '支援';

  @override
  String get supportText =>
      'Mialuna は無料で、広告もなく、あなたを追跡しません。気に入ったら、Lightning Network で少し sats を送れます。';

  @override
  String get donateWithLightning => 'Lightning で寄付';

  @override
  String get authorNoZaps => 'この投稿者は zaps を受け付けていません';

  @override
  String get sendZap => 'zap を送る ⚡';

  @override
  String get amountInSats => '金額（sats）';

  @override
  String minMaxSats(Object min, Object max) {
    return '最小 $min – 最大 $max';
  }

  @override
  String get zap => 'Zap';

  @override
  String get signInToZap => 'zaps を送るにはログインしてください';

  @override
  String zapSent(Object sats) {
    return '$sats sats の Zap を送信しました ⚡';
  }

  @override
  String nwcPaymentFailed(Object error) {
    return 'NWC の支払いに失敗しました：$error';
  }

  @override
  String get noLightningWallet => 'Lightning ウォレットが見つかりません';

  @override
  String storiesRailLabel(Object state) {
    return 'ストーリー、$state';
  }

  @override
  String get close => '閉じる';

  @override
  String hoursAgo(int hours) {
    return '$hours 時間前';
  }

  @override
  String daysAgo(int days) {
    return '$days 日前';
  }

  @override
  String get now => '今';

  @override
  String get youPrefix => 'あなた: ';

  @override
  String get storiesStateUnseen => '新着';

  @override
  String get storiesStateSeen => '閲覧済み';

  @override
  String weekdayShort(String day) {
    String _temp0 = intl.Intl.selectLogic(day, {
      'mon': '月',
      'tue': '火',
      'wed': '水',
      'thu': '木',
      'fri': '金',
      'sat': '土',
      'sun': '日',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get sharedAMoment => 'モーメントをシェアしました';

  @override
  String get blossomOtherError => 'エラー';

  @override
  String get languageTitle => '言語';

  @override
  String get languageSystem => 'システム';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageItalian => 'Italiano';

  @override
  String get cannotEditPhoto => 'この写真はここでは編集できません。';

  @override
  String notificationsNew(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '新しい通知 $count 件',
      one: '新しい通知 1 件',
    );
    return '$_temp0';
  }

  @override
  String messagesUnread(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '未読メッセージ $count 件',
      one: '未読メッセージ 1 件',
    );
    return '$_temp0';
  }

  @override
  String get done => '完了';

  @override
  String get storyAddText => 'テキストを追加';

  @override
  String get storyEditText => 'テキストを編集';

  @override
  String get storyTextHint => '何か書いて… #hashtags はタップできます';

  @override
  String get storyTextsHelp =>
      '画像をタップして書きます。ドラッグで移動、ピンチでサイズ変更と回転、テキストをタップして編集します。';

  @override
  String storyTextsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'テキスト $count 件',
      one: 'テキスト 1 件',
      zero: 'テキストなし',
    );
    return '$_temp0';
  }

  @override
  String get storyFontClassic => 'クラシック';

  @override
  String get storyFontBold => '太字';

  @override
  String get storyFontSerif => 'Serif';

  @override
  String get storyFontMono => 'Mono';

  @override
  String get storyFontItalic => 'イタリック';

  @override
  String get storyTextBackground => 'テキストの背景';

  @override
  String get storyTextColor => 'テキストの色';

  @override
  String storyTextLimit(int max) {
    return 'テキストは最大 $max 件まで追加できます。';
  }

  @override
  String get wotTitle => '信頼ネットワーク';

  @override
  String get wotEnable => '信頼ネットワークは常にオンです';

  @override
  String wotExplain(int min) {
    return '常にオンです。見つけるは、このネットワークだけを表示します：あなた、フォローしている人、そしてそのうち少なくとも $min 人にフォローされている人です。同じネットワークにより、それ以外の人からのコメント、通知、非公開の投稿、メッセージは隠されます。アプリを初めて開いたとき、公開のフォローリストからこの端末上で算出されます。次からはそれを再利用します。どのサーバーにも何も送られません。';
  }

  @override
  String get wotRefresh => 'ネットワークを今すぐ更新';

  @override
  String get wotStatusIdle => 'まだ作られていません。アプリを初めて開いたときに作られます。';

  @override
  String get wotBuildingTitle => '見つけるフィードを作成しています';

  @override
  String get wotBuildingBody => 'フォローしている人が誰をフォローしているかを読み、見つけるを準備しています。';

  @override
  String get wotDiscoverHint =>
      'あなたの信頼ネットワークだけ：フォローしている人と、そのうち十分な人数がフォローしている人。';

  @override
  String get wotDiscoverSignIn =>
      '見つけるはあなたの信頼ネットワークを表示します。ログインすると、初回は Mialuna がフォローしている人を読み取り、このフィードを作ります。その後の起動ではそれを再利用します。';

  @override
  String get wotDiscoverEmpty => '信頼ネットワークからの投稿はまだありません。';

  @override
  String wotStatusDiscovering(int done, int total) {
    return 'フォロー先が誰をフォローしているか確認しています… $done / $total';
  }

  @override
  String wotStatusComplete(int direct, int indirect, Object when) {
    return 'あなたのネットワーク：フォローしている $direct 人に加え、そのうち十分な人数にフォローされている $indirect 人。更新：$when。';
  }

  @override
  String wotStatusFailed(Object reason) {
    return 'ネットワークを算出できませんでした：$reason';
  }

  @override
  String get wotNoFollows => 'まだ誰もフォローしていません';

  @override
  String get messageRequests => 'メッセージリクエスト';

  @override
  String messageRequestsSubtitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '信頼ネットワークの外からの会話 $count 件',
      one: '信頼ネットワークの外からの会話 1 件',
    );
    return '$_temp0';
  }

  @override
  String get messageRequestsHint =>
      '信頼ネットワークの外の人からです。未読には数えません。返信すると、会話が受信箱に移ります。';

  @override
  String get storyViewsSetting => 'ストーリーを見たことを相手に知らせる';

  @override
  String get storyViewsSettingExplain =>
      'ストーリーを見ると、作者に受領確認が送られます。暗号化され、読めるのは本人だけです。あなたの名前が相手の隣に並びます。relays には何も見えません。届けられないときは保管し、あとで再試行します。オフにすると、誰にも知らせずに見られます：まだ送っていない受領確認は破棄されます（すでに届いたものは取り消せません）。';

  @override
  String storySeenBy(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 人が見ました',
      one: '1 人が見ました',
      zero: 'まだ閲覧はありません',
    );
    return '$_temp0';
  }

  @override
  String get storyViewsEmpty => 'このストーリーをまだ誰も見ていないか、受領確認が届いていません。';

  @override
  String get storyViewsHint => '許可した人だけが受領確認を送るため、実際の人数はもっと多いことがあります。';

  @override
  String get systemNotifications => 'システムの通知';

  @override
  String get systemNotificationsExplain =>
      'Mialuna がバックグラウンドのときに新しいものがあると、端末に通知を出します。プライベートメッセージは本文を出さず、ロック画面でも出しません。Android は長くバックグラウンドにあるアプリを一時停止するため、通知は Mialuna がまだ動いている間に届きます。';

  @override
  String get systemNotificationsBlocked => '端末の設定で Mialuna の通知がオフになっています。';

  @override
  String get systemNotificationsOpenSettings => '設定を開く';

  @override
  String get systemNotificationsBattery =>
      '画面が消えて数分たつと、Android はアプリをスリープさせ、通知も一緒に止まります。受け取り続けるには、Mialuna の電池使用量を“制限なし”にしてください。';

  @override
  String get systemNotificationsBatteryAction => '電池設定を開く';

  @override
  String get newFollowersSetting => '新しいフォロワーを表示';

  @override
  String get newFollowersSettingExplain =>
      '新しいフォロワーは通知と端末に表示されます。フォローで埋め尽くされるときはオフにしてください：いいね、コメント、zaps は表示され続けます。';

  @override
  String get systemNotificationMessage => 'プライベートメッセージを送りました';

  @override
  String get systemNotificationNewMessage => '新しいプライベートメッセージ';

  @override
  String get systemNotificationNew => '新しい通知';

  @override
  String get notificationChannelSocial => 'リアクション、コメント、zaps、フォロワー';

  @override
  String get notificationChannelMessages => 'プライベートメッセージ';

  @override
  String get zapInvoiceMismatch => '請求書が選んだ金額と一致しません。支払いは行われていません。';

  @override
  String get storyYourStory => 'あなたのストーリー';

  @override
  String get storyNew => '新しいストーリー';

  @override
  String get storyAddSemantics => 'ストーリーに追加';

  @override
  String storyOwnRailLabel(int count, Object state) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ストーリー $count 件',
      one: 'ストーリー 1 件',
    );
    return 'あなたのストーリー、$_temp0、$state';
  }

  @override
  String get storyTextSize => '文字サイズ';

  @override
  String get storyPickPrompt => 'ストーリー用の写真または動画を選んでください';

  @override
  String get storyEditPhoto => '写真を編集';

  @override
  String get storyCaption => 'キャプション';

  @override
  String get storyDiscardTitle => 'このストーリーを破棄しますか？';

  @override
  String get storyDiscard => '破棄';

  @override
  String get storyShare => 'シェア';

  @override
  String get storyShared => 'ストーリーをシェアしました';

  @override
  String get deletePost => '削除';

  @override
  String get deletePostTitle => 'この投稿を削除しますか？';

  @override
  String get deleteStoryTitle => 'このストーリーを削除しますか？';

  @override
  String get deletePostBody =>
      'Mialuna は relays に削除を依頼し、メディアサーバーに写真または動画の削除を依頼します。リクエストを無視する relay や、すでにコピーを保存した人の手元には残ることがあります。';

  @override
  String get deletePrivateBody =>
      '親しい友達向けの投稿は relays から取り消せません。Mialuna は友達のアプリに削除を伝え、メディアサーバーに暗号化ファイルの削除を依頼します。すでにコピーを保存した友達の手元には残ることがあります。';

  @override
  String get deletingPost => '削除しています…';

  @override
  String get postDeleted => '削除しました。';

  @override
  String get postWasDeleted => 'この投稿は削除されました。';

  @override
  String get deleteNotAllowed => 'これを公開したアカウントだけが削除できます。';

  @override
  String deleteFailed(Object reason) {
    return '削除できませんでした：$reason';
  }

  @override
  String get deleteNoRelay =>
      'どの relay も削除リクエストを受け付けなかったため、まだオンラインです。接続を確認してもう一度お試しください。';

  @override
  String deleteMediaLeft(Object servers) {
    return '$servers からメディアを削除できませんでした。';
  }

  @override
  String get deleteMediaNotAuthorized =>
      '署名ツールがメディアの削除を認可しなかったため、ファイルはメディアサーバーに残っています。';

  @override
  String deleteFriendsMissed(Object count) {
    return '親しい友達 $count 人に伝えられなかったため、相手の端末に残ることがあります。';
  }

  @override
  String get storyCleanupSetting => '期限が切れたら自分のストーリーを削除する';

  @override
  String get storyCleanupSettingExplain =>
      '24 時間後、Mialuna は relays とメディアサーバーに、写真と動画を含むストーリーの削除を依頼します。リクエストを無視するサーバーや、コピーを残した人の手元には残ることがあります。';

  @override
  String storyCleanupWaiting(Object count) {
    return '署名ツールが毎回の整理を承認する必要があるため、あなたが依頼するまで待ちます。削除待ちの期限切れストーリー：$count。';
  }

  @override
  String get storyCleanupNow => '今すぐ削除';

  @override
  String get storyCleanupDone => '期限切れのストーリーを削除しました。';

  @override
  String get storyCleanupPartly => 'まだ削除できないものがあります。Mialuna が再試行します。';
}
