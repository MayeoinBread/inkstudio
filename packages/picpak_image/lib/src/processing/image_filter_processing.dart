import 'dart:ui';

import 'package:image/image.dart' as img;
import 'package:picpak_image/picpak_image.dart';

class ImageFilterProcessor {
  static img.Image apply(
    img.Image input,
    ImageFilter filter,
    ImageAdjustments adjustments
  ) {
    switch (filter) {
      case ImageFilter.posterise:
        return _posterise(input, adjustments);

      case ImageFilter.comic:
        return _comic(input, adjustments);
      
      default:
        return _perPixelFilter(input, filter);
    }
  }

  static img.Image _perPixelFilter(img.Image input, ImageFilter filter) {
    final out = img.Image.from(input);

    for (int y = 0; y < out.height; y++) {
      for (int x = 0; x < out.width; x++) {
        final p = out.getPixel(x, y);

        int r = p.r.toInt();
        int g = p.g.toInt();
        int b = p.b.toInt();

        switch (filter) {
          case ImageFilter.normal:
            break;

          case ImageFilter.vibrant:
            r = (r * 1.25).clamp(0, 255).toInt();
            g = (g * 1.25).clamp(0, 255).toInt();
            b = (b * 1.25).clamp(0, 255).toInt();
            break;

          case ImageFilter.grayscale:
            final l = ((r + g + b) / 3).round();
            r = g = b = l;
            break;

          case ImageFilter.highContrast:
            final l = ((r + g + b) / 3).round();
            final v = l > 128 ? 255 : 0;
            r = g = b = v;
            break;
          
          default:
            break;
        }

        out.setPixelRgb(x, y, r, g, b);
      }
    }

    return out;
  }

  static img.Image _posterise(img.Image input, ImageAdjustments adj) {
    final out = img.Image.from(input);

    // const levels = 4;
    final levels = adj.toneLevels.round().clamp(2, 8);
    final step = 255 ~/ (levels - 1);

    for (int y=0; y<out.height; y++) {
      for (int x=0; x<out.width; x++) {
        final p = out.getPixel(x, y);

        int r = ((p.r / step).round() * step).clamp(0, 255).toInt();
        int g = ((p.g / step).round() * step).clamp(0, 255).toInt();
        int b = ((p.b / step).round() * step).clamp(0, 255).toInt();

        out.setPixelRgb(x, y, r, g, b);
      }
    }

    return out;
  }

  static img.Image _comic(img.Image input, ImageAdjustments adj) {
    final base = _posterise(input, adj);

    final blurred = img.gaussianBlur(
      img.grayscale(input),
      radius: 1,
    );

    final edges = img.sobel(blurred);

    final out = img.Image.from(base);

    // final threshold = lerpDouble(140, 60, adj.comicStrength)!;
    final threshold = adj.comicStrength == 1.0
      ? 90.0
      : lerpDouble(140, 60, adj.comicStrength)!;

    final thickness = adj.inkThickness.round().clamp(0, 3);

    for (int y = 0; y < out.height; y++) {
      for (int x = 0; x < out.width; x++) {
        final p = base.getPixel(x, y);
        final e = edges.getPixel(x, y);

        final edge =
            0.299 * e.r +
            0.587 * e.g +
            0.114 * e.b;

        if (edge > threshold) {
          if (thickness > 0) {
            _drawInk(out, x, y, thickness);
          } else {
            out.setPixelRgb(x, y, 0, 0, 0);
          }
        } else {
          out.setPixelRgb(
            x,
            y,
            p.r.toInt(),
            p.g.toInt(),
            p.b.toInt(),
          );
        }
      }
    }

    if (adj.toneLevels <= 1) return out;
    return _applyToon(out, adj.toneLevels);
  }

  static void _drawInk(img.Image img, int x, int y, int t) {
    for (int dy = -t; dy <= t; dy++) {
      for (int dx = -t; dx <= t; dx++) {
        final nx = x + dx;
        final ny = y + dy;

        if (nx < 0 ||
            ny < 0 ||
            nx >= img.width ||
            ny >= img.height) continue;

        img.setPixelRgb(nx, ny, 0, 0, 0);
      }
    }
  }

  static img.Image _applyToon(img.Image input, double levels) {
    final out = img.Image.from(input);

    final bands = levels.round().clamp(2, 8);
    final step = 255 / (bands - 1);

    for (int y = 0; y < out.height; y++) {
      for (int x = 0; x < out.width; x++) {
        final p = out.getPixel(x, y);

        int r = ((p.r / step).round() * step).clamp(0, 255).toInt();
        int g = ((p.g / step).round() * step).clamp(0, 255).toInt();
        int b = ((p.b / step).round() * step).clamp(0, 255).toInt();

        out.setPixelRgb(x, y, r, g, b);
      }
    }

    return out;
  }
}