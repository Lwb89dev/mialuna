import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;

import 'adjustments.dart';
import 'color_engine.dart';
import 'crop_tool.dart';
import 'image_edit_apply.dart';

/// Shared GPU program of the preview; null once it is known not to load
/// (no shader support): the preview then renders on the CPU.
class PreviewShader {
  PreviewShader._();

  static Future<ui.FragmentProgram?>? _program;

  static Future<ui.FragmentProgram?> load() =>
      _program ??= ui.FragmentProgram.fromAsset('shaders/photo_edit.frag')
          .then<ui.FragmentProgram?>((p) => p)
          .catchError((_) => null);
}

/// The photo with an [ImageEdit] applied, live. With [showCrop] only the
/// cropped part is drawn; otherwise the whole frame (the crop tool draws
/// its overlay on top). [original] shows the photo as it was shot.
class EditPreview extends StatefulWidget {
  final PreviewSource source;
  final ui.Image image;
  final ImageEdit edit;
  final bool showCrop;
  final bool original;

  const EditPreview({
    super.key,
    required this.source,
    required this.image,
    required this.edit,
    this.showCrop = false,
    this.original = false,
  });

  @override
  State<EditPreview> createState() => _EditPreviewState();
}

class _EditPreviewState extends State<EditPreview> {
  ui.FragmentProgram? _program;
  bool _shaderChecked = false;

  ui.Image? _lut;
  Adjustments? _lutFor;
  int _lutGeneration = 0;

  // CPU fallback.
  ui.Image? _cpuFrame;
  Timer? _cpuDebounce;
  img.Image? _cpuSource;

  @override
  void initState() {
    super.initState();
    PreviewShader.load().then((program) {
      if (!mounted) return;
      setState(() {
        _program = program;
        _shaderChecked = true;
      });
      _refresh();
    });
  }

  @override
  void didUpdateWidget(EditPreview old) {
    super.didUpdateWidget(old);
    if (old.edit != widget.edit ||
        old.original != widget.original ||
        old.showCrop != widget.showCrop) {
      _refresh();
    }
  }

  @override
  void dispose() {
    _cpuDebounce?.cancel();
    _lut?.dispose();
    _cpuFrame?.dispose();
    super.dispose();
  }

  Adjustments get _colorOnly => widget.original
      ? Adjustments.none
      : widget.edit.adjust.copyWith(sharpen: 0, vignette: 0, grain: 0);

  void _refresh() {
    if (!_shaderChecked) return;
    if (_program != null) {
      _refreshLut();
    } else {
      _cpuDebounce?.cancel();
      _cpuDebounce = Timer(const Duration(milliseconds: 60), _renderCpu);
    }
  }

  Future<void> _refreshLut() async {
    final wanted = _colorOnly;
    if (wanted == _lutFor) return;
    _lutFor = wanted;
    if (wanted.isColorIdentity) {
      setState(() {});
      return;
    }
    final generation = ++_lutGeneration;
    final rgba = ColorEngine.lutToRgba(ColorEngine.buildLut(wanted));
    const n = ColorEngine.lutSize;
    final completer = Completer<ui.Image>();
    ui.decodeImageFromPixels(
      rgba,
      n * n,
      n,
      ui.PixelFormat.rgba8888,
      completer.complete,
    );
    final image = await completer.future;
    if (!mounted || generation != _lutGeneration) {
      image.dispose();
      return;
    }
    setState(() {
      _lut?.dispose();
      _lut = image;
    });
  }

  Future<void> _renderCpu() async {
    final source = _cpuSource ??= _shrink(widget.source.toImage(), 900);
    final edit = widget.original
        ? ImageEdit(
            quarterTurns: widget.edit.quarterTurns,
            flipHorizontal: widget.edit.flipHorizontal,
            straighten: widget.edit.straighten,
            crop: widget.edit.crop,
          )
        : widget.edit;
    final shown = widget.showCrop ? edit : edit.copyWith(crop: Crop.full);
    final out = renderEdit(source, shown).convert(numChannels: 4, alpha: 255);
    final completer = Completer<ui.Image>();
    ui.decodeImageFromPixels(
      out.toUint8List(),
      out.width,
      out.height,
      ui.PixelFormat.rgba8888,
      completer.complete,
    );
    final frame = await completer.future;
    if (!mounted) {
      frame.dispose();
      return;
    }
    setState(() {
      _cpuFrame?.dispose();
      _cpuFrame = frame;
    });
  }

  static img.Image _shrink(img.Image image, int maxSide) {
    if (image.width <= maxSide && image.height <= maxSide) return image;
    return img.copyResize(
      image,
      width: image.width >= image.height ? maxSide : null,
      height: image.height > image.width ? maxSide : null,
      interpolation: img.Interpolation.average,
    );
  }

  @override
  Widget build(BuildContext context) {
    final program = _program;
    if (program == null) {
      final frame = _cpuFrame;
      if (frame == null) return const ColoredBox(color: Colors.black);
      return RawImage(image: frame, fit: BoxFit.fill);
    }
    final useLut = !_colorOnly.isColorIdentity && _lut != null;
    return CustomPaint(
      painter: _ShaderPainter(
        program: program,
        image: widget.image,
        lut: useLut ? _lut : null,
        source: widget.source,
        edit: widget.edit,
        effects: widget.original ? Adjustments.none : widget.edit.adjust,
        showCrop: widget.showCrop,
      ),
      child: const SizedBox.expand(),
    );
  }
}

class _ShaderPainter extends CustomPainter {
  final ui.FragmentProgram program;
  final ui.Image image;
  final ui.Image? lut;
  final PreviewSource source;
  final ImageEdit edit;
  final Adjustments effects;
  final bool showCrop;

  _ShaderPainter({
    required this.program,
    required this.image,
    required this.lut,
    required this.source,
    required this.edit,
    required this.effects,
    required this.showCrop,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final geo = edit.geometryFor(source.fullWidth, source.fullHeight);
    final crop = edit.crop;
    final cropW = crop.width * geo.frameWidth;
    final cropH = crop.height * geo.frameHeight;
    final short = cropW < cropH ? cropW : cropH;
    final shader = program.fragmentShader();
    var i = 0;
    void f(double v) => shader.setFloat(i++, v);
    f(size.width);
    f(size.height);
    f(1 / source.width);
    f(1 / source.height);
    f(geo.frameWidth.toDouble());
    f(geo.frameHeight.toDouble());
    f(geo.quarterTurns.toDouble());
    f(geo.flip ? 1 : 0);
    f(geo.angle);
    f(geo.coverScale);
    f(crop.left);
    f(crop.top);
    f(crop.right);
    f(crop.bottom);
    f(effects.sharpen);
    f(effects.vignette);
    f(effects.grain);
    f(lut != null ? 1 : 0);
    f(cropW / short * ColorEngine.grainCells);
    f(cropH / short * ColorEngine.grainCells);
    f(ColorEngine.lutSize.toDouble());
    f(showCrop ? 1 : 0);
    shader.setImageSampler(0, image, filterQuality: FilterQuality.low);
    shader.setImageSampler(1, lut ?? image);
    canvas.drawRect(Offset.zero & size, Paint()..shader = shader);
    shader.dispose();
  }

  @override
  bool shouldRepaint(_ShaderPainter old) =>
      old.image != image ||
      old.lut != lut ||
      old.edit != edit ||
      old.effects != effects ||
      old.showCrop != showCrop;
}

/// Makes a GPU image of the preview pixels.
Future<ui.Image> previewImageOf(PreviewSource source) {
  final completer = Completer<ui.Image>();
  ui.decodeImageFromPixels(
    source.rgba,
    source.width,
    source.height,
    ui.PixelFormat.rgba8888,
    completer.complete,
  );
  return completer.future;
}

/// Histogram of the preview with [adjust] applied: 256 bins for red,
/// green, blue and luminance, from a sample of about 40 000 pixels.
class Histogram {
  final Uint32List red, green, blue, luma;
  final int peak;

  Histogram._(this.red, this.green, this.blue, this.luma, this.peak);

  factory Histogram.of(PreviewSource source, Adjustments adjust) {
    final r = Uint32List(256), g = Uint32List(256), b = Uint32List(256);
    final l = Uint32List(256);
    final lut = adjust.isColorIdentity ? null : ColorEngine.buildLut(adjust);
    final total = source.width * source.height;
    final step = total > 40000 ? (total / 40000).ceil() : 1;
    final px = source.rgba;
    final out = Float64List(3);
    const inv = 1 / 255;
    for (var p = 0; p < total; p += step) {
      final i = p * 4;
      int rv, gv, bv;
      if (lut != null) {
        ColorEngine.sampleLut(
          lut,
          px[i] * inv,
          px[i + 1] * inv,
          px[i + 2] * inv,
          out,
        );
        rv = (out[0] * 255 + 0.5).toInt();
        gv = (out[1] * 255 + 0.5).toInt();
        bv = (out[2] * 255 + 0.5).toInt();
      } else {
        rv = px[i];
        gv = px[i + 1];
        bv = px[i + 2];
      }
      r[rv]++;
      g[gv]++;
      b[bv]++;
      l[(0.2126 * rv + 0.7152 * gv + 0.0722 * bv).round().clamp(0, 255)]++;
    }
    var peak = 1;
    // The extremes are often a spike of clipped pixels; leave them out of
    // the scale so the rest stays readable.
    for (var i = 1; i < 255; i++) {
      for (final h in [r, g, b]) {
        if (h[i] > peak) peak = h[i];
      }
    }
    return Histogram._(r, g, b, l, peak);
  }
}

class HistogramView extends StatelessWidget {
  final Histogram? histogram;
  const HistogramView({super.key, required this.histogram});

  @override
  Widget build(BuildContext context) => CustomPaint(
    painter: _HistogramPainter(histogram),
    child: const SizedBox.expand(),
  );
}

class _HistogramPainter extends CustomPainter {
  final Histogram? h;
  _HistogramPainter(this.h);

  @override
  void paint(Canvas canvas, Size size) {
    final bg = Paint()..color = Colors.white.withValues(alpha: 0.06);
    canvas.drawRRect(
      RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(6)),
      bg,
    );
    final hist = h;
    if (hist == null) return;
    void channel(Uint32List bins, Color color) {
      final path = Path()..moveTo(0, size.height);
      for (var i = 0; i < 256; i++) {
        final x = i / 255 * size.width;
        final v = (bins[i] / hist.peak).clamp(0.0, 1.0);
        path.lineTo(x, size.height - v * (size.height - 2));
      }
      path
        ..lineTo(size.width, size.height)
        ..close();
      canvas.drawPath(
        path,
        Paint()
          ..color = color
          ..blendMode = BlendMode.plus,
      );
    }

    canvas.save();
    canvas.clipRRect(
      RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(6)),
    );
    channel(hist.red, const Color(0x88E5484D));
    channel(hist.green, const Color(0x8846A758));
    channel(hist.blue, const Color(0x883E63DD));
    canvas.restore();
  }

  @override
  bool shouldRepaint(_HistogramPainter old) => old.h != h;
}
