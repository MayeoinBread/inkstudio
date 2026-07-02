import 'package:flutter/material.dart';
import 'package:inkstudio_image/inkstudio_image.dart';

class DitheringControls extends StatelessWidget {
  final DitherMode selectedAlgorithm;

  final ValueChanged<DitherMode> onAlgorithmChanged;

  const DitheringControls({
    super.key,
    required this.selectedAlgorithm,
    required this.onAlgorithmChanged
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Dithering', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: DitherMode.values.map((dither) {
                  final selected = dither == selectedAlgorithm;
                  return ChoiceChip(
                    label: Text(dither.name),
                    selected: selected,
                    showCheckmark: false,
                    onSelected: (_) {
                      onAlgorithmChanged(dither);
                    },
                  );
                }).toList(),
              ),
            ],
          )
        )
      )
    );
  }
}