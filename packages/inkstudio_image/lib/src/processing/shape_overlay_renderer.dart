import 'dart:math' as math;

import 'package:inkstudio_core/inkstudio_core.dart';
import 'package:inkstudio_image/inkstudio_image.dart';

class ShapeOverlayRenderer {
  static void apply(
    PaletteFramebuffer framebuffer,
    ContentOverlay overlay
  ) {
    final data = overlay.data;

    if (data is! ShapeOverlayData) return;

    final colour = overlay.colour.index;

    final x =
        (overlay.x * framebuffer.width).round();

    final y =
        (overlay.y * framebuffer.height).round();

    final width =
        (overlay.width * framebuffer.width).round();

    final height =
        (overlay.height * framebuffer.height).round();

    switch (data.shape) {
      case ShapeType.square:
        _drawSquare(
          framebuffer,
          x,
          y,
          width,
          height,
          colour,
          data.style,
          overlay.rotation,
        );

      case ShapeType.star:
        _drawStar(
          framebuffer,
          x,
          y,
          width,
          height,
          colour,
          data.style,
          overlay.rotation,
        );

      default:
        return;
    }
  }

  static void _drawSquare(
    PaletteFramebuffer framebuffer,
    int x,
    int y,
    int width,
    int height,
    PaletteIndex colour,
    OverlayStyle style,
    double rotation,
  ) {
    final centre = _Point(
      x: x + width / 2,
      y: y + height / 2,
    );

    final points = <_Point>[
      _Point(x: x.toDouble(), y: y.toDouble()),
      _Point(
        x: (x + width).toDouble(),
        y: y.toDouble(),
      ),
      _Point(
        x: (x + width).toDouble(),
        y: (y + height).toDouble(),
      ),
      _Point(
        x: x.toDouble(),
        y: (y + height).toDouble(),
      ),
    ];

    final transformed = points
        .map(
          (point) => _rotatePoint(
            point,
            centre,
            rotation,
          ),
        )
        .toList();

    if (style == OverlayStyle.filled) {
      _fillPolygon(
        framebuffer,
        transformed,
        colour,
      );
    } else {
      _drawPolygonOutline(
        framebuffer,
        transformed,
        colour,
      );
    }
  }

  static void _drawStar(
    PaletteFramebuffer framebuffer,
    int x,
    int y,
    int width,
    int height,
    PaletteIndex colour,
    OverlayStyle style,
    double rotation,
  ) {
    final normalisedPoints =
        _createStartPoints(
      sides: 5,
      innerRadius: 0.4,
    );

    final centre = _Point(
      x: x + width / 2,
      y: y + height / 2,
    );

    // First convert the normalised star into
    // its actual framebuffer-space geometry.
    final points = normalisedPoints.map(
      (point) {
        return _Point(
          x: x + point.x * width,
          y: y + point.y * height,
        );
      },
    ).toList();

    // Then rotate the actual pixel geometry
    // around the actual centre.
    final transformed = points
        .map(
          (point) => _rotatePoint(
            point,
            centre,
            rotation,
          ),
        )
        .toList();

    if (style == OverlayStyle.filled) {
      _fillPolygon(
        framebuffer,
        transformed,
        colour,
      );
    } else {
      _drawPolygonOutline(
        framebuffer,
        transformed,
        colour,
      );
    }
  }

  static List<_Point> _createStartPoints({
    required int sides,
    required double innerRadius
  }) {
    final points = <_Point>[];

    final outerRadius = 0.5;

    // Start at the top
    final startAngle = -math.pi / 2;
    for (int i=0; i<sides*2; i++) {
      final isOuter = i.isEven;

      final radius = isOuter
        ? outerRadius
        : outerRadius * innerRadius;
      
      final angle = startAngle + (i * math.pi / sides);
      final x = 0.5 + math.cos(angle) * radius;
      final y = 0.5 + math.sin(angle) * radius;

      points.add(_Point(x: x, y: y));
    }

    return points;
  }

  static void _fillPolygon(
    PaletteFramebuffer framebuffer,
    List<_Point> points,
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
    List<_Point> points,
    PaletteIndex colour
  ) {
    for (int i=0; i<points.length; i++) {
      final start = points[i];
      final end = points[(i + 1) % points.length];

      _drawLine(framebuffer, start, end, colour);
    }
  }

  static bool _isPointInsidePolygon(
    double x, double y, List<_Point> points
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

  static void _drawLine(
    PaletteFramebuffer framebuffer,
    _Point start, _Point end,
    PaletteIndex colour
  ) {
    int x0 = start.x.round();
    int y0 = start.y.round();

    final x1 = end.x.round();
    final y1 = end.y.round();

    final dx = (x1 - x0).abs();
    final dy = (y1 - y0).abs();

    final sx = x0 < x1 ? 1 : -1;
    final sy = y0 < y1 ? 1 : -1;

    int err = dx - dy;

    while (true) {
      if (x0 >= 0 && y0 >= 0 &&
          x0 < framebuffer.width && y0 < framebuffer.height) {
        framebuffer.setPixel(x0, y0, colour);
      }

      if (x0 == x1 && y0 == y1) break;

      final e2 = 2 * err;

      if (e2 > -dy) {
        err -= dy;
        x0 += sx;
      }

      if (e2 < dx) {
        err += dx;
        y0 += sy;
      }
    }
  }

  static _Point _rotatePoint(
    _Point point,
    _Point centre,
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

    return _Point(
      x: centre.x +
          dx * cosAngle -
          dy * sinAngle,
      y: centre.y +
          dx * sinAngle +
          dy * cosAngle,
    );
  }
}

class _Point {
  final double x;
  final double y;

  const _Point({
    required this.x,
    required this.y
  });
}