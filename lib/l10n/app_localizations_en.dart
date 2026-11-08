// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get syncUpToDate => 'Up to date';

  @override
  String get syncFailed => 'Sync failed';

  @override
  String get relaysUpdatedFromProfile =>
      'Relays updated from your profile (NIP-65)';

  @override
  String get relayListPublished => 'Relay list published';

  @override
  String get mediaServersUpdatedFromProfile =>
      'Media servers updated from your profile';

  @override
  String get tabHome => 'Home';

  @override
  String get tabDiscover => 'Discover';

  @override
  String get tabCreate => 'Create';

  @override
  String get tabReels => 'Reels';

  @override
  String get tabProfile => 'Profile';

  @override
  String get signInToUploadMedia => 'Sign in to upload media.';

  @override
  String get noMediaServer =>
      'No media server configured. Add one in Settings.';

  @override
  String serverNoResponse(Object server) {
    return '$server: no response';
  }

  @override
  String serverUnreachable(Object server, Object error) {
    return '$server: unreachable ($error)';
  }

  @override
  String uploadRejected(Object reason) {
    return 'Upload rejected — $reason';
  }

  @override
  String noServerAcceptedFile(Object reasons) {
    return 'No server accepted the file — $reasons';
  }

  @override
  String get blossomInvalidResponse => 'invalid response';

  @override
  String get blossomInvalidFileUrl => 'invalid file address';

  @override
  String get blossomServerAlteredFile => 'the server modified the file';

  @override
  String get blossomBadRequest => 'invalid request';

  @override
  String get blossomUnauthorized => 'authorization denied';

  @override
  String get blossomPaymentRequired => 'payment required';

  @override
  String get blossomForbidden => 'not allowed';

  @override
  String get blossomLengthRequired => 'missing size';

  @override
  String get blossomTooLarge => 'file too large';

  @override
  String get blossomUnsupportedType => 'format not accepted';

  @override
  String get blossomTooManyRequests => 'too many requests';

  @override
  String get blossomServerError => 'server error';

  @override
  String get cipherInvalidKey => 'Invalid key';

  @override
  String get cipherTruncated => 'Encrypted file is truncated';

  @override
  String get cipherMismatch =>
      'The file does not match the key: modified or corrupted';

  @override
  String get sanitizeHeifNeedsAsync =>
      'HEIC/AVIF format: conversion requires sanitizeAsync';

  @override
  String get sanitizeWebmUnsupported =>
      'WebM/MKV video is not supported: use MP4 or MOV so the metadata can be removed before uploading.';

  @override
  String get sanitizeUnknownFormat =>
      'Unrecognized file format: JPEG/PNG/WebP/GIF photos or MP4/MOV videos.';

  @override
  String sanitizeLeftovers(Object items) {
    return 'Could not remove all the metadata ($items): file not uploaded.';
  }

  @override
  String sanitizeProcessingFailed(Object error) {
    return 'Could not process the file: $error';
  }

  @override
  String get sanitizeJpegInvalid => 'Invalid JPEG';

  @override
  String get sanitizeJpegTruncated => 'Truncated JPEG';

  @override
  String get sanitizeJpegNoSize => 'JPEG without dimensions';

  @override
  String get sanitizeJpegUndecodable => 'JPEG cannot be decoded';

  @override
  String get sanitizePngTruncated => 'Truncated PNG';

  @override
  String get sanitizePngInvalid => 'Invalid PNG';

  @override
  String get sanitizeGifInvalid => 'Invalid GIF';

  @override
  String get sanitizeGifTruncated => 'Truncated GIF';

  @override
  String get sanitizeWebpTruncated => 'Truncated WebP';

  @override
  String get sanitizeWebpInvalid => 'Invalid WebP';

  @override
  String get sanitizeMp4Invalid => 'Invalid MP4/MOV video';

  @override
  String get sanitizeConversionFailed => 'Conversion failed';

  @override
  String get sanitizeHeifUnsupported =>
      'This format (HEIC/AVIF) cannot be converted on this device. Choose a JPEG or PNG photo.';

  @override
  String get privateMediaNotEncrypted => 'Media is not encrypted';

  @override
  String serverReplied(Object status) {
    return 'The server replied $status';
  }

  @override
  String get fileTooLarge => 'File too large';

  @override
  String get serverFileNotOriginal =>
      'The file on the server is not the original';

  @override
  String get contentMismatch => 'The content does not match';

  @override
  String get mediaUnreachable => 'Media unreachable';

  @override
  String get amberInvalidKey => 'Amber returned an invalid key';

  @override
  String get amberNoKey => 'Amber did not return a key';

  @override
  String get amberRequestRejected => 'Request rejected in Amber';

  @override
  String get amberAndroidOnly => 'Amber is only available on Android';

  @override
  String get amberEmptySignature => 'Amber returned an empty signature';

  @override
  String get amberSignRejected => 'Signature rejected in Amber';

  @override
  String get amberTimeout => 'Amber did not answer in time';

  @override
  String get amberEmptyResponse => 'Amber returned an empty response';

  @override
  String get bunkerInvalidUrl => 'Invalid bunker URL';

  @override
  String get bunkerNoRelay => 'The bunker does not list any relay';

  @override
  String get bunkerWebAuth =>
      'The bunker requires web authorization (auth_url is not supported)';

  @override
  String get bunkerInvalidKey => 'The bunker did not return a valid key';

  @override
  String get signerInvalidResponse =>
      'The signer returned an invalid signed event';

  @override
  String get bunkerTimeout => 'Bunker timed out';

  @override
  String get nwcInvalidUri => 'Invalid NWC URI';

  @override
  String get nwcNoRelay => 'The NWC URI does not list any relay';

  @override
  String get nwcNoSecret => 'The NWC URI does not contain a valid secret';

  @override
  String get nwcTimeout => 'Wallet timed out';

  @override
  String get signerNoPrivateMessages =>
      'This sign-in method does not support private messages';

  @override
  String get zapNotSupported => 'This address does not support Nostr zaps';

  @override
  String zapAmountOutOfRange(Object min, Object max) {
    return 'Amount out of range ($min–$max sats)';
  }

  @override
  String get commentNotSent => 'Comment not sent. Try again later.';

  @override
  String get comments => 'Comments';

  @override
  String get noCommentsYet => 'No comments yet.';

  @override
  String get signInToComment => 'Sign in to comment.';

  @override
  String get addComment => 'Add a comment…';

  @override
  String get signInToPublish => 'Sign in to publish.';

  @override
  String get addMediaFirst =>
      'Add at least one photo or video before publishing.';

  @override
  String get removingMetadata => 'Removing metadata…';

  @override
  String uploadingProgress(Object current, Object total) {
    return 'Uploading $current of $total…';
  }

  @override
  String get creatingPreview => 'Creating the preview…';

  @override
  String uploadFailed(Object error) {
    return 'Upload failed: $error';
  }

  @override
  String get publishing => 'Publishing…';

  @override
  String noRelayAcceptedPost(Object reason) {
    return 'No relay accepted the post$reason. The content stays in your drafts.';
  }

  @override
  String get privateNeedsKeySigner =>
      'This sign-in method does not support private content. Use Amber, a bunker or the local key.';

  @override
  String get closeFriendsListEmptyAddSomeone =>
      'Your close friends list is empty: add someone.';

  @override
  String get fileOver100Mb =>
      'The file is over 100 MB: that is the limit for close friends (it is encrypted whole on your phone).';

  @override
  String get encryptingOnPhone => 'Encrypting on your phone…';

  @override
  String noServerAcceptedEncrypted(Object details) {
    return 'None of your media servers accepted the encrypted file. It is not published in the clear. Add a server that accepts encrypted files in Settings (for example cdn.hzrd149.com). $details';
  }

  @override
  String get sendingToFriends => 'Sending to friends…';

  @override
  String sendingToFriendsProgress(Object done, Object total) {
    return 'Sending to friends $done/$total…';
  }

  @override
  String noFriendReceivedPost(Object reason) {
    return 'No friend received the post$reason. The content stays in your drafts.';
  }

  @override
  String sentToCloseFriends(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Sent to $count close friends 🔒',
      one: 'Sent to 1 close friend 🔒',
    );
    return '$_temp0';
  }

  @override
  String sentToFriendsWithMisses(int delivered, Object missed) {
    String _temp0 = intl.Intl.pluralLogic(
      delivered,
      locale: localeName,
      other: 'Sent to $delivered friends.',
      one: 'Sent to 1 friend.',
    );
    return '$_temp0 $missed did not receive it (private messages are off).';
  }

  @override
  String get altText => 'Alt text';

  @override
  String get altTextHint =>
      'Describe the content for people who cannot see it…';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get momentPublished => 'Moment published ✨';

  @override
  String get newMoment => 'New moment';

  @override
  String get publish => 'Publish';

  @override
  String get guestMode => 'Guest mode';

  @override
  String get signInToPostMoments => 'Sign in to publish your moments.';

  @override
  String get signIn => 'Sign in';

  @override
  String get kindPhoto => 'Photo';

  @override
  String get kindVideo => 'Video';

  @override
  String get kindReel => 'Reel';

  @override
  String get kindStory => 'Story';

  @override
  String get storyExpiryNote =>
      'Stories expire after 24 hours on relays that honour NIP-40, but others can still save or archive them.';

  @override
  String get fromGallery => 'From gallery';

  @override
  String get galleryLongPressVideo => 'Gallery (long-press for video)';

  @override
  String get addVideo => 'Add video';

  @override
  String get camera => 'Camera';

  @override
  String get exifRemovedNote =>
      'Location metadata (EXIF) is removed automatically.';

  @override
  String get writeCaption => 'Write a caption…';

  @override
  String get privatePostNote =>
      'Private post: no public hashtags, it cannot be found through search.';

  @override
  String willPublishAs(Object caption) {
    return 'It will be published as: \"$caption\"';
  }

  @override
  String get tapThumbnailForAlt => 'Tap a thumbnail to add alt text.';

  @override
  String get sensitiveContent => 'Sensitive content';

  @override
  String get sensitiveContentNote =>
      'The post will be hidden behind a warning (NIP-36).';

  @override
  String get uploadingMedia => 'Uploading media…';

  @override
  String get audiencePublic => 'Public';

  @override
  String get closeFriends => 'Close friends';

  @override
  String get signerCannotPublishCloseFriends =>
      'With this sign-in method you cannot publish for close friends: use Amber, a bunker or the local key.';

  @override
  String get closeFriendsEmptyPrompt =>
      'Your list is empty: add the people who can see this post.';

  @override
  String onlyYourCloseFriendsSee(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Only your $count close friends will see this. Photos and videos are encrypted on your phone before they are uploaded.',
      one:
          'Only your 1 close friend will see this. Photos and videos are encrypted on your phone before they are uploaded.',
    );
    return '$_temp0';
  }

  @override
  String get addFriends => 'Add friends';

  @override
  String get manageList => 'Manage the list';

  @override
  String get edit => 'Edit';

  @override
  String get reset => 'Reset';

  @override
  String get apply => 'Apply';

  @override
  String get cropFree => 'Free';

  @override
  String get cropOriginal => 'Original';

  @override
  String get rotate => 'Rotate';

  @override
  String get flip => 'Flip';

  @override
  String get brightness => 'Brightness';

  @override
  String get contrast => 'Contrast';

  @override
  String get saturation => 'Saturation';

  @override
  String postsByAuthor(Object author) {
    return 'Posts by $author…';
  }

  @override
  String get searchHint => 'Search people, hashtags or words…';

  @override
  String get clear => 'Clear';

  @override
  String get recent => 'Recent';

  @override
  String get searchDependsOnRelays =>
      'Search depends on the configured relays: results may be partial.';

  @override
  String get recentPostsEverywhere =>
      'Recent posts from the whole network, including people you do not follow.';

  @override
  String get noResultsOnRelays => 'No results on the configured relays.';

  @override
  String get noRecentPostsFromFollowed =>
      'No recent posts from the people you follow.';

  @override
  String get noMomentsFound =>
      'No moments found on the relays. Check your connection.';

  @override
  String get loadFailed => 'Loading failed';

  @override
  String get notifications => 'Notifications';

  @override
  String get messages => 'Messages';

  @override
  String get homeEmptyFollowsNobody =>
      'Posts from the people you follow appear here.\nYou do not follow anyone yet: discover interesting people and profiles.';

  @override
  String get discoverPeople => 'Discover people';

  @override
  String get homeEmpty =>
      'No moments yet.\nPull down to refresh or publish your first shot.';

  @override
  String get retry => 'Try again';

  @override
  String get seenEverything => 'You have seen everything for now ✨';

  @override
  String get discoverMoreProfiles => 'Discover more profiles';

  @override
  String get feedFollowing => 'Following';

  @override
  String get signInToSeeFollowed =>
      'Sign in to see posts from the people you follow';

  @override
  String get videoPreview => 'Video preview';

  @override
  String get cannotOpenPrivateVideo => 'Cannot open the private video';

  @override
  String get cannotPlayVideo => 'Cannot play the video';

  @override
  String get pauseVideo => 'Pause the video';

  @override
  String get playVideo => 'Play the video';

  @override
  String errorTapToRetry(Object error) {
    return '$error — tap to retry';
  }

  @override
  String get soundOn => 'Turn the sound on';

  @override
  String get soundOff => 'Turn the sound off';

  @override
  String get postImage => 'Post image';

  @override
  String get imageUnavailable => 'Image not available';

  @override
  String errorTapToRetryNewline(Object message) {
    return '$message\nTap to retry';
  }

  @override
  String get cannotOpenPrivateContent => 'Cannot open this private content';

  @override
  String get privateImage => 'Private image';

  @override
  String get invalidImage => 'Invalid image';

  @override
  String get more => 'More';

  @override
  String get removeFromSaved => 'Remove from saved';

  @override
  String get copyLink => 'Copy link';

  @override
  String get muteAuthor => 'Mute author';

  @override
  String get blockAuthor => 'Block author';

  @override
  String get report => 'Report';

  @override
  String get like => 'Like';

  @override
  String get sendInMessage => 'Send in a message';

  @override
  String get zapOptional => 'Zap (optional)';

  @override
  String get closeFriendsOnlyNote =>
      'Visible only to close friends. Likes and replies go only to the author.';

  @override
  String get likeFailed => 'Could not send the like';

  @override
  String get nostrLinkCopied => 'Nostr link copied to the clipboard';

  @override
  String get authorMuted => 'Author muted';

  @override
  String get authorBlocked => 'Author blocked';

  @override
  String get reportSent => 'Report sent (NIP-56)';

  @override
  String get signInToReport => 'Sign in to report';

  @override
  String minutesAgo(Object minutes) {
    return '$minutes min ago';
  }

  @override
  String get show => 'Show';

  @override
  String get chatEmptyHint =>
      'Write the first message.\nIt is encrypted: only the two of you can see it.';

  @override
  String get messageHint => 'Message…';

  @override
  String get send => 'Send';

  @override
  String get notSentSuffix => ' not sent';

  @override
  String get contentUnavailable =>
      'Content not available (expired or not found on the relays)';

  @override
  String get signInToSendPrivateMessages => 'Sign in to send private messages.';

  @override
  String get cannotMessageYourself => 'You cannot write to yourself.';

  @override
  String get recipientNoPrivateMessages =>
      'This person has not turned on private messages yet.';

  @override
  String noRecipientRelayAccepted(Object reason) {
    return 'No recipient relay accepted the message$reason.';
  }

  @override
  String sendFailed(Object error) {
    return 'Sending failed: $error';
  }

  @override
  String get signInToReadMessages =>
      'Sign in to read and send private messages.';

  @override
  String get signerNoPrivateMessagesLong =>
      'Private messages cannot be used with this sign-in method. Sign in with Amber, a bunker or the local key.';

  @override
  String get inboxEmpty =>
      'No conversations.\nTap the pencil to write to someone, or forward a moment with the ✈ icon under every post.';

  @override
  String get newMessage => 'New message';

  @override
  String get privateMessagesEnabled => 'Private messages turned on';

  @override
  String get enableMessagesFailed => 'Could not turn them on. Try again.';

  @override
  String get enablePrivateMessages => 'Turn on private messages';

  @override
  String enablePrivateMessagesExplain(Object count) {
    return 'To receive messages you need to say which relays they should arrive on. A small list (NIP-17) is published with $count default relays: you can change it later. Messages stay encrypted: relays see neither who writes nor the text.';
  }

  @override
  String get turnOn => 'Turn on';

  @override
  String get searchByNameOrUsername => 'Search by name or username';

  @override
  String get searching => 'Searching…';

  @override
  String get noOneWithNameHint =>
      'Nobody with this name. Try fewer letters or an address like name@domain.com.';

  @override
  String get sent => 'Sent';

  @override
  String sentToPeople(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Sent to $count people',
      one: 'Sent to 1 person',
    );
    return '$_temp0';
  }

  @override
  String sentToPeopleWithFailure(int count, Object failure) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Sent to $count people. $failure',
      one: 'Sent to 1 person. $failure',
    );
    return '$_temp0';
  }

  @override
  String get signerNoPrivateMessagesShort =>
      'You cannot use private messages with this sign-in method.';

  @override
  String get followToStartOrSearch =>
      'Follow someone to start, or search by name.';

  @override
  String get addMessage => 'Add a message…';

  @override
  String sendWithCount(Object count) {
    return 'Send ($count)';
  }

  @override
  String get linkCopied => 'Link copied to the clipboard';

  @override
  String get noNotifications => 'No notifications right now.';

  @override
  String get notificationsDependOnRelays =>
      'Notifications depend on relays: they may be incomplete.';

  @override
  String get reactedToYourMoment => 'reacted to your moment';

  @override
  String commentedText(Object text) {
    return 'commented: $text';
  }

  @override
  String sentYouSats(Object sats, Object comment) {
    return 'sent you $sats sats$comment';
  }

  @override
  String get sentYouZap => 'sent you a zap';

  @override
  String get startedFollowingYou => 'started following you';

  @override
  String get amberNotFound => 'Amber not found';

  @override
  String get amberExplain =>
      'Amber is a Nostr signer that keeps your private key outside Mialuna. Install it and try again.';

  @override
  String get downloadFromFdroid => 'Download from F-Droid';

  @override
  String get continueWithAmber => 'Continue with Amber';

  @override
  String get amberRecommended =>
      'Recommended: your private key stays safe in Amber.';

  @override
  String get amberNotDetected =>
      'Amber not detected: install it for the recommended sign-in.';

  @override
  String get exploreWithoutAccount => 'Explore without an account';

  @override
  String get remoteBunker => 'Remote bunker (NIP-46)';

  @override
  String get invalidBunkerUrlDot => 'Invalid bunker URL.';

  @override
  String get connectBunker => 'Connect bunker';

  @override
  String get advancedNsec => 'Advanced sign-in (nsec)';

  @override
  String get nsecWarning =>
      'Warning: pasting your private key is risky. Never share it with anyone. On Android prefer Amber.';

  @override
  String get invalidNsec => 'Invalid nsec key.';

  @override
  String get signInWithNsec => 'Sign in with nsec';

  @override
  String get tagline => 'Your moments, under the same moon.';

  @override
  String get skip => 'Skip';

  @override
  String get permissionsAndWallet => 'Permissions and wallet';

  @override
  String get permissionsExplain =>
      'They only let you publish and receive notifications. You can change them at any time in the system settings.';

  @override
  String get photosAndVideos => 'Photos and videos';

  @override
  String get toUploadYourMoments => 'To upload your moments';

  @override
  String get allow => 'Allow';

  @override
  String get reactionsCommentsZaps => 'Reactions, comments and zaps';

  @override
  String get lightningWalletOptional => 'Lightning wallet (optional)';

  @override
  String get nwcExplain =>
      'Connect a Nostr Wallet Connect wallet to send zaps without leaving the app.';

  @override
  String get walletConnected => 'Wallet connected';

  @override
  String get disconnect => 'Disconnect';

  @override
  String get connectWallet => 'Connect wallet';

  @override
  String get getStarted => 'Get started';

  @override
  String get welcome1 =>
      'Mialuna is a visual social network: photos, videos, Reels and Stories — never text-only posts.';

  @override
  String get welcome2 =>
      'It runs on Nostr, an open protocol: your identity is a key you own, not an account a company can take away. No ads, no trackers, no central servers.';

  @override
  String get welcome3 =>
      'Share your light with people everywhere, from any app that speaks the same open language.';

  @override
  String onboardingWot(int min) {
    return 'Web of trust is always on. The first time you open Mialuna it reads who you follow and builds the Discover feed from that network: you, the people you follow, and whoever at least $min of them follow. The next times you open the app, that feed is already there.';
  }

  @override
  String get publicAndPrivate => 'Public and private';

  @override
  String get publicAndPrivateIntro =>
      'Mialuna is built on Nostr, an open network. What you publish is public: posts, photos and videos stay visible to anyone with the link, even outside Mialuna.';

  @override
  String get closeFriendsExplain1 =>
      'Only the people on this list receive your \"Close friends\" posts, stories and videos. The list is inside the post; you do not have to pick it every time.';

  @override
  String get closeFriendsExplain2 =>
      'Photos and videos are encrypted on your phone before they are uploaded. File servers (Blossom) do not encrypt anything by themselves: that is why Mialuna does it, and the server only sees unreadable data. Whoever finds the file address cannot open it.';

  @override
  String get closeFriendsExplain3 =>
      'It is not an absolute guarantee: whoever receives a post can take a screenshot, and removing a friend only applies to future posts.';

  @override
  String get closeFriendsExplain4 =>
      'Every friend must use Mialuna with private messages turned on. Other Nostr clients do not show these posts.';

  @override
  String get closeFriendsExplain5 =>
      'Public posts stay public: their files are visible to anyone with the link.';

  @override
  String get closeFriendsExplain6 =>
      'If none of your servers accepts encrypted files, the post is not published: never in the clear.';

  @override
  String get addToCloseFriends => 'Add to close friends';

  @override
  String maxFriendsReached(Object max, Object added) {
    return 'Limit of $max friends: $added added.';
  }

  @override
  String get add => 'Add';

  @override
  String get signInToCreateList => 'Sign in to create your list.';

  @override
  String get signerNoCloseFriends =>
      'Close friends cannot be used with this sign-in method. Sign in with Amber, a bunker or the local key.';

  @override
  String peopleOfMax(Object count, Object max) {
    return '$count / $max people';
  }

  @override
  String get noOneYet => 'Nobody yet.';

  @override
  String get addPeople => 'Add people';

  @override
  String get friendNoPrivateMessagesWarning =>
      'They have not turned on private messages: they will not receive your posts';

  @override
  String get removeFromList => 'Remove from the list';

  @override
  String get noOneWithThisName => 'Nobody with this name.';

  @override
  String get signInToSendPrivateContent => 'Sign in to send private content.';

  @override
  String get reasonNoPrivateMessages => 'has not turned on private messages';

  @override
  String get reasonNoRelayAnswered => 'no relay answered';

  @override
  String get profileUpdated => 'Profile updated';

  @override
  String get noRelayAcceptedRetry => 'No relay accepted it. Try again later.';

  @override
  String get editProfile => 'Edit profile';

  @override
  String get fieldName => 'Name';

  @override
  String get fieldBio => 'Bio';

  @override
  String get fieldAvatarUrl => 'Avatar URL';

  @override
  String get fieldNip05 => 'NIP-05 (e.g. you@example.com)';

  @override
  String get browsingAsGuest => 'You are browsing as a guest';

  @override
  String get signInToInteract => 'Sign in to publish, follow and interact.';

  @override
  String get settings => 'Settings';

  @override
  String get signOut => 'Sign out';

  @override
  String get npubCopied => 'npub copied';

  @override
  String get copyNpub => 'Copy npub';

  @override
  String get mute => 'Mute';

  @override
  String get block => 'Block';

  @override
  String get posts => 'Posts';

  @override
  String get saved => 'Saved';

  @override
  String get nothingPublishedYet => 'You have not published anything yet.';

  @override
  String get noPostsOnRelays => 'No posts found on the relays.';

  @override
  String get noReelsPublished => 'No reels published.';

  @override
  String get noReelsOnRelays => 'No reels found on the relays.';

  @override
  String get noSavedPosts => 'No saved posts.';

  @override
  String get followingButton => 'Following';

  @override
  String get follow => 'Follow';

  @override
  String get messageButton => 'Message';

  @override
  String get loginLocalKey => 'Local key';

  @override
  String get loginGuest => 'Guest';

  @override
  String get followUpdateFailed =>
      'Could not update your follows right now. Try again.';

  @override
  String get noReelsComeBack =>
      'No reels found on the relays.\nCome back soon!';

  @override
  String get followUpdateFailedShort =>
      'Could not update your follows right now';

  @override
  String get needOneReadRelay => 'At least one read relay is required.';

  @override
  String get listSavedLocally => 'List saved on this device, not published.';

  @override
  String get noRelayAcceptedList =>
      'No relay accepted the list: it will be retried later.';

  @override
  String relayListPublishedTo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Relay list published to $count relays',
      one: 'Relay list published to 1 relay',
    );
    return '$_temp0';
  }

  @override
  String get mediaServersUpdated => 'Media servers updated';

  @override
  String get appearance => 'Appearance';

  @override
  String get publishingSettings => 'Publishing';

  @override
  String get addMialunaHashtag => 'Add #mialuna';

  @override
  String get addMialunaHashtagNote =>
      'Add the official hashtag to public posts and stories. You can turn this off at any time.';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get themeSystem => 'System';

  @override
  String get relays => 'Relays';

  @override
  String get relaysExplainSignedOut =>
      'Relays store and distribute content. Sign in to use your own list automatically (NIP-65).';

  @override
  String get relaysExplainSynced =>
      'The list is synced with your Nostr profile (NIP-65): every change is published and applies to all your apps.';

  @override
  String get syncing => 'Syncing…';

  @override
  String get waitingFirstSync => 'Waiting for the first sync';

  @override
  String get syncNow => 'Sync now';

  @override
  String get addRelay => 'Add relay';

  @override
  String get restoreDefaultRelays => 'Restore default relays';

  @override
  String get createYourList => 'Create your list';

  @override
  String peopleCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count people',
      one: '1 person',
    );
    return '$_temp0';
  }

  @override
  String get closeFriendsSettingsNote =>
      'Posts, stories and videos visible only to them, with encrypted photos and videos.';

  @override
  String get mediaServersBlossom => 'Media servers (Blossom)';

  @override
  String get mediaServersExplain =>
      'Photos and videos are uploaded only to these servers, in the order shown: the first one that accepts them wins. EXIF and location are removed before uploading.';

  @override
  String get primary => 'Primary';

  @override
  String get makePrimary => 'Make primary';

  @override
  String get remove => 'Remove';

  @override
  String get addServer => 'Add server';

  @override
  String get moderation => 'Moderation';

  @override
  String get moderationExplain =>
      'Muted authors and hidden hashtags are synced via NIP-51. Blocked authors stay only on this device.';

  @override
  String get mutedAuthors => 'Muted authors';

  @override
  String get noMutedAuthors => 'No muted authors';

  @override
  String get blockedAuthors => 'Blocked authors';

  @override
  String get noBlockedAuthors => 'No blocked authors';

  @override
  String get hiddenHashtags => 'Hidden hashtags';

  @override
  String get noHiddenHashtags => 'No hidden hashtags';

  @override
  String get hashtagToHide => '#hashtag to hide';

  @override
  String get storage => 'Storage';

  @override
  String get clearCache => 'Clear event cache and drafts';

  @override
  String get cacheCleared => 'Cache cleared';

  @override
  String get reviewIntro => 'Review the introduction';

  @override
  String get reviewIntroSubtitle =>
      'What is public, what is private, and the limits of close friends.';

  @override
  String noLightningWalletCopied(Object address) {
    return 'No Lightning wallet found: address copied ($address)';
  }

  @override
  String get about => 'About';

  @override
  String aboutText(Object version) {
    return 'Mialuna $version — Your moments, under the same moon.\nOpen source (MIT). github.com/Lwb89dev/mialuna';
  }

  @override
  String get invalidRelayAddress => 'Invalid address: use wss://…';

  @override
  String get invalidServerAddress => 'Invalid address: use https://…';

  @override
  String get relayRead => 'Read';

  @override
  String get relayWrite => 'Write';

  @override
  String get support => 'Support';

  @override
  String get supportText =>
      'Mialuna is free, has no ads and does not track you. If you like it, you can send a few sats over the Lightning Network.';

  @override
  String get donateWithLightning => 'Donate with Lightning';

  @override
  String get authorNoZaps => 'This author does not accept zaps';

  @override
  String get sendZap => 'Send a zap ⚡';

  @override
  String get amountInSats => 'Amount in sats';

  @override
  String minMaxSats(Object min, Object max) {
    return 'min $min – max $max';
  }

  @override
  String get zap => 'Zap';

  @override
  String get signInToZap => 'Sign in to send zaps';

  @override
  String zapSent(Object sats) {
    return 'Zap of $sats sats sent ⚡';
  }

  @override
  String nwcPaymentFailed(Object error) {
    return 'NWC payment failed: $error';
  }

  @override
  String get noLightningWallet => 'No Lightning wallet found';

  @override
  String storiesRailLabel(Object state) {
    return 'Stories, $state';
  }

  @override
  String get close => 'Close';

  @override
  String hoursAgo(int hours) {
    return '$hours h ago';
  }

  @override
  String daysAgo(int days) {
    return '$days d ago';
  }

  @override
  String get now => 'now';

  @override
  String get youPrefix => 'You: ';

  @override
  String get storiesStateUnseen => 'new';

  @override
  String get storiesStateSeen => 'seen';

  @override
  String weekdayShort(String day) {
    String _temp0 = intl.Intl.selectLogic(day, {
      'mon': 'Mon',
      'tue': 'Tue',
      'wed': 'Wed',
      'thu': 'Thu',
      'fri': 'Fri',
      'sat': 'Sat',
      'sun': 'Sun',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get sharedAMoment => 'Shared a moment';

  @override
  String get blossomOtherError => 'error';

  @override
  String get languageTitle => 'Language';

  @override
  String get languageSystem => 'System';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageItalian => 'Italiano';

  @override
  String get cannotEditPhoto => 'This photo can\'t be edited here.';

  @override
  String notificationsNew(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count new notifications',
      one: '1 new notification',
    );
    return '$_temp0';
  }

  @override
  String messagesUnread(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count unread messages',
      one: '1 unread message',
    );
    return '$_temp0';
  }

  @override
  String get done => 'Done';

  @override
  String get storyAddText => 'Add text';

  @override
  String get storyEditText => 'Edit text';

  @override
  String get storyTextHint => 'Write something… #hashtags are tappable';

  @override
  String get storyTextsHelp =>
      'Tap the picture to write. Drag to move, pinch to resize and rotate, tap a text to edit it.';

  @override
  String storyTextsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count texts',
      one: '1 text',
      zero: 'No text',
    );
    return '$_temp0';
  }

  @override
  String get storyFontClassic => 'Classic';

  @override
  String get storyFontBold => 'Bold';

  @override
  String get storyFontSerif => 'Serif';

  @override
  String get storyFontMono => 'Mono';

  @override
  String get storyFontItalic => 'Italic';

  @override
  String get storyTextBackground => 'Text background';

  @override
  String get storyTextColor => 'Text colour';

  @override
  String storyTextLimit(int max) {
    return 'You can add up to $max texts.';
  }

  @override
  String get wotTitle => 'Web of trust';

  @override
  String get wotEnable => 'Web of trust is always on';

  @override
  String wotExplain(int min) {
    return 'Always on. Discover shows only this network: you, the people you follow, and whoever is followed by at least $min of them. The same network hides comments, notifications, private posts and messages from everyone else. It is worked out on this phone from public follow lists the first time you open the app; later opens reuse it. Nothing is sent to any server.';
  }

  @override
  String get wotRefresh => 'Refresh network now';

  @override
  String get wotStatusIdle =>
      'Not built yet. It is built the first time you open the app.';

  @override
  String get wotBuildingTitle => 'Building your Discover feed';

  @override
  String get wotBuildingBody =>
      'Reading who the people you follow also follow, and preparing Discover.';

  @override
  String get wotDiscoverHint =>
      'Only your web of trust: people you follow, and people enough of them follow.';

  @override
  String get wotDiscoverSignIn =>
      'Discover shows your web of trust. Sign in and, the first time, Mialuna reads who you follow and builds this feed. Later opens reuse it.';

  @override
  String get wotDiscoverEmpty => 'No posts from your web of trust yet.';

  @override
  String wotStatusDiscovering(int done, int total) {
    return 'Checking who your follows follow… $done of $total';
  }

  @override
  String wotStatusComplete(int direct, int indirect, Object when) {
    return 'Your network: $direct people you follow plus $indirect followed by enough of them. Updated $when.';
  }

  @override
  String wotStatusFailed(Object reason) {
    return 'Couldn\'t compute your network: $reason';
  }

  @override
  String get wotNoFollows => 'you don\'t follow anyone yet';

  @override
  String get messageRequests => 'Message requests';

  @override
  String messageRequestsSubtitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count conversations from outside your web of trust',
      one: '1 conversation from outside your web of trust',
    );
    return '$_temp0';
  }

  @override
  String get messageRequestsHint =>
      'From people outside your web of trust. They don\'t count as unread. Reply to move a conversation to your inbox.';

  @override
  String get storyViewsSetting => 'Let people see that I viewed their stories';

  @override
  String get storyViewsSettingExplain =>
      'When you watch a story, a receipt is sent to its author, encrypted so that only they can read it. It lists your name next to theirs; relays see nothing. If it cannot be delivered, it is kept and tried again later. Turn it off to watch without telling anyone: receipts not sent yet are discarded (one already delivered cannot be taken back).';

  @override
  String storySeenBy(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Seen by $count people',
      one: 'Seen by 1 person',
      zero: 'No views yet',
    );
    return '$_temp0';
  }

  @override
  String get storyViewsEmpty =>
      'Nobody has watched this story yet, or their receipts have not reached you.';

  @override
  String get storyViewsHint =>
      'Only people who allow it send a receipt, so the real number can be higher.';

  @override
  String get systemNotifications => 'System notifications';

  @override
  String get systemNotificationsExplain =>
      'Show a notification on your phone when something new arrives while Mialuna is in the background. Private messages never show their text, not even on the lock screen. Android pauses apps that stay in the background for long, so notifications arrive while Mialuna is still running.';

  @override
  String get systemNotificationsBlocked =>
      'Notifications are turned off for Mialuna in the phone\'s settings.';

  @override
  String get systemNotificationsOpenSettings => 'Open settings';

  @override
  String get systemNotificationsBattery =>
      'Android puts apps to sleep a few minutes after the screen turns off, and notifications stop with them. To keep receiving them, set Mialuna\'s battery use to “Unrestricted”.';

  @override
  String get systemNotificationsBatteryAction => 'Open battery settings';

  @override
  String get newFollowersSetting => 'Show new followers';

  @override
  String get newFollowersSettingExplain =>
      'New followers appear in Notifications and on your phone. Turn it off if people flood you with follows: likes, comments and zaps keep showing.';

  @override
  String get systemNotificationMessage => 'sent you a private message';

  @override
  String get systemNotificationNewMessage => 'New private message';

  @override
  String get systemNotificationNew => 'New notification';

  @override
  String get notificationChannelSocial =>
      'Reactions, comments, zaps and followers';

  @override
  String get notificationChannelMessages => 'Private messages';

  @override
  String get zapInvoiceMismatch =>
      'The invoice does not match the amount you chose. Nothing was paid.';

  @override
  String get storyYourStory => 'Your story';

  @override
  String get storyNew => 'New story';

  @override
  String get storyAddSemantics => 'Add to your story';

  @override
  String storyOwnRailLabel(int count, Object state) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count stories',
      one: '1 story',
    );
    return 'Your story, $_temp0, $state';
  }

  @override
  String get storyTextSize => 'Text size';

  @override
  String get storyPickPrompt => 'Choose a photo or a video for your story';

  @override
  String get storyEditPhoto => 'Edit photo';

  @override
  String get storyCaption => 'Caption';

  @override
  String get storyDiscardTitle => 'Discard this story?';

  @override
  String get storyDiscard => 'Discard';

  @override
  String get storyShare => 'Share';

  @override
  String get storyShared => 'Story shared';

  @override
  String get deletePost => 'Delete';

  @override
  String get deletePostTitle => 'Delete this post?';

  @override
  String get deleteStoryTitle => 'Delete this story?';

  @override
  String get deletePostBody =>
      'Mialuna will ask your relays to delete it and the media servers to delete its photos or video. A relay that ignores the request, or someone who already saved a copy, may still have it.';

  @override
  String get deletePrivateBody =>
      'A close-friends post can\'t be recalled from the relays. Mialuna will tell your friends\' apps to remove it and ask the media server to delete its encrypted files. A friend who already saved a copy may still have it.';

  @override
  String get deletingPost => 'Deleting…';

  @override
  String get postDeleted => 'Deleted.';

  @override
  String get postWasDeleted => 'This post was deleted.';

  @override
  String get deleteNotAllowed =>
      'Only the account that published this can delete it.';

  @override
  String deleteFailed(Object reason) {
    return 'Couldn\'t delete: $reason';
  }

  @override
  String get deleteNoRelay =>
      'No relay accepted the deletion request, so it is still online. Check your connection and try again.';

  @override
  String deleteMediaLeft(Object servers) {
    return 'The media could not be removed from $servers.';
  }

  @override
  String get deleteMediaNotAuthorized =>
      'Your signer did not authorize removing the media, so the files are still on the media server.';

  @override
  String deleteFriendsMissed(Object count) {
    return '$count of your close friends could not be told, so it may stay on their phones.';
  }

  @override
  String get storyCleanupSetting => 'Delete my stories when they expire';

  @override
  String get storyCleanupSettingExplain =>
      'After 24 hours Mialuna asks your relays and your media servers to delete your stories, their photos and videos included. A server that ignores the request, or someone who kept a copy, may still have them.';

  @override
  String storyCleanupWaiting(Object count) {
    return 'Your signer has to approve each cleanup, so it waits until you ask. Expired stories waiting: $count.';
  }

  @override
  String get storyCleanupNow => 'Delete now';

  @override
  String get storyCleanupDone => 'Expired stories deleted.';

  @override
  String get storyCleanupPartly =>
      'Some could not be deleted yet; Mialuna will try again.';
}
