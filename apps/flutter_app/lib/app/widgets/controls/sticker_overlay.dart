import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:inkstudio_image/inkstudio_image.dart';

enum StickerHandle {
  none,
  topLeft,
  topRight,
  bottomLeft,
  bottomRight,
  rotation,
}

class StickerOverlay extends StatefulWidget {
  final ContentOverlay overlay;
  final Size imageSize;
  final Widget child;
  final bool selected;

  final VoidCallback onSelected;
  final ValueChanged<ContentOverlay> onChanged;

  const StickerOverlay({
    super.key,
    required this.overlay,
    required this.imageSize,
    required this.child,
    required this.selected,
    required this.onSelected,
    required this.onChanged,
  });

  @override
  State<StickerOverlay> createState() => _StickerOverlayState();
}

class _StickerOverlayState extends State<StickerOverlay> {

  late Rect displayRect;

  StickerHandle _activeHandle = StickerHandle.none;

  double _rotationStart = 0;
  double _pointerAngleStart = 0;

  @override
  void initState() {
    super.initState();
    displayRect = _toDisplay(widget.overlay);
  }

  @override
  void didUpdateWidget(
    covariant StickerOverlay oldWidget,
  ) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.overlay != widget.overlay || oldWidget.imageSize != widget.imageSize) {
      displayRect = _toDisplay(widget.overlay);
    }
  }

  Rect _toDisplay(
    ContentOverlay overlay,
  ) {
    return Rect.fromLTWH(
      overlay.x * widget.imageSize.width,
      overlay.y * widget.imageSize.height,
      overlay.width * widget.imageSize.width,
      overlay.height * widget.imageSize.height
    );
  }

  ContentOverlay _fromDisplay(
    Rect rect,
  ) {
    return widget.overlay.copyWith(
      x: rect.left / widget.imageSize.width,
      y: rect.top / widget.imageSize.height,
      width: rect.width / widget.imageSize.width,
      height: rect.height / widget.imageSize.height
    );
  }

  StickerHandle _hitTestHandle(
    Offset position,
  ) {
    const hitSize = 48.0;

    // The handles are visually rotated with the sticker.
    // Convert the pointer position back into the sticker's
    // unrotated coordinate space before testing them.
    final centre = displayRect.center;

    final dx = position.dx - centre.dx;
    final dy = position.dy - centre.dy;

    final cosAngle = math.cos(-widget.overlay.rotation);
    final sinAngle = math.sin(-widget.overlay.rotation);

    final unrotatedPosition = Offset(
      centre.dx + dx * cosAngle - dy * sinAngle,
      centre.dy + dx * sinAngle + dy * cosAngle
    );

    Rect makeHandle(
      Offset centre,
    ) {
      return Rect.fromCenter(
        center: centre,
        width: hitSize,
        height: hitSize,
      );
    }

    if (makeHandle(displayRect.topLeft).contains(unrotatedPosition)) {
      return StickerHandle.topLeft;
    }

    if (makeHandle(displayRect.topRight).contains(unrotatedPosition)) {
      return StickerHandle.topRight;
    }

    if (makeHandle(displayRect.bottomLeft).contains(unrotatedPosition)) {
      return StickerHandle.bottomLeft;
    }

    if (makeHandle(displayRect.bottomRight).contains(unrotatedPosition)) {
      return StickerHandle.bottomRight;
    }

    if (makeHandle(Offset(displayRect.center.dx, displayRect.top - 32)).contains(unrotatedPosition)) {
      return StickerHandle.rotation;
    }

    return StickerHandle.none;
  }

  void _move(Offset delta) {
    final updated = _clampToBounds(displayRect.shift(delta));

    setState(() {
      displayRect = updated;
    });

    widget.onChanged(_fromDisplay(updated));
  }

  void _resize(
    StickerHandle handle,
    Offset pointerPosition,
  ) {
    const minSize = 48.0;

    final rect = displayRect;
    final angle = widget.overlay.rotation;

    // The sticker's current centre in image/display coordinates.
    final centre = rect.center;

    // Convert a point from image/display coordinates into
    // the sticker's local, unrotated coordinate system.
    Offset toLocal(Offset point) {
      final dx = point.dx - centre.dx;
      final dy = point.dy - centre.dy;

      final cosAngle = math.cos(-angle);
      final sinAngle = math.sin(-angle);

      return Offset(
        dx * cosAngle - dy * sinAngle,
        dx * sinAngle + dy * cosAngle
      );
    }

    // Convert a point from the sticker's local coordinate
    // system back into image/display coordinates.
    Offset toWorld(Offset point) {
      final cosAngle = math.cos(angle);
      final sinAngle = math.sin(angle);

      return Offset(
        centre.dx + point.dx * cosAngle - point.dy * sinAngle,
        centre.dy + point.dx * sinAngle + point.dy * cosAngle
      );
    }

    // The four corners in local coordinates.
    final localTopLeft = Offset(-rect.width / 2, -rect.height / 2);
    final localTopRight = Offset(rect.width / 2, -rect.height / 2);
    final localBottomLeft = Offset(-rect.width / 2, rect.height / 2);
    final localBottomRight = Offset(rect.width / 2, rect.height / 2);

    // The opposite corner is the fixed anchor.
    final localAnchor;

    switch (handle) {
      case StickerHandle.topLeft:
        localAnchor = localBottomRight;
        break;

      case StickerHandle.topRight:
        localAnchor = localBottomLeft;
        break;

      case StickerHandle.bottomLeft:
        localAnchor = localTopRight;
        break;

      case StickerHandle.bottomRight:
        localAnchor = localTopLeft;
        break;

      case StickerHandle.none:
      case StickerHandle.rotation:
        return;
    }

    // Convert the fixed anchor into world coordinates.
    final worldAnchor = toWorld(localAnchor);

    // Convert the current pointer position into
    // the sticker's local coordinate system.
    //
    // This must be relative to the CURRENT centre.
    final localPointer = toLocal(pointerPosition);

    // Calculate the new dimensions from the fixed anchor
    // to the dragged pointer.
    double width = (localPointer.dx - localAnchor.dx).abs();

    double height = (localPointer.dy - localAnchor.dy).abs();

    final aspect = rect.width / rect.height;

    // Preserve aspect ratio.
    if (width / height > aspect) {
      width = height * aspect;
    } else {
      height = width / aspect;
    }

    // Minimum size.
    if (width < minSize) {
      width = minSize;
      height = width / aspect;
    }

    if (height < minSize) {
      height = minSize;
      width = height * aspect;
    }

    // Determine which side of the anchor the
    // dragged corner belongs to.
    final isRight = handle == StickerHandle.topRight || handle == StickerHandle.bottomRight;
    final isBottom = handle == StickerHandle.bottomLeft || handle == StickerHandle.bottomRight;

    // Build the new local rectangle around the
    // fixed local anchor.
    final localLeft = isRight
      ? localAnchor.dx
      : localAnchor.dx - width;

    final localTop = isBottom
      ? localAnchor.dy
      : localAnchor.dy - height;

    final localNewRight = localLeft + width;
    final localNewBottom = localTop + height;

    final localNewCentre = Offset(
      (localLeft + localNewRight) / 2,
      (localTop + localNewBottom) / 2
    );

    // The local centre above is relative to the OLD centre.
    // Convert it to world coordinates.
    final newCentre = toWorld(localNewCentre);

    // Calculate the new axis-aligned storage rect.
    //
    // The stored rect remains axis-aligned because x/y/width/height
    // are the unrotated bounds used by the renderer.
    final updated = Rect.fromCenter(
      center: newCentre,
      width: width,
      height: height,
    );

    // Keep the unrotated storage rect inside the image.
    final clamped = _clampToBounds(updated);

    setState(() {
      displayRect = clamped;
    });

    widget.onChanged(_fromDisplay(clamped));
  }

  void _startRotation(Offset position) {
    final centre = displayRect.center;

    _pointerAngleStart = math.atan2(
      position.dy - centre.dy,
      position.dx - centre.dx
    );

    _rotationStart = widget.overlay.rotation;
  }

  void _rotate(Offset position) {
    final centre = displayRect.center;

    final currentAngle = math.atan2(
      position.dy - centre.dy,
      position.dx - centre.dx
    );

    var delta = currentAngle - _pointerAngleStart;

    // Keep the angle difference continuous
    // when crossing -pi / pi.
    if (delta > math.pi) {
      delta -= math.pi * 2;
    } else if (delta < -math.pi) {
      delta += math.pi * 2;
    }

    widget.onChanged(
      widget.overlay.copyWith(rotation: _rotationStart + delta)
    );
  }

  Rect _clampToBounds(Rect rect) {
    final maxX = math.max(0.0, widget.imageSize.width - rect.width);

    final maxY = math.max(0.0, widget.imageSize.height - rect.height);

    return Rect.fromLTWH(
      rect.left.clamp(0.0, maxX),
      rect.top.clamp(0.0, maxY),
      rect.width,
      rect.height,
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    final data = widget.overlay.data;

    if (data is! ShapeOverlayData) return const SizedBox.shrink();

    const hitPadding = 48.0;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          left: displayRect.left - hitPadding,
          top: displayRect.top - hitPadding,
          width: displayRect.width + hitPadding * 2,
          height: displayRect.height + hitPadding * 2,
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTapDown: (_) {
              widget.onSelected();
            },
            onPanStart: (details) {
              final pointerPosition = details.localPosition + Offset(
                displayRect.left - hitPadding, displayRect.top - hitPadding
              );
              
              _activeHandle = _hitTestHandle(pointerPosition);

              if (_activeHandle == StickerHandle.rotation) {
                _startRotation(pointerPosition);
                return;
              }

              if (_activeHandle != StickerHandle.none) {
                widget.onSelected();
                return;
              }

              if (displayRect.contains(pointerPosition)) {
                widget.onSelected();
              }
            },
            onPanUpdate: (details) {
              final pointerPosition = details.localPosition + Offset(displayRect.left - hitPadding, displayRect.top - hitPadding);
              if (_activeHandle == StickerHandle.rotation) {
                _rotate(pointerPosition);
                return;
              }
              
              if (_activeHandle != StickerHandle.none) {
                _resize(_activeHandle, pointerPosition);
                return;
              }

              _move(details.delta);
            },
            onPanEnd: (_) {
              _activeHandle = StickerHandle.none;
            },
            // child: Transform.rotate(
            //   angle: widget.overlay.rotation,
            //   child: widget.child
            // )
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  left: hitPadding,
                  top: hitPadding,
                  width: displayRect.width,
                  height: displayRect.height,
                  child: ShapeHitTest(
                    shape: data.shape,
                    child: Transform.rotate(
                      angle: widget.overlay.rotation,
                      child: widget.child
                    )
                  )
                )
              ]
            )
          )
        ),

        if (widget.selected)
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                size: widget.imageSize,
                painter: _StickerSelectionPainter(
                  rect: displayRect,
                  rotation: widget.overlay.rotation
                )
              )
            )
          )
      ]
    );
  }
}

class _StickerSelectionPainter extends CustomPainter {
  final Rect rect;
  final double rotation;

  const _StickerSelectionPainter({
    required this.rect,
    required this.rotation,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final borderPaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final handlePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final handleBorder = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Rotate the entire selection UI around
    // the centre of the sticker.
    canvas.save();

    canvas.translate(
      rect.center.dx,
      rect.center.dy,
    );

    canvas.rotate(rotation);

    canvas.translate(
      -rect.center.dx,
      -rect.center.dy,
    );

    // Selection box.
    canvas.drawRect(
      rect,
      borderPaint,
    );

    // Corner handles.
    for (final point in [
      rect.topLeft,
      rect.topRight,
      rect.bottomLeft,
      rect.bottomRight,
    ]) {
      canvas.drawCircle(
        point,
        8,
        handlePaint,
      );

      canvas.drawCircle(
        point,
        8,
        handleBorder,
      );
    }

    // Rotation handle.
    final rotationPoint = Offset(
      rect.center.dx,
      rect.top - 32,
    );

    canvas.drawLine(
      Offset(
        rect.center.dx,
        rect.top,
      ),
      rotationPoint,
      handleBorder,
    );

    canvas.drawCircle(
      rotationPoint,
      8,
      handlePaint,
    );

    canvas.drawCircle(
      rotationPoint,
      8,
      handleBorder,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(
    covariant _StickerSelectionPainter oldDelegate,
  ) {
    return oldDelegate.rect != rect ||
        oldDelegate.rotation != rotation;
  }
}