import 'dart:typed_data';
import 'package:image/image.dart' as img;

abstract class DitherAlgorithm {
  String get name;

  img.Image apply(img.Image input);
}