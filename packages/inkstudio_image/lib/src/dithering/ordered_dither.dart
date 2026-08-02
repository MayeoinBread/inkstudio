import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:inkstudio_image/inkstudio_image.dart';
import 'package:inkstudio_image/src/dithering/dither_options.dart';

import '../palette/palette_mapper.dart';
import '../pipeline/palette_framebuffer.dart';
import 'dither_engine.dart';

class OrderedDither implements DitherEngine {
  String get name => "Ordered";

  static const matrix2 = [
    [0, 2],
    [3, 1],
  ];

  static const matrix4 = [
    [0, 8, 2, 10],
    [12, 4, 14, 6],
    [3, 11, 1, 9],
    [15, 7, 13, 5],
  ];

  static const matrix8 = [
    [0, 48, 12, 60, 3, 51, 15, 63],
    [32, 16, 44, 28, 35, 19, 47, 31],
    [8, 56, 4, 52, 11, 59, 7, 55],
    [40, 24, 36, 20, 43, 27, 39, 23],
    [2, 50, 14, 62, 1, 49, 13, 61],
    [34, 18, 46, 30, 33, 17, 45, 29],
    [10, 58, 6, 54, 9, 57, 5, 53],
    [42, 26, 38, 22, 41, 25, 37, 21],
  ];

  @override
  PaletteFramebuffer apply(
    img.Image image,
    PaletteBias bias,
    DitherOptions dOps,
  ) {
    final matrix = switch (dOps.orderedMatrixSize) {
      2 => matrix2,
      8 => matrix8,
      _ => matrix4,
    };

    final size = matrix.length;
    final maxValue = size * size;

    final output = PaletteFramebuffer(
      width: image.width,
      height: image.height,
      pixels: Uint8List(image.width * image.height),
    );

    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        final pixel = image.getPixel(x, y);

        final threshold =
            (matrix[y % size][x % size] / maxValue - 0.5) *
            dOps.orderedStrength;

        final r = (pixel.r + threshold).clamp(0.0, 255.0);
        final g = (pixel.g + threshold).clamp(0.0, 255.0);
        final b = (pixel.b + threshold).clamp(0.0, 255.0);

        final mapped = PaletteMapper.map(
          r,
          g,
          b,
          bias,
        );

        output.setPixel(x, y, mapped);
      }
    }

    return output;
  }
}