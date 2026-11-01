import 'dart:typed_data';

import 'package:image/image.dart' as img;

import 'crop_tool.dart';

/// A concrete, destructive edit to apply to a photo before upload:
/// quarter turns, horizontal flip, crop (fractions of the rotated picture)
/// and basic light/color adjustments (-1..1, 0 = neutral).
class ImageEdit {
  final int quarterTurns;
  final bool flipHorizontal;
  final Crop crop;
  final double brightness;
  final double contrast;
  final double saturation;

  const ImageEdit({
    this.quarterTurns = 0,
    this.flipHorizontal = false,
    this.crop = Crop.full,
    this.brightness = 0,
    this.contrast = 0,
    this.saturation = 0,
  });

  bool get isIdentity =>
      quarterTurns % 4 == 0 &&
      !flipHorizontal &&
      crop.isFull &&
      brightness == 0 &&
      contrast == 0 &&
      saturation == 0;

  ImageEdit copyWith({
    int? quarterTurns,
    bool? flipHorizontal,
    Crop? crop,
    double? brightness,
    double? contrast,
    double? saturation,
  }) => ImageEdit(
    quarterTurns: quarterTurns ?? this.quarterTurns,
    flipHorizontal: flipHorizontal ?? this.flipHorizontal,
    crop: crop ?? this.crop,
    brightness: brightness ?? this.brightness,
    contrast: contrast ?? this.contrast,
    saturation: saturation ?? this.saturation,
  );
}

/// Applies an [ImageEdit] to encoded image bytes, returning re-encoded
/// bytes of the same format (JPEG quality 92). Rotation comes first, then
/// flip, then crop, then adjustments — one resample per step.
Uint8List applyImageEdit(
  Uint8List bytes,
  ImageEdit edit, {
  String mimeType = 'image/jpeg',
}) {
  final decoded = img.decodeImage(bytes);
  if (decoded == null) return bytes;
  var image = decoded;

  for (var i = 0; i < edit.quarterTurns % 4; i++) {
    image = img.copyRotate(image, angle: 90);
  }
  if (edit.flipHorizontal) {
    image = img.copyFlip(image, direction: img.FlipDirection.horizontal);
  }

  if (!edit.crop.isFull) {
    final x = (edit.crop.left * image.width).round();
    final y = (edit.crop.top * image.height).round();
    final w = (edit.crop.width * image.width).round();
    final h = (edit.crop.height * image.height).round();
    image = img.copyCrop(
      image,
      x: x.clamp(0, image.width - 1),
      y: y.clamp(0, image.height - 1),
      width: w.clamp(1, image.width),
      height: h.clamp(1, image.height),
    );
  }

  if (edit.brightness != 0 || edit.contrast != 0 || edit.saturation != 0) {
    image = img.adjustColor(
      image,
      brightness: 1 + edit.brightness,
      contrast: 1 + edit.contrast,
      saturation: 1 + edit.saturation,
    );
  }

  return Uint8List.fromList(
    mimeType == 'image/png'
        ? img.encodePng(image)
        : img.encodeJpg(image, quality: 92),
  );
}
