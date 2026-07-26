import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:inkstudio/app/widgets/controls/sticker_editor_controls.dart';
import 'package:inkstudio/app/widgets/controls/sticker_editor_preview.dart';
import 'package:inkstudio_core/inkstudio_core.dart';
import 'package:inkstudio_image/inkstudio_image.dart';
import 'package:uuid/uuid.dart';

class StickerEditor extends StatefulWidget {
  final Uint8List backgroundBytes;
  final List<ContentOverlay> initialOverlays;

  const StickerEditor({
    super.key,
    required this.backgroundBytes,
    required this.initialOverlays
  });

  @override
  State<StickerEditor> createState() => _StickerEditorState();
}

class _StickerEditorState extends State<StickerEditor> {
  late List<ContentOverlay> overlays;

  String? selectedOverlayId;

  @override
  void initState() {
    super.initState();

    overlays = List.of(widget.initialOverlays);
  }

  ContentOverlay? get selectedOverlay {
    final id = selectedOverlayId;
    if (id == null) return null;

    for (final overlay in overlays) {
      if (overlay.id == id) {
        return overlay;
      }
    }
    return null;
  }

  void _addSticker() {
    final sticker = ContentOverlay(
      id: const Uuid().v4(),
      x: 0.4, y: 0.4,
      width: 0.2, height: 0.2,
      rotation: 0,
      colour: ProtocolPalette.red,
      data: ShapeOverlayData(
        shape: ShapeType.square,
        style: OverlayStyle.filled
      )
    );

    setState(() {
      overlays.add(sticker);
      selectedOverlayId = sticker.id;
    });
  }

  void _deleteSelected() {
    final id = selectedOverlayId;
    if (id == null) return;

    setState(() {
      overlays.removeWhere((overlay) => overlay.id == id);
      selectedOverlayId = null;
    });
  }

  void _updateOverlay(ContentOverlay updatedOverlay) {
    setState(() {
      overlays = overlays.map((overlay) {
        if (overlay.id == updatedOverlay.id) {
          return updatedOverlay;
        }
        return overlay;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: StickerEditorPreview(
                backgroundBytes: widget.backgroundBytes,
                overlays: overlays,
                selectedOverlayId: selectedOverlayId,
                onOverlaySelected: (id) {
                  setState(() {
                    selectedOverlayId = id;
                  });
                },
                onOverlayChanged: (updatedOverlay) {
                  setState(() {
                    final index = overlays.indexWhere((overlay) => overlay.id == updatedOverlay.id);
                    if (index != -1) {
                      overlays[index] = updatedOverlay;
                    }
                  });
                }
              )
            ),
            StickerEditorControls(
              selectedOverlay: selectedOverlay,
              onAddSticker: _addSticker,
              onDeleteSticker: _deleteSelected,
              onOverlayChanged: _updateOverlay,
            ),

            const SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel')
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context, List<ContentOverlay>.unmodifiable(overlays));
                  },
                  child: const Text('Done')
                )
              ],
            )
          ]
        )
      )
    );
  }
}