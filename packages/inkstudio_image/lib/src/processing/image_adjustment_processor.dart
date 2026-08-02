import 'package:image/image.dart' as img;
import 'package:inkstudio_image/inkstudio_image.dart';

class ImageAdjustmentProcessor {
  static img.Image apply(img.Image src, ImageAdjustments adj) {
    if (adj.brightness == 0.0 && adj.contrast == 1.0 && adj.saturation == 1.0) {
      return src;
    }

    final out = img.Image.from(src);

    for (int y = 0; y < out.height; y++) {
      for (int x = 0; x < out.width; x++) {
        final p = out.getPixel(x, y);

        double r = p.r.toDouble();
        double g = p.g.toDouble();
        double b = p.b.toDouble();

        // brightness
        r += adj.brightness;
        g += adj.brightness;
        b += adj.brightness;

        // contrast
        r = ((r - 128) * adj.contrast) + 128;
        g = ((g - 128) * adj.contrast) + 128;
        b = ((b - 128) * adj.contrast) + 128;

        // saturation
        final grey = (r + g + b) / 3.0;

        r = grey + ((r - grey) * adj.saturation);
        g = grey + ((g - grey) * adj.saturation);
        b = grey + ((b - grey) * adj.saturation);

        out.setPixelRgb(x, y, r.clamp(0, 255).round(), g.clamp(0, 255).round(), b.clamp(0, 255));
      }
    }

    return out;
  }

  static img.Image applySharpen(img.Image src, double amount) {
    if (amount <= 0) return src;

    final blurred = img.gaussianBlur(img.Image.from(src), radius: 2);
    final result = img.Image.from(src);

    for (int y=0; y<src.height; y++) {
      for (int x=0; x<src.width; x++) {
        final source = src.getPixel(x, y);
        final blur = blurred.getPixel(x, y);

        final r = (source.r + (source.r - blur.r) * amount)
          .clamp(0, 255)
          .round();

        final g = (source.g + (source.g - blur.g) * amount)
          .clamp(0, 255)
          .round();

        final b = (source.b + (source.b - blur.b) * amount)
          .clamp(0, 255)
          .round();

        result.setPixelRgb(x, y, r, g, b);
      }
    }

    return result;
  }
}