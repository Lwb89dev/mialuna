import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;

import '../../../l10n/strings.dart';
import 'crop_tool.dart';
import 'image_edit_apply.dart';

/// Photo editor for the composer: crop (free or locked shape), rotation,
/// flip and basic light adjustments. Returns the edited bytes on pop.
class ImageEditorScreen extends StatefulWidget {
  final Uint8List bytes;
  final String mimeType;

  const ImageEditorScreen({
    super.key,
    required this.bytes,
    this.mimeType = 'image/jpeg',
  });

  static Future<Uint8List?> show(
    BuildContext context, {
    required Uint8List bytes,
    String mimeType = 'image/jpeg',
  }) => Navigator.of(context, rootNavigator: true).push<Uint8List>(
    MaterialPageRoute(
      builder: (_) => ImageEditorScreen(bytes: bytes, mimeType: mimeType),
    ),
  );

  @override
  State<ImageEditorScreen> createState() => _ImageEditorScreenState();
}

class _ImageEditorScreenState extends State<ImageEditorScreen> {
  late final img.Image _source;
  late final img.Image _previewSource;
  late Uint8List _previewBytes;

  /// The bytes are a format the `image` package cannot read (HEIC, a
  /// corrupt file…): the screen says so instead of crashing.
  bool _undecodable = false;

  ImageEdit _edit = const ImageEdit();
  CropShape _shape = CropShape.free;
  CropHandle? _activeHandle;

  /// Aspect of the picture after rotation/flip (width over height).
  double get _canvasAspect {
    final rotated = _edit.quarterTurns % 2 == 1;
    return rotated
        ? _source.height / _source.width
        : _source.width / _source.height;
  }

  @override
  void initState() {
    super.initState();
    final decoded = img.decodeImage(widget.bytes);
    if (decoded == null) {
      _undecodable = true;
      return;
    }
    _source = decoded;
    _previewSource = img.copyResize(
      decoded,
      width: decoded.width >= decoded.height ? 900 : null,
      height: decoded.height > decoded.width ? 900 : null,
    );
    _refreshPreview();
  }

  void _refreshPreview() {
    // Geometry and tone only: the crop stays an overlay on screen.
    _previewBytes = applyImageEdit(
      Uint8List.fromList(img.encodeJpg(_previewSource, quality: 88)),
      _edit.copyWith(crop: Crop.full),
    );
  }

  void _update(ImageEdit edit) {
    setState(() {
      _edit = edit;
      _refreshPreview();
    });
  }

  void _rotate() => _update(
    _edit.copyWith(
      quarterTurns: (_edit.quarterTurns + 1) % 4,
      crop: _shape == CropShape.free
          ? Crop.full
          : CropTool.fit(Crop.full, _lockedRatio!, _canvasAspectSwapped),
    ),
  );

  double get _canvasAspectSwapped {
    final rotated = (_edit.quarterTurns + 1) % 2 == 1;
    return rotated
        ? _source.height / _source.width
        : _source.width / _source.height;
  }

  void _flip() => _update(
    _edit.copyWith(flipHorizontal: !_edit.flipHorizontal, crop: _edit.crop),
  );

  double? get _lockedRatio => CropTool.ratioOf(_shape, _canvasAspect);

  void _selectShape(CropShape shape) {
    final ratio = CropTool.ratioOf(shape, _canvasAspect);
    _update(
      _edit.copyWith(
        crop: ratio == null
            ? _edit.crop
            : CropTool.fit(_edit.crop, ratio, _canvasAspect),
      ),
    );
    setState(() => _shape = shape);
  }

  void _reset() {
    setState(() => _shape = CropShape.free);
    _update(const ImageEdit());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (_undecodable) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: Text(context.l10n.edit),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Text(
              context.l10n.cannotEditPhoto,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(color: Colors.white70),
            ),
          ),
        ),
      );
    }
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(context.l10n.edit),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: context.l10n.reset,
            onPressed: _edit.isIdentity && _shape == CropShape.free
                ? null
                : _reset,
          ),
          TextButton(
            onPressed: () {
              final result = applyImageEdit(
                widget.bytes,
                _edit,
                mimeType: widget.mimeType,
              );
              Navigator.pop(context, result);
            },
            child: Text(context.l10n.apply),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(child: LayoutBuilder(builder: _buildPreview)),
          Container(
            color: theme.colorScheme.surface,
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    children: [
                      for (final (label, shape) in [
                        (context.l10n.cropFree, CropShape.free),
                        (context.l10n.cropOriginal, CropShape.original),
                        ('1:1', CropShape.square),
                        ('4:3', CropShape.fourThree),
                        ('3:2', CropShape.threeTwo),
                        ('16:9', CropShape.sixteenNine),
                      ])
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(label),
                            selected: _shape == shape,
                            onSelected: (_) => _selectShape(shape),
                          ),
                        ),
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.rotate_right),
                      tooltip: context.l10n.rotate,
                      onPressed: _rotate,
                    ),
                    IconButton(
                      icon: const Icon(Icons.flip),
                      tooltip: context.l10n.flip,
                      onPressed: _flip,
                    ),
                  ],
                ),
                _slider(
                  context.l10n.brightness,
                  _edit.brightness,
                  (v) => _update(_edit.copyWith(brightness: v)),
                ),
                _slider(
                  context.l10n.contrast,
                  _edit.contrast,
                  (v) => _update(_edit.copyWith(contrast: v)),
                ),
                _slider(
                  context.l10n.saturation,
                  _edit.saturation,
                  (v) => _update(_edit.copyWith(saturation: v)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _slider(String label, double value, ValueChanged<double> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          SizedBox(
            width: 88,
            child: Text(label, style: const TextStyle(fontSize: 12)),
          ),
          Expanded(
            child: Slider(value: value, min: -1, max: 1, onChanged: onChanged),
          ),
        ],
      ),
    );
  }

  Widget _buildPreview(BuildContext context, BoxConstraints constraints) {
    final area = Size(constraints.maxWidth, constraints.maxHeight);
    final scale = math.min(
      area.width / _displaySize.width,
      area.height / _displaySize.height,
    );
    final rect = Rect.fromCenter(
      center: area.center(Offset.zero),
      width: _displaySize.width * scale,
      height: _displaySize.height * scale,
    );

    return GestureDetector(
      onPanStart: (d) {
        final fx = (d.localPosition.dx - rect.left) / rect.width;
        final fy = (d.localPosition.dy - rect.top) / rect.height;
        _activeHandle = CropTool.handleAt(
          _edit.crop,
          fx,
          fy,
          28 / math.min(rect.width, rect.height),
        );
      },
      onPanUpdate: (d) {
        final handle = _activeHandle;
        if (handle == null) return;
        final dx = d.delta.dx / rect.width;
        final dy = d.delta.dy / rect.height;
        setState(() {
          _edit = _edit.copyWith(
            crop: CropTool.drag(
              _edit.crop,
              handle,
              dx,
              dy,
              _lockedRatio,
              _canvasAspect,
            ),
          );
        });
      },
      onPanEnd: (_) => _activeHandle = null,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fromRect(
            rect: rect,
            child: Image.memory(_previewBytes, fit: BoxFit.fill),
          ),
          Positioned.fill(
            child: CustomPaint(
              painter: _CropOverlayPainter(rect: rect, crop: _edit.crop),
            ),
          ),
        ],
      ),
    );
  }

  /// Displayed size of the preview after rotation.
  Size get _displaySize {
    final rotated = _edit.quarterTurns % 2 == 1;
    return rotated
        ? Size(
            _previewSource.height.toDouble(),
            _previewSource.width.toDouble(),
          )
        : Size(
            _previewSource.width.toDouble(),
            _previewSource.height.toDouble(),
          );
  }
}

class _CropOverlayPainter extends CustomPainter {
  final Rect rect;
  final Crop crop;

  _CropOverlayPainter({required this.rect, required this.crop});

  @override
  void paint(Canvas canvas, Size size) {
    final cropRect = Rect.fromLTRB(
      rect.left + crop.left * rect.width,
      rect.top + crop.top * rect.height,
      rect.left + crop.right * rect.width,
      rect.top + crop.bottom * rect.height,
    );
    final dim = Paint()..color = Colors.black.withValues(alpha: 0.5);
    canvas
      ..drawRect(
        Rect.fromLTRB(rect.left, rect.top, rect.right, cropRect.top),
        dim,
      )
      ..drawRect(
        Rect.fromLTRB(rect.left, cropRect.bottom, rect.right, rect.bottom),
        dim,
      )
      ..drawRect(
        Rect.fromLTRB(rect.left, cropRect.top, cropRect.left, cropRect.bottom),
        dim,
      )
      ..drawRect(
        Rect.fromLTRB(
          cropRect.right,
          cropRect.top,
          rect.right,
          cropRect.bottom,
        ),
        dim,
      );
    final border = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawRect(cropRect, border);
    final handlePaint = Paint()..color = Colors.white;
    for (final corner in [
      cropRect.topLeft,
      cropRect.topRight,
      cropRect.bottomLeft,
      cropRect.bottomRight,
    ]) {
      canvas.drawCircle(corner, 8, handlePaint);
    }
  }

  @override
  bool shouldRepaint(_CropOverlayPainter oldDelegate) =>
      oldDelegate.crop != crop || oldDelegate.rect != rect;
}
