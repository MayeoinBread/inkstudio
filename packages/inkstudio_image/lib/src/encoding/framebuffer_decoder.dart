import 'package:flutter/foundation.dart';
import 'package:inkstudio_core/inkstudio_core.dart';
import 'package:inkstudio_image/inkstudio_image.dart';

class FramebufferDecoder {
  static PaletteFramebuffer decode(Uint8List bytes) {
    final totalPixels = DeviceConstants.imageWidth * DeviceConstants.imageHeight;
    final pixels = Uint8List(totalPixels);

    int p = 0;

    for (final byte in bytes) {
      if (p < totalPixels) pixels[p++] = (byte >> 6) & 0x03;
      if (p < totalPixels) pixels[p++] = (byte >> 4) & 0x03;
      if (p < totalPixels) pixels[p++] = (byte >> 2) & 0x03;
      if (p < totalPixels) pixels[p++] = (byte >> 0) & 0x03;
    }

    final flippedBuffer =  PaletteFramebuffer(width: DeviceConstants.imageWidth, height: DeviceConstants.imageHeight, pixels: pixels);
    return flipVertical(flippedBuffer);
  }
}