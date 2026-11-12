import 'dart:math' as math;

import 'package:flutter/foundation.dart';

/// The eight colour ranges the HSL panel works on, with the hue (degrees)
/// each one is centred on.
enum HslColor {
  red(0),
  orange(30),
  yellow(60),
  green(120),
  aqua(180),
  blue(240),
  purple(280),
  magenta(320);

  final double hue;
  const HslColor(this.hue);
}

/// A shift of one colour range: hue, saturation and luminance, -1..1 each.
@immutable
class HslShift {
  final double hue;
  final double saturation;
  final double luminance;

  const HslShift({this.hue = 0, this.saturation = 0, this.luminance = 0});

  static const none = HslShift();

  bool get isIdentity => hue == 0 && saturation == 0 && luminance == 0;

  HslShift copyWith({double? hue, double? saturation, double? luminance}) =>
      HslShift(
        hue: hue ?? this.hue,
        saturation: saturation ?? this.saturation,
        luminance: luminance ?? this.luminance,
      );

  @override
  bool operator ==(Object other) =>
      other is HslShift &&
      other.hue == hue &&
      other.saturation == saturation &&
      other.luminance == luminance;

  @override
  int get hashCode => Object.hash(hue, saturation, luminance);
}

/// One point of a tone curve, both coordinates 0..1.
@immutable
class CurvePoint {
  final double x;
  final double y;
  const CurvePoint(this.x, this.y);

  @override
  bool operator ==(Object other) =>
      other is CurvePoint && other.x == x && other.y == y;

  @override
  int get hashCode => Object.hash(x, y);

  @override
  String toString() => 'CurvePoint($x, $y)';
}

/// A tone curve through control points sorted by x. The first point is
/// always at x = 0 and the last at x = 1 (their y can move: that is how a
/// faded black or a dimmed white is made).
@immutable
class ToneCurve {
  final List<CurvePoint> points;

  const ToneCurve([this.points = const [CurvePoint(0, 0), CurvePoint(1, 1)]]);

  static const identity = ToneCurve();

  /// Closest two points may get on the x axis.
  static const minGap = 0.02;

  bool get isIdentity => points.every((p) => (p.x - p.y).abs() < 1e-6);

  /// Samples of the curve at [size] evenly spaced x from 0 to 1, clamped to
  /// 0..1. A monotone cubic (Fritsch–Carlson) goes through every point, so
  /// the curve never overshoots between two of them.
  Float32List table([int size = 1024]) {
    final out = Float32List(size);
    final n = points.length;
    if (n < 2) {
      for (var i = 0; i < size; i++) {
        out[i] = i / (size - 1);
      }
      return out;
    }
    final xs = [for (final p in points) p.x];
    final ys = [for (final p in points) p.y];
    final d = List<double>.filled(n - 1, 0);
    for (var i = 0; i < n - 1; i++) {
      final dx = xs[i + 1] - xs[i];
      d[i] = dx <= 0 ? 0 : (ys[i + 1] - ys[i]) / dx;
    }
    final m = List<double>.filled(n, 0);
    m[0] = d[0];
    m[n - 1] = d[n - 2];
    for (var i = 1; i < n - 1; i++) {
      m[i] = d[i - 1] * d[i] <= 0 ? 0 : (d[i - 1] + d[i]) / 2;
    }
    for (var i = 0; i < n - 1; i++) {
      if (d[i] == 0) {
        m[i] = 0;
        m[i + 1] = 0;
        continue;
      }
      final a = m[i] / d[i];
      final b = m[i + 1] / d[i];
      final s = a * a + b * b;
      if (s > 9) {
        final t = 3 / math.sqrt(s);
        m[i] = t * a * d[i];
        m[i + 1] = t * b * d[i];
      }
    }
    var seg = 0;
    for (var i = 0; i < size; i++) {
      final x = i / (size - 1);
      while (seg < n - 2 && x > xs[seg + 1]) {
        seg++;
      }
      double y;
      if (x <= xs[0]) {
        y = ys[0];
      } else if (x >= xs[n - 1]) {
        y = ys[n - 1];
      } else {
        final h = xs[seg + 1] - xs[seg];
        final t = h <= 0 ? 0.0 : (x - xs[seg]) / h;
        final t2 = t * t;
        final t3 = t2 * t;
        y =
            (2 * t3 - 3 * t2 + 1) * ys[seg] +
            (t3 - 2 * t2 + t) * h * m[seg] +
            (-2 * t3 + 3 * t2) * ys[seg + 1] +
            (t3 - t2) * h * m[seg + 1];
      }
      out[i] = y.clamp(0.0, 1.0);
    }
    return out;
  }

  /// The curve with point [index] moved to ([x], [y]), kept between its
  /// neighbours; the end points only move up and down.
  ToneCurve moved(int index, double x, double y) {
    final list = [...points];
    final last = list.length - 1;
    final nx = index == 0
        ? 0.0
        : index == last
        ? 1.0
        : x.clamp(list[index - 1].x + minGap, list[index + 1].x - minGap);
    list[index] = CurvePoint(nx, y.clamp(0.0, 1.0));
    return ToneCurve(List.unmodifiable(list));
  }

  /// The curve with a new point at ([x], [y]) and the index it got, or null
  /// when it would sit too close to an existing point.
  (ToneCurve, int)? inserted(double x, double y) {
    if (x <= minGap || x >= 1 - minGap) return null;
    var at = points.indexWhere((p) => p.x > x);
    if (at <= 0) return null;
    if (x - points[at - 1].x < minGap || points[at].x - x < minGap) {
      return null;
    }
    final list = [...points]..insert(at, CurvePoint(x, y.clamp(0.0, 1.0)));
    return (ToneCurve(List.unmodifiable(list)), at);
  }

  /// The curve without point [index]; the end points stay.
  ToneCurve removed(int index) {
    if (index <= 0 || index >= points.length - 1) return this;
    return ToneCurve(List.unmodifiable([...points]..removeAt(index)));
  }

  @override
  bool operator ==(Object other) =>
      other is ToneCurve && listEquals(other.points, points);

  @override
  int get hashCode => Object.hashAll(points);
}

/// Which curve the curves panel is editing.
enum CurveChannel { rgb, red, green, blue }

@immutable
class ToneCurves {
  final ToneCurve rgb;
  final ToneCurve red;
  final ToneCurve green;
  final ToneCurve blue;

  const ToneCurves({
    this.rgb = ToneCurve.identity,
    this.red = ToneCurve.identity,
    this.green = ToneCurve.identity,
    this.blue = ToneCurve.identity,
  });

  static const identity = ToneCurves();

  bool get isIdentity =>
      rgb.isIdentity && red.isIdentity && green.isIdentity && blue.isIdentity;

  ToneCurve operator [](CurveChannel channel) => switch (channel) {
    CurveChannel.rgb => rgb,
    CurveChannel.red => red,
    CurveChannel.green => green,
    CurveChannel.blue => blue,
  };

  ToneCurves withCurve(CurveChannel channel, ToneCurve curve) => ToneCurves(
    rgb: channel == CurveChannel.rgb ? curve : rgb,
    red: channel == CurveChannel.red ? curve : red,
    green: channel == CurveChannel.green ? curve : green,
    blue: channel == CurveChannel.blue ? curve : blue,
  );

  @override
  bool operator ==(Object other) =>
      other is ToneCurves &&
      other.rgb == rgb &&
      other.red == red &&
      other.green == green &&
      other.blue == blue;

  @override
  int get hashCode => Object.hash(rgb, red, green, blue);
}

/// The look of a photo: light, colour, curves and finishing effects. Every
/// slider is -1..1 with 0 neutral, except [sharpen] and [grain] (0..1).
///
/// It holds no geometry, so the same look can be copied onto every photo of
/// a carousel.
@immutable
class Adjustments {
  // Light.
  final double exposure;
  final double brightness;
  final double contrast;
  final double highlights;
  final double shadows;
  final double whites;
  final double blacks;

  // Colour.
  final double temperature;
  final double tint;
  final double vibrance;
  final double saturation;
  final List<HslShift> hsl;

  final ToneCurves curves;

  // Effects.
  final double sharpen;
  final double vignette;
  final double grain;

  const Adjustments({
    this.exposure = 0,
    this.brightness = 0,
    this.contrast = 0,
    this.highlights = 0,
    this.shadows = 0,
    this.whites = 0,
    this.blacks = 0,
    this.temperature = 0,
    this.tint = 0,
    this.vibrance = 0,
    this.saturation = 0,
    this.hsl = noHsl,
    this.curves = ToneCurves.identity,
    this.sharpen = 0,
    this.vignette = 0,
    this.grain = 0,
  });

  static const none = Adjustments();

  static const noHsl = [
    HslShift.none,
    HslShift.none,
    HslShift.none,
    HslShift.none,
    HslShift.none,
    HslShift.none,
    HslShift.none,
    HslShift.none,
  ];

  /// True when the colour of a pixel depends only on its own colour and
  /// nothing changes it (no light, colour or curve adjustment).
  bool get isColorIdentity =>
      exposure == 0 &&
      brightness == 0 &&
      contrast == 0 &&
      highlights == 0 &&
      shadows == 0 &&
      whites == 0 &&
      blacks == 0 &&
      temperature == 0 &&
      tint == 0 &&
      vibrance == 0 &&
      saturation == 0 &&
      hsl.every((h) => h.isIdentity) &&
      curves.isIdentity;

  bool get hasEffects => sharpen != 0 || vignette != 0 || grain != 0;

  bool get isIdentity => isColorIdentity && !hasEffects;

  HslShift hslOf(HslColor color) => hsl[color.index];

  Adjustments withHsl(HslColor color, HslShift shift) =>
      copyWith(hsl: List.unmodifiable([...hsl]..[color.index] = shift));

  Adjustments copyWith({
    double? exposure,
    double? brightness,
    double? contrast,
    double? highlights,
    double? shadows,
    double? whites,
    double? blacks,
    double? temperature,
    double? tint,
    double? vibrance,
    double? saturation,
    List<HslShift>? hsl,
    ToneCurves? curves,
    double? sharpen,
    double? vignette,
    double? grain,
  }) => Adjustments(
    exposure: exposure ?? this.exposure,
    brightness: brightness ?? this.brightness,
    contrast: contrast ?? this.contrast,
    highlights: highlights ?? this.highlights,
    shadows: shadows ?? this.shadows,
    whites: whites ?? this.whites,
    blacks: blacks ?? this.blacks,
    temperature: temperature ?? this.temperature,
    tint: tint ?? this.tint,
    vibrance: vibrance ?? this.vibrance,
    saturation: saturation ?? this.saturation,
    hsl: hsl ?? this.hsl,
    curves: curves ?? this.curves,
    sharpen: sharpen ?? this.sharpen,
    vignette: vignette ?? this.vignette,
    grain: grain ?? this.grain,
  );

  @override
  bool operator ==(Object other) =>
      other is Adjustments &&
      other.exposure == exposure &&
      other.brightness == brightness &&
      other.contrast == contrast &&
      other.highlights == highlights &&
      other.shadows == shadows &&
      other.whites == whites &&
      other.blacks == blacks &&
      other.temperature == temperature &&
      other.tint == tint &&
      other.vibrance == vibrance &&
      other.saturation == saturation &&
      listEquals(other.hsl, hsl) &&
      other.curves == curves &&
      other.sharpen == sharpen &&
      other.vignette == vignette &&
      other.grain == grain;

  @override
  int get hashCode => Object.hash(
    exposure,
    brightness,
    contrast,
    highlights,
    shadows,
    whites,
    blacks,
    temperature,
    tint,
    vibrance,
    saturation,
    Object.hashAll(hsl),
    curves,
    sharpen,
    vignette,
    grain,
  );
}
