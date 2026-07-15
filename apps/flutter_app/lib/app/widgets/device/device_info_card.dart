import 'package:flutter/material.dart';
import 'package:inkstudio/app/state/device_session_state.dart';

class DeviceInfoCard extends StatefulWidget {
  final VoidCallback? onConnect;
  final VoidCallback? onDisconnect;

  final DeviceSessionState state;

  const DeviceInfoCard({
    super.key,
    required this.state,
    required this.onConnect,
    required this.onDisconnect
  });

  @override
  State<DeviceInfoCard> createState() => _DeviceInfoCardState();
}

class _DeviceInfoCardState extends State<DeviceInfoCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.state.deviceName,
              style: Theme.of(context).textTheme.titleLarge
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.circle, size: 12, color: widget.state.isConnected ? Colors.green : Colors.red
                ),
                const SizedBox(width: 8),
                Text(widget.state.statusText)
              ]
            ),
            const SizedBox(height: 16),
            Text('Firmware: ${widget.state.deviceInfo.firmware}'),
            Text('Battery: ${widget.state.deviceInfo.battery}%'),
            Text('Serial: ${widget.state.deviceInfo.serial}'),
            const SizedBox(height: 16),
            Text('Image Refresh Period: ${widget.state.settings.seconds}s'),
            Text('Accelerometer Enabled: ${widget.state.settings.accelerometer}'),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: widget.onConnect,
              child: const Text('Connect'),
            ),  

            const SizedBox(height: 8),

            FilledButton(
              onPressed: widget.onDisconnect,
              child: const Text('Disconnect'),
            ),
          ],
        )
      )
    );
  }
}