import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:inkstudio/app/data/models/editor_result.dart';
import 'package:inkstudio/app/widgets/common/image_preview_panel.dart';
import 'package:inkstudio/app/widgets/library/library_item.dart';
import 'package:inkstudio/app/widgets/popups/image_editor_tab.dart';
import 'package:inkstudio/app/widgets/popups/note_editor_tab.dart';
import 'package:inkstudio/app/widgets/popups/qr_code_tab.dart';
import 'package:inkstudio_core/inkstudio_core.dart';

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

  bool pipelinePrepared = false;

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
        onPreviewChanged: _updatePreview,
        onPipelinePrepared: () {
          setState(() {
            pipelinePrepared = true;
          });
        },
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
          Stack(
            children: [
              ImagePreviewPanel(
                title:  null,
                height: DeviceConstants.imageHeight,
                imageBytes: previewBytes
              ),

              if (!pipelinePrepared)
                Positioned.fill(
                  child: Padding(
                    padding: EdgeInsetsGeometry.all(4),
                    child: ClipRRect(
                      borderRadius: BorderRadiusGeometry.circular(16),
                      child: Container(
                        color: Colors.black54,
                        child: const Center(
                          child: CircularProgressIndicator()
                        )
                      )
                    )
                  )
                )
            ],
          ),

          // SizedBox(
          //   height: 350,
          //   child: ImagePreviewPanel(
          //     height: 300,
          //     imageBytes: previewBytes
          //   )
          // ),
      
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