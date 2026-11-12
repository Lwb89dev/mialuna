import 'dart:math' as math;

/// The part of the picture kept, as fractions of the (rotated) picture:
/// 0,0 is the top left, 1,1 the bottom right.
///
/// Ported from eikon-gallery (`domain/edit/EditRecipe.kt`, MIT,
/// https://github.com/Lwb89dev/eikon-gallery).
class Crop {
  final double left;
  final double top;
  final double right;
  final double bottom;

  const Crop({this.left = 0, this.top = 0, this.right = 1, this.bottom = 1});

  static const full = Crop();
  static const minSize = 0.05;

  bool get isFull => left == 0 && top == 0 && right == 1 && bottom == 1;

  double get width => right - left;
  double get height => bottom - top;

  /// Inside 0..1 and at least [minSize] wide and tall.
  Crop clamped() {
    final l = left.clamp(0.0, 1 - minSize);
    final t = top.clamp(0.0, 1 - minSize);
    return Crop(
      left: l,
      top: t,
      right: right.clamp(l + minSize, 1.0),
      bottom: bottom.clamp(t + minSize, 1.0),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is Crop &&
      other.left == left &&
      other.top == top &&
      other.right == right &&
      other.bottom == bottom;

  @override
  int get hashCode => Object.hash(left, top, right, bottom);

  @override
  String toString() => 'Crop($left, $top, $right, $bottom)';
}

/// The parts of the crop rectangle a finger can grab.
enum CropHandle {
  move,
  topLeft,
  top,
  topRight,
  right,
  bottomRight,
  bottom,
  bottomLeft,
  left,
}

/// The shapes the crop can be locked to. [ratio] is width over height;
/// null leaves it free, and [original] keeps the picture's own shape.
enum CropShape {
  free(null),
  original(-1),
  square(1),
  fourFive(4 / 5),
  fourThree(4 / 3),
  threeTwo(3 / 2),
  sixteenNine(16 / 9);

  final double? ratio;
  const CropShape(this.ratio);
}

/// The arithmetic of dragging the crop rectangle, apart from the screen so
/// it can be tested. The crop is in fractions of the picture (0..1 each
/// way); `canvasAspect` is the picture's width over height in pixels.
///
/// Ported from eikon-gallery (`domain/edit/CropTool.kt`, MIT).
abstract final class CropTool {
  static const _leftSide = {
    CropHandle.topLeft,
    CropHandle.left,
    CropHandle.bottomLeft,
  };
  static const _rightSide = {
    CropHandle.topRight,
    CropHandle.right,
    CropHandle.bottomRight,
  };
  static const _topSide = {
    CropHandle.topLeft,
    CropHandle.top,
    CropHandle.topRight,
  };
  static const _bottomSide = {
    CropHandle.bottomLeft,
    CropHandle.bottom,
    CropHandle.bottomRight,
  };

  /// The handle under ([x], [y]) (fractions of the picture) within [slop]
  /// of it, corners before edges before the inside; null outside.
  static CropHandle? handleAt(Crop crop, double x, double y, double slop) {
    final nearLeft = (x - crop.left).abs() <= slop;
    final nearRight = (x - crop.right).abs() <= slop;
    final nearTop = (y - crop.top).abs() <= slop;
    final nearBottom = (y - crop.bottom).abs() <= slop;
    final insideX = x >= crop.left - slop && x <= crop.right + slop;
    final insideY = y >= crop.top - slop && y <= crop.bottom + slop;
    if (nearLeft && nearTop) return CropHandle.topLeft;
    if (nearRight && nearTop) return CropHandle.topRight;
    if (nearLeft && nearBottom) return CropHandle.bottomLeft;
    if (nearRight && nearBottom) return CropHandle.bottomRight;
    if (nearTop && insideX) return CropHandle.top;
    if (nearBottom && insideX) return CropHandle.bottom;
    if (nearLeft && insideY) return CropHandle.left;
    if (nearRight && insideY) return CropHandle.right;
    if (x >= crop.left &&
        x <= crop.right &&
        y >= crop.top &&
        y <= crop.bottom) {
      return CropHandle.move;
    }
    return null;
  }

  /// The crop after dragging [handle] by ([dx], [dy]) fractions; [ratio]
  /// (width over height, in pixels) locks the shape if not null.
  static Crop drag(
    Crop crop,
    CropHandle handle,
    double dx,
    double dy,
    double? ratio,
    double canvasAspect,
  ) {
    if (handle == CropHandle.move) return _move(crop, dx, dy);
    final free = _resize(crop, handle, dx, dy);
    return ratio == null
        ? free
        : _lockShape(crop, free, handle, ratio / canvasAspect);
  }

  /// The largest crop of shape [ratio] (width over height in pixels) that
  /// fits in the picture, centred on the current crop where it can be.
  static Crop fit(Crop crop, double ratio, double canvasAspect) {
    final shape = ratio / canvasAspect; // width over height in fractions
    var width = crop.width;
    var height = width / shape;
    if (height > 1) {
      height = 1;
      width = height * shape;
    }
    if (width > 1) {
      width = 1;
      height = width / shape;
    }
    final centreX = (crop.left + crop.right) / 2;
    final centreY = (crop.top + crop.bottom) / 2;
    final left = (centreX - width / 2).clamp(0.0, 1 - width);
    final top = (centreY - height / 2).clamp(0.0, 1 - height);
    return Crop(
      left: left,
      top: top,
      right: left + width,
      bottom: top + height,
    ).clamped();
  }

  /// The whole picture, or for [CropShape.original] the picture's own shape.
  static double? ratioOf(CropShape shape, double canvasAspect) =>
      shape == CropShape.original ? canvasAspect : shape.ratio;

  static Crop _move(Crop crop, double dx, double dy) {
    final left = (crop.left + dx).clamp(0.0, 1 - crop.width);
    final top = (crop.top + dy).clamp(0.0, 1 - crop.height);
    return Crop(
      left: left,
      top: top,
      right: left + crop.width,
      bottom: top + crop.height,
    );
  }

  static Crop _resize(Crop crop, CropHandle handle, double dx, double dy) {
    var left = crop.left;
    var top = crop.top;
    var right = crop.right;
    var bottom = crop.bottom;
    if (_leftSide.contains(handle)) {
      left = (left + dx).clamp(0.0, right - Crop.minSize);
    }
    if (_rightSide.contains(handle)) {
      right = (right + dx).clamp(left + Crop.minSize, 1.0);
    }
    if (_topSide.contains(handle)) {
      top = (top + dy).clamp(0.0, bottom - Crop.minSize);
    }
    if (_bottomSide.contains(handle)) {
      bottom = (bottom + dy).clamp(top + Crop.minSize, 1.0);
    }
    return Crop(left: left, top: top, right: right, bottom: bottom);
  }

  /// Makes [dragged] the shape [shape] (width over height in fractions)
  /// while the side opposite the handle stays where it was in [before].
  static Crop _lockShape(
    Crop before,
    Crop dragged,
    CropHandle handle,
    double shape,
  ) {
    final anchorX = _leftSide.contains(handle)
        ? before.right
        : _rightSide.contains(handle)
        ? before.left
        : (before.left + before.right) / 2;
    final anchorY = _topSide.contains(handle)
        ? before.bottom
        : _bottomSide.contains(handle)
        ? before.top
        : (before.top + before.bottom) / 2;
    final horizontalRoom = _leftSide.contains(handle)
        ? anchorX
        : _rightSide.contains(handle)
        ? 1 - anchorX
        : 2 * math.min(anchorX, 1 - anchorX);
    final verticalRoom = _topSide.contains(handle)
        ? anchorY
        : _bottomSide.contains(handle)
        ? 1 - anchorY
        : 2 * math.min(anchorY, 1 - anchorY);
    final wanted = (handle == CropHandle.top || handle == CropHandle.bottom)
        ? dragged.height * shape
        : dragged.width;
    final width = math
        .min(math.min(wanted, horizontalRoom), verticalRoom * shape)
        .clamp(Crop.minSize, double.infinity);
    final height = width / shape;
    final left = _leftSide.contains(handle)
        ? anchorX - width
        : _rightSide.contains(handle)
        ? anchorX
        : anchorX - width / 2;
    final top = _topSide.contains(handle)
        ? anchorY - height
        : _bottomSide.contains(handle)
        ? anchorY
        : anchorY - height / 2;
    return Crop(
      left: left,
      top: top,
      right: left + width,
      bottom: top + height,
    ).clamped();
  }
}
