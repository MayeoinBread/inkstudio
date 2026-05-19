import 'dart:typed_data';
import 'package:image/image.dart' as img;
import '../pipeline/fit_strategy.dart';
import '../palette/palette_mapper.dart';
import '../dithering/floyd_steinberg_dither.dart';
import '../dithering/atkinson_dither.dart';

class ImagePipeline {
  final int targetWidth;
  final int targetHeight;

  const ImagePipeline({
    this.targetWidth = 400,
    this.targetHeight = 300
  });

  img.Image process(
    Uint8List inputBytes, {
    FitStrategy fit = FitStrategy.crop,
    String dither = "fs",
  }) {
    final decoded = img.decodeImage(inputBytes);

    if (decoded == null) {
      throw Exception('Failed to decode image');
    }

    final resized = _resize(decoded, fit);
    
    final dithered = switch (dither) {
      "atkinson" => AtkinsonDither().apply(resized),
      _ => FloydSteinbergDither().apply(resized)
    };

    return dithered;
  }

  // TODO delete function unless we think we still need it
  img.Image applyPalette(img.Image input) {
    final output = img.Image(
      width: input.width,
      height: input.height
    );

    for (int y=0; y < input.height; y++) {
      for (int x=0; x<input.width; x++) {
        final pixel = input.getPixel(x, y);

        final r = pixel.r.toInt();
        final g = pixel.g.toInt();
        final b = pixel.b.toInt();

        final mapped = PaletteMapper.map(r, g, b);

        output.setPixelRgb(x, y, mapped.r, mapped.g, mapped.b);
      }
    }

    return output;
  }

  img.Image _resize(img.Image src, FitStrategy fit) {
    switch(fit) {
      case FitStrategy.scale:
        return img.copyResize(
          src,
          width: targetWidth,
          height: targetHeight
        );
      case FitStrategy.crop:
      final ratioSrc = src.width / src.height;
      final ratioTarget = targetWidth / targetHeight;

      img.Image cropped;

      if (ratioSrc > ratioTarget) {
        final newWidth = (src.height * ratioTarget).round();
        final xOffset = ((src.width - newWidth) / 2).round();

        cropped = img.copyCrop(src, x: xOffset, y: 0, width: newWidth, height: src.height);
      } else {
        final newHeight = (src.width / ratioTarget).round();
        final yOffset = ((src.height - newHeight) / 2).round();

        cropped = img.copyCrop(src, x: 0, y: yOffset, width: src.width, height: newHeight);
      }

      return img.copyResize(cropped, width: targetWidth, height: targetHeight);
    }
  }
}