import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:inkstudio_core/inkstudio_core.dart';
import 'package:inkstudio_image/inkstudio_image.dart';

import '../palette/palette_mapper.dart';
import 'dither_engine.dart';

class SierraDither implements DitherEngine {
  String get name => "Sierra";

  @override
  PaletteFramebuffer apply(img.Image input, PaletteBias bias, DitherOptions dOps) {
    final width = input.width;
    final height = input.height;

    // Float buffers preserve fractional error during diffusion
    final r = List.generate(height, (_) => List<double>.filled(width, 0.0));
    final g = List.generate(height, (_) => List<double>.filled(width, 0.0));
    final b = List.generate(height, (_) => List<double>.filled(width, 0.0));

    // Copy input pixels into float buffers
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

        output.setPixel(x, y, mapped);

        final paletteColour = ProtocolPalette.all.firstWhere((c) => c.index == mapped);

        // Sierra currently uses full error diffusion
        final errR = (oldR - paletteColour.r.toDouble()) * dOps.errorStrength / 32.0;
        final errG = (oldG - paletteColour.g.toDouble()) * dOps.errorStrength / 32.0;
        final errB = (oldB - paletteColour.b.toDouble()) * dOps.errorStrength / 32.0;

        final direction = reverse ? -1 : 1;

        _distribute(r, g, b, x + direction, y, errR * 5, errG * 5, errB * 5, width, height);
        _distribute(r, g, b, x + (direction * 2), y, errR * 3, errG * 3, errB * 3, width, height);

        _distribute(r, g, b, x - (direction * 2), y + 1, errR * 2, errG * 2, errB * 2, width, height);
        _distribute(r, g, b, x - direction, y + 1, errR * 4, errG * 4, errB * 4, width, height);
        _distribute(r, g, b, x, y + 1, errR * 5, errG * 5, errB * 5, width, height);
        _distribute(r, g, b, x + direction, y + 1, errR * 4, errG * 4, errB * 4, width, height);
        _distribute(r, g, b, x + (direction * 2), y + 1, errR * 2, errG * 2, errB * 2, width, height);

        _distribute(r, g, b, x - direction, y + 2, errR * 2, errG * 2, errB * 2, width, height);
        _distribute(r, g, b, x, y + 2, errR * 3, errG * 3, errB * 3, width, height);
        _distribute(r, g, b, x + direction, y + 2, errR * 2, errG * 2, errB * 2, width, height);

      }
    }

    return output;
  }

  void _distribute(
    List<List<double>> r,
    List<List<double>> g,
    List<List<double>> b,
    int x,
    int y,
    double errR,
    double errG,
    double errB,
    int width,
    int height
  ) {
    if (x < 0 || y < 0 || x >= width || y >= height) {
      return;
    }

    r[y][x] += errR;
    g[y][x] += errG;
    b[y][x] += errB;
  }
}