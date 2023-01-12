import 'package:flutter/material.dart';
import 'package:flutter_reorderable_grid_view/entities/order_update_entity.dart';
import 'package:flutter_reorderable_grid_view/widgets/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:omelet/common/index.dart';
import 'dart:ui' as ui;

import 'package:omelet/pages/image_joint/image_editor_painter.dart';

class ImageReorderPage extends StatefulWidget {
  final ImageEditorPainterController controller;
  const ImageReorderPage(this.controller, {Key? key}) : super(key: key);

  @override
  State<ImageReorderPage> createState() => _ImageReorderPageState();
}

class _ImageReorderPageState extends State<ImageReorderPage> {
  List<JointItem> items = [];

  @override
  void initState() {
    items.addAll(widget.controller.items);
    super.initState();
  }

  final _scrollController = ScrollController();
  final _gridViewKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'Image Reorder',
          style: GoogleFonts.maShanZheng(
            textStyle: const TextStyle(
              fontSize: 24,
            ),
          ),
        ),
        actions: [
          IconButton(
            onPressed: Navigator.of(context).pop,
            icon: const Icon(Icons.close, color: Colors.black),
            tooltip: 'Cancel',
          ),
          IconButton(
            onPressed: () {
              widget.controller.applyReorder(items);
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.done, color: Colors.black),
            tooltip: 'Done',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: ReorderableBuilder(
          scrollController: _scrollController,
          builder: (children) {
            return GridView(
              key: _gridViewKey,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 8,
                mainAxisSpacing: 4,
              ),
              children: children,
            );
          },
          onReorder: (List<OrderUpdateEntity> orderUpdateEntities) {
            for (final orderUpdateEntity in orderUpdateEntities) {
              final old = items.removeAt(orderUpdateEntity.oldIndex);
              items.insert(orderUpdateEntity.newIndex, old);
            }
          },
          children: List.generate(items.length, (index) {
            final item = items.elementAt(index);
            return Container(
              key: item.key,
              decoration: BoxDecoration(
                  color: Colors.black45,
                  borderRadius: BorderRadius.all(Radius.circular(20))),
              child: Image.memory(item.imageData!),
            );
          }),
        ),
      ),
    );
  }
}
