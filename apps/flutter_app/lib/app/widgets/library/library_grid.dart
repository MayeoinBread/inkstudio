import 'package:flutter/material.dart';
import 'package:flutter_app/app/widgets/library/library_item.dart';

import 'slot_tile.dart';

class LibraryGrid extends StatelessWidget {
  final List<LibraryItem> items;
  final int? selectedSlot;
  final ValueChanged<int> onSelected;

  final void Function(int slot) onEdit;
  final Future<void> Function(int slot) onDelete;

  const LibraryGrid({
    super.key,
    required this.items,
    required this.selectedSlot,
    required this.onSelected,
    required this.onEdit,
    required this.onDelete
  });

  @override
  Widget build(BuildContext context) {

    return GridView.builder(
      itemCount: items.length,
      gridDelegate:
          const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemBuilder: (context, index) {

        final item = items[index];

        return SlotTile(
          thumbnail: item.thumbnailBytes,
          exists: item.exists,
          selected: selectedSlot == item.slot,
          metadata: item.metadata,
          onTap: () => onSelected(item.slot),
          onEdit: () => onEdit(item.slot),
          onDelete: () => onDelete(item.slot)
        );
      },
    );
  }
}