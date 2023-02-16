import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:omelet/common/index.dart';
import 'package:omelet/pages/image_joint/image_editor_painter.dart';
import 'package:omelet/pages/image_joint/joint_item.dart';
import 'package:omelet/widgets/cell.dart';
import 'package:provider/provider.dart';

class TextItemEditor extends StatefulWidget {
  final JointText? itemValue;
  final ImageEditorPainterController controller;
  const TextItemEditor({Key? key, this.itemValue, required this.controller})
      : super(key: key);

  @override
  State<TextItemEditor> createState() => _TextItemEditorState();
}

class _TextItemEditorState extends State<TextItemEditor> {
  late final JointText data;
  late final TextEditingController textEditingController;

  late final state = VM(data);

  static const textAlignItems = <_TextAlignArrItem>[
    _TextAlignArrItem(
      JointTextAlign.left,
      Icons.format_align_left,
    ),
    _TextAlignArrItem(
      JointTextAlign.center,
      Icons.format_align_center,
    ),
    _TextAlignArrItem(
      JointTextAlign.right,
      Icons.format_align_right,
    ),
  ];

  @override
  void initState() {
    if (widget.itemValue != null) {
      data = widget.itemValue!;
    } else {
      data = JointText(
        textStr: '',
        textColor: Colors.black,
        textHeight: 200,
        textWidth: widget.controller.maxItemWidth,
        fontSize: JointFontSize.middle,
        textAlign: JointTextAlign.left,
      );
    }
    textEditingController = TextEditingController(text: data.textStr);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: state,
      builder: (context, child) => AlertDialog(
        contentPadding: const EdgeInsets.symmetric(
          vertical: 15,
          horizontal: 15,
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: double.infinity,
                height: 120,
                color: Colors.grey.shade300,
                child: CustomPaint(
                  painter: _TextItemPainter(state),
                ),
              ),
              const SizedBox(height: 5),
              TextField(
                controller: textEditingController,
                decoration: const InputDecoration(
                    hintText: "Enter text here",
                    labelStyle: Ts.s8,
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.all(10)),
                maxLines: 5,
                style: Ts.s12,
                onChanged: (str) {
                  state.value.textStr = str;
                  state.forceUpdate();
                },
              ),
              const SizedBox(height: 5),
              Cell(
                padding: const EdgeInsets.symmetric(vertical: 10),
                leading: const Text("Text Size"),
                trailing: VMSelector<JointText, JointFontSize?>(
                  selector: (_, s) => s.value.fontSize,
                  builder: (_, fontSize, child) =>
                      DropdownButton<JointFontSize>(
                    items: JointFontSize.values
                        .map((e) => DropdownMenuItem(
                              value: e,
                              child: Text(e.toShortString()),
                            ))
                        .toList(growable: false),
                    value: fontSize,
                    onChanged: (value) {
                      if (value != null) {
                        state.value.fontSize = value;
                        state.forceUpdate();
                      }
                    },
                  ),
                ),
              ),
              DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(width: 1),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(1),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Row(
                      children: List.generate(
                        textAlignItems.length * 2 - 1,
                        (index) {
                          if (index % 2 != 0) {
                            return Container(
                              width: 0.1,
                              height: 20,
                              color: Colors.grey.shade700,
                            );
                          }
                          final item = textAlignItems[index ~/ 2];
                          return VMSelector<JointText, JointTextAlign>(
                            selector: (_, s) => s.value.textAlign,
                            builder: (_, textAlign, child) {
                              final active = textAlign == item.value;
                              return Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    state.value.textAlign = item.value;
                                    state.forceUpdate();
                                  },
                                  child: ColoredBox(
                                    color: active
                                        ? Colors.orange.shade200
                                        : Colors.transparent,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 4),
                                      child: Icon(
                                        item.icon,
                                        color: active
                                            ? Colors.white
                                            : Colors.black,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
              Cell(
                padding: const EdgeInsets.symmetric(vertical: 10),
                leading: const Text("Text Color"),
                trailing: VMSelector<JointText, Color>(
                  selector: (_, s) => s.value.textColor,
                  builder: (context, color, child) => GestureDetector(
                    onTap: () async {
                      final newColor =
                          await Utils.showColorPicker(context, color);
                      if (newColor != null &&
                          state.value.textColor != newColor) {
                        state.value.textColor = newColor;
                        state.forceUpdate();
                      }
                    },
                    child: Container(
                      width: 24,
                      height: 24,
                      color: color,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            child: const Text("Cancel"),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          ElevatedButton(
            child: const Text("Confirm"),
            onPressed: () {
              if (data.textStr.isEmpty) {
                Navigator.of(context).pop();
              } else {
                data.applyFontSize(widget.controller.maxItemWidth);
                Navigator.of(context).pop(data);
              }
            },
          ),
        ],
      ),
    );
  }
}

class _TextItemPainter extends CustomPainter {
  final VM<JointText> textData;
  const _TextItemPainter(this.textData) : super(repaint: textData);

  @override
  void paint(Canvas canvas, Size size) {
    if (textData.value.textStr.isEmpty) {
      const textSpan = TextSpan(
        text: 'Say Your Story',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
          color: Colors.grey,
          height: 1,
        ),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout(
        maxWidth: size.width,
      );
      textPainter.paint(
        canvas,
        Offset((size.width - textPainter.width) / 2,
            (size.height - textPainter.height) / 2),
      );
    } else {
      textData.value.drawPreview(canvas, size);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

class _TextAlignArrItem {
  final JointTextAlign value;
  final IconData icon;
  const _TextAlignArrItem(this.value, this.icon);
}
