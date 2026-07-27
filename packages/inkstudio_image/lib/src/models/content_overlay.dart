import 'package:inkstudio_image/src/models/overlay_data.dart';
import 'package:inkstudio_core/inkstudio_core.dart';

class ContentOverlay {
  final String id;

  // Normalised coordinates (0..1)
  final double x;
  final double y;
  final double width;
  final double height;

  final double rotation;

  final ProtocolPaletteColour colour;

  final OverlayData data;

  const ContentOverlay({
    required this.id,
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    this.rotation = 0,
    this.colour = ProtocolPalette.red,
    required this.data
  });

  Map<String, dynamic> toJson() {
    final version = 1;

    return {
      'version': version,
      'id': id,
      'x': x,
      'y': y,
      'width': width,
      'height': height,
      'rotation': rotation,
      'colour': colour.index.index,
      'data': data.toJson()
    };
  }

  factory ContentOverlay.fromJson(
    Map<String, dynamic> json
  ) {
    return ContentOverlay(
      id: json['id'] as String,
      x: (json['x'] as num).toDouble(),
      y: (json['y'] as num).toDouble(),
      width: (json['width'] as num).toDouble(),
      height: (json['height'] as num).toDouble(),
      data: OverlayData.fromJson(json['data'] as Map<String, dynamic>),
      rotation: (json['rotation'] as num?)?.toDouble() ?? 0,
      colour: ProtocolPalette.paletteFromIndex((json['colour'] as num?)?.toInt() ?? 3)
    );
  }

  ContentOverlay copyWith({
    double? x,
    double? y,
    double? width,
    double? height,
    double? rotation,
    ProtocolPaletteColour? colour,
    OverlayData? data
  }) {
    return ContentOverlay(
      id: id,
      x: x ?? this.x,
      y: y ?? this.y,
      width: width ?? this.width,
      height: height ?? this.height,
      data: data ?? this.data,
      rotation: rotation ?? this.rotation,
      colour: colour ?? this.colour
    );
  }
}