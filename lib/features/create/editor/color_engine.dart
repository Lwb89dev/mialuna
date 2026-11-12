import 'dart:math' as math;
import 'dart:typed_data';

import 'adjustments.dart';

/// The colour maths of the editor. Every per-pixel adjustment (light,
/// colour, HSL, curves) is baked into one 3D lookup table; the preview
/// shader and the full-size export both read that same table, so what the
/// photographer sees is what gets published.
///
/// The functions here mirror `shaders/photo_edit.frag` line by line: keep
/// them in step.
class ColorEngine {
  ColorEngine._();

  /// Points per axis of the lookup table (the usual size of a .cube LUT).
  static const lutSize = 33;

  /// Grain cells across the short side of the (cropped) photo.
  static const grainCells = 700.0;

  /// Bakes [a] into a lookup table of `size³` RGB triples, red varying
  /// fastest: entry `((b * size + g) * size + r) * 3`.
  static Float32List buildLut(Adjustments a, {int size = lutSize}) {
    final pipe = _Pipeline(a);
    final out = Float32List(size * size * size * 3);
    final rgb = Float64List(3);
    var i = 0;
    for (var b = 0; b < size; b++) {
      for (var g = 0; g < size; g++) {
        for (var r = 0; r < size; r++) {
          rgb[0] = r / (size - 1);
          rgb[1] = g / (size - 1);
          rgb[2] = b / (size - 1);
          pipe.apply(rgb);
          out[i++] = rgb[0];
          out[i++] = rgb[1];
          out[i++] = rgb[2];
        }
      }
    }
    return out;
  }

  /// The table as an RGBA image `size²` wide and `size` tall, blue slices
  /// side by side: pixel (b * size + r, g). This is what the shader reads.
  static Uint8List lutToRgba(Float32List lut, {int size = lutSize}) {
    final width = size * size;
    final out = Uint8List(width * size * 4);
    for (var b = 0; b < size; b++) {
      for (var g = 0; g < size; g++) {
        for (var r = 0; r < size; r++) {
          final src = ((b * size + g) * size + r) * 3;
          final dst = (g * width + b * size + r) * 4;
          out[dst] = (lut[src] * 255 + 0.5).toInt();
          out[dst + 1] = (lut[src + 1] * 255 + 0.5).toInt();
          out[dst + 2] = (lut[src + 2] * 255 + 0.5).toInt();
          out[dst + 3] = 255;
        }
      }
    }
    return out;
  }

  /// The table applied to one colour (0..1 each), trilinear; writes into
  /// [out].
  static void sampleLut(
    Float32List lut,
    double r,
    double g,
    double b,
    Float64List out, {
    int size = lutSize,
  }) {
    final s = size - 1;
    final fr = r.clamp(0.0, 1.0) * s;
    final fg = g.clamp(0.0, 1.0) * s;
    final fb = b.clamp(0.0, 1.0) * s;
    final r0 = math.min(fr.floor(), s - 1);
    final g0 = math.min(fg.floor(), s - 1);
    final b0 = math.min(fb.floor(), s - 1);
    final tr = fr - r0;
    final tg = fg - g0;
    final tb = fb - b0;
    final sr = 3;
    final sg = size * 3;
    final sb = size * size * 3;
    final base = b0 * sb + g0 * sg + r0 * sr;
    for (var c = 0; c < 3; c++) {
      final i = base + c;
      final c000 = lut[i];
      final c100 = lut[i + sr];
      final c010 = lut[i + sg];
      final c110 = lut[i + sg + sr];
      final c001 = lut[i + sb];
      final c101 = lut[i + sb + sr];
      final c011 = lut[i + sb + sg];
      final c111 = lut[i + sb + sg + sr];
      final x00 = c000 + (c100 - c000) * tr;
      final x10 = c010 + (c110 - c010) * tr;
      final x01 = c001 + (c101 - c001) * tr;
      final x11 = c011 + (c111 - c011) * tr;
      final y0 = x00 + (x10 - x00) * tg;
      final y1 = x01 + (x11 - x01) * tg;
      out[c] = y0 + (y1 - y0) * tb;
    }
  }

  /// Fast trilinear lookups of 8-bit colours in [lut], for the export: the
  /// cell and the position inside it of every byte value are worked out
  /// once.
  static LutSampler sampler(Float32List lut, {int size = lutSize}) =>
      LutSampler._(lut, size);

  /// Hash without sine (Dave Hoskins), 0..1 — the same one as the shader.
  static double hash12(double x, double y) {
    var p0 = _fract(x * 0.1031);
    var p1 = _fract(y * 0.1031);
    var p2 = _fract(x * 0.1031);
    final d = p0 * (p1 + 33.33) + p1 * (p2 + 33.33) + p2 * (p0 + 33.33);
    p0 += d;
    p1 += d;
    p2 += d;
    return _fract((p0 + p1) * p2);
  }

  /// Smooth value noise, -0.5..0.5, at a point measured in grain cells.
  static double grainNoise(double x, double y) {
    final ix = x.floorToDouble();
    final iy = y.floorToDouble();
    var fx = x - ix;
    var fy = y - iy;
    fx = fx * fx * (3 - 2 * fx);
    fy = fy * fy * (3 - 2 * fy);
    final a = hash12(ix, iy);
    final b = hash12(ix + 1, iy);
    final c = hash12(ix, iy + 1);
    final d = hash12(ix + 1, iy + 1);
    final top = a + (b - a) * fx;
    final bottom = c + (d - c) * fx;
    return top + (bottom - top) * fy - 0.5;
  }

  /// The vignette weight at a point of the cropped photo (0..1 each way):
  /// 0 in the middle, 1 in the corners.
  static double vignetteMask(double u, double v) {
    final dx = (u - 0.5) * 2;
    final dy = (v - 0.5) * 2;
    final r = math.sqrt(dx * dx + dy * dy) / math.sqrt2;
    return smoothstep(0.25, 1.05, r);
  }

  /// Vignette (darkens when [amount] < 0, lightens when > 0) and grain on
  /// one colour; [u], [v] place it in the cropped photo, [gx], [gy] in
  /// grain cells.
  static void finish(
    Float64List rgb,
    Adjustments a,
    double u,
    double v,
    double gx,
    double gy,
  ) {
    if (a.vignette != 0) {
      final m = vignetteMask(u, v) * a.vignette.abs() * 0.85;
      for (var c = 0; c < 3; c++) {
        rgb[c] = a.vignette < 0 ? rgb[c] * (1 - m) : rgb[c] + (1 - rgb[c]) * m;
      }
    }
    if (a.grain != 0) {
      final n = grainNoise(gx, gy) * a.grain * 0.22;
      for (var c = 0; c < 3; c++) {
        rgb[c] += n;
      }
    }
  }

  static double smoothstep(double e0, double e1, double x) {
    final t = ((x - e0) / (e1 - e0)).clamp(0.0, 1.0);
    return t * t * (3 - 2 * t);
  }

  static double _fract(double v) => v - v.floorToDouble();
}

class LutSampler {
  final Float32List lut;
  final int size;
  final Int32List _cell = Int32List(256);
  final Float64List _frac = Float64List(256);

  LutSampler._(this.lut, this.size) {
    final s = size - 1;
    for (var v = 0; v < 256; v++) {
      final f = v / 255 * s;
      final i = math.min(f.floor(), s - 1);
      _cell[v] = i;
      _frac[v] = f - i;
    }
  }

  /// [r], [g], [b] are 0..255; the result (0..1 each) goes in [out].
  void sample(int r, int g, int b, Float64List out) {
    final sg = size * 3;
    final sb = size * size * 3;
    final tr = _frac[r], tg = _frac[g], tb = _frac[b];
    final base = _cell[b] * sb + _cell[g] * sg + _cell[r] * 3;
    final l = lut;
    for (var c = 0; c < 3; c++) {
      final i = base + c;
      final c000 = l[i], c100 = l[i + 3];
      final c010 = l[i + sg], c110 = l[i + sg + 3];
      final c001 = l[i + sb], c101 = l[i + sb + 3];
      final c011 = l[i + sb + sg], c111 = l[i + sb + sg + 3];
      final x00 = c000 + (c100 - c000) * tr;
      final x10 = c010 + (c110 - c010) * tr;
      final x01 = c001 + (c101 - c001) * tr;
      final x11 = c011 + (c111 - c011) * tr;
      final y0 = x00 + (x10 - x00) * tg;
      final y1 = x01 + (x11 - x01) * tg;
      out[c] = y0 + (y1 - y0) * tb;
    }
  }
}

/// Per-pixel steps in order: white balance and exposure (linear light),
/// brightness, tone (highlights, shadows, whites, blacks), contrast,
/// vibrance and saturation, HSL ranges, curves.
class _Pipeline {
  final Adjustments a;
  final double wbR, wbG, wbB, gain;
  final double gamma;
  final Float32List? rgbCurve, redCurve, greenCurve, blueCurve;
  final bool hasHsl;

  factory _Pipeline(Adjustments a) {
    final t = a.temperature;
    final tn = a.tint;
    var r = 1 + 0.30 * t;
    var g = 1 - 0.20 * tn;
    var b = 1 - 0.30 * t;
    final k = 1 / (0.2126 * r + 0.7152 * g + 0.0722 * b);
    r *= k;
    g *= k;
    b *= k;
    final c = a.curves;
    return _Pipeline._(
      a,
      r,
      g,
      b,
      math.pow(2, a.exposure * 2).toDouble(),
      a.brightness >= 0 ? 1 / (1 + a.brightness * 0.9) : 1 - a.brightness * 0.9,
      c.rgb.isIdentity ? null : c.rgb.table(),
      c.red.isIdentity ? null : c.red.table(),
      c.green.isIdentity ? null : c.green.table(),
      c.blue.isIdentity ? null : c.blue.table(),
      a.hsl.any((h) => !h.isIdentity),
    );
  }

  _Pipeline._(
    this.a,
    this.wbR,
    this.wbG,
    this.wbB,
    this.gain,
    this.gamma,
    this.rgbCurve,
    this.redCurve,
    this.greenCurve,
    this.blueCurve,
    this.hasHsl,
  );

  void apply(Float64List c) {
    var r = c[0], g = c[1], b = c[2];

    // White balance and exposure, in linear light.
    if (wbR != 1 || wbG != 1 || wbB != 1 || gain != 1) {
      r = _toSrgb(_toLinear(r) * wbR * gain);
      g = _toSrgb(_toLinear(g) * wbG * gain);
      b = _toSrgb(_toLinear(b) * wbB * gain);
    }

    // Brightness: a midtone gamma, the ends stay put.
    if (gamma != 1) {
      r = _gamma(r);
      g = _gamma(g);
      b = _gamma(b);
    }

    // Tone, on luminance, added equally to the three channels.
    if (a.highlights != 0 || a.shadows != 0 || a.whites != 0 || a.blacks != 0) {
      final l = 0.2126 * r + 0.7152 * g + 0.0722 * b;
      final lc = l.clamp(0.0, 1.0);
      var d = 0.0;
      if (a.highlights != 0) {
        var m = ColorEngine.smoothstep(0.35, 0.95, l);
        if (a.highlights > 0) m *= math.min(1.0, 2.5 * (1 - lc));
        d += a.highlights * 0.3 * m;
      }
      if (a.shadows != 0) {
        var m = 1 - ColorEngine.smoothstep(0.05, 0.65, l);
        if (a.shadows > 0) m *= math.min(1.0, 4 * lc);
        d += a.shadows * 0.3 * m;
      }
      if (a.whites != 0) {
        d += a.whites * 0.25 * ColorEngine.smoothstep(0.5, 1.0, l);
      }
      if (a.blacks != 0) {
        d += a.blacks * 0.2 * (1 - ColorEngine.smoothstep(0.0, 0.5, l));
      }
      r += d;
      g += d;
      b += d;
    }

    // Contrast: an S around the middle grey, or a flatter line.
    if (a.contrast != 0) {
      r = _contrast(r);
      g = _contrast(g);
      b = _contrast(b);
    }

    r = r.clamp(0.0, 1.0);
    g = g.clamp(0.0, 1.0);
    b = b.clamp(0.0, 1.0);

    // Vibrance (favours the muted colours) and saturation.
    if (a.vibrance != 0 || a.saturation != 0) {
      final grey = 0.2126 * r + 0.7152 * g + 0.0722 * b;
      final chroma = math.max(r, math.max(g, b)) - math.min(r, math.min(g, b));
      var k = 1 + a.saturation;
      if (a.vibrance > 0) {
        k *= 1 + a.vibrance * (1 - chroma);
      } else if (a.vibrance < 0) {
        k *= 1 + a.vibrance * 0.85;
      }
      r = (grey + (r - grey) * k).clamp(0.0, 1.0);
      g = (grey + (g - grey) * k).clamp(0.0, 1.0);
      b = (grey + (b - grey) * k).clamp(0.0, 1.0);
    }

    if (hasHsl) {
      final out = _hsl(r, g, b);
      r = out.$1;
      g = out.$2;
      b = out.$3;
    }

    final rc = rgbCurve;
    if (rc != null) {
      r = _curve(rc, r);
      g = _curve(rc, g);
      b = _curve(rc, b);
    }
    if (redCurve != null) r = _curve(redCurve!, r);
    if (greenCurve != null) g = _curve(greenCurve!, g);
    if (blueCurve != null) b = _curve(blueCurve!, b);

    c[0] = r.clamp(0.0, 1.0);
    c[1] = g.clamp(0.0, 1.0);
    c[2] = b.clamp(0.0, 1.0);
  }

  double _gamma(double x) {
    if (x <= 0) return x;
    if (x >= 1) return 1 + (x - 1) * gamma;
    return math.pow(x, gamma).toDouble();
  }

  double _contrast(double x) {
    final k = a.contrast;
    if (k > 0) {
      final xc = x.clamp(0.0, 1.0);
      final s = xc < 0.5 ? 2 * xc * xc : 1 - 2 * (1 - xc) * (1 - xc);
      return x + (s - xc) * k;
    }
    return 0.5 + (x - 0.5) * (1 + k * 0.6);
  }

  (double, double, double) _hsl(double r, double g, double b) {
    final max = math.max(r, math.max(g, b));
    final min = math.min(r, math.min(g, b));
    final chroma = max - min;
    if (chroma < 1e-5) return (r, g, b);
    var l = (max + min) / 2;
    var s = chroma / (1 - (2 * l - 1).abs()).clamp(1e-5, 1.0);
    double h;
    if (max == r) {
      h = 60 * (((g - b) / chroma) % 6);
    } else if (max == g) {
      h = 60 * ((b - r) / chroma + 2);
    } else {
      h = 60 * ((r - g) / chroma + 4);
    }
    if (h < 0) h += 360;

    // Weights of the two ranges the hue falls between (they add up to 1).
    const centres = HslColor.values;
    var dh = 0.0, ds = 0.0, dl = 0.0;
    for (var i = 0; i < centres.length; i++) {
      final from = centres[i].hue;
      final to = i + 1 < centres.length ? centres[i + 1].hue : 360.0;
      if (h >= from && h < to) {
        var t = (h - from) / (to - from);
        t = t * t * (3 - 2 * t);
        final lo = a.hsl[i];
        final hi = a.hsl[(i + 1) % centres.length];
        dh = lo.hue * (1 - t) + hi.hue * t;
        ds = lo.saturation * (1 - t) + hi.saturation * t;
        dl = lo.luminance * (1 - t) + hi.luminance * t;
        break;
      }
    }
    h = (h + dh * 30) % 360;
    if (h < 0) h += 360;
    s = (s * (1 + ds)).clamp(0.0, 1.0);
    l = (l + dl * 0.3 * math.min(1.0, chroma * 1.5)).clamp(0.0, 1.0);

    final c = (1 - (2 * l - 1).abs()) * s;
    final x = c * (1 - ((h / 60) % 2 - 1).abs());
    final m = l - c / 2;
    final (r1, g1, b1) = switch (h ~/ 60) {
      0 => (c, x, 0.0),
      1 => (x, c, 0.0),
      2 => (0.0, c, x),
      3 => (0.0, x, c),
      4 => (x, 0.0, c),
      _ => (c, 0.0, x),
    };
    return (r1 + m, g1 + m, b1 + m);
  }

  static double _curve(Float32List table, double x) {
    final f = x.clamp(0.0, 1.0) * (table.length - 1);
    final i = math.min(f.floor(), table.length - 2);
    final t = f - i;
    return table[i] + (table[i + 1] - table[i]) * t;
  }

  static double _toLinear(double v) {
    if (v <= 0.04045) return v / 12.92;
    return math.pow((v + 0.055) / 1.055, 2.4).toDouble();
  }

  static double _toSrgb(double v) {
    if (v <= 0.0031308) return v * 12.92;
    return 1.055 * math.pow(v, 1 / 2.4) - 0.055;
  }
}

/// Where a point of the edited frame comes from in the source photo.
///
/// The frame is the source turned [quarterTurns] times clockwise, then
/// mirrored, then straightened by [angle] radians (clockwise) and scaled up
/// just enough that no empty corner shows. Shared by the shader (as
/// uniforms) and the export.
class FrameGeometry {
  final int quarterTurns;
  final bool flip;
  final double angle;

  /// Source size in pixels, upright (EXIF orientation already applied).
  final int sourceWidth;
  final int sourceHeight;

  const FrameGeometry({
    required this.quarterTurns,
    required this.flip,
    required this.angle,
    required this.sourceWidth,
    required this.sourceHeight,
  });

  bool get turned => quarterTurns % 2 == 1;

  int get frameWidth => turned ? sourceHeight : sourceWidth;
  int get frameHeight => turned ? sourceWidth : sourceHeight;

  /// Scale that keeps the straightened picture covering the whole frame.
  double get coverScale => coverScaleFor(angle, frameWidth, frameHeight);

  static double coverScaleFor(double angle, int width, int height) {
    final a = angle.abs();
    final long = math.max(width, height).toDouble();
    final short = math.max(1, math.min(width, height)).toDouble();
    return math.cos(a) + long / short * math.sin(a);
  }

  /// Source position (0..1 each way) of frame position ([u], [v]).
  (double, double) sourceOf(double u, double v) {
    var fu = u, fv = v;
    if (angle != 0) {
      final w = frameWidth.toDouble(), h = frameHeight.toDouble();
      final k = coverScale;
      final px = (u - 0.5) * w;
      final py = (v - 0.5) * h;
      final c = math.cos(angle), s = math.sin(angle);
      // Inverse of a clockwise turn (y points down) and of the scale.
      final qx = (c * px + s * py) / k;
      final qy = (-s * px + c * py) / k;
      fu = qx / w + 0.5;
      fv = qy / h + 0.5;
    }
    if (flip) fu = 1 - fu;
    return switch (quarterTurns % 4) {
      1 => (fv, 1 - fu),
      2 => (1 - fu, 1 - fv),
      3 => (1 - fv, fu),
      _ => (fu, fv),
    };
  }
}
