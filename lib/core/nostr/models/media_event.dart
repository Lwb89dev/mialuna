import '../../text/hashtags.dart';
import '../event.dart';
import '../relay.dart' show isPublicHost;
import 'story_text.dart';

/// Hosts whose URLs are web pages, not media files. Posts pointing at them
/// (seen in the wild as kind 21/22 events carrying YouTube watch URLs) can
/// never be rendered, so they are rejected during parsing.
const _pageHosts = {
  'youtube.com',
  'youtu.be',
  'vimeo.com',
  'twitter.com',
  'x.com',
  'instagram.com',
  'facebook.com',
  'fb.watch',
  'tiktok.com',
  'open.spotify.com',
  'soundcloud.com',
  'twitch.tv',
};

/// Whether [url] may be fetched and rendered as media: http(s) only, a
/// public host (no loopback / LAN addresses an event could point the app
/// at) and not a known web-page host.
bool isUsableMediaUrl(String url) {
  final uri = Uri.tryParse(url.trim());
  if (uri == null || (uri.scheme != 'https' && uri.scheme != 'http')) {
    return false;
  }
  final host = uri.host.toLowerCase();
  if (!isPublicHost(host)) return false;
  for (final page in _pageHosts) {
    if (host == page || host.endsWith('.$page')) return false;
  }
  return true;
}

enum MediaType { image, video, unknown }

/// How a close-friends file was encrypted. The key and nonce live only inside
/// the gift-wrapped post; the server stores nothing but opaque bytes.
class MediaEncryption {
  final String algorithm;
  final String key;
  final String nonce;
  const MediaEncryption({
    this.algorithm = 'aes-gcm',
    required this.key,
    required this.nonce,
  });

  @override
  bool operator ==(Object other) =>
      other is MediaEncryption &&
      other.algorithm == algorithm &&
      other.key == key &&
      other.nonce == nonce;

  @override
  int get hashCode => Object.hash(algorithm, key, nonce);
}

/// One media item inside a NIP-68/NIP-71 event (from an `imeta` tag or a
/// bare `url` tag).
class MediaItem {
  final String url;
  final String? mimeType;
  final String? sha256;
  final int? width;
  final int? height;
  final String? alt;
  final String? blurhash;

  /// Poster / thumbnail image (`image` or `thumb` in `imeta`).
  final String? previewUrl;

  /// Alternative URLs for the same file (`fallback` in `imeta`).
  final List<String> fallbackUrls;

  /// Duration in seconds, when the publisher declared it.
  final double? duration;

  /// Set for close-friends media: [url] holds ciphertext, decrypt with this.
  final MediaEncryption? encryption;

  /// Same for the cover image ([previewUrl]) of an encrypted video.
  final MediaEncryption? previewEncryption;

  /// SHA-256 of the original file (`ox`), checked after decryption.
  final String? plainSha256;

  const MediaItem({
    required this.url,
    this.mimeType,
    this.sha256,
    this.width,
    this.height,
    this.alt,
    this.blurhash,
    this.previewUrl,
    this.fallbackUrls = const [],
    this.duration,
    this.encryption,
    this.previewEncryption,
    this.plainSha256,
  });

  bool get isEncrypted => encryption != null;

  static final _imageExt = RegExp(
    r'\.(jpe?g|png|gif|webp|avif|heic|bmp)(\?|#|$)',
    caseSensitive: false,
  );
  static final _videoExt = RegExp(
    r'\.(mp4|mov|webm|m4v|mkv)(\?|#|$)',
    caseSensitive: false,
  );

  /// Declared type first, then the file extension.
  MediaType get type {
    final m = (mimeType ?? '').toLowerCase();
    if (m.startsWith('video/')) return MediaType.video;
    if (m.startsWith('image/')) return MediaType.image;
    if (_videoExt.hasMatch(url)) return MediaType.video;
    if (_imageExt.hasMatch(url)) return MediaType.image;
    return MediaType.unknown;
  }

  bool get isImage => type == MediaType.image;
  bool get isVideo => type == MediaType.video;

  double? get aspectRatio =>
      (width != null && height != null && width! > 0 && height! > 0)
      ? width! / height!
      : null;

  MediaItem copyWith({
    String? url,
    String? mimeType,
    int? width,
    int? height,
    String? previewUrl,
    double? duration,
    List<String>? fallbackUrls,
    bool dropPreview = false,
  }) => MediaItem(
    url: url ?? this.url,
    mimeType: mimeType ?? this.mimeType,
    sha256: sha256,
    width: width ?? this.width,
    height: height ?? this.height,
    alt: alt,
    blurhash: blurhash,
    previewUrl: dropPreview ? null : (previewUrl ?? this.previewUrl),
    fallbackUrls: fallbackUrls ?? this.fallbackUrls,
    duration: duration ?? this.duration,
    encryption: encryption,
    previewEncryption: dropPreview ? null : previewEncryption,
    plainSha256: plainSha256,
  );

  /// Builds the NIP-68/NIP-71/NIP-92 `imeta` tag for this item.
  List<String> toImetaTag() => [
    'imeta',
    'url $url',
    if (mimeType != null) 'm $mimeType',
    if (sha256 != null) 'x $sha256',
    if (width != null && height != null) 'dim ${width}x$height',
    if (alt != null) 'alt $alt',
    if (blurhash != null) 'blurhash $blurhash',
    if (previewUrl != null) 'image $previewUrl',
    for (final f in fallbackUrls) 'fallback $f',
    if (plainSha256 != null) 'ox $plainSha256',
    if (encryption != null) ...[
      'encryption-algorithm ${encryption!.algorithm}',
      'decryption-key ${encryption!.key}',
      'decryption-nonce ${encryption!.nonce}',
    ],
    if (previewEncryption != null) ...[
      'image-decryption-key ${previewEncryption!.key}',
      'image-decryption-nonce ${previewEncryption!.nonce}',
    ],
  ];

  static MediaItem? fromImetaTag(List<String> tag) {
    String? url, mime, hash, alt, blurhash, preview, plainHash;
    String? encAlgorithm, encKey, encNonce, previewKey, previewNonce;
    final fallbacks = <String>[];
    int? width, height;
    double? duration;
    for (var i = 1; i < tag.length; i++) {
      final part = tag[i];
      final space = part.indexOf(' ');
      if (space == -1) continue;
      final key = part.substring(0, space);
      final value = part.substring(space + 1).trim();
      switch (key) {
        case 'url':
          url = value;
        case 'm':
          mime = value;
        case 'x':
          hash = value;
        case 'dim':
          final dims = value.split('x');
          if (dims.length == 2) {
            width = int.tryParse(dims[0]);
            height = int.tryParse(dims[1]);
          }
        case 'alt':
          alt = value;
        case 'blurhash':
          blurhash = value;
        case 'image' || 'thumb':
          preview ??= value;
        case 'fallback':
          fallbacks.add(value);
        case 'duration':
          duration = double.tryParse(value);
        case 'ox':
          plainHash = value;
        case 'encryption-algorithm':
          encAlgorithm = value;
        case 'decryption-key':
          encKey = value;
        case 'decryption-nonce':
          encNonce = value;
        case 'image-decryption-key':
          previewKey = value;
        case 'image-decryption-nonce':
          previewNonce = value;
      }
    }
    if (url == null || url.isEmpty) return null;
    return MediaItem(
      url: url,
      mimeType: mime,
      sha256: hash,
      width: width,
      height: height,
      alt: alt,
      blurhash: blurhash,
      previewUrl: preview,
      fallbackUrls: fallbacks,
      duration: duration,
      plainSha256: plainHash,
      encryption:
          encKey != null &&
              encNonce != null &&
              (encAlgorithm ?? 'aes-gcm') == 'aes-gcm'
          ? MediaEncryption(key: encKey, nonce: encNonce)
          : null,
      previewEncryption: previewKey != null && previewNonce != null
          ? MediaEncryption(key: previewKey, nonce: previewNonce)
          : null,
    );
  }
}

/// A media post (kind 20/21/22/34235/34236) as rendered by Mialuna.
class MediaPost {
  final NostrEvent event;
  final List<MediaItem> media;
  final String caption;
  final String? title;
  final List<String> hashtags;
  final bool isSensitive;
  final String? sensitiveReason;
  final bool isStory;
  final int? expiresAt;

  /// Texts laid over a story (see [StoryText]); always empty for other posts.
  final List<StoryText> overlays;

  /// Close-friends post: it reached this device inside a gift wrap, its media
  /// is encrypted, and [recipients] is the audience the author injected.
  final bool isPrivate;
  final List<String> recipients;

  const MediaPost({
    required this.event,
    required this.media,
    required this.caption,
    this.title,
    required this.hashtags,
    required this.isSensitive,
    this.sensitiveReason,
    required this.isStory,
    this.expiresAt,
    this.overlays = const [],
    this.isPrivate = false,
    this.recipients = const [],
  });

  String get id => event.id;
  String get author => event.pubkey;
  int get createdAt => event.createdAt;
  int get kind => event.kind;

  /// Posts are the same post when they come from the same event; this keeps
  /// per-post providers (keyed by [MediaPost]) stable across re-parsing.
  @override
  bool operator ==(Object other) => other is MediaPost && other.id == id;

  @override
  int get hashCode => id.hashCode;

  bool get isCarousel => media.length > 1;
  bool get isVideo =>
      kind == NostrKinds.video ||
      kind == NostrKinds.shortVideo ||
      kind == NostrKinds.addressableVideo ||
      kind == NostrKinds.addressableShortVideo;
  bool get isReel =>
      kind == NostrKinds.shortVideo || kind == NostrKinds.addressableShortVideo;

  /// How long a story is shown, whatever its NIP-40 tag says (or leaves out):
  /// the tag is the author's promise to relays, not proof that the media is
  /// gone, and an absent, malformed or far-off one must not keep a story on
  /// screen for longer than a day.
  static const storyWindowSeconds = 24 * 3600;

  /// How far ahead of this phone's clock a story may be dated before it is
  /// taken for a forgery: phones disagree by seconds, not by hours.
  static const storyClockSkewSeconds = 10 * 60;

  /// A valid NIP-40 expiration always counts. A story is also over once its
  /// [storyWindowSeconds] are, and is not shown at all when dated further in
  /// the future than clock skew explains.
  bool isExpired([int? nowSeconds]) {
    final now = nowSeconds ?? DateTime.now().millisecondsSinceEpoch ~/ 1000;
    if (event.isExpired(now)) return true;
    if (!isStory) return false;
    return createdAt > now + storyClockSkewSeconds ||
        now >= createdAt + storyWindowSeconds;
  }

  /// Parses any supported media event. Returns null when the event carries
  /// no usable media — Mialuna never renders such events as posts.
  ///
  /// A post carrying the close-friends audience tag is only accepted with
  /// [allowPrivate] — which only the private store (events that arrived
  /// inside a gift wrap) sets. A *public* event claiming to be private is
  /// dropped, so a relay cannot make anything look like a private post.
  static MediaPost? tryParse(NostrEvent event, {bool allowPrivate = false}) {
    if (!NostrKinds.mediaKinds.contains(event.kind)) return null;
    final videoKind =
        event.kind == NostrKinds.video ||
        event.kind == NostrKinds.shortVideo ||
        event.kind == NostrKinds.addressableVideo ||
        event.kind == NostrKinds.addressableShortVideo;

    var media = <MediaItem>[];
    for (final tag in event.tagsNamed('imeta')) {
      final item = MediaItem.fromImetaTag(tag);
      if (item != null) media.add(item);
    }
    // Fallback: bare url tags or URLs in content (interoperability with
    // clients that publish minimal NIP-71 events).
    if (media.isEmpty) {
      for (final url in event.tagsNamed('url')) {
        if (url.length > 1 && url[1].isNotEmpty) {
          media.add(MediaItem(url: url[1]));
        }
      }
    }
    if (media.isEmpty) {
      final match = RegExp(
        r'https?://\S+\.(jpe?g|png|gif|webp|mp4|mov|webm)',
        caseSensitive: false,
      ).firstMatch(event.content);
      if (match != null) media.add(MediaItem(url: match.group(0)!));
    }

    // Poster and duration declared outside `imeta` (older NIP-71 events).
    final topImage =
        event.firstTagValue('image') ?? event.firstTagValue('thumb');
    final topDuration = double.tryParse(event.firstTagValue('duration') ?? '');
    media = [
      for (final item in media)
        if (isUsableMediaUrl(item.url))
          item.copyWith(
            previewUrl:
                item.previewUrl ??
                (topImage != null && isUsableMediaUrl(topImage)
                    ? topImage
                    : null),
            duration: item.duration ?? topDuration,
          ),
    ];
    // Drop unusable poster/fallback URLs instead of failing at render time.
    media = [
      for (final item in media)
        item.copyWith(
          dropPreview:
              item.previewUrl != null && !isUsableMediaUrl(item.previewUrl!),
          fallbackUrls: [
            for (final f in item.fallbackUrls)
              if (isUsableMediaUrl(f)) f,
          ],
        ),
    ];

    // Keep only items that can be shown by this kind: photos for kind 20,
    // videos for 21/22 (an undeclared type is accepted for either).
    media = [
      for (final item in media)
        if (videoKind
            ? item.type != MediaType.image
            : item.type != MediaType.video)
          item,
    ];
    if (media.isEmpty) return null;

    final claimsPrivate = event.tags.any(
      (t) =>
          t.length > 1 && t[0] == audienceTag && t[1] == closeFriendsAudience,
    );
    if (claimsPrivate && !allowPrivate) return null;

    final contentWarning = event.firstTagValue('content-warning');
    final storyMarker =
        event
            .tagsNamed('l')
            .any(
              (t) =>
                  t.length > 1 && (t[1] == 'story' || t[1] == 'mialuna:story'),
            ) ||
        event
            .tagsNamed('L')
            .any((t) => t.length > 1 && t[1] == 'mialuna.story');

    return MediaPost(
      event: event,
      media: media,
      caption: event.content,
      title: event.firstTagValue('title'),
      hashtags: [
        for (final t in event.tagsNamed('t'))
          if (t.length > 1) t[1],
      ],
      isSensitive: contentWarning != null,
      sensitiveReason: contentWarning,
      isStory: storyMarker,
      expiresAt: event.expiration,
      overlays: storyMarker ? StoryText.fromTags(event.tags) : const [],
      isPrivate: event.tags.any(
        (t) =>
            t.length > 1 && t[0] == audienceTag && t[1] == closeFriendsAudience,
      ),
      recipients: [
        for (final t in event.tagsNamed('p'))
          if (t.length > 1) t[1],
      ],
    );
  }

  /// Marks a post addressed to the close-friends list.
  static const audienceTag = 'audience';
  static const closeFriendsAudience = 'close-friends';

  /// Short post title for the NIP-68/NIP-71 `title` tag: the first line of
  /// the caption without hashtags, or [fallback].
  static String deriveTitle(String caption, {String fallback = 'Mialuna'}) {
    for (final line in caption.split('\n')) {
      final cleaned = Hashtags.strip(line).trim();
      if (cleaned.isNotEmpty) {
        return cleaned.length > 80 ? '${cleaned.substring(0, 79)}…' : cleaned;
      }
    }
    return fallback;
  }

  /// Composes the tag list for a new media event.
  static List<List<String>> buildTags({
    required List<MediaItem> media,
    required String caption,
    String? title,
    List<String> extraHashtags = const [],
    String? alt,
    String? contentWarning,
    bool isStory = false,
    int? expiresAt,
    double? duration,
    int? publishedAt,

    /// The close-friends audience, injected into the post. Null = public.
    List<String>? closeFriends,

    /// Texts laid over a story. Their hashtags become `t` tags too.
    List<StoryText> overlays = const [],
  }) {
    final tags = <List<String>>[
      for (final item in media) item.toImetaTag(),
      if (media.length > 1) ...[
        // NIP-68 carousels also carry plain url tags for wider compatibility.
        for (final item in media) ['url', item.url],
      ],
      if (title != null && title.isNotEmpty) ['title', title],
      if (publishedAt != null) ['published_at', publishedAt.toString()],
      if (duration != null && duration > 0)
        ['duration', duration.round().toString()],
      for (final tag in extraHashtags) ['t', tag.toLowerCase()],
      if (contentWarning != null) ['content-warning', contentWarning],
      if (closeFriends != null) ...[
        [audienceTag, closeFriendsAudience],
        for (final pk in closeFriends) ['p', pk],
      ],
      if (isStory) ...[
        ['L', 'mialuna.story'],
        ['l', 'story', 'mialuna.story'],
      ],
      if (isStory)
        for (final text in overlays.take(StoryText.maxTexts)) text.toTag(),
      if (expiresAt != null) ['expiration', expiresAt.toString()],
    ];
    // Inline hashtags mentioned in the caption.
    final existing = extraHashtags.map((t) => t.toLowerCase()).toSet();
    final written = [
      caption,
      if (isStory)
        for (final o in overlays) o.text,
    ];
    for (final tag in written.expand(Hashtags.extract)) {
      if (existing.add(tag)) tags.add(['t', tag]);
    }
    return tags;
  }
}
