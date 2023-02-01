import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:omelet/pages/image_joint/image_editor_painter.dart';
import 'package:omelet/widgets/cell.dart';

import '../../common/index.dart';

class ImageJointPresets extends StatefulWidget {
  const ImageJointPresets({Key? key}) : super(key: key);

  @override
  State<ImageJointPresets> createState() => _ImageJointPresetsState();
}

class _ImageJointPresetsState extends State<ImageJointPresets> {
  static const presetsKey = 'presets';
  late List<ImageEditorPainterController> controllers;

  late List<String> stringList;

  @override
  void initState() {
    stringList = Utils.prefs.getStringList(presetsKey) ?? [];
    final Iterable<Map<String, dynamic>> jsonList =
        stringList.map((e) => jsonDecode(e));
    controllers = jsonList.map(ImageEditorPainterController.fromJson).toList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Presets'),
      ),
      body: controllers.isNotEmpty
          ? Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
              child: SingleChildScrollView(
                child: Column(
                  children: List.generate(controllers.length, _genItem),
                ),
              ),
            )
          : const Center(child: Text("Empty", style: Ts.grey)),
    );
  }

  Widget _genItem(int index) {
    final ctrl = controllers[index];
    return Cell(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
      divider: const Divider(height: 1),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(ctrl.presetName, style: Ts.s16),
          const SizedBox(height: 4),
          Text(ctrl.presetRemark, style: Ts.s12 | Ts.grey),
        ],
      ),
      trailing: Row(
        children: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(ctrl);
            },
            style: const ButtonStyle(
              padding: MaterialStatePropertyAll(EdgeInsets.all(0)),
              backgroundColor: MaterialStatePropertyAll(Colors.yellow),
            ),
            child: const Text('Apply', style: Ts.black),
          ),
          const SizedBox(width: 10),
          ElevatedButton(
            onPressed: () {
              setState(() {
                stringList.removeAt(index);
                controllers.removeAt(index);
                Utils.prefs.setStringList(presetsKey, stringList);
                Utils.toast('Preset ${ctrl.presetName} Deleted');
              });
            },
            style: const ButtonStyle(
              padding: MaterialStatePropertyAll(EdgeInsets.all(0)),
              backgroundColor: MaterialStatePropertyAll(Colors.red),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
