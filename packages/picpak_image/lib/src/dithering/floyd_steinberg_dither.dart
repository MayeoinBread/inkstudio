import 'package:image/image.dart' as img;
import '../palette/palette_mapper.dart';
import 'dither_algorithm.dart';

class FloydSteinbergDither implements DitherAlgorithm {
  @override
  String get name => "Floyd-Steinberg";

  @override
  img.Image apply(img.Image input) {
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

    final output = img.Image(width: width, height: height);

    for (int y=0; y<height; y++) {
      for (int x=0; x<width; x++) {
        final oldR = r[y][x].clamp(0, 255).toInt();
        final oldG = g[y][x].clamp(0, 255).toInt();
        final oldB = b[y][x].clamp(0, 255).toInt();

        final mapped = PaletteMapper.map(oldR, oldG, oldB);

        output.setPixelRgb(x, y, mapped.r, mapped.g, mapped.b);

        final errR = oldR - mapped.r;
        final errG = oldG - mapped.g;
        final errB = oldB - mapped.b;

        _distributed(r, g, b, x + 1, y,     errR, errG, errB, width, height, 7 / 16);
        _distributed(r, g, b, x - 1, y + 1, errR, errG, errB, width, height, 3 / 16);
        _distributed(r, g, b, x,     y + 1, errR, errG, errB, width, height, 5 / 16);
        _distributed(r, g, b, x + 1, y + 1, errR, errG, errB, width, height, 1 / 16);
      }
    }

    return output;
  }

  void _distributed(
    List<List<double>> r,
    List<List<double>> g,
    List<List<double>> b,
    int x, int y,
    int errR, int errG, int errB,
    int width, int height,
    double factor
  ) {
    if (x < 0 || x >= width || y < 0 || y >= height) return;

    r[y][x] += errR * factor;
    g[y][x] += errG * factor;
    b[y][x] += errB * factor;
  }
}