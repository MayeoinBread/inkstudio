import 'package:flutter/material.dart';
import 'package:inkstudio_core/inkstudio_core.dart';
import 'package:inkstudio_image/inkstudio_image.dart';

class StickerEditorControls extends StatelessWidget {
  final ContentOverlay? selectedOverlay;

  final VoidCallback onAddSticker;
  final VoidCallback onDeleteSticker;

  final ValueChanged<ContentOverlay> onOverlayChanged;

  const StickerEditorControls({
    super.key,
    required this.selectedOverlay,
    required this.onAddSticker,
    required this.onDeleteSticker,
    required this.onOverlayChanged,
  });

  ShapeOverlayData? get _shapeData {
    final data = selectedOverlay?.data;

    if (data is ShapeOverlayData) return data;

    return null;
  }

  void _updateData(
    ShapeOverlayData data,
  ) {
    final overlay = selectedOverlay;

    if (overlay == null) return;

    onOverlayChanged(overlay.copyWith(data: data));
  }

  void _updateColour(
    ProtocolPaletteColour colour,
  ) {
    final overlay = selectedOverlay;

    if (overlay == null) return;

    onOverlayChanged(overlay.copyWith(colour: colour));
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 700;

    final data = _shapeData;
    final hasSelection = selectedOverlay != null && data != null;

    if (isMobile) {
      return Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            ElevatedButton.icon(
              onPressed: onAddSticker,
              icon: const Icon(Icons.add),
              label: const Text('Add Sticker'),
            ),
            SegmentedButton<OverlayStyle>(
              segments: const [
                ButtonSegment(
                  value: OverlayStyle.filled,
                  label: Text('Filled'),
                  icon: Icon(
                    Icons.format_color_fill,
                  ),
                ),
                ButtonSegment(
                  value: OverlayStyle.outline,
                  label: Text('Outline'),
                  icon: Icon(
                    Icons.border_style,
                  ),
                ),
              ],
              selected: {
                data?.style ?? OverlayStyle.filled
              },
              onSelectionChanged: hasSelection
                ? (selection) {
                    _updateData(data.copyWith(style: selection.first));
                  }
                : null
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                DropdownButton<ShapeType>(
                  value: hasSelection ? data.shape : null,
                  onChanged: hasSelection
                    ? (shape) {
                        if (shape == null) return;
                        _updateData(data.copyWith(shape: shape));
                      }
                    : null,
                  items: ShapeType.values.map(
                    (shape) {
                      return DropdownMenuItem(
                        value: shape,
                        child: Text(shape.name),
                      );
                    },
                  ).toList(),
                ),
                const SizedBox(width: 12),
                DropdownButton<ProtocolPaletteColour>(
                  value: hasSelection ? selectedOverlay!.colour : null,
                  hint: const Text('Colour'),
                  onChanged: hasSelection
                    ? (colour) {
                        if (colour == null) return;
                        _updateColour(colour);
                      }
                    : null,
                  items: ProtocolPalette.all.map(
                    (colour) {
                      return DropdownMenuItem(
                        value: colour,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                color: ProtocolPalette.colorFromPalette(
                                  ProtocolPalette.paletteFromIndex(colour.index.index)
                                ),
                                border: Border.all(
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(colour.name),
                          ],
                        ),
                      );
                    },
                  ).toList(),
                ),
              ]
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Line Thickness:'),
                SizedBox(
                  width: 200,
                  child: Slider(
                    value: (data?.strokeWidth ?? 1.0).clamp(1.0, 10.0),
                    min: 1.0,
                    max: 10.0,
                    divisions: 9,
                    label: '${(data?.strokeWidth ?? 1.0).round()} px',
                    onChanged: hasSelection
                      ? (value) {
                          _updateData(data.copyWith(strokeWidth: value));
                        }
                      : null
                  )
                ),
              ],
            ),

            ElevatedButton.icon(
              onPressed: onDeleteSticker,
              icon: const Icon(Icons.delete),
              label: const Text('Delete'),
            ),
          ],
        )
      );
    } else {
      return Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              onPressed: onAddSticker,
              icon: const Icon(Icons.add),
              label: const Text('Add Sticker'),
            ),
            const SizedBox(width: 12),
            SegmentedButton<OverlayStyle>(
              segments: const [
                ButtonSegment(
                  value: OverlayStyle.filled,
                  label: Text('Filled'),
                  icon: Icon(
                    Icons.format_color_fill,
                  ),
                ),
                ButtonSegment(
                  value: OverlayStyle.outline,
                  label: Text('Outline'),
                  icon: Icon(
                    Icons.border_style,
                  ),
                ),
              ],
              selected: {
                data?.style ?? OverlayStyle.filled
              },
              onSelectionChanged: hasSelection
                ? (selection) {
                    _updateData(data.copyWith(style: selection.first));
                  }
                : null
            ),
            const SizedBox(width: 12),
            DropdownButton<ShapeType>(
              value: hasSelection ? data.shape : null,
              onChanged: hasSelection
                ? (shape) {
                    if (shape == null) return;
                    _updateData(data.copyWith(shape: shape));
                  }
                : null,
              items: ShapeType.values.map(
                (shape) {
                  return DropdownMenuItem(
                    value: shape,
                    child: Text(shape.name),
                  );
                },
              ).toList(),
            ),
            const SizedBox(width: 12),
            DropdownButton<ProtocolPaletteColour>(
              value: hasSelection ? selectedOverlay!.colour : null,
              hint: const Text('Colour'),
              onChanged: hasSelection
                ? (colour) {
                    if (colour == null) return;
                    _updateColour(colour);
                  }
                : null,
              items: ProtocolPalette.all.map(
                (colour) {
                  return DropdownMenuItem(
                    value: colour,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: ProtocolPalette.colorFromPalette(
                              ProtocolPalette.paletteFromIndex(colour.index.index)
                            ),
                            border: Border.all(
                              color: Colors.grey,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(colour.name),
                      ],
                    ),
                  );
                },
              ).toList(),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Line Thickness:'),
                SizedBox(
                  width: 200,
                  child: Slider(
                    value: (data?.strokeWidth ?? 1.0).clamp(1.0, 10.0),
                    min: 1.0,
                    max: 10.0,
                    divisions: 9,
                    label: '${(data?.strokeWidth ?? 1.0).round()} px',
                    onChanged: hasSelection
                      ? (value) {
                          _updateData(data.copyWith(strokeWidth: value));
                        }
                      : null
                  )
                ),
              ],
            ),

            ElevatedButton.icon(
              onPressed: onDeleteSticker,
              icon: const Icon(Icons.delete),
              label: const Text('Delete'),
            ),
          ],
        )
      );
    }
  }
}