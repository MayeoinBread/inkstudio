import 'dart:math' as math;
import 'dart:ui';

import 'package:inkstudio_image/inkstudio_image.dart';

class ShapePoint {
  final double x;
  final double y;
  const ShapePoint({required this.x, required this.y});
}

sealed class ShapeCommand {
  const ShapeCommand();
}

class MoveTo extends ShapeCommand {
  final double x;
  final double y;
  const MoveTo(this.x, this.y);
}

class LineTo extends ShapeCommand {
  final double x;
  final double y;
  const LineTo(this.x, this.y);
}

class CubicTo extends ShapeCommand {
  final double x1;
  final double y1;

  final double x2;
  final double y2;

  final double x3;
  final double y3;

  const CubicTo(
    this.x1, this.y1,
    this.x2, this.y2,
    this.x3, this.y3,
  );
}

class Close extends ShapeCommand {
  const Close();
}

class ShapePathBuilder {
  static List<ShapeCommand> commands(ShapeType shape) {
    switch (shape) {
      case ShapeType.square:
        return _createSquareCommands();
      case ShapeType.heart:
        return _createHeartCommands();
      case ShapeType.star:
      default:
        return _createStarCommands(sides: 5, innerRadius: 0.4);
    }
  }

  static Path create(
    ShapeType shape
  ) {
    final path = Path();

    for (final command in commands(shape)) {
      switch(command) {
        case MoveTo():
          path.moveTo(command.x, command.y);
        case LineTo():
          path.lineTo(command.x, command.y);
        case CubicTo():
          path.cubicTo(
            command.x1, command.y1,
            command.x2, command.y2,
            command.x3, command.y3
          );
        case Close():
          path.close();
      }
    }

    return path;
  }

  static List<ShapePoint> flattenCommands(
    List<ShapeCommand> commands, {
      int curveSteps = 24
    }
  ) {
    final points = <ShapePoint>[];

    ShapePoint current = const ShapePoint(x: 0, y:0);

    for (final command in commands) {
      switch (command) {
        case MoveTo():
          current = ShapePoint(x: command.x, y: command.y);
          points.add(current);
        case LineTo():
          current = ShapePoint(x: command.x, y: command.y);
          points.add(current);
        case CubicTo():
          for (int i = 1; i <= curveSteps; i++) {
            final t = i / curveSteps;

            final mt = 1 - t;

            final x =
                mt * mt * mt * current.x +
                3 * mt * mt * t * command.x1 +
                3 * mt * t * t * command.x2 +
                t * t * t * command.x3;

            final y =
                mt * mt * mt * current.y +
                3 * mt * mt * t * command.y1 +
                3 * mt * t * t * command.y2 +
                t * t * t * command.y3;

            points.add(ShapePoint(x: x, y: y));
          }

          current = ShapePoint(x: command.x3, y: command.y3);
        case Close():
          break;
      }
    }

    return points;
  }

  static List<ShapeCommand> _createSquareCommands() {
    return const [
      MoveTo(0.0, 0.0),
      LineTo(1.0, 0.0),
      LineTo(1.0, 1.0),
      LineTo(0.0, 1.0),
      Close(),
    ];
  }

  static List<ShapeCommand> _createStarCommands({
    required int sides,
    required double innerRadius
  }) {
    final commands = <ShapeCommand>[];

    const outerRadius = 0.5;
    const startAngle = -math.pi / 2;

    for (int i = 0; i < sides * 2; i++) {
      final radius = i.isEven
          ? outerRadius
          : outerRadius * innerRadius;

      final angle = startAngle + i * math.pi / sides;

      final x = 0.5 + math.cos(angle) * radius;

      final y = 0.5 + math.sin(angle) * radius;

      if (i == 0) {
        commands.add(MoveTo(x, y));
      } else {
        commands.add(LineTo(x, y));
      }
    }

    commands.add(const Close());

    return commands;
  }

  static List<ShapeCommand> _createHeartCommands() {
    return const [
      // Bottom point
      MoveTo(0.5, 0.95),

      // Left lower curve -> left lobe outer edge
      CubicTo(
        0.42, 0.82,
        0.08, 0.62,
        0.08, 0.35,
      ),

      // Left lobe up and into centre cleft
      CubicTo(
        0.08, 0.12,
        0.32, -0.03,
        0.5, 0.25,
      ),

      // Centre cleft -> right lobe
      CubicTo(
        0.68, -0.03,
        0.92, 0.12,
        0.92, 0.35,
      ),

      // Right lobe -> bottom point
      CubicTo(
        0.92, 0.62,
        0.58, 0.82,
        0.5, 0.95,
      ),

      Close(),
    ];
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