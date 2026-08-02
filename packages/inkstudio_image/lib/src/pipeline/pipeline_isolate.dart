import 'dart:typed_data';
import 'dart:ui';

import 'package:image/image.dart' as img;
import 'package:inkstudio_image/inkstudio_image.dart';

img.Image runPrepareIsolate(PrepareRequest request) {
  final decoded = img.decodeImage(request.bytes)!;
  return ImagePipeline().prepareBaseImage(
    decoded,
    request.cropRect,
    request.rotation
  );
}

PipelineResult runPipelineIsolate(dynamic data) {
  final req = data as PipelineRequest;
  final pipeline = ImagePipeline(
    targetWidth: req.width,
    targetHeight: req.height,
  );

  return pipeline.process(
    req.workingImage,
    filter: req.filter,
    simulateDevice: req.simulateDevice,
    adjustments: req.adjustments,
    paletteBias: req.paletteBias,
    dOps: req.ditherOptions,
    dither: req.dither,
    overlays: req.overlays
  );
}

class PrepareRequest {
  final Uint8List bytes;
  final Rect? cropRect;
  final int rotation;

  PrepareRequest({
    required this.bytes,
    required this.cropRect,
    required this.rotation
  });
}

class PipelineRequest {
  final img.Image workingImage;
  final ImageFilter filter;
  final bool simulateDevice;
  final int width;
  final int height;
  final DitherMode dither;
  final ImageAdjustments adjustments;
  final DitherOptions ditherOptions;
  final PaletteBias paletteBias;
  final List<ContentOverlay> overlays;

  PipelineRequest({
    required this.workingImage,
    required this.filter,
    required this.simulateDevice,
    required this.width,
    required this.height,
    required this.dither,
    required this.adjustments,
    required this.ditherOptions,
    required this.paletteBias,
    required this.overlays
  });
}