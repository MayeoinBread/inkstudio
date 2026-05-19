class PaletteColour {
  final int r;
  final int g;
  final int b;

  const PaletteColour(this.r, this.g, this.b);
}

class Palette {
  /// TODO Update with actual palette colours from panel
  static const black = PaletteColour(24, 20, 17);
  static const white = PaletteColour(138, 135, 119);
  static const yellow = PaletteColour(151, 109, 1);
  static const red = PaletteColour(84, 29, 17);

  static const all = <PaletteColour>[black, white, yellow, red];
}

class PaletteMapper {
  /// Returns closest palette colour for a given RGB pixel
  
  static PaletteColour map(int r, int g, int b) {
    PaletteColour best = Palette.all.first;
    int bestDist = _dist(r, g, b, best);

    for (final c in Palette.all.skip(1)) {
      final d  = _dist(r, g, b, c);
      if (d < bestDist) {
        bestDist = d;
        best = c;
      }
    }
    return best;
  }

  static int _dist(int r, int g, int b, PaletteColour c) {
    final dr = r - c.r;
    final dg = g - c.g;
    final db = b - c.b;
    return dr * dr + dg * dg + db * db;
  }
}