import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image/image.dart' as img;
import 'package:omelet/ext/index.dart';
import 'package:omelet/pages/image_joint/Image_joint_main_viewer.dart';
import 'package:omelet/pages/image_joint/image_args_page.dart';
import 'package:omelet/pages/image_joint/image_editor_painter.dart';
import 'dart:ui' as ui;
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:omelet/common/index.dart';
import 'package:omelet/pages/image_joint/image_joint_presets.dart';
import 'package:omelet/pages/image_joint/image_joint_settings_page.dart';
import 'package:omelet/pages/image_joint/images_edit_page.dart';
import 'package:omelet/pages/image_joint/joint_item.dart';
import 'package:omelet/pages/image_joint/text_item_editor.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

typedef _ImageArgData = ImageArgData<ImageEditorPainterController, String>;

class ImageJointPage extends StatefulWidget {
  const ImageJointPage({Key? key}) : super(key: key);

  @override
  State<ImageJointPage> createState() => _ImageJointPageState();
}

class _ImageJointPageState extends State<ImageJointPage> {
  ImageEditorPainterController controller = ImageEditorPainterController();
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
          IconButton(
            onPressed: () {
              // controller.saveSetting(context);
              showMenu(
                context: context,
                position: const RelativeRect.fromLTRB(1, 0, 0, 0),
                items: <PopupMenuEntry>[
                  PopupMenuItem(
                    onTap: () {
                      Utils.nextFrameCall(() async {
                        final oldPixelScale =
                            ImageJointSettingData.instance.pixelScale;
                        await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) =>
                                const ImageJointSettingsPage(),
                          ),
                        );
                        if (ImageJointSettingData.instance.pixelScale !=
                            oldPixelScale) {
                          controller.updateImagesChange();
                        }
                      });
                    },
                    child: const Text('Settings'),
                  ),
                  PopupMenuItem(
                    onTap: () {
                      Utils.nextFrameCall(() async {
                        final ImageEditorPainterController ctrl =
                            await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) {
                              return const ImageJointPresets();
                            },
                          ),
                        );
                        controller.merge(ctrl);
                        Utils.toast('Applied');
                      });
                    },
                    child: const Text('Presets'),
                  ),
                  PopupMenuItem(
                    onTap: () async {
                      SchedulerBinding.instance.addPostFrameCallback((_) {
                        controller.saveSetting(context);
                      });
                    },
                    child: const Text('New Preset'),
                  ),
                ],
              );
            },
            icon: const Icon(Icons.more_vert),
          )
        ],
      ),
      body: MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: controller),
        ],
        builder: (context, child) {
          const tabHeight = 80.0;
          return LayoutBuilder(builder: (context, constraints) {
            final viewerHeight = constraints.maxHeight - tabHeight;
            return SizedBox(
              width: double.infinity,
              child: Column(
                children: <Widget>[
                  ImageJointMainViewer(
                    viewerHeight: viewerHeight,
                    controller: controller,
                  ),
                  SizedBox(
                    height: tabHeight,
                    width: double.infinity,
                    child: ColoredBox(
                      color: Colors.grey.shade100,
                      child: Padding(
                        padding: const EdgeInsets.only(
                          top: 5,
                          left: 20,
                          right: 20,
                          bottom: 15,
                        ),
                        child: SafeArea(
                          bottom: true,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                _BottomBtn(
                                  icon: Icons.add_rounded,
                                  text: 'APPEND',
                                  onPressed: controller.appendImage,
                                ),
                                const SizedBox(width: 2),
                                _BottomBtn(
                                  icon: Icons.list,
                                  onPressed: () =>
                                      showReorderPage(context, controller),
                                  text: 'EDIT',
                                ),
                                const SizedBox(width: 2),
                                _BottomBtn(
                                  icon: Icons.space_bar_rounded,
                                  onPressed: () =>
                                      showSpacingEditPage(context, controller),
                                  text: 'SPACING',
                                ),
                                const SizedBox(width: 2),
                                _BottomBtn(
                                  icon: Icons.texture_rounded,
                                  onPressed: () =>
                                      showShadowEdit(context, controller),
                                  text: 'SHADOW',
                                ),
                                const SizedBox(width: 2),
                                _BottomBtn(
                                  icon: Icons.color_lens_rounded,
                                  onPressed: () => showBackgroundPanel(
                                    context,
                                    controller,
                                  ),
                                  text: 'COLOR',
                                ),
                                const SizedBox(width: 2),
                                _BottomBtn(
                                  icon: Icons.title_rounded,
                                  onPressed: () => showTextEditor(
                                    context,
                                    controller,
                                  ),
                                  text: 'ADD TITLE',
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          });
        },
      ),
    );
  }

  /// 显示重牌页面
  void showReorderPage(
    BuildContext context,
    ImageEditorPainterController controller,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ImagesEditPage(
          controller,
        ),
      ),
    );
  }

  /// 显示空隙编辑页面
  void showSpacingEditPage(
    BuildContext context,
    ImageEditorPainterController controller,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          return ImageArgsPage(
            controller: controller,
            data: [
              _ImageArgData(
                name: 'Spacing Y',
                min: 0,
                max: 500,
                initialValue: controller.spacing,
                onChanged: (value) {
                  controller.setSpacing(value);
                },
                selector: (c) => c.spacing.toStringAsFixed(0),
              ),
              _ImageArgData(
                name: 'Padding Horizontal',
                min: 0,
                max: 500,
                initialValue: controller.padding.left,
                onChanged: (value) {
                  controller.setPadding(controller.padding.copyWith(
                    left: value,
                    right: value,
                  ));
                },
                selector: (c) => c.padding.left.toStringAsFixed(0),
              ),
              _ImageArgData(
                name: 'Padding Vertical',
                min: 0,
                max: 500,
                initialValue: controller.padding.top,
                onChanged: (value) {
                  controller.setPadding(controller.padding.copyWith(
                    top: value,
                    bottom: value,
                  ));
                },
                selector: (c) => c.padding.top.toStringAsFixed(0),
              ),
              _ImageArgData(
                name: 'Radius',
                min: 0,
                max: 500,
                initialValue: controller.radius.x,
                onChanged: (value) {
                  controller.setRadius(Radius.circular(value));
                },
                selector: (c) => c.radius.x.toStringAsFixed(0),
              ),
            ],
          );
        },
      ),
    );
  }

  /// 显示阴影编辑
  void showShadowEdit(
    BuildContext context,
    ImageEditorPainterController controller,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          return ImageArgsPage(
            controller: controller,
            data: [
              _ImageArgData(
                name: 'Shadow Elevation',
                min: 0,
                max: 50,
                initialValue: controller.shadowElevation,
                onChanged: (value) {
                  controller.setShadowElevation(value);
                },
                selector: (c) => c.shadowElevation.toStringAsFixed(1),
              ),
              _ImageArgData(
                name: 'Shadow Offset X',
                min: -100,
                max: 100,
                initialValue: controller.shadowOffset.dx,
                onChanged: (value) {
                  controller.setShadowOffset(dx: value);
                },
                selector: (c) => c.shadowOffset.dx.toStringAsFixed(0),
              ),
              _ImageArgData(
                name: 'Shadow Offset Y',
                min: -100,
                max: 100,
                initialValue: controller.shadowOffset.dy,
                onChanged: (value) {
                  controller.setShadowOffset(dy: value);
                },
                selector: (c) => c.shadowOffset.dy.toStringAsFixed(0),
              ),
            ],
          );
        },
      ),
    );
  }

  /// 保存
  void save() async {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.storage.request();
    }
    Fluttertoast.showToast(msg: 'Start Saving...');
    // await compute(computeSave, controller);
    await computeSave(controller);
    Fluttertoast.showToast(msg: 'Saved');
  }

  static Future<void> computeSave(
      ImageEditorPainterController controller) async {
    final stopwatch0 = Stopwatch()..start();
    final stopwatch = Stopwatch()..start();
    final bytes = await compute(controller.export, 0);
    print('painted ${stopwatch.elapsed}');
    final image = img.decodeImage(bytes)!;
    final file = await ImageJointSettingData.instance.encodeFile(image);
    if (file != null) {
      await ImageGallerySaver.saveFile(file.path);
      print('total use ${stopwatch0.elapsed}');
    }
  }

  // 显示切换背景
  void showBackgroundPanel(
    BuildContext context,
    ImageEditorPainterController controller,
  ) {
    var initialBgColor = controller.bgColor;
    var initialShadowColor = controller.shadowColor;
    showModalBottomSheet(
      context: context,
      barrierColor: Colors.transparent,
      backgroundColor: Colors.grey.shade300.withOpacity(0.9),
      elevation: 30,
      builder: (context) {
        var bgColor = controller.bgColor;
        var shadowColor = controller.shadowColor;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {
                      controller.setBgColor(initialBgColor);
                      controller.setShadowColor(initialShadowColor);
                      Navigator.of(context).pop();
                    },
                    child: const Text(
                      'Cancel',
                      style: Ts.grey,
                    ),
                  ),
                  TextButton(
                    onPressed: Navigator.of(context).pop,
                    child: const Text(
                      'Confirm',
                      style: Ts.blue,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              StatefulBuilder(
                builder: (context, setState) {
                  return ColoredBox(
                    color: shadowColor,
                    child: SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: () async {
                          final newColor =
                              await Utils.showColorPicker(context, shadowColor);
                          if (newColor != null) {
                            controller.setShadowColor(newColor);
                            setState(() {
                              shadowColor = newColor;
                            });
                          }
                        },
                        child: Text(
                          'Shadow Color',
                          style: GoogleFonts.maShanZheng(
                            textStyle: TextStyle(
                              color: shadowColor.invert,
                              fontSize: 24,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 10),
              StatefulBuilder(
                builder: (context, setState) {
                  return ColoredBox(
                    color: bgColor,
                    child: SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: () async {
                          final newColor = await Utils.showColorPicker(context, bgColor);
                          if (newColor != null) {
                            controller.setBgColor(newColor);
                            setState(() {
                              bgColor = newColor;
                            });
                          }
                        },
                        child: Text(
                          'Background Color',
                          style: GoogleFonts.maShanZheng(
                            textStyle: TextStyle(
                              color: bgColor.invert,
                              fontSize: 24,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 80),
            ],
          ),
        );
      },
    );
  }

  void showTextEditor(
    BuildContext context,
    ImageEditorPainterController controller,
  ) async {
    final data = await showDialog<JointText>(
      context: context,
      builder: (_) => TextItemEditor(controller: controller),
    );
    if (data != null) {
      controller.appendTextItem(data);
    }
  }
}

class _BottomBtn extends StatelessWidget {
  final VoidCallback? onPressed;
  final IconData icon;
  final String text;

  const _BottomBtn({
    Key? key,
    this.onPressed,
    required this.icon,
    required this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(Colors.transparent),
        shadowColor: MaterialStateProperty.all(Colors.transparent),
        foregroundColor: MaterialStateProperty.all(Colors.black),
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
