import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:omelet/common/media_query.dart';

class ImageEditorPainter extends CustomPainter {
  ImageEditorController controller;

  ImageEditorPainter({required this.controller}): super(repaint: controller);

  static Future<ui.Image> loadImage(Uint8List imageData) async {
    final codec = await ui.instantiateImageCodec(imageData);
    final frame = await codec.getNextFrame();
    return frame.image;
  }

  @override
  void paint(Canvas canvas, Size size) {
    double currTop = controller.padding.top;
    double currLeft = controller.padding.left;
    for (var img in controller.images) {
      final w = img.width.toDouble();
      final h = img.height.toDouble();
      final Rect src = Rect.fromLTWH(0, 0, w, h);
      late final Rect dest;
      if (controller.isHorizontal) {
        final dh = ScreenAdaptor.screenHeight;
        final scale = h / dh;
        final dw = w / scale;
        dest = Rect.fromLTWH(currLeft, currTop, dw, dh);
        currLeft += dw + controller.spacing;
      } else {
        final dw = ScreenAdaptor.screenWidth;
        final scale = w / dw;
        final dh = h / scale;
        dest = Rect.fromLTWH(currLeft, currTop, dw, dh);
        currTop += dh + controller.spacing;
      }
      canvas.drawImageRect(img, src, dest, Paint());
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return controller.images.length != (oldDelegate as ImageEditorPainter).controller.images.length;
  }
}

class ImageEditorController with ChangeNotifier {
  List<ui.Image> images = [];
  /// 是否是水平
  bool isHorizontal = false;
  /// 间隔
  double spacing = 0;
  /// 白边
  EdgeInsets padding = EdgeInsets.zero;
  /// 背景颜色
  Color bgColor = Colors.white;

  appendImage(ui.Image img) {
    images.add(img);
    notifyListeners();
  }

  clear() {
    images.clear();
    notifyListeners();
  }

  setHorizontal(bool val) {
    if (isHorizontal != val) {
      isHorizontal = val;
      notifyListeners();
    }
  }

  setSpacing(double val) {
    if (spacing != val) {
      spacing = val;
      notifyListeners();
    }
  }

  setPadding(EdgeInsets val) {
    if (padding != val) {
      padding = val;
      notifyListeners();
    }
  }

  setBgColor(Color c) {
    if (bgColor != c) {
      bgColor = c;
      notifyListeners();
    }
  }
}