import 'dart:typed_data';

import 'package:flutter/material.dart' hide ConnectionState;
import 'package:flutter_app/app/services/dashboard_actions.dart';
import 'package:flutter_app/app/state/device_session_state.dart';
import 'package:flutter_app/app/widgets/common/image_preview_panel.dart';
import 'package:flutter_app/app/widgets/common/status_bar.dart';
import 'package:flutter_app/app/widgets/controls/dithering_controls.dart';
import 'package:flutter_app/app/widgets/controls/image_adjustment_controls.dart';
import 'package:flutter_app/app/widgets/device/device_actions_panel.dart';
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

  void updateSession(DeviceSessionState Function(DeviceSessionState current) updater) {
    setState(() { session = updater(session);});
  }

  @override
  void initState() {
    super.initState();

    ble.onImageDownloaded = (framebuffer) {
      final previewBytes = Uint8List.fromList(
        img.encodePng(PanelRerender.renderFramebuffer(framebuffer))
      );
      setState(() {
        _deviceImageBytes = previewBytes;
        session = session.copyWith(
          transfer: TransferState.idle,
          progress: 0,
          activeSlot: null
        );
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
                    color: Theme.of(context).colorScheme.surfaceContainerLow,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        DeviceInfoCard(state: session),
                        const SizedBox(height: 16),
                        // ElevatedButton(
                        //   onPressed: session.canConnect ? () => DashboardActions.connect(ble: ble, updateSession: updateSession) : null,
                        //   child: const Text('Connect')
                        // ),
                        // const SizedBox(height: 8),
                        // ElevatedButton(
                        //   onPressed: session.canDisconnect ? () => DashboardActions.disconnect(ble: ble, updateSession: updateSession) : null,
                        //   child: const Text('Disconnect')
                        // )
                        DeviceActionsPanel(
                          onConnect: session.canConnect
                            ? () => DashboardActions.connect(ble: ble, updateSession: updateSession)
                            : null,
                          onDisconnect: session.canDisconnect
                            ? () => DashboardActions.disconnect(ble: ble, updateSession: updateSession)
                            : null,
                          onDownload: session.canTransfer
                            ? () => DashboardActions.downloadSlot(ble: ble, slot: session.activeSlot, updateSession: updateSession)
                            : null,
                          onUpload: session.canTransfer
                            ? () {}
                            : null
                        )
                      ],
                    ),
                  ),
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
                    color: Theme.of(context).colorScheme.surfaceContainerLowest,
                    child: Column(
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.all(16),
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
                                const SizedBox(height: 16),
                                ImageAdjustmentControls(
                                  adjustments: adjustments,
                                  onChanged: (newAdjustments) {
                                    setState(() {
                                      adjustments = newAdjustments;
                                    });
                                  }
                                )
                              ]
                            )
                          )
                        ),
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