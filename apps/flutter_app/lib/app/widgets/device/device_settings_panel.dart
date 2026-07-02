import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:picpak_open/app/data/models/device_settings.dart';

class DeviceSettingsPanel extends StatefulWidget {
  final ValueChanged<DeviceSettings> onSettingsChanged;

  final DeviceSettings settings;

  const DeviceSettingsPanel({
    super.key,
    required this.onSettingsChanged,
    required this.settings
  });

  @override
  State<DeviceSettingsPanel> createState() => _DeviceSettingsPanelState();
}

class _DeviceSettingsPanelState extends State<DeviceSettingsPanel> {
  late final TextEditingController _refreshTextController;

  @override
  void initState() {
    super.initState();

    _refreshTextController = TextEditingController(
      text: widget.settings.seconds.toString()
    );
  }

  @override
  void didUpdateWidget(covariant DeviceSettingsPanel oldWidget) {
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
            Text('Device Settings', style: Theme.of(context).textTheme.titleMedium),
        
            const SizedBox(height: 16),
        
            TextField(
              controller: _refreshTextController,
              decoration: const InputDecoration(
                labelText: 'Refresh Seconds',
                border: OutlineInputBorder()
              ),
        
              keyboardType: TextInputType.number,
        
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly
              ]
            ),
        
            const SizedBox(height: 8),
        
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Color.fromARGB(48, 255, 128, 0),
                borderRadius: BorderRadius.circular(8)
              ),
              child: Text("Possible to set any duration, but actual usage not verified")
            ),
        
            const SizedBox(height: 16),
        
            FilledButton(
              onPressed: () {
                widget.settings.seconds = int.parse(_refreshTextController.text);
                widget.onSettingsChanged(widget.settings);
              },
              child: const Text('Set Refresh Period')
            ),
        
            const SizedBox(height: 16),
        
            Material(
              borderRadius: BorderRadius.circular(12),
              child: SwitchListTile(
                title: const Text('Accelerometer'),
                value: widget.settings.accelerometer,
                onChanged: (accel) async {
                  setState(() {
                    widget.settings.accelerometer = accel;
                  });
                  widget.onSettingsChanged(widget.settings);
                },
              )
            ),
          ],
        ),
      ),
    );
  }
}