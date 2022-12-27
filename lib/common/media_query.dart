import 'package:flutter/cupertino.dart';

class ScreenAdaptor extends StatefulWidget with WidgetsBindingObserver {
  /// 设计分辨率750*1334
  static const double designedWidth = 750;
  static const double designedHeight = 1334;

  static late double _screenWidth;
  static late double _screenHeight;
  static late double _scale;

  static double get screenWidth => _screenWidth;
  static double get screenHeight => _screenHeight;
  static double get scale => _scale;
  static MediaQueryData get mediaQuery => MediaQueryData.fromWindow(WidgetsBinding.instance.window);

  final Widget child;

  ScreenAdaptor({required this.child, super.key});

  static void _init() {
    final mq = mediaQuery;
    _screenWidth = mq.size.width;
    _screenHeight = mq.size.height;
    // 对于长宽比小于设计长宽比的设备，例如iPad，按高度进行缩放
    if (_screenHeight / _screenWidth < designedHeight / designedWidth) {
      _scale = _screenHeight / designedHeight;
    } else {
      // 其余设备按宽度进行缩放
      _scale = _screenWidth / designedWidth;
    }
  }

  @override
  State<ScreenAdaptor> createState() => _ScreenAdaptorState();
}

class _ScreenAdaptorState extends State<ScreenAdaptor> {

  @override
  void initState() {
    super.initState();
    ScreenAdaptor._init();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}