import 'package:flutter/material.dart';
import 'package:omelet/common/index.dart';
import 'package:omelet/widgets/cell.dart';

class ImageJointSettingsPage extends StatefulWidget {
  const ImageJointSettingsPage({Key? key}) : super(key: key);

  @override
  State<ImageJointSettingsPage> createState() => _ImageJointSettingsPageState();
}

class _ImageJointSettingsPageState extends State<ImageJointSettingsPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
        child: Column(
          children: [
            Cell(
              height: 50,
              leading: const Text('Quality'),
              trailing: const Text('80'),
              divider: const Divider(height: 1),
              onTap: () {
                final list = List.generate(16, (index) => 20 + 5 * index);
                Utils.showPicker(
                  list: list
                      .map((e) => Text(e.toString()))
                      .toList(growable: false),
                  onSelect: (index) {
                    print(">> ${list[index]}");
                  },
                );
              },
            ),
            const Cell(
              height: 50,
              leading: Text('Image Scale'),
              trailing: Text('50%'),
              divider: Divider(height: 1),
            ),
          ],
        ),
      ),
    );
  }
}