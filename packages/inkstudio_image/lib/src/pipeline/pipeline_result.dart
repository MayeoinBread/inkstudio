import 'dart:typed_data';

import 'package:inkstudio_image/src/pipeline/palette_framebuffer.dart';

class PipelineResult {
  final PaletteFramebuffer framebuffer;
  final PaletteFramebuffer stickerlessFramebuffer;
  final Uint8List previewBytes;
  final Uint8List stickerlessPreviewBytes;

  PipelineResult({
    required this.framebuffer,
    required this.stickerlessFramebuffer,
    required this.previewBytes,
    required this.stickerlessPreviewBytes
  });
}