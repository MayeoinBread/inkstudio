import 'package:inkstudio_image/src/models/overlay_enums.dart';

sealed class OverlayData {
  const OverlayData();

  String get type;

  Map<String, dynamic> toJson();

  factory OverlayData.fromJson(Map<String, dynamic> json) {
    switch(json['type']) {
      case 'shape':
        return ShapeOverlayData.fromJson(json);
      default:
        throw FormatException(
          'Unknown overlay data type: ${json['type']}'
        );
    }
  }
}

class ShapeOverlayData extends OverlayData {
  final ShapeType shape;
  final OverlayStyle style;

  ShapeOverlayData({
    required this.shape,
    required this.style
  });

  @override
  String get type => 'shape';

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'shape': shape.name,
      'style': style.name
    };
  }

  factory ShapeOverlayData.fromJson(
    Map<String, dynamic> json
  ) {
    return ShapeOverlayData(
      shape: ShapeType.values.byName(json['shape'] as String),
      style: OverlayStyle.values.byName(json['style'] as String)
    );
  }
}

// TODO when needed:

// class ImageOverlayData extends OverlayData {
//   final String imageId;
// }

// class TextOverlayData extends OverlayData {
//   final String text;

//   // font, size, etc. later
// }