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

  OverlayData copyWith();
}

class ShapeOverlayData extends OverlayData {
  final ShapeType shape;
  final OverlayStyle style;
  final double strokeWidth;

  ShapeOverlayData({
    required this.shape,
    required this.style,
    this.strokeWidth = 1.5
  });

  @override
  String get type => 'shape';

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'shape': shape.name,
      'style': style.name,
      'strokeWidth': strokeWidth
    };
  }

  @override
  ShapeOverlayData copyWith({
    ShapeType? shape,
    OverlayStyle? style,
    double? strokeWidth
  }) {
    return ShapeOverlayData(
      shape: shape ?? this.shape,
      style: style ?? this.style,
      strokeWidth: strokeWidth ?? this.strokeWidth
    );
  }

  factory ShapeOverlayData.fromJson(
    Map<String, dynamic> json
  ) {
    return ShapeOverlayData(
      shape: ShapeType.values.byName(json['shape'] as String),
      style: OverlayStyle.values.byName(json['style'] as String),
      strokeWidth: (json['strokeWidth'] as num?)?.toDouble() ?? 1.5
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