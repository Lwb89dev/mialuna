import 'package:flutter_test/flutter_test.dart';
import 'package:mialuna/features/create/editor/crop_tool.dart';

// Ported from eikon-gallery CropToolTest.kt (MIT,
// https://github.com/Lwb89dev/eikon-gallery) — same cases, same tolerances.
void main() {
  const canvas = 1.5; // a 3:2 picture
  const crop = Crop(left: 0.2, top: 0.2, right: 0.8, bottom: 0.8);

  double width(Crop c) => c.right - c.left;
  double height(Crop c) => c.bottom - c.top;

  /// Shape of the crop in pixels: width over height.
  double shape(Crop c) => width(c) * canvas / height(c);

  bool inside(Crop c) =>
      c.left >= 0 &&
      c.top >= 0 &&
      c.right <= 1 + 1e-6 &&
      c.bottom <= 1 + 1e-6 &&
      width(c) >= Crop.minSize - 1e-6 &&
      height(c) >= Crop.minSize - 1e-6;

  test('handles are found by their place, corners first', () {
    const slop = 0.04;
    expect(CropTool.handleAt(crop, 0.21, 0.19, slop), CropHandle.topLeft);
    expect(CropTool.handleAt(crop, 0.8, 0.8, slop), CropHandle.bottomRight);
    expect(CropTool.handleAt(crop, 0.5, 0.2, slop), CropHandle.top);
    expect(CropTool.handleAt(crop, 0.2, 0.5, slop), CropHandle.left);
    expect(CropTool.handleAt(crop, 0.5, 0.5, slop), CropHandle.move);
    expect(CropTool.handleAt(crop, 0.05, 0.05, slop), isNull);
  });

  test('moving keeps the size and stops at the edge of the picture', () {
    final moved = CropTool.drag(crop, CropHandle.move, 0.5, -0.5, null, canvas);
    expect(width(moved), closeTo(width(crop), 1e-6));
    expect(height(moved), closeTo(height(crop), 1e-6));
    expect(moved.right, closeTo(1, 1e-6));
    expect(moved.top, closeTo(0, 1e-6));
  });

  test('a free drag moves only the grabbed sides', () {
    final edge = CropTool.drag(crop, CropHandle.right, -0.1, 0.3, null, canvas);
    expect(edge.left, crop.left);
    expect(edge.top, crop.top);
    expect(edge.bottom, crop.bottom);
    expect(edge.right, closeTo(0.7, 1e-6));
    final corner = CropTool.drag(
      crop,
      CropHandle.topLeft,
      0.1,
      0.05,
      null,
      canvas,
    );
    expect(corner.left, closeTo(0.3, 1e-6));
    expect(corner.top, closeTo(0.25, 1e-6));
  });

  test('the crop never leaves the picture or shrinks to nothing', () {
    for (final handle in CropHandle.values) {
      for (final (dx, dy) in [
        (5.0, 5.0),
        (-5.0, -5.0),
        (5.0, -5.0),
        (-5.0, 5.0),
      ]) {
        for (final ratio in [null, 1.0, 16 / 9]) {
          final out = CropTool.drag(crop, handle, dx, dy, ratio, canvas);
          expect(inside(out), isTrue, reason: '$handle $dx,$dy ratio $ratio');
        }
      }
    }
  });

  test('a locked shape is kept whatever is dragged', () {
    for (final handle in CropHandle.values.where((h) => h != CropHandle.move)) {
      final out = CropTool.drag(
        const Crop(left: 0.1, top: 0.1, right: 0.7, bottom: 0.5),
        handle,
        0.07,
        -0.05,
        1,
        canvas,
      );
      expect(shape(out), closeTo(1, 0.02), reason: '$handle');
    }
  });

  test('dragging a corner of a locked crop keeps the opposite corner', () {
    const start = Crop(left: 0.1, top: 0.1, right: 0.7, bottom: 0.5);
    final out = CropTool.drag(
      start,
      CropHandle.topLeft,
      0.1,
      0.1,
      4 / 3,
      canvas,
    );
    expect(out.right, closeTo(start.right, 1e-5));
    expect(out.bottom, closeTo(start.bottom, 1e-5));
    expect(shape(out), closeTo(4 / 3, 0.02));
  });

  test('choosing a shape fits the largest crop around the centre', () {
    final square = CropTool.fit(Crop.full, 1, canvas);
    expect(shape(square), closeTo(1, 0.01));
    expect(height(square), closeTo(1, 1e-5));
    expect((square.left + square.right) / 2, closeTo(0.5, 1e-5));
    final wide = CropTool.fit(Crop.full, 16 / 9, canvas);
    expect(shape(wide), closeTo(16 / 9, 0.02));
    expect(width(wide), closeTo(1, 1e-5));
  });

  test('the original shape is the picture\'s own', () {
    expect(CropTool.ratioOf(CropShape.original, canvas), canvas);
    expect(CropTool.ratioOf(CropShape.free, canvas), isNull);
    expect(CropTool.ratioOf(CropShape.square, canvas), 1);
    expect((CropShape.sixteenNine.ratio! - 1.7778).abs(), lessThan(1e-3));
  });
}
