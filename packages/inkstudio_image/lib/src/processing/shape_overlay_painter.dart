import 'package:flutter/material.dart';
import 'package:inkstudio_core/inkstudio_core.dart';
import 'package:inkstudio_image/inkstudio_image.dart';
import 'package:inkstudio_image/src/processing/shape_path_builder.dart';
import 'package:vector_math/vector_math_64.dart' hide Colors;

class ShapeOverlayPainter extends CustomPainter {
  final ShapeOverlayData data;
  final PaletteIndex colour;
  final bool selected;

  const ShapeOverlayPainter({
    required this.data,
    required this.colour,
    required this.selected
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = _toFlutterColour(colour)
      ..style = data.style == OverlayStyle.filled
        ? PaintingStyle.fill
        : PaintingStyle.stroke
      ..strokeWidth = data.style == OverlayStyle.outline
        ? data.strokeWidth : 0
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;

    final path = ShapePathBuilder.create(data.shape);

    final transform = Matrix4.identity()
      ..scaleByVector3(Vector3(size.width, size.height, 1));

    canvas.drawPath(path.transform(transform.storage), paint);

    if (selected) {
      final selectionPaint = Paint()
        ..color = Colors.blue
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;
      
      canvas.drawRect(Offset.zero & size, selectionPaint);
    }
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
    return oldDelegate.data.shape != data.shape ||
        oldDelegate.data.style != data.style ||
        oldDelegate.data.strokeWidth != data.strokeWidth ||
        oldDelegate.colour != colour ||
        oldDelegate.selected != selected;
  }
}