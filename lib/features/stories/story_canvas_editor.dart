import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../core/nostr/models/story_text.dart';
import '../../core/text/hashtags.dart';
import '../../l10n/strings.dart';
import 'story_text_view.dart';

/// Colours offered for story texts.
const _palette = [
  0xFFFFFF,
  0x000000,
  0xFF3B30,
  0xFF9500,
  0xFFCC00,
  0x34C759,
  0x00C7BE,
  0x007AFF,
  0xAF52DE,
  0xFF2D92,
];

/// The scale range of the size slider (pinching goes further).
const _sliderMin = 0.5;
const _sliderMax = 3.0;

/// A story text being edited. The value changes while it is dragged.
class _Entry {
  final Key key = UniqueKey();
  StoryText value;
  _Entry(this.value);
}

/// The picture of a story with its texts, edited in place, like Instagram:
/// tap the picture to write — the words appear right on it, over the dimmed
/// photo, with the fonts and colours above the keyboard — then drag a text to
/// move it, pinch to resize and turn it, tap it to edit it again, or drop it
/// on the bin to delete it.
///
/// It fills the whole screen; the screen around it contributes its own bars
/// as [top] and [bottom], which fade out while a text is written or dragged.
/// Reach [StoryCanvasEditorState.addText] with a `GlobalKey` to start a new
/// text from a button.
class StoryCanvasEditor extends StatefulWidget {
  /// The picture (or a frame of the video); null shows a plain backdrop.
  final Uint8List? imageBytes;

  /// Width over height of the picture; unknown → a phone-screen shape.
  final double? mediaAspect;
  final List<StoryText> initial;

  /// Told after every change, with the texts as they are now.
  final ValueChanged<List<StoryText>> onChanged;
  final Widget? top;
  final Widget? bottom;

  /// Whether Back may leave the screen while no text is being written. When
  /// it may not, [onLeaveBlocked] is called instead (to ask "discard?").
  /// While a text is written Back always just finishes it.
  final bool canLeave;
  final VoidCallback? onLeaveBlocked;

  const StoryCanvasEditor({
    super.key,
    this.imageBytes,
    this.mediaAspect,
    this.initial = const [],
    required this.onChanged,
    this.top,
    this.bottom,
    this.canLeave = true,
    this.onLeaveBlocked,
  });

  @override
  State<StoryCanvasEditor> createState() => StoryCanvasEditorState();
}

class StoryCanvasEditorState extends State<StoryCanvasEditor> {
  static const _binHeight = 80.0;

  final _canvasKey = GlobalKey();
  final _writer = GlobalKey<_InlineTextWriterState>();
  late final List<_Entry> _entries = [
    for (final t in widget.initial) _Entry(t),
  ];

  /// The text being written, if any. A new one is not in [_entries] yet.
  _Entry? _editing;
  bool _editingIsNew = false;

  _Entry? _dragging;
  bool _overBin = false;
  double _startScale = 1;
  double _startRotation = 0;

  List<StoryText> get texts => [for (final e in _entries) e.value];
  bool get isEditingText => _editing != null;

  void _changed() => widget.onChanged(texts);

  // ── gestures ────────────────────────────────────────────────────────

  void _onScaleStart(_Entry e) {
    _startScale = e.value.scale;
    _startRotation = e.value.rotation;
    setState(() => _dragging = e);
  }

  void _onScaleUpdate(_Entry e, ScaleUpdateDetails d, Rect media) {
    final v = e.value;
    setState(() {
      e.value = v.copyWith(
        x: (v.x + d.focalPointDelta.dx / media.width).clamp(0.0, 1.0),
        y: (v.y + d.focalPointDelta.dy / media.height).clamp(0.0, 1.0),
        scale: (_startScale * d.scale).clamp(
          StoryText.minScale,
          StoryText.maxScale,
        ),
        rotation: _startRotation + d.rotation,
      );
      _overBin = _isOverBin(d.focalPoint);
    });
  }

  void _onScaleEnd(_Entry e) {
    setState(() {
      if (_overBin) _entries.remove(e);
      _dragging = null;
      _overBin = false;
    });
    _changed();
  }

  /// Whether the finger ([global]) is on the bin at the bottom of the canvas.
  bool _isOverBin(Offset global) {
    final box = _canvasKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return false;
    final local = box.globalToLocal(global);
    final nearBottom = local.dy > box.size.height - _binHeight;
    return nearBottom && (local.dx - box.size.width / 2).abs() < _binHeight / 2;
  }

  // ── writing ─────────────────────────────────────────────────────────

  /// Starts a new text, written in place over the picture.
  void addText() {
    if (_editing != null) return;
    if (_entries.length >= StoryText.maxTexts) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.storyTextLimit(StoryText.maxTexts)),
        ),
      );
      return;
    }
    // Each new text starts a little lower, so they do not pile up.
    final y = 0.3 + 0.1 * (_entries.length % 5);
    setState(() {
      _editing = _Entry(StoryText(text: '', y: y));
      _editingIsNew = true;
    });
  }

  void _edit(_Entry e) {
    if (_editing != null) return;
    setState(() {
      _editing = e;
      _editingIsNew = false;
    });
  }

  /// The writer is done: an emptied text is a deleted text.
  void _finishEditing(StoryText result) {
    final entry = _editing;
    if (entry == null) return;
    final empty = StoryText.cleanText(result.text).isEmpty;
    setState(() {
      if (empty) {
        _entries.remove(entry);
      } else {
        entry.value = result;
        if (_editingIsNew) _entries.add(entry);
      }
      _editing = null;
      _editingIsNew = false;
    });
    _changed();
  }

  // ── layout ──────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final editing = _editing;
    final calm = editing == null && _dragging == null;
    return PopScope(
      canPop: editing == null && widget.canLeave,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        if (_editing == null) {
          widget.onLeaveBlocked?.call();
        } else {
          _writer.currentState?.finish();
        }
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          final media = storyMediaRect(
            constraints.biggest,
            widget.mediaAspect ?? 9 / 16,
          );
          return Stack(
            fit: StackFit.expand,
            children: [
              _canvas(media),
              if (calm && widget.top != null) _bar(widget.top!, top: true),
              if (calm && widget.bottom != null)
                _bar(widget.bottom!, top: false),
              if (editing != null)
                Positioned.fill(
                  child: _InlineTextWriter(
                    key: _writer,
                    initial: editing.value,
                    mediaWidth: media.width,
                    onDone: _finishEditing,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  /// A bar of the screen around the canvas, on a fade so it reads on any
  /// picture.
  Widget _bar(Widget child, {required bool top}) {
    final from = top ? Alignment.topCenter : Alignment.bottomCenter;
    final to = top ? Alignment.bottomCenter : Alignment.topCenter;
    return Positioned(
      top: top ? 0 : null,
      bottom: top ? null : 0,
      left: 0,
      right: 0,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: from,
            end: to,
            colors: [Colors.black54, Colors.black.withValues(alpha: 0)],
          ),
        ),
        child: SafeArea(top: top, bottom: !top, child: child),
      ),
    );
  }

  Widget _canvas(Rect media) {
    final hidden = _editing;
    return Stack(
      key: _canvasKey,
      clipBehavior: Clip.hardEdge,
      children: [
        const Positioned.fill(child: ColoredBox(color: Colors.black)),
        Positioned.fromRect(
          rect: media,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: addText,
            child: _backdrop(),
          ),
        ),
        for (final e in _entries)
          if (!identical(e, hidden))
            placeStoryText(e.value, media, _draggable(e, media), key: e.key),
        if (_dragging != null) _bin(),
      ],
    );
  }

  Widget _backdrop() {
    final bytes = widget.imageBytes;
    if (bytes == null) {
      return const ColoredBox(
        color: Color(0xFF1B1B1B),
        child: Center(
          child: Icon(
            Icons.play_circle_outline,
            color: Colors.white38,
            size: 56,
          ),
        ),
      );
    }
    return Image.memory(bytes, fit: BoxFit.fill, cacheWidth: 1080);
  }

  Widget _draggable(_Entry e, Rect media) => GestureDetector(
    behavior: HitTestBehavior.opaque,
    onTap: () => _edit(e),
    onScaleStart: (_) => _onScaleStart(e),
    onScaleUpdate: (d) => _onScaleUpdate(e, d, media),
    onScaleEnd: (_) => _onScaleEnd(e),
    child: StoryTextView(text: e.value, mediaWidth: media.width),
  );

  Widget _bin() => Positioned(
    left: 0,
    right: 0,
    bottom: 24,
    child: Center(
      child: AnimatedScale(
        scale: _overBin ? 1.25 : 1,
        duration: const Duration(milliseconds: 120),
        child: CircleAvatar(
          radius: 26,
          backgroundColor: _overBin ? Colors.red : Colors.white24,
          child: const Icon(Icons.delete_outline, color: Colors.white),
        ),
      ),
    ),
  );
}

/// A text controller that underlines the `#hashtags` as they are typed, so
/// it is clear which words will be tappable.
class _TagController extends TextEditingController {
  _TagController(String text) : super(text: text);

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    // Mid-composition (accents, other scripts) the keyboard's own marks win.
    if (withComposing && value.isComposingRangeValid) {
      return super.buildTextSpan(
        context: context,
        style: style,
        withComposing: withComposing,
      );
    }
    final underlined = storyTagStyle(style ?? const TextStyle());
    final spans = <TextSpan>[];
    var last = 0;
    for (final m in Hashtags.matches(text)) {
      if (m.start > last) {
        spans.add(TextSpan(text: text.substring(last, m.start)));
      }
      spans.add(TextSpan(text: m.group(0), style: underlined));
      last = m.end;
    }
    if (last < text.length) spans.add(TextSpan(text: text.substring(last)));
    return TextSpan(style: style, children: spans);
  }
}

/// The writing mode: the photo dimmed, the text field in the middle of it in
/// the very look the text will have, and the tools above the keyboard — fonts,
/// colours, the pill behind the letters and a size slider. Tapping outside
/// the words (or Back) finishes, like Instagram.
class _InlineTextWriter extends StatefulWidget {
  final StoryText initial;
  final double mediaWidth;
  final ValueChanged<StoryText> onDone;

  const _InlineTextWriter({
    super.key,
    required this.initial,
    required this.mediaWidth,
    required this.onDone,
  });

  @override
  State<_InlineTextWriter> createState() => _InlineTextWriterState();
}

class _InlineTextWriterState extends State<_InlineTextWriter> {
  late final _TagController _controller = _TagController(widget.initial.text);
  late StoryText _value = widget.initial;
  bool _finished = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Hands the text back to the canvas (once).
  void finish() {
    if (_finished) return;
    _finished = true;
    FocusManager.instance.primaryFocus?.unfocus();
    widget.onDone(_value.copyWith(text: _controller.text));
  }

  void _cycleBackground() {
    const order = StoryTextBackground.values;
    final next = order[(order.indexOf(_value.background) + 1) % order.length];
    setState(() => _value = _value.copyWith(background: next));
  }

  @override
  Widget build(BuildContext context) {
    final inset = MediaQuery.viewInsetsOf(context).bottom;
    final navigation = MediaQuery.paddingOf(context).bottom;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: finish,
      child: ColoredBox(
        color: Colors.black.withValues(alpha: 0.62),
        child: Padding(
          padding: EdgeInsets.only(bottom: math.max(inset, navigation)),
          child: SafeArea(
            bottom: false,
            child: Column(
              children: [
                _topRow(context.l10n),
                Expanded(child: _middle(context.l10n)),
                _fonts(context.l10n),
                _colors(context.l10n.storyTextColor),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _topRow(AppLocalizations l10n) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 8),
    child: Row(
      children: [
        IconButton(
          tooltip: l10n.storyTextBackground,
          color: Colors.white,
          isSelected: _value.background != StoryTextBackground.none,
          selectedIcon: const Icon(Icons.format_color_fill),
          icon: const Icon(Icons.format_color_fill_outlined),
          onPressed: _cycleBackground,
        ),
        Expanded(child: _doneAction(l10n)),
      ],
    ),
  );

  Widget _doneAction(AppLocalizations l10n) {
    return Align(
      alignment: AlignmentDirectional.centerEnd,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: AlignmentDirectional.centerEnd,
        child: TextButton(
          onPressed: finish,
          child: Text(
            l10n.done,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }

  Widget _middle(AppLocalizations l10n) => Row(
    children: [
      _sizeSlider(l10n.storyTextSize),
      Expanded(child: Center(child: _field(l10n.storyTextHint))),
      // As wide as the slider, so the field stays in the middle.
      const SizedBox(width: 48),
    ],
  );

  /// Instagram's vertical size slider, on the left.
  Widget _sizeSlider(String label) => SizedBox(
    width: 48,
    child: RotatedBox(
      quarterTurns: 3,
      child: Semantics(
        label: label,
        child: Slider(
          min: _sliderMin,
          max: _sliderMax,
          value: _value.scale.clamp(_sliderMin, _sliderMax),
          activeColor: Colors.white,
          inactiveColor: Colors.white30,
          onChanged: (v) => setState(() => _value = _value.copyWith(scale: v)),
        ),
      ),
    ),
  );

  /// The field itself, in the look the text will have: hugging its words,
  /// on its pill, as large as it will be on the picture.
  Widget _field(String hint) {
    final look = storyTextLook(_value, widget.mediaWidth);
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaler: TextScaler.noScaling),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: look.size * 2,
          maxWidth: storyTextMaxWidth(widget.mediaWidth),
        ),
        child: IntrinsicWidth(
          child: storyTextPill(
            pill: look.pill,
            size: look.size,
            child: TextField(
              controller: _controller,
              autofocus: true,
              minLines: 1,
              maxLines: 6,
              maxLength: StoryText.maxLength,
              buildCounter: (
                _, {
                required currentLength,
                required isFocused,
                required maxLength,
              }) => null,
              textAlign: TextAlign.center,
              textCapitalization: TextCapitalization.sentences,
              enableIMEPersonalizedLearning: false,
              cursorColor: look.style.color,
              style: look.style,
              decoration: InputDecoration.collapsed(
                hintText: hint,
                hintStyle: look.style.copyWith(
                  color: Colors.white54,
                  shadows: const [],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _fonts(AppLocalizations l10n) {
    final names = {
      StoryTextFont.classic: l10n.storyFontClassic,
      StoryTextFont.bold: l10n.storyFontBold,
      StoryTextFont.serif: l10n.storyFontSerif,
      StoryTextFont.mono: l10n.storyFontMono,
      StoryTextFont.italic: l10n.storyFontItalic,
    };
    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        children: [
          for (final f in StoryTextFont.values) _fontChip(f, names[f]!),
        ],
      ),
    );
  }

  Widget _fontChip(StoryTextFont font, String name) {
    final selected = _value.font == font;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: StoryPill(
        // The name is written in its own font.
        label: Text(name, style: storyTextStyle(font, 14)),
        selected: selected,
        onTap: () => setState(() => _value = _value.copyWith(font: font)),
      ),
    );
  }

  Widget _colors(String label) => SizedBox(
    height: 44,
    child: ListView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      children: [for (final c in _palette) _swatch(c, label)],
    ),
  );

  Widget _swatch(int rgb, String label) {
    final selected = _value.color == rgb;
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: GestureDetector(
        onTap: () => setState(() => _value = _value.copyWith(color: rgb)),
        child: Container(
          width: 30,
          height: 30,
          margin: const EdgeInsets.only(right: 12, top: 7, bottom: 7),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: storyColor(rgb),
            border: Border.all(
              color: selected ? Colors.white : Colors.white54,
              width: selected ? 3 : 1.5,
            ),
          ),
        ),
      ),
    );
  }
}

/// A choice on top of a picture (a font, who sees the story): white when
/// chosen, a translucent veil when not, so it reads on any photo and in both
/// themes. Drawn by hand: the Material chips follow the app theme, which is
/// light, and turned out pale-on-pale here.
class StoryPill extends StatelessWidget {
  final Widget label;
  final IconData? icon;
  final bool selected;
  final VoidCallback? onTap;

  const StoryPill({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
  });

  /// A font chip sits in a horizontal list (unbounded width) and keeps its
  /// natural size. A chip in a bounded bar scales the word down to fit.
  Widget _pillRow(double maxWidth) {
    final word = maxWidth.isFinite ? _scaled(label) : label;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[Icon(icon), const SizedBox(width: 6)],
        word,
      ],
    );
  }

  Widget _scaled(Widget child) {
    return Flexible(
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: AlignmentDirectional.centerStart,
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ink = selected ? Colors.black : Colors.white;
    return Semantics(
      button: true,
      selected: selected,
      enabled: onTap != null,
      child: Material(
        color: selected ? Colors.white : Colors.white24,
        shape: const StadiumBorder(),
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: IconTheme(
              data: IconThemeData(color: ink, size: 16),
              child: DefaultTextStyle.merge(
                style: TextStyle(color: ink),
                child: LayoutBuilder(
                  builder: (context, constraints) =>
                      _pillRow(constraints.maxWidth),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
