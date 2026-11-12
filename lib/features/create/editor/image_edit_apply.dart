import 'dart:isolate';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;

import 'adjustments.dart';
import 'color_engine.dart';
import 'crop_tool.dart';

/// Everything done to a photo in the editor: geometry (quarter turns,
/// mirror, straighten, crop) and its look ([adjust]). It is a recipe, not
/// pixels: the composer keeps it next to the untouched original, so the
/// editor can be reopened with every slider where it was left and the
/// photo is re-rendered from the original once, never re-compressed twice.
@immutable
class ImageEdit {
  final int quarterTurns;
  final bool flipHorizontal;

  /// Straighten angle in degrees, clockwise, within ±[maxStraighten].
  final double straighten;

  /// Part kept, in fractions of the turned and straightened frame.
  final Crop crop;
  final Adjustments adjust;

  const ImageEdit({
    this.quarterTurns = 0,
    this.flipHorizontal = false,
    this.straighten = 0,
    this.crop = Crop.full,
    this.adjust = Adjustments.none,
  });

  static const maxStraighten = 45.0;

  bool get hasGeometry =>
      quarterTurns % 4 != 0 ||
      flipHorizontal ||
      straighten != 0 ||
      !crop.isFull;

  bool get isIdentity => !hasGeometry && adjust.isIdentity;

  ImageEdit copyWith({
    int? quarterTurns,
    bool? flipHorizontal,
    double? straighten,
    Crop? crop,
    Adjustments? adjust,
  }) => ImageEdit(
    quarterTurns: quarterTurns ?? this.quarterTurns,
    flipHorizontal: flipHorizontal ?? this.flipHorizontal,
    straighten: straighten ?? this.straighten,
    crop: crop ?? this.crop,
    adjust: adjust ?? this.adjust,
  );

  FrameGeometry geometryFor(int sourceWidth, int sourceHeight) => FrameGeometry(
    quarterTurns: quarterTurns % 4,
    flip: flipHorizontal,
    angle: straighten * math.pi / 180,
    sourceWidth: sourceWidth,
    sourceHeight: sourceHeight,
  );

  @override
  bool operator ==(Object other) =>
      other is ImageEdit &&
      other.quarterTurns == quarterTurns &&
      other.flipHorizontal == flipHorizontal &&
      other.straighten == straighten &&
      other.crop == crop &&
      other.adjust == adjust;

  @override
  int get hashCode =>
      Object.hash(quarterTurns, flipHorizontal, straighten, crop, adjust);
}

/// A photo the editor produced.
class EditedImage {
  final Uint8List bytes;
  final String mimeType;
  final int width;
  final int height;

  const EditedImage({
    required this.bytes,
    required this.mimeType,
    required this.width,
    required this.height,
  });
}

/// JPEG quality of an edited photo. High on purpose: this is the one and
/// only re-encode the picture goes through (EXIF cleaning is lossless).
const editedJpegQuality = 95;

/// Decodes [bytes] upright: the EXIF orientation is applied to the pixels
/// (the `image` package does not do it on its own), so what the editor
/// shows is the way the phone shot it. Null when the format is unknown.
img.Image? decodeUpright(Uint8List bytes) {
  final decoded = img.decodeImage(bytes);
  if (decoded == null) return null;
  final ifd = decoded.exif.imageIfd;
  if (ifd.hasOrientation && ifd.orientation != 1) {
    final icc = decoded.iccProfile;
    return img.bakeOrientation(decoded)..iccProfile = icc;
  }
  return decoded;
}

/// Renders [edit] onto the original [bytes] at full resolution. Returns
/// the original bytes untouched when there is nothing to do, and null when
/// the photo cannot be decoded.
///
/// The colour profile (ICC) of the original is kept, so a Display P3 or
/// Adobe RGB photo still looks right; EXIF is left behind (the publish step
/// would remove it anyway).
EditedImage? applyImageEdit(Uint8List bytes, ImageEdit edit) {
  final decoded = decodeUpright(bytes);
  if (decoded == null) return null;
  final png = img.findFormatForData(bytes) == img.ImageFormat.png;
  if (edit.isIdentity) {
    return EditedImage(
      bytes: bytes,
      mimeType: png ? 'image/png' : _mimeOf(bytes),
      width: decoded.width,
      height: decoded.height,
    );
  }
  final out = renderEdit(decoded, edit);
  out.iccProfile = decoded.iccProfile;
  final keepPng = png || out.numChannels == 4;
  return EditedImage(
    bytes: keepPng
        ? img.encodePng(out)
        : img.encodeJpg(out, quality: editedJpegQuality),
    mimeType: keepPng ? 'image/png' : 'image/jpeg',
    width: out.width,
    height: out.height,
  );
}

/// [applyImageEdit] in a background isolate, so a 48 MP photo does not
/// freeze the screen.
Future<EditedImage?> applyImageEditAsync(Uint8List bytes, ImageEdit edit) =>
    Isolate.run(() => applyImageEdit(bytes, edit));

/// The geometry, colour and effects of [edit] applied to an already
/// decoded, upright [source]. Also used for previews when the GPU shader is
/// not available, at preview size.
img.Image renderEdit(img.Image source, ImageEdit edit) {
  final alpha = source.numChannels == 4;
  final channels = alpha ? 4 : 3;
  var src = source;
  if (src.format != img.Format.uint8 ||
      src.hasPalette ||
      src.numChannels != channels) {
    src = src.convert(
      format: img.Format.uint8,
      numChannels: channels,
      alpha: alpha ? 255 : null,
    );
  }
  final sw = src.width, sh = src.height;
  var pixels = src.toUint8List();

  final a = edit.adjust;
  if (a.sharpen > 0) pixels = _sharpen(pixels, sw, sh, channels, a.sharpen);

  final geo = edit.geometryFor(sw, sh);
  final fw = geo.frameWidth, fh = geo.frameHeight;
  final x0 = (edit.crop.left * fw).round().clamp(0, fw - 1);
  final y0 = (edit.crop.top * fh).round().clamp(0, fh - 1);
  final x1 = (edit.crop.right * fw).round().clamp(x0 + 1, fw);
  final y1 = (edit.crop.bottom * fh).round().clamp(y0 + 1, fh);
  final cw = x1 - x0, ch = y1 - y0;

  final out = img.Image(width: cw, height: ch, numChannels: channels);
  final dst = out.toUint8List();

  final lut = a.isColorIdentity
      ? null
      : ColorEngine.sampler(ColorEngine.buildLut(a));
  final finish = a.vignette != 0 || a.grain != 0;
  final grainScale = ColorEngine.grainCells / math.min(cw, ch);
  final rgb = Float64List(3);
  final straight = geo.angle == 0;
  const inv = 1 / 255;

  // The frame-to-source mapping is affine: work out where the first pixel
  // lands and how far one step right or down moves, instead of mapping
  // every pixel.
  final (ou, ov) = geo.sourceOf((x0 + 0.5) / fw, (y0 + 0.5) / fh);
  final (xu, xv) = geo.sourceOf((x0 + 1.5) / fw, (y0 + 0.5) / fh);
  final (yu, yv) = geo.sourceOf((x0 + 0.5) / fw, (y0 + 1.5) / fh);
  final dxu = xu - ou, dxv = xv - ov, dyu = yu - ou, dyv = yv - ov;

  var o = 0;
  for (var oy = 0; oy < ch; oy++) {
    var su = ou + dyu * oy;
    var sv = ov + dyv * oy;
    for (var ox = 0; ox < cw; ox++, su += dxu, sv += dxv) {
      double r, g, b, al = 255;
      if (straight) {
        final sx = (su * sw).floor().clamp(0, sw - 1);
        final sy = (sv * sh).floor().clamp(0, sh - 1);
        final i = (sy * sw + sx) * channels;
        r = pixels[i].toDouble();
        g = pixels[i + 1].toDouble();
        b = pixels[i + 2].toDouble();
        if (alpha) al = pixels[i + 3].toDouble();
      } else {
        final fx = (su * sw - 0.5).clamp(0.0, sw - 1.0);
        final fy = (sv * sh - 0.5).clamp(0.0, sh - 1.0);
        final ix = math.min(fx.floor(), sw - 2).clamp(0, sw - 1);
        final iy = math.min(fy.floor(), sh - 2).clamp(0, sh - 1);
        final tx = sw > 1 ? fx - ix : 0.0;
        final ty = sh > 1 ? fy - iy : 0.0;
        final i00 = (iy * sw + ix) * channels;
        final i10 = sw > 1 ? i00 + channels : i00;
        final i01 = sh > 1 ? i00 + sw * channels : i00;
        final i11 = sh > 1 ? i10 + sw * channels : i10;
        double lerp(int c) {
          final top =
              pixels[i00 + c] + (pixels[i10 + c] - pixels[i00 + c]) * tx;
          final bot =
              pixels[i01 + c] + (pixels[i11 + c] - pixels[i01 + c]) * tx;
          return top + (bot - top) * ty;
        }

        r = lerp(0);
        g = lerp(1);
        b = lerp(2);
        if (alpha) al = lerp(3);
      }

      if (lut != null || finish) {
        if (lut != null) {
          lut.sample(_byte(r), _byte(g), _byte(b), rgb);
        } else {
          rgb[0] = r * inv;
          rgb[1] = g * inv;
          rgb[2] = b * inv;
        }
        if (finish) {
          ColorEngine.finish(
            rgb,
            a,
            (ox + 0.5) / cw,
            (oy + 0.5) / ch,
            (ox + 0.5) * grainScale,
            (oy + 0.5) * grainScale,
          );
        }
        r = rgb[0] * 255;
        g = rgb[1] * 255;
        b = rgb[2] * 255;
      }
      dst[o] = _byte(r);
      dst[o + 1] = _byte(g);
      dst[o + 2] = _byte(b);
      if (alpha) dst[o + 3] = _byte(al);
      o += channels;
    }
  }
  return out;
}

int _byte(double v) => v <= 0 ? 0 : (v >= 255 ? 255 : (v + 0.5).toInt());

/// Unsharp mask with a 1-pixel cross: each channel gets back
/// [amount]·0.6 of its difference from its four neighbours.
Uint8List _sharpen(Uint8List px, int w, int h, int channels, double amount) {
  final out = Uint8List.fromList(px);
  final k = amount * 0.6;
  final stride = w * channels;
  for (var y = 1; y < h - 1; y++) {
    for (var x = 1; x < w - 1; x++) {
      final i = y * stride + x * channels;
      for (var c = 0; c < 3; c++) {
        final centre = px[i + c];
        final lap =
            4 * centre -
            px[i + c - channels] -
            px[i + c + channels] -
            px[i + c - stride] -
            px[i + c + stride];
        out[i + c] = _byte(centre + lap * k);
      }
    }
  }
  return out;
}

String _mimeOf(Uint8List bytes) => switch (img.findFormatForData(bytes)) {
  img.ImageFormat.png => 'image/png',
  img.ImageFormat.gif => 'image/gif',
  img.ImageFormat.webp => 'image/webp',
  _ => 'image/jpeg',
};

/// A small upright copy of a photo for the editor's live preview, plus the
/// size of the full photo.
class PreviewSource {
  final Uint8List rgba;
  final int width;
  final int height;
  final int fullWidth;
  final int fullHeight;

  const PreviewSource({
    required this.rgba,
    required this.width,
    required this.height,
    required this.fullWidth,
    required this.fullHeight,
  });

  /// The preview as an `image` package picture (for the CPU fallback and
  /// the histogram).
  img.Image toImage() => img.Image.fromBytes(
    width: width,
    height: height,
    bytes: rgba.buffer,
    numChannels: 4,
  );
}

/// Decodes [bytes] upright and shrinks them so the long side is at most
/// [maxSide]; null when the format cannot be read.
PreviewSource? decodePreview(Uint8List bytes, {int maxSide = 1600}) {
  final full = decodeUpright(bytes);
  if (full == null) return null;
  final long = math.max(full.width, full.height);
  final small = long <= maxSide
      ? full
      : img.copyResize(
          full,
          width: full.width >= full.height ? maxSide : null,
          height: full.height > full.width ? maxSide : null,
          interpolation: img.Interpolation.average,
        );
  final rgba = small
      .convert(format: img.Format.uint8, numChannels: 4, alpha: 255)
      .toUint8List();
  return PreviewSource(
    rgba: rgba,
    width: small.width,
    height: small.height,
    fullWidth: full.width,
    fullHeight: full.height,
  );
}

Future<PreviewSource?> decodePreviewAsync(
  Uint8List bytes, {
  int maxSide = 1600,
}) => Isolate.run(() => decodePreview(bytes, maxSide: maxSide));
