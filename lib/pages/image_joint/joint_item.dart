import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:omelet/common/index.dart';
import 'package:omelet/pages/image_joint/image_editor_painter.dart';
import 'dart:ui' as ui;

enum JointType {
  image,
  text,
}

abstract class JointItem {
  final JointType type;
  final Key key = UniqueKey();

  JointItem(this.type);
  Offset draw(
    Canvas canvas,
    ImageEditorPainterController controller,
    Size maxSize,
    Offset offset,
  );
  int getWidth();
  int getHeight();
  Widget thumbnail(Size size);
  @override
  String toString() {
    return 'JoinItem($type)';
  }
}

class JointImage extends JointItem {
  ui.Image image;
  Uint8List imageData;
  String imagePath;
  JointImage(this.image, this.imageData, this.imagePath)
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

  static Future<List<JointItem>> getImages() async {
    final picker = ImagePicker();
    final ret = await picker.pickMultiImage();
    List<JointItem> result = [];
    for (var file in ret) {
      final bytes = await file.readAsBytes();
      final img = await ImageEditorPainter.loadImage(bytes);
      result.add(JointImage(img, bytes, file.path));
    }
    return result;
  }

  @override
  Widget thumbnail(Size size) {
    return ColoredBox(
      color: Colors.black,
      child: Image.memory(
        imageData,
        width: size.width,
        height: size.height,
      ),
    );
  }
}

class JointText extends JointItem {
  String textStr;
  Color textColor;
  double textWidth;
  double textHeight;
  JointTextSize fontSize;
  JointTextAlign textAlign;
  double _realFontSize = 0;
  TextPainter? _textPainter;

  JointText({
    required this.textStr,
    required this.textColor,
    required this.textWidth,
    required this.textHeight,
    required this.fontSize,
    required this.textAlign,
  }) : super(JointType.text);

  @override
  Offset draw(Canvas canvas, ImageEditorPainterController controller,
      Size maxSize, Offset offset) {
    final textPainter = _textPainter ?? getTextPainter();
    textPainter.paint(canvas, offset);
    if (controller.isHorizontal) {
      return Offset(textWidth, 0);
    } else {
      return Offset(0, textHeight + controller.spacing);
    }
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
  Widget thumbnail(Size size) {
    return ColoredBox(
      color: Colors.grey.shade700,
      child: SizedBox.fromSize(
        size: size,
        child: Center(
          child: Text(
            textStr,
            style: Ts.white | Ts.s24,
          ),
        ),
      ),
    );
  }

  /// 当最大宽度变化的时候
  /// 通常是加减图片的时候调用
  void applyFontSize([double? maxWidth]) {
    final width = maxWidth ?? textWidth;
    _realFontSize = width / 10;
    final textPainter = getTextPainter(width);
    textWidth = textPainter.width;
    textHeight = textPainter.height;
  }

  TextPainter getTextPainter([double? width]) {
    final textSpan = TextSpan(
      text: textStr,
      style: GoogleFonts.maShanZheng(
        textStyle: TextStyle(
          fontSize: _realFontSize,
          color: Colors.black,
          height: 1,
        ),
      ),
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    textPainter.layout(
      maxWidth: width ?? textWidth,
    );
    _textPainter = textPainter;
    return textPainter;
  }
}

enum JointTextSize {
  small,
  middle,
  large,
}


enum JointTextAlign {
  left,
  center,
  right,
}

extension JointTextSizeToString on Enum {
  String toShortString() {
    return toString().split('.').last;
  }
}

extension JointTextAlignExt on JointTextAlign {
  TextAlign toTextAlign() {
    switch(this) {
      case JointTextAlign.left: return TextAlign.left;
      case JointTextAlign.center: return TextAlign.center;
      case JointTextAlign.right: return TextAlign.right;
    }
  }
}