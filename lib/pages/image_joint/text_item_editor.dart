import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:omelet/common/index.dart';
import 'package:omelet/pages/image_joint/image_editor_painter.dart';
import 'package:omelet/pages/image_joint/joint_item.dart';
import 'package:omelet/widgets/cell.dart';
import 'package:provider/provider.dart';

class TextItemEditor extends StatefulWidget {
  final Joint2Text? itemValue;
  const TextItemEditor({Key? key, this.itemValue}) : super(key: key);

  @override
  State<TextItemEditor> createState() => _TextItemEditorState();
}

class _TextItemEditorState extends State<TextItemEditor> {
  late final Joint2Text data;

  late final state = VM(data);

  @override
  void initState() {
    data = widget.itemValue ??
        Joint2Text(
          textStr: '',
          textColor: Colors.black,
          textHeight: 200,
          textWidth: 200,
          fontSize: JointTextSize.middle,
        );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: state,
      builder: (context, child) => AlertDialog(
        content: SizedBox(
          width: 300,
          height: 300,
          child: Column(
            children: [
              Container(
                width: double.infinity,
                height: 60,
                color: Colors.grey.shade300,
                child: VMSelector<Joint2Text, String>(
                  selector: (_, s) => s.value.textStr,
                  builder: (context, str, child) {
                    return CustomPaint(
                      painter: TextItemPainter(
                        TextItemData(str, Colors.black),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 5),
              TextField(
                decoration: const InputDecoration(
                  hintText: "Enter text here",
                  labelStyle: Ts.s8,
                ),
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
                trailing: VMSelector<Joint2Text, JointTextSize?>(
                  selector: (_, s) => s.value.fontSize,
                  builder: (_, fontSize, child) =>
                      DropdownButton<JointTextSize>(
                    items: JointTextSize.values
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
              Cell(
                padding: const EdgeInsets.symmetric(vertical: 10),
                leading: const Text("Text Color"),
                trailing: VMSelector<Joint2Text, Color>(
                  selector: (_, s) => s.value.textColor,
                  builder: (_, color, child) => Container(
                    width: 24,
                    height: 24,
                    color: color,
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
              Navigator.of(context).pop(data.textStr!.isEmpty ? null : data);
            },
          ),
        ],
      ),
    );
  }
}

class TextItemPainter extends CustomPainter {
  final TextItemData data;
  const TextItemPainter(this.data) : super(repaint: data);

  @override
  void paint(Canvas canvas, Size size) {
    final textSpan = TextSpan(
      text: data.text,
      style: GoogleFonts.maShanZheng(
        textStyle: TextStyle(
          fontSize: 16,
          color: data.color,
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
      maxWidth: size.width,
    );
    textPainter.paint(
        canvas,
        Offset((size.width - textPainter.width) / 2,
            (size.height - textPainter.height) / 2));
    // textPainter.paint(canvas, Offset(0, 0));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

class TextItemData with ChangeNotifier {
  String text;
  Color color;
  TextItemData(this.text, this.color);

  setText(String val) {
    text = val;
    notifyListeners();
  }

  setColor(Color val) {
    color = val;
    notifyListeners();
  }
}
