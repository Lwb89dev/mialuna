import 'dart:typed_data';

import 'package:flutter/painting.dart' show decodeImageFromList;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../app/providers.dart';
import '../../core/auth/auth_controller.dart';
import '../../core/branding/mialuna_tag.dart';
import '../../core/media/blossom.dart';
import '../../core/media/media_cipher.dart';
import '../../core/media/media_sanitizer.dart';
import '../../core/media/private_media.dart';
import '../../core/media/video_frames.dart';
import '../../core/nostr/event.dart';
import '../../core/nostr/models/media_event.dart';
import '../../core/nostr/models/story_text.dart';
import '../../core/nostr/nip59.dart';
import '../../core/nostr/signer.dart';
import '../../l10n/strings.dart';
import '../private/close_friends.dart';
import '../private/private_delivery.dart';
import '../stories/stories_controller.dart';

enum ComposerMode { photo, video, reel, story }

class PickedMedia {
  final XFile file;
  final Uint8List bytes;
  final String mimeType;
  String alt;

  /// Upload of the (sanitized) file; kept so a retry after a failed publish
  /// does not upload the same file again.
  BlossomUploadResult? uploaded;
  BlossomUploadResult? uploadedCover;
  SanitizedMedia? sanitized;
  VideoFrame? cover;

  /// Close-friends artifacts, kept for the same reason as above.
  EncryptedBlob? encrypted;
  BlossomUploadResult? uploadedPrivate;
  EncryptedBlob? encryptedCover;
  BlossomUploadResult? uploadedPrivateCover;

  PickedMedia({
    required this.file,
    required this.bytes,
    required this.mimeType,
    this.alt = '',
  });

  bool get isVideo => mimeType.startsWith('video/');
}

class ComposerState {
  final List<PickedMedia> media;
  final String caption;
  final ComposerMode mode;
  final bool isPublishing;
  final double uploadProgress;
  final String? stage;
  final String? error;
  final bool published;

  /// NIP-36: publish behind a sensitive-content warning.
  final bool sensitive;

  /// Who the post is for: everybody, or the close-friends list.
  final Audience audience;

  /// What happened after a successful publish (e.g. who got it).
  final String? notice;

  /// Texts laid over the picture of a story (see [StoryText]).
  final List<StoryText> overlays;

  const ComposerState({
    this.media = const [],
    this.caption = '',
    this.mode = ComposerMode.photo,
    this.isPublishing = false,
    this.uploadProgress = 0,
    this.stage,
    this.error,
    this.published = false,
    this.sensitive = false,
    this.audience = Audience.public,
    this.notice,
    this.overlays = const [],
  });

  /// The caption exactly as it will be published (with #mialuna applied).
  /// Close-friends posts are not discoverable, so they carry no hashtag.
  String get finalCaption => audience == Audience.closeFriends
      ? caption.trim()
      : MialunaTag.applyToCaption(caption);

  /// Media-first rule: publishing requires at least one usable media item.
  bool get canPublish =>
      media.isNotEmpty &&
      !isPublishing &&
      media.every((m) => m.bytes.isNotEmpty);

  ComposerState copyWith({
    List<PickedMedia>? media,
    String? caption,
    ComposerMode? mode,
    bool? isPublishing,
    double? uploadProgress,
    String? stage,
    String? error,
    bool? published,
    bool? sensitive,
    Audience? audience,
    String? notice,
    List<StoryText>? overlays,
  }) => ComposerState(
    media: media ?? this.media,
    caption: caption ?? this.caption,
    mode: mode ?? this.mode,
    isPublishing: isPublishing ?? this.isPublishing,
    uploadProgress: uploadProgress ?? this.uploadProgress,
    stage: stage,
    error: error,
    published: published ?? this.published,
    sensitive: sensitive ?? this.sensitive,
    audience: audience ?? this.audience,
    notice: notice,
    overlays: overlays ?? this.overlays,
  );
}

class ComposerController extends Notifier<ComposerState> {
  static const _draftKey = 'composer_draft';

  @override
  ComposerState build() {
    _restoreDraft();
    // The audience picked last time is the default for the next post.
    ref.listen(audiencePreferenceProvider, (_, audience) {
      if (!state.isPublishing) state = state.copyWith(audience: audience);
    });
    return ComposerState(audience: ref.read(audiencePreferenceProvider));
  }

  /// Switches between public and close-friends (and remembers the choice).
  void setAudience(Audience audience) {
    if (audience == state.audience) return;
    state = state.copyWith(audience: audience);
    ref.read(audiencePreferenceProvider.notifier).set(audience);
  }

  Future<void> _restoreDraft() async {
    final drafts = await ref.read(localCacheProvider).loadDrafts();
    final draft = drafts[_draftKey];
    // The draft belongs to the post composer. By the time it has been read the
    // person may be writing a story, or have typed something: neither is
    // overwritten (and a story never starts with somebody else's words).
    if (state.mode == ComposerMode.story || state.caption.isNotEmpty) return;
    if (draft is Map && draft['caption'] is String) {
      state = state.copyWith(caption: draft['caption'] as String);
    }
  }

  void setMode(ComposerMode mode) {
    if (mode == state.mode) return;
    // Switching mode clears picked media: photo carousels and videos are
    // different event kinds.
    state = state.copyWith(mode: mode, media: const [], overlays: const []);
  }

  /// Begins a new story from nothing: no picture, no texts, no caption, no
  /// content warning, no leftovers of an earlier try. Only the audience stays:
  /// it is a standing choice, remembered for every post (and shown on the
  /// screen). (A publish in progress is left alone.)
  void startStory() {
    if (state.isPublishing) return;
    state = ComposerState(mode: ComposerMode.story, audience: state.audience);
  }

  Future<void> pickVideo() async {
    final picker = ImagePicker();
    final file = await picker.pickVideo(source: ImageSource.gallery);
    if (file == null) return;
    final bytes = await file.readAsBytes();
    if (bytes.isEmpty) return;
    state = state.copyWith(
      media: [
        PickedMedia(
          file: file,
          bytes: bytes,
          mimeType: _mimeOf(bytes, file.name),
        ),
      ],
      overlays: const [],
    );
  }

  /// Captures a photo with the device camera.
  Future<void> capturePhoto() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.camera);
    if (file == null) return;
    final bytes = await file.readAsBytes();
    if (bytes.isEmpty) return;
    final media = state.mode == ComposerMode.story
        ? <PickedMedia>[]
        : [...state.media];
    media.add(
      PickedMedia(
        file: file,
        bytes: bytes,
        mimeType: _mimeOf(bytes, file.name),
      ),
    );
    state = state.copyWith(media: media, overlays: const []);
  }

  Future<void> pickImages() async {
    final picker = ImagePicker();
    // A story is one picture: ask for exactly one, so the system picker runs
    // in its single-choice mode instead of the multi-select one.
    final List<XFile> files;
    if (state.mode == ComposerMode.story) {
      final one = await picker.pickImage(source: ImageSource.gallery);
      files = one == null ? const [] : [one];
    } else {
      files = await picker.pickMultiImage(limit: 10);
    }
    if (files.isEmpty) return;
    final media = state.mode == ComposerMode.story
        ? <PickedMedia>[]
        : [...state.media];
    for (final f in files) {
      final bytes = await f.readAsBytes();
      if (bytes.isEmpty) continue;
      media.add(
        PickedMedia(file: f, bytes: bytes, mimeType: _mimeOf(bytes, f.name)),
      );
    }
    state = state.copyWith(media: media, overlays: const []);
  }

  /// Adds an already-read file to the post (used by the pickers and tests).
  void addPicked(PickedMedia media) {
    final list = state.mode == ComposerMode.story
        ? <PickedMedia>[]
        : [...state.media];
    list.add(media);
    state = state.copyWith(media: list, overlays: const []);
  }

  void removeMedia(int index) {
    final media = [...state.media]..removeAt(index);
    state = state.copyWith(
      media: media,
      // Texts belong to the picture they were laid on.
      overlays: media.isEmpty ? const [] : state.overlays,
    );
  }

  void setOverlays(List<StoryText> overlays) {
    state = state.copyWith(overlays: overlays);
  }

  /// What the story texts are laid over: the picture (or, for a video, a
  /// frame of it) and its width over height. Both null when it cannot be
  /// shown; the editor then uses a plain backdrop.
  Future<({Uint8List? bytes, double? aspect})> storyBackdrop() async {
    final item = state.media.first;
    if (item.isVideo) {
      final frame = item.cover ??= await VideoFrames.extract(item.file.path);
      if (frame == null) return (bytes: null, aspect: null);
      return (bytes: frame.bytes, aspect: frame.width / frame.height);
    }
    try {
      final image = await decodeImageFromList(item.bytes);
      final aspect = image.height == 0 ? null : image.width / image.height;
      image.dispose();
      return (bytes: item.bytes, aspect: aspect);
    } catch (_) {
      return (bytes: null, aspect: null);
    }
  }

  /// Replaces a photo's bytes with its edited version.
  void replaceMediaBytes(int index, Uint8List bytes) {
    final media = [...state.media];
    media[index] = PickedMedia(
      file: media[index].file,
      bytes: bytes,
      mimeType: media[index].mimeType,
      alt: media[index].alt,
    );
    state = state.copyWith(media: media);
  }

  void reorderMedia(int oldIndex, int newIndex) {
    // onReorderItem passes an already-adjusted newIndex.
    final media = [...state.media];
    final item = media.removeAt(oldIndex);
    media.insert(newIndex, item);
    state = state.copyWith(media: media);
  }

  void setAlt(int index, String alt) {
    state.media[index].alt = alt;
    state = state.copyWith();
  }

  void setSensitive(bool sensitive) {
    state = state.copyWith(sensitive: sensitive);
  }

  void setCaption(String caption) {
    state = state.copyWith(caption: caption);
    // Drafts survive offline/relay failures. A story's caption is not one: it
    // is never restored, and saving it would replace the draft of the post
    // composer (and show a close-friends caption in a public post).
    if (state.mode == ComposerMode.story) return;
    ref.read(localCacheProvider).saveDraft(_draftKey, {'caption': caption});
  }

  void _progress(double value, String stage) {
    state = ComposerState(
      media: state.media,
      caption: state.caption,
      mode: state.mode,
      isPublishing: true,
      uploadProgress: value.clamp(0.0, 1.0),
      stage: stage,
      sensitive: state.sensitive,
      audience: state.audience,
      overlays: state.overlays,
    );
  }

  /// Full publish flow: sanitize (remove EXIF/location) and upload every
  /// media item to Blossom, then build, sign and publish the media event
  /// (kind 20/21/22 depending on mode). A failed upload aborts publishing —
  /// no event ever references media that failed to upload.
  Future<bool> publish() async {
    final auth = ref.read(authProvider);
    if (!auth.signer.canSign) {
      state = state.copyWith(error: AppStrings.current.signInToPublish);
      return false;
    }
    if (!state.canPublish) {
      state = state.copyWith(error: AppStrings.current.addMediaFirst);
      return false;
    }
    if (state.audience == Audience.closeFriends) return _publishPrivate();

    state = state.copyWith(isPublishing: true, uploadProgress: 0);
    final blossom = ref.read(blossomClientProvider);
    final total = state.media.length;
    final mediaItems = <MediaItem>[];
    double? videoDuration;

    try {
      for (var i = 0; i < total; i++) {
        final item = state.media[i];
        double share(double within) => (i + within) / total;

        // 1. Remove every trace of metadata. Fail-closed: a file that cannot
        // be cleaned is never uploaded.
        _progress(share(0), AppStrings.current.removingMetadata);
        item.sanitized ??= await MediaSanitizer.sanitizeAsync(item.bytes);
        final clean = item.sanitized!;

        // 2. Upload the cleaned file.
        item.uploaded ??= await blossom.upload(
          signer: auth.signer,
          bytes: clean.bytes,
          mimeType: clean.mimeType,
          label: item.isVideo ? 'video' : 'photo',
          onProgress: (p) => _progress(
            share(0.1 + 0.7 * p),
            AppStrings.current.uploadingProgress(i + 1, total),
          ),
        );

        // 3. Videos get a cover image (poster) taken from the first seconds.
        int? width = clean.width, height = clean.height;
        String? coverUrl;
        if (item.isVideo) {
          _progress(share(0.85), AppStrings.current.creatingPreview);
          item.cover ??= await VideoFrames.extract(item.file.path);
          final frame = item.cover;
          if (frame != null) {
            width = frame.width;
            height = frame.height;
            if (frame.durationMs > 0) videoDuration ??= frame.durationMs / 1000;
            final coverClean = MediaSanitizer.sanitize(frame.bytes);
            item.uploadedCover ??= await blossom.upload(
              signer: auth.signer,
              bytes: coverClean.bytes,
              mimeType: coverClean.mimeType,
              label: 'cover',
            );
            coverUrl = item.uploadedCover!.url;
          }
        }

        mediaItems.add(
          MediaItem(
            url: item.uploaded!.url,
            mimeType: clean.mimeType,
            sha256: item.uploaded!.sha256,
            width: width,
            height: height,
            alt: item.alt.isNotEmpty ? item.alt : null,
            previewUrl: coverUrl,
          ),
        );
      }
    } on MediaSanitizeException catch (e) {
      state = state.copyWith(isPublishing: false, error: e.message);
      return false;
    } on BlossomException catch (e) {
      state = state.copyWith(isPublishing: false, error: e.message);
      return false;
    } on SignerException catch (e) {
      state = state.copyWith(isPublishing: false, error: e.message);
      return false;
    } catch (e) {
      state = state.copyWith(
        isPublishing: false,
        error: AppStrings.current.uploadFailed(e),
      );
      return false;
    }

    _progress(0.95, AppStrings.current.publishing);
    final caption = state.finalCaption; // includes #mialuna exactly once
    final isStory = state.mode == ComposerMode.story;
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final tags = MialunaTag.applyToTags(
      MediaPost.buildTags(
        media: mediaItems,
        caption: caption,
        title: MediaPost.deriveTitle(state.caption),
        publishedAt: now,
        duration: videoDuration,
        extraHashtags: const [MialunaTag.hashtag],
        contentWarning: state.sensitive ? 'sensitive content' : null,
        isStory: isStory,
        expiresAt: isStory ? now + 86400 : null,
        overlays: state.overlays,
      ),
    );

    try {
      final kind = switch (state.mode) {
        ComposerMode.photo => NostrKinds.picture,
        ComposerMode.video => NostrKinds.video,
        ComposerMode.reel => NostrKinds.shortVideo,
        ComposerMode.story =>
          state.media.first.isVideo
              ? NostrKinds.shortVideo
              : NostrKinds.picture,
      };
      final event = await auth.signer.signEvent(
        kind: kind,
        tags: tags,
        content: caption,
      );
      final report = await ref.read(relayPoolProvider).publish(event);
      if (!report.publishedSomewhere) {
        final why = report.firstFailureReason;
        state = state.copyWith(
          isPublishing: false,
          error: AppStrings.current.noRelayAcceptedPost(
            why != null ? ' ($why)' : '',
          ),
        );
        return false;
      }
      // A story never used the post draft; leave the post's draft alone.
      if (!isStory) await ref.read(localCacheProvider).deleteDraft(_draftKey);
      if (isStory) ref.read(storiesProvider.notifier).addPublished(event);
      state = ComposerState(published: true, audience: state.audience);
      return true;
    } on SignerException catch (e) {
      state = state.copyWith(isPublishing: false, error: e.message);
      return false;
    } catch (e) {
      state = state.copyWith(isPublishing: false, error: e.toString());
      return false;
    }
  }

  /// Uploads an encrypted blob under the post's one-time key, and keeps that
  /// key: only it can ask the server to delete the file with the post.
  Future<BlossomUploadResult> _uploadPrivate(
    BlossomClient blossom,
    Signer uploader,
    String uploaderKey,
    Uint8List bytes, {
    void Function(double progress)? onProgress,
  }) async {
    final result = await blossom.upload(
      signer: uploader,
      bytes: bytes,
      mimeType: 'application/octet-stream',
      opaque: true,
      label: 'blob',
      onProgress: onProgress,
    );
    await ref.read(uploadKeysProvider).remember([result.sha256], uploaderKey);
    return result;
  }

  /// Close-friends flow: the picture/video is cleaned, **encrypted on this
  /// phone** (a new AES-256 key per file), uploaded as an opaque blob signed
  /// with a throw-away key, and the post — carrying the keys and the friends
  /// list — is wrapped for each friend. A server, or anyone who finds the
  /// URL, only ever holds scrambled bytes. If the media cannot be uploaded
  /// encrypted, nothing is published: there is no unencrypted fallback.
  Future<bool> _publishPrivate() async {
    final auth = ref.read(authProvider);
    final me = auth.publicKey;
    if (me == null || !auth.signer.canEncrypt) {
      state = state.copyWith(error: AppStrings.current.privateNeedsKeySigner);
      return false;
    }
    final friends = ref.read(closeFriendsProvider).members;
    if (friends.isEmpty) {
      state = state.copyWith(
        error: AppStrings.current.closeFriendsListEmptyAddSomeone,
      );
      return false;
    }

    state = state.copyWith(isPublishing: true, uploadProgress: 0);
    final blossom = ref.read(blossomClientProvider);
    // The upload is authorised by a key that exists only for this post, so
    // the encrypted blob is not linked to the author's account.
    final uploaderKey = NsecSigner.generatePrivateKey();
    final uploader = NsecSigner.fromNsec(uploaderKey);
    final total = state.media.length;
    final items = <MediaItem>[];
    double? videoDuration;

    try {
      for (var i = 0; i < total; i++) {
        final item = state.media[i];
        double share(double within) => (i + within) / total;

        _progress(share(0), AppStrings.current.removingMetadata);
        item.sanitized ??= await MediaSanitizer.sanitizeAsync(item.bytes);
        final clean = item.sanitized!;
        if (clean.bytes.length > PrivateMediaService.maxFileBytes) {
          throw const MediaSanitizeException(
            MediaSanitizeError.privateFileTooLarge,
          );
        }

        _progress(share(0.1), AppStrings.current.encryptingOnPhone);
        item.encrypted ??= await MediaCipher.encryptAsync(clean.bytes);
        final enc = item.encrypted!;
        item.uploadedPrivate ??= await _uploadPrivate(
          blossom,
          uploader,
          uploaderKey,
          enc.bytes,
          onProgress: (p) => _progress(
            share(0.15 + 0.6 * p),
            AppStrings.current.uploadingProgress(i + 1, total),
          ),
        );

        int? width = clean.width, height = clean.height;
        String? coverUrl;
        MediaEncryption? coverEncryption;
        if (item.isVideo) {
          _progress(share(0.8), AppStrings.current.creatingPreview);
          item.cover ??= await VideoFrames.extract(item.file.path);
          final frame = item.cover;
          if (frame != null) {
            width = frame.width;
            height = frame.height;
            if (frame.durationMs > 0) videoDuration ??= frame.durationMs / 1000;
            item.encryptedCover ??= await MediaCipher.encryptAsync(
              MediaSanitizer.sanitize(frame.bytes).bytes,
            );
            final cover = item.encryptedCover!;
            item.uploadedPrivateCover ??= await _uploadPrivate(
              blossom,
              uploader,
              uploaderKey,
              cover.bytes,
            );
            coverUrl = item.uploadedPrivateCover!.url;
            coverEncryption = MediaEncryption(
              key: cover.key,
              nonce: cover.nonce,
            );
          }
        }

        items.add(
          MediaItem(
            url: item.uploadedPrivate!.url,
            mimeType: clean.mimeType,
            sha256: enc.sha256,
            plainSha256: enc.plainSha256,
            width: width,
            height: height,
            alt: item.alt.isNotEmpty ? item.alt : null,
            previewUrl: coverUrl,
            encryption: MediaEncryption(key: enc.key, nonce: enc.nonce),
            previewEncryption: coverEncryption,
          ),
        );
      }
    } on MediaSanitizeException catch (e) {
      state = state.copyWith(isPublishing: false, error: e.message);
      return false;
    } on BlossomException catch (e) {
      state = state.copyWith(
        isPublishing: false,
        error: AppStrings.current.noServerAcceptedEncrypted(e.message),
      );
      return false;
    } on SignerException catch (e) {
      state = state.copyWith(isPublishing: false, error: e.message);
      return false;
    } catch (e) {
      state = state.copyWith(
        isPublishing: false,
        error: AppStrings.current.uploadFailed(e),
      );
      return false;
    }

    final isStory = state.mode == ComposerMode.story;
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final expiresAt = isStory ? now + 86400 : null;
    final caption = state.finalCaption;
    final kind = switch (state.mode) {
      ComposerMode.photo => NostrKinds.picture,
      ComposerMode.video => NostrKinds.video,
      ComposerMode.reel => NostrKinds.shortVideo,
      ComposerMode.story =>
        state.media.first.isVideo ? NostrKinds.shortVideo : NostrKinds.picture,
    };
    final rumor = Rumor.create(
      pubkey: me,
      kind: kind,
      createdAt: now,
      content: caption,
      tags: MediaPost.buildTags(
        media: items,
        caption: caption,
        title: MediaPost.deriveTitle(state.caption),
        publishedAt: now,
        duration: videoDuration,
        contentWarning: state.sensitive ? 'sensitive content' : null,
        isStory: isStory,
        expiresAt: expiresAt,
        // The friends list is injected into the post itself.
        closeFriends: friends,
        overlays: state.overlays,
      ),
    );

    try {
      _progress(0.9, AppStrings.current.sendingToFriends);
      final report = await ref
          .read(privateDeliveryProvider)
          .send(
            rumor,
            friends,
            expiresAt: expiresAt,
            onProgress: (done, all) => _progress(
              0.9 + 0.1 * done / all,
              AppStrings.current.sendingToFriendsProgress(done, all),
            ),
          );
      if (!report.reachedSomeone) {
        final why = report.failed.values.toSet().take(2).join('; ');
        state = state.copyWith(
          isPublishing: false,
          error: AppStrings.current.noFriendReceivedPost(
            why.isEmpty ? '' : ' ($why)',
          ),
        );
        return false;
      }
      // A story never used the post draft; leave the post's draft alone.
      if (!isStory) await ref.read(localCacheProvider).deleteDraft(_draftKey);
      final missed = report.failed.length;
      state = ComposerState(
        published: true,
        audience: state.audience,
        notice: missed == 0
            ? AppStrings.current.sentToCloseFriends(report.delivered.length)
            : AppStrings.current.sentToFriendsWithMisses(
                report.delivered.length,
                missed,
              ),
      );
      return true;
    } on SignerException catch (e) {
      state = state.copyWith(isPublishing: false, error: e.message);
      return false;
    } catch (e) {
      state = state.copyWith(isPublishing: false, error: e.toString());
      return false;
    }
  }

  /// The real type is read from the bytes; the file name is only a fallback.
  static String _mimeOf(Uint8List bytes, String name) {
    switch (MediaSanitizer.detect(bytes)) {
      case MediaFormat.jpeg:
        return 'image/jpeg';
      case MediaFormat.png:
        return 'image/png';
      case MediaFormat.gif:
        return 'image/gif';
      case MediaFormat.webp:
        return 'image/webp';
      case MediaFormat.heif:
        return 'image/heic';
      case MediaFormat.webm:
        return 'video/webm';
      case MediaFormat.mp4:
        return name.toLowerCase().endsWith('.mov')
            ? 'video/quicktime'
            : 'video/mp4';
      case MediaFormat.unknown:
        final lower = name.toLowerCase();
        if (lower.endsWith('.mp4')) return 'video/mp4';
        if (lower.endsWith('.mov')) return 'video/quicktime';
        return 'image/jpeg';
    }
  }
}

final composerProvider = NotifierProvider<ComposerController, ComposerState>(
  ComposerController.new,
);
