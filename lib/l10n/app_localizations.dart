import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_it.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('it'),
  ];

  /// No description provided for @syncUpToDate.
  ///
  /// In en, this message translates to:
  /// **'Up to date'**
  String get syncUpToDate;

  /// No description provided for @syncFailed.
  ///
  /// In en, this message translates to:
  /// **'Sync failed'**
  String get syncFailed;

  /// No description provided for @relaysUpdatedFromProfile.
  ///
  /// In en, this message translates to:
  /// **'Relays updated from your profile (NIP-65)'**
  String get relaysUpdatedFromProfile;

  /// No description provided for @relayListPublished.
  ///
  /// In en, this message translates to:
  /// **'Relay list published'**
  String get relayListPublished;

  /// No description provided for @mediaServersUpdatedFromProfile.
  ///
  /// In en, this message translates to:
  /// **'Media servers updated from your profile'**
  String get mediaServersUpdatedFromProfile;

  /// No description provided for @tabHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get tabHome;

  /// No description provided for @tabDiscover.
  ///
  /// In en, this message translates to:
  /// **'Discover'**
  String get tabDiscover;

  /// No description provided for @tabCreate.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get tabCreate;

  /// No description provided for @tabReels.
  ///
  /// In en, this message translates to:
  /// **'Reels'**
  String get tabReels;

  /// No description provided for @tabProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get tabProfile;

  /// No description provided for @signInToUploadMedia.
  ///
  /// In en, this message translates to:
  /// **'Sign in to upload media.'**
  String get signInToUploadMedia;

  /// No description provided for @noMediaServer.
  ///
  /// In en, this message translates to:
  /// **'No media server configured. Add one in Settings.'**
  String get noMediaServer;

  /// No description provided for @serverNoResponse.
  ///
  /// In en, this message translates to:
  /// **'{server}: no response'**
  String serverNoResponse(Object server);

  /// No description provided for @serverUnreachable.
  ///
  /// In en, this message translates to:
  /// **'{server}: unreachable ({error})'**
  String serverUnreachable(Object server, Object error);

  /// No description provided for @uploadRejected.
  ///
  /// In en, this message translates to:
  /// **'Upload rejected — {reason}'**
  String uploadRejected(Object reason);

  /// No description provided for @noServerAcceptedFile.
  ///
  /// In en, this message translates to:
  /// **'No server accepted the file — {reasons}'**
  String noServerAcceptedFile(Object reasons);

  /// No description provided for @blossomInvalidResponse.
  ///
  /// In en, this message translates to:
  /// **'invalid response'**
  String get blossomInvalidResponse;

  /// No description provided for @blossomInvalidFileUrl.
  ///
  /// In en, this message translates to:
  /// **'invalid file address'**
  String get blossomInvalidFileUrl;

  /// No description provided for @blossomServerAlteredFile.
  ///
  /// In en, this message translates to:
  /// **'the server modified the file'**
  String get blossomServerAlteredFile;

  /// No description provided for @blossomBadRequest.
  ///
  /// In en, this message translates to:
  /// **'invalid request'**
  String get blossomBadRequest;

  /// No description provided for @blossomUnauthorized.
  ///
  /// In en, this message translates to:
  /// **'authorization denied'**
  String get blossomUnauthorized;

  /// No description provided for @blossomPaymentRequired.
  ///
  /// In en, this message translates to:
  /// **'payment required'**
  String get blossomPaymentRequired;

  /// No description provided for @blossomForbidden.
  ///
  /// In en, this message translates to:
  /// **'not allowed'**
  String get blossomForbidden;

  /// No description provided for @blossomLengthRequired.
  ///
  /// In en, this message translates to:
  /// **'missing size'**
  String get blossomLengthRequired;

  /// No description provided for @blossomTooLarge.
  ///
  /// In en, this message translates to:
  /// **'file too large'**
  String get blossomTooLarge;

  /// No description provided for @blossomUnsupportedType.
  ///
  /// In en, this message translates to:
  /// **'format not accepted'**
  String get blossomUnsupportedType;

  /// No description provided for @blossomTooManyRequests.
  ///
  /// In en, this message translates to:
  /// **'too many requests'**
  String get blossomTooManyRequests;

  /// No description provided for @blossomServerError.
  ///
  /// In en, this message translates to:
  /// **'server error'**
  String get blossomServerError;

  /// No description provided for @cipherInvalidKey.
  ///
  /// In en, this message translates to:
  /// **'Invalid key'**
  String get cipherInvalidKey;

  /// No description provided for @cipherTruncated.
  ///
  /// In en, this message translates to:
  /// **'Encrypted file is truncated'**
  String get cipherTruncated;

  /// No description provided for @cipherMismatch.
  ///
  /// In en, this message translates to:
  /// **'The file does not match the key: modified or corrupted'**
  String get cipherMismatch;

  /// No description provided for @sanitizeHeifNeedsAsync.
  ///
  /// In en, this message translates to:
  /// **'HEIC/AVIF format: conversion requires sanitizeAsync'**
  String get sanitizeHeifNeedsAsync;

  /// No description provided for @sanitizeWebmUnsupported.
  ///
  /// In en, this message translates to:
  /// **'WebM/MKV video is not supported: use MP4 or MOV so the metadata can be removed before uploading.'**
  String get sanitizeWebmUnsupported;

  /// No description provided for @sanitizeUnknownFormat.
  ///
  /// In en, this message translates to:
  /// **'Unrecognized file format: JPEG/PNG/WebP/GIF photos or MP4/MOV videos.'**
  String get sanitizeUnknownFormat;

  /// No description provided for @sanitizeLeftovers.
  ///
  /// In en, this message translates to:
  /// **'Could not remove all the metadata ({items}): file not uploaded.'**
  String sanitizeLeftovers(Object items);

  /// No description provided for @sanitizeProcessingFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not process the file: {error}'**
  String sanitizeProcessingFailed(Object error);

  /// No description provided for @sanitizeJpegInvalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid JPEG'**
  String get sanitizeJpegInvalid;

  /// No description provided for @sanitizeJpegTruncated.
  ///
  /// In en, this message translates to:
  /// **'Truncated JPEG'**
  String get sanitizeJpegTruncated;

  /// No description provided for @sanitizeJpegNoSize.
  ///
  /// In en, this message translates to:
  /// **'JPEG without dimensions'**
  String get sanitizeJpegNoSize;

  /// No description provided for @sanitizeJpegUndecodable.
  ///
  /// In en, this message translates to:
  /// **'JPEG cannot be decoded'**
  String get sanitizeJpegUndecodable;

  /// No description provided for @sanitizePngTruncated.
  ///
  /// In en, this message translates to:
  /// **'Truncated PNG'**
  String get sanitizePngTruncated;

  /// No description provided for @sanitizePngInvalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid PNG'**
  String get sanitizePngInvalid;

  /// No description provided for @sanitizeGifInvalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid GIF'**
  String get sanitizeGifInvalid;

  /// No description provided for @sanitizeGifTruncated.
  ///
  /// In en, this message translates to:
  /// **'Truncated GIF'**
  String get sanitizeGifTruncated;

  /// No description provided for @sanitizeWebpTruncated.
  ///
  /// In en, this message translates to:
  /// **'Truncated WebP'**
  String get sanitizeWebpTruncated;

  /// No description provided for @sanitizeWebpInvalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid WebP'**
  String get sanitizeWebpInvalid;

  /// No description provided for @sanitizeMp4Invalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid MP4/MOV video'**
  String get sanitizeMp4Invalid;

  /// No description provided for @sanitizeConversionFailed.
  ///
  /// In en, this message translates to:
  /// **'Conversion failed'**
  String get sanitizeConversionFailed;

  /// No description provided for @sanitizeHeifUnsupported.
  ///
  /// In en, this message translates to:
  /// **'This format (HEIC/AVIF) cannot be converted on this device. Choose a JPEG or PNG photo.'**
  String get sanitizeHeifUnsupported;

  /// No description provided for @privateMediaNotEncrypted.
  ///
  /// In en, this message translates to:
  /// **'Media is not encrypted'**
  String get privateMediaNotEncrypted;

  /// No description provided for @serverReplied.
  ///
  /// In en, this message translates to:
  /// **'The server replied {status}'**
  String serverReplied(Object status);

  /// No description provided for @fileTooLarge.
  ///
  /// In en, this message translates to:
  /// **'File too large'**
  String get fileTooLarge;

  /// No description provided for @serverFileNotOriginal.
  ///
  /// In en, this message translates to:
  /// **'The file on the server is not the original'**
  String get serverFileNotOriginal;

  /// No description provided for @contentMismatch.
  ///
  /// In en, this message translates to:
  /// **'The content does not match'**
  String get contentMismatch;

  /// No description provided for @mediaUnreachable.
  ///
  /// In en, this message translates to:
  /// **'Media unreachable'**
  String get mediaUnreachable;

  /// No description provided for @amberInvalidKey.
  ///
  /// In en, this message translates to:
  /// **'Amber returned an invalid key'**
  String get amberInvalidKey;

  /// No description provided for @amberNoKey.
  ///
  /// In en, this message translates to:
  /// **'Amber did not return a key'**
  String get amberNoKey;

  /// No description provided for @amberRequestRejected.
  ///
  /// In en, this message translates to:
  /// **'Request rejected in Amber'**
  String get amberRequestRejected;

  /// No description provided for @amberAndroidOnly.
  ///
  /// In en, this message translates to:
  /// **'Amber is only available on Android'**
  String get amberAndroidOnly;

  /// No description provided for @amberEmptySignature.
  ///
  /// In en, this message translates to:
  /// **'Amber returned an empty signature'**
  String get amberEmptySignature;

  /// No description provided for @amberSignRejected.
  ///
  /// In en, this message translates to:
  /// **'Signature rejected in Amber'**
  String get amberSignRejected;

  /// No description provided for @amberTimeout.
  ///
  /// In en, this message translates to:
  /// **'Amber did not answer in time'**
  String get amberTimeout;

  /// No description provided for @amberEmptyResponse.
  ///
  /// In en, this message translates to:
  /// **'Amber returned an empty response'**
  String get amberEmptyResponse;

  /// No description provided for @bunkerInvalidUrl.
  ///
  /// In en, this message translates to:
  /// **'Invalid bunker URL'**
  String get bunkerInvalidUrl;

  /// No description provided for @bunkerNoRelay.
  ///
  /// In en, this message translates to:
  /// **'The bunker does not list any relay'**
  String get bunkerNoRelay;

  /// No description provided for @bunkerWebAuth.
  ///
  /// In en, this message translates to:
  /// **'The bunker requires web authorization (auth_url is not supported)'**
  String get bunkerWebAuth;

  /// No description provided for @bunkerInvalidKey.
  ///
  /// In en, this message translates to:
  /// **'The bunker did not return a valid key'**
  String get bunkerInvalidKey;

  /// No description provided for @bunkerTimeout.
  ///
  /// In en, this message translates to:
  /// **'Bunker timed out'**
  String get bunkerTimeout;

  /// No description provided for @nwcInvalidUri.
  ///
  /// In en, this message translates to:
  /// **'Invalid NWC URI'**
  String get nwcInvalidUri;

  /// No description provided for @nwcNoRelay.
  ///
  /// In en, this message translates to:
  /// **'The NWC URI does not list any relay'**
  String get nwcNoRelay;

  /// No description provided for @nwcNoSecret.
  ///
  /// In en, this message translates to:
  /// **'The NWC URI does not contain a valid secret'**
  String get nwcNoSecret;

  /// No description provided for @nwcTimeout.
  ///
  /// In en, this message translates to:
  /// **'Wallet timed out'**
  String get nwcTimeout;

  /// No description provided for @signerNoPrivateMessages.
  ///
  /// In en, this message translates to:
  /// **'This sign-in method does not support private messages'**
  String get signerNoPrivateMessages;

  /// No description provided for @zapNotSupported.
  ///
  /// In en, this message translates to:
  /// **'This address does not support Nostr zaps'**
  String get zapNotSupported;

  /// No description provided for @zapAmountOutOfRange.
  ///
  /// In en, this message translates to:
  /// **'Amount out of range ({min}–{max} sats)'**
  String zapAmountOutOfRange(Object min, Object max);

  /// No description provided for @commentNotSent.
  ///
  /// In en, this message translates to:
  /// **'Comment not sent. Try again later.'**
  String get commentNotSent;

  /// No description provided for @comments.
  ///
  /// In en, this message translates to:
  /// **'Comments'**
  String get comments;

  /// No description provided for @noCommentsYet.
  ///
  /// In en, this message translates to:
  /// **'No comments yet.'**
  String get noCommentsYet;

  /// No description provided for @signInToComment.
  ///
  /// In en, this message translates to:
  /// **'Sign in to comment.'**
  String get signInToComment;

  /// No description provided for @addComment.
  ///
  /// In en, this message translates to:
  /// **'Add a comment…'**
  String get addComment;

  /// No description provided for @signInToPublish.
  ///
  /// In en, this message translates to:
  /// **'Sign in to publish.'**
  String get signInToPublish;

  /// No description provided for @addMediaFirst.
  ///
  /// In en, this message translates to:
  /// **'Add at least one photo or video before publishing.'**
  String get addMediaFirst;

  /// No description provided for @removingMetadata.
  ///
  /// In en, this message translates to:
  /// **'Removing metadata…'**
  String get removingMetadata;

  /// No description provided for @uploadingProgress.
  ///
  /// In en, this message translates to:
  /// **'Uploading {current} of {total}…'**
  String uploadingProgress(Object current, Object total);

  /// No description provided for @creatingPreview.
  ///
  /// In en, this message translates to:
  /// **'Creating the preview…'**
  String get creatingPreview;

  /// No description provided for @uploadFailed.
  ///
  /// In en, this message translates to:
  /// **'Upload failed: {error}'**
  String uploadFailed(Object error);

  /// No description provided for @publishing.
  ///
  /// In en, this message translates to:
  /// **'Publishing…'**
  String get publishing;

  /// No description provided for @noRelayAcceptedPost.
  ///
  /// In en, this message translates to:
  /// **'No relay accepted the post{reason}. The content stays in your drafts.'**
  String noRelayAcceptedPost(Object reason);

  /// No description provided for @privateNeedsKeySigner.
  ///
  /// In en, this message translates to:
  /// **'This sign-in method does not support private content. Use Amber, a bunker or the local key.'**
  String get privateNeedsKeySigner;

  /// No description provided for @closeFriendsListEmptyAddSomeone.
  ///
  /// In en, this message translates to:
  /// **'Your close friends list is empty: add someone.'**
  String get closeFriendsListEmptyAddSomeone;

  /// No description provided for @fileOver100Mb.
  ///
  /// In en, this message translates to:
  /// **'The file is over 100 MB: that is the limit for close friends (it is encrypted whole on your phone).'**
  String get fileOver100Mb;

  /// No description provided for @encryptingOnPhone.
  ///
  /// In en, this message translates to:
  /// **'Encrypting on your phone…'**
  String get encryptingOnPhone;

  /// No description provided for @noServerAcceptedEncrypted.
  ///
  /// In en, this message translates to:
  /// **'None of your media servers accepted the encrypted file. It is not published in the clear. Add a server that accepts encrypted files in Settings (for example cdn.hzrd149.com). {details}'**
  String noServerAcceptedEncrypted(Object details);

  /// No description provided for @sendingToFriends.
  ///
  /// In en, this message translates to:
  /// **'Sending to friends…'**
  String get sendingToFriends;

  /// No description provided for @sendingToFriendsProgress.
  ///
  /// In en, this message translates to:
  /// **'Sending to friends {done}/{total}…'**
  String sendingToFriendsProgress(Object done, Object total);

  /// No description provided for @noFriendReceivedPost.
  ///
  /// In en, this message translates to:
  /// **'No friend received the post{reason}. The content stays in your drafts.'**
  String noFriendReceivedPost(Object reason);

  /// No description provided for @sentToCloseFriends.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Sent to 1 close friend 🔒} other{Sent to {count} close friends 🔒}}'**
  String sentToCloseFriends(int count);

  /// No description provided for @sentToFriendsWithMisses.
  ///
  /// In en, this message translates to:
  /// **'{delivered, plural, =1{Sent to 1 friend.} other{Sent to {delivered} friends.}} {missed} did not receive it (private messages are off).'**
  String sentToFriendsWithMisses(int delivered, Object missed);

  /// No description provided for @altText.
  ///
  /// In en, this message translates to:
  /// **'Alt text'**
  String get altText;

  /// No description provided for @altTextHint.
  ///
  /// In en, this message translates to:
  /// **'Describe the content for people who cannot see it…'**
  String get altTextHint;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @momentPublished.
  ///
  /// In en, this message translates to:
  /// **'Moment published ✨'**
  String get momentPublished;

  /// No description provided for @newMoment.
  ///
  /// In en, this message translates to:
  /// **'New moment'**
  String get newMoment;

  /// No description provided for @publish.
  ///
  /// In en, this message translates to:
  /// **'Publish'**
  String get publish;

  /// No description provided for @guestMode.
  ///
  /// In en, this message translates to:
  /// **'Guest mode'**
  String get guestMode;

  /// No description provided for @signInToPostMoments.
  ///
  /// In en, this message translates to:
  /// **'Sign in to publish your moments.'**
  String get signInToPostMoments;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signIn;

  /// No description provided for @kindPhoto.
  ///
  /// In en, this message translates to:
  /// **'Photo'**
  String get kindPhoto;

  /// No description provided for @kindVideo.
  ///
  /// In en, this message translates to:
  /// **'Video'**
  String get kindVideo;

  /// No description provided for @kindReel.
  ///
  /// In en, this message translates to:
  /// **'Reel'**
  String get kindReel;

  /// No description provided for @kindStory.
  ///
  /// In en, this message translates to:
  /// **'Story'**
  String get kindStory;

  /// No description provided for @storyExpiryNote.
  ///
  /// In en, this message translates to:
  /// **'Stories expire after 24 hours on relays that honour NIP-40, but others can still save or archive them.'**
  String get storyExpiryNote;

  /// No description provided for @fromGallery.
  ///
  /// In en, this message translates to:
  /// **'From gallery'**
  String get fromGallery;

  /// No description provided for @galleryLongPressVideo.
  ///
  /// In en, this message translates to:
  /// **'Gallery (long-press for video)'**
  String get galleryLongPressVideo;

  /// No description provided for @addVideo.
  ///
  /// In en, this message translates to:
  /// **'Add video'**
  String get addVideo;

  /// No description provided for @camera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get camera;

  /// No description provided for @exifRemovedNote.
  ///
  /// In en, this message translates to:
  /// **'Location metadata (EXIF) is removed automatically.'**
  String get exifRemovedNote;

  /// No description provided for @writeCaption.
  ///
  /// In en, this message translates to:
  /// **'Write a caption…'**
  String get writeCaption;

  /// No description provided for @privatePostNote.
  ///
  /// In en, this message translates to:
  /// **'Private post: no public hashtags, it cannot be found through search.'**
  String get privatePostNote;

  /// No description provided for @willPublishAs.
  ///
  /// In en, this message translates to:
  /// **'It will be published as: \"{caption}\"'**
  String willPublishAs(Object caption);

  /// No description provided for @tapThumbnailForAlt.
  ///
  /// In en, this message translates to:
  /// **'Tap a thumbnail to add alt text.'**
  String get tapThumbnailForAlt;

  /// No description provided for @sensitiveContent.
  ///
  /// In en, this message translates to:
  /// **'Sensitive content'**
  String get sensitiveContent;

  /// No description provided for @sensitiveContentNote.
  ///
  /// In en, this message translates to:
  /// **'The post will be hidden behind a warning (NIP-36).'**
  String get sensitiveContentNote;

  /// No description provided for @uploadingMedia.
  ///
  /// In en, this message translates to:
  /// **'Uploading media…'**
  String get uploadingMedia;

  /// No description provided for @audiencePublic.
  ///
  /// In en, this message translates to:
  /// **'Public'**
  String get audiencePublic;

  /// No description provided for @closeFriends.
  ///
  /// In en, this message translates to:
  /// **'Close friends'**
  String get closeFriends;

  /// No description provided for @signerCannotPublishCloseFriends.
  ///
  /// In en, this message translates to:
  /// **'With this sign-in method you cannot publish for close friends: use Amber, a bunker or the local key.'**
  String get signerCannotPublishCloseFriends;

  /// No description provided for @closeFriendsEmptyPrompt.
  ///
  /// In en, this message translates to:
  /// **'Your list is empty: add the people who can see this post.'**
  String get closeFriendsEmptyPrompt;

  /// No description provided for @onlyYourCloseFriendsSee.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Only your 1 close friend will see this. Photos and videos are encrypted on your phone before they are uploaded.} other{Only your {count} close friends will see this. Photos and videos are encrypted on your phone before they are uploaded.}}'**
  String onlyYourCloseFriendsSee(int count);

  /// No description provided for @addFriends.
  ///
  /// In en, this message translates to:
  /// **'Add friends'**
  String get addFriends;

  /// No description provided for @manageList.
  ///
  /// In en, this message translates to:
  /// **'Manage the list'**
  String get manageList;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// No description provided for @cropFree.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get cropFree;

  /// No description provided for @cropOriginal.
  ///
  /// In en, this message translates to:
  /// **'Original'**
  String get cropOriginal;

  /// No description provided for @rotate.
  ///
  /// In en, this message translates to:
  /// **'Rotate'**
  String get rotate;

  /// No description provided for @flip.
  ///
  /// In en, this message translates to:
  /// **'Flip'**
  String get flip;

  /// No description provided for @brightness.
  ///
  /// In en, this message translates to:
  /// **'Brightness'**
  String get brightness;

  /// No description provided for @contrast.
  ///
  /// In en, this message translates to:
  /// **'Contrast'**
  String get contrast;

  /// No description provided for @saturation.
  ///
  /// In en, this message translates to:
  /// **'Saturation'**
  String get saturation;

  /// No description provided for @postsByAuthor.
  ///
  /// In en, this message translates to:
  /// **'Posts by {author}…'**
  String postsByAuthor(Object author);

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search people, hashtags or words…'**
  String get searchHint;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @recent.
  ///
  /// In en, this message translates to:
  /// **'Recent'**
  String get recent;

  /// No description provided for @searchDependsOnRelays.
  ///
  /// In en, this message translates to:
  /// **'Search depends on the configured relays: results may be partial.'**
  String get searchDependsOnRelays;

  /// No description provided for @recentPostsEverywhere.
  ///
  /// In en, this message translates to:
  /// **'Recent posts from the whole network, including people you do not follow.'**
  String get recentPostsEverywhere;

  /// No description provided for @noResultsOnRelays.
  ///
  /// In en, this message translates to:
  /// **'No results on the configured relays.'**
  String get noResultsOnRelays;

  /// No description provided for @noRecentPostsFromFollowed.
  ///
  /// In en, this message translates to:
  /// **'No recent posts from the people you follow.'**
  String get noRecentPostsFromFollowed;

  /// No description provided for @noMomentsFound.
  ///
  /// In en, this message translates to:
  /// **'No moments found on the relays. Check your connection.'**
  String get noMomentsFound;

  /// No description provided for @loadFailed.
  ///
  /// In en, this message translates to:
  /// **'Loading failed'**
  String get loadFailed;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @messages.
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get messages;

  /// No description provided for @homeEmptyFollowsNobody.
  ///
  /// In en, this message translates to:
  /// **'Posts from the people you follow appear here.\nYou do not follow anyone yet: discover interesting people and profiles.'**
  String get homeEmptyFollowsNobody;

  /// No description provided for @discoverPeople.
  ///
  /// In en, this message translates to:
  /// **'Discover people'**
  String get discoverPeople;

  /// No description provided for @homeEmpty.
  ///
  /// In en, this message translates to:
  /// **'No moments yet.\nPull down to refresh or publish your first shot.'**
  String get homeEmpty;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get retry;

  /// No description provided for @seenEverything.
  ///
  /// In en, this message translates to:
  /// **'You have seen everything for now ✨'**
  String get seenEverything;

  /// No description provided for @discoverMoreProfiles.
  ///
  /// In en, this message translates to:
  /// **'Discover more profiles'**
  String get discoverMoreProfiles;

  /// No description provided for @feedFollowing.
  ///
  /// In en, this message translates to:
  /// **'Following'**
  String get feedFollowing;

  /// No description provided for @signInToSeeFollowed.
  ///
  /// In en, this message translates to:
  /// **'Sign in to see posts from the people you follow'**
  String get signInToSeeFollowed;

  /// No description provided for @videoPreview.
  ///
  /// In en, this message translates to:
  /// **'Video preview'**
  String get videoPreview;

  /// No description provided for @cannotOpenPrivateVideo.
  ///
  /// In en, this message translates to:
  /// **'Cannot open the private video'**
  String get cannotOpenPrivateVideo;

  /// No description provided for @cannotPlayVideo.
  ///
  /// In en, this message translates to:
  /// **'Cannot play the video'**
  String get cannotPlayVideo;

  /// No description provided for @pauseVideo.
  ///
  /// In en, this message translates to:
  /// **'Pause the video'**
  String get pauseVideo;

  /// No description provided for @playVideo.
  ///
  /// In en, this message translates to:
  /// **'Play the video'**
  String get playVideo;

  /// No description provided for @errorTapToRetry.
  ///
  /// In en, this message translates to:
  /// **'{error} — tap to retry'**
  String errorTapToRetry(Object error);

  /// No description provided for @soundOn.
  ///
  /// In en, this message translates to:
  /// **'Turn the sound on'**
  String get soundOn;

  /// No description provided for @soundOff.
  ///
  /// In en, this message translates to:
  /// **'Turn the sound off'**
  String get soundOff;

  /// No description provided for @postImage.
  ///
  /// In en, this message translates to:
  /// **'Post image'**
  String get postImage;

  /// No description provided for @imageUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Image not available'**
  String get imageUnavailable;

  /// No description provided for @errorTapToRetryNewline.
  ///
  /// In en, this message translates to:
  /// **'{message}\nTap to retry'**
  String errorTapToRetryNewline(Object message);

  /// No description provided for @cannotOpenPrivateContent.
  ///
  /// In en, this message translates to:
  /// **'Cannot open this private content'**
  String get cannotOpenPrivateContent;

  /// No description provided for @privateImage.
  ///
  /// In en, this message translates to:
  /// **'Private image'**
  String get privateImage;

  /// No description provided for @invalidImage.
  ///
  /// In en, this message translates to:
  /// **'Invalid image'**
  String get invalidImage;

  /// No description provided for @more.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get more;

  /// No description provided for @removeFromSaved.
  ///
  /// In en, this message translates to:
  /// **'Remove from saved'**
  String get removeFromSaved;

  /// No description provided for @copyLink.
  ///
  /// In en, this message translates to:
  /// **'Copy link'**
  String get copyLink;

  /// No description provided for @muteAuthor.
  ///
  /// In en, this message translates to:
  /// **'Mute author'**
  String get muteAuthor;

  /// No description provided for @blockAuthor.
  ///
  /// In en, this message translates to:
  /// **'Block author'**
  String get blockAuthor;

  /// No description provided for @report.
  ///
  /// In en, this message translates to:
  /// **'Report'**
  String get report;

  /// No description provided for @like.
  ///
  /// In en, this message translates to:
  /// **'Like'**
  String get like;

  /// No description provided for @sendInMessage.
  ///
  /// In en, this message translates to:
  /// **'Send in a message'**
  String get sendInMessage;

  /// No description provided for @zapOptional.
  ///
  /// In en, this message translates to:
  /// **'Zap (optional)'**
  String get zapOptional;

  /// No description provided for @closeFriendsOnlyNote.
  ///
  /// In en, this message translates to:
  /// **'Visible only to close friends. Likes and replies go only to the author.'**
  String get closeFriendsOnlyNote;

  /// No description provided for @likeFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not send the like'**
  String get likeFailed;

  /// No description provided for @nostrLinkCopied.
  ///
  /// In en, this message translates to:
  /// **'Nostr link copied to the clipboard'**
  String get nostrLinkCopied;

  /// No description provided for @authorMuted.
  ///
  /// In en, this message translates to:
  /// **'Author muted'**
  String get authorMuted;

  /// No description provided for @authorBlocked.
  ///
  /// In en, this message translates to:
  /// **'Author blocked'**
  String get authorBlocked;

  /// No description provided for @reportSent.
  ///
  /// In en, this message translates to:
  /// **'Report sent (NIP-56)'**
  String get reportSent;

  /// No description provided for @signInToReport.
  ///
  /// In en, this message translates to:
  /// **'Sign in to report'**
  String get signInToReport;

  /// No description provided for @minutesAgo.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min ago'**
  String minutesAgo(Object minutes);

  /// No description provided for @show.
  ///
  /// In en, this message translates to:
  /// **'Show'**
  String get show;

  /// No description provided for @chatEmptyHint.
  ///
  /// In en, this message translates to:
  /// **'Write the first message.\nIt is encrypted: only the two of you can see it.'**
  String get chatEmptyHint;

  /// No description provided for @messageHint.
  ///
  /// In en, this message translates to:
  /// **'Message…'**
  String get messageHint;

  /// No description provided for @send.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;

  /// No description provided for @notSentSuffix.
  ///
  /// In en, this message translates to:
  /// **' not sent'**
  String get notSentSuffix;

  /// No description provided for @contentUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Content not available (expired or not found on the relays)'**
  String get contentUnavailable;

  /// No description provided for @signInToSendPrivateMessages.
  ///
  /// In en, this message translates to:
  /// **'Sign in to send private messages.'**
  String get signInToSendPrivateMessages;

  /// No description provided for @cannotMessageYourself.
  ///
  /// In en, this message translates to:
  /// **'You cannot write to yourself.'**
  String get cannotMessageYourself;

  /// No description provided for @recipientNoPrivateMessages.
  ///
  /// In en, this message translates to:
  /// **'This person has not turned on private messages yet.'**
  String get recipientNoPrivateMessages;

  /// No description provided for @noRecipientRelayAccepted.
  ///
  /// In en, this message translates to:
  /// **'No recipient relay accepted the message{reason}.'**
  String noRecipientRelayAccepted(Object reason);

  /// No description provided for @sendFailed.
  ///
  /// In en, this message translates to:
  /// **'Sending failed: {error}'**
  String sendFailed(Object error);

  /// No description provided for @signInToReadMessages.
  ///
  /// In en, this message translates to:
  /// **'Sign in to read and send private messages.'**
  String get signInToReadMessages;

  /// No description provided for @signerNoPrivateMessagesLong.
  ///
  /// In en, this message translates to:
  /// **'Private messages cannot be used with this sign-in method. Sign in with Amber, a bunker or the local key.'**
  String get signerNoPrivateMessagesLong;

  /// No description provided for @inboxEmpty.
  ///
  /// In en, this message translates to:
  /// **'No conversations.\nTap the pencil to write to someone, or forward a moment with the ✈ icon under every post.'**
  String get inboxEmpty;

  /// No description provided for @newMessage.
  ///
  /// In en, this message translates to:
  /// **'New message'**
  String get newMessage;

  /// No description provided for @privateMessagesEnabled.
  ///
  /// In en, this message translates to:
  /// **'Private messages turned on'**
  String get privateMessagesEnabled;

  /// No description provided for @enableMessagesFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not turn them on. Try again.'**
  String get enableMessagesFailed;

  /// No description provided for @enablePrivateMessages.
  ///
  /// In en, this message translates to:
  /// **'Turn on private messages'**
  String get enablePrivateMessages;

  /// No description provided for @enablePrivateMessagesExplain.
  ///
  /// In en, this message translates to:
  /// **'To receive messages you need to say which relays they should arrive on. A small list (NIP-17) is published with {count} default relays: you can change it later. Messages stay encrypted: relays see neither who writes nor the text.'**
  String enablePrivateMessagesExplain(Object count);

  /// No description provided for @turnOn.
  ///
  /// In en, this message translates to:
  /// **'Turn on'**
  String get turnOn;

  /// No description provided for @searchByNameOrUsername.
  ///
  /// In en, this message translates to:
  /// **'Search by name or username'**
  String get searchByNameOrUsername;

  /// No description provided for @searching.
  ///
  /// In en, this message translates to:
  /// **'Searching…'**
  String get searching;

  /// No description provided for @noOneWithNameHint.
  ///
  /// In en, this message translates to:
  /// **'Nobody with this name. Try fewer letters or an address like name@domain.com.'**
  String get noOneWithNameHint;

  /// No description provided for @sent.
  ///
  /// In en, this message translates to:
  /// **'Sent'**
  String get sent;

  /// No description provided for @sentToPeople.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Sent to 1 person} other{Sent to {count} people}}'**
  String sentToPeople(int count);

  /// No description provided for @sentToPeopleWithFailure.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Sent to 1 person. {failure}} other{Sent to {count} people. {failure}}}'**
  String sentToPeopleWithFailure(int count, Object failure);

  /// No description provided for @signerNoPrivateMessagesShort.
  ///
  /// In en, this message translates to:
  /// **'You cannot use private messages with this sign-in method.'**
  String get signerNoPrivateMessagesShort;

  /// No description provided for @followToStartOrSearch.
  ///
  /// In en, this message translates to:
  /// **'Follow someone to start, or search by name.'**
  String get followToStartOrSearch;

  /// No description provided for @addMessage.
  ///
  /// In en, this message translates to:
  /// **'Add a message…'**
  String get addMessage;

  /// No description provided for @sendWithCount.
  ///
  /// In en, this message translates to:
  /// **'Send ({count})'**
  String sendWithCount(Object count);

  /// No description provided for @linkCopied.
  ///
  /// In en, this message translates to:
  /// **'Link copied to the clipboard'**
  String get linkCopied;

  /// No description provided for @noNotifications.
  ///
  /// In en, this message translates to:
  /// **'No notifications right now.'**
  String get noNotifications;

  /// No description provided for @notificationsDependOnRelays.
  ///
  /// In en, this message translates to:
  /// **'Notifications depend on relays: they may be incomplete.'**
  String get notificationsDependOnRelays;

  /// No description provided for @reactedToYourMoment.
  ///
  /// In en, this message translates to:
  /// **'reacted to your moment'**
  String get reactedToYourMoment;

  /// No description provided for @commentedText.
  ///
  /// In en, this message translates to:
  /// **'commented: {text}'**
  String commentedText(Object text);

  /// No description provided for @sentYouSats.
  ///
  /// In en, this message translates to:
  /// **'sent you {sats} sats{comment}'**
  String sentYouSats(Object sats, Object comment);

  /// No description provided for @sentYouZap.
  ///
  /// In en, this message translates to:
  /// **'sent you a zap'**
  String get sentYouZap;

  /// No description provided for @startedFollowingYou.
  ///
  /// In en, this message translates to:
  /// **'started following you'**
  String get startedFollowingYou;

  /// No description provided for @amberNotFound.
  ///
  /// In en, this message translates to:
  /// **'Amber not found'**
  String get amberNotFound;

  /// No description provided for @amberExplain.
  ///
  /// In en, this message translates to:
  /// **'Amber is a Nostr signer that keeps your private key outside Mialuna. Install it and try again.'**
  String get amberExplain;

  /// No description provided for @downloadFromFdroid.
  ///
  /// In en, this message translates to:
  /// **'Download from F-Droid'**
  String get downloadFromFdroid;

  /// No description provided for @continueWithAmber.
  ///
  /// In en, this message translates to:
  /// **'Continue with Amber'**
  String get continueWithAmber;

  /// No description provided for @amberRecommended.
  ///
  /// In en, this message translates to:
  /// **'Recommended: your private key stays safe in Amber.'**
  String get amberRecommended;

  /// No description provided for @amberNotDetected.
  ///
  /// In en, this message translates to:
  /// **'Amber not detected: install it for the recommended sign-in.'**
  String get amberNotDetected;

  /// No description provided for @exploreWithoutAccount.
  ///
  /// In en, this message translates to:
  /// **'Explore without an account'**
  String get exploreWithoutAccount;

  /// No description provided for @remoteBunker.
  ///
  /// In en, this message translates to:
  /// **'Remote bunker (NIP-46)'**
  String get remoteBunker;

  /// No description provided for @invalidBunkerUrlDot.
  ///
  /// In en, this message translates to:
  /// **'Invalid bunker URL.'**
  String get invalidBunkerUrlDot;

  /// No description provided for @connectBunker.
  ///
  /// In en, this message translates to:
  /// **'Connect bunker'**
  String get connectBunker;

  /// No description provided for @advancedNsec.
  ///
  /// In en, this message translates to:
  /// **'Advanced sign-in (nsec)'**
  String get advancedNsec;

  /// No description provided for @nsecWarning.
  ///
  /// In en, this message translates to:
  /// **'Warning: pasting your private key is risky. Never share it with anyone. On Android prefer Amber.'**
  String get nsecWarning;

  /// No description provided for @invalidNsec.
  ///
  /// In en, this message translates to:
  /// **'Invalid nsec key.'**
  String get invalidNsec;

  /// No description provided for @signInWithNsec.
  ///
  /// In en, this message translates to:
  /// **'Sign in with nsec'**
  String get signInWithNsec;

  /// No description provided for @tagline.
  ///
  /// In en, this message translates to:
  /// **'Your moments, under the same moon.'**
  String get tagline;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @permissionsAndWallet.
  ///
  /// In en, this message translates to:
  /// **'Permissions and wallet'**
  String get permissionsAndWallet;

  /// No description provided for @permissionsExplain.
  ///
  /// In en, this message translates to:
  /// **'They only let you publish and receive notifications. You can change them at any time in the system settings.'**
  String get permissionsExplain;

  /// No description provided for @photosAndVideos.
  ///
  /// In en, this message translates to:
  /// **'Photos and videos'**
  String get photosAndVideos;

  /// No description provided for @toUploadYourMoments.
  ///
  /// In en, this message translates to:
  /// **'To upload your moments'**
  String get toUploadYourMoments;

  /// No description provided for @allow.
  ///
  /// In en, this message translates to:
  /// **'Allow'**
  String get allow;

  /// No description provided for @reactionsCommentsZaps.
  ///
  /// In en, this message translates to:
  /// **'Reactions, comments and zaps'**
  String get reactionsCommentsZaps;

  /// No description provided for @lightningWalletOptional.
  ///
  /// In en, this message translates to:
  /// **'Lightning wallet (optional)'**
  String get lightningWalletOptional;

  /// No description provided for @nwcExplain.
  ///
  /// In en, this message translates to:
  /// **'Connect a Nostr Wallet Connect wallet to send zaps without leaving the app.'**
  String get nwcExplain;

  /// No description provided for @walletConnected.
  ///
  /// In en, this message translates to:
  /// **'Wallet connected'**
  String get walletConnected;

  /// No description provided for @disconnect.
  ///
  /// In en, this message translates to:
  /// **'Disconnect'**
  String get disconnect;

  /// No description provided for @connectWallet.
  ///
  /// In en, this message translates to:
  /// **'Connect wallet'**
  String get connectWallet;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get getStarted;

  /// No description provided for @welcome1.
  ///
  /// In en, this message translates to:
  /// **'Mialuna is a visual social network: photos, videos, Reels and Stories — never text-only posts.'**
  String get welcome1;

  /// No description provided for @welcome2.
  ///
  /// In en, this message translates to:
  /// **'It runs on Nostr, an open protocol: your identity is a key you own, not an account a company can take away. No ads, no trackers, no central servers.'**
  String get welcome2;

  /// No description provided for @welcome3.
  ///
  /// In en, this message translates to:
  /// **'Share your light with people everywhere, from any app that speaks the same open language.'**
  String get welcome3;

  /// No description provided for @publicAndPrivate.
  ///
  /// In en, this message translates to:
  /// **'Public and private'**
  String get publicAndPrivate;

  /// No description provided for @publicAndPrivateIntro.
  ///
  /// In en, this message translates to:
  /// **'Mialuna is built on Nostr, an open network. What you publish is public: posts, photos and videos stay visible to anyone with the link, even outside Mialuna.'**
  String get publicAndPrivateIntro;

  /// No description provided for @closeFriendsExplain1.
  ///
  /// In en, this message translates to:
  /// **'Only the people on this list receive your \"Close friends\" posts, stories and videos. The list is inside the post; you do not have to pick it every time.'**
  String get closeFriendsExplain1;

  /// No description provided for @closeFriendsExplain2.
  ///
  /// In en, this message translates to:
  /// **'Photos and videos are encrypted on your phone before they are uploaded. File servers (Blossom) do not encrypt anything by themselves: that is why Mialuna does it, and the server only sees unreadable data. Whoever finds the file address cannot open it.'**
  String get closeFriendsExplain2;

  /// No description provided for @closeFriendsExplain3.
  ///
  /// In en, this message translates to:
  /// **'It is not an absolute guarantee: whoever receives a post can take a screenshot, and removing a friend only applies to future posts.'**
  String get closeFriendsExplain3;

  /// No description provided for @closeFriendsExplain4.
  ///
  /// In en, this message translates to:
  /// **'Every friend must use Mialuna with private messages turned on. Other Nostr clients do not show these posts.'**
  String get closeFriendsExplain4;

  /// No description provided for @closeFriendsExplain5.
  ///
  /// In en, this message translates to:
  /// **'Public posts stay public: their files are visible to anyone with the link.'**
  String get closeFriendsExplain5;

  /// No description provided for @closeFriendsExplain6.
  ///
  /// In en, this message translates to:
  /// **'If none of your servers accepts encrypted files, the post is not published: never in the clear.'**
  String get closeFriendsExplain6;

  /// No description provided for @addToCloseFriends.
  ///
  /// In en, this message translates to:
  /// **'Add to close friends'**
  String get addToCloseFriends;

  /// No description provided for @maxFriendsReached.
  ///
  /// In en, this message translates to:
  /// **'Limit of {max} friends: {added} added.'**
  String maxFriendsReached(Object max, Object added);

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @signInToCreateList.
  ///
  /// In en, this message translates to:
  /// **'Sign in to create your list.'**
  String get signInToCreateList;

  /// No description provided for @signerNoCloseFriends.
  ///
  /// In en, this message translates to:
  /// **'Close friends cannot be used with this sign-in method. Sign in with Amber, a bunker or the local key.'**
  String get signerNoCloseFriends;

  /// No description provided for @peopleOfMax.
  ///
  /// In en, this message translates to:
  /// **'{count} / {max} people'**
  String peopleOfMax(Object count, Object max);

  /// No description provided for @noOneYet.
  ///
  /// In en, this message translates to:
  /// **'Nobody yet.'**
  String get noOneYet;

  /// No description provided for @addPeople.
  ///
  /// In en, this message translates to:
  /// **'Add people'**
  String get addPeople;

  /// No description provided for @friendNoPrivateMessagesWarning.
  ///
  /// In en, this message translates to:
  /// **'They have not turned on private messages: they will not receive your posts'**
  String get friendNoPrivateMessagesWarning;

  /// No description provided for @removeFromList.
  ///
  /// In en, this message translates to:
  /// **'Remove from the list'**
  String get removeFromList;

  /// No description provided for @noOneWithThisName.
  ///
  /// In en, this message translates to:
  /// **'Nobody with this name.'**
  String get noOneWithThisName;

  /// No description provided for @signInToSendPrivateContent.
  ///
  /// In en, this message translates to:
  /// **'Sign in to send private content.'**
  String get signInToSendPrivateContent;

  /// No description provided for @reasonNoPrivateMessages.
  ///
  /// In en, this message translates to:
  /// **'has not turned on private messages'**
  String get reasonNoPrivateMessages;

  /// No description provided for @reasonNoRelayAnswered.
  ///
  /// In en, this message translates to:
  /// **'no relay answered'**
  String get reasonNoRelayAnswered;

  /// No description provided for @profileUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile updated'**
  String get profileUpdated;

  /// No description provided for @noRelayAcceptedRetry.
  ///
  /// In en, this message translates to:
  /// **'No relay accepted it. Try again later.'**
  String get noRelayAcceptedRetry;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get editProfile;

  /// No description provided for @fieldName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get fieldName;

  /// No description provided for @fieldBio.
  ///
  /// In en, this message translates to:
  /// **'Bio'**
  String get fieldBio;

  /// No description provided for @fieldAvatarUrl.
  ///
  /// In en, this message translates to:
  /// **'Avatar URL'**
  String get fieldAvatarUrl;

  /// No description provided for @fieldNip05.
  ///
  /// In en, this message translates to:
  /// **'NIP-05 (e.g. you@example.com)'**
  String get fieldNip05;

  /// No description provided for @browsingAsGuest.
  ///
  /// In en, this message translates to:
  /// **'You are browsing as a guest'**
  String get browsingAsGuest;

  /// No description provided for @signInToInteract.
  ///
  /// In en, this message translates to:
  /// **'Sign in to publish, follow and interact.'**
  String get signInToInteract;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// No description provided for @npubCopied.
  ///
  /// In en, this message translates to:
  /// **'npub copied'**
  String get npubCopied;

  /// No description provided for @copyNpub.
  ///
  /// In en, this message translates to:
  /// **'Copy npub'**
  String get copyNpub;

  /// No description provided for @mute.
  ///
  /// In en, this message translates to:
  /// **'Mute'**
  String get mute;

  /// No description provided for @block.
  ///
  /// In en, this message translates to:
  /// **'Block'**
  String get block;

  /// No description provided for @posts.
  ///
  /// In en, this message translates to:
  /// **'Posts'**
  String get posts;

  /// No description provided for @saved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get saved;

  /// No description provided for @nothingPublishedYet.
  ///
  /// In en, this message translates to:
  /// **'You have not published anything yet.'**
  String get nothingPublishedYet;

  /// No description provided for @noPostsOnRelays.
  ///
  /// In en, this message translates to:
  /// **'No posts found on the relays.'**
  String get noPostsOnRelays;

  /// No description provided for @noReelsPublished.
  ///
  /// In en, this message translates to:
  /// **'No reels published.'**
  String get noReelsPublished;

  /// No description provided for @noReelsOnRelays.
  ///
  /// In en, this message translates to:
  /// **'No reels found on the relays.'**
  String get noReelsOnRelays;

  /// No description provided for @noSavedPosts.
  ///
  /// In en, this message translates to:
  /// **'No saved posts.'**
  String get noSavedPosts;

  /// No description provided for @followingButton.
  ///
  /// In en, this message translates to:
  /// **'Following'**
  String get followingButton;

  /// No description provided for @follow.
  ///
  /// In en, this message translates to:
  /// **'Follow'**
  String get follow;

  /// No description provided for @messageButton.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get messageButton;

  /// No description provided for @loginLocalKey.
  ///
  /// In en, this message translates to:
  /// **'Local key'**
  String get loginLocalKey;

  /// No description provided for @loginGuest.
  ///
  /// In en, this message translates to:
  /// **'Guest'**
  String get loginGuest;

  /// No description provided for @followUpdateFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not update your follows right now. Try again.'**
  String get followUpdateFailed;

  /// No description provided for @noReelsComeBack.
  ///
  /// In en, this message translates to:
  /// **'No reels found on the relays.\nCome back soon!'**
  String get noReelsComeBack;

  /// No description provided for @followUpdateFailedShort.
  ///
  /// In en, this message translates to:
  /// **'Could not update your follows right now'**
  String get followUpdateFailedShort;

  /// No description provided for @needOneReadRelay.
  ///
  /// In en, this message translates to:
  /// **'At least one read relay is required.'**
  String get needOneReadRelay;

  /// No description provided for @listSavedLocally.
  ///
  /// In en, this message translates to:
  /// **'List saved on this device, not published.'**
  String get listSavedLocally;

  /// No description provided for @noRelayAcceptedList.
  ///
  /// In en, this message translates to:
  /// **'No relay accepted the list: it will be retried later.'**
  String get noRelayAcceptedList;

  /// No description provided for @relayListPublishedTo.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Relay list published to 1 relay} other{Relay list published to {count} relays}}'**
  String relayListPublishedTo(int count);

  /// No description provided for @mediaServersUpdated.
  ///
  /// In en, this message translates to:
  /// **'Media servers updated'**
  String get mediaServersUpdated;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @relays.
  ///
  /// In en, this message translates to:
  /// **'Relays'**
  String get relays;

  /// No description provided for @relaysExplainSignedOut.
  ///
  /// In en, this message translates to:
  /// **'Relays store and distribute content. Sign in to use your own list automatically (NIP-65).'**
  String get relaysExplainSignedOut;

  /// No description provided for @relaysExplainSynced.
  ///
  /// In en, this message translates to:
  /// **'The list is synced with your Nostr profile (NIP-65): every change is published and applies to all your apps.'**
  String get relaysExplainSynced;

  /// No description provided for @syncing.
  ///
  /// In en, this message translates to:
  /// **'Syncing…'**
  String get syncing;

  /// No description provided for @waitingFirstSync.
  ///
  /// In en, this message translates to:
  /// **'Waiting for the first sync'**
  String get waitingFirstSync;

  /// No description provided for @syncNow.
  ///
  /// In en, this message translates to:
  /// **'Sync now'**
  String get syncNow;

  /// No description provided for @addRelay.
  ///
  /// In en, this message translates to:
  /// **'Add relay'**
  String get addRelay;

  /// No description provided for @restoreDefaultRelays.
  ///
  /// In en, this message translates to:
  /// **'Restore default relays'**
  String get restoreDefaultRelays;

  /// No description provided for @createYourList.
  ///
  /// In en, this message translates to:
  /// **'Create your list'**
  String get createYourList;

  /// No description provided for @peopleCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 person} other{{count} people}}'**
  String peopleCount(int count);

  /// No description provided for @closeFriendsSettingsNote.
  ///
  /// In en, this message translates to:
  /// **'Posts, stories and videos visible only to them, with encrypted photos and videos.'**
  String get closeFriendsSettingsNote;

  /// No description provided for @mediaServersBlossom.
  ///
  /// In en, this message translates to:
  /// **'Media servers (Blossom)'**
  String get mediaServersBlossom;

  /// No description provided for @mediaServersExplain.
  ///
  /// In en, this message translates to:
  /// **'Photos and videos are uploaded only to these servers, in the order shown: the first one that accepts them wins. EXIF and location are removed before uploading.'**
  String get mediaServersExplain;

  /// No description provided for @primary.
  ///
  /// In en, this message translates to:
  /// **'Primary'**
  String get primary;

  /// No description provided for @makePrimary.
  ///
  /// In en, this message translates to:
  /// **'Make primary'**
  String get makePrimary;

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// No description provided for @addServer.
  ///
  /// In en, this message translates to:
  /// **'Add server'**
  String get addServer;

  /// No description provided for @moderation.
  ///
  /// In en, this message translates to:
  /// **'Moderation'**
  String get moderation;

  /// No description provided for @moderationExplain.
  ///
  /// In en, this message translates to:
  /// **'Muted authors and hidden hashtags are synced via NIP-51. Blocked authors stay only on this device.'**
  String get moderationExplain;

  /// No description provided for @mutedAuthors.
  ///
  /// In en, this message translates to:
  /// **'Muted authors'**
  String get mutedAuthors;

  /// No description provided for @noMutedAuthors.
  ///
  /// In en, this message translates to:
  /// **'No muted authors'**
  String get noMutedAuthors;

  /// No description provided for @blockedAuthors.
  ///
  /// In en, this message translates to:
  /// **'Blocked authors'**
  String get blockedAuthors;

  /// No description provided for @noBlockedAuthors.
  ///
  /// In en, this message translates to:
  /// **'No blocked authors'**
  String get noBlockedAuthors;

  /// No description provided for @hiddenHashtags.
  ///
  /// In en, this message translates to:
  /// **'Hidden hashtags'**
  String get hiddenHashtags;

  /// No description provided for @noHiddenHashtags.
  ///
  /// In en, this message translates to:
  /// **'No hidden hashtags'**
  String get noHiddenHashtags;

  /// No description provided for @hashtagToHide.
  ///
  /// In en, this message translates to:
  /// **'#hashtag to hide'**
  String get hashtagToHide;

  /// No description provided for @storage.
  ///
  /// In en, this message translates to:
  /// **'Storage'**
  String get storage;

  /// No description provided for @clearCache.
  ///
  /// In en, this message translates to:
  /// **'Clear event cache and drafts'**
  String get clearCache;

  /// No description provided for @cacheCleared.
  ///
  /// In en, this message translates to:
  /// **'Cache cleared'**
  String get cacheCleared;

  /// No description provided for @reviewIntro.
  ///
  /// In en, this message translates to:
  /// **'Review the introduction'**
  String get reviewIntro;

  /// No description provided for @reviewIntroSubtitle.
  ///
  /// In en, this message translates to:
  /// **'What is public, what is private, and the limits of close friends.'**
  String get reviewIntroSubtitle;

  /// No description provided for @noLightningWalletCopied.
  ///
  /// In en, this message translates to:
  /// **'No Lightning wallet found: address copied ({address})'**
  String noLightningWalletCopied(Object address);

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @aboutText.
  ///
  /// In en, this message translates to:
  /// **'Mialuna {version} — Your moments, under the same moon.\nOpen source (MIT). github.com/Lwb89dev/mialuna'**
  String aboutText(Object version);

  /// No description provided for @invalidRelayAddress.
  ///
  /// In en, this message translates to:
  /// **'Invalid address: use wss://…'**
  String get invalidRelayAddress;

  /// No description provided for @relayRead.
  ///
  /// In en, this message translates to:
  /// **'Read'**
  String get relayRead;

  /// No description provided for @relayWrite.
  ///
  /// In en, this message translates to:
  /// **'Write'**
  String get relayWrite;

  /// No description provided for @support.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get support;

  /// No description provided for @supportText.
  ///
  /// In en, this message translates to:
  /// **'Mialuna is free, has no ads and does not track you. If you like it, you can send a few sats over the Lightning Network.'**
  String get supportText;

  /// No description provided for @donateWithLightning.
  ///
  /// In en, this message translates to:
  /// **'Donate with Lightning'**
  String get donateWithLightning;

  /// No description provided for @authorNoZaps.
  ///
  /// In en, this message translates to:
  /// **'This author does not accept zaps'**
  String get authorNoZaps;

  /// No description provided for @sendZap.
  ///
  /// In en, this message translates to:
  /// **'Send a zap ⚡'**
  String get sendZap;

  /// No description provided for @amountInSats.
  ///
  /// In en, this message translates to:
  /// **'Amount in sats'**
  String get amountInSats;

  /// No description provided for @minMaxSats.
  ///
  /// In en, this message translates to:
  /// **'min {min} – max {max}'**
  String minMaxSats(Object min, Object max);

  /// No description provided for @zap.
  ///
  /// In en, this message translates to:
  /// **'Zap'**
  String get zap;

  /// No description provided for @signInToZap.
  ///
  /// In en, this message translates to:
  /// **'Sign in to send zaps'**
  String get signInToZap;

  /// No description provided for @zapSent.
  ///
  /// In en, this message translates to:
  /// **'Zap of {sats} sats sent ⚡'**
  String zapSent(Object sats);

  /// No description provided for @nwcPaymentFailed.
  ///
  /// In en, this message translates to:
  /// **'NWC payment failed: {error}'**
  String nwcPaymentFailed(Object error);

  /// No description provided for @noLightningWallet.
  ///
  /// In en, this message translates to:
  /// **'No Lightning wallet found'**
  String get noLightningWallet;

  /// No description provided for @storiesRailLabel.
  ///
  /// In en, this message translates to:
  /// **'Stories, {state}'**
  String storiesRailLabel(Object state);

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @hoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{hours} h ago'**
  String hoursAgo(int hours);

  /// No description provided for @daysAgo.
  ///
  /// In en, this message translates to:
  /// **'{days} d ago'**
  String daysAgo(int days);

  /// No description provided for @now.
  ///
  /// In en, this message translates to:
  /// **'now'**
  String get now;

  /// No description provided for @youPrefix.
  ///
  /// In en, this message translates to:
  /// **'You: '**
  String get youPrefix;

  /// No description provided for @storiesStateUnseen.
  ///
  /// In en, this message translates to:
  /// **'new'**
  String get storiesStateUnseen;

  /// No description provided for @storiesStateSeen.
  ///
  /// In en, this message translates to:
  /// **'seen'**
  String get storiesStateSeen;

  /// No description provided for @weekdayShort.
  ///
  /// In en, this message translates to:
  /// **'{day, select, mon{Mon} tue{Tue} wed{Wed} thu{Thu} fri{Fri} sat{Sat} sun{Sun} other{}}'**
  String weekdayShort(String day);

  /// No description provided for @sharedAMoment.
  ///
  /// In en, this message translates to:
  /// **'Shared a moment'**
  String get sharedAMoment;

  /// No description provided for @blossomOtherError.
  ///
  /// In en, this message translates to:
  /// **'error'**
  String get blossomOtherError;

  /// No description provided for @languageTitle.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageTitle;

  /// No description provided for @languageSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get languageSystem;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageItalian.
  ///
  /// In en, this message translates to:
  /// **'Italiano'**
  String get languageItalian;

  /// No description provided for @cannotEditPhoto.
  ///
  /// In en, this message translates to:
  /// **'This photo can\'t be edited here.'**
  String get cannotEditPhoto;

  /// No description provided for @notificationsNew.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 new notification} other{{count} new notifications}}'**
  String notificationsNew(int count);

  /// No description provided for @messagesUnread.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 unread message} other{{count} unread messages}}'**
  String messagesUnread(int count);

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @storyAddText.
  ///
  /// In en, this message translates to:
  /// **'Add text'**
  String get storyAddText;

  /// No description provided for @storyEditText.
  ///
  /// In en, this message translates to:
  /// **'Edit text'**
  String get storyEditText;

  /// No description provided for @storyTextHint.
  ///
  /// In en, this message translates to:
  /// **'Write something… #hashtags are tappable'**
  String get storyTextHint;

  /// No description provided for @storyTextsHelp.
  ///
  /// In en, this message translates to:
  /// **'Tap the picture to write. Drag to move, pinch to resize and rotate, tap a text to edit it.'**
  String get storyTextsHelp;

  /// No description provided for @storyTextsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No text} =1{1 text} other{{count} texts}}'**
  String storyTextsCount(int count);

  /// No description provided for @storyFontClassic.
  ///
  /// In en, this message translates to:
  /// **'Classic'**
  String get storyFontClassic;

  /// No description provided for @storyFontBold.
  ///
  /// In en, this message translates to:
  /// **'Bold'**
  String get storyFontBold;

  /// No description provided for @storyFontSerif.
  ///
  /// In en, this message translates to:
  /// **'Serif'**
  String get storyFontSerif;

  /// No description provided for @storyFontMono.
  ///
  /// In en, this message translates to:
  /// **'Mono'**
  String get storyFontMono;

  /// No description provided for @storyFontItalic.
  ///
  /// In en, this message translates to:
  /// **'Italic'**
  String get storyFontItalic;

  /// No description provided for @storyTextBackground.
  ///
  /// In en, this message translates to:
  /// **'Text background'**
  String get storyTextBackground;

  /// No description provided for @storyTextColor.
  ///
  /// In en, this message translates to:
  /// **'Text colour'**
  String get storyTextColor;

  /// No description provided for @storyTextLimit.
  ///
  /// In en, this message translates to:
  /// **'You can add up to {max} texts.'**
  String storyTextLimit(int max);

  /// No description provided for @wotTitle.
  ///
  /// In en, this message translates to:
  /// **'Web of trust'**
  String get wotTitle;

  /// No description provided for @wotEnable.
  ///
  /// In en, this message translates to:
  /// **'Filter spam with your web of trust'**
  String get wotEnable;

  /// No description provided for @wotExplain.
  ///
  /// In en, this message translates to:
  /// **'Hide comments, notifications, private posts and messages from people you don\'t follow and that aren\'t followed by at least {min} of the people you follow. Worked out on this phone from public follow lists; nothing is sent to any server. Discover is never filtered.'**
  String wotExplain(int min);

  /// No description provided for @wotRefresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh network now'**
  String get wotRefresh;

  /// No description provided for @wotStatusIdle.
  ///
  /// In en, this message translates to:
  /// **'Not computed yet. Turn the filter on, or refresh, to build your network.'**
  String get wotStatusIdle;

  /// No description provided for @wotStatusDiscovering.
  ///
  /// In en, this message translates to:
  /// **'Checking who your follows follow… {done} of {total}'**
  String wotStatusDiscovering(int done, int total);

  /// No description provided for @wotStatusComplete.
  ///
  /// In en, this message translates to:
  /// **'Your network: {direct} people you follow plus {indirect} followed by enough of them. Updated {when}.'**
  String wotStatusComplete(int direct, int indirect, Object when);

  /// No description provided for @wotStatusFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t compute your network: {reason}'**
  String wotStatusFailed(Object reason);

  /// No description provided for @wotNoFollows.
  ///
  /// In en, this message translates to:
  /// **'you don\'t follow anyone yet'**
  String get wotNoFollows;

  /// No description provided for @messageRequests.
  ///
  /// In en, this message translates to:
  /// **'Message requests'**
  String get messageRequests;

  /// No description provided for @messageRequestsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 conversation from outside your web of trust} other{{count} conversations from outside your web of trust}}'**
  String messageRequestsSubtitle(int count);

  /// No description provided for @messageRequestsHint.
  ///
  /// In en, this message translates to:
  /// **'From people outside your web of trust. They don\'t count as unread. Reply to move a conversation to your inbox.'**
  String get messageRequestsHint;

  /// No description provided for @storyViewsSetting.
  ///
  /// In en, this message translates to:
  /// **'Let people see that I viewed their stories'**
  String get storyViewsSetting;

  /// No description provided for @storyViewsSettingExplain.
  ///
  /// In en, this message translates to:
  /// **'When you watch a story, a receipt is sent to its author, encrypted so that only they can read it. It lists your name next to theirs; relays see nothing. If it cannot be delivered, it is kept and tried again later. Turn it off to watch without telling anyone: receipts not sent yet are discarded (one already delivered cannot be taken back).'**
  String get storyViewsSettingExplain;

  /// No description provided for @storySeenBy.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No views yet} =1{Seen by 1 person} other{Seen by {count} people}}'**
  String storySeenBy(int count);

  /// No description provided for @storyViewsEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nobody has watched this story yet, or their receipts have not reached you.'**
  String get storyViewsEmpty;

  /// No description provided for @storyViewsHint.
  ///
  /// In en, this message translates to:
  /// **'Only people who allow it send a receipt, so the real number can be higher.'**
  String get storyViewsHint;

  /// No description provided for @systemNotifications.
  ///
  /// In en, this message translates to:
  /// **'System notifications'**
  String get systemNotifications;

  /// No description provided for @systemNotificationsExplain.
  ///
  /// In en, this message translates to:
  /// **'Show a notification on your phone when something new arrives while Mialuna is in the background. Private messages never show their text, not even on the lock screen. Android pauses apps that stay in the background for long, so notifications arrive while Mialuna is still running.'**
  String get systemNotificationsExplain;

  /// No description provided for @systemNotificationsBlocked.
  ///
  /// In en, this message translates to:
  /// **'Notifications are turned off for Mialuna in the phone\'s settings.'**
  String get systemNotificationsBlocked;

  /// No description provided for @systemNotificationsOpenSettings.
  ///
  /// In en, this message translates to:
  /// **'Open settings'**
  String get systemNotificationsOpenSettings;

  /// No description provided for @systemNotificationMessage.
  ///
  /// In en, this message translates to:
  /// **'sent you a private message'**
  String get systemNotificationMessage;

  /// No description provided for @systemNotificationNewMessage.
  ///
  /// In en, this message translates to:
  /// **'New private message'**
  String get systemNotificationNewMessage;

  /// No description provided for @systemNotificationNew.
  ///
  /// In en, this message translates to:
  /// **'New notification'**
  String get systemNotificationNew;

  /// No description provided for @notificationChannelSocial.
  ///
  /// In en, this message translates to:
  /// **'Reactions, comments, zaps and followers'**
  String get notificationChannelSocial;

  /// No description provided for @notificationChannelMessages.
  ///
  /// In en, this message translates to:
  /// **'Private messages'**
  String get notificationChannelMessages;

  /// No description provided for @zapInvoiceMismatch.
  ///
  /// In en, this message translates to:
  /// **'The invoice does not match the amount you chose. Nothing was paid.'**
  String get zapInvoiceMismatch;

  /// No description provided for @storyYourStory.
  ///
  /// In en, this message translates to:
  /// **'Your story'**
  String get storyYourStory;

  /// No description provided for @storyNew.
  ///
  /// In en, this message translates to:
  /// **'New story'**
  String get storyNew;

  /// No description provided for @storyAddSemantics.
  ///
  /// In en, this message translates to:
  /// **'Add to your story'**
  String get storyAddSemantics;

  /// No description provided for @storyOwnRailLabel.
  ///
  /// In en, this message translates to:
  /// **'Your story, {count, plural, =1{1 story} other{{count} stories}}, {state}'**
  String storyOwnRailLabel(int count, Object state);

  /// No description provided for @storyTextSize.
  ///
  /// In en, this message translates to:
  /// **'Text size'**
  String get storyTextSize;

  /// No description provided for @storyPickPrompt.
  ///
  /// In en, this message translates to:
  /// **'Choose a photo or a video for your story'**
  String get storyPickPrompt;

  /// No description provided for @storyEditPhoto.
  ///
  /// In en, this message translates to:
  /// **'Edit photo'**
  String get storyEditPhoto;

  /// No description provided for @storyCaption.
  ///
  /// In en, this message translates to:
  /// **'Caption'**
  String get storyCaption;

  /// No description provided for @storyDiscardTitle.
  ///
  /// In en, this message translates to:
  /// **'Discard this story?'**
  String get storyDiscardTitle;

  /// No description provided for @storyDiscard.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get storyDiscard;

  /// No description provided for @storyShare.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get storyShare;

  /// No description provided for @storyShared.
  ///
  /// In en, this message translates to:
  /// **'Story shared'**
  String get storyShared;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'it'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'it':
      return AppLocalizationsIt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
