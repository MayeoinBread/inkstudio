import 'package:flutter/material.dart';

class DeviceActionsPanel extends StatelessWidget {
  final VoidCallback? onConnect;
  final VoidCallback? onDisconnect;
  final VoidCallback? onDownload;
  final VoidCallback? onUpload;

  const DeviceActionsPanel({
    super.key,
    required this.onConnect,
    required this.onDisconnect,
    required this.onDownload,
    required this.onUpload,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton(
          onPressed: onConnect,
          child: const Text('Connect'),
        ),

        const SizedBox(height: 8),

        ElevatedButton(
          onPressed: onDisconnect,
          child: const Text('Disconnect'),
        ),

        const SizedBox(height: 24),

        ElevatedButton(
          onPressed: onDownload,
          child: const Text('Download Slot 1'),
        ),

        const SizedBox(height: 8),

        ElevatedButton(
          onPressed: onUpload,
          child: const Text('Upload'),
        ),
      ],
    );
  }
}