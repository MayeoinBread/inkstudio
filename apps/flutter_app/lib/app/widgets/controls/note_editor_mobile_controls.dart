import 'package:flutter/material.dart';

class NoteEditorMobileControls extends StatelessWidget {

  final TextEditingController textController;
  
  final VoidCallback onPreview;
  final VoidCallback onSave;

  const NoteEditorMobileControls({
    super.key,
    required this.textController,
    required this.onPreview,
    required this.onSave
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 250,
            child: TextField(
              controller: textController,
              expands: true,
              maxLines: null,
              decoration: const InputDecoration(
                border: OutlineInputBorder()
              ),
            )
          ),

          const SizedBox(height: 16),

          FilledButton(onPressed: onPreview, child: const Text('Preview')),

          const SizedBox(height: 8),

          FilledButton(onPressed: onSave, child: const Text('Save'))
        ]
      )
    );
  }
}