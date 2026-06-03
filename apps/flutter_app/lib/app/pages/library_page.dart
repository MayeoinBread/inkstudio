import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_app/app/controller/library_controller.dart';
import 'package:flutter_app/app/services/ble_service.dart';
import 'package:flutter_app/app/services/device_session_service.dart';
import 'package:flutter_app/app/services/image_pipeline_controller.dart';
import 'package:flutter_app/app/state/device_session_state.dart';
import 'package:flutter_app/app/widgets/common/status_bar.dart';
import 'package:flutter_app/app/widgets/library/library_grid.dart';
import 'package:flutter_app/app/widgets/library/slot_inspector.dart';
import 'package:image/image.dart' as img;
import 'package:picpak_image/picpak_image.dart';

class LibraryPage extends StatefulWidget {

  const LibraryPage({super.key});

  @override
  State<LibraryPage> createState() =>
      _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {

  final controller = LibraryController();

  final ble = BleService.instance.manager;

  final session = DeviceSessionService.instance;

  // late final void Function(PaletteFramebuffer) _imageListener;

  void updateSession(DeviceSessionState Function(DeviceSessionState current) updater) {
    setState(() { session.state = updater(session.state);});
  }

  final ImagePipelineController pipeline = ImagePipelineController();

  late StreamSubscription sub;

  int? selectedSlot;

  double progress = 0.0;

  @override
  void initState() {
    debugPrint('Library initState');
    super.initState();

    controller.initialise(700);

    // sub = ble.imageStream.stream.listen((fb) {
    //   if (!mounted) return;

    //   setState(() {

    //   });
    // });
  }

  @override
  void dispose() {
    debugPrint('Library dispose');
    sub.cancel();
    super.dispose();
  }

  Future<void> _sync() async {
    await controller.syncLibrary(
      ble: ble,
      session: session,
      availableSlots: session.state.availableSlots,
      onSlotReady: (slot, thumb) {
        controller.updateSlot(slot: slot, exists: true, thumbnail: thumb);
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('Library build');
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {

        return Row(
          children: [

            SizedBox(
              width: 300,
              child: SlotInspector(
                onSync: _sync,
                item: selectedSlot == null
                  ? null
                  : controller.items[selectedSlot!]
              ),
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: LibraryGrid(
                  items: controller.items,
                  selectedSlot: selectedSlot,
                  onSelected: (slot) {
                    setState(() {
                      selectedSlot = slot;
                    });
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}