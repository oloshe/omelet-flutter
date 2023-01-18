import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:omelet/common/index.dart';

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
  List<JointItem> items = [];

  /// 预设名字
  String presetName = 'Unnamed Preset';

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

  double _maxImgWidth = 0;
  double _maxImgHeight = 0;

  ImageEditorPainterController();

  factory ImageEditorPainterController.fromJson(Map<String, dynamic> json) {
    return ImageEditorPainterController()
      ..presetName = json['presetName']
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

  /// 宽度
  double getWidth() {
    if (items.isEmpty) {
      return 0;
    }
    if (isHorizontal) {
      final dh = getHeight();
      final totalWidth = items.map((e) {
        final scale = e.height / dh;
        return e.width / scale;
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
      return _maxImgHeight;
    } else {
      final dw = getWidth() - padding.left - padding.right;
      final totalHeight = items.map((e) {
        final scale = e.width / dw;
        return e.height / scale;
      }).reduce((a, b) => a + b);
      return totalHeight + totalSpacing + padding.top + padding.bottom;
    }
  }

  /// 总共的间隙
  double get totalSpacing => spacing * (items.length - 1);

  _updateMaxImgSize() {
    if (items.isEmpty) {
      _maxImgWidth = 0;
      _maxImgHeight = 0;
    } else {
      _maxImgWidth = items.map((e) => e.width).reduce(max).toDouble();
      _maxImgHeight = items.map((e) => e.height).reduce(max).toDouble();
    }
  }

  /// 添加一张图片
  void appendImage() async {
    final picker = ImagePicker();
    final ret = await picker.pickMultiImage();
    for (var file in ret) {
      final bytes = await file.readAsBytes();
      final img = await ImageEditorPainter.loadImage(bytes);
      items.add(JointItem.image(img, bytes, UniqueKey()));
    }
    _updateMaxImgSize();
    notifyListeners();
  }

  /// 清除所有
  clear() {
    items.clear();
    _updateMaxImgSize();
    notifyListeners();
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

  void applyNewList(List<JointItem> newList) {
    items = newList;
    _updateMaxImgSize();
    notifyListeners();
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
    double maxWidth = items.map((e) => e.width).reduce(max).toDouble();
    double maxHeight = items.map((e) => e.height).reduce(max).toDouble();
    double currTop = padding.top;
    double currLeft = padding.left;
    final bgPaint = Paint()..color = bgColor;
    final bgRect = Rect.fromLTWH(0, 0, getWidth(), getHeight());
    canvas.drawRect(bgRect, bgPaint);
    for (var item in items) {
      final w = item.width.toDouble();
      final h = item.height.toDouble();
      final Rect src = Rect.fromLTWH(0, 0, w, h);
      late final Rect dest;
      if (isHorizontal) {
        final scale = h / maxHeight;
        final dw = w / scale;
        dest = Rect.fromLTWH(currLeft, currTop, dw, maxHeight);
        currLeft += dw + spacing;
      } else {
        final scale = w / maxWidth;
        final dh = h / scale;
        dest = Rect.fromLTWH(currLeft, currTop, maxWidth, dh);
        currTop += dh + spacing;
      }
      item.drawImageRect(canvas, src, dest, Paint(), this);
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
    final pngBytes = await img.toByteData(format: ui.ImageByteFormat.png);
    return Uint8List.view(pngBytes!.buffer);
  }

  void saveSetting(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        var oldName = presetName;
        return AlertDialog(
          title: const Text('Save as Preset'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Save your current setting to presets'),
              TextField(
                  controller: TextEditingController(text: presetName),
                  onChanged: (str) => presetName = str,
                  decoration: const InputDecoration(
                    labelText: 'Preset Name',
                  )),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                presetName = oldName;
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

enum JointType {
  image,
}

class JointItem {
  final JointType type;
  // image
  final ui.Image? image;
  final Uint8List? imageData;

  final Key key;
  const JointItem.image(ui.Image img, Uint8List data, this.key)
      : image = img,
        imageData = data,
        type = JointType.image;

  int get height {
    switch (type) {
      case JointType.image:
        {
          return image!.height;
        }
    }
  }

  int get width {
    switch (type) {
      case JointType.image:
        {
          return image!.width;
        }
    }
  }

  void drawImageRect(
    Canvas canvas,
    Rect src,
    Rect dest,
    Paint paint,
    ImageEditorPainterController ctrl,
  ) {
    if (image != null) {
      final radius = ctrl.radius;
      // 阴影
      Path path = Path()
        ..addRRect(RRect.fromLTRBAndCorners(
          dest.left + ctrl.shadowOffset.dx / 2,
          dest.top + ctrl.shadowOffset.dy / 2,
          dest.right + ctrl.shadowOffset.dx / 2,
          dest.bottom + ctrl.shadowOffset.dy / 2,
          topLeft: radius,
          topRight: radius,
          bottomLeft: radius,
          bottomRight: radius,
        ));
      canvas.drawShadow(path, ctrl.shadowColor, ctrl.shadowElevation, true);
      canvas.save();

      // 圆角
      if (radius != Radius.zero) {
        canvas.clipRRect(RRect.fromLTRBAndCorners(
          dest.left,
          dest.top,
          dest.right,
          dest.bottom,
          topLeft: radius,
          topRight: radius,
          bottomLeft: radius,
          bottomRight: radius,
        ));
      }

      canvas.drawImageRect(image!, src, dest, paint);
      canvas.restore();
    }
  }

  @override
  String toString() {
    return 'JoinItem($type)';
  }
}
