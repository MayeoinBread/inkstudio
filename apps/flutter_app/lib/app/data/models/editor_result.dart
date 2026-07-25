import 'dart:typed_data';

import 'package:inkstudio_image/src/models/content_overlay.dart';
import 'package:inkstudio/app/widgets/library/slot_metadata.dart';

class EditorResult {
  final SlotMetadata metadata;
  final Uint8List? originalBytes;
  final Uint8List previewBytes;
  final Uint8List packedBytes;

  final List<ContentOverlay> overlays;
  
  const EditorResult({
    required this.metadata,
    required this.originalBytes,
    required this.previewBytes,
    required this.packedBytes,
    required this.overlays
  });
}