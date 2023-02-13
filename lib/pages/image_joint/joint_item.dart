import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:omelet/pages/image_joint/image_editor_painter.dart';
import 'dart:ui' as ui;

enum JointType {
  image,
  text,
}

abstract class JointItem2 {
  final JointType type;
  final Key key = UniqueKey();

  JointItem2(this.type);
  Offset draw(
    Canvas canvas,
    ImageEditorPainterController controller,
    Size maxSize,
    Offset offset,
  );
  int getWidth();
  int getHeight();
  Widget thumbnail();
  @override
  String toString() {
    return 'JoinItem($type)';
  }
}

class Joint2Image extends JointItem2 {
  ui.Image image;
  Uint8List imageData;
  String imagePath;
  Joint2Image(this.image, this.imageData, this.imagePath)
      : super(JointType.image);

  @override
  Offset draw(
    Canvas canvas,
    ImageEditorPainterController controller,
    Size maxSize,
    Offset offset,
  ) {
    final itemWidth = getWidth().toDouble();
    final itemHeight = getHeight().toDouble();
    final Rect src = Rect.fromLTWH(0, 0, itemWidth, itemHeight);
    late final Rect dest;
    late Offset result;
    if (controller.isHorizontal) {
      final thisScale = itemHeight / maxSize.height;
      final dw = itemWidth / thisScale;
      dest = Rect.fromLTWH(offset.dx, offset.dy, dw, maxSize.height);
      result = Offset(dw + controller.spacing, 0);
    } else {
      final thisScale = itemWidth / maxSize.width;
      final dh = itemHeight / thisScale;
      dest = Rect.fromLTWH(offset.dx, offset.dy, maxSize.width, dh);
      result = Offset(0, dh + controller.spacing);
    }

    final radius = controller.radius;
    // 阴影
    Path path = Path()
      ..addRRect(RRect.fromLTRBAndCorners(
        dest.left + controller.shadowOffset.dx / 2,
        dest.top + controller.shadowOffset.dy / 2,
        dest.right + controller.shadowOffset.dx / 2,
        dest.bottom + controller.shadowOffset.dy / 2,
        topLeft: radius,
        topRight: radius,
        bottomLeft: radius,
        bottomRight: radius,
      ));
    canvas.drawShadow(
      path,
      controller.shadowColor,
      controller.shadowElevation,
      true,
    );
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

    canvas.drawImageRect(image, src, dest, Paint());
    canvas.restore();

    return result;
  }

  @override
  int getHeight() {
    return image.height;
  }

  @override
  int getWidth() {
    return image.width;
  }

  void changeCroppedImg(CroppedFile file) async {
    imagePath = file.path;
    imageData = await file.readAsBytes();
    image = await ImageEditorPainter.loadImage(imageData);
  }

  static Future<List<JointItem2>> getImages() async {
    final picker = ImagePicker();
    final ret = await picker.pickMultiImage();
    List<JointItem2> result = [];
    for (var file in ret) {
      final bytes = await file.readAsBytes();
      final img = await ImageEditorPainter.loadImage(bytes);
      result.add(Joint2Image(img, bytes, file.path));
    }
    return result;
  }

  @override
  Widget thumbnail() {
    return ColoredBox(
      color: Colors.black,
      child: Image.memory(
        imageData,
        width: 60,
        height: 60,
      ),
    );
  }
}


enum JointTextSize {
  small,
  middle,
  large,
}

extension JointTextSizeToString on JointTextSize {
  String toShortString() {
    return toString().split('.').last;
  }
}

class Joint2Text extends JointItem2 {
  String textStr;
  Color textColor;
  double textWidth;
  double textHeight;
  JointTextSize fontSize;

  Joint2Text({
    required this.textStr,
    required this.textColor,
    required this.textWidth,
    required this.textHeight,
    required this.fontSize,
  }) : super(JointType.text);

  @override
  Offset draw(Canvas canvas, ImageEditorPainterController controller,
      Size maxSize, Offset offset) {
    return Offset.zero;
  }

  @override
  int getHeight() {
    return textHeight.toInt();
  }

  @override
  int getWidth() {
    return textWidth.toInt();
  }

  @override
  Widget thumbnail() {
    return ColoredBox(
      color: Colors.black,
      child: Text(textStr[0]),
    );
  }
}
