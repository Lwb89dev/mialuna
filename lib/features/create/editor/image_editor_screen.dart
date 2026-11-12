import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../../l10n/strings.dart';
import 'adjustments.dart';
import 'crop_tool.dart';
import 'edit_preview.dart';
import 'image_edit_apply.dart';
import 'tone_curve_editor.dart';

/// What the editor hands back: the rendered photo (null when every edit
/// was undone, meaning "use the original"), the recipe that made it, and
/// whether the same look should go on the other photos of the post.
class EditorResult {
  final EditedImage? image;
  final ImageEdit edit;
  final bool lookToAll;

  const EditorResult({
    required this.image,
    required this.edit,
    this.lookToAll = false,
  });
}

/// The panels of the Pro mode.
enum EditorTool { crop, light, color, hsl, curves, effects }

/// Photo editor of the composer. The Basic mode is the quick one (crop,
/// rotation, three sliders); the Pro mode adds light, colour, HSL, curves,
/// effects, straightening, a histogram and before/after. Both work on the
/// same [ImageEdit] recipe and the untouched original [bytes].
class ImageEditorScreen extends StatefulWidget {
  final Uint8List bytes;
  final ImageEdit initial;
  final bool pro;

  /// Other photos of the same post: when there are some, the Pro mode
  /// offers to copy this look onto them.
  final int otherPhotos;

  /// Pro panel shown first.
  final EditorTool initialTool;

  const ImageEditorScreen({
    super.key,
    required this.bytes,
    this.initial = const ImageEdit(),
    this.pro = false,
    this.otherPhotos = 0,
    this.initialTool = EditorTool.light,
  });

  static Future<EditorResult?> show(
    BuildContext context, {
    required Uint8List bytes,
    ImageEdit initial = const ImageEdit(),
    bool pro = false,
    int otherPhotos = 0,
  }) => Navigator.of(context, rootNavigator: true).push<EditorResult>(
    MaterialPageRoute(
      builder: (_) => ImageEditorScreen(
        bytes: bytes,
        initial: initial,
        pro: pro,
        otherPhotos: otherPhotos,
      ),
    ),
  );

  @override
  State<ImageEditorScreen> createState() => _ImageEditorScreenState();
}

class _ImageEditorScreenState extends State<ImageEditorScreen> {
  PreviewSource? _preview;
  ui.Image? _image;

  /// The bytes are a format the `image` package cannot read (HEIC, a
  /// corrupt file…): the screen says so instead of crashing.
  bool _undecodable = false;
  bool _saving = false;

  late ImageEdit _edit = widget.initial;
  late bool _pro = widget.pro;
  CropShape _shape = CropShape.free;
  CropHandle? _activeHandle;
  late EditorTool _tool = widget.initialTool;
  HslColor _hslColor = HslColor.red;
  CurveChannel _curveChannel = CurveChannel.rgb;
  bool _showOriginal = false;
  bool _straightening = false;

  Histogram? _histogram;
  Timer? _histogramDebounce;

  Adjustments get _adjust => _edit.adjust;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final preview = await decodePreviewAsync(widget.bytes);
    if (!mounted) return;
    if (preview == null) {
      setState(() => _undecodable = true);
      return;
    }
    final image = await previewImageOf(preview);
    if (!mounted) {
      image.dispose();
      return;
    }
    setState(() {
      _preview = preview;
      _image = image;
    });
    _scheduleHistogram();
  }

  @override
  void dispose() {
    _histogramDebounce?.cancel();
    _image?.dispose();
    super.dispose();
  }

  void _scheduleHistogram() {
    _histogramDebounce?.cancel();
    _histogramDebounce = Timer(const Duration(milliseconds: 120), () {
      final preview = _preview;
      if (preview == null || !mounted) return;
      final h = Histogram.of(
        preview,
        _adjust.copyWith(sharpen: 0, vignette: 0, grain: 0),
      );
      if (mounted) setState(() => _histogram = h);
    });
  }

  void _update(ImageEdit edit) {
    final colorChanged = edit.adjust != _edit.adjust;
    setState(() => _edit = edit);
    if (colorChanged) _scheduleHistogram();
  }

  void _adjustWith(Adjustments a) => _update(_edit.copyWith(adjust: a));

  // ---- Geometry -----------------------------------------------------------

  int get _fullWidth => _preview!.fullWidth;
  int get _fullHeight => _preview!.fullHeight;

  /// Aspect of the frame after quarter turns (width over height).
  double _frameAspect(int quarterTurns) => quarterTurns % 2 == 1
      ? _fullHeight / _fullWidth
      : _fullWidth / _fullHeight;

  double get _canvasAspect => _frameAspect(_edit.quarterTurns);

  double? get _lockedRatio => CropTool.ratioOf(_shape, _canvasAspect);

  void _rotate() {
    final turns = (_edit.quarterTurns + 1) % 4;
    final ratio = CropTool.ratioOf(_shape, _frameAspect(turns));
    _update(
      _edit.copyWith(
        quarterTurns: turns,
        crop: ratio == null
            ? Crop.full
            : CropTool.fit(Crop.full, ratio, _frameAspect(turns)),
      ),
    );
  }

  void _flip() =>
      _update(_edit.copyWith(flipHorizontal: !_edit.flipHorizontal));

  void _selectShape(CropShape shape) {
    final ratio = CropTool.ratioOf(shape, _canvasAspect);
    setState(() => _shape = shape);
    _update(
      _edit.copyWith(
        crop: ratio == null
            ? _edit.crop
            : CropTool.fit(_edit.crop, ratio, _canvasAspect),
      ),
    );
  }

  void _reset() {
    setState(() => _shape = CropShape.free);
    _update(const ImageEdit());
  }

  // ---- Apply --------------------------------------------------------------

  Future<void> _apply({bool lookToAll = false}) async {
    if (_saving) return;
    if (_edit.isIdentity) {
      Navigator.pop(
        context,
        EditorResult(image: null, edit: _edit, lookToAll: lookToAll),
      );
      return;
    }
    setState(() => _saving = true);
    final image = await applyImageEditAsync(widget.bytes, _edit);
    if (!mounted) return;
    if (image == null) {
      setState(() => _saving = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(context.l10n.cannotEditPhoto)));
      return;
    }
    Navigator.pop(
      context,
      EditorResult(image: image, edit: _edit, lookToAll: lookToAll),
    );
  }

  // ---- Build --------------------------------------------------------------

  bool get _cropVisible => !_pro || _tool == EditorTool.crop;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    if (_undecodable) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(backgroundColor: Colors.black, title: Text(l10n.edit)),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Text(
              l10n.cannotEditPhoto,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(color: Colors.white70),
            ),
          ),
        ),
      );
    }
    final ready = _preview != null && _image != null;
    return Theme(
      data: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: theme.colorScheme.primary,
          brightness: Brightness.dark,
        ),
      ),
      child: Builder(
        builder: (context) {
          final dark = Theme.of(context);
          return Scaffold(
            backgroundColor: Colors.black,
            appBar: AppBar(
              backgroundColor: Colors.black,
              titleSpacing: 0,
              // Long words and large text: shrink rather than overflow.
              title: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: AlignmentDirectional.centerStart,
                child: SegmentedButton<bool>(
                  showSelectedIcon: false,
                  style: const ButtonStyle(
                    visualDensity: VisualDensity.compact,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  segments: [
                    ButtonSegment(
                      value: false,
                      label: Text(l10n.editorModeBasic),
                    ),
                    ButtonSegment(value: true, label: Text(l10n.editorModePro)),
                  ],
                  selected: {_pro},
                  onSelectionChanged: (s) => setState(() => _pro = s.first),
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh),
                  tooltip: l10n.reset,
                  onPressed:
                      !ready ||
                          _saving ||
                          (_edit.isIdentity && _shape == CropShape.free)
                      ? null
                      : _reset,
                ),
                if (_pro && widget.otherPhotos > 0)
                  PopupMenuButton<void>(
                    enabled: ready && !_saving,
                    itemBuilder: (_) => [
                      PopupMenuItem(
                        onTap: () => _apply(lookToAll: true),
                        child: Text(l10n.applyLookToAll),
                      ),
                    ],
                  ),
                IconButton(
                  icon: const Icon(Icons.check),
                  tooltip: l10n.apply,
                  color: Theme.of(context).colorScheme.primary,
                  onPressed: ready && !_saving ? _apply : null,
                ),
              ],
            ),
            body: !ready
                ? const Center(child: CircularProgressIndicator())
                : Stack(
                    children: [
                      Column(
                        children: [
                          Expanded(
                            child: LayoutBuilder(builder: _buildPreview),
                          ),
                          Material(
                            color: dark.colorScheme.surfaceContainer,
                            child: SafeArea(
                              top: false,
                              child: _pro ? _proPanel(context) : _basicPanel(),
                            ),
                          ),
                        ],
                      ),
                      if (_saving)
                        const Positioned.fill(
                          child: ColoredBox(
                            color: Colors.black54,
                            child: Center(child: CircularProgressIndicator()),
                          ),
                        ),
                    ],
                  ),
          );
        },
      ),
    );
  }

  Widget _buildPreview(BuildContext context, BoxConstraints constraints) {
    final preview = _preview!;
    final geo = _edit.geometryFor(preview.fullWidth, preview.fullHeight);
    final crop = _edit.crop;
    final cropOnly = !_cropVisible;
    final w = cropOnly
        ? crop.width * geo.frameWidth
        : geo.frameWidth.toDouble();
    final h = cropOnly
        ? crop.height * geo.frameHeight
        : geo.frameHeight.toDouble();
    const pad = 16.0;
    final area = Size(constraints.maxWidth, constraints.maxHeight);
    final scale = math.min(
      (area.width - 2 * pad) / w,
      (area.height - 2 * pad) / h,
    );
    final rect = Rect.fromCenter(
      center: area.center(Offset.zero),
      width: w * scale,
      height: h * scale,
    );

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onLongPressStart: (_) => setState(() => _showOriginal = true),
      onLongPressEnd: (_) => setState(() => _showOriginal = false),
      onPanStart: !_cropVisible
          ? null
          : (d) {
              final fx = (d.localPosition.dx - rect.left) / rect.width;
              final fy = (d.localPosition.dy - rect.top) / rect.height;
              _activeHandle = CropTool.handleAt(
                _edit.crop,
                fx,
                fy,
                28 / math.min(rect.width, rect.height),
              );
            },
      onPanUpdate: !_cropVisible
          ? null
          : (d) {
              final handle = _activeHandle;
              if (handle == null) return;
              _update(
                _edit.copyWith(
                  crop: CropTool.drag(
                    _edit.crop,
                    handle,
                    d.delta.dx / rect.width,
                    d.delta.dy / rect.height,
                    _lockedRatio,
                    _canvasAspect,
                  ),
                ),
              );
            },
      onPanEnd: !_cropVisible ? null : (_) => _activeHandle = null,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fromRect(
            rect: rect,
            child: EditPreview(
              source: preview,
              image: _image!,
              edit: _edit,
              showCrop: cropOnly,
              original: _showOriginal,
            ),
          ),
          if (_cropVisible)
            Positioned.fill(
              child: CustomPaint(
                painter: _CropOverlayPainter(
                  rect: rect,
                  crop: _edit.crop,
                  fineGrid: _straightening,
                ),
              ),
            ),
          if (_showOriginal)
            Positioned(
              left: rect.left + 8,
              top: rect.top + 8,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  child: Text(
                    context.l10n.showingOriginal,
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ---- Basic --------------------------------------------------------------

  Widget _basicPanel() {
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _shapeChips(),
          _turnButtons(),
          _slider(
            l10n.brightness,
            _adjust.brightness,
            (v) => _adjustWith(_adjust.copyWith(brightness: v)),
          ),
          _slider(
            l10n.contrast,
            _adjust.contrast,
            (v) => _adjustWith(_adjust.copyWith(contrast: v)),
          ),
          _slider(
            l10n.saturation,
            _adjust.saturation,
            (v) => _adjustWith(_adjust.copyWith(saturation: v)),
          ),
        ],
      ),
    );
  }

  Widget _shapeChips() {
    final l10n = context.l10n;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          for (final (label, shape) in [
            (l10n.cropFree, CropShape.free),
            (l10n.cropOriginal, CropShape.original),
            ('1:1', CropShape.square),
            ('4:5', CropShape.fourFive),
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
    );
  }

  Widget _turnButtons() {
    final l10n = context.l10n;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        IconButton(
          icon: const Icon(Icons.rotate_right),
          tooltip: l10n.rotate,
          onPressed: _rotate,
        ),
        IconButton(
          icon: const Icon(Icons.flip),
          tooltip: l10n.flip,
          onPressed: _flip,
        ),
      ],
    );
  }

  // ---- Pro ----------------------------------------------------------------

  Widget _proPanel(BuildContext context) {
    final l10n = context.l10n;
    final tools = [
      (EditorTool.crop, Icons.crop_rotate, l10n.toolCrop),
      (EditorTool.light, Icons.wb_sunny_outlined, l10n.toolLight),
      (EditorTool.color, Icons.thermostat_outlined, l10n.toolColor),
      (EditorTool.hsl, Icons.palette_outlined, l10n.toolHsl),
      (EditorTool.curves, Icons.show_chart, l10n.toolCurves),
      (EditorTool.effects, Icons.auto_awesome_outlined, l10n.toolEffects),
    ];
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
          child: SizedBox(
            height: 48,
            child: HistogramView(histogram: _histogram),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
          child: Text(
            l10n.holdForOriginal,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 11, color: Colors.white60),
          ),
        ),
        SizedBox(
          height: _tool == EditorTool.curves ? 250 : 220,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: switch (_tool) {
              EditorTool.crop => _cropPanel(),
              EditorTool.light => _lightPanel(),
              EditorTool.color => _colorPanel(),
              EditorTool.hsl => _hslPanel(),
              EditorTool.curves => _curvesPanel(),
              EditorTool.effects => _effectsPanel(),
            },
          ),
        ),
        const Divider(height: 1),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            children: [
              for (final (tool, icon, label) in tools)
                _ToolTab(
                  icon: icon,
                  label: label,
                  selected: _tool == tool,
                  changed: _toolChanged(tool),
                  onTap: () => setState(() => _tool = tool),
                ),
            ],
          ),
        ),
      ],
    );
  }

  /// Whether a panel holds any change, for the dot under its tab.
  bool _toolChanged(EditorTool tool) {
    final a = _adjust;
    return switch (tool) {
      EditorTool.crop => _edit.hasGeometry,
      EditorTool.light =>
        a.exposure != 0 ||
            a.brightness != 0 ||
            a.contrast != 0 ||
            a.highlights != 0 ||
            a.shadows != 0 ||
            a.whites != 0 ||
            a.blacks != 0,
      EditorTool.color =>
        a.temperature != 0 ||
            a.tint != 0 ||
            a.vibrance != 0 ||
            a.saturation != 0,
      EditorTool.hsl => a.hsl.any((h) => !h.isIdentity),
      EditorTool.curves => !a.curves.isIdentity,
      EditorTool.effects => a.hasEffects,
    };
  }

  Widget _cropPanel() {
    final l10n = context.l10n;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _shapeChips(),
        _turnButtons(),
        _slider(
          l10n.straighten,
          _edit.straighten,
          (v) => _update(_edit.copyWith(straighten: v)),
          min: -ImageEdit.maxStraighten,
          max: ImageEdit.maxStraighten,
          display: (v) => '${v >= 0 ? '' : '−'}${v.abs().toStringAsFixed(1)}°',
          onStart: () => setState(() => _straightening = true),
          onEnd: () => setState(() => _straightening = false),
        ),
      ],
    );
  }

  Widget _lightPanel() {
    final l10n = context.l10n;
    final a = _adjust;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _slider(
          l10n.exposure,
          a.exposure,
          (v) => _adjustWith(a.copyWith(exposure: v)),
          display: (v) =>
              '${v >= 0 ? '+' : '−'}${(v.abs() * 2).toStringAsFixed(2)}',
        ),
        _slider(
          l10n.contrast,
          a.contrast,
          (v) => _adjustWith(a.copyWith(contrast: v)),
        ),
        _slider(
          l10n.highlights,
          a.highlights,
          (v) => _adjustWith(a.copyWith(highlights: v)),
        ),
        _slider(
          l10n.shadows,
          a.shadows,
          (v) => _adjustWith(a.copyWith(shadows: v)),
        ),
        _slider(
          l10n.whites,
          a.whites,
          (v) => _adjustWith(a.copyWith(whites: v)),
        ),
        _slider(
          l10n.blacks,
          a.blacks,
          (v) => _adjustWith(a.copyWith(blacks: v)),
        ),
        _slider(
          l10n.brightness,
          a.brightness,
          (v) => _adjustWith(a.copyWith(brightness: v)),
        ),
      ],
    );
  }

  Widget _colorPanel() {
    final l10n = context.l10n;
    final a = _adjust;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _slider(
          l10n.temperature,
          a.temperature,
          (v) => _adjustWith(a.copyWith(temperature: v)),
          track: const [Color(0xFF4A7BD0), Color(0xFFE8C547)],
        ),
        _slider(
          l10n.tint,
          a.tint,
          (v) => _adjustWith(a.copyWith(tint: v)),
          track: const [Color(0xFF4FB86A), Color(0xFFD255C8)],
        ),
        _slider(
          l10n.vibrance,
          a.vibrance,
          (v) => _adjustWith(a.copyWith(vibrance: v)),
        ),
        _slider(
          l10n.saturation,
          a.saturation,
          (v) => _adjustWith(a.copyWith(saturation: v)),
        ),
      ],
    );
  }

  static const _hslSwatches = {
    HslColor.red: Color(0xFFE5484D),
    HslColor.orange: Color(0xFFF08A24),
    HslColor.yellow: Color(0xFFF5D90A),
    HslColor.green: Color(0xFF46A758),
    HslColor.aqua: Color(0xFF12A5B0),
    HslColor.blue: Color(0xFF3E63DD),
    HslColor.purple: Color(0xFF8E4EC6),
    HslColor.magenta: Color(0xFFD6409F),
  };

  String _hslName(HslColor c) {
    final l10n = context.l10n;
    return switch (c) {
      HslColor.red => l10n.colorRed,
      HslColor.orange => l10n.colorOrange,
      HslColor.yellow => l10n.colorYellow,
      HslColor.green => l10n.colorGreen,
      HslColor.aqua => l10n.colorAqua,
      HslColor.blue => l10n.colorBlue,
      HslColor.purple => l10n.colorPurple,
      HslColor.magenta => l10n.colorMagenta,
    };
  }

  Widget _hslPanel() {
    final l10n = context.l10n;
    final shift = _adjust.hslOf(_hslColor);
    void set(HslShift s) => _adjustWith(_adjust.withHsl(_hslColor, s));
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              for (final c in HslColor.values)
                Tooltip(
                  message: _hslName(c),
                  child: InkResponse(
                    onTap: () => setState(() => _hslColor = c),
                    radius: 22,
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: _hslSwatches[c],
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: c == _hslColor
                              ? Colors.white
                              : Colors.transparent,
                          width: 2.5,
                        ),
                      ),
                      child: _adjust.hslOf(c).isIdentity
                          ? null
                          : const Center(
                              child: CircleAvatar(
                                radius: 3,
                                backgroundColor: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 6, bottom: 2),
          child: Text(
            _hslName(_hslColor),
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ),
        _slider(l10n.hue, shift.hue, (v) => set(shift.copyWith(hue: v))),
        _slider(
          l10n.saturation,
          shift.saturation,
          (v) => set(shift.copyWith(saturation: v)),
        ),
        _slider(
          l10n.luminance,
          shift.luminance,
          (v) => set(shift.copyWith(luminance: v)),
        ),
      ],
    );
  }

  static const _curveColors = {
    CurveChannel.rgb: Colors.white,
    CurveChannel.red: Color(0xFFE5484D),
    CurveChannel.green: Color(0xFF46A758),
    CurveChannel.blue: Color(0xFF3E63DD),
  };

  Widget _curvesPanel() {
    final curves = _adjust.curves;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              for (final ch in CurveChannel.values)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () => setState(() => _curveChannel = ch),
                    onDoubleTap: () => _adjustWith(
                      _adjust.copyWith(
                        curves: curves.withCurve(ch, ToneCurve.identity),
                      ),
                    ),
                    child: Container(
                      width: 48,
                      height: 36,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: ch == _curveChannel
                              ? _curveColors[ch]!
                              : Colors.white24,
                          width: ch == _curveChannel ? 2 : 1,
                        ),
                      ),
                      child: Text(
                        switch (ch) {
                          CurveChannel.rgb => 'RGB',
                          CurveChannel.red => 'R',
                          CurveChannel.green => 'G',
                          CurveChannel.blue => 'B',
                        },
                        style: TextStyle(
                          color: _curveColors[ch],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              children: [
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 200),
                  child: ToneCurveEditor(
                    curve: curves[_curveChannel],
                    color: _curveColors[_curveChannel]!,
                    background: [
                      for (final ch in CurveChannel.values)
                        if (ch != _curveChannel)
                          (curves[ch], _curveColors[ch]!),
                    ],
                    onChanged: (c) => _adjustWith(
                      _adjust.copyWith(
                        curves: curves.withCurve(_curveChannel, c),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  context.l10n.curveHint,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 11, color: Colors.white60),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _effectsPanel() {
    final l10n = context.l10n;
    final a = _adjust;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _slider(
          l10n.sharpen,
          a.sharpen,
          (v) => _adjustWith(a.copyWith(sharpen: v)),
          min: 0,
        ),
        _slider(
          l10n.vignette,
          a.vignette,
          (v) => _adjustWith(a.copyWith(vignette: v)),
        ),
        _slider(
          l10n.grain,
          a.grain,
          (v) => _adjustWith(a.copyWith(grain: v)),
          min: 0,
        ),
      ],
    );
  }

  /// A labelled slider; double-tap the label to put it back to neutral.
  Widget _slider(
    String label,
    double value,
    ValueChanged<double> onChanged, {
    double min = -1,
    double max = 1,
    String Function(double)? display,
    List<Color>? track,
    VoidCallback? onStart,
    VoidCallback? onEnd,
  }) {
    final shown =
        display?.call(value) ??
        (value == 0
            ? '0'
            : '${value > 0 && min < 0
                      ? '+'
                      : value < 0
                      ? '−'
                      : ''}'
                  '${(value.abs() * 100).round()}');
    final scheme = Theme.of(context).colorScheme;
    Widget slider = Slider(
      value: value.clamp(min, max),
      min: min,
      max: max,
      onChanged: (v) {
        // A light snap to neutral makes zero easy to find by feel.
        final span = max - min;
        onChanged(v.abs() < span * 0.015 ? 0 : v);
      },
      onChangeStart: onStart == null ? null : (_) => onStart(),
      onChangeEnd: onEnd == null ? null : (_) => onEnd(),
    );
    if (min < 0) {
      // Neutral is in the middle: fill from there, not from the left end.
      slider = SliderTheme(
        data: SliderTheme.of(context)
            .copyWith(trackShape: _CentredTrackShape(gradient: track)),
        child: slider,
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        height: 36,
        child: Row(
          children: [
            SizedBox(
              width: 100,
              child: GestureDetector(
                onDoubleTap: () => onChanged(min < 0 ? 0 : min),
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 13),
                ),
              ),
            ),
            Expanded(child: slider),
            SizedBox(
              width: 48,
              child: Text(
                shown,
                textAlign: TextAlign.end,
                style: TextStyle(
                  fontSize: 12,
                  fontFeatures: const [FontFeature.tabularFigures()],
                  color: value == 0 ? Colors.white38 : scheme.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ToolTab extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final bool changed;
  final VoidCallback onTap;

  const _ToolTab({
    required this.icon,
    required this.label,
    required this.selected,
    required this.changed,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = selected ? scheme.primary : scheme.onSurfaceVariant;
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(fontSize: 11, color: color)),
            const SizedBox(height: 2),
            CircleAvatar(
              radius: 2,
              backgroundColor: changed ? scheme.primary : Colors.transparent,
            ),
          ],
        ),
      ),
    );
  }
}

/// A track filled from its middle to the thumb, for sliders whose neutral
/// value is in the middle.
class _CentredTrackShape extends RoundedRectSliderTrackShape {
  /// Colours of the track from end to end (temperature, tint); null for the
  /// plain filled track.
  final List<Color>? gradient;

  _CentredTrackShape({this.gradient});

  @override
  void paint(
    PaintingContext context,
    Offset offset, {
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required Animation<double> enableAnimation,
    required TextDirection textDirection,
    required Offset thumbCenter,
    Offset? secondaryOffset,
    bool isDiscrete = false,
    bool isEnabled = false,
    double additionalActiveTrackHeight = 2,
  }) {
    final rect = getPreferredRect(
      parentBox: parentBox,
      offset: offset,
      sliderTheme: sliderTheme,
      isEnabled: isEnabled,
      isDiscrete: isDiscrete,
    );
    final radius = Radius.circular(rect.height / 2);
    final mid = rect.center.dx;
    final colors = gradient;
    if (colors != null) {
      context.canvas
        ..drawRRect(
          RRect.fromRectAndRadius(rect, radius),
          Paint()..shader = LinearGradient(colors: colors).createShader(rect),
        )
        ..drawCircle(
          Offset(mid, rect.center.dy),
          rect.height,
          Paint()..color = Colors.white70,
        );
      return;
    }
    context.canvas.drawRRect(
      RRect.fromRectAndRadius(rect, radius),
      Paint()..color = sliderTheme.inactiveTrackColor ?? Colors.white24,
    );
    final active = Rect.fromLTRB(
      math.min(mid, thumbCenter.dx),
      rect.top - 1,
      math.max(mid, thumbCenter.dx),
      rect.bottom + 1,
    );
    context.canvas
      ..drawRRect(
        RRect.fromRectAndRadius(active, radius),
        Paint()..color = sliderTheme.activeTrackColor ?? Colors.white,
      )
      ..drawCircle(
        Offset(mid, rect.center.dy),
        rect.height,
        Paint()..color = sliderTheme.activeTrackColor ?? Colors.white,
      );
  }
}

class _CropOverlayPainter extends CustomPainter {
  final Rect rect;
  final Crop crop;
  final bool fineGrid;

  _CropOverlayPainter({
    required this.rect,
    required this.crop,
    this.fineGrid = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cropRect = Rect.fromLTRB(
      rect.left + crop.left * rect.width,
      rect.top + crop.top * rect.height,
      rect.left + crop.right * rect.width,
      rect.top + crop.bottom * rect.height,
    );
    final dim = Paint()..color = Colors.black.withValues(alpha: 0.55);
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

    final lines = fineGrid ? 9 : 3;
    final grid = Paint()
      ..color = Colors.white.withValues(alpha: fineGrid ? 0.25 : 0.35)
      ..strokeWidth = 1;
    for (var i = 1; i < lines; i++) {
      final x = cropRect.left + cropRect.width * i / lines;
      final y = cropRect.top + cropRect.height * i / lines;
      canvas
        ..drawLine(Offset(x, cropRect.top), Offset(x, cropRect.bottom), grid)
        ..drawLine(Offset(cropRect.left, y), Offset(cropRect.right, y), grid);
    }

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
      oldDelegate.crop != crop ||
      oldDelegate.rect != rect ||
      oldDelegate.fineGrid != fineGrid;
}
