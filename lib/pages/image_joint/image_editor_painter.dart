import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:omelet/common/index.dart';
import 'package:omelet/pages/image_joint/image_joint_settings_page.dart';
import 'package:omelet/pages/image_joint/joint_item.dart';

class ImageEditorPainter extends CustomPainter {
  ImageEditorPainterController controller;

  ImageEditorPainter({required this.controller}) : super(repaint: controller);

  static Future<ui.Image> loadImage(Uint8List imageData) async {
    final codec = await ui.instantiateImageCodec(imageData);
    final frame = await codec.getNextFrame();
    return frame.image;
  }

  @override
  void paint(Canvas canvas, Size size) {
    controller.paint(canvas, size);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return controller.items.length !=
        (oldDelegate as ImageEditorPainter).controller.items.length;
  }
}

class ImageEditorPainterController with ChangeNotifier {
  List<JointItem2> items = [];
  // =====================【预设】========================
  /// 预设名字
  String presetName = 'Unnamed Preset';

  /// 预设备注
  String presetRemark = '';
  // ====================================================

  String title = 'Hello Omelet';
  Color titleColor = Colors.black;

  /// 是否是水平
  bool isHorizontal = false;

  /// 间隔
  double spacing = 0;

  /// 白边
  EdgeInsets padding = EdgeInsets.zero;

  /// 背景颜色
  Color bgColor = Colors.white;

  /// 圆角
  Radius radius = Radius.zero;

  /// 阴影偏移
  Offset shadowOffset = Offset.zero;

  /// 阴影高度
  double shadowElevation = 0;

  /// 阴影颜色
  Color shadowColor = Colors.black;

  /// 最宽的图片宽度
  double _maxImgWidth = 0;

  /// 最长的图片长度
  double _maxImgHeight = 0;

  /// 缩放，0.5就是把像素缩小一倍
  double get scale => ImageJointSettingData.instance.pixelScale;

  ImageEditorPainterController();

  factory ImageEditorPainterController.fromJson(Map<String, dynamic> json) {
    return ImageEditorPainterController()
      ..presetName = json['presetName']
      ..presetRemark = json['presetName']
      ..isHorizontal = json['isHorizontal']
      ..spacing = json['spacing']
      ..padding = EdgeInsets.fromLTRB(
        json['paddingLeft'],
        json['paddingTop'],
        json['paddingRight'],
        json['paddingBottom'],
      )
      ..bgColor = Color(json['bgColor'])
      ..shadowColor = Color(json['shadowColor'])
      ..radius = Radius.elliptical(json['radiusX'], json['radiusY'])
      ..shadowOffset = Offset(json['shadowOffsetDx'], json['shadowOffsetDy'])
      ..shadowElevation = json['shadowElevation'];
  }

  Map<String, dynamic> toJson() => {
        'presetName': presetName,
        'presetRemark': presetRemark,
        'isHorizontal': isHorizontal,
        'spacing': spacing,
        'paddingLeft': padding.left,
        'paddingTop': padding.top,
        'paddingRight': padding.right,
        'paddingBottom': padding.bottom,
        'bgColor': bgColor.value,
        'shadowColor': shadowColor.value,
        'radiusX': radius.x,
        'radiusY': radius.y,
        'shadowOffsetDx': shadowOffset.dx,
        'shadowOffsetDy': shadowOffset.dy,
        'shadowElevation': shadowElevation,
      };

  void merge(ImageEditorPainterController other) {
    presetName = other.presetName;
    presetRemark = other.presetRemark;
    isHorizontal = other.isHorizontal;
    spacing = other.spacing;
    padding = other.padding.copyWith();
    bgColor = Color(other.bgColor.value);
    shadowColor = Color(other.shadowColor.value);
    radius = Radius.elliptical(other.radius.x, other.radius.y);
    shadowOffset = Offset(other.shadowOffset.dx, other.shadowOffset.dy);
    shadowElevation = other.shadowElevation;
    notifyListeners();
  }

  /// 宽度
  double getWidth() {
    if (items.isEmpty) {
      return 0;
    }
    if (isHorizontal) {
      final dh = getHeight() - padding.top - padding.bottom;
      final totalWidth = items.map((e) {
        final thisScale = e.getHeight() / dh;
        return e.getWidth() / thisScale;
      }).reduce((a, b) => a + b);
      return totalWidth + totalSpacing + padding.left + padding.right;
    } else {
      return _maxImgWidth + padding.left + padding.right;
    }
  }

  /// 高度
  double getHeight() {
    if (items.isEmpty) {
      return 0;
    }
    if (isHorizontal) {
      return _maxImgHeight + padding.top + padding.bottom;
    } else {
      final dw = getWidth() - padding.left - padding.right;
      final totalHeight = items.map((e) {
        final thisScale = e.getWidth() / dw;
        return e.getHeight() / thisScale;
      }).reduce((a, b) => a + b);
      return totalHeight + totalSpacing + padding.top + padding.bottom;
    }
  }

  /// 总共的间隙
  double get totalSpacing => spacing * (items.length - 1);

  updateImagesChange() {
    if (items.isEmpty) {
      _maxImgWidth = 0;
      _maxImgHeight = 0;
    } else {
      _maxImgWidth = _getMaxWidth();
      _maxImgHeight = _getMaxHeight();
    }
    notifyListeners();
  }

  double _getMaxWidth() {
    return items.map((e) => e.getWidth() * scale).reduce(max).toDouble();
  }

  double _getMaxHeight() {
    return items.map((e) => e.getHeight() * scale).reduce(max).toDouble();
  }

  /// 添加一张图片
  void appendImage() async {
    items.addAll(await Joint2Image.getImages());
    updateImagesChange();
  }

  void appendTextItem(Joint2Text data) async {
    assert(data.type == JointType.text);
    items.add(data);
    updateImagesChange();
  }

  /// 清除所有
  clear() {
    items.clear();
    updateImagesChange();
    Fluttertoast.showToast(
      msg: 'Cleared',
    );
  }

  /// 设置是否水平分布
  setHorizontal(bool val) {
    if (isHorizontal != val) {
      isHorizontal = val;
      notifyListeners();
    }
  }

  /// 设置间隙
  setSpacing(double val) {
    if (spacing != val) {
      spacing = val;
      notifyListeners();
    }
  }

  /// 设置 padding
  setPadding(EdgeInsets val) {
    if (padding != val) {
      padding = val;
      notifyListeners();
    }
  }

  /// 设置背景颜色
  setBgColor(Color c) {
    if (bgColor != c) {
      bgColor = c;
      notifyListeners();
    }
  }

  /// 设置圆角
  setRadius(Radius val) {
    radius = val;
    notifyListeners();
  }

  void applyNewList(List<JointItem2> newList) {
    items = newList;
    updateImagesChange();
  }

  void setShadowElevation(double newVal) {
    shadowElevation = newVal;
    notifyListeners();
  }

  void setShadowOffset({double? dx, double? dy}) {
    if (dx != null) {
      shadowOffset = Offset(dx, shadowOffset.dy);
    }
    if (dy != null) {
      shadowOffset = Offset(shadowOffset.dx, dy);
    }
    notifyListeners();
  }

  void setShadowColor(Color newColor) {
    shadowColor = newColor;
    notifyListeners();
  }

  void paint(Canvas canvas, Size size) {
    if (items.isEmpty) {
      return;
    }
    double maxWidth = _getMaxWidth();
    double maxHeight = _getMaxHeight();
    Size maxSize = Size(maxWidth, maxHeight);
    double viewportWidth = getWidth();
    double viewportHeight = getHeight();
    Offset currPos = Offset(padding.left, padding.top);

    // 绘制纯色背景
    final bgPaint = Paint()..color = bgColor;
    final bgRect = Rect.fromLTWH(0, 0, getWidth(), getHeight());
    canvas.drawRect(bgRect, bgPaint);

    // final textSpan = TextSpan(
    //   text: title,
    //   style: GoogleFonts.maShanZheng(
    //     textStyle: const TextStyle(
    //       fontSize: 300,
    //       color: Colors.black,
    //       height: 1,
    //     ),
    //   ),
    // );
    // final textPainter = TextPainter(
    //   text: textSpan,
    //   textDirection: TextDirection.ltr,
    //   textAlign: TextAlign.center,
    // );
    // textPainter.layout(
    //   maxWidth: viewportWidth,
    // );
    // Offset titleOffset;
    // if (isHorizontal) {
    //   titleOffset = Offset(currLeft, (viewportHeight - textPainter.height) / 2);
    //   currLeft += textPainter.width + spacing;
    // } else {
    //   titleOffset = Offset((viewportWidth - textPainter.width) / 2, 100);
    // }
    // textPainter.paint(canvas, titleOffset);

    for (var item in items) {
      final offset = item.draw(canvas, this, maxSize, currPos);
      currPos.translate(offset.dx, offset.dy);
    }
  }

  Future<Uint8List> export() async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final w = getWidth();
    final h = getHeight();
    paint(canvas, ui.Size(w, h));
    final pic = recorder.endRecording();
    final img = await pic.toImage(w.toInt(), h.toInt());
    final stopwatch3 = Stopwatch()..start();
    final pngBytes = await img.toByteData(format: ui.ImageByteFormat.png);
    print("toByteData ${stopwatch3.elapsed}");
    return Uint8List.view(pngBytes!.buffer);
  }

  void saveSetting(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        var oldName = presetName;
        var oldRemark = presetRemark;
        return AlertDialog(
          title: const Text('New Preset'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Save your current setting to presets'),
              TextField(
                controller: TextEditingController(text: presetName),
                onChanged: (str) => presetName = str,
                decoration: const InputDecoration(
                  labelText: 'Preset Name',
                ),
              ),
              TextField(
                controller: TextEditingController(text: presetRemark),
                onChanged: (str) => presetRemark = str,
                decoration: const InputDecoration(
                  labelText: 'Preset Remark',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                presetName = oldName;
                presetRemark = oldRemark;
              },
              child: const Text(
                'cancel',
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                final jsonStr = const JsonEncoder().convert(this);
                const key = 'presets';
                final stringList = Utils.prefs.getStringList(key) ?? [];
                stringList.add(jsonStr);
                Utils.prefs.setStringList(key, stringList);
                // print("saved");
                Navigator.of(context).pop();
                Utils.toast('Preset Saved');
              },
              child: const Text('save'),
            ),
          ],
        );
      },
    );
  }
}