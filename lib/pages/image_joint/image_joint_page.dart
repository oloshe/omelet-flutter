import 'package:flutter/material.dart';
import 'package:omelet/pages/image_joint/image_editor_painter.dart';
import 'dart:ui' as ui;
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:image_picker/image_picker.dart';
import 'package:omelet/common/index.dart';
import 'package:omelet/pages/image_joint/image_reorder_page.dart';
import 'package:omelet/widgets/cell.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class ImageJointPage extends StatefulWidget {
  const ImageJointPage({Key? key}) : super(key: key);

  @override
  State<ImageJointPage> createState() => _ImageJointPageState();
}

class _ImageJointPageState extends State<ImageJointPage> {
  ImageEditorPainterController controller = ImageEditorPainterController();
  ImageJointPageController state = ImageJointPageController();
  @override
  Widget build(BuildContext context) {
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
        actions: [
          IconButton(
            onPressed: save,
            icon: const Icon(Icons.save),
          ),
        ],
      ),
      body: Theme(
        data: Theme.of(context).copyWith(
          primaryColor: Colors.blue,
          secondaryHeaderColor: Colors.blue,
        ),
        child: MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: controller),
            ChangeNotifierProvider.value(value: state),
          ],
          builder: (context, child) {
            final viewerHeight = ScreenAdaptor.screenHeight / 2;
            return SizedBox(
              width: double.infinity,
              child: Column(
                children: <Widget>[
                  InteractiveViewer(
                    panEnabled: false,
                    child: SizedBox(
                      height: viewerHeight,
                      width: double.infinity,
                      child: ColoredBox(
                        color: Colors.grey.shade300,
                        child: Center(
                          child:
                              Selector<ImageEditorPainterController, ui.Size>(
                            selector: (_, controller) {
                              return ui.Size(controller.getWidth(),
                                  controller.getHeight());
                            },
                            builder: (context, value, child) {
                              final isHorizontal = value.width > value.height;
                              final scaleW =
                                  ScreenAdaptor.screenWidth / value.width;
                              final scaleH = value.width == 0
                                  ? 1.0
                                  : viewerHeight / value.height;
                              final scale = value.width == 0
                                  ? 1.0
                                  : (isHorizontal ? scaleW : scaleH);
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
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Selector<ImageEditorPainterController, double>(
                            selector: (context, val) => val.spacing,
                            builder: (context, val, child) {
                              return Cell(
                                leading: const Text("Spacing"),
                                title: Row(
                                  children: [
                                    SizedBox(
                                      width: 25,
                                      child: Text(val.toInt().toString()),
                                    ),
                                    Expanded(
                                      child: Slider(
                                        value: val,
                                        min: 0,
                                        max: 200,
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
                                  'T ${val.top.toInt().toString()} '
                                  'B ${val.bottom.toInt().toString()} '
                                  'L ${val.left.toInt().toString()} '
                                  'R ${val.right.toInt().toString()}',
                                  style: const TextStyle(
                                    color: Colors.grey,
                                  ),
                                ),
                                trailing:
                                    Selector<ImageJointPageController, bool>(
                                        selector: (_, val) =>
                                            val.paddingEditing,
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
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 10),
                                  child: Selector<ImageEditorPainterController,
                                      EdgeInsets>(
                                    selector: (_, val) => val.padding,
                                    builder: (context, pad, child) {
                                      return Column(
                                        children: [
                                          _padCell('Top', pad.top, (val) {
                                            controller.setPadding(
                                                pad.copyWith(top: val));
                                          }),
                                          _padCell('Bottom', pad.bottom, (val) {
                                            controller.setPadding(
                                                pad.copyWith(bottom: val));
                                          }),
                                          _padCell('Left', pad.left, (val) {
                                            controller.setPadding(
                                                pad.copyWith(left: val));
                                          }),
                                          _padCell('Right', pad.right, (val) {
                                            controller.setPadding(
                                                pad.copyWith(right: val));
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
                              style: Ts.s14,
                            ),
                            title: Align(
                              alignment: Alignment.centerLeft,
                              child:
                                  Selector<ImageEditorPainterController, Color>(
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
                                pickColor(context, controller);
                              },
                              child: const Text(
                                'Pick Color',
                                style: TextStyle(
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 20,
                      right: 20,
                      bottom: 15,
                    ),
                    child: SafeArea(
                      bottom: true,
                      child: Row(
                        children: [
                          _BottomBtn(
                            backgroundColor: Colors.blue,
                            icon: Icons.add,
                            text: 'APPEND',
                            onPressed: controller.appendImage,
                          ),
                          const SizedBox(width: 10),
                          _BottomBtn(
                            backgroundColor: Colors.red,
                            icon: Icons.delete,
                            onPressed: controller.clear,
                            text: 'CLEAR',
                          ),
                          const SizedBox(width: 10),
                          _BottomBtn(
                            backgroundColor: Colors.cyan,
                            icon: Icons.sort,
                            onPressed: () =>
                                showReorderPage(context, controller),
                            text: 'REORDER',
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  /// 选取颜色
  void pickColor(
    BuildContext context,
    ImageEditorPainterController controller,
  ) {
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
  }

  /// 显示重牌页面
  void showReorderPage(
    BuildContext context,
    ImageEditorPainterController controller,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ImageReorderPage(
          controller,
        ),
      ),
    );
  }

  /// 保存
  void save() async {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.storage.request();
    }
    final img = await controller.export();
    await ImageGallerySaver.saveImage(img);
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
            child: Text(paddingVal.toInt().toString()),
          ),
          Expanded(
            child: Slider(
              value: paddingVal,
              min: 0,
              max: 200,
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

class _BottomBtn extends StatelessWidget {
  final VoidCallback? onPressed;
  final IconData icon;
  final String text;
  final Color? backgroundColor;

  const _BottomBtn({
    Key? key,
    this.onPressed,
    required this.icon,
    this.backgroundColor,
    required this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(Colors.transparent),
        shadowColor: MaterialStateProperty.all(Colors.transparent),
        padding: MaterialStateProperty.all(
          const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        ),
        shape: MaterialStateProperty.all(const CircleBorder()),
      ),
      child: Column(
        children: [
          Icon(icon, size: 28),
          const SizedBox(height: 2),
          Text(text, style: Ts.s8),
        ],
      ),
    );
  }
}
