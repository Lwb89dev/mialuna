import '../event.dart';

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
  final String? previewUrl;

  const MediaItem({
    required this.url,
    this.mimeType,
    this.sha256,
    this.width,
    this.height,
    this.alt,
    this.blurhash,
    this.previewUrl,
  });

  bool get isImage =>
      (mimeType ?? '').startsWith('image/') ||
      RegExp(
        r'\.(jpe?g|png|gif|webp|avif)(\?|$)',
        caseSensitive: false,
      ).hasMatch(url);

  bool get isVideo =>
      (mimeType ?? '').startsWith('video/') ||
      RegExp(r'\.(mp4|mov|webm|m4v)(\?|$)', caseSensitive: false).hasMatch(url);

  /// Builds the NIP-68/NIP-92 `imeta` tag for this item.
  List<String> toImetaTag() => [
    'imeta',
    'url $url',
    if (mimeType != null) 'm $mimeType',
    if (sha256 != null) 'x $sha256',
    if (width != null && height != null) 'dim ${width}x$height',
    if (alt != null) 'alt $alt',
    if (blurhash != null) 'blurhash $blurhash',
    if (previewUrl != null) 'image $previewUrl',
  ];

  static MediaItem? fromImetaTag(List<String> tag) {
    String? url, mime, hash, alt, blurhash, preview;
    int? width, height;
    for (var i = 1; i < tag.length; i++) {
      final part = tag[i];
      final space = part.indexOf(' ');
      if (space == -1) continue;
      final key = part.substring(0, space);
      final value = part.substring(space + 1);
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
        case 'image':
          preview = value;
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
  });

  String get id => event.id;
  String get author => event.pubkey;
  int get createdAt => event.createdAt;
  int get kind => event.kind;
  bool get isCarousel => media.length > 1;
  bool get isVideo =>
      kind == NostrKinds.video ||
      kind == NostrKinds.shortVideo ||
      kind == NostrKinds.addressableVideo ||
      kind == NostrKinds.addressableShortVideo;
  bool get isReel =>
      kind == NostrKinds.shortVideo || kind == NostrKinds.addressableShortVideo;

  bool isExpired([int? nowSeconds]) => event.isExpired(nowSeconds);

  /// Parses any supported media event. Returns null when the event carries
  /// no usable media — Mialuna never renders such events as posts.
  static MediaPost? tryParse(NostrEvent event) {
    if (!NostrKinds.mediaKinds.contains(event.kind)) return null;

    final media = <MediaItem>[];
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
    if (media.isEmpty) return null;

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
    );
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
  }) {
    final tags = <List<String>>[
      for (final item in media) item.toImetaTag(),
      if (media.length > 1) ...[
        // NIP-68 carousels also carry plain url tags for wider compatibility.
        for (final item in media) ['url', item.url],
      ],
      if (title != null && title.isNotEmpty) ['title', title],
      for (final tag in extraHashtags) ['t', tag.toLowerCase()],
      if (contentWarning != null) ['content-warning', contentWarning],
      if (isStory) ...[
        ['L', 'mialuna.story'],
        ['l', 'story', 'mialuna.story'],
      ],
      if (expiresAt != null) ['expiration', expiresAt.toString()],
    ];
    // Inline hashtags mentioned in the caption.
    final mentionPattern = RegExp(r'#(\w+)');
    final existing = extraHashtags.map((t) => t.toLowerCase()).toSet();
    for (final m in mentionPattern.allMatches(caption)) {
      final tag = m.group(1)!.toLowerCase();
      if (existing.add(tag)) tags.add(['t', tag]);
    }
    return tags;
  }
}
