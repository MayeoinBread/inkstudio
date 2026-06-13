import 'package:flutter/material.dart';

class CropOverlay extends StatefulWidget {
  final Rect? initialRect;
  final double aspectRatio;
  final Size imageSize;
  final ValueChanged<Rect> onChanged;

  const CropOverlay({
    super.key,
    required this.aspectRatio,
    required this.imageSize,
    required this.onChanged,
    this.initialRect
  });

  @override
  State<CropOverlay> createState() => _CropOverlayState();
}

class _CropOverlayState extends State<CropOverlay> {
  late Rect cropRect;

  @override
  void initState() {
    super.initState();

    cropRect = widget.initialRect ?? _defaultCenterCrop(widget.imageSize, widget.aspectRatio);
  }

  Rect _defaultCenterCrop(Size size, double aspect) {
    final imageAspect = size.width / size.height;

    double w, h;

    if (imageAspect > aspect) {
      h = size.height;
      w = h * aspect;
    } else {
      w = size.width;
      h = w / aspect;
    }

    final left = (size.width - w) / 2;
    final top = (size.height - h) / 2;

    return Rect.fromLTWH(left, top, w, h);
  }

  Rect _clampToBounds(Rect r) {
    double left = r.left;
    double top = r.top;

    if (left < 0) left = 0;
    if (top < 0) top = 0;

    if (left + r.width > widget.imageSize.width) {
      left = widget.imageSize.width - r.width;
    }

    if (top + r.height > widget.imageSize.height) {
      top = widget.imageSize.height - r.height;
    }

    return Rect.fromLTWH(left, top, r.width, r.height);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final scaleX = constraints.maxWidth / widget.imageSize.width;
        final scaleY = constraints.maxHeight / widget.imageSize.height;

        final paintRect = Rect.fromLTWH(
          cropRect.left * scaleX,
          cropRect.top * scaleY,
          cropRect.width * scaleX,
          cropRect.height * scaleY,
        );

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onPanUpdate: (details) {
            final dx = details.delta.dx / scaleX;
            final dy = details.delta.dy / scaleY;

            setState(() {
              cropRect = _clampToBounds(cropRect.shift(Offset(dx, dy)));
            });

            widget.onChanged(cropRect);
          },
          child: CustomPaint(
            size: Size(constraints.maxWidth, constraints.maxHeight),
            painter: _CropPainter(paintRect),
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
      ..color = Colors.black.withOpacity(0.5);

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
  }

  @override
  bool shouldRepaint(covariant _CropPainter oldDelegate) {
    return oldDelegate.rect != rect;
  }
}
