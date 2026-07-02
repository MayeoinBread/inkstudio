import 'package:flutter/material.dart';
import 'package:picpak_image/picpak_image.dart';

class QrEditorMobileControls extends StatelessWidget {

  final TextEditingController textController;
  final TextEditingController ssidController;
  final TextEditingController passwordController;

  final QrType qrType;
  final String securityType;

  final VoidCallback onPreview;
  final VoidCallback onSave;

  final ValueChanged<QrType> onQrTypeChanged;
  final ValueChanged<String> onSecurityTypeChanged;

  const QrEditorMobileControls({
    super.key,
    required this.textController,
    required this.ssidController,
    required this.passwordController,
    required this.qrType,
    required this.securityType,
    required this.onQrTypeChanged,
    required this.onSecurityTypeChanged,
    required this.onPreview,
    required this.onSave
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DropdownButton<QrType>(
            value: qrType,
            items: const [
              DropdownMenuItem(value: QrType.text, child: Text('Text')),
              DropdownMenuItem(value: QrType.url, child: Text('URL')),
              DropdownMenuItem(value: QrType.wifi, child: Text('WiFi'))
            ],
            onChanged: (value) => onQrTypeChanged(value!)
          ),

          const SizedBox(height: 16),

          if (qrType == QrType.text || qrType == QrType.url)
            TextField(
              controller: textController,
              decoration: InputDecoration(
                labelText: qrType == QrType.url ? 'URL' : 'Text',
                border: const OutlineInputBorder()
              ),
            ),
          if (qrType == QrType.wifi)
            Column(
              children: [
                TextField(
                  controller: ssidController,
                  decoration: const InputDecoration(
                    labelText: 'SSID',
                    border: OutlineInputBorder()
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder()
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: securityType,
                  items: const [
                    DropdownMenuItem(value: 'WPA', child: Text('WPA/WPA2')),
                    DropdownMenuItem(value: 'WEP', child: Text('WEP')),
                    DropdownMenuItem(value: 'nopass', child: Text('Open Network'))
                  ],
                  onChanged: (value) => onSecurityTypeChanged(value!)
                )
              ]
            ),
          const SizedBox(height: 16),

          FilledButton(onPressed: onPreview, child: const Text('Preview')),

          const SizedBox(height: 8),

          FilledButton(onPressed: onSave, child: const Text('Save'))
        ]
      )
    );
  }
}