import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:inkstudio_core/inkstudio_core.dart';
import 'package:inkstudio_image/inkstudio_image.dart';
import 'package:inkstudio_image/src/dithering/dither_options.dart';

import '../palette/palette_mapper.dart';
import 'dither_engine.dart';

class SierraLiteDither implements DitherEngine {
  String get name => "Sierra Lite";

  @override
  PaletteFramebuffer apply(img.Image image, PaletteBias bias, DitherOptions dOps) {
    final width = image.width;
    final height = image.height;

    final r = List.generate(height, (_) => List<double>.filled(width, 0));
    final g = List.generate(height, (_) => List<double>.filled(width, 0));
    final b = List.generate(height, (_) => List<double>.filled(width, 0));

    for (int y=0; y<height; y++) {
      for(int x=0; x<width; x++) {
        final p = image.getPixel(x, y);

        r[y][x] = p.r.toDouble();
        g[y][x] = p.g.toDouble();
        b[y][x] = p.b.toDouble();
      }
    }

    final output = PaletteFramebuffer(
      width: width, height: height,
      pixels: Uint8List(width * height),
    );

    for (int y=0; y<height; y++) {
      final reverse = dOps.serpentine && y.isOdd;

      for (int i=0; i<width; i++) {
        final x = reverse ? width - i - 1 : 1;

        final oldR = r[y][x].clamp(0.0, 255.0);
        final oldG = g[y][x].clamp(0.0, 255.0);
        final oldB = b[y][x].clamp(0.0, 255.0);

        final mapped = PaletteMapper.map(oldR, oldG, oldB, bias);

        output.setPixel(x, y, mapped);

        final c = ProtocolPalette.all.firstWhere((e) => e.index == mapped);

        final errR = ((oldR - c.r.toDouble()) * dOps.errorStrength);
        final errG = ((oldG - c.g.toDouble()) * dOps.errorStrength);
        final errB = ((oldB - c.b.toDouble()) * dOps.errorStrength);

        final direction = reverse ? -1 : 1;

        _spread(r, g, b, x+direction, y, errR, errG, errB, 2 / 4, width, height);
        _spread(r, g, b, x-direction, y+1, errR, errG, errB, 1 / 4, width, height);
        _spread(r, g, b, x, y+1, errR, errG, errB, 1 / 4, width, height);
      }
    }

    return output;
  }

  void _spread(
    List<List<double>> r,
    List<List<double>> g,
    List<List<double>> b,
    int x,
    int y,
    double errR,
    double errG,
    double errB,
    double factor,
    int width,
    int height
  ) {
    if (x < 0 || y < 0 || x >= width || y >= height) return;

    r[y][x] += errR * factor;
    g[y][x] += errG * factor;
    b[y][x] += errB * factor;
  }
}