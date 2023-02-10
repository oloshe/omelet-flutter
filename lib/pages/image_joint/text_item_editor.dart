import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TextItemEditor extends StatefulWidget {
  const TextItemEditor({Key? key}) : super(key: key);

  @override
  State<TextItemEditor> createState() => _TextItemEditorState();
}

class _TextItemEditorState extends State<TextItemEditor> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Container(
        width: 300,
        height: 300,
        child: Column(
          children: [
            Container(
              width: double.infinity,
              height: 100,
              color: Colors.green,
              child: CustomPaint(
                painter: TextItemPainter(TextItemData(
                  'Test',
                  Colors.black,
                )),
              ),
            ),
            TextField(
              decoration: InputDecoration(
                hintText: "Enter text here",
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Text size",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  "Text color",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                DropdownButton<int>(
                  items: [
                    DropdownMenuItem(
                      child: Text("12"),
                      value: 12,
                    ),
                    DropdownMenuItem(
                      child: Text("14"),
                      value: 14,
                    ),
                    DropdownMenuItem(
                      child: Text("16"),
                      value: 16,
                    ),
                  ],
                  onChanged: (value) {
                    // do something with the selected text size
                  },
                ),
                DropdownButton<Color>(
                  items: [
                    DropdownMenuItem(
                      child: Container(
                        width: 20,
                        height: 20,
                        color: Colors.red,
                      ),
                      value: Colors.red,
                    ),
                    DropdownMenuItem(
                      child: Container(
                        width: 20,
                        height: 20,
                        color: Colors.blue,
                      ),
                      value: Colors.blue,
                    ),
                    DropdownMenuItem(
                      child: Container(
                        width: 20,
                        height: 20,
                        color: Colors.green,
                      ),
                      value: Colors.green,
                    ),
                  ],
                  onChanged: (value) {
                    // do something with the selected text color
                  },
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        ElevatedButton(
          child: Text("Cancel"),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        ElevatedButton(
          child: Text("Confirm"),
          onPressed: () {
            // onTap function goes here
          },
        ),
      ],
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
    textPainter.paint(canvas, Offset((size.width - textPainter.width) / 2, (size.height - textPainter.height) / 2));
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
