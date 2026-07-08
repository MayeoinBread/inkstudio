import 'dart:math' as math;

import 'package:flutter/material.dart';

enum CropHandle {
  none,
  topLeft,
  topRight,
  bottomLeft,
  bottomRight
}

class CropOverlay extends StatefulWidget {
  final Rect initialRect;  // Normalised, 0..1
  final double aspectRatio;
  final Size imageSize;
  final ValueChanged<Rect> onChanged;

  const CropOverlay({
    super.key,
    required this.aspectRatio,
    required this.imageSize,
    required this.onChanged,
    required this.initialRect
  });

  @override
  State<CropOverlay> createState() => _CropOverlayState();
}

class _CropOverlayState extends State<CropOverlay> {
  Rect cropRect = Rect.zero;
  Rect displayRect = Rect.zero;

  CropHandle _activeHandle = CropHandle.none;
  static const double _handleRadius = 20;

  @override
  void initState() {
    super.initState();

    cropRect = widget.initialRect;
    displayRect = _toDisplay(cropRect);
  }

  Rect _toDisplay(Rect r) {
    return Rect.fromLTWH(
      r.left * widget.imageSize.width,
      r.top * widget.imageSize.height,
      r.width * widget.imageSize.width,
      r.height * widget.imageSize.height
    );
  }

  Rect _fromDisplay(Rect r) {
    return Rect.fromLTWH(
      r.left / widget.imageSize.width,
      r.top / widget.imageSize.height,
      r.width / widget.imageSize.width,
      r.height / widget.imageSize.height
    );
  }

  CropHandle _hitTestHandle(Offset pos, Rect rect) {
  const hitSize = 48.0; // bigger for touch devices

  Rect makeHandle(Offset c) =>
      Rect.fromCenter(center: c, width: hitSize, height: hitSize);

  if (makeHandle(rect.topLeft).contains(pos)) return CropHandle.topLeft;
  if (makeHandle(rect.topRight).contains(pos)) return CropHandle.topRight;
  if (makeHandle(rect.bottomLeft).contains(pos)) return CropHandle.bottomLeft;
  if (makeHandle(rect.bottomRight).contains(pos)) return CropHandle.bottomRight;

  return CropHandle.none;
}

  void _resize(CropHandle handle, Offset delta) {
    const minSize = 48.0;

    final imageW = widget.imageSize.width;
    final imageH = widget.imageSize.height;
    final aspect = widget.aspectRatio;

    Rect r = displayRect;

    double left = r.left;
    double top = r.top;
    double right = r.right;
    double bottom = r.bottom;

    switch (handle) {
      case CropHandle.bottomRight:
        right += delta.dx;
        bottom += delta.dy;
        break;

      case CropHandle.bottomLeft:
        left += delta.dx;
        bottom += delta.dy;
        break;

      case CropHandle.topRight:
        right += delta.dx;
        top += delta.dy;
        break;

      case CropHandle.topLeft:
        left += delta.dx;
        top += delta.dy;
        break;

      case CropHandle.none:
        return;
    }

    double width = right - left;
    double height = bottom - top;

    // enforce aspect ratio FIRST (no vector projection nonsense)
    final currentAspect = width / height;

    if (currentAspect > aspect) {
      // too wide → adjust width
      width = height * aspect;
    } else {
      // too tall → adjust height
      height = width / aspect;
    }

    // enforce minimum size
    if (width < minSize) {
      width = minSize;
      height = width / aspect;
    }

    if (height < minSize) {
      height = minSize;
      width = height * aspect;
    }

    // re-anchor based on handle
    switch (handle) {
      case CropHandle.bottomRight:
        right = left + width;
        bottom = top + height;
        break;

      case CropHandle.bottomLeft:
        left = right - width;
        bottom = top + height;
        break;

      case CropHandle.topRight:
        right = left + width;
        top = bottom - height;
        break;

      case CropHandle.topLeft:
        left = right - width;
        top = bottom - height;
        break;

      case CropHandle.none:
        return;
    }

    Rect updated = Rect.fromLTRB(left, top, right, bottom);

    // SAFE clamp (no negative max)
    final maxX = math.max(0.0, imageW - updated.width);
    final maxY = math.max(0.0, imageH - updated.height);

    final clampedLeft = updated.left.clamp(0.0, maxX);
    final clampedTop = updated.top.clamp(0.0, maxY);

    updated = Rect.fromLTWH(clampedLeft, clampedTop, updated.width, updated.height);

    setState(() {
      displayRect = updated;
      cropRect = _fromDisplay(updated);
    });

    widget.onChanged(cropRect);
  }

  Rect _clampToBounds(Rect r) {
    final maxX = math.max(0.0, widget.imageSize.width - r.width);
    final maxY = math.max(0.0, widget.imageSize.height - r.height);

    final left = r.left.clamp(0.0, maxX);
    final top = r.top.clamp(0.0, maxY);

    return Rect.fromLTWH(left, top, r.width, r.height);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onPanStart: (details) {
            _activeHandle = _hitTestHandle(details.localPosition, displayRect);
          },
          onPanUpdate: (details) {
            if (_activeHandle != CropHandle.none) {
              _resize(_activeHandle, details.delta);
              return;
            }

            final dx = details.delta.dx;
            final dy = details.delta.dy;

            setState(() {
              displayRect = displayRect.shift(Offset(dx, dy));
              displayRect = _clampToBounds(displayRect);

              cropRect = _fromDisplay(displayRect);
            });

            widget.onChanged(cropRect);
          },
          onPanEnd: (_) {
            _activeHandle = CropHandle.none;
          },
          child: CustomPaint(
            size: Size(constraints.maxWidth, constraints.maxHeight),
            painter: _CropPainter(displayRect),
          ),
        );
      },
    );
  }
}

class _CropPainter extends CustomPainter {
  final Rect rect;

  _CropPainter(this.rect);

  @override
  void paint(Canvas canvas, Size size) {
    final overlayPaint = Paint()
      ..color = Colors.black45;

    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // top
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, rect.top),
      overlayPaint,
    );

    // bottom
    canvas.drawRect(
      Rect.fromLTWH(
        0,
        rect.bottom,
        size.width,
        size.height - rect.bottom,
      ),
      overlayPaint,
    );

    // left
    canvas.drawRect(
      Rect.fromLTWH(
        0,
        rect.top,
        rect.left,
        rect.height,
      ),
      overlayPaint,
    );

    // right
    canvas.drawRect(
      Rect.fromLTWH(
        rect.right,
        rect.top,
        size.width - rect.right,
        rect.height,
      ),
      overlayPaint,
    );

    canvas.drawRect(rect, borderPaint);

    final handlePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(rect.topLeft, 8, handlePaint);
    canvas.drawCircle(rect.topRight, 8, handlePaint);
    canvas.drawCircle(rect.bottomLeft, 8, handlePaint);
    canvas.drawCircle(rect.bottomRight, 8, handlePaint);
  }

  @override
  bool shouldRepaint(covariant _CropPainter oldDelegate) {
    return oldDelegate.rect != rect;
  }
}
