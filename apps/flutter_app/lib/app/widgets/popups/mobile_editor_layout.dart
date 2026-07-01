import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:picpak_open/app/data/models/editor_result.dart';
import 'package:picpak_open/app/widgets/common/image_preview_panel.dart';
import 'package:picpak_open/app/widgets/library/library_item.dart';
import 'package:picpak_open/app/widgets/popups/image_editor_tab.dart';
import 'package:picpak_open/app/widgets/popups/note_editor_tab.dart';
import 'package:picpak_open/app/widgets/popups/qr_code_tab.dart';

class MobileEditorLayout extends StatefulWidget {
  final LibraryItem item;
  final void Function(
    EditorResult editorResult
  ) onSaved;

  const MobileEditorLayout({
    super.key,
    required this.item,
    required this.onSaved
  });

  @override
  State<MobileEditorLayout> createState() => _MobileEditorLayoutState();
}

class _MobileEditorLayoutState extends State<MobileEditorLayout> {
  Uint8List? previewBytes;

  List<Tab> tabs = [
    Tab(text: 'Image'),
    Tab(text: 'Note'),
    Tab(text: 'QR')
  ];

  void _updatePreview(Uint8List bytes) {
    setState(() {
      previewBytes = bytes;
    });
  }

  List<Widget> _buildTabs(BuildContext context) {
    return [
      ImageEditorTab(
        item: widget.item,
        onSaved: widget.onSaved,
        onPreviewChanged: _updatePreview
      ),

      NoteEditorTab(
        item: widget.item,
        onSaved: widget.onSaved,
        onPreviewChanged: _updatePreview
      ),

      QrCodeTab(
        item: widget.item,
        onSaved: widget.onSaved,
        onPreviewChanged: _updatePreview
      )
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add/Edit')
      ),
      body: Column(
        children: [
          SizedBox(
            height: 350,
            child: ImagePreviewPanel(
              height: 300,
              imageBytes: previewBytes
            )
          ),
      
          Expanded(
            child: DefaultTabController(
              length: tabs.length,
              child: Column(
                children: [
                  TabBar(tabs: tabs),
      
                  Expanded(
                    child: TabBarView(
                      children: _buildTabs(context)
                    )
                  )
                ]
              )
            )
          )
        ]
      ),
    );
  }
}