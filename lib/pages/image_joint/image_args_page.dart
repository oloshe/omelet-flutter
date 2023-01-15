import 'package:flutter/material.dart';
import 'package:omelet/pages/image_joint/image_editor_painter.dart';
import 'package:omelet/pages/image_joint/image_joint_page.dart';
import 'package:provider/provider.dart';

class ImageArgsPage extends StatefulWidget {
  final ImageEditorPainterController controller;
  const ImageArgsPage({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  State<ImageArgsPage> createState() => _ImageArgsPageState();
}

class _ImageArgsPageState extends State<ImageArgsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: widget.controller),
        ],
        child: LayoutBuilder(
          builder: (context, constraint) {
            return ImageJointMainViewer(
              viewerHeight: constraint.maxHeight,
              controller: widget.controller,
              fitHeight: true,
            );
          },
        ),
      ),
    );
  }
}
