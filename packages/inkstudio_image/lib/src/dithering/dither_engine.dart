import 'package:image/image.dart' as img;
import 'package:inkstudio_image/inkstudio_image.dart';

abstract class DitherEngine {
  PaletteFramebuffer apply(img.Image image, PaletteBias bias);
}