import 'package:flutter/material.dart';
import 'package:picpak_image/picpak_image.dart';

class ImageAdjustmentControls extends StatelessWidget {
  final ImageAdjustments adjustments;

  final ValueChanged<ImageAdjustments> onChanged;

  const ImageAdjustmentControls({
    super.key,
    required this.adjustments,
    required this.onChanged
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Image Adjustments', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 24),

            // BRIGHTNESS
            Text('Brightness', style: Theme.of(context).textTheme.titleMedium),
            ExcludeSemantics(
              child: Slider(
                value: adjustments.brightness,
                min: -1.0,
                max: 1.0,
                onChanged: (value) {
                  onChanged(adjustments.copyWith(brightness: value));
                }
              )
            ),
            Text(adjustments.brightness.toStringAsFixed(2)),
            const SizedBox(height: 24),

            // CONTRAST
            Text('Contrast', style: Theme.of(context).textTheme.titleMedium),
            ExcludeSemantics(
              child: Slider(
                value: adjustments.contrast,
                min: 0.0,
                max: 2.0,
                onChanged: (value) {
                  onChanged(adjustments.copyWith(contrast: value));
                },
              )
            ),
            Text(adjustments.contrast.toStringAsFixed(2))
          ]
        )
      )
    );
  }
}