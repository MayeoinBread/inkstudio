import 'dart:ui';

import 'package:inkstudio_core/inkstudio_core.dart';

Rect defaultCropRect(int width, int height) {
  const targetAspect = DeviceConstants.imageWidth / DeviceConstants.imageHeight;
    final imageAspect = width / height;

    double w;
    double h;

    if (imageAspect > targetAspect) {
      h = 1.0;
      w = targetAspect / imageAspect;
    } else {
      w = 1.0;
      h = imageAspect / targetAspect;
    }

    return Rect.fromLTWH((1-w) / 2, (1 - h) / 2, w, h);
}