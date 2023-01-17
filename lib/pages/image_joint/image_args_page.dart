import 'package:flutter/material.dart';
import 'package:omelet/common/index.dart';
import 'package:omelet/pages/image_joint/image_editor_painter.dart';
import 'package:omelet/pages/image_joint/image_joint_page.dart';
import 'package:omelet/widgets/cell.dart';
import 'package:provider/provider.dart';

class ImageArgData<T, R> {
  final String name;
  final double min;
  final double max;
  final double initialValue;
  final ValueChanged<double> onChanged;
  final R Function(T) selector;
  const ImageArgData({
    required this.name,
    required this.min,
    required this.max,
    required this.initialValue,
    required this.selector,
    required this.onChanged,
  });
}

typedef _ThisSelector<T> = Selector<ArgsPageController, T>;

class ImageArgsPage<T, R> extends StatefulWidget {
  final ImageEditorPainterController controller;
  final List<ImageArgData<T, R>> data;
  final int initialIndex;
  const ImageArgsPage({
    Key? key,
    required this.controller,
    required this.data,
    this.initialIndex = 0,
  })  : assert(data.length != 0),
        assert(initialIndex < data.length && initialIndex >= 0),
        super(key: key);

  @override
  State<ImageArgsPage> createState() => _ImageArgsPageState<T, R>();
}

class _ImageArgsPageState<T, R> extends State<ImageArgsPage<T, R>> {
  late ArgsPageController controller = ArgsPageController(
    currIndex: widget.initialIndex,
    posY: -widget.initialIndex * cellHeight,
    allProgressValues:
        widget.data.map((e) => e.initialValue).toList(growable: false),
  );

  // VM<double> currPos = VM(0);
  // late VM<int> currIndex = VM(widget.initialIndex);
  late double maxHeight;

  ImageArgData<T, R> get currData => widget.data[controller.currIndex];

  @override
  void initState() {
    maxHeight = cellHeight * (widget.data.length - 1);
    super.initState();
  }

  static const double cellHeight = 60;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.white,
      child: SafeArea(
        child: Scaffold(
          body: MultiProvider(
            providers: [
              ChangeNotifierProvider.value(value: widget.controller),
              ChangeNotifierProvider.value(value: controller),
            ],
            child: ColoredBox(
              color: Colors.grey.shade700,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  LayoutBuilder(
                    builder: (context, constraint) {
                      return ImageJointMainViewer(
                        viewerHeight: constraint.maxHeight,
                        controller: widget.controller,
                        fitScreen: true,
                      );
                    },
                  ),
                  _ThisSelector<double>(
                    selector: (_, __) => controller.currProgressValue,
                    builder: (context, progress, child) {
                      return _TopProgressBar(percent: progress);
                    },
                  ),
                  _ThisSelector<bool>(
                    selector: (_, __) => controller.isChangingIndex,
                    builder: (context, isChangingIndex, child) {
                      return Opacity(
                        opacity: isChangingIndex ? 1 : 0,
                        child: child,
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 50),
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          _ThisSelector(
                            selector: (_, __) => controller.posY,
                            builder: (context, pos, child) {
                              return Positioned(
                                top: pos,
                                left: 0,
                                right: 0,
                                child: child!,
                              );
                            },
                            child: ColoredBox(
                              color: Colors.grey.shade700.withOpacity(0.92),
                              child: DefaultTextStyle.merge(
                                style: Ts.white,
                                child: _ThisSelector<int>(
                                  selector: (_, __) => controller.currIndex,
                                  builder: (context, index, child) {
                                    return Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        for (final data in widget.data)
                                          data.name == currData.name
                                              ? const SizedBox(
                                                  height: cellHeight)
                                              : Cell(
                                                  title: Text(data.name),
                                                  height: cellHeight,
                                                  textStyle: Ts.s14,
                                                  trailing: Selector<T, R>(
                                                    selector: (_, controller) =>
                                                        data.selector(
                                                            controller),
                                                    builder:
                                                        (context, val, child) {
                                                      return Text(
                                                          val.toString());
                                                    },
                                                  ),
                                                ),
                                      ],
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                          ColoredBox(
                            color: Colors.blue.shade300.withOpacity(0.9),
                            child: DefaultTextStyle.merge(
                              style: Ts.white,
                              child: _ThisSelector<int>(
                                selector: (_, __) => controller.currIndex,
                                builder: (context, index, child) {
                                  return Cell(
                                    title: Text(currData.name),
                                    height: cellHeight,
                                    textStyle: Ts.s14,
                                    trailing: Selector<T, R>(
                                      selector: (_, controller) =>
                                          currData.selector(controller),
                                      builder: (context, val, child) {
                                        return Text(val.toString());
                                      },
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      print("onTap");
                    },
                    onHorizontalDragUpdate: (detail) {
                      var newVal = controller.currProgressValue +
                          (detail.delta.dx / 100);
                      if (newVal > 1.0) newVal = 1.0;
                      if (newVal < 0.0) newVal = 0.0;
                      if (newVal != controller.currProgressValue) {
                        controller.setCurrProgress(newVal);
                        final data = currData;
                        data.onChanged(
                            (data.max - data.min) * newVal + data.min);
                      }
                    },
                    onVerticalDragUpdate: (detail) {
                      var newVal = controller.posY + (detail.delta.dy);
                      if (newVal > 0) newVal = 0;
                      if (newVal < -maxHeight) newVal = -maxHeight;
                      if (newVal != controller.posY) {
                        controller.setPosY(newVal);
                        var index =
                            ((-newVal - (cellHeight / 2)) / cellHeight).ceil();
                        if (index != controller.currIndex) {
                          controller.setCurrIndex(index);
                        }
                      }
                    },
                    onVerticalDragStart: (_) {
                      controller.setIsChangingIndex(true);
                    },
                    onVerticalDragEnd: (_) {
                      controller.setIsChangingIndex(false);
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TopProgressBar extends StatelessWidget {
  final double? percent;
  const _TopProgressBar({
    Key? key,
    this.percent,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ColoredBox(
        color: Colors.grey,
        child: SizedBox(
          width: double.infinity,
          height: 8,
          child: Align(
            alignment: Alignment.centerLeft,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return ColoredBox(
                  color: Colors.yellow,
                  child: SizedBox(
                    height: double.infinity,
                    width: constraints.maxWidth * (percent ?? 0),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class ArgsPageController with ChangeNotifier {
  double posY;
  int currIndex;
  double progressValue;
  List<double> allProgressValues;
  bool isChangingIndex = false;

  double get currProgressValue => allProgressValues[currIndex];

  ArgsPageController({
    required this.posY,
    required this.currIndex,
    required this.allProgressValues,
  }) : progressValue = allProgressValues[currIndex];

  void setPosY(double pos) {
    posY = pos;
    notifyListeners();
  }

  void setCurrIndex(int index) {
    currIndex = index;
    notifyListeners();
  }

  void setProgressValue(double value) {
    progressValue = value;
    notifyListeners();
  }

  void setCurrProgress(double val) {
    allProgressValues[currIndex] = val;
    notifyListeners();
  }

  void setIsChangingIndex(bool val) {
    isChangingIndex = val;
    notifyListeners();
  }
}
