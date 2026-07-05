import 'dart:async';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:inkstudio_core/inkstudio_core.dart';
import 'package:inkstudio_image/inkstudio_image.dart';
import 'package:inkstudio/app/services/ble_service.dart';
import 'package:inkstudio/app/services/dashboard_actions.dart';
import 'package:inkstudio/app/services/device_session_service.dart';
import 'package:inkstudio/app/services/image_pipeline_controller.dart';
import 'package:inkstudio/app/state/device_session_state.dart';
import 'package:inkstudio/app/widgets/common/image_preview_panel.dart';
import 'package:inkstudio/app/widgets/controls/dithering_controls.dart';
import 'package:inkstudio/app/widgets/controls/filter_controls.dart';
import 'package:inkstudio/app/widgets/controls/filter_options_controls.dart';
import 'package:inkstudio/app/widgets/controls/image_adjustment_controls.dart';
import 'package:inkstudio/app/widgets/controls/palette_bias_controls.dart';
import 'package:inkstudio/app/widgets/device/device_slot_panel.dart';
import 'package:inkstudio/app/widgets/popups/crop_dialog.dart';
import 'package:inkstudio_protocol/inkstudio_protocol.dart';

class DevWorkbenchPage extends StatefulWidget {
  final VoidCallback onToggleTheme;
  const DevWorkbenchPage({
    super.key,
    required this.onToggleTheme
  });

  @override
  State<DevWorkbenchPage> createState() => _DevWorkbenchPageState();
}

class _DevWorkbenchPageState extends State<DevWorkbenchPage> {
  final ble = BleService.instance.manager;
  final session = DeviceSessionService.instance;
  final ImagePipelineController pipeline = ImagePipelineController();

  Uint8List? _originalImageBytes;
  Uint8List? _previewBytes;

  DitherMode _ditherMode = DitherMode.floydSteinberg;
  // SwatchType _swatchType = SwatchType.noise;

  ImageAdjustments _adjustments = ImageAdjustments();
  PaletteBias _bias = PaletteBias();

  ImageFilter _filter = ImageFilter.normal;
  bool _simulateDevice = false;

  Rect? cropRect;
  int rotation = 0;

  int _processVersion = 0;

  late StreamSubscription sub;

  void updateSession(DeviceSessionState Function(DeviceSessionState current) updater) {
    setState(() { session.state = updater(session.state); });
  }

  // TODO Add swatches, etc. here

  // TODO See if we can use the "albums" to open the original image too here when pulling from device

  @override
  void initState() {
    super.initState();

    sub = ble.imageStream.stream.listen((fb) {
      if (!mounted) return;

      pipeline.framebuffer = fb;
      pipeline.previewBytes = Uint8List.fromList(
        img.encodePng(PanelRerender.renderFramebuffer(fb))
      );

      setState(() {
        session.state = session.state.copyWith(
          transfer: TransferState.idle,
          progress: 0.0,
          activeSlot: null
        );

        _previewBytes = pipeline.previewBytes!;
      });
    });

    ble.onDeviceSettings = (settings) {
      if (mounted) {
        debugPrint("DEV PAGE: onDeviceSettings, mounted");
        setState(() {
          session.state = session.state.copyWith(
            settings: settings
          );
        });
      }
    };

    ble.onUploadComplete = () {
      setState(() {
        session.state = session.state.copyWith(
          transfer: TransferState.idle,
          progress: 0
        );
      });
    };
  }

  @override
  void dispose() {
    sub.cancel();
    super.dispose();
  }

  Future<void> _prepareWorkingImage() async {
    final bytes = _originalImageBytes;
    if (bytes == null) return;

    await pipeline.prepare(bytes, cropRect, rotation);
  }

  Future<void> _reprocess() async {
    final bytes = _originalImageBytes;
    if (bytes == null) return;

    final int version = ++_processVersion;
    
    await pipeline.process(
      dither: _ditherMode,
      filter: _filter,
      simulateDevice: _simulateDevice,
      adjustments: _adjustments,
      paletteBias: _bias,
      rotation: rotation
    );

    if (version != _processVersion) return;

    setState(() {
      _previewBytes = pipeline.previewBytes!;
    });
  }

  Future<void> _loadImageBytes(Uint8List bytes) async {
    setState(() {
      if (!listEquals(_originalImageBytes, bytes)) {
        _originalImageBytes = bytes;
      }
    });

    await _prepareWorkingImage();
    await _reprocess();
  }

  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true
    );

    if (result == null || result.files.isEmpty) return;

    final bytes = result.files.first.bytes;

    if (bytes == null) return;

    await _loadImageBytes(bytes);
  }

  Future<void> _uploadImage() async {
    final fb = pipeline.framebuffer;
    if (fb == null) return;

    setState(() {
      session.state = session.state.copyWith(
        transfer: TransferState.uploading,
        progress: 0
      );
    });

    final flipped = flipVertical(fb);
    final packed = FramebufferPacker.pack(flipped);

    final packets = UploadSession.build(imageNumber: session.state.activeSlot!, packedImageData: packed);

    await ble.sendImage(packets);
    await ble.sendMd5Trigger(imageNumber: session.state.activeSlot!, imageData: packed);
  }

  Future<void> _handleCropButton() async {
    if (_originalImageBytes == null) return;
    final rect = await showDialog<Rect>(
      context: context,
      builder: (_) => CropDialog(
        imageBytes: _originalImageBytes!,
        initialRect: cropRect,
      )
    );

    if (rect != null) {
      setState(() {
        cropRect = rect;
      });
    }

    await _prepareWorkingImage();
    await _reprocess();
  }

  Future<void> _autoEnhance() async {
    final image = pipeline.sourceImage;
    if (image == null) return;
    final metrics = ImageMetrics.analyseImage(image);
    final suggested = ImageAdjustments.autoEnhance(metrics);
    setState(() {
      _adjustments = suggested;
    });
    await _reprocess();
  }

  Future<void> _handleRotateButton() async {
    setState(() {
      rotation = (rotation + 90) % 360;
    });
    await _reprocess();
  }

  // Future<void> _loadSwatch() async {
  //   final swatch = await SwatchGenerator.generate(
  //     _swatchType,
  //     width: DeviceConstants.imageWidth,
  //     height: DeviceConstants.imageHeight
  //   );
  //   final bytes = Uint8List.fromList(
  //     img.encodePng(swatch)
  //   );

  //   await _loadImageBytes(bytes);
  // }

  // Future<void> _generateNote() async {
  //   final note = NoteRenderer.render(
  //     text: _noteController.text,
  //     w: DeviceConstants.imageWidth,
  //     h: DeviceConstants.imageHeight
  //   );

  //   final bytes = Uint8List.fromList(
  //     img.encodePng(note)
  //   );

  //   await _loadImageBytes(bytes);
  // }

  Widget _leftPanel(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DeviceSlotPanel(
            onDownload: session.state.canDownload
              ? () => DashboardActions.downloadSlot(ble: ble, slot: session.state.activeSlot!, updateSession: updateSession)
              : null,
            onUpload: session.state.canTransfer
              ? _uploadImage
              : null,
            activeSlot: session.state.activeSlot,
            onSlotChanged: (slot) {
              updateSession((s) => s.copyWith(activeSlot: slot));
            },
            settings: session.state.settings
          )
        ]
      ),
    );
  }

  Widget _centerPanel(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
          children: [
            FilledButton(
              onPressed: () async {
                await _pickImage();
              },
              child: const Text('Import Image')
            ),
            const SizedBox(height: 8),
            Card(
              child: Row(
                children: [
                  Expanded(
                    child: IconButton(
                      icon: const Icon(Icons.crop),
                      tooltip: 'Crop',
                      onPressed: () async {
                        await _handleCropButton();
                      }
                    )
                  ),

                  Expanded(
                    child: IconButton(
                      icon: const Icon(Icons.rotate_90_degrees_cw),
                      tooltip: 'Rotate',
                      onPressed: () async {
                        await _handleRotateButton();
                      }
                    )
                  ),

                  Expanded(
                    child: IconButton(
                      icon: const Icon(Icons.diamond_sharp),
                      tooltip: 'Auto-Enhance',
                      onPressed: () async {
                        await _autoEnhance();
                      }
                    )
                  )
                ]
              )
            ),
            const SizedBox(height: 8),
            DitheringControls(
              selectedAlgorithm: _ditherMode,
              onAlgorithmChanged: (newAlg) async {
                setState(() {
                  _ditherMode = newAlg;
                });
                _reprocess();
              }
            ),
            const SizedBox(height: 8),
            ImageAdjustmentControls(
              adjustments: _adjustments,
              onChanged: (newAdjustments) async {
                setState(() {
                  _adjustments = newAdjustments;
                });
      
                _reprocess();
              }
            ),
            const SizedBox(height: 8),
            PaletteBiasControls(
              paletteBias: _bias,
              onChanged: (newBias) async {
                setState(() {
                  _bias = newBias;
                });
                _reprocess();
              }
            ),
            const SizedBox(height: 8),
            FilterControls(
              selectedFilter: _filter,
              onFilterChanged: (filter) async {
                setState(() {
                  _filter = filter;
                });
                _reprocess();
              }
            ),
            FilterOptionsControls(
              adjustments: _adjustments,
              filter: _filter,
              onChanged: (filtOptions) async {
                setState(() {
                  _adjustments = filtOptions;
                });
                _reprocess();
              }
            )
          ]
        ),
    )
    ;
  }

  Widget _rightPanel(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          SwitchListTile(
            title: const Text('Simulate Device Colours'),
            value: _simulateDevice,
            onChanged: (newSim) async {
              setState(() {
                _simulateDevice = newSim;
              });
              await _reprocess();
            }
          ),
          ImagePreviewPanel(title: 'Original', height: DeviceConstants.imageHeight, imageBytes: _originalImageBytes),
          ImagePreviewPanel(title: 'Preview', height: DeviceConstants.imageHeight, imageBytes: _previewBytes)
        ]
      ),
    );
  }

  List<Widget> _buildDesktopLayout(BuildContext context) {
    return [
      SingleChildScrollView(child: SizedBox(width: 300, child: _leftPanel(context))),
      SingleChildScrollView(child: SizedBox(width: 340, child: _centerPanel(context))),
      Expanded(child: SingleChildScrollView(child: _rightPanel(context)))
    ];
  }

  Widget _buildMobileLayout(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _leftPanel(context),
          _rightPanel(context),
          _centerPanel(context)
        ],
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 700;

    return Scaffold(
      appBar: AppBar(
        title: const Text('InkStudio'),
        actions: [
          IconButton(
            icon: const Icon(Icons.dark_mode),
            onPressed: widget.onToggleTheme,
          )
        ]
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: isMobile
          ? _buildMobileLayout(context)
          : Row(children: _buildDesktopLayout(context))
      ),
    );
  }
}
