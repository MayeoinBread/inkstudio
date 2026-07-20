import 'dart:async';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:inkstudio/app/controller/library_controller.dart';
import 'package:inkstudio/app/data/models/editor_result.dart';
import 'package:inkstudio/app/repositories/image_repository.dart';
import 'package:inkstudio/app/services/ble_service.dart';
import 'package:inkstudio/app/services/device_session_service.dart';
import 'package:inkstudio/app/services/image_pipeline_controller.dart';
import 'package:inkstudio/app/services/thumbnail_service.dart';
import 'package:inkstudio/app/state/device_session_state.dart';
import 'package:inkstudio/app/widgets/library/album_selector.dart';
import 'package:inkstudio/app/widgets/library/library_grid.dart';
import 'package:inkstudio/app/widgets/library/library_item.dart';
import 'package:inkstudio/app/widgets/library/slot_inspector.dart';
import 'package:inkstudio/app/widgets/library/slot_metadata.dart';
import 'package:inkstudio/app/widgets/popups/content_editor_dialog.dart';
import 'package:inkstudio/app/widgets/popups/mobile_editor_layout.dart';
import 'package:inkstudio_image/inkstudio_image.dart';

class LibraryPage extends StatefulWidget {

  final VoidCallback onToggleTheme;

  const LibraryPage({
    super.key,
    required this.onToggleTheme
  });

  @override
  State<LibraryPage> createState() =>
      _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {

  final controller = LibraryController();

  final ble = BleService.instance.manager;

  final session = DeviceSessionService.instance;

  void updateSession(DeviceSessionState Function(DeviceSessionState current) updater) {
    setState(() { session.state = updater(session.state);});
  }

  final ImagePipelineController pipeline = ImagePipelineController();

  // late StreamSubscription? sub;

  int? selectedSlot;

  double progress = 0.0;

  bool _initStarted = false;

  @override
  void initState() {
    super.initState();

    // controller.init();

    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   controller.loadFromDatabase();
    // });
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();

    if (_initStarted) return;
    _initStarted = true;

    controller.init();

    await controller.refreshSyncState(session.state.deviceInfo.serial);
  }

  @override
  void dispose() {
    // sub?.cancel();
    super.dispose();
  }

  Future<void> _sync() async {
    await controller.pullFromDevice(
      ble: ble,
      // session: session,
      availableSlots: session.state.availableSlots,
      onSlotReady: (slot) async {
        controller.updateSlot(
          slot: slot,
          exists: true,
          metadata: controller.items[slot]!.metadata
        );
      }
    );

    await controller.commitAllSlots();

    await controller.refreshSyncState(session.state.deviceInfo.serial);
  }

  Future<void> _onEdit(int slot) async {
    final item = controller.items[slot];
    if (item == null) return;

    final result = await _openEditor(context, slot, item);
    if (result == null) return;

    await _handleEditorResult(slot, item, result);
  }

  Future<EditorResult?> _openEditor(
    BuildContext context, int slot, LibraryItem item
  ) {
    final isMobile = MediaQuery.sizeOf(context).width < 700;
    
    final completer = Completer<EditorResult?>();

    if (isMobile) {
      Navigator.push<EditorResult>(
        context,
        MaterialPageRoute(
          fullscreenDialog: true,
          builder: (_) => MobileEditorLayout(
            item: item,
            onSaved: (result) {
              if (!completer.isCompleted) {
                completer.complete(result);
              }
            }
          )
        )
      // ).then((routeResult) {
      //   // Optional safety: if route is popped via back button etcs
      //   if (!completer.isCompleted) {
      //     completer.complete(routeResult);
      //   }
      // }
      );

      return completer.future;
    }

    showDialog<EditorResult>(
      context: context,
      builder: (_) => Dialog(
        child: SizedBox(
          width: 900,
          height: 700,
          child: ContentEditorDialog(
            item: item,
            // onSaved: (result) => Navigator.pop(context, result),
            onSaved: (result) {
              if (!completer.isCompleted) {
                completer.complete(result);
              }
            }
          )
        )
      )
    );

    return completer.future;
  }

  Future<void> _handleEditorResult(int slot, LibraryItem item, EditorResult editorResult) async {
    final previewMd5 = md5.convert(editorResult.packedBytes).toString();

    if (item.exists) {
      final existingImage = await ImageRepository().getImage(item.metadata.imageId!);
      if (previewMd5 == existingImage?.deviceHash){
        return;
      }
    }

    final thumbnail = ThumbnailService.createFromBytes(editorResult.previewBytes);

    final image = await ImageRepository().storeImage(
      originalBytes: editorResult.originalBytes,
      thumbnailBytes: thumbnail,
      packedBytes: editorResult.packedBytes
    );

    final newMetadata = editorResult.metadata.copyWith(
      imageId: image.id,
      syncState: SlotSyncState.uploading,
      pendingAction: SlotPendingAction.upload
    );

    controller.updateSlot(
      slot: slot,
      exists: true,
      thumbnailBytes: thumbnail,
      metadata: newMetadata
    );

    await controller.commitSlot(albumId: controller.currentAlbum!.id, slot: slot);
  }

  Future<void> _onDeleteFromDevice(int slot) async {
    final item = controller.items[slot];
    final metadata = item!.metadata;

    if (!item.exists) return;

    final newAction = metadata.pendingAction == SlotPendingAction.delete
        ? SlotPendingAction.none
        : SlotPendingAction.delete;

    final updatedMetadata = metadata.copyWith(
      pendingAction: newAction,
    );

    controller.updateMetadata(slot, updatedMetadata);

    controller.commitSlot(albumId: controller.currentAlbum!.id, slot:slot);
  }

  Future<void> _onClearSlot(int slot) async {
    final item = controller.items[slot];
    
    if (item == null) return;

    if (!item.exists) return;

    controller.updateSlot(slot: slot, exists: false, metadata: SlotMetadataDefaults.empty(slot));
    controller.commitSlot(albumId: controller.currentAlbum!.id, slot: slot);
  }

  Future<void> _pickMultipleImages() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withReadStream: true,
      allowMultiple: true
    );

    if (result == null || result.files.isEmpty) return;

    final numToAdd = result.files.length;
    int addedIndex = 0;

    for (final file in result.files) {

      updateSession((s) => s.copyWith(
        progress: addedIndex.toDouble() / numToAdd,
        transfer: TransferState.importing)
      );

      final slot = controller.getNextEmptySlot();
      final bytes = await readStream(file.readStream!);

      final metadata = SlotMetadata(
        type: SlotContentType.image,
        adjustments: ImageAdjustments(),
        dither: DitherMode.atkinson,
        filter: ImageFilter.normal,
        imageId: null,
        cropRect: null,
        rotation: 0
      );

      await pipeline.prepare(bytes, null, 0);

      await pipeline.processMetadata(
        metadata: metadata,
        simulateDevice: false
      );

      final packedBytes = FramebufferPacker.pack(flipVertical(pipeline.framebuffer!));

      EditorResult mResult = EditorResult(
        metadata: metadata,
        originalBytes: bytes,
        previewBytes: pipeline.previewBytes!,
        packedBytes: packedBytes
      );

      await _handleEditorResult(slot, controller.items[slot]!, mResult);

      addedIndex += 1;
    }

    updateSession((s) => s.copyWith(
      progress: 0,
      transfer: TransferState.idle)
    );
  }

  Future<Uint8List> readStream(Stream<List<int>> stream) async {
    final builder = BytesBuilder();
    await for (final chunk in stream) {
      builder.add(chunk);
    }

    return builder.takeBytes();
  }

  void _showAlbumPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (sheetContext) {
        return ListenableBuilder(
          listenable: controller,
          builder: (context, _) {
            return AlbumSelector(
              albums: controller.albums,
              currentAlbum: controller.currentAlbum!,
              onAlbumSelected: (album) {
                controller.onAlbumSelected(album, session.state.deviceInfo.serial);
                // Navigator.pop(sheetContext);
              },
              onCreateAlbum: (name) async {
                await controller.onCreateAlbum(name);
              },
              onRenameAlbum: (id, name) async {
                await controller.onRenameAlbum(id, name);
              },
              onDeleteAlbum: (id) async {
                await controller.onDeleteAlbum(id);
              }
            );
          }
        );
      }
    );
  }

  Widget _buildGrid(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: LibraryGrid(
        items: controller.items,
        selectedSlot: selectedSlot,
        onSelected: (slot) { setState(() => selectedSlot = slot);},
        onEdit: _onEdit, onDeleteFromDevice: _onDeleteFromDevice,
        onClearSlot: _onClearSlot)
    );
  }

  Widget _buildDesktopSidebar(BuildContext context) {
    return SizedBox(
      width: 200,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          AlbumSelector(
            albums: controller.albums,
            currentAlbum: controller.currentAlbum!,
            onAlbumSelected: (album) {
              controller.onAlbumSelected(album, session.state.deviceInfo.serial);
            }, 
            onCreateAlbum: controller.onCreateAlbum,
            onRenameAlbum: controller.onRenameAlbum,
            onDeleteAlbum: controller.onDeleteAlbum
          ),
          SlotInspector(item: selectedSlot == null ? null : controller.items[selectedSlot], onSync: _sync),
          FilledButton(
            onPressed: session.state.isConnected
              ? () async {await controller.pushToDevice(ble: ble, session: session);}
              : null,
            child: const Text('Push Updates')),
          FilledButton(
            onPressed: () async {
              final deleted = await ImageRepository().cleanupUnusedImages();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Deleted $deleted unused images'))
                );
              }
            },
            child: const Text('Cleanup Storage')
          )
        ]
      )
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Row (
      children: [
        _buildDesktopSidebar(context),
        Expanded(child: _buildGrid(context))
      ]
    );
  }

  Widget _buildMobileLayout(BuildContext context ) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: LibraryGrid(
        items: controller.items,
        selectedSlot: selectedSlot,
        onSelected: (slot) {
          setState(() => selectedSlot = slot);
          if (controller.items[slot] != null) {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              useSafeArea: true,
              builder: (_) {
                return FractionallySizedBox(
                  heightFactor: 0.4,
                  child: SlotInspector(item: controller.items[slot], onSync: _sync)
                );
              }
            );
          }
        },
        onEdit: _onEdit,
        onDeleteFromDevice: _onDeleteFromDevice,
        onClearSlot: _onClearSlot
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.sizeOf(context).width < 700;

    return Scaffold(
      appBar: AppBar(
        title: const Text('InkStudio'),
        actions: [
          IconButton(
            icon: const Icon(Icons.image_search_outlined),
            onPressed: () async {
              await _pickMultipleImages();
            }
          ),
          IconButton(
            icon: const Icon(Icons.folder_open),
            onPressed: () {
              _showAlbumPicker(context);
            }
          ),
          IconButton(
            icon: const Icon(Icons.dark_mode),
            onPressed: widget.onToggleTheme
          ),
          IconButton(
            icon: const Icon(Icons.sync_rounded),
            onPressed: session.state.isConnected
              ? _sync
              : null,
          )
        ]
      ),
      body: ListenableBuilder(
        listenable: controller,
        builder: (context, _) {
          if (!controller.initialised) {
            return const Center(
              child: CircularProgressIndicator()
            );
          }
          return isMobile
            ? _buildMobileLayout(context)
            : Scaffold(
                body: _buildDesktopLayout(context)
              );
        },
      ),
      floatingActionButton: isMobile
        ? ble.bleSession.isConnected
          ? FloatingActionButton.extended(
              onPressed: () async {
                await controller.pushToDevice(ble: ble, session: session);
              },
              icon: const Icon(Icons.upload),
              label: const Text('Push')
            )
          : null
        : null
    );
  }
} 