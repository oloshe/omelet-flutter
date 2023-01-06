import 'package:flutter/material.dart';
import 'package:omelet/pages/image_joint/image_editor_painter.dart';
import 'dart:ui' as ui;
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:image_picker/image_picker.dart';
import 'package:omelet/common/index.dart';
import 'package:omelet/widgets/cell.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class ImageJointPage extends StatelessWidget {
  const ImageJointPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ImageEditorPainterController controller = ImageEditorPainterController();
    ImageJointPageController state = ImageJointPageController();
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Omelet - Image Joint Editor",
          style: GoogleFonts.maShanZheng(
            textStyle: const TextStyle(
              fontSize: 24,
            ),
          ),
        ),
      ),
      body: MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: controller),
          ChangeNotifierProvider.value(value: state),
        ],
        builder: (context, child) {
          return SingleChildScrollView(
            child: SizedBox(
              width: double.infinity,
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 10,
                      left: 10,
                      right: 10,
                    ),
                    child: Row(
                      children: [
                        ElevatedButton(
                          onPressed: () async {
                            final picker = ImagePicker();
                            final ret = await picker.pickMultiImage();
                            for (var file in ret) {
                              final list = await file.readAsBytes();
                              final img =
                                  await ImageEditorPainter.loadImage(list);
                              controller.appendImage(img);
                            }
                          },
                          child: Row(
                            children: const [
                              Icon(Icons.add),
                              Text("Append"),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: () async {
                            var status = await Permission.storage.status;
                            if (!status.isGranted) {
                              await Permission.storage.request();
                            }
                            final img = await controller.export();
                            await ImageGallerySaver.saveImage(img);
                          },
                          style: const ButtonStyle(
                            backgroundColor:
                                MaterialStatePropertyAll(Colors.green),
                          ),
                          child: Row(
                            children: const [
                              Icon(Icons.save),
                              SizedBox(width: 2),
                              Text("Save"),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: () {
                            controller.clear();
                          },
                          style: const ButtonStyle(
                            backgroundColor:
                                MaterialStatePropertyAll(Colors.redAccent),
                          ),
                          child: Row(
                            children: const [Icon(Icons.clear), Text("Clear")],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Selector<ImageEditorPainterController, double>(
                    selector: (context, val) => val.spacing,
                    builder: (context, val, child) {
                      return Cell(
                        leading: const Text("Spacing"),
                        title: Row(
                          children: [
                            Text(val.toStringAsFixed(1)),
                            Expanded(
                              child: Slider(
                                value: val,
                                min: 0,
                                max: 50,
                                onChanged: (val) {
                                  controller.setSpacing(val);
                                },
                              ),
                            )
                          ],
                        ),
                      );
                    },
                  ),
                  Selector<ImageEditorPainterController, EdgeInsets>(
                    selector: (context, val) => val.padding,
                    builder: (context, val, child) {
                      return Cell(
                        leading: const Text('Padding'),
                        title: Text(
                          'T ${val.top.toStringAsFixed(1)} '
                          'B ${val.bottom.toStringAsFixed(1)} '
                          'L ${val.left.toStringAsFixed(1)} '
                          'R ${val.right.toStringAsFixed(1)}',
                          style: const TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                        trailing: Selector<ImageJointPageController, bool>(
                            selector: (_, val) => val.paddingEditing,
                            builder: (context, show, child) {
                              if (show) {
                                return TextButton(
                                  onPressed: () {
                                    state.donePadding();
                                  },
                                  child: const Text("Done"),
                                );
                              } else {
                                return TextButton(
                                  onPressed: () {
                                    state.editPadding();
                                  },
                                  child: const Text("Edit"),
                                );
                              }
                            }),
                      );
                    },
                  ),
                  Selector<ImageJointPageController, bool>(
                    selector: (_, val) => val.paddingEditing,
                    builder: (context, show, child) {
                      if (!show) {
                        return const SizedBox.shrink();
                      }
                      return ColoredBox(
                        color: const Color(0xfff1f1f1),
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          child: Selector<ImageEditorPainterController, EdgeInsets>(
                            selector: (_, val) => val.padding,
                            builder: (context, pad, child) {
                              return Column(
                                children: [
                                  _padCell('Top', pad.top, (val) {
                                    controller.setPadding(pad.copyWith(top: val));
                                  }),
                                  _padCell('Bottom', pad.bottom, (val) {
                                    controller
                                        .setPadding(pad.copyWith(bottom: val));
                                  }),
                                  _padCell('Left', pad.left, (val) {
                                    controller.setPadding(pad.copyWith(left: val));
                                  }),
                                  _padCell('Right', pad.right, (val) {
                                    controller.setPadding(pad.copyWith(right: val));
                                  }),
                                ],
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),
                  Cell(
                    leading: const Text(
                      "Background",
                      style: R.s14,
                    ),
                    title: Align(
                      alignment: Alignment.centerLeft,
                      child: Selector<ImageEditorPainterController, Color>(
                        selector: (_, val) => val.bgColor,
                        builder: (_, color, child) => DecoratedBox(
                          decoration: BoxDecoration(
                            color: color,
                            border: Border.all(
                              color: const Color(0xff333333),
                            ),
                          ),
                          child: SizedBox.fromSize(
                            size: const ui.Size.fromRadius(15),
                          ),
                        ),
                      ),
                    ),
                    trailing: TextButton(
                      onPressed: () {
                        Color selectColor = controller.bgColor;
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: const Text('Pick a color!'),
                              content: SingleChildScrollView(
                                child: SlidePicker(
                                  pickerColor: controller.bgColor,
                                  onColorChanged: (clr) {
                                    selectColor = clr;
                                  },
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    controller.setBgColor(selectColor);
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text('Got it'),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      child: const Text(
                        'Pick Color',
                        style: TextStyle(
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(left: 10),
                    child: SizedBox(
                      height: 40,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Preview",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Selector<ImageEditorPainterController, ui.Size>(
                    selector: (context, val) {
                      return ui.Size(val.getWidth(), val.getHeight());
                    },
                    builder: (context, value, child) {
                      final scale = value.width == 0
                          ? 1.0
                          : ScreenAdaptor.screenWidth / value.width;
                      return Transform.scale(
                        scale: scale,
                        origin: Offset.zero,
                        alignment: Alignment.topLeft,
                        child: CustomPaint(
                          size: value * scale,
                          painter: ImageEditorPainter(
                            controller: controller,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Cell _padCell(
    String title,
    double paddingVal,
    ValueChanged<double> onChanged,
  ) {
    return Cell(
      height: 40,
      leading: SizedBox(
        width: 50,
        child: Text(title),
      ),
      title: Row(
        children: [
          SizedBox(
            width: 30,
            child: Text(paddingVal.toStringAsFixed(1)),
          ),
          Expanded(
            child: Slider(
              value: paddingVal,
              min: 0,
              max: 50,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}

class ImageJointPageController with ChangeNotifier {
  bool paddingEditing = false;

  void editPadding() {
    paddingEditing = true;
    notifyListeners();
  }

  void donePadding() {
    paddingEditing = false;
    notifyListeners();
  }
}
