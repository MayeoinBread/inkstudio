import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:inkstudio_image/inkstudio_image.dart';

class StickerEditorControls extends StatelessWidget {
  final ContentOverlay? selectedOverlay;

  final VoidCallback onAddSticker;
  final VoidCallback onDeleteSticker;

  const StickerEditorControls({
    super.key,
    required this.selectedOverlay,
    required this.onAddSticker,
    required this.onDeleteSticker
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          ElevatedButton.icon(
            onPressed: onAddSticker,
            icon: const Icon(Icons.add),
            label: const Text('Add Sticker')
          ),

          const SizedBox(width: 12),

          if (selectedOverlay != null)
            ElevatedButton.icon(
              onPressed: onDeleteSticker,
              icon: const Icon(Icons.delete),
              label: const Text('Delete')
            )
        ]
      )
    );
  }
}