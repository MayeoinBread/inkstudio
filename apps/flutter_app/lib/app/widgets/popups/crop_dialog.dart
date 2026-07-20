import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:inkstudio/app/widgets/controls/crop_overlay.dart';
import 'package:inkstudio_core/inkstudio_core.dart';
import 'package:inkstudio_image/inkstudio_image.dart';

class CropDialog extends StatefulWidget {
  final Uint8List imageBytes;
  final Rect? initialRect;
  final int rotation;

  const CropDialog({
    super.key,
    required this.imageBytes,
    this.initialRect,
    this.rotation = 0
  });

  @override
  State<CropDialog> createState() => _CropDialogState();
}

class _CropDialogState extends State<CropDialog> {
  late img.Image decoded;
  late final Uint8List rotatedBytes;

  late Rect cropRect;

  @override
  void initState() {
    super.initState();

    decoded = img.decodeImage(widget.imageBytes)!;
    decoded = img.copyRotate(decoded, angle: widget.rotation);

    rotatedBytes = Uint8List.fromList(img.encodePng(decoded));

    cropRect = widget.initialRect ??
      defaultCropRect(
        decoded.width,
        decoded.height
      );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Crop Image',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final imageAspect = decoded.width / decoded.height;
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
                    child: InteractiveViewer(
                      minScale: 0.5,
                      maxScale: 5,
                      child: SizedBox(
                        width: displayWidth,
                        height: displayHeight,
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: Image.memory(
                                rotatedBytes,
                                fit: BoxFit.fill,
                                cacheWidth: 800,
                              )
                            ),

                            CropOverlay(
                              imageSize: Size(displayWidth, displayHeight),
                              initialRect: cropRect,
                              aspectRatio: DeviceConstants.imageWidth / DeviceConstants.imageHeight,
                              onChanged: (rect) {
                                cropRect = rect;
                              }
                            )
                          ]
                        )
                      )
                    )
                  );
                }
              )
            ),

            const SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel'),
                ),

                const SizedBox(width: 8),

                FilledButton(
                  onPressed: () {
                    Navigator.pop(context, cropRect);
                  },
                  child: const Text('Apply'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}