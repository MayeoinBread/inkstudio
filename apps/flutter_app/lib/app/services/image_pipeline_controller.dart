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
  Uint8List? stickerlessPreviewBytes;

  Future<void> prepare(Uint8List bytes, Rect? cropRect, int rotation) async {
    sourceImage = await compute(
      runPrepareIsolate,
      PrepareRequest(
        bytes: bytes,
        cropRect: cropRect,
        rotation: rotation
      )
    );
    // sourceImage = pipeline.prepareBaseImage(decoded, cropRect, rotation);
  }

  Future<void> processMetadata({
    required SlotMetadata metadata,
    required List<ContentOverlay> overlays,
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
        ditherOptions: metadata.ditherOptions,
        paletteBias: metadata.paletteBias,
        overlays: overlays
      )
    );

    framebuffer = result.framebuffer;
    previewBytes = result.previewBytes;
    stickerlessPreviewBytes = result.stickerlessPreviewBytes;
  }

  Future<void> process({
    required DitherMode dither,
    required ImageFilter filter,
    required bool simulateDevice,
    required ImageAdjustments adjustments,
    required DitherOptions ditherOptions,
    required PaletteBias paletteBias,
    required List<ContentOverlay> overlays
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
        ditherOptions: ditherOptions,
        paletteBias: paletteBias,
        overlays: overlays
      )
    );

    framebuffer = result.framebuffer;
    previewBytes = result.previewBytes;
    stickerlessPreviewBytes = result.stickerlessPreviewBytes;
  }

  void clear() {
    sourceImage = null;
    framebuffer = null;
    previewBytes = null;
    stickerlessPreviewBytes = null;
  }
}