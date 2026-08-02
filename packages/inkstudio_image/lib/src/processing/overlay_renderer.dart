import 'package:inkstudio_image/inkstudio_image.dart';

class OverlayRenderer {
  static void apply(
    PaletteFramebuffer framebuffer,
    List<ContentOverlay> overlays
  ) {
    for (final overlay in overlays) {
      _applyOverlay(framebuffer, overlay);
    }
  }

  static void _applyOverlay(
    PaletteFramebuffer framebuffer,
    ContentOverlay overlay
  ) {
    switch (overlay.data) {
      case ShapeOverlayData():
        ShapeOverlayRenderer.apply(
          framebuffer,
          overlay
        );
    }
  }
}