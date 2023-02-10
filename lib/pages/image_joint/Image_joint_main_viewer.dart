
import 'package:flutter/material.dart';
import 'package:omelet/common/index.dart';
import 'package:omelet/pages/image_joint/image_editor_painter.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';
import 'dart:ui' as ui;

class ImageJointMainViewer extends StatelessWidget {
  const ImageJointMainViewer({
    Key? key,
    required this.viewerHeight,
    required this.controller,
    this.fitScreen = false,
  }) : super(key: key);

  final double viewerHeight;
  final ImageEditorPainterController controller;
  final bool fitScreen;

  @override
  Widget build(BuildContext context) {
    final viewerWidth = ScreenAdaptor.screenWidth;
    return SizedBox(
      height: viewerHeight,
      width: double.infinity,
      child: Center(
        child: Selector<ImageEditorPainterController, bool>(
          selector: (_, controller) => controller.isHorizontal,
          builder: (_, isHorizontal, child) {
            return SingleChildScrollView(
              scrollDirection: isHorizontal ? Axis.horizontal : Axis.vertical,
              child: child,
            );
          },
          child: ColoredBox(
            color: Colors.grey.shade400,
            child: Center(
              child: Selector<ImageEditorPainterController, Tuple2<ui.Size, bool>>(
                selector: (_, controller) {
                  return Tuple2(ui.Size(controller.getWidth(), controller.getHeight()), controller.isHorizontal,);
                },
                builder: (context, tuple, child) {
                  final size = tuple.item1;
                  final isHorizontal = tuple.item2;
                  if (size.width == 0 || size.height == 0) {
                    return const SizedBox.shrink();
                  }
                  final double scale = (() {
                    // final isHorizontal = value.width > value.height;
                    // final viewerFactor = viewerWidth / viewerHeight;
                    // final imgFactor = value.width / value.height; // 值越大，越扁
                    final scaleW = viewerWidth / size.width;
                    final scaleH = viewerHeight / size.height;
                    // print("viewer: $viewerFactor, $imgFactor $fitScreen");
                    if (fitScreen) {
                      if (isHorizontal) {
                        return scaleW;
                      } else {
                        // 是否适应屏幕，否则是居中
                        if (scaleH * size.width > viewerWidth) {
                          return scaleW;
                        }
                        return scaleH;
                      }
                    } else {
                      if (isHorizontal) {
                        return scaleH;
                      }
                      return scaleW;
                    }
                  })();

                  return Transform.scale(
                    scale: scale,
                    origin: Offset.zero,
                    alignment: Alignment.topLeft,
                    child: CustomPaint(
                      size: size * scale,
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
    );
  }
}