import 'package:image/image.dart' as img;
import 'package:inkstudio_image/inkstudio_image.dart';

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
    dither: req.dither
  );
}

class PipelineRequest {
  final img.Image workingImage;
  final ImageFilter filter;
  final bool simulateDevice;
  final int width;
  final int height;
  final DitherMode dither;
  final ImageAdjustments adjustments;
  final PaletteBias paletteBias;

  PipelineRequest({
    required this.workingImage,
    required this.filter,
    required this.simulateDevice,
    required this.width,
    required this.height,
    required this.dither,
    required this.adjustments,
    required this.paletteBias
  });
}