import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:inkstudio/app/widgets/library/slot_metadata.dart';

class SlotTile extends StatelessWidget {
  final Uint8List? thumbnail;

  final bool selected;

  final bool exists;

  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onClear;

  final SlotMetadata metadata;

  const SlotTile({
    super.key,
    required this.thumbnail,
    required this.selected,
    required this.exists,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    required this.onClear,
    required this.metadata
  });

  void _showMenu(BuildContext context, Offset position) async {
    final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;

    final result = await showMenu<String>(
      context: context,
      position: RelativeRect.fromRect(
        Rect.fromLTWH(position.dx, position.dy, 0, 0),
        Offset.zero & overlay.size
      ),
      items: const [
        PopupMenuItem(
          value: 'edit',
          child: Text('Add/Edit')
        ),
        PopupMenuItem(
          value: 'delete',
          child: Text('Delete from device')
        ),
        PopupMenuItem(
          value: 'clear',
          child: Text('Clear slot')
        )
      ]
    );
    if (result == 'edit') {
      Future.microtask(() => onEdit());
    } else if (result == 'delete') {
      Future.microtask(() => onDelete());
    } else if (result == 'clear') {
      Future.microtask(() => onClear());
    }
  }

  @override
  Widget build(BuildContext context) {
    final indicator = getStatusIndicator(metadata);
    return GestureDetector(
      onTap: onTap,
      onLongPressStart: (details) {_showMenu(context, details.globalPosition);},
      onSecondaryTapDown: (details) {
        _showMenu(context, details.globalPosition);
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: selected
              ? Colors.blue
              : Colors.grey,
            width: selected ? 2 : 1,
          ),
        ),
        child: Stack(
          children: [
            // SizedBox.expand(
            AspectRatio(
              aspectRatio: 1,
              child: exists && thumbnail != null
                ? Opacity(
                    opacity: metadata.pendingAction == SlotPendingAction.delete ? 0.4 : 1.0,
                    child: Image.memory(
                      thumbnail!,
                      fit: BoxFit.cover,
                      gaplessPlayback: true,
                    )
                  )
                : const Center(child: Icon(Icons.image_not_supported_outlined))
            ),
            if (indicator != null)
              Positioned(
                top: 4, right: 4,
                child: Icon(
                  indicator.icon,
                  size: indicator.size,
                  color: indicator.colour
                )
              )
          ]
        )
      )
    );
  }
}