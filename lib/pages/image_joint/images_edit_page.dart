import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:omelet/common/index.dart';

import 'package:omelet/pages/image_joint/image_editor_painter.dart';
import 'package:omelet/pages/image_joint/joint_item.dart';
import 'package:omelet/pages/image_joint/text_item_editor.dart';
import 'package:omelet/widgets/cell.dart';
import 'package:reorderables/reorderables.dart';

class ImagesEditPage extends StatefulWidget {
  final ImageEditorPainterController controller;
  const ImagesEditPage(this.controller, {Key? key}) : super(key: key);

  @override
  State<ImagesEditPage> createState() => _ImagesEditPageState();
}

class _ImagesEditPageState extends State<ImagesEditPage> {
  List<JointItem> items = [];

  @override
  void initState() {
    items.addAll(widget.controller.items);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Images Edit',
          style: GoogleFonts.maShanZheng(
            textStyle: const TextStyle(
              fontSize: 24,
            ),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () async {
              if (items.isEmpty) {
                return;
              }
              final result = await Utils.showConfirm(
                  title: 'Delete All',
                  content: 'Are you sure to clear all images?');
              if (result == true) {
                widget.controller.clear();
                Utils.toast('Clear');
              }
            },
            icon: const Icon(Icons.delete_forever_rounded, color: Colors.black),
            tooltip: 'Clear All',
          ),
          IconButton(
            onPressed: () async {
              final list = await JointImage.getImages();
              setState(() {
                items.addAll(list);
              });
            },
            icon: const Icon(Icons.add_rounded, color: Colors.black),
            tooltip: 'Append',
          ),
          IconButton(
            onPressed: () {
              widget.controller.applyNewList(items);
              Utils.toast('Applied');
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.done_rounded, color: Colors.black),
            tooltip: 'Done',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: ReorderableColumn(
          onReorder: (oldIndex, newIndex) {
            setState(() {
              final old = items.removeAt(oldIndex);
              items.insert(newIndex, old);
            });
          },
          children: List.generate(items.length, (index) {
            final item = items.elementAt(index);
            return Cell(
              key: item.key,
              // color: Colors.grey.shade200,
              // borderRadius: BorderRadius.circular(radius),
              divider: const Divider(height: 1),
              leading: item.thumbnail(const Size.square(60)),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  item.titleWidget(),
                  const SizedBox(height: 10),
                  Text(
                    '${item.getWidth()} X ${item.getHeight()}',
                    style: Ts.s10,
                  ),
                ],
              ),
              trailing: Row(
                children: [
                  if (item is JointImage)
                    IconButton(
                      onPressed: () async {
                        final croppedFile =
                            await Utils.cropImage(item.imagePath);
                        if (croppedFile != null) {
                          setState(() {
                            item.changeCroppedImg(croppedFile);
                          });
                        }
                      },
                      icon: const Icon(Icons.crop_rounded),
                    ),
                  if (item is JointImage) const SizedBox(width: 20),
                  const Icon(Icons.reorder_rounded, color: Colors.grey),
                ],
              ),
              onTap: () async {
                if (item is JointText) {
                  await showDialog<JointText>(
                    context: context,
                    builder: (_) => TextItemEditor(
                      controller: widget.controller,
                      itemValue: item,
                    ),
                  );
                  setState(() {});
                } else if (item is JointImage) {
                  await _previewImage(
                    context,
                    items.whereType<JointImage>().toList(growable: false),
                    item,
                    onDeleted: () {
                      setState(() {
                        items.removeAt(index);
                      });
                      Utils.toast('Deleted');
                    },
                    onEdited: (_) {
                      setState(() {});
                      widget.controller.updateImagesChange();
                    },
                  );
                }
              },
            );
          }),
        ),
      ),
    );
  }
}

/// 预览图片，返回是否删除
Future<void> _previewImage(
  BuildContext context,
  List<JointImage> images,
  JointImage initialItem, {
  VoidCallback? onDeleted,
  void Function(CroppedFile)? onEdited,
}) {
  return showDialog<void>(
    context: context,
    builder: (context) {
      var index = images.indexOf(initialItem);
      return Material(
        child: ColoredBox(
          color: Colors.black87,
          child: StatefulBuilder(builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Expanded(
                  child: GestureDetector(
                    child: InteractiveViewer(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Image.memory(
                            images[index].imageData,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 60,
                  child: ColoredBox(
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              onDeleted?.call();
                            },
                            icon: const Icon(
                              Icons.delete,
                              color: Colors.redAccent,
                            ),
                          ),
                          IconButton(
                            onPressed: () async {
                              final croppedFile = await Utils.cropImage(
                                  images[index].imagePath);
                              if (croppedFile != null) {
                                setState(() {
                                  images[index].changeCroppedImg(croppedFile);
                                });
                                onEdited?.call(croppedFile);
                              }
                            },
                            icon: const Icon(Icons.crop, color: Colors.black),
                          ),
                          IconButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            icon: const Icon(Icons.close, color: Colors.black),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              ],
            );
          }),
        ),
      );
    },
  );
}
