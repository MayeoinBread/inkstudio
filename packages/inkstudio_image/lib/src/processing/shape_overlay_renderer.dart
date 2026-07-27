import 'dart:math' as math;

import 'package:inkstudio_core/inkstudio_core.dart';
import 'package:inkstudio_image/inkstudio_image.dart';
import 'package:inkstudio_image/src/processing/shape_path_builder.dart';

class ShapeOverlayRenderer {
  static void apply(
    PaletteFramebuffer framebuffer,
    ContentOverlay overlay
  ) {
    final data = overlay.data;

    if (data is! ShapeOverlayData) return;

    final colour = overlay.colour.index;

    final x = overlay.x * framebuffer.width;
    final y = overlay.y * framebuffer.height;

    final width = overlay.width * framebuffer.width;
    final height = overlay.height * framebuffer.height;

    // final path = ShapePathBuilder.create(data.shape);

    // final points = _pathToPoints(path, width, height);
    final points = ShapePathBuilder.flattenCommands(
      ShapePathBuilder.commands(data.shape)
    );

    final centre = ShapePoint(x: x + width / 2, y: y + height / 2);

    // final transformed = points.map(
    //   (point) => _rotatePoint(point, centre, overlay.rotation)
    // ).toList();
    final transformed = points.map((point) {
      return _rotatePoint(
        ShapePoint(x: x + point.x * width, y: y + point.y * height), centre, overlay.rotation);
    }).toList();

    if (data.style == OverlayStyle.filled) {
      _fillPolygon(framebuffer, transformed, colour);
    } else {
      _drawPolygonOutline(framebuffer, transformed, colour, data.strokeWidth);
    }
  }

  static void _fillPolygon(
    PaletteFramebuffer framebuffer,
    List<ShapePoint> points,
    PaletteIndex colour
  ) {
    if (points.length < 3) return;

    final minX = points.map((p) => p.x).reduce(math.min).floor();
    final maxX = points.map((p) => p.x).reduce(math.max).ceil();
    final minY = points.map((p) => p.y).reduce(math.min).floor();
    final maxY = points.map((p) => p.y).reduce(math.max).ceil();

    for (int y=minY; y<=maxY; y++) {
      for (int x=minX; x<maxX; x++) {
        if (x < 0 || y < 0 || x >= framebuffer.width || y >= framebuffer.height) continue;

        if (_isPointInsidePolygon(x + 0.5, y + 0.5, points)) {
          framebuffer.setPixel(x, y, colour);
        }
      }
    }
  }

  static void _drawPolygonOutline(
    PaletteFramebuffer framebuffer,
    List<ShapePoint> points,
    PaletteIndex colour,
    double strokeWidth
  ) {
    final radius = math.max(0.5, strokeWidth / 2);

    for (int i=0; i<points.length; i++) {
      final start = points[i];
      final end = points[(i + 1) % points.length];

      // _drawLine(framebuffer, start, end, colour);
      _drawThickLine(framebuffer, start, end, colour, radius);
    }
  }

  static bool _isPointInsidePolygon(
    double x, double y, List<ShapePoint> points
  ) {
    bool inside = false;

    int j = points.length - 1;

    for (int i=0; i<points.length; i++) {
      final xi = points[i].x;
      final yi = points[i].y;

      final xj = points[j].x;
      final yj = points[j].y;

      final intersects = ((yi > y) != (yj > y)) && (x < (xj - xi) * (y - yi) / (yj - yi) + xi);

      if (intersects) inside = !inside;

      j = i;
    }

    return inside;
  }

  static void _drawThickLine(
    PaletteFramebuffer framebuffer,
    ShapePoint start,
    ShapePoint end,
    PaletteIndex colour,
    double radius,
  ) {
    final minX =
        math.min(start.x, end.x) - radius;

    final maxX =
        math.max(start.x, end.x) + radius;

    final minY =
        math.min(start.y, end.y) - radius;

    final maxY =
        math.max(start.y, end.y) + radius;

    final startX =
        minX.floor();

    final endX =
        maxX.ceil();

    final startY =
        minY.floor();

    final endY =
        maxY.ceil();

    final dx =
        end.x - start.x;

    final dy =
        end.y - start.y;

    final lengthSquared =
        dx * dx + dy * dy;

    for (int y = startY; y <= endY; y++) {
      for (int x = startX; x <= endX; x++) {
        if (x < 0 ||
            y < 0 ||
            x >= framebuffer.width ||
            y >= framebuffer.height) {
          continue;
        }

        final px = x + 0.5;
        final py = y + 0.5;

        double t;

        if (lengthSquared == 0) {
          t = 0;
        } else {
          t = (
            (px - start.x) * dx +
            (py - start.y) * dy
          ) / lengthSquared;

          t = t.clamp(0.0, 1.0);
        }

        final closestX =
            start.x + t * dx;

        final closestY =
            start.y + t * dy;

        final distance =
            math.sqrt(
              math.pow(
                px - closestX,
                2,
              ) +
              math.pow(
                py - closestY,
                2,
              ),
            );

        if (distance <= radius) {
          framebuffer.setPixel(
            x,
            y,
            colour,
          );
        }
      }
    }
  }

  static ShapePoint _rotatePoint(
    ShapePoint point,
    ShapePoint centre,
    double rotation,
  ) {
    final dx =
        point.x - centre.x;

    final dy =
        point.y - centre.y;

    final cosAngle =
        math.cos(rotation);

    final sinAngle =
        math.sin(rotation);

    return ShapePoint(
      x: centre.x +
          dx * cosAngle -
          dy * sinAngle,
      y: centre.y +
          dx * sinAngle +
          dy * cosAngle,
    );
  }
}
