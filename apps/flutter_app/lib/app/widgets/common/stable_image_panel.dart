import 'package:flutter/material.dart';

class StableImagePanel extends StatelessWidget {
  final ImageProvider? image;

  const StableImagePanel({super.key, this.image});

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: image == null
        ? const Text('No image')
        : Image(image: image!)
    );
  }
}