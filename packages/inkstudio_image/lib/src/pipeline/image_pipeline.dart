import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:inkstudio_core/inkstudio_core.dart';
import 'package:inkstudio_image/inkstudio_image.dart';
import 'package:inkstudio_image/src/dithering/dither_register.dart';
import 'package:inkstudio_image/src/pipeline/framebuffer_preview_renderer.dart';
import 'package:inkstudio_image/src/processing/image_adjustment_processor.dart';
import 'package:inkstudio_image/src/processing/image_filter_processing.dart';

class ImagePipeline {
  final int targetWidth;
  final int targetHeight;

  const ImagePipeline({
    this.targetWidth = DeviceConstants.imageWidth,
    this.targetHeight = DeviceConstants.imageHeight
  });

  PipelineResult process(
    img.Image workingImage, {
    required ImageFilter filter,
    required bool simulateDevice,
    required ImageAdjustments adjustments,
    required PaletteBias paletteBias,
    DitherMode dither = DitherMode.floydSteinberg,
  }) {
    final resized = workingImage;

    final filtered = ImageFilterProcessor.apply(
      resized, filter, adjustments
    );

    final adjusted = ImageAdjustmentProcessor.apply(filtered, adjustments);

    final sharpened = ImageAdjustmentProcessor.applySharpen(adjusted, adjustments.sharpen);

    final framebuffer = DitherRegistry.create(dither).apply(sharpened, paletteBias);

    final preview = FramebufferPreviewRenderer.render(
      framebuffer, simulateDevice: simulateDevice
    );

    final previewBytes = Uint8List.fromList(
      img.encodePng(preview)
    );

    return PipelineResult(
      framebuffer: framebuffer,
      previewBytes: previewBytes
    );
  }

  // TODO change this to use metadata
  // Need to move metadata out of lib/src, to one of the other packages
  img.Image prepareBaseImage(img.Image src, Rect? cropRect, int rotation) {
    if (rotation != 0) {
      src = img.copyRotate(src, angle: rotation);
    }

    if (cropRect != null) {
      // Catch if crop bounds are outside the 0..1 ratio we expect
      if (cropRect.right > 1 || cropRect.bottom > 1) {
        cropRect = Rect.fromLTWH(cropRect.left, cropRect.top, 1 - cropRect.left, 1 - cropRect.top);
      }
    }

    Rect crop = cropRect ?? defaultCropRect(src.width, src.height);

    final x = (crop.left * src.width).round();
    final y = (crop.top * src.height).round();
    final w = (crop.width * src.width).round();
    final h = (crop.height * src.height).round();

    src = img.copyCrop(src, x: x, y: y, width: w, height: h);

    return img.copyResize(src, width: targetWidth, height: targetHeight);
  }

  Rect defaultCrop(Size imageSize) {
    final targetAspect = 4 / 3;
    final imageAspect = imageSize.width / imageSize.height;

    double cropW, cropH;

    if (imageAspect > targetAspect) {
      cropH = imageSize.height;
      cropW = cropH * targetAspect;
    } else {
      cropW = imageSize.width;
      cropH = cropW / targetAspect;
    }

    final left = (imageSize.width - cropW) / 2;
    final top = (imageSize.height - cropH) / 2;

    return Rect.fromLTWH(left, top, cropW, cropH);
  }
}