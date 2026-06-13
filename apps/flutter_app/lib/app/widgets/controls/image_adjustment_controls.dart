import 'package:flutter/material.dart';
import 'package:picpak_image/picpak_image.dart';

class ImageAdjustmentControls extends StatelessWidget {
  final ImageAdjustments adjustments;
  final ImageFilter filter;

  final ValueChanged<ImageAdjustments> onChanged;

  const ImageAdjustmentControls({
    super.key,
    required this.adjustments,
    required this.filter,
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
            Slider(
              min: -1.0, max: 1.0, divisions: 20,
              value: adjustments.brightness,
              label: adjustments.brightness.toStringAsFixed(2),
              onChanged: (value) {
                onChanged(adjustments.copyWith(brightness: value));
              },
            ),

            const SizedBox(height: 16),

            // CONTRAST
            Text('Contrast', style: Theme.of(context).textTheme.titleMedium),
            Slider(
              min: 0.0, max: 2.0, divisions: 20,
              value: adjustments.contrast,
              label: adjustments.contrast.toStringAsFixed(2),
              onChanged: (value) {
                onChanged(adjustments.copyWith(contrast: value));
              },
            ),
            
            const SizedBox(height: 16),

            Text('Saturation', style: Theme.of(context).textTheme.titleMedium),
            Slider(
              min: 0.0, max: 2.0, divisions: 20,
              value: adjustments.saturation,
              label: adjustments.saturation.toStringAsFixed(2),
              onChanged: (value) {
                onChanged(adjustments.copyWith(saturation: value));
              },
            ),

            const SizedBox(height: 16),

            Text('Sharpen', style: Theme.of(context).textTheme.titleMedium),
            Slider(
              min: 0.0, max: 2.0, divisions: 20,
              value: adjustments.sharpen,
              onChanged: (value) {
                onChanged(adjustments.copyWith(sharpen: value));
              }
            ),

            const SizedBox(height: 16),

            Text('Tone Levels'),
            Slider(
              min: 2.0, max: 8.0, divisions: 12,
              value: adjustments.toneLevels,
              label: adjustments.toneLevels.toStringAsFixed(2),
              onChanged: (filter == ImageFilter.comic || filter == ImageFilter.posterise)
                ? (value) {
                  onChanged(adjustments.copyWith(toneLevels: value));
                }
                : null,
            ),

            const SizedBox(height: 16),

            Text('Comic Strength'),
            Slider(
              min: 0.5, max: 2.0, divisions: 6,
              value: adjustments.comicStrength,
              label: adjustments.comicStrength.toStringAsFixed(2),
              onChanged: filter == ImageFilter.comic
                ? (value) {
                  onChanged(adjustments.copyWith(comicStrength: value));
                }
                : null,
            ),

            const SizedBox(height: 16),

            Text('Ink Thickness'),
            Slider(
              min: 0.0, max: 3.0, divisions: 12,
              value: adjustments.inkThickness,
              label: adjustments.inkThickness.toStringAsFixed(2),
              onChanged: filter == ImageFilter.comic
                ? (value) {
                  onChanged(adjustments.copyWith(inkThickness: value));
                }
                : null,
            )
          ]
        )
      )
    );
  }
}