import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

/// Recognizes a two-finger pinch without competing with one-finger gestures:
/// it stays passive until a second finger lands, so scrolling a list or
/// swiping a carousel keeps working untouched.
class PinchGestureRecognizer extends OneSequenceGestureRecognizer {
  void Function(Offset focal, double distance)? onStart;
  void Function(Offset focal, double distance)? onUpdate;
  VoidCallback? onEnd;

  final Map<int, Offset> _pointers = {};
  bool _active = false;

  @override
  void addAllowedPointer(PointerDownEvent event) {
    startTrackingPointer(event.pointer, event.transform);
    _pointers[event.pointer] = event.position;
    if (_pointers.length >= 2 && !_active) {
      _active = true;
      resolve(GestureDisposition.accepted);
      onStart?.call(_focal(), _distance());
    }
  }

  @override
  void handleEvent(PointerEvent event) {
    if (event is PointerMoveEvent) {
      _pointers[event.pointer] = event.position;
      if (_active) onUpdate?.call(_focal(), _distance());
    } else if (event is PointerUpEvent || event is PointerCancelEvent) {
      _pointers.remove(event.pointer);
      stopTrackingPointer(event.pointer);
      if (_active && _pointers.length < 2) {
        _active = false;
        onEnd?.call();
      }
    }
  }

  Offset _focal() {
    var sum = Offset.zero;
    var n = 0;
    for (final p in _pointers.values.take(2)) {
      sum += p;
      n++;
    }
    return n == 0 ? Offset.zero : sum / n.toDouble();
  }

  double _distance() {
    final pts = _pointers.values.take(2).toList();
    return pts.length < 2 ? 1 : math.max((pts[0] - pts[1]).distance, 1);
  }

  @override
  void rejectGesture(int pointer) {
    _pointers.remove(pointer);
    super.rejectGesture(pointer);
  }

  @override
  void didStopTrackingLastPointer(int pointer) {
    if (_active) {
      _active = false;
      onEnd?.call();
    }
    _pointers.clear();
  }

  @override
  String get debugDescription => 'pinch';
}

/// Instagram-style zoom: pinch the media with two fingers and it grows above
/// the rest of the screen (the feed does not scroll, no new page opens);
/// letting go springs it back into place.
class PinchToZoom extends StatefulWidget {
  final Widget child;
  final bool enabled;
  final double maxScale;

  const PinchToZoom({
    super.key,
    required this.child,
    this.enabled = true,
    this.maxScale = 5,
  });

  @override
  State<PinchToZoom> createState() => _PinchToZoomState();
}

class _PinchToZoomState extends State<PinchToZoom>
    with SingleTickerProviderStateMixin {
  final _state = ValueNotifier<_ZoomValue>(const _ZoomValue.identity());
  late final AnimationController _back;
  OverlayEntry? _entry;
  Offset _focalStart = Offset.zero;
  double _distanceStart = 1;
  Rect _rect = Rect.zero;
  bool _zooming = false;
  _ZoomValue _releasedFrom = const _ZoomValue.identity();

  @override
  void initState() {
    super.initState();
    _back =
        AnimationController(
            vsync: this,
            duration: const Duration(milliseconds: 220),
          )
          ..addListener(_onBackTick)
          ..addStatusListener(_onBackStatus);
  }

  @override
  void dispose() {
    _back.dispose();
    _entry?.remove();
    _entry = null;
    _state.dispose();
    super.dispose();
  }

  void _start(Offset focal, double distance) {
    final box = context.findRenderObject() as RenderBox?;
    if (box == null || !box.attached) return;
    _back.stop();
    _focalStart = focal;
    _distanceStart = distance;
    _rect = box.localToGlobal(Offset.zero) & box.size;
    _state.value = const _ZoomValue.identity();
    if (_entry == null) {
      _entry = OverlayEntry(builder: _buildOverlay);
      Overlay.of(context, rootOverlay: true).insert(_entry!);
    }
    setState(() => _zooming = true);
  }

  void _update(Offset focal, double distance) {
    final scale = (distance / _distanceStart).clamp(1.0, widget.maxScale);
    _state.value = _ZoomValue(scale, focal - _focalStart);
  }

  void _end() {
    if (!_zooming) return;
    _releasedFrom = _state.value;
    _back.forward(from: 0);
  }

  void _onBackTick() {
    final t = Curves.easeOutCubic.transform(_back.value);
    _state.value = _ZoomValue(
      1 + (_releasedFrom.scale - 1) * (1 - t),
      _releasedFrom.offset * (1 - t),
    );
  }

  void _onBackStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      _entry?.remove();
      _entry = null;
      if (mounted) setState(() => _zooming = false);
    }
  }

  Widget _buildOverlay(BuildContext context) {
    return ValueListenableBuilder<_ZoomValue>(
      valueListenable: _state,
      builder: (context, z, _) {
        final dim = ((z.scale - 1) / 1.5).clamp(0.0, 0.75);
        // Scaling happens around the pinch centre: a point p of the original
        // layout lands on F + s·(p − F0).
        final shift = z.offset + (_rect.topLeft - _focalStart) * (z.scale - 1);
        return IgnorePointer(
          child: Stack(
            children: [
              Positioned.fill(
                child: ColoredBox(color: Colors.black.withValues(alpha: dim)),
              ),
              Positioned(
                left: _rect.left,
                top: _rect.top,
                width: _rect.width,
                height: _rect.height,
                child: Transform(
                  alignment: Alignment.topLeft,
                  transform: Matrix4.identity()
                    ..translateByDouble(shift.dx, shift.dy, 0, 1)
                    ..scaleByDouble(z.scale, z.scale, 1, 1),
                  child: widget.child,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) return widget.child;
    return RawGestureDetector(
      behavior: HitTestBehavior.translucent,
      gestures: {
        PinchGestureRecognizer:
            GestureRecognizerFactoryWithHandlers<PinchGestureRecognizer>(
              PinchGestureRecognizer.new,
              (r) => r
                ..onStart = _start
                ..onUpdate = _update
                ..onEnd = _end,
            ),
      },
      // While zoomed, the original is hidden: the overlay shows the copy.
      child: Opacity(opacity: _zooming ? 0 : 1, child: widget.child),
    );
  }
}

class _ZoomValue {
  final double scale;
  final Offset offset;
  const _ZoomValue(this.scale, this.offset);
  const _ZoomValue.identity() : scale = 1, offset = Offset.zero;
}
