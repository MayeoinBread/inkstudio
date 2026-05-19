import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:picpak_image/src/pipeline/image_pipeline.dart';
import 'package:picpak_image/src/pipeline/fit_strategy.dart';
import 'package:image/image.dart' as img;

void main() {
  runApp(const PicPakApp());
}

class PicPakApp extends StatelessWidget {
  const PicPakApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PicPak Open',
      debugShowCheckedModeBanner: true,
      theme: ThemeData.dark(),
      home: const ImageComparePage(),
    );
  }
}

class ImageComparePage extends StatefulWidget {
  const ImageComparePage({super.key});

  @override
  State<ImageComparePage> createState() => _ImageComparePageState();
}

class _ImageComparePageState extends State<ImageComparePage> {
  Uint8List? _originalImage;
  Uint8List? _processedImage;
  final pipeline = const ImagePipeline();

  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );

    if (result == null || result.files.isEmpty) return;

    final bytes = result.files.first.bytes;
    if (bytes == null) return;

    final processed = pipeline.process(
      bytes,
      fit: FitStrategy.crop,
      dither: "atkinson"
    );

    setState(() {
      _originalImage = bytes;
      _processedImage = Uint8List.fromList(img.encodePng(processed));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PicPak Image Pipeline'),
        actions: [
          IconButton(
            icon: const Icon(Icons.folder_open),
            onPressed: _pickImage,
          )
        ]
      ),
      body: Row(
        children: [
          Expanded(
            child: ImagePanel(
              title: 'Original',
              imageBytes: _originalImage
            )
          ),
          const VerticalDivider(width: 1),
          Expanded(
            child: ImagePanel(
              title: "Processed (placeholder)",
              imageBytes: _processedImage
            )
          )
        ]
      )
    );
  }
}

class ImagePanel extends StatelessWidget {
  final String title;
  final Uint8List? imageBytes;

  const ImagePanel({
    super.key,
    required this.title,
    required this.imageBytes
  });

  @override
  Widget build(BuildContext context){
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          child: Text(title)
        ),
        const Divider(height: 1),
        Expanded(
          child: Center(
            child: imageBytes == null
              ? const Text("No image loaded")
              : Image.memory(imageBytes!)
          )
        )
      ],
    );
  }
}