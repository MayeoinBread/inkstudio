import 'dart:typed_data';

import 'package:inkstudio_image/inkstudio_image.dart';

class PipelineArgs {
  final Uint8List image;
  final ImageFilter filter;
  final bool simulateDevice;
  final DitherMode dither;

  const PipelineArgs({
    required this.image,
    required this.filter,
    required this.simulateDevice,
    required this.dither
  });
}