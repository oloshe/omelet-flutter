import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';

import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:image_picker/image_picker.dart';
import 'package:omelet/common/media_query.dart';
import 'package:omelet/ext/index.dart';
import 'package:omelet/painter/image_editor.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

void main() {
  LicenseRegistry.addLicense(() async* {
    final license = await rootBundle.loadString('google_fonts/OFL.txt');
    yield LicenseEntryWithLineBreaks(['google_fonts'], license);
  });
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
      debugShowCheckedModeBanner: false,
      home: ScreenAdaptor(
        child: MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  ImageEditorController controller = ImageEditorController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Omelet - Image Joint Editor",
          style: GoogleFonts.maShanZheng(
            textStyle: const TextStyle(
              fontSize: 24,
            ),
          ),
        ),
      ),
      body: MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: controller),
          ],
          builder: (context, child) {
            return SingleChildScrollView(
              child: SizedBox(
                width: double.infinity,
                child: Column(
                  // mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 10,
                        left: 10,
                        right: 10,
                      ),
                      child: Row(
                        children: [
                          ElevatedButton(
                            onPressed: () async {
                              final picker = ImagePicker();
                              final ret = await picker.pickMultiImage();
                              for (var file in ret) {
                                final list = await file.readAsBytes();
                                final img =
                                    await ImageEditorPainter.loadImage(list);
                                controller.appendImage(img);
                              }
                            },
                            child: Row(
                              children: const [
                                Icon(Icons.add),
                                Text("Append"),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton(
                            onPressed: () async {
                              var status = await Permission.storage.status;
                              if (!status.isGranted) {
                                await Permission.storage.request();
                              }
                              final img = await controller.export();
                              await ImageGallerySaver.saveImage(img);
                            },
                            style: const ButtonStyle(
                              backgroundColor:
                                  MaterialStatePropertyAll(Colors.green),
                            ),
                            child: Row(
                              children: const [
                                Icon(Icons.save),
                                SizedBox(width: 2),
                                Text("Save"),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton(
                            onPressed: () {
                              controller.clear();
                            },
                            style: const ButtonStyle(
                              backgroundColor:
                                  MaterialStatePropertyAll(Colors.redAccent),
                            ),
                            child: Row(
                              children: const [
                                Icon(Icons.clear),
                                Text("Clear")
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Selector<ImageEditorController, double>(
                      selector: (context, val) => val.spacing,
                      builder: (context, val, child) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Row(
                            children: [
                              const Text("Spacing"),
                              const SizedBox(width: 20),
                              Text(val.toStringAsFixed(1)),
                              Expanded(
                                child: Slider(
                                  value: val,
                                  min: 0,
                                  max: 50,
                                  onChanged: (val) {
                                    controller.setSpacing(val);
                                  },
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    Selector<ImageEditorController, EdgeInsets>(
                      selector: (context, val) => val.padding,
                      builder: (context, val, child) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  const Text("Padding Y"),
                                  const SizedBox(width: 20),
                                  Text(val.top.toStringAsFixed(1)),
                                  Expanded(
                                    child: Slider(
                                      value: val.top,
                                      min: 0,
                                      max: 30,
                                      onChanged: (newVal) {
                                        controller.setPadding(
                                          val.copyWith(
                                              top: newVal, bottom: newVal),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  const Text("Padding X"),
                                  const SizedBox(width: 20),
                                  Text(val.left.toStringAsFixed(1)),
                                  Expanded(
                                    child: Slider(
                                      value: val.left,
                                      min: 0,
                                      max: 30,
                                      onChanged: (newVal) {
                                        controller.setPadding(
                                          val.copyWith(
                                              left: newVal, right: newVal),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              const Text("Background"),
                              const SizedBox(width: 20),
                              Selector<ImageEditorController, Color>(
                                selector: (_, val) => val.bgColor,
                                builder: (_, color, child) => ColoredBox(
                                  color: color,
                                  child: SizedBox.fromSize(
                                    size: const ui.Size.fromRadius(15),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 20),
                              TextButton(
                                onPressed: () {
                                  Color selectColor = controller.bgColor;
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: const Text('Pick a color!'),
                                        content: SingleChildScrollView(
                                          child: SlidePicker(
                                            pickerColor: controller.bgColor,
                                            onColorChanged: (clr) {
                                              selectColor = clr;
                                            },
                                          ),
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              controller
                                                  .setBgColor(selectColor);
                                              Navigator.of(context).pop();
                                            },
                                            child: const Text('Got it'),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                                child: const Text(
                                  'Pick Color',
                                  style: TextStyle(
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(left: 10),
                      child: SizedBox(
                        height: 40,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Preview",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Selector<ImageEditorController, ui.Size>(
                      selector: (context, val) {
                        return ui.Size(val.getWidth(), val.getHeight());
                      },
                      builder: (context, value, child) {
                        var scale = value.width == 0
                            ? 1.0
                            : ScreenAdaptor.screenWidth / value.width;
                        return Transform.scale(
                          scale: scale,
                          origin: Offset.zero,
                          alignment: Alignment.topLeft,
                          child: CustomPaint(
                            size: value * scale,
                            painter: ImageEditorPainter(
                              controller: controller,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          }),
    );
  }
}
