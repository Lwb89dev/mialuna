import 'dart:convert';
import 'dart:math' as math;

/// How the letters of a story text are drawn.
enum StoryTextFont { classic, bold, serif, mono, italic }

/// What sits behind the letters: nothing, a solid pill in the text colour
/// (the letters turn dark or light to stay readable), or a dark veil.
enum StoryTextBackground { none, solid, veil }

/// A piece of text laid over a story, like Instagram's text sticker.
///
/// It travels as a tag of the story event, not baked into the pixels, so
/// that `#hashtags` in it stay tappable:
///
/// ```json
/// ["story-text", "{\"t\":\"Sunday #sea\",\"x\":0.5,\"y\":0.4,\"s\":1,\"r\":0,\"c\":\"ffffff\",\"f\":\"bold\",\"b\":\"solid\"}"]
/// ```
///
/// Position is the centre of the text as a fraction of the picture's width
/// and height, so it lands in the same place at any screen size. The size is
/// a fraction of the picture's width too ([scale] 1 is the base size). Other
/// clients ignore the tag and show the plain picture.
class StoryText {
  static const tagName = 'story-text';
  static const maxTexts = 8;
  static const maxLength = 200;
  static const minScale = 0.4;
  static const maxScale = 5.0;

  final String text;
  final double x;
  final double y;
  final double scale;

  /// Radians, clockwise.
  final double rotation;

  /// Opaque colour of the letters (or of the pill), `0xRRGGBB`.
  final int color;
  final StoryTextFont font;
  final StoryTextBackground background;

  const StoryText({
    required this.text,
    this.x = 0.5,
    this.y = 0.5,
    this.scale = 1,
    this.rotation = 0,
    this.color = 0xFFFFFF,
    this.font = StoryTextFont.classic,
    this.background = StoryTextBackground.none,
  });

  StoryText copyWith({
    String? text,
    double? x,
    double? y,
    double? scale,
    double? rotation,
    int? color,
    StoryTextFont? font,
    StoryTextBackground? background,
  }) => StoryText(
    text: text ?? this.text,
    x: x ?? this.x,
    y: y ?? this.y,
    scale: scale ?? this.scale,
    rotation: rotation ?? this.rotation,
    color: color ?? this.color,
    font: font ?? this.font,
    background: background ?? this.background,
  );

  /// Control characters (other than a line break) have no place in a label.
  static final _control = RegExp(r'[\u0000-\u0009\u000B-\u001F\u007F]');

  /// [raw] trimmed, without control characters and cut to [maxLength].
  static String cleanText(String raw) {
    final text = raw.replaceAll(_control, '').trim();
    if (text.length <= maxLength) return text;
    return text.substring(0, maxLength).trimRight();
  }

  static double _round(double v) => (v * 10000).round() / 10000;

  Map<String, dynamic> toJson() => {
    't': cleanText(text),
    'x': _round(x.clamp(0.0, 1.0)),
    'y': _round(y.clamp(0.0, 1.0)),
    's': _round(scale.clamp(minScale, maxScale)),
    'r': _round(rotation),
    'c': (color & 0xFFFFFF).toRadixString(16).padLeft(6, '0'),
    'f': font.name,
    'b': background.name,
  };

  List<String> toTag() => [tagName, jsonEncode(toJson())];

  /// Reads one tag, or null when it is not a usable story text. Everything
  /// comes from other people's events: numbers are clamped, unknown fonts
  /// fall back to the default one and an empty text is dropped.
  static StoryText? fromTag(List<String> tag) {
    if (tag.length < 2 || tag[0] != tagName) return null;
    try {
      final json = jsonDecode(tag[1]);
      return json is Map ? _fromJson(json) : null;
    } catch (_) {
      return null;
    }
  }

  static StoryText? _fromJson(Map json) {
    final raw = json['t'];
    if (raw is! String) return null;
    final text = cleanText(raw);
    if (text.isEmpty) return null;
    return StoryText(
      text: text,
      x: _number(json['x'], 0.5).clamp(0.0, 1.0),
      y: _number(json['y'], 0.5).clamp(0.0, 1.0),
      scale: _number(json['s'], 1).clamp(minScale, maxScale),
      rotation: _number(json['r'], 0).clamp(-2 * math.pi, 2 * math.pi),
      color:
          int.tryParse('${json['c']}', radix: 16)?.clamp(0, 0xFFFFFF) ??
          0xFFFFFF,
      font: _named(StoryTextFont.values, json['f'], StoryTextFont.classic),
      background: _named(
        StoryTextBackground.values,
        json['b'],
        StoryTextBackground.none,
      ),
    );
  }

  static double _number(Object? v, double fallback) {
    if (v is! num || v.isNaN || v.isInfinite) return fallback;
    return v.toDouble();
  }

  static T _named<T extends Enum>(List<T> values, Object? name, T fallback) {
    for (final v in values) {
      if (v.name == name) return v;
    }
    return fallback;
  }

  /// The story texts of an event's [tags], at most [maxTexts].
  static List<StoryText> fromTags(List<List<String>> tags) {
    final out = <StoryText>[];
    for (final tag in tags) {
      final text = fromTag(tag);
      if (text != null) out.add(text);
      if (out.length == maxTexts) break;
    }
    return out;
  }

  @override
  bool operator ==(Object other) =>
      other is StoryText &&
      other.text == text &&
      other.x == x &&
      other.y == y &&
      other.scale == scale &&
      other.rotation == rotation &&
      other.color == color &&
      other.font == font &&
      other.background == background;

  @override
  int get hashCode =>
      Object.hash(text, x, y, scale, rotation, color, font, background);
}
