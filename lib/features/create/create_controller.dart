import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../app/providers.dart';
import '../../core/auth/auth_controller.dart';
import '../../core/branding/mialuna_tag.dart';
import '../../core/media/blossom.dart';
import '../../core/media/exif.dart';
import '../../core/nostr/event.dart';
import '../../core/nostr/models/media_event.dart';

enum ComposerMode { photo, video, reel, story }

class PickedMedia {
  final XFile file;
  final Uint8List bytes;
  final String mimeType;
  String alt;
  BlossomUploadResult? uploaded;

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
  final String? error;
  final bool published;

  /// NIP-36: publish behind a sensitive-content warning.
  final bool sensitive;

  const ComposerState({
    this.media = const [],
    this.caption = '',
    this.mode = ComposerMode.photo,
    this.isPublishing = false,
    this.uploadProgress = 0,
    this.error,
    this.published = false,
    this.sensitive = false,
  });

  /// The caption exactly as it will be published (with #mialuna applied).
  String get finalCaption => MialunaTag.applyToCaption(caption);

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
    String? error,
    bool? published,
    bool? sensitive,
  }) => ComposerState(
    media: media ?? this.media,
    caption: caption ?? this.caption,
    mode: mode ?? this.mode,
    isPublishing: isPublishing ?? this.isPublishing,
    uploadProgress: uploadProgress ?? this.uploadProgress,
    error: error,
    published: published ?? this.published,
    sensitive: sensitive ?? this.sensitive,
  );
}

class ComposerController extends Notifier<ComposerState> {
  static const _draftKey = 'composer_draft';

  @override
  ComposerState build() {
    _restoreDraft();
    return const ComposerState();
  }

  Future<void> _restoreDraft() async {
    final drafts = await ref.read(localCacheProvider).loadDrafts();
    final draft = drafts[_draftKey];
    if (draft is Map && draft['caption'] is String) {
      state = state.copyWith(caption: draft['caption'] as String);
    }
  }

  void setMode(ComposerMode mode) {
    if (mode == state.mode) return;
    // Switching mode clears picked media: photo carousels and videos are
    // different event kinds.
    state = state.copyWith(mode: mode, media: const []);
  }

  Future<void> pickVideo() async {
    final picker = ImagePicker();
    final file = await picker.pickVideo(source: ImageSource.gallery);
    if (file == null) return;
    final bytes = await file.readAsBytes();
    if (bytes.isEmpty) return;
    state = state.copyWith(
      media: [
        PickedMedia(file: file, bytes: bytes, mimeType: _guessMime(file.name)),
      ],
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
      PickedMedia(file: file, bytes: bytes, mimeType: _guessMime(file.name)),
    );
    state = state.copyWith(media: media);
  }

  Future<void> pickImages() async {
    final picker = ImagePicker();
    final files = await picker.pickMultiImage(limit: 10);
    if (files.isEmpty) return;
    // Stories carry a single media per event.
    final selected = state.mode == ComposerMode.story
        ? files.take(1).toList()
        : files;
    final media = state.mode == ComposerMode.story
        ? <PickedMedia>[]
        : [...state.media];
    for (final f in selected) {
      final bytes = await f.readAsBytes();
      if (bytes.isEmpty) continue;
      media.add(
        PickedMedia(file: f, bytes: bytes, mimeType: _guessMime(f.name)),
      );
    }
    state = state.copyWith(media: media);
  }

  void removeMedia(int index) {
    final media = [...state.media]..removeAt(index);
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
    // Drafts survive offline/relay failures.
    ref.read(localCacheProvider).saveDraft(_draftKey, {'caption': caption});
  }

  /// Full publish flow: upload every media item to Blossom, then build,
  /// sign and publish the media event (kind 20/21/22 depending on mode).
  /// A failed upload aborts publishing — no event ever references media
  /// that failed to upload.
  Future<bool> publish() async {
    final auth = ref.read(authProvider);
    if (!auth.signer.canSign) {
      state = state.copyWith(error: 'Accedi per pubblicare.');
      return false;
    }
    if (!state.canPublish) {
      state = state.copyWith(
        error: 'Aggiungi almeno una foto o un video prima di pubblicare.',
      );
      return false;
    }

    state = state.copyWith(isPublishing: true, uploadProgress: 0, error: null);
    final blossom = ref.read(blossomClientProvider);

    try {
      for (var i = 0; i < state.media.length; i++) {
        final item = state.media[i];
        // EXIF (incl. GPS) is stripped by default before upload.
        final (cleanBytes, cleanMime) = ExifStripper.strip(
          item.bytes,
          item.mimeType,
        );
        item.uploaded ??= await blossom.upload(
          signer: auth.signer,
          bytes: cleanBytes,
          mimeType: cleanMime,
          onProgress: (p) => state = state.copyWith(
            uploadProgress: (i + p) / state.media.length,
          ),
        );
      }
    } on BlossomException catch (e) {
      state = state.copyWith(isPublishing: false, error: e.message);
      return false;
    }

    final mediaItems = [
      for (final m in state.media)
        MediaItem(
          url: m.uploaded!.url,
          mimeType: m.uploaded!.mimeType ?? m.mimeType,
          sha256: m.uploaded!.sha256,
          alt: m.alt.isNotEmpty ? m.alt : null,
        ),
    ];

    final caption = state.finalCaption; // includes #mialuna exactly once
    final isStory = state.mode == ComposerMode.story;
    final tags = MialunaTag.applyToTags(
      MediaPost.buildTags(
        media: mediaItems,
        caption: caption,
        extraHashtags: const [MialunaTag.hashtag],
        contentWarning: state.sensitive ? 'sensitive content' : null,
        isStory: isStory,
        expiresAt: isStory
            ? DateTime.now().millisecondsSinceEpoch ~/ 1000 + 86400
            : null,
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
        state = state.copyWith(
          isPublishing: false,
          error:
              'Nessun relay ha accettato il post. Il contenuto resta in bozze.',
        );
        return false;
      }
      await ref.read(localCacheProvider).deleteDraft(_draftKey);
      state = const ComposerState(published: true);
      return true;
    } catch (e) {
      state = state.copyWith(isPublishing: false, error: e.toString());
      return false;
    }
  }

  static String _guessMime(String name) {
    final lower = name.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.gif')) return 'image/gif';
    if (lower.endsWith('.webp')) return 'image/webp';
    if (lower.endsWith('.mp4')) return 'video/mp4';
    if (lower.endsWith('.mov')) return 'video/quicktime';
    return 'image/jpeg';
  }
}

final composerProvider = NotifierProvider<ComposerController, ComposerState>(
  ComposerController.new,
);
