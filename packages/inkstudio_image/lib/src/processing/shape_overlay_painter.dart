import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:inkstudio_core/inkstudio_core.dart';
import 'package:inkstudio_image/src/models/overlay_enums.dart';

class ShapeOverlayPainter extends CustomPainter {
  final ShapeType shape;
  final OverlayStyle style;
  final PaletteIndex colour;
  final bool selected;

  const ShapeOverlayPainter({
    required this.shape,
    required this.style,
    required this.colour,
    required this.selected
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = _toFlutterColour(colour)
      ..style = style == OverlayStyle.filled
        ? PaintingStyle.fill
        : PaintingStyle.stroke
      ..strokeWidth = selected ? 2.0 : 1.5
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;

    final path = _createPath(size);

    canvas.drawPath(path, paint);

    if (selected) {
      final selectionPaint = Paint()
        ..color = Colors.blue
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;
      
      canvas.drawRect(Offset.zero & size, selectionPaint);
    }
  }

  Path _createPath(Size size) {
    switch (shape) {
      case ShapeType.star:
        return _createStarPath(size);

      case ShapeType.heart:
        return _createHeartPath(size);

      case ShapeType.circle:
        return _createCirclePath(size);

      case ShapeType.square:
        return _createSquarePath(size);

      case ShapeType.triangle:
        return _createTrianglePath(size);

      default:
        return _createSquarePath(size);
    }
  }

  Path _createStarPath(Size size) {
    final path = Path();

    final centre = Offset(
      size.width / 2,
      size.height / 2,
    );

    final outerRadius = math.min(
      size.width,
      size.height,
    ) / 2;

    final innerRadius = outerRadius * 0.4;

    const points = 5;

    for (int i = 0; i < points * 2; i++) {
      final radius = i.isEven
          ? outerRadius
          : innerRadius;

      final angle =
          -math.pi / 2 +
          (i * math.pi / points);

      final point = Offset(
        centre.dx + math.cos(angle) * radius,
        centre.dy + math.sin(angle) * radius,
      );

      if (i == 0) {
        path.moveTo(
          point.dx,
          point.dy,
        );
      } else {
        path.lineTo(
          point.dx,
          point.dy,
        );
      }
    }

    path.close();

    return path;
  }

  Path _createHeartPath(Size size) {
    final path = Path();

    final width = size.width;
    final height = size.height;

    path.moveTo(
      width / 2,
      height * 0.9,
    );

    path.cubicTo(
      width * 0.1,
      height * 0.65,
      width * 0.05,
      height * 0.25,
      width * 0.25,
      height * 0.12,
    );

    path.cubicTo(
      width * 0.38,
      height * 0.02,
      width * 0.48,
      height * 0.12,
      width / 2,
      height * 0.25,
    );

    path.cubicTo(
      width * 0.52,
      height * 0.12,
      width * 0.62,
      height * 0.02,
      width * 0.75,
      height * 0.12,
    );

    path.cubicTo(
      width * 0.95,
      height * 0.25,
      width * 0.9,
      height * 0.65,
      width / 2,
      height * 0.9,
    );

    path.close();

    return path;
  }

  Path _createCirclePath(Size size) {
    final path = Path();

    final radius = math.min(
      size.width,
      size.height,
    ) / 2;

    path.addOval(
      Rect.fromCircle(
        center: Offset(
          size.width / 2,
          size.height / 2,
        ),
        radius: radius,
      ),
    );

    return path;
  }

  Path _createSquarePath(Size size) {
    return Path()
      ..addRect(
        Rect.fromLTWH(
          0,
          0,
          size.width,
          size.height,
        ),
      );
  }

  Path _createTrianglePath(Size size) {
    final path = Path();

    path.moveTo(
      size.width / 2,
      0,
    );

    path.lineTo(
      size.width,
      size.height,
    );

    path.lineTo(
      0,
      size.height,
    );

    path.close();

    return path;
  }

  Color _toFlutterColour(PaletteIndex colour) {
    switch (colour) {
      case PaletteIndex.black:
        return Colors.black;

      case PaletteIndex.white:
        return Colors.white;

      case PaletteIndex.yellow:
        return Colors.yellow;

      case PaletteIndex.red:
        return Colors.red;
    }
  }

  @override
  bool shouldRepaint(
    covariant ShapeOverlayPainter oldDelegate,
  ) {
    return oldDelegate.shape != shape ||
        oldDelegate.style != style ||
        oldDelegate.colour != colour ||
        oldDelegate.selected != selected;
  }
}