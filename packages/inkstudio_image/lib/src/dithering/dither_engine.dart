import 'package:image/image.dart' as img;
import 'package:inkstudio_image/inkstudio_image.dart';

const double ditherErrorStrength = 0.8;
abstract class DitherEngine {
  PaletteFramebuffer apply(img.Image image, PaletteBias bias);
}