import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:inkstudio_core/inkstudio_core.dart';
import 'package:inkstudio_image/inkstudio_image.dart';
import 'package:inkstudio_image/src/dithering/dither_engine.dart';
import 'package:inkstudio_image/src/dithering/dither_options.dart';
import '../palette/palette_mapper.dart';

class AdaptiveAtkinsonDither implements DitherEngine {
  String get name => "Adaptive Atkinson";

  @override
  PaletteFramebuffer apply(img.Image input, PaletteBias bias, DitherOptions dOps) {
    final width = input.width;
    final height = input.height;

    final edges = List.generate(height, (_) => List<double>.filled(width, 0));

    for (int y=1; y<height-1; y++) {
      for (int x=1; x<width-1; x++) {
        final l1 = img.getLuminance(input.getPixel(x-1, y));
        final l2 = img.getLuminance(input.getPixel(x+1, y));
        final l3 = img.getLuminance(input.getPixel(x, y-1));
        final l4 = img.getLuminance(input.getPixel(x, y+1));

        edges[y][x] = ((l1 - l2).abs() + (l3 - l4).abs()) / 255.0;
      }
    }

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
      for (int x=0; x<width; x++) {
        final oldR = r[y][x].clamp(0.0, 255.0);
        final oldG = g[y][x].clamp(0.0, 255.0);
        final oldB = b[y][x].clamp(0.0, 255.0);

        final mapped = PaletteMapper.map(oldR, oldG, oldB, bias);

        final paletteColour = ProtocolPalette.all.firstWhere(
          (c) => c.index == mapped
        );

        output.setPixel(x, y, mapped);

        final strength = edges[y][x];

        final diffusion = strength > dOps.edgeDetectionThreshold ? 1.0 : dOps.smoothAreaDiffusion;
        final effectiveStrength = diffusion * dOps.errorStrength;

        final errR = (oldR - paletteColour.r) * effectiveStrength / 8.0;
        final errG = (oldG - paletteColour.g) * effectiveStrength / 8.0;
        final errB = (oldB - paletteColour.b) * effectiveStrength / 8.0;

        _distributed(r, g, b, x + 1, y,     errR, errG, errB, width, height);
        _distributed(r, g, b, x + 2, y,     errR, errG, errB, width, height);

        _distributed(r, g, b, x - 1, y + 1, errR, errG, errB, width, height);
        _distributed(r, g, b, x,     y + 1, errR, errG, errB, width, height);
        _distributed(r, g, b, x + 1, y + 1, errR, errG, errB, width, height);

        _distributed(r, g, b, x,     y + 2, errR, errG, errB, width, height);
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
    int width, int height
  ) {
    if (x < 0 || x >= width || y < 0 || y >= height) return;

    r[y][x] += errR;
    g[y][x] += errG;
    b[y][x] += errB;
  }
}