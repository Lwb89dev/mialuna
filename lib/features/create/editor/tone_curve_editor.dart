import 'package:flutter/material.dart';

import 'adjustments.dart';

/// A square tone-curve editor: drag a point to move it, tap on empty space
/// to add one, double-tap a point to remove it. The end points move only
/// up and down.
class ToneCurveEditor extends StatefulWidget {
  final ToneCurve curve;
  final Color color;
  final ValueChanged<ToneCurve> onChanged;

  /// Other curves drawn faintly behind, for reference.
  final List<(ToneCurve, Color)> background;

  const ToneCurveEditor({
    super.key,
    required this.curve,
    required this.color,
    required this.onChanged,
    this.background = const [],
  });

  @override
  State<ToneCurveEditor> createState() => _ToneCurveEditorState();
}

class _ToneCurveEditorState extends State<ToneCurveEditor> {
  int? _dragging;

  static const _hitRadius = 22.0;

  int? _pointAt(Offset pos, Size size) {
    int? best;
    var bestDist = double.infinity;
    for (var i = 0; i < widget.curve.points.length; i++) {
      final p = widget.curve.points[i];
      final d =
          (Offset(p.x * size.width, (1 - p.y) * size.height) - pos).distance;
      if (d < _hitRadius && d < bestDist) {
        best = i;
        bestDist = d;
      }
    }
    return best;
  }

  (double, double) _valueAt(Offset pos, Size size) => (
    (pos.dx / size.width).clamp(0.0, 1.0),
    (1 - pos.dy / size.height).clamp(0.0, 1.0),
  );

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final size = constraints.biggest;
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onPanStart: (d) {
              var index = _pointAt(d.localPosition, size);
              if (index == null) {
                final (x, y) = _valueAt(d.localPosition, size);
                final added = widget.curve.inserted(x, y);
                if (added == null) return;
                widget.onChanged(added.$1);
                index = added.$2;
              }
              _dragging = index;
            },
            onPanUpdate: (d) {
              final index = _dragging;
              if (index == null) return;
              final (x, y) = _valueAt(d.localPosition, size);
              widget.onChanged(widget.curve.moved(index, x, y));
            },
            onPanEnd: (_) => _dragging = null,
            onTapUp: (d) {
              if (_pointAt(d.localPosition, size) != null) return;
              final (x, y) = _valueAt(d.localPosition, size);
              final added = widget.curve.inserted(x, y);
              if (added != null) widget.onChanged(added.$1);
            },
            onDoubleTapDown: (d) {
              final index = _pointAt(d.localPosition, size);
              if (index != null) {
                widget.onChanged(widget.curve.removed(index));
              }
            },
            child: CustomPaint(
              painter: _CurvePainter(
                curve: widget.curve,
                color: widget.color,
                background: widget.background,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _CurvePainter extends CustomPainter {
  final ToneCurve curve;
  final Color color;
  final List<(ToneCurve, Color)> background;

  _CurvePainter({
    required this.curve,
    required this.color,
    required this.background,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(8)),
      Paint()..color = Colors.white.withValues(alpha: 0.05),
    );
    final grid = Paint()
      ..color = Colors.white.withValues(alpha: 0.12)
      ..strokeWidth = 1;
    for (var i = 1; i < 4; i++) {
      final x = size.width * i / 4, y = size.height * i / 4;
      canvas
        ..drawLine(Offset(x, 0), Offset(x, size.height), grid)
        ..drawLine(Offset(0, y), Offset(size.width, y), grid);
    }
    canvas.drawLine(
      Offset(0, size.height),
      Offset(size.width, 0),
      grid..color = Colors.white.withValues(alpha: 0.18),
    );

    for (final (c, col) in background) {
      if (!c.isIdentity) {
        _drawCurve(canvas, size, c, col.withValues(alpha: 0.35), 1.5);
      }
    }
    _drawCurve(canvas, size, curve, color, 2.5);

    final dot = Paint()..color = color;
    final ring = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    for (final p in curve.points) {
      final o = Offset(p.x * size.width, (1 - p.y) * size.height);
      canvas
        ..drawCircle(o, 7, dot)
        ..drawCircle(o, 7, ring);
    }
  }

  void _drawCurve(
    Canvas canvas,
    Size size,
    ToneCurve c,
    Color col,
    double width,
  ) {
    final table = c.table(256);
    final path = Path();
    for (var i = 0; i < table.length; i++) {
      final x = i / (table.length - 1) * size.width;
      final y = (1 - table[i]) * size.height;
      i == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = col
        ..style = PaintingStyle.stroke
        ..strokeWidth = width,
    );
  }

  @override
  bool shouldRepaint(_CurvePainter old) =>
      old.curve != curve || old.color != color || old.background != background;
}
