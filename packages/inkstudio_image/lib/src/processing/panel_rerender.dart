import 'package:image/image.dart' as img;
import 'package:inkstudio_core/inkstudio_core.dart';
import 'package:inkstudio_image/inkstudio_image.dart';


class PanelRerender {
  static img.Image renderFramebuffer(PaletteFramebuffer fb) {
    final imgOut = img.Image(width: fb.width, height: fb.height);

    for (int y = 0; y < fb.height; y++) {
      for (int x = 0; x < fb.width; x++) {
        final index = (y * fb.width + x);
        final colourIndex = fb.pixels[index];
        final colour = ProtocolPalette.all[colourIndex];

        imgOut.setPixelRgb(x, y, colour.r, colour.g, colour.b);
      }
    }

    return imgOut;
  }
}