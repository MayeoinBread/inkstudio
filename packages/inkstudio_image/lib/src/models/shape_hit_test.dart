import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:inkstudio_image/src/models/overlay_enums.dart';
import 'package:inkstudio_image/src/processing/shape_path_builder.dart';
import 'package:vector_math/vector_math_64.dart';

class ShapeHitTest extends SingleChildRenderObjectWidget {
  final ShapeType shape;

  const ShapeHitTest({
    super.key,
    required this.shape,
    required super.child
  });

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _ShapeHitTestRenderBox(
      shape: shape
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    covariant _ShapeHitTestRenderBox renderObject
  ) {
    renderObject.shape = shape;
  }
}

class _ShapeHitTestRenderBox extends RenderProxyBox {
  ShapeType shape;

  _ShapeHitTestRenderBox({
    required this.shape
  });

  @override
  bool hitTest(
    BoxHitTestResult result,
    {required Offset position}
  ) {
    if (!size.contains(position)) return false;

    final path = ShapePathBuilder.create(shape);

    final transform = Matrix4.identity()
      ..scaleByVector3(
        Vector3(
          size.width,
          size.height,
          1.0,
        ),
      );

    final scaledPath =
        path.transform(
      transform.storage,
    );

    if (!scaledPath.contains(position)) {
      return false;
    }

    return super.hitTest(result, position: position);
  }
}