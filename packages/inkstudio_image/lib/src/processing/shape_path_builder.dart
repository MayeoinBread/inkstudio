import 'dart:math' as math;
import 'dart:ui';

import 'package:inkstudio_image/inkstudio_image.dart';

class ShapePathBuilder {
  static Path create(
    ShapeType shape
  ) {
    switch (shape) {
      case ShapeType.square:
        return _createSquare();
      
      case ShapeType.star:
        return _createStar();
      
      case ShapeType.heart:
        return _createHeart();
      
      case ShapeType.circle:
        return _createCircle();
      
      case ShapeType.triangle:
        return _createTriangle();
      
      default:
        return _createSquare();
    }
  }

  static Path _createSquare() {
    return Path()
      ..addRect(
        Rect.fromLTWH(0, 0, 1, 1)
      );
  }

  static Path _createStar() {
    final path = Path();

    const sides = 5;
    const innerRadius = 0.4;
    const outerRadius = 0.5;

    final startAngle = -math.pi / 2;

    for (int i = 0; i < sides * 2; i++) {
      final radius = i.isEven
          ? outerRadius
          : outerRadius * innerRadius;

      final angle = startAngle + i * math.pi / sides;

      final x = 0.5 + math.cos(angle) * radius;

      final y = 0.5 + math.sin(angle) * radius;

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    path.close();

    return path;
  }

  static Path _createHeart() {
    final path = Path();

    path.moveTo(0.5, 0.9);

    path.cubicTo(
      0.35,
      0.75,
      0.05,
      0.55,
      0.05,
      0.3,
    );

    path.cubicTo(
      0.05,
      0.1,
      0.25,
      0.0,
      0.4,
      0.0,
    );

    path.cubicTo(
      0.5,
      0.0,
      0.5,
      0.1,
      0.5,
      0.2,
    );

    path.cubicTo(
      0.5,
      0.1,
      0.5,
      0.0,
      0.6,
      0.0,
    );

    path.cubicTo(
      0.75,
      0.0,
      0.95,
      0.1,
      0.95,
      0.3,
    );

    path.cubicTo(
      0.95,
      0.55,
      0.65,
      0.75,
      0.5,
      0.9,
    );

    path.close();

    return path;
  }

  static Path _createCircle() {
    return Path()
      ..addOval(const Rect.fromLTWH(0, 0, 1, 1));
  }

  static Path _createTriangle() {
    final path = Path();

    path.moveTo(0.5, 0);
    path.lineTo(1, 1);
    path.lineTo(0, 1);
    path.close();

    return path;
  }
}