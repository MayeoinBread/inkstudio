import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:inkstudio/app/widgets/controls/sticker_overlay.dart';
import 'package:inkstudio_core/inkstudio_core.dart';
import 'package:inkstudio_image/inkstudio_image.dart';

class StickerEditorPreview extends StatefulWidget {
  final Uint8List backgroundBytes;
  final List<ContentOverlay> overlays;
  final String? selectedOverlayId;

  final ValueChanged<String> onOverlaySelected;
  final ValueChanged<ContentOverlay> onOverlayChanged;

  const StickerEditorPreview({
    super.key,
    required this.backgroundBytes,
    required this.overlays,
    required this.selectedOverlayId,
    required this.onOverlaySelected,
    required this.onOverlayChanged
  });

  @override
  State<StickerEditorPreview> createState() => _StickerEditorPreviewState();
}

class _StickerEditorPreviewState extends State<StickerEditorPreview> {

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final imageAspect = DeviceConstants.imageWidth / DeviceConstants.imageHeight;
        final availableAspect = constraints.maxWidth / constraints.maxHeight;

        double displayWidth;
        double displayHeight;

        if (imageAspect > availableAspect) {
          displayWidth = constraints.maxWidth;
          displayHeight = displayWidth / imageAspect;
        } else {
          displayHeight = constraints.maxHeight;
          displayWidth = displayHeight * imageAspect;
        }

        return Center(
          child: SizedBox(
            width: displayWidth,
            height: displayHeight,
            child: Stack(
              children: [
                Positioned.fill(
                  child: Image.memory(widget.backgroundBytes, fit: BoxFit.fill, cacheWidth: DeviceConstants.imageWidth)
                ),
                for (final overlay in widget.overlays)
                  _buildOverlay(overlay, displayWidth, displayHeight)
              ]
            )
          )
        );
      }
    );
  }

  Widget _buildOverlay(
    ContentOverlay overlay,
    double imageWidth,
    double imageHeight,
  ) {
    final isSelected = overlay.id == widget.selectedOverlayId;

    return StickerOverlay(
      overlay: overlay,
      imageSize: Size(
        imageWidth,
        imageHeight,
      ),
      selected: isSelected,
      child: _buildOverlayVisual(overlay),
      onSelected: () {
        widget.onOverlaySelected(overlay.id);
      },
      onChanged: (updatedOverlay) {
        widget.onOverlayChanged(updatedOverlay);
      },
    );
  }

  Widget _buildOverlayVisual(ContentOverlay overlay) {
    final data = overlay.data;

    if (data is! ShapeOverlayData) {
      return const SizedBox();
    }
    return CustomPaint(
      painter: ShapeOverlayPainter(
        data: data,
        colour: overlay.colour.index,
        selected: overlay.id == widget.selectedOverlayId
      ),
      child: const SizedBox.expand()
    );
  }
}