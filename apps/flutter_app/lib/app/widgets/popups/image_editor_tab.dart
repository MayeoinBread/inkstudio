import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:inkstudio/app/data/models/editor_result.dart';
import 'package:inkstudio/app/repositories/image_repository.dart';
import 'package:inkstudio/app/services/image_pipeline_controller.dart';
import 'package:inkstudio/app/widgets/common/image_preview_panel.dart';
import 'package:inkstudio/app/widgets/controls/dithering_controls.dart';
import 'package:inkstudio/app/widgets/controls/filter_options_controls.dart';
import 'package:inkstudio/app/widgets/controls/image_adjustment_controls.dart';
import 'package:inkstudio/app/widgets/controls/image_editor_mobile_controls.dart';
import 'package:inkstudio/app/widgets/controls/palette_bias_controls.dart';
import 'package:inkstudio/app/widgets/controls/filter_controls.dart';
import 'package:inkstudio/app/widgets/library/library_item.dart';
import 'package:inkstudio/app/widgets/library/slot_metadata.dart';
import 'package:inkstudio_core/inkstudio_core.dart';
import 'package:inkstudio_image/inkstudio_image.dart';
import 'package:inkstudio/app/widgets/popups/crop_dialog.dart';

class ImageEditorTab extends StatefulWidget {
  final LibraryItem item;

  final void Function(
    EditorResult editorResult
  ) onSaved;

  final ValueChanged<Uint8List>? onPreviewChanged;

  const ImageEditorTab({
    super.key,
    required this.item,
    required this.onSaved,
    this.onPreviewChanged
  });

  @override
  State<ImageEditorTab> createState() => _ImageEditorTabState();
}

class _ImageEditorTabState extends State<ImageEditorTab> {
  Uint8List? _originalImageBytes;
  Uint8List? previewBytes;

  int _processVersion = 0;

  bool pipelinePrepared = false;

  final ImagePipelineController pipeline = ImagePipelineController();

  // Image Adjustments/Dithering, etc.
  DitherMode algorithm = DitherMode.atkinson;
  ImageAdjustments adjustments = ImageAdjustments();
  PaletteBias paletteBias = PaletteBias();
  ImageFilter _filter = ImageFilter.normal;
  bool _simulateDeviceScreen = false;
  Rect? cropRect;
  int rotation = 0;

  @override
  void initState() {
    super.initState();
    // TODO can we just load the processed bytes directly into the frame, rather than setting up the processing pipeline immediately?

    _hydrateFromItem();
  }

  Future<void> _hydrateFromItem() async {
    // pipeline.clear();
    final item = widget.item;

    final metadata = item.metadata;

    final imageId = metadata.imageId;
    if (imageId == null) return;

    setState(() {
      algorithm = metadata.dither;
      adjustments = metadata.adjustments;
      _filter = metadata.filter;
      cropRect = metadata.cropRect;
      rotation = metadata.rotation;
    });

    // Reload the existing, processed image instead of reprocessing from scratch (ever so slightly faster on mobile)
    _originalImageBytes = await ImageRepository().loadOriginalBytes(imageId);
    if (_originalImageBytes == null) return;
    final processedBytes = await ImageRepository().loadProcessedBytes(imageId);
    final decodedBuffer = FramebufferDecoder.decode(processedBytes!);
    final decodedBytes = PanelRerender.renderFramebuffer(decodedBuffer);
    setState(() {
      widget.onPreviewChanged?.call(Uint8List.fromList(img.encodePng(decodedBytes)));
    });
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

  Future<void> _loadImageBytes(Uint8List bytes) async {
    setState(() {
      if (!listEquals(_originalImageBytes, bytes)) {
        _originalImageBytes = bytes;
      }
    });

    await _prepareWorkingImage();
    await _reprocess();
  }

  Future<void> _prepareWorkingImage() async {
    final bytes = _originalImageBytes;
    if (bytes == null) return;

    await pipeline.prepare(bytes, cropRect, rotation);
  }

  Future<void> _reprocess() async {
    // Need to make sure the pipeline is set up before we try processing any adjustments
    if (!pipelinePrepared) {
      await _prepareWorkingImage();
      pipelinePrepared = true;
    }
    final bytes = _originalImageBytes;
    if (bytes == null) return;

    final int version = ++_processVersion;

    await pipeline.process(
      dither: algorithm,
      filter: _filter,
      simulateDevice: _simulateDeviceScreen,
      adjustments: adjustments,
      paletteBias: paletteBias
    );

    if (version != _processVersion) return;

    setState((){
      widget.onPreviewChanged?.call(pipeline.previewBytes!);
    });
  }

  void _save() async {
    // Maybe we don't need this, but maybe we keep it just in case timing was an issue?
    await pipeline.process(
      dither: algorithm,
      filter: _filter,
      simulateDevice: _simulateDeviceScreen,
      adjustments: adjustments,
      paletteBias: paletteBias
    );

    final item = widget.item;
    final metadata = item.metadata;

    final retMetadata = SlotMetadata(
      type: SlotContentType.image,
      pendingAction: SlotPendingAction.verifyHash,
      adjustments: adjustments,
      dither: algorithm,
      filter: _filter,
      imageId: metadata.imageId,
      cropRect: cropRect,
      rotation: rotation
    );

    // packedBytes should match what is being sent to the device, which is the flipped image
    final packedBytes = FramebufferPacker.pack(flipVertical(pipeline.framebuffer!));

    final res = EditorResult(
      metadata: retMetadata,
      originalBytes: _originalImageBytes!,
      previewBytes: pipeline.previewBytes!,
      packedBytes: packedBytes);

    widget.onSaved(res);
  }

  Future<void> _autoEnhance() async {
    final image = pipeline.sourceImage;
    if (image == null) return;
    final metrics = ImageMetrics.analyseImage(image);
    final suggested = ImageAdjustments.autoEnhance(metrics);
    setState(() {
      adjustments = suggested;
    });
    await _reprocess();
  }

  Future<void> _handleRotateButton() async {
    setState(() {
      rotation = (rotation + 90) % 360;
    });
    debugPrint("Rotation: $rotation");
    await _prepareWorkingImage();
    await _reprocess();
  }

  Future<void> _handleCropButton() async {
    if (_originalImageBytes == null) return;
    final rect = await showDialog<Rect>(
      context: context,
      builder: (_) => CropDialog(
        imageBytes: _originalImageBytes!,
        initialRect: cropRect,
        rotation: rotation
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

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 700;

    if (isMobile) {
      return ImageEditorMobileControls(
        alg: algorithm,
        adjustments: adjustments,
        bias: paletteBias,
        filter: _filter,
        simulateDevice: _simulateDeviceScreen,
        onAlgChanged: (newAlg) async {
          setState(() {
            algorithm = newAlg;
          });
          _reprocess();
        },
        onAdjustmentsChanged: (newAdjustments) async {
          setState(() {
            adjustments = newAdjustments;
          });
          _reprocess();
        },
        onPaletteBiasChanged: (newBias) async {
          setState(() {
            paletteBias = newBias;
          });
          _reprocess();
        },
        onFilterChanged: (newFilter) async {
          setState(() {
            _filter = newFilter;
          });
          _reprocess();
        },
        onSimulateDeviceChanged: (newSim) async {
          setState(() {
            _simulateDeviceScreen = newSim;
          });
          _reprocess();
        },
        onAutoEnhanceSelected: () async {
          await _autoEnhance();
        },
        onRotateSelected: () async {
          await _handleRotateButton();
        },
        onCropSelected: () => _handleCropButton(),
        onLoadImageSelected: _pickImage,
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
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(8),
              child: Column(
                children: [
                  FilledButton(
                    onPressed: _pickImage,
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
                            },
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
                      ],
                    )
                  ),

                  const SizedBox(height: 8),
                  
                  ImageAdjustmentControls(
                    adjustments: adjustments,
                    onChanged: (newAdjustments) async {
                      setState(() {
                        adjustments = newAdjustments;
                      });
                      _reprocess();
                    }
                  ),
                  const SizedBox(height: 8),
                  PaletteBiasControls(
                    paletteBias: paletteBias,
                    onChanged: (newBias) async {
                      setState(() {
                        paletteBias = newBias;
                      });
                      _reprocess();
                    }
                  ),
                  const SizedBox(height: 8),
                  DitheringControls(
                    selectedAlgorithm: algorithm,
                    onAlgorithmChanged: (newAlg) async {
                      setState(() {
                        algorithm = newAlg;
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
                  const SizedBox(height: 8),
                  FilterOptionsControls(
                    adjustments: adjustments,
                    filter: _filter,
                    onChanged: (newAdjustments) async {
                      setState(() {
                        adjustments = newAdjustments;
                      });
                      _reprocess();
                    }
                  )
                ]
              )
            )
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Simulate Device Colours'),
                  value: _simulateDeviceScreen,
                  onChanged: (simulate) async {
                    setState(() {
                      _simulateDeviceScreen = simulate;
                    });
                    _reprocess();
                  },
                ),
                ImagePreviewPanel(
                  title: 'Preview',
                  height: DeviceConstants.imageHeight,
                  imageBytes: pipeline.previewBytes
                ),
                FilledButton(onPressed: () async {
                  _save();
                  Navigator.pop(context);
                },
                child: const Text('Save'))
              ]
            )
          )
        ],
      )
    );
  }
}