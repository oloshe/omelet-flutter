import 'dart:ffi';
import 'dart:typed_data';

import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:omelet/common/media_query.dart';
import 'package:omelet/ext/index.dart';
import 'package:omelet/painter/image_editor.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ScreenAdaptor(
        child: const MyHomePage(title: '坑爹拼图'),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  ImageEditorController controller = ImageEditorController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          // mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            GestureDetector(
              onTap: () async {
                final picker = ImagePicker();
                final ret = await picker.pickImage(source: ImageSource.gallery);
                if (ret != null) {
                  final list = await ret.readAsBytes();
                  final img = await ImageEditorPainter.loadImage(list);
                  controller.appendImage(img);
                }
              },
              child: const ColoredBox(
                color: Colors.grey,
                child: SizedBox(
                  width: 200,
                  height: 100,
                  child: Icon(Icons.add, color: Colors.white),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                controller.clear();
              },
              child: const Text("Clear"),
            ),
            SizedBox(
              width: double.infinity,
              child: CustomPaint(
                painter: ImageEditorPainter(
                  controller: controller,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
