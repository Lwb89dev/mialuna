/// A part of a story's picture, as fractions of its width and height.
class StoryArea {
  final double left;
  final double top;
  final double width;
  final double height;

  const StoryArea({
    required this.left,
    required this.top,
    required this.width,
    required this.height,
  });

  String encode() =>
      [left, top, width, height].map((v) => v.toStringAsFixed(4)).join(',');

  /// Reads [encode]'s form; null for anything that is not a rectangle inside
  /// the picture (it comes from other people's events).
  static StoryArea? decode(String text) {
    final parts = [for (final p in text.split(',')) double.tryParse(p)];
    if (parts.length != 4 || parts.any((v) => v == null || !v.isFinite)) {
      return null;
    }
    final [l!, t!, w!, h!] = parts;
    // Room for the rounding of [encode].
    const slack = 0.001;
    if (l < 0 || t < 0 || w <= 0 || h <= 0) return null;
    if (l + w > 1 + slack || t + h > 1 + slack) return null;
    return StoryArea(left: l, top: t, width: w, height: h);
  }

  @override
  bool operator ==(Object other) =>
      other is StoryArea &&
      other.left == left &&
      other.top == top &&
      other.width == width &&
      other.height == height;

  @override
  int get hashCode => Object.hash(left, top, width, height);
}

/// A story that shows a post: the story's picture is a preview of it, and
/// these tags say which post that is (a NIP-18 `q` tag) and where on the
/// picture the preview sits, so that tapping it opens the post.
///
/// ```json
/// ["q", "<event id>", "wss://relay…", "<author pubkey>"]
/// ["story-card", "0.1200,0.1800,0.7600,0.6400"]
/// ```
class StoryPostLink {
  static const quoteTag = 'q';
  static const areaTag = 'story-card';

  static final _hex64 = RegExp(r'^[0-9a-f]{64}$');

  final String eventId;
  final String? author;
  final String? relay;
  final StoryArea? area;

  const StoryPostLink({
    required this.eventId,
    this.author,
    this.relay,
    this.area,
  });

  List<List<String>> toTags() => [
    [
      quoteTag,
      eventId,
      if (relay != null || author != null) relay ?? '',
      ?author,
    ],
    if (area != null) [areaTag, area!.encode()],
  ];

  /// The post the [tags] of a story point at, or null.
  static StoryPostLink? fromTags(List<List<String>> tags) {
    List<String>? quote;
    StoryArea? area;
    for (final tag in tags) {
      if (tag.length < 2) continue;
      if (tag[0] == quoteTag && quote == null && _hex64.hasMatch(tag[1])) {
        quote = tag;
      } else if (tag[0] == areaTag) {
        area ??= StoryArea.decode(tag[1]);
      }
    }
    if (quote == null) return null;
    final relay = quote.length > 2 ? quote[2] : '';
    final author = quote.length > 3 ? quote[3] : '';
    return StoryPostLink(
      eventId: quote[1],
      relay: relay.startsWith('wss://') ? relay : null,
      author: _hex64.hasMatch(author) ? author : null,
      area: area,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is StoryPostLink &&
      other.eventId == eventId &&
      other.author == author &&
      other.relay == relay &&
      other.area == area;

  @override
  int get hashCode => Object.hash(eventId, author, relay, area);
}
