import 'dart:typed_data';

import 'package:flutter/material.dart' hide ConnectionState;
import 'package:flutter_app/app/state/device_session_state.dart';
import 'package:flutter_app/app/widgets/common/image_preview_panel.dart';
import 'package:flutter_app/app/widgets/common/status_bar.dart';
import 'package:flutter_app/app/widgets/controls/dithering_controls.dart';
import 'package:flutter_app/app/widgets/controls/image_adjustment_controls.dart';
import 'package:flutter_app/app/widgets/device/device_info_card.dart';
import 'package:flutter_app/transport/ble_manager.dart';
import 'package:image/image.dart' as img;
import 'package:picpak_core/picpak_core.dart';
import 'package:picpak_image/picpak_image.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {

  DitherMode algorithm = DitherMode.atkinson;
  ImageAdjustments adjustments = ImageAdjustments(brightness: 0.0, contrast: 1.0);

  DeviceSessionState session = DeviceSessionState(connection: ConnectionState.disconnected, transfer: TransferState.idle, progress: 0.0, deviceName: 'Not Connected', batteryPercent: 0, firmware: '-');

  Uint8List? _deviceImageBytes;

  final BleManager ble = BleManager();

  @override
  void initState() {
    super.initState();

    ble.onImageDownloaded = (framebuffer) {
      final previewBytes = Uint8List.fromList(
        img.encodePng(PanelRerender.renderFramebuffer(framebuffer))
      );
      setState(() {
        _deviceImageBytes = previewBytes;
      });
    };

    ble.onDeviceInfo = (info) {
      setState(() {
        session = session.copyWith(
          batteryPercent: info.battery,
          firmware: info.firmware
        );
      });
    };
  }

  Future<void> connect() async {
    setState(() {
      session = session.copyWith(
        connection: ConnectionState.scanning
      );
    });

    final device = await ble.scanForDevice();

    if (device == null) {
      setState(() {
        session = session.copyWith(
          connection: ConnectionState.disconnected
        );
      });
      return;
    }

    setState(() {
      session = session.copyWith(connection: ConnectionState.connecting);
    });

    try {
      await ble.connect(device);
      setState(() {
        session = session.copyWith(
          connection: ConnectionState.connected,
          deviceName: device.platformName
        );
      });

      await ble.requestDeviceInfo();
    } catch (e) {
      setState(() {
        session = session.copyWith(
          connection: ConnectionState.disconnected
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PicPak Open')
      ),

      body: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                // LEFT PANEL
                SizedBox(
                  width: 300,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    color: Theme.of(context)
                      .colorScheme
                      .surfaceContainerLow,
                    child: DeviceInfoCard(state: session)
                  )
                ),

                // CENTER
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        ImagePreviewPanel(title: 'Original', height: DeviceConstants.imageHeight, imageBytes: null),
                        const SizedBox(height: 16),
                        ImagePreviewPanel(title: 'Preview', height: DeviceConstants.imageHeight, imageBytes: _deviceImageBytes)
                      ]
                    )
                  )
                ),

                // RIGHT PANEL
                SizedBox(
                  width: 340,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    color: Theme.of(context)
                      .colorScheme
                      .surfaceContainerLowest,
                    child: Column(
                      children: [
                        DitheringControls(
                          selectedAlgorithm: algorithm,
                          onAlgorithmChanged: (newAlg) {
                            setState(() {
                              algorithm = newAlg;
                            });
                          }
                        ),

                        ImageAdjustmentControls(
                          adjustments: adjustments,
                          onChanged: (newAdjustments) {
                            setState(() {
                              adjustments = newAdjustments;
                            });
                          }
                        ),
                        ElevatedButton(onPressed: connect, child: const Text('Connect')),
                        ElevatedButton(onPressed: () {
                          ble.getImageInSlot(1);
                        }, child: const Text('Download slot 1'))
                      ],
                    )
                  )
                )
              ]
            )
          ),

          // STATUS BAR
          StatusBar(state: session)
        ],
      )
    );
  }
}