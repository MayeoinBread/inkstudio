import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:picpak_open/app/data/models/editor_result.dart';
import 'package:picpak_open/app/services/image_pipeline_controller.dart';
import 'package:picpak_open/app/widgets/common/image_preview_panel.dart';
import 'package:picpak_open/app/widgets/controls/qr_editor_mobile_controls.dart';
import 'package:picpak_open/app/widgets/library/library_item.dart';
import 'package:picpak_open/app/widgets/library/slot_metadata.dart';
import 'package:image/image.dart' as img;
import 'package:picpak_core/picpak_core.dart';
import 'package:picpak_image/picpak_image.dart';

class QrCodeTab extends StatefulWidget {
  final LibraryItem item;

  final void Function(
    EditorResult editorResult
  ) onSaved;

  final ValueChanged<Uint8List>? onPreviewChanged;

  const QrCodeTab({
    super.key,
    required this.item,
    required this.onSaved,
    this.onPreviewChanged
  });

  @override
  State<QrCodeTab> createState() => _QrCodeTabState();
}

class _QrCodeTabState extends State<QrCodeTab> {
  QrType qrType = QrType.text;

  late final TextEditingController textController;
  late final TextEditingController ssidController;
  late final TextEditingController passwordController;

  String securityType = 'WPA';

  Uint8List? previewBytes;

  final ImagePipelineController pipeline = ImagePipelineController();

  @override
  void initState() {
    super.initState();
    textController = TextEditingController(
      text: widget.item.metadata.type == SlotContentType.qr ? widget.item.metadata.text ?? '' : ''
    );
    ssidController = TextEditingController(
      text: widget.item.metadata.wifiSsid ?? ''
    );
    passwordController = TextEditingController(
      text: widget.item.metadata.wifiPassword ?? ''
    );
    securityType = widget.item.metadata.wifiSecurity ?? 'WPA';
  }

  String _generatePayloadString() {
    String payload;
    switch (qrType) {
      case QrType.text:
        payload = textController.text;
        break;
      case QrType.url:
        payload = textController.text;
        break;
      case QrType.wifi:
        payload =
          'WIFI:'
          'T:$securityType;'
          'S:${ssidController.text};'
          'P:${passwordController.text};;';
        break;
      case QrType.none:
        payload = '';
        break;
    }

    return payload;
  }

  void _generatePreview() {
    final image = QrRenderer.render(
      data: _generatePayloadString()
    );

    setState(() {
      previewBytes = Uint8List.fromList(img.encodePng(image));
    });
    widget.onPreviewChanged?.call(previewBytes!);
  }

  void _save() async {
    final image = QrRenderer.render(
      data: _generatePayloadString()
    );

    previewBytes = Uint8List.fromList(img.encodePng(image));

    final metadata = SlotMetadata(
      type: SlotContentType.qr,
      pendingAction: SlotPendingAction.upload,
      qrType: qrType,
      text: (qrType == QrType.text || qrType == QrType.url) ? textController.text : null,
      wifiSsid: (qrType == QrType.wifi) ? ssidController.text : null,
      wifiPassword: (qrType == QrType.wifi) ? passwordController.text : null,
      wifiSecurity: (qrType == QrType.wifi) ? securityType : null,
    );

    await pipeline.prepare(previewBytes!, FitStrategy.crop, null);
    await pipeline.processMetadata(metadata: metadata);
    final packedBytes = FramebufferPacker.pack(pipeline.framebuffer!);

    final edRes = EditorResult(
      metadata: metadata,
      originalBytes: null,
      previewBytes: previewBytes!,
      packedBytes: packedBytes
    );

    widget.onSaved(edRes);
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 700;

    if (isMobile) {
      return QrEditorMobileControls(
        textController: textController,
        ssidController: ssidController,
        passwordController: passwordController,
        qrType: qrType,
        securityType: securityType,
        onQrTypeChanged: onQrTypeChanged,
        onSecurityTypeChanged: onSecurityTypeChanged,
        onPreview: _generatePreview,
        onSave: () {
          _save();
          Navigator.pop(context);
        }
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  
                  DropdownButton<QrType>(
                    value: qrType,
                    items: const [
                      DropdownMenuItem(value: QrType.text, child: Text('Text')),
                      DropdownMenuItem(value: QrType.url, child: Text('URL')),
                      DropdownMenuItem(value: QrType.wifi, child: Text('WiFi'))
                    ],
                    onChanged: (value) {
                      setState(() {
                        qrType = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  if (qrType == QrType.text || qrType == QrType.url)
                    TextField(
                      controller: textController,
                      decoration: InputDecoration(
                        labelText: qrType == QrType.url
                          ? 'URL' : 'Text',
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
                          onChanged: (value) {
                            setState(() {
                              securityType = value!;
                            });
                          }
                        )
                      ],
                    ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FilledButton(onPressed: _generatePreview, child: const Text('Preview')),
                      const SizedBox(width:8),
                      FilledButton(
                        onPressed: () async {
                          _save();
                          Navigator.pop(context);
                        },
                        child: const Text('Save')
                      )
                    ]
                  )
                ]
              )
            )
          ),
          const SizedBox(width: 16),

          Expanded(
            child: previewBytes == null
              ? const Center(child: Text('No Preview'))
              : ImagePreviewPanel(height: DeviceConstants.imageHeight, imageBytes: previewBytes!)
          )
        ]
      )
    );
  }
  
  void onQrTypeChanged(QrType value) {
    setState(() {
      qrType = value;
    });
  }
  
  void onSecurityTypeChanged(String value) {
    setState(() {
      securityType = value;
    });
  }
}
