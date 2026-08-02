import 'package:flutter/material.dart';
import 'package:inkstudio_image/inkstudio_image.dart';

class DitherOptionsControls extends StatelessWidget {
  final DitherMode ditherMode;
  final DitherOptions ditherOptions;

  final ValueChanged<DitherOptions> onChanged;

  const DitherOptionsControls({
    super.key,
    required this.ditherMode,
    required this.ditherOptions,
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
            Text('Dither Options', style: Theme.of(context).textTheme.titleMedium),

            Row(
              children: [
                SizedBox(
                  width: 70,
                  child: Text('Serpentine scan', style: Theme.of(context).textTheme.bodySmall),
                ),
                Expanded(
                  child: Checkbox(
                    value: ditherOptions.serpentine,
                    onChanged: (ditherMode == DitherMode.atkinson || ditherMode == DitherMode.adaptiveAtkinson || ditherMode == DitherMode.burkes
                                || ditherMode == DitherMode.floydSteinberg || ditherMode == DitherMode.jjn || ditherMode == DitherMode.sierra
                                || ditherMode == DitherMode.sierraLite || ditherMode == DitherMode.stucki)
                    ? (value) {
                      onChanged(ditherOptions.copyWith(serpentine: value));
                    }
                    : null
                  )
                )
              ],
            ),

            Row(
              children: [
                SizedBox(
                  width: 70,
                  child: Text('Error Strength', style: Theme.of(context).textTheme.bodySmall)
                ),
                Expanded(
                  child: Slider(
                    min: 0.0, max: 1.2, divisions: 24,
                    value: ditherOptions.errorStrength,
                    label: ditherOptions.errorStrength.toStringAsFixed(2),
                    onChanged: (ditherMode == DitherMode.burkes || ditherMode == DitherMode.floydSteinberg || ditherMode == DitherMode.jjn
                                || ditherMode == DitherMode.sierra || ditherMode == DitherMode.sierraLite || ditherMode == DitherMode.stucki
                                || ditherMode == DitherMode.atkinson || ditherMode == DitherMode.adaptiveAtkinson)
                    ? (value) {
                        onChanged(ditherOptions.copyWith(errorStrength: value));
                      }
                    : null,
                  )
                )
              ],
            ),

            Row(
              children: [
                SizedBox(
                  width: 70,
                  child: Text('Ordered Size', style: Theme.of(context).textTheme.bodySmall)
                ),
                Expanded(
                  child: Wrap(
                    spacing: 8,
                    children: [2, 4, 8].map((size) {
                      return ChoiceChip(
                        label: Text('${size}x$size'),
                        selected: ditherOptions.orderedMatrixSize == size,
                        onSelected: ditherMode == DitherMode.ordered
                        ? (selected) {
                            if (!selected) return;

                            onChanged(ditherOptions.copyWith(orderedMatrixSize: size));
                          }
                        : null);
                    }).toList()
                  )
                )
              ],
            ),

            Row(
              children: [
                SizedBox(
                  width: 70,
                  child: Text('Ordered Strength', style: Theme.of(context).textTheme.bodySmall)
                ),
                Expanded(
                  child: Slider(
                    value: ditherOptions.orderedStrength.toDouble(),
                    min: 0,
                    max: 100,
                    divisions: 20,
                    label: ditherOptions.orderedStrength.round().toString(),
                    onChanged: ditherMode == DitherMode.ordered
                      ? (value) {
                        onChanged(ditherOptions.copyWith(orderedStrength: value.toInt()));
                      }
                      : null,
                  )
                )
              ]
            ),

            Row(
              children: [
                SizedBox(
                  width: 70,
                  child: Text('Smooth Area Diffusion', style: Theme.of(context).textTheme.bodySmall)
                ),
                Expanded(
                  child: Slider(
                    value: ditherOptions.smoothAreaDiffusion,
                    min: 0.0,
                    max: 1.0,
                    divisions: 20,
                    label: ditherOptions.smoothAreaDiffusion.toStringAsFixed(2),
                    onChanged: ditherMode == DitherMode.adaptiveAtkinson
                      ? (value) {
                        onChanged(ditherOptions.copyWith(smoothAreaDiffusion: value));
                      }
                      : null,
                  )
                )
              ]
            ),

            Row(
              children: [
                SizedBox(
                  width: 70,
                  child: Text('Edge Detection', style: Theme.of(context).textTheme.bodySmall)
                ),
                Expanded(
                  child: Slider(
                    value: ditherOptions.edgeDetectionThreshold,
                    min: 0.05,
                    max: 0.4,
                    divisions: 8,
                    label: ditherOptions.edgeDetectionThreshold.toStringAsFixed(2),
                    onChanged: ditherMode == DitherMode.adaptiveAtkinson
                      ? (value) {
                        onChanged(ditherOptions.copyWith(edgeDetectionThreshold: value));
                      }
                      : null,
                  )
                )
              ]
            )
          ],
        )
      )
    );
  }
}