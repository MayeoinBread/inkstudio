import 'package:flutter/material.dart';
import 'package:picpak_image/picpak_image.dart';

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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Dithering', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            DropdownButtonFormField<DitherMode>(
              initialValue: selectedAlgorithm,
              decoration: const InputDecoration(
                labelText: 'Algorithm',
                border: OutlineInputBorder()
              ),
              items: DitherMode.values.map((alg) {
                return DropdownMenuItem(
                  value: alg,
                  child: Text(alg.name)
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  onAlgorithmChanged(value);
                }
              },
            )
          ],
        )
      )
    );
  }
}