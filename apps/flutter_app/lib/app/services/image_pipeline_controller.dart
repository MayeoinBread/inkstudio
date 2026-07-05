import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:inkstudio_image/inkstudio_image.dart';

import 'package:inkstudio_core/inkstudio_core.dart';
import 'package:inkstudio/app/widgets/library/slot_metadata.dart';

class ImagePipelineController {
  img.Image? sourceImage;
  PaletteFramebuffer? framebuffer;
  Uint8List? previewBytes;

  Future<void> prepare(Uint8List bytes, Rect? cropRect, int rotation) async {
    final decoded = img.decodeImage(bytes);
    if (decoded == null) return;

    final pipeline = ImagePipeline();
    sourceImage = pipeline.prepareBaseImage(decoded, cropRect, rotation);
  }

  Future<void> processMetadata({
    required SlotMetadata metadata,
    bool simulateDevice = false
    }) async {
    if (sourceImage == null) return;

    final result = await compute(
      runPipelineIsolate,
      PipelineRequest(
        workingImage: sourceImage!,
        filter: metadata.filter,
        simulateDevice: simulateDevice,
        width: DeviceConstants.imageWidth,
        height: DeviceConstants.imageHeight,
        dither: metadata.dither,
        adjustments: metadata.adjustments,
        paletteBias: metadata.paletteBias
      )
    );

    framebuffer = result.framebuffer;
    previewBytes = result.previewBytes;
  }

  Future<void> process({
    required DitherMode dither,
    required ImageFilter filter,
    required bool simulateDevice,
    required ImageAdjustments adjustments,
    required PaletteBias paletteBias,
    required int rotation
  }) async {
    if (sourceImage == null) return;

    final result = await compute(
      runPipelineIsolate,
      PipelineRequest(
        workingImage: sourceImage!,
        filter: filter,
        simulateDevice: simulateDevice,
        width: DeviceConstants.imageWidth,
        height: DeviceConstants.imageHeight,
        dither: dither,
        adjustments: adjustments,
        paletteBias: paletteBias
      )
    );

    framebuffer = result.framebuffer;
    previewBytes = result.previewBytes;
  }

  void clear() {
    sourceImage = null;
    framebuffer = null;
    previewBytes = null;
  }
}