import 'package:inkstudio_core/inkstudio_core.dart';
import 'package:inkstudio_image/inkstudio_image.dart';

class PaletteMapper {
  static PaletteIndex map(double r, double g, double b, PaletteBias bias) {
    ProtocolPaletteColour best = ProtocolPalette.all.first;
    double bestDist = _dist(r, g, b, best, bias);

    for (final c in ProtocolPalette.all.skip(1)) {
      final d = _dist(r, g, b, c, bias);

      if (d < bestDist) {
        bestDist = d;
        best = c;
      }
    }

    return best.index;
  }

  static double _dist(double r, double g, double b, ProtocolPaletteColour c, PaletteBias bias) {
    final dr = r - c.r;
    final dg = g - c.g;
    final db = b - c.b;

    double distance = (dr * dr + dg * dg + db * db);

    switch (c.index) {
      case PaletteIndex.black:
        distance *= bias.black;
        break;
      case PaletteIndex.white:
        distance *= bias.white;
        break;
      case PaletteIndex.red:
        distance *= bias.red;
        break;
      case PaletteIndex.yellow:
        distance *= bias.yellow;
        break;
    }

    return distance;
  }
}