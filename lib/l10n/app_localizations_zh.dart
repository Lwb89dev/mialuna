// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get syncUpToDate => '已是最新';

  @override
  String get syncFailed => '同步失败';

  @override
  String get relaysUpdatedFromProfile => '已根据你的资料更新 Relays（NIP-65）';

  @override
  String get relayListPublished => 'Relay 列表已发布';

  @override
  String get mediaServersUpdatedFromProfile => '已根据你的资料更新媒体服务器';

  @override
  String get tabHome => 'Home';

  @override
  String get tabDiscover => '发现';

  @override
  String get tabCreate => '创建';

  @override
  String get tabReels => 'Reels';

  @override
  String get tabProfile => '资料';

  @override
  String get signInToUploadMedia => '登录后才能上传媒体。';

  @override
  String get noMediaServer => '还没有配置媒体服务器。请在设置里添加一个。';

  @override
  String serverNoResponse(Object server) {
    return '$server：无响应';
  }

  @override
  String serverUnreachable(Object server, Object error) {
    return '$server：无法连接（$error）';
  }

  @override
  String uploadRejected(Object reason) {
    return '上传被拒绝 — $reason';
  }

  @override
  String noServerAcceptedFile(Object reasons) {
    return '没有服务器接受该文件 — $reasons';
  }

  @override
  String get blossomInvalidResponse => '无效响应';

  @override
  String get blossomInvalidFileUrl => '无效的文件地址';

  @override
  String get blossomServerAlteredFile => '服务器修改了文件';

  @override
  String get blossomBadRequest => '无效请求';

  @override
  String get blossomUnauthorized => '授权被拒绝';

  @override
  String get blossomPaymentRequired => '需要付款';

  @override
  String get blossomForbidden => '不允许';

  @override
  String get blossomLengthRequired => '缺少大小';

  @override
  String get blossomTooLarge => '文件过大';

  @override
  String get blossomUnsupportedType => '不接受此格式';

  @override
  String get blossomTooManyRequests => '请求过多';

  @override
  String get blossomServerError => '服务器错误';

  @override
  String get cipherInvalidKey => '无效的密钥';

  @override
  String get cipherTruncated => '加密文件不完整';

  @override
  String get cipherMismatch => '文件与密钥不符：已被修改或损坏';

  @override
  String get sanitizeHeifNeedsAsync => 'HEIC/AVIF 格式：转换需要 sanitizeAsync';

  @override
  String get sanitizeWebmUnsupported =>
      '不支持 WebM/MKV 视频：请使用 MP4 或 MOV，以便上传前去掉元数据。';

  @override
  String get sanitizeUnknownFormat =>
      '无法识别的文件格式：JPEG/PNG/WebP/GIF 照片或 MP4/MOV 视频。';

  @override
  String sanitizeLeftovers(Object items) {
    return '无法去掉全部元数据（$items）：文件未上传。';
  }

  @override
  String sanitizeProcessingFailed(Object error) {
    return '无法处理该文件：$error';
  }

  @override
  String get sanitizeJpegInvalid => '无效的 JPEG';

  @override
  String get sanitizeJpegTruncated => '不完整的 JPEG';

  @override
  String get sanitizeJpegNoSize => 'JPEG 没有尺寸';

  @override
  String get sanitizeJpegUndecodable => 'JPEG 无法解码';

  @override
  String get sanitizePngTruncated => '不完整的 PNG';

  @override
  String get sanitizePngInvalid => '无效的 PNG';

  @override
  String get sanitizeGifInvalid => '无效的 GIF';

  @override
  String get sanitizeGifTruncated => '不完整的 GIF';

  @override
  String get sanitizeWebpTruncated => '不完整的 WebP';

  @override
  String get sanitizeWebpInvalid => '无效的 WebP';

  @override
  String get sanitizeMp4Invalid => '无效的 MP4/MOV 视频';

  @override
  String get sanitizeConversionFailed => '转换失败';

  @override
  String get sanitizeHeifUnsupported =>
      '此设备无法转换该格式（HEIC/AVIF）。请改用 JPEG 或 PNG 照片。';

  @override
  String get privateMediaNotEncrypted => '媒体未加密';

  @override
  String serverReplied(Object status) {
    return '服务器回复了 $status';
  }

  @override
  String get fileTooLarge => '文件过大';

  @override
  String get serverFileNotOriginal => '服务器上的文件不是原件';

  @override
  String get contentMismatch => '内容不一致';

  @override
  String get mediaUnreachable => '媒体无法访问';

  @override
  String get amberInvalidKey => 'Amber 返回了无效的密钥';

  @override
  String get amberNoKey => 'Amber 没有返回密钥';

  @override
  String get amberRequestRejected => '请求在 Amber 中被拒绝';

  @override
  String get amberAndroidOnly => 'Amber 仅在 Android 上可用';

  @override
  String get amberEmptySignature => 'Amber 返回了空签名';

  @override
  String get amberSignRejected => '签名在 Amber 中被拒绝';

  @override
  String get amberTimeout => 'Amber 没有及时响应';

  @override
  String get amberEmptyResponse => 'Amber 返回了空响应';

  @override
  String get bunkerInvalidUrl => '无效的 bunker URL';

  @override
  String get bunkerNoRelay => '该 bunker 没有列出任何 relay';

  @override
  String get bunkerWebAuth => '该 bunker 需要网页授权（不支持 auth_url）';

  @override
  String get bunkerInvalidKey => '该 bunker 没有返回有效密钥';

  @override
  String get signerInvalidResponse => '签名器返回了无效的已签名事件';

  @override
  String get bunkerTimeout => 'Bunker 超时';

  @override
  String get nwcInvalidUri => '无效的 NWC URI';

  @override
  String get nwcNoRelay => '该 NWC URI 没有列出任何 relay';

  @override
  String get nwcNoSecret => '该 NWC URI 没有包含有效密钥';

  @override
  String get nwcTimeout => '钱包超时';

  @override
  String get signerNoPrivateMessages => '此登录方式不支持私信';

  @override
  String get zapNotSupported => '该地址不支持 Nostr zaps';

  @override
  String zapAmountOutOfRange(Object min, Object max) {
    return '金额超出范围（$min–$max sats）';
  }

  @override
  String get commentNotSent => '评论未发送。请稍后再试。';

  @override
  String get comments => '评论';

  @override
  String get noCommentsYet => '还没有评论。';

  @override
  String get signInToComment => '登录后才能评论。';

  @override
  String get addComment => '添加评论…';

  @override
  String get signInToPublish => '登录后才能发布。';

  @override
  String get addMediaFirst => '发布前请至少添加一张照片或一段视频。';

  @override
  String get removingMetadata => '正在去掉元数据…';

  @override
  String uploadingProgress(Object current, Object total) {
    return '正在上传 $current/$total…';
  }

  @override
  String get creatingPreview => '正在创建预览…';

  @override
  String uploadFailed(Object error) {
    return '上传失败：$error';
  }

  @override
  String get publishing => '正在发布…';

  @override
  String noRelayAcceptedPost(Object reason) {
    return '没有 relay$reason 接受这条帖子。内容仍留在草稿里。';
  }

  @override
  String get privateNeedsKeySigner => '此登录方式不支持私密内容。请使用 Amber、bunker 或本地密钥。';

  @override
  String get closeFriendsListEmptyAddSomeone => '你的密友列表是空的：请添加一个人。';

  @override
  String get fileOver100Mb => '文件超过 100 MB：这是密友的上限（会在你的手机上整份加密）。';

  @override
  String get encryptingOnPhone => '正在你的手机上加密…';

  @override
  String noServerAcceptedEncrypted(Object details) {
    return '你的媒体服务器都没有接受这个加密文件。它不会以明文发布。请在设置里添加一个接受加密文件的服务器（例如 cdn.hzrd149.com）。$details';
  }

  @override
  String get sendingToFriends => '正在发给朋友…';

  @override
  String sendingToFriendsProgress(Object done, Object total) {
    return '正在发给朋友 $done/$total…';
  }

  @override
  String noFriendReceivedPost(Object reason) {
    return '没有朋友收到 post$reason。内容仍留在草稿里。';
  }

  @override
  String sentToCloseFriends(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '已发给 $count 位密友 🔒',
      one: '已发给 1 位密友 🔒',
    );
    return '$_temp0';
  }

  @override
  String sentToFriendsWithMisses(int delivered, Object missed) {
    String _temp0 = intl.Intl.pluralLogic(
      delivered,
      locale: localeName,
      other: '已发给 $delivered 位朋友。',
      one: '已发给 1 位朋友。',
    );
    return '$_temp0 $missed 没有收到（私信未开启）。';
  }

  @override
  String get altText => '替代文本';

  @override
  String get altTextHint => '为看不见它的人描述一下内容…';

  @override
  String get cancel => '取消';

  @override
  String get save => '保存';

  @override
  String get momentPublished => '瞬间已发布 ✨';

  @override
  String get newMoment => '新瞬间';

  @override
  String get publish => '发布';

  @override
  String get guestMode => '访客模式';

  @override
  String get signInToPostMoments => '登录后才能发布你的瞬间。';

  @override
  String get signIn => '登录';

  @override
  String get kindPhoto => '照片';

  @override
  String get kindVideo => '视频';

  @override
  String get kindReel => 'Reel';

  @override
  String get kindStory => '快拍';

  @override
  String get storyExpiryNote =>
      '在遵守 NIP-40 的 relays 上，快拍会在 24 小时后过期，但其他人仍可能保存或归档。';

  @override
  String get fromGallery => '来自相册';

  @override
  String get galleryLongPressVideo => '相册（长按选择视频）';

  @override
  String get addVideo => '添加视频';

  @override
  String get camera => '相机';

  @override
  String get exifRemovedNote => '位置元数据（EXIF）会自动去掉。';

  @override
  String get writeCaption => '写一句配文…';

  @override
  String get privatePostNote => '私密帖子：没有公开话题标签，无法通过搜索找到。';

  @override
  String willPublishAs(Object caption) {
    return '将以此发布：「$caption」';
  }

  @override
  String get tapThumbnailForAlt => '点按缩略图以添加替代文本。';

  @override
  String get sensitiveContent => '敏感内容';

  @override
  String get sensitiveContentNote => '这条帖子会藏在警告后面（NIP-36）。';

  @override
  String get uploadingMedia => '正在上传媒体…';

  @override
  String get audiencePublic => '公开';

  @override
  String get closeFriends => '密友';

  @override
  String get signerCannotPublishCloseFriends =>
      '用此登录方式无法向密友发布：请使用 Amber、bunker 或本地密钥。';

  @override
  String get closeFriendsEmptyPrompt => '你的列表是空的：添加可以看见这条帖子的人。';

  @override
  String onlyYourCloseFriendsSee(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '只有你的 $count 位密友能看见。照片和视频会在上传前于你的手机上加密。',
      one: '只有你的 1 位密友能看见。照片和视频会在上传前于你的手机上加密。',
    );
    return '$_temp0';
  }

  @override
  String get addFriends => '添加朋友';

  @override
  String get manageList => '管理列表';

  @override
  String get edit => '编辑';

  @override
  String get reset => '重置';

  @override
  String get apply => '应用';

  @override
  String get cropFree => '自由';

  @override
  String get cropOriginal => '原始';

  @override
  String get rotate => '旋转';

  @override
  String get flip => '翻转';

  @override
  String get brightness => '亮度';

  @override
  String get contrast => '对比度';

  @override
  String get saturation => '饱和度';

  @override
  String postsByAuthor(Object author) {
    return '$author 的帖子…';
  }

  @override
  String get searchHint => '搜索用户、话题或文字…';

  @override
  String get clear => '清除';

  @override
  String get recent => '最近';

  @override
  String get searchDependsOnRelays => '搜索取决于已配置的 relays：结果可能不完整。';

  @override
  String get recentPostsEverywhere => '来自整个网络的最新帖子，包括你没有关注的人。';

  @override
  String get noResultsOnRelays => '已配置的 relays 上没有结果。';

  @override
  String get noRecentPostsFromFollowed => '你关注的人最近没有帖子。';

  @override
  String get noMomentsFound => '在 relays 上没有找到瞬间。请检查网络连接。';

  @override
  String get loadFailed => '加载失败';

  @override
  String get notifications => '通知';

  @override
  String get messages => '消息';

  @override
  String get homeEmptyFollowsNobody => '你关注的人的帖子会显示在这里。\n你还没有关注任何人：去发现有趣的人和资料。';

  @override
  String get discoverPeople => '发现用户';

  @override
  String get homeEmpty => '还没有瞬间。\n下拉刷新，或发布你的第一张。';

  @override
  String get retry => '重试';

  @override
  String get seenEverything => '你暂时已经看完了 ✨';

  @override
  String get discoverMoreProfiles => '发现更多资料';

  @override
  String get feedFollowing => '关注中';

  @override
  String get signInToSeeFollowed => '登录后查看你关注的人的帖子';

  @override
  String get videoPreview => '视频预览';

  @override
  String get cannotOpenPrivateVideo => '无法打开私密视频';

  @override
  String get cannotPlayVideo => '无法播放视频';

  @override
  String get pauseVideo => '暂停视频';

  @override
  String get playVideo => '播放视频';

  @override
  String errorTapToRetry(Object error) {
    return '$error — 点按重试';
  }

  @override
  String get soundOn => '打开声音';

  @override
  String get soundOff => '关闭声音';

  @override
  String get postImage => '帖子图片';

  @override
  String get imageUnavailable => '图片不可用';

  @override
  String errorTapToRetryNewline(Object message) {
    return '$message\n点按重试';
  }

  @override
  String get cannotOpenPrivateContent => '无法打开这份私密内容';

  @override
  String get privateImage => '私密图片';

  @override
  String get invalidImage => '无效图片';

  @override
  String get more => '更多';

  @override
  String get removeFromSaved => '从已保存中移除';

  @override
  String get copyLink => '复制链接';

  @override
  String get muteAuthor => '静音作者';

  @override
  String get blockAuthor => '拉黑作者';

  @override
  String get report => '举报';

  @override
  String get like => '喜欢';

  @override
  String get sendInMessage => '用消息发送';

  @override
  String get zapOptional => 'Zap（可选）';

  @override
  String get closeFriendsOnlyNote => '仅密友可见。喜欢和回复只发给作者。';

  @override
  String get likeFailed => '无法发送喜欢';

  @override
  String get nostrLinkCopied => 'Nostr 链接已复制到剪贴板';

  @override
  String get authorMuted => '已静音该作者';

  @override
  String get authorBlocked => '已拉黑该作者';

  @override
  String get reportSent => '举报已发送（NIP-56）';

  @override
  String get signInToReport => '登录后才能举报';

  @override
  String minutesAgo(Object minutes) {
    return '$minutes 分钟前';
  }

  @override
  String get show => '显示';

  @override
  String get chatEmptyHint => '写下第一条消息。\n内容已加密：只有你们两人能看见。';

  @override
  String get messageHint => '消息…';

  @override
  String get send => '发送';

  @override
  String get notSentSuffix => ' 未发送';

  @override
  String get contentUnavailable => '内容不可用（已过期，或在 relays 上找不到）';

  @override
  String get signInToSendPrivateMessages => '登录后才能发送私信。';

  @override
  String get cannotMessageYourself => '你不能给自己写消息。';

  @override
  String get recipientNoPrivateMessages => '此人还没有开启私信。';

  @override
  String noRecipientRelayAccepted(Object reason) {
    return '没有接收方 relay$reason 接受这条消息。';
  }

  @override
  String sendFailed(Object error) {
    return '发送失败：$error';
  }

  @override
  String get signInToReadMessages => '登录后才能阅读和发送私信。';

  @override
  String get signerNoPrivateMessagesLong =>
      '此登录方式无法使用私信。请使用 Amber、bunker 或本地密钥登录。';

  @override
  String get inboxEmpty => '没有会话。\n点按铅笔给某人写信，或用每条帖子下方的 ✈ 图标转发瞬间。';

  @override
  String get newMessage => '新消息';

  @override
  String get privateMessagesEnabled => '私信已开启';

  @override
  String get enableMessagesFailed => '无法开启。请重试。';

  @override
  String get enablePrivateMessages => '开启私信';

  @override
  String enablePrivateMessagesExplain(Object count) {
    return '要接收消息，你需要说明它们应送到哪些 relays。会发布一份含 $count 个默认 relays 的小列表（NIP-17）：之后可以修改。消息保持加密：relays 既看不到是谁写的，也看不到正文。';
  }

  @override
  String get turnOn => '开启';

  @override
  String get searchByNameOrUsername => '按名字或用户名搜索';

  @override
  String get searching => '正在搜索…';

  @override
  String get noOneWithNameHint =>
      '没有这个名字的人。试着少打几个字母，或使用 name@domain.com 这样的地址。';

  @override
  String get sent => '已发送';

  @override
  String sentToPeople(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '已发给 $count 人',
      one: '已发给 1 人',
    );
    return '$_temp0';
  }

  @override
  String sentToPeopleWithFailure(int count, Object failure) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '已发给 $count 人。$failure',
      one: '已发给 1 人。$failure',
    );
    return '$_temp0';
  }

  @override
  String get signerNoPrivateMessagesShort => '此登录方式无法使用私信。';

  @override
  String get followToStartOrSearch => '先关注一个人，或按名字搜索。';

  @override
  String get addMessage => '添加消息…';

  @override
  String sendWithCount(Object count) {
    return '发送（$count）';
  }

  @override
  String get linkCopied => '链接已复制到剪贴板';

  @override
  String get noNotifications => '目前没有通知。';

  @override
  String get notificationsDependOnRelays => '通知取决于 relays：可能不完整。';

  @override
  String get reactedToYourMoment => '对你的瞬间作出了反应';

  @override
  String commentedText(Object text) {
    return '评论了：$text';
  }

  @override
  String sentYouSats(Object sats, Object comment) {
    return '给你发了 $sats sats$comment';
  }

  @override
  String get sentYouZap => '给你发了一个 zap';

  @override
  String get startedFollowingYou => '开始关注你';

  @override
  String get amberNotFound => '未找到 Amber';

  @override
  String get amberExplain => 'Amber 是一个 Nostr 签名器，会把你的私钥留在 Mialuna 之外。请安装后再试。';

  @override
  String get downloadFromFdroid => '从 F-Droid 下载';

  @override
  String get continueWithAmber => '使用 Amber 继续';

  @override
  String get amberRecommended => '推荐：你的私钥安全地留在 Amber 里。';

  @override
  String get amberNotDetected => '未检测到 Amber：安装它即可使用推荐的登录方式。';

  @override
  String get exploreWithoutAccount => '不登录账号，先看看';

  @override
  String get remoteBunker => '远程 bunker（NIP-46）';

  @override
  String get invalidBunkerUrlDot => '无效的 bunker URL。';

  @override
  String get connectBunker => '连接 bunker';

  @override
  String get advancedNsec => '高级登录（nsec）';

  @override
  String get nsecWarning => '警告：粘贴私钥有风险。切勿告诉任何人。在 Android 上请优先使用 Amber。';

  @override
  String get invalidNsec => '无效的 nsec 密钥。';

  @override
  String get signInWithNsec => '使用 nsec 登录';

  @override
  String get tagline => '你的瞬间，在同一轮月亮下。';

  @override
  String get skip => '跳过';

  @override
  String get permissionsAndWallet => '权限和钱包';

  @override
  String get permissionsExplain => '它们只用于发布和接收通知。你可以随时在系统设置里更改。';

  @override
  String get photosAndVideos => '照片和视频';

  @override
  String get toUploadYourMoments => '用于上传你的瞬间';

  @override
  String get allow => '允许';

  @override
  String get reactionsCommentsZaps => '反应、评论和 zaps';

  @override
  String get lightningWalletOptional => 'Lightning 钱包（可选）';

  @override
  String get nwcExplain => '连接 Nostr Wallet Connect 钱包，即可不离开应用发送 zaps。';

  @override
  String get walletConnected => '钱包已连接';

  @override
  String get disconnect => '断开连接';

  @override
  String get connectWallet => '连接钱包';

  @override
  String get getStarted => '开始使用';

  @override
  String get welcome1 => 'Mialuna 是一个视觉社交网络：照片、视频、Reels 和快拍 — 从不以纯文字发帖。';

  @override
  String get welcome2 =>
      '它运行在 Nostr 上，这是一个开放协议：你的身份是你自己的一把密钥，不是公司可以拿走的账号。没有广告，没有追踪器，没有中心服务器。';

  @override
  String get welcome3 => '用任何说同一种开放语言的应用，把你的光分享给各处的人。';

  @override
  String onboardingWot(int min) {
    return '信任网络始终开启。你第一次打开 Mialuna 时，它会读取你关注了谁，并据此构建发现信息流：你、你关注的人，以及其中至少 $min 人共同关注的人。之后再打开应用，这条信息流已经在那里。';
  }

  @override
  String get publicAndPrivate => '公开与私密';

  @override
  String get publicAndPrivateIntro =>
      'Mialuna 构建在 Nostr 之上，这是一个开放网络。你发布的内容是公开的：帖子、照片和视频对任何有链接的人都可见，即使在 Mialuna 之外。';

  @override
  String get closeFriendsExplain1 =>
      '只有这份列表上的人会收到你的「密友」帖子、快拍和视频。列表就在帖子里；你不必每次都挑选。';

  @override
  String get closeFriendsExplain2 =>
      '照片和视频会在上传前于你的手机上加密。文件服务器（Blossom）自己不会加密任何东西：所以由 Mialuna 来做，服务器只能看到无法阅读的数据。就算有人找到文件地址，也打不开。';

  @override
  String get closeFriendsExplain3 => '这不是绝对保证：收到帖子的人可以截图，移除朋友只对以后的帖子生效。';

  @override
  String get closeFriendsExplain4 =>
      '每位朋友都必须使用已开启私信的 Mialuna。其他 Nostr 客户端不会显示这些帖子。';

  @override
  String get closeFriendsExplain5 => '公开帖子保持公开：其文件对任何有链接的人都可见。';

  @override
  String get closeFriendsExplain6 => '如果你的服务器都不接受加密文件，这条帖子不会发布：绝不以明文发出。';

  @override
  String get addToCloseFriends => '添加到密友';

  @override
  String maxFriendsReached(Object max, Object added) {
    return '朋友上限为 $max 人：已添加 $added 人。';
  }

  @override
  String get add => '添加';

  @override
  String get signInToCreateList => '登录后才能创建你的列表。';

  @override
  String get signerNoCloseFriends => '此登录方式无法使用密友。请使用 Amber、bunker 或本地密钥登录。';

  @override
  String peopleOfMax(Object count, Object max) {
    return '$count / $max 人';
  }

  @override
  String get noOneYet => '还没有人。';

  @override
  String get addPeople => '添加用户';

  @override
  String get friendNoPrivateMessagesWarning => '他们还没有开启私信：收不到你的帖子';

  @override
  String get removeFromList => '从列表中移除';

  @override
  String get noOneWithThisName => '没有这个名字的人。';

  @override
  String get signInToSendPrivateContent => '登录后才能发送私密内容。';

  @override
  String get reasonNoPrivateMessages => '尚未开启私信';

  @override
  String get reasonNoRelayAnswered => '没有 relay 响应';

  @override
  String get profileUpdated => '资料已更新';

  @override
  String get noRelayAcceptedRetry => '没有 relay 接受。请稍后再试。';

  @override
  String get editProfile => '编辑资料';

  @override
  String get fieldName => '名字';

  @override
  String get fieldBio => '简介';

  @override
  String get fieldAvatarUrl => '头像 URL';

  @override
  String get fieldNip05 => 'NIP-05（例如 you@example.com）';

  @override
  String get browsingAsGuest => '你正在以访客身份浏览';

  @override
  String get signInToInteract => '登录后才能发布、关注和互动。';

  @override
  String get settings => '设置';

  @override
  String get signOut => '退出登录';

  @override
  String get npubCopied => 'npub 已复制';

  @override
  String get copyNpub => '复制 npub';

  @override
  String get mute => '静音';

  @override
  String get block => '拉黑';

  @override
  String get posts => '帖子';

  @override
  String get saved => '已保存';

  @override
  String get nothingPublishedYet => '你还没有发布任何内容。';

  @override
  String get noPostsOnRelays => '在 relays 上没有找到帖子。';

  @override
  String get noReelsPublished => '还没有发布 reels。';

  @override
  String get noReelsOnRelays => '在 relays 上没有找到 reels。';

  @override
  String get noSavedPosts => '没有已保存的帖子。';

  @override
  String get followingButton => '已关注';

  @override
  String get follow => '关注';

  @override
  String get messageButton => '消息';

  @override
  String get loginLocalKey => '本地密钥';

  @override
  String get loginGuest => '访客';

  @override
  String get followUpdateFailed => '目前无法更新你的关注。请重试。';

  @override
  String get noReelsComeBack => '在 relays 上没有找到 reels。\n请稍后再来！';

  @override
  String get followUpdateFailedShort => '目前无法更新你的关注';

  @override
  String get needOneReadRelay => '至少需要一个读取用的 relay。';

  @override
  String get listSavedLocally => '列表已保存在此设备上，尚未发布。';

  @override
  String get noRelayAcceptedList => '没有 relay 接受这份列表：稍后会重试。';

  @override
  String relayListPublishedTo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Relay 列表已发布到 $count 个 relays',
      one: 'Relay 列表已发布到 1 个 relay',
    );
    return '$_temp0';
  }

  @override
  String get mediaServersUpdated => '媒体服务器已更新';

  @override
  String get appearance => '外观';

  @override
  String get publishingSettings => '发布';

  @override
  String get addMialunaHashtag => '添加 #mialuna';

  @override
  String get addMialunaHashtagNote => '把官方话题标签加到公开帖子和快拍上。你可以随时关闭。';

  @override
  String get themeLight => '浅色';

  @override
  String get themeDark => '深色';

  @override
  String get themeSystem => '跟随系统';

  @override
  String get relays => 'Relays';

  @override
  String get relaysExplainSignedOut =>
      'Relays 负责存储和分发内容。登录后即可自动使用你自己的列表（NIP-65）。';

  @override
  String get relaysExplainSynced =>
      '这份列表与你的 Nostr 资料同步（NIP-65）：每次更改都会发布，并应用到你的所有应用。';

  @override
  String get syncing => '正在同步…';

  @override
  String get waitingFirstSync => '正在等待首次同步';

  @override
  String get syncNow => '立即同步';

  @override
  String get addRelay => '添加 relay';

  @override
  String get restoreDefaultRelays => '恢复默认 relays';

  @override
  String get createYourList => '创建你的列表';

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
  String get closeFriendsSettingsNote => '帖子、快拍和视频仅对他们可见，照片和视频会加密。';

  @override
  String get mediaServersBlossom => '媒体服务器（Blossom）';

  @override
  String get mediaServersExplain =>
      '照片和视频只按所示顺序上传到这些服务器：第一个接受的会被用上。EXIF 和位置信息会在上传前去掉。';

  @override
  String get primary => '主要';

  @override
  String get makePrimary => '设为主要';

  @override
  String get remove => '移除';

  @override
  String get addServer => '添加服务器';

  @override
  String get moderation => '内容管理';

  @override
  String get moderationExplain => '已静音的作者和隐藏的话题标签通过 NIP-51 同步。已拉黑的作者只留在此设备上。';

  @override
  String get mutedAuthors => '已静音的作者';

  @override
  String get noMutedAuthors => '没有已静音的作者';

  @override
  String get blockedAuthors => '已拉黑的作者';

  @override
  String get noBlockedAuthors => '没有已拉黑的作者';

  @override
  String get hiddenHashtags => '隐藏的话题标签';

  @override
  String get noHiddenHashtags => '没有隐藏的话题标签';

  @override
  String get hashtagToHide => '要隐藏的 #hashtag';

  @override
  String get storage => '存储';

  @override
  String get clearCache => '清除事件缓存和草稿';

  @override
  String get cacheCleared => '缓存已清除';

  @override
  String get reviewIntro => '再看一遍介绍';

  @override
  String get reviewIntroSubtitle => '什么是公开的，什么是私密的，以及密友的限制。';

  @override
  String noLightningWalletCopied(Object address) {
    return '未找到 Lightning 钱包：地址已复制（$address）';
  }

  @override
  String get about => '关于';

  @override
  String aboutText(Object version) {
    return 'Mialuna $version — 你的瞬间，在同一轮月亮下。\n开源（MIT）。github.com/Lwb89dev/mialuna';
  }

  @override
  String get invalidRelayAddress => '无效地址：请使用 wss://…';

  @override
  String get invalidServerAddress => '无效地址：请使用 https://…';

  @override
  String get relayRead => '读取';

  @override
  String get relayWrite => '写入';

  @override
  String get support => '支持';

  @override
  String get supportText =>
      'Mialuna 免费、没有广告，也不会追踪你。如果你喜欢，可以通过 Lightning Network 发送一些 sats。';

  @override
  String get donateWithLightning => '用 Lightning 捐赠';

  @override
  String get authorNoZaps => '该作者不接受 zaps';

  @override
  String get sendZap => '发送一个 zap ⚡';

  @override
  String get amountInSats => '金额（sats）';

  @override
  String minMaxSats(Object min, Object max) {
    return '最小 $min – 最大 $max';
  }

  @override
  String get zap => 'Zap';

  @override
  String get signInToZap => '登录后才能发送 zaps';

  @override
  String zapSent(Object sats) {
    return '已发送 $sats sats 的 Zap ⚡';
  }

  @override
  String nwcPaymentFailed(Object error) {
    return 'NWC 支付失败：$error';
  }

  @override
  String get noLightningWallet => '未找到 Lightning 钱包';

  @override
  String storiesRailLabel(Object state) {
    return '快拍，$state';
  }

  @override
  String get close => '关闭';

  @override
  String hoursAgo(int hours) {
    return '$hours 小时前';
  }

  @override
  String daysAgo(int days) {
    return '$days 天前';
  }

  @override
  String get now => '现在';

  @override
  String get youPrefix => '你: ';

  @override
  String get storiesStateUnseen => '新';

  @override
  String get storiesStateSeen => '已看';

  @override
  String weekdayShort(String day) {
    String _temp0 = intl.Intl.selectLogic(day, {
      'mon': '周一',
      'tue': '周二',
      'wed': '周三',
      'thu': '周四',
      'fri': '周五',
      'sat': '周六',
      'sun': '周日',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get sharedAMoment => '分享了一个瞬间';

  @override
  String get blossomOtherError => '错误';

  @override
  String get languageTitle => '语言';

  @override
  String get languageSystem => '跟随系统';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageItalian => 'Italiano';

  @override
  String get cannotEditPhoto => '无法在这里编辑这张照片。';

  @override
  String notificationsNew(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 条新通知',
      one: '1 条新通知',
    );
    return '$_temp0';
  }

  @override
  String messagesUnread(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 条未读消息',
      one: '1 条未读消息',
    );
    return '$_temp0';
  }

  @override
  String get done => '完成';

  @override
  String get storyAddText => '添加文字';

  @override
  String get storyEditText => '编辑文字';

  @override
  String get storyTextHint => '写点什么… #hashtags 可以点按';

  @override
  String get storyTextsHelp => '点按图片即可书写。拖动来移动，双指捏合来缩放和旋转，点按文字来编辑。';

  @override
  String storyTextsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 段文字',
      one: '1 段文字',
      zero: '没有文字',
    );
    return '$_temp0';
  }

  @override
  String get storyFontClassic => '经典';

  @override
  String get storyFontBold => '粗体';

  @override
  String get storyFontSerif => 'Serif';

  @override
  String get storyFontMono => 'Mono';

  @override
  String get storyFontItalic => '斜体';

  @override
  String get storyTextBackground => '文字背景';

  @override
  String get storyTextColor => '文字颜色';

  @override
  String storyTextLimit(int max) {
    return '最多可以添加 $max 段文字。';
  }

  @override
  String get wotTitle => '信任网络';

  @override
  String get wotEnable => '信任网络始终开启';

  @override
  String wotExplain(int min) {
    return '始终开启。发现只显示这个网络：你、你关注的人，以及其中至少 $min 人所关注的人。同一网络会隐藏其他人的评论、通知、私密帖子和消息。它会在你第一次打开应用时，凭公开的关注列表在这台手机上算好；之后打开会直接沿用。不会向任何服务器发送任何内容。';
  }

  @override
  String get wotRefresh => '立即刷新网络';

  @override
  String get wotStatusIdle => '还没有构建。会在你第一次打开应用时构建。';

  @override
  String get wotBuildingTitle => '正在构建你的发现信息流';

  @override
  String get wotBuildingBody => '正在读取你关注的人还关注了谁，并准备发现。';

  @override
  String get wotDiscoverHint => '只有你的信任网络：你关注的人，以及他们中足够多人共同关注的人。';

  @override
  String get wotDiscoverSignIn =>
      '发现显示的是你的信任网络。登录后，第一次 Mialuna 会读取你关注了谁并构建这条信息流。之后打开会直接沿用。';

  @override
  String get wotDiscoverEmpty => '你的信任网络还没有帖子。';

  @override
  String wotStatusDiscovering(int done, int total) {
    return '正在查看你关注的人还关注了谁… $done / $total';
  }

  @override
  String wotStatusComplete(int direct, int indirect, Object when) {
    return '你的网络：你关注的 $direct 人，加上被他们中足够多人关注的 $indirect 人。更新于 $when。';
  }

  @override
  String wotStatusFailed(Object reason) {
    return '无法算出你的网络：$reason';
  }

  @override
  String get wotNoFollows => '你还没有关注任何人';

  @override
  String get messageRequests => '消息请求';

  @override
  String messageRequestsSubtitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 个来自你的信任网络之外的会话',
      one: '1 个来自你的信任网络之外的会话',
    );
    return '$_temp0';
  }

  @override
  String get messageRequestsHint => '来自你的信任网络之外的人。它们不算未读。回复后，会话会移到收件箱。';

  @override
  String get storyViewsSetting => '让别人看到我看过他们的快拍';

  @override
  String get storyViewsSettingExplain =>
      '当你观看快拍时，会向作者发送一条回执，加密后只有对方能读。回执会把你的名字列在对方旁边；relays 什么也看不到。如果送不到，会先留着，稍后再试。关掉它，就可以在不告诉任何人的情况下观看：还没发出的回执会被丢弃（已经送达的无法收回）。';

  @override
  String storySeenBy(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 人看过',
      one: '1 人看过',
      zero: '还没有人看过',
    );
    return '$_temp0';
  }

  @override
  String get storyViewsEmpty => '还没有人看过这条快拍，或者他们的回执还没到你这里。';

  @override
  String get storyViewsHint => '只有允许发送的人才会发回执，所以真实人数可能更多。';

  @override
  String get systemNotifications => '系统通知';

  @override
  String get systemNotificationsExplain =>
      '当 Mialuna 在后台、有新内容时，在手机上显示通知。私信从不显示正文，锁屏上也不会。Android 会暂停长时间待在后台的应用，所以只有 Mialuna 仍在运行时通知才会到达。';

  @override
  String get systemNotificationsBlocked => '手机设置里已关闭 Mialuna 的通知。';

  @override
  String get systemNotificationsOpenSettings => '打开设置';

  @override
  String get systemNotificationsBattery =>
      '屏幕关闭几分钟后，Android 会让应用进入休眠，通知也会一起停。若要继续收到，请把 Mialuna 的电池用量设为“无限制”。';

  @override
  String get systemNotificationsBatteryAction => '打开电池设置';

  @override
  String get newFollowersSetting => '显示新关注者';

  @override
  String get newFollowersSettingExplain =>
      '新关注者会出现在通知里和你的手机上。如果有人用关注刷屏，可以关掉：喜欢、评论和 zaps 仍会显示。';

  @override
  String get systemNotificationMessage => '给你发了一条私信';

  @override
  String get systemNotificationNewMessage => '新私信';

  @override
  String get systemNotificationNew => '新通知';

  @override
  String get notificationChannelSocial => '反应、评论、zaps 和关注者';

  @override
  String get notificationChannelMessages => '私信';

  @override
  String get zapInvoiceMismatch => '发票与你选的金额不符。没有支付任何款项。';

  @override
  String get storyYourStory => '你的快拍';

  @override
  String get storyNew => '新快拍';

  @override
  String get storyAddSemantics => '添加到你的快拍';

  @override
  String storyOwnRailLabel(int count, Object state) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 条快拍',
      one: '1 条快拍',
    );
    return '你的快拍，$_temp0，$state';
  }

  @override
  String get storyTextSize => '文字大小';

  @override
  String get storyPickPrompt => '为你的快拍选一张照片或一段视频';

  @override
  String get storyEditPhoto => '编辑照片';

  @override
  String get storyCaption => '配文';

  @override
  String get storyDiscardTitle => '丢弃这条快拍？';

  @override
  String get storyDiscard => '丢弃';

  @override
  String get storyShare => '分享';

  @override
  String get storyShared => '快拍已分享';

  @override
  String get deletePost => '删除';

  @override
  String get deletePostTitle => '删除这条帖子？';

  @override
  String get deleteStoryTitle => '删除这条快拍？';

  @override
  String get deletePostBody =>
      'Mialuna 会请你的 relays 删除它，并请媒体服务器删除其中的照片或视频。忽略该请求的 relay，或已经保存了副本的人，可能仍然留有它。';

  @override
  String get deletePrivateBody =>
      '密友帖子无法从 relays 撤回。Mialuna 会让朋友的应用移除它，并请媒体服务器删除加密文件。已经保存了副本的朋友，手里可能还有。';

  @override
  String get deletingPost => '正在删除…';

  @override
  String get postDeleted => '已删除。';

  @override
  String get postWasDeleted => '这条帖子已删除。';

  @override
  String get deleteNotAllowed => '只有发布它的账号才能删除。';

  @override
  String deleteFailed(Object reason) {
    return '无法删除：$reason';
  }

  @override
  String get deleteNoRelay => '没有 relay 接受删除请求，所以它仍在线上。请检查连接并重试。';

  @override
  String deleteMediaLeft(Object servers) {
    return '无法从 $servers 移除媒体。';
  }

  @override
  String get deleteMediaNotAuthorized => '你的签名器没有授权移除媒体，所以文件仍在媒体服务器上。';

  @override
  String deleteFriendsMissed(Object count) {
    return '有 $count 位密友未能通知到，所以它可能还留在他们的手机上。';
  }

  @override
  String get storyCleanupSetting => '快拍过期时删除我的快拍';

  @override
  String get storyCleanupSettingExplain =>
      '24 小时后，Mialuna 会请你的 relays 和媒体服务器删除你的快拍，包括其中的照片和视频。忽略该请求的服务器，或留有副本的人，可能仍然留有它们。';

  @override
  String storyCleanupWaiting(Object count) {
    return '你的签名器必须批准每次清理，所以会等到你提出请求。等待删除的过期快拍：$count。';
  }

  @override
  String get storyCleanupNow => '立即删除';

  @override
  String get storyCleanupDone => '过期快拍已删除。';

  @override
  String get storyCleanupPartly => '有些还删不掉；Mialuna 会再试。';
}
