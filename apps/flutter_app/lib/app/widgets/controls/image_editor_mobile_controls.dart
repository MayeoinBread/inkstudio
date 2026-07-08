import 'package:flutter/material.dart';
import 'package:inkstudio_image/inkstudio_image.dart';
import 'package:inkstudio/app/widgets/controls/dithering_controls.dart';
import 'package:inkstudio/app/widgets/controls/filter_controls.dart';
import 'package:inkstudio/app/widgets/controls/filter_options_controls.dart';
import 'package:inkstudio/app/widgets/controls/image_adjustment_controls.dart';
import 'package:inkstudio/app/widgets/controls/palette_bias_controls.dart';

class ImageEditorMobileControls extends StatelessWidget {
  final DitherMode alg;
  final ImageAdjustments adjustments;
  final PaletteBias bias;
  final ImageFilter filter;
  final bool simulateDevice;

  final VoidCallback onSave;
  final VoidCallback onLoadImageSelected;
  
  final ValueChanged<DitherMode> onAlgChanged;
  final ValueChanged<ImageAdjustments> onAdjustmentsChanged;
  final ValueChanged<PaletteBias> onPaletteBiasChanged;
  final ValueChanged<ImageFilter> onFilterChanged;
  final ValueChanged<bool> onSimulateDeviceChanged;

  final VoidCallback onCropSelected;
  final VoidCallback onAutoEnhanceSelected;
  final VoidCallback onRotateSelected;

  const ImageEditorMobileControls({
    super.key,
    required this.alg,
    required this.adjustments,
    required this.bias,
    required this.filter,
    required this.simulateDevice,
    required this.onAlgChanged,
    required this.onAdjustmentsChanged,
    required this.onPaletteBiasChanged,
    required this.onFilterChanged,
    required this.onSimulateDeviceChanged,
    required this.onCropSelected,
    required this.onAutoEnhanceSelected,
    required this.onRotateSelected,
    required this.onLoadImageSelected,
    required this.onSave
  });

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                FilledButton(
                  onPressed: onLoadImageSelected,
                  child: const Text('Load Image')
                ),
                
                FilledButton(
                  onPressed: onSave,
                  child: const Text('Save')
                ),
              ],
            )
          ),

          const TabBar(
            tabs: [
              Tab(text: 'General'),
              // Tab(text: 'Crop'),
              Tab(text: 'Dithering'),
              Tab(text: 'Adjustments'),
              Tab(text: 'Filters + Options')
            ]
          ),

          Expanded(
            child: TabBarView(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    children: [
                      
                      Card(
                        child: Row(
                          children: [
                            Expanded(
                              child: IconButton(
                                icon: const Icon(Icons.crop),
                                tooltip: 'Crop',
                                onPressed: onCropSelected
                              )
                            ),

                            Expanded(
                              child: IconButton(
                                icon: const Icon(Icons.rotate_90_degrees_cw),
                                tooltip: 'Rotate',
                                onPressed: onRotateSelected
                              )
                            ),

                            Expanded(
                              child: IconButton(
                                icon: const Icon(Icons.diamond_sharp),
                                tooltip: 'Auto-Enhance',
                                onPressed: onAutoEnhanceSelected
                              )
                            )
                          ]
                        )
                      ),

                      SwitchListTile(
                        title: const Text('Simulate Device Colours'),
                        value: simulateDevice,
                        onChanged: onSimulateDeviceChanged
                      )
                    ],
                  )
                ),
                
                // SingleChildScrollView(
                //   padding: const EdgeInsets.all(12),
                //   child: CropControls(
                //     fitStrategy: fit,
                //     onFitChanged: onFitChanged
                //   )
                // ),

                SingleChildScrollView(
                  padding: const EdgeInsets.all(8),
                  child: DitheringControls(
                    selectedAlgorithm: alg,
                    onAlgorithmChanged: onAlgChanged
                  )
                ),

                SingleChildScrollView(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    children: [
                      ImageAdjustmentControls(
                        adjustments: adjustments,
                        onChanged: onAdjustmentsChanged
                      ),
                      SizedBox(height: 8),
                      PaletteBiasControls(
                        paletteBias: bias,
                        onChanged: onPaletteBiasChanged
                      )
                    ]
                  )
                ),

                SingleChildScrollView(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    children: [
                      FilterControls(
                        selectedFilter: filter,
                        onFilterChanged: onFilterChanged
                      ),
                      SizedBox(height: 8),
                      FilterOptionsControls(
                        adjustments: adjustments,
                        filter: filter,
                        onChanged: onAdjustmentsChanged
                      )
                    ]
                  )
                )
              ]
            )
          )
        ]
      )
    );
  }
}