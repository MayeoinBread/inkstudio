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

  // CropHandle _hitTestHandle(Offset pos, Rect paintRect) {
  //   if ((pos - paintRect.topLeft).distance <= _handleRadius) {
  //     return CropHandle.topLeft;
  //   }

  //   if ((pos - paintRect.topRight).distance <= _handleRadius) {
  //     return CropHandle.topRight;
  //   }

  //   if ((pos - paintRect.bottomLeft).distance <= _handleRadius) {
  //     return CropHandle.bottomLeft;
  //   }

  //   if ((pos - paintRect.bottomRight).distance <= _handleRadius) {
  //     return CropHandle.bottomRight;
  //   }

  //   return CropHandle.none;
  // }
  CropHandle _hitTestHandle(Offset pos, Rect rect) {
    final hit = _handleRadius * 2;

    final topLeft = Rect.fromCenter(center: rect.topLeft, width: hit, height: hit);
    if (topLeft.contains(pos)) return CropHandle.topLeft;

    final topRight = Rect.fromCenter(center: rect.topRight, width: hit, height: hit);
    if (topRight.contains(pos)) return CropHandle.topRight;

    final bottomLeft = Rect.fromCenter(center: rect.bottomLeft, width: hit, height: hit);
    if (bottomLeft.contains(pos)) return CropHandle.bottomLeft;

    final bottomRight = Rect.fromCenter(center: rect.bottomRight, width: hit, height: hit);
    if (bottomRight.contains(pos)) return CropHandle.bottomRight;

    return CropHandle.none;
  }

  void _resize(CropHandle handle, Offset delta) {
    const minSize = 48.0;

    Rect r = displayRect;

    double dx = delta.dx;
    double dy = delta.dy;

    final aspect = widget.aspectRatio;

    double newLeft = r.left;
    double newTop = r.top;
    double newWidth = r.width;
    double newHeight = r.height;

    switch (handle) {
      case CropHandle.bottomRight:
        newWidth += dx;
        newHeight = newWidth / aspect;
        break;

      case CropHandle.bottomLeft:
        newWidth -= dx;
        newHeight = newWidth / aspect;
        newLeft = r.right - newWidth;
        break;

      case CropHandle.topRight:
        newWidth += dx;
        newHeight = newWidth / aspect;
        newTop = r.bottom - newHeight;
        break;

      case CropHandle.topLeft:
        newWidth -= dx;
        newHeight = newWidth / aspect;
        newLeft = r.right - newWidth;
        newTop = r.bottom - newHeight;
        break;

      case CropHandle.none:
        return;
    }

    // enforce minimum size
    if (newWidth < minSize) {
      newWidth = minSize;
      newHeight = newWidth / aspect;
    }

    r = Rect.fromLTWH(newLeft, newTop, newWidth, newHeight);

    setState(() {
      displayRect = _clampToBounds(r);
      cropRect = _fromDisplay(displayRect);
    });

    widget.onChanged(cropRect);
  }

  Rect _clampToBounds(Rect r) {
    final maxX = widget.imageSize.width - r.width;
    final maxY = widget.imageSize.height - r.height;

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
