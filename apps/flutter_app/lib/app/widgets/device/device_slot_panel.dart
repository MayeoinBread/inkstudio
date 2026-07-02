import 'package:flutter/material.dart';
import 'package:picpak_open/app/data/models/device_settings.dart';
import 'package:picpak_open/app/widgets/controls/slot_input_field.dart';

class DeviceSlotPanel extends StatefulWidget {
  final VoidCallback? onDownload;
  final VoidCallback? onUpload;

  final int? activeSlot;
  final ValueChanged<int?> onSlotChanged;

  final DeviceSettings settings;

  const DeviceSlotPanel({
    super.key,
    required this.onDownload,
    required this.onUpload,
    required this.activeSlot,
    required this.onSlotChanged,
    required this.settings
  });

  @override
  State<DeviceSlotPanel> createState() => _DeviceSlotPanelState();
}

class _DeviceSlotPanelState extends State<DeviceSlotPanel> {
  late final TextEditingController _refreshTextController;

  @override
  void initState() {
    super.initState();

    _refreshTextController = TextEditingController(
      text: widget.settings.seconds.toString()
    );
  }

  @override
  void didUpdateWidget(covariant DeviceSlotPanel oldWidget) {
    super.didUpdateWidget(oldWidget);

    final newText = widget.settings.seconds.toString();

    if (_refreshTextController.text != newText) {
      _refreshTextController.text = newText;
    }
  }

  @override
  void dispose() {
    _refreshTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Slot Number', style: Theme.of(context).textTheme.titleMedium),
        
            const SizedBox(height: 16),
        
            SlotInputField(value: widget.activeSlot, onChanged: widget.onSlotChanged),
        
            const SizedBox(height: 24),
        
            FilledButton(
              onPressed: widget.onDownload,
              child: Text('Download')
            ),
        
            const SizedBox(height: 8),
        
            FilledButton(
              onPressed: widget.onUpload,
              child: const Text('Upload'),
            )
          ],
        ),
      ),
    );
  }
}