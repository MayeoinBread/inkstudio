import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:inkstudio_core/inkstudio_core.dart';
import 'package:inkstudio_image/inkstudio_image.dart';
import 'package:inkstudio_image/src/dithering/dither_engine.dart';
import '../palette/palette_mapper.dart';

class FloydSteinbergDither implements DitherEngine {
  String get name => "Floyd-Steinberg";

  @override
  PaletteFramebuffer apply(img.Image input, PaletteBias bias, DitherOptions dOps) {
    final width = input.width;
    final height = input.height;

    // work on float buffers for error diffusion
    final r = List.generate(height, (_) => List<double>.filled(width, 0));
    final g = List.generate(height, (_) => List<double>.filled(width, 0));
    final b = List.generate(height, (_) => List<double>.filled(width, 0));

    // copy input into float buffers
    for (int y=0; y<height; y++) {
      for (int x=0; x<width; x++) {
        final p = input.getPixel(x, y);
        r[y][x] = p.r.toDouble();
        g[y][x] = p.g.toDouble();
        b[y][x] = p.b.toDouble();
      }
    }

    final output = PaletteFramebuffer(width: width, height: height, pixels: Uint8List(width * height));

    for (int y=0; y<height; y++) {
      final reverse = dOps.serpentine && y.isOdd;

      for (int i=0; i<width; i++) {
        final x = reverse ? width - i - 1 : i;

        final oldR = r[y][x].clamp(0.0, 255.0);
        final oldG = g[y][x].clamp(0.0, 255.0);
        final oldB = b[y][x].clamp(0.0, 255.0);

        final mapped = PaletteMapper.map(oldR, oldG, oldB, bias);

        final paletteColour = ProtocolPalette.all.firstWhere(
          (c) => c.index == mapped
        );

        output.setPixel(x, y, mapped);

        final errR = ((oldR - paletteColour.r) * dOps.errorStrength);
        final errG = ((oldG - paletteColour.g) * dOps.errorStrength);
        final errB = ((oldB - paletteColour.b) * dOps.errorStrength);

        final direction = reverse ? -1 : 1;

        _distributed(r, g, b, x + direction, y,     errR, errG, errB, width, height, 7 / 16);
        _distributed(r, g, b, x - direction, y + 1, errR, errG, errB, width, height, 3 / 16);
        _distributed(r, g, b, x,     y + 1, errR, errG, errB, width, height, 5 / 16);
        _distributed(r, g, b, x + direction, y + 1, errR, errG, errB, width, height, 1 / 16);
      }
    }

    return output;
  }

  void _distributed(
    List<List<double>> r,
    List<List<double>> g,
    List<List<double>> b,
    int x, int y,
    double errR, double errG, double errB,
    int width, int height,
    double factor
  ) {
    if (x < 0 || x >= width || y < 0 || y >= height) return;

    r[y][x] += errR * factor;
    g[y][x] += errG * factor;
    b[y][x] += errB * factor;
  }
}