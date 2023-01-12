import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

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

  /// 是否是水平
  bool isHorizontal = false;

  /// 间隔
  double spacing = 0;

  /// 白边
  EdgeInsets padding = EdgeInsets.zero;

  /// 背景颜色
  Color bgColor = Colors.white;

  double _maxImgWidth = 0;
  double _maxImgHeight = 0;

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
    _maxImgWidth = items.map((e) => e.width).reduce(max).toDouble();
    _maxImgHeight = items.map((e) => e.height).reduce(max).toDouble();
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
      item.drawImageRect(canvas, src, dest, Paint());
    }
  }

  Future<Uint8List> export() async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final w = getWidth();
    final h = getHeight();
    paint(canvas, ui.Size(w, h));
    final pic = recorder.endRecording();
    print(">>> $w $h");
    final img = await pic.toImage(w.toInt(), h.toInt());
    final pngBytes = await img.toByteData(format: ui.ImageByteFormat.png);
    return Uint8List.view(pngBytes!.buffer);
  }

  void applyReorder(List<JointItem> newList) {
    assert(items.length == newList.length);
    items = newList;
    notifyListeners();
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
    switch(type) {
      case JointType.image: {
        return image!.height;
      }
    }
  }
  int get width {
    switch(type) {
      case JointType.image: {
        return image!.width;
      }
    }
  }

  void drawImageRect(Canvas canvas, Rect src, Rect dest, Paint paint) {
    if (image != null) {
      canvas.drawImageRect(image!, src, dest, paint);
    }
  }

  @override
  String toString() {
    return 'JoinItem($type)';
  }
}
