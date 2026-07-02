import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:inkstudio/app/widgets/controls/crop_overlay.dart';

class CropDialog extends StatefulWidget {
  final Uint8List imageBytes;
  final Rect? initialRect;

  const CropDialog({
    super.key,
    required this.imageBytes,
    this.initialRect,
  });

  @override
  State<CropDialog> createState() => _CropDialogState();
}

class _CropDialogState extends State<CropDialog> {
  late final img.Image decoded;

  late Rect cropRect;

  @override
  void initState() {
    super.initState();

    decoded = img.decodeImage(widget.imageBytes)!;

    cropRect = widget.initialRect ??
        _defaultCrop(
          decoded.width.toDouble(),
          decoded.height.toDouble(),
        );
  }

  Rect _defaultCrop(double width, double height) {
    const targetAspect = 400.0 / 300.0;

    double cropW;
    double cropH;

    if (width / height > targetAspect) {
      cropH = height * 0.8;
      cropW = cropH * targetAspect;
    } else {
      cropW = width * 0.8;
      cropH = cropW / targetAspect;
    }

    return Rect.fromLTWH(
      (width - cropW) / 2,
      (height - cropH) / 2,
      cropW,
      cropH,
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
              child: InteractiveViewer(
                minScale: 0.5,
                maxScale: 5,
                child: Stack(
                  children: [
                    Image.memory(widget.imageBytes),

                    Positioned.fill(
                      child: CropOverlay(
                        imageSize: Size(
                          decoded.width.toDouble(),
                          decoded.height.toDouble(),
                        ),
                        initialRect: cropRect,
                        aspectRatio: 400 / 300,
                        onChanged: (rect) {
                          cropRect = rect;
                        },
                      ),
                    ),
                  ],
                ),
              ),
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