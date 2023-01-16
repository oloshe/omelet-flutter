import 'package:flutter/material.dart';
import 'package:omelet/common/index.dart';
import 'package:omelet/pages/image_joint/image_editor_painter.dart';
import 'package:omelet/pages/image_joint/image_joint_page.dart';
import 'package:omelet/widgets/cell.dart';
import 'package:provider/provider.dart';

class ImageArgData {
  final String displayName;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;
  const ImageArgData(this.displayName, this.min, this.max, this.onChanged);
}

class ImageArgsPage extends StatefulWidget {
  final ImageEditorPainterController controller;
  final List<ImageArgData> data;
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
  State<ImageArgsPage> createState() => _ImageArgsPageState();
}

class _ImageArgsPageState extends State<ImageArgsPage> {
  double value = 0.2;
  late int currIndex;

  @override
  void initState() {
    currIndex = widget.initialIndex;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.white,
      child: SafeArea(
        child: Scaffold(
          body: MultiProvider(
            providers: [
              ChangeNotifierProvider.value(value: widget.controller),
            ],
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
                _TopProgressBar(percent: value),
                ColoredBox(
                  color: Colors.purple,
                  child: DefaultTextStyle.merge(
                    style: Ts.white,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (final data in widget.data)
                          Cell(
                            title: Text(data.displayName),
                            trailing:
                                Selector<ImageEditorPainterController, String>(
                              selector: (_, controller) =>
                                  controller.spacing.toStringAsFixed(0),
                              builder: (context, val, child) {
                                return Text(val);
                              },
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
                    var newVal = value + (detail.delta.dx / 100);
                    if (newVal > 1.0) newVal = 1.0;
                    if (newVal < 0.0) newVal = 0.0;
                    if (newVal != value) {
                      setState(() {
                        value = newVal;
                      });
                      final data = widget.data[currIndex];
                      data.onChanged((data.max - data.min) * newVal + data.min);
                    }
                  },
                  onVerticalDragUpdate: (detail) {
                    print(">>> Change Data");
                  },
                ),
              ],
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
