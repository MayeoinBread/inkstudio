import 'dart:typed_data';

import 'package:inkstudio_image/src/pipeline/palette_framebuffer.dart';

class PipelineResult {
  final PaletteFramebuffer framebuffer;
  final Uint8List previewBytes;

  PipelineResult({
    required this.framebuffer,
    required this.previewBytes
  });
}