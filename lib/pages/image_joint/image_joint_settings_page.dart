import 'dart:io';

import 'package:flutter/material.dart';
import 'package:omelet/common/index.dart';
import 'package:omelet/widgets/cell.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:image/image.dart' as img;

class ImageJointSettingsPage extends StatefulWidget {
  const ImageJointSettingsPage({Key? key}) : super(key: key);

  @override
  State<ImageJointSettingsPage> createState() => _ImageJointSettingsPageState();
}

class _ImageJointSettingsPageState extends State<ImageJointSettingsPage> {
  @override
  Widget build(BuildContext context) {
    final numList = List.generate(17, (index) => 20 + 5 * index);
    final typeList = ['jpg', 'png'];
    final compressionList = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9];
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: ImageJointSettingData.instance),
        ],
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
          child: Column(
            children: [
              Cell(
                height: 50,
                leading: const Text('Export File Type'),
                trailing: Selector<ImageJointSettingData, String>(
                  selector: (_, data) => data.fileType,
                  builder: (_, val, __) => Text(val),
                ),
                divider: const Divider(height: 1),
                onTap: () {
                  Utils.showPicker(
                    title: 'Choose File Type',
                    list: typeList.map((e) => Text(e)).toList(growable: false),
                    defaultIndex: typeList.indexOf(
                      ImageJointSettingData.instance.fileType,
                    ),
                    onSelect: (index) {
                      ImageJointSettingData.instance
                          .setFileType(typeList[index]);
                    },
                  );
                },
              ),
              Selector<ImageJointSettingData, bool>(
                selector: (_, data) => data.fileType != 'jpg',
                builder: (_, ignore, child) {
                  return IgnorePointer(
                    ignoring: ignore,
                    child: Cell(
                      height: 50,
                      color: ignore ? Colors.grey.shade300 : Colors.transparent,
                      leading: const Text('JPG Quality'),
                      trailing: Selector<ImageJointSettingData, int>(
                        selector: (_, data) => data.quality,
                        builder: (_, val, __) => Text(val.toString()),
                      ),
                      divider: const Divider(height: 1),
                      onTap: () {
                        Utils.showPicker(
                          title: 'JPG Export Quality',
                          list: numList
                              .map((e) => Text(e.toString()))
                              .toList(growable: false),
                          defaultIndex: numList.indexWhere((quality) =>
                              quality >=
                              ImageJointSettingData.instance.quality),
                          onSelect: (index) {
                            ImageJointSettingData.instance
                                .setQuality(numList[index]);
                          },
                        );
                      },
                    ),
                  );
                },
              ),
              Selector<ImageJointSettingData, bool>(
                selector: (_, data) => data.fileType != 'png',
                builder: (_, ignore, child) {
                  return IgnorePointer(
                    ignoring: ignore,
                    child: Cell(
                      height: 50,
                      color: ignore ? Colors.grey.shade300 : Colors.transparent,
                      leading: const Text('PNG Compression Level'),
                      trailing: Selector<ImageJointSettingData, int>(
                        selector: (_, data) => data.level,
                        builder: (_, val, __) => Text(val.toString()),
                      ),
                      divider: const Divider(height: 1),
                      onTap: () {
                        Utils.showPicker(
                          title: 'PNG Compression Level',
                          list: compressionList
                              .map((e) => Text(e.toString()))
                              .toList(growable: false),
                          defaultIndex: compressionList.indexWhere((lv) =>
                              lv >= ImageJointSettingData.instance.level),
                          onSelect: (index) {
                            ImageJointSettingData.instance
                                .setLevel(compressionList[index]);
                          },
                        );
                      },
                    ),
                  );
                },
              ),
              Cell(
                height: 50,
                leading: const Text('Pixel Scale'),
                trailing: Selector<ImageJointSettingData, String>(
                  selector: (_, data) =>
                      (data.pixelScale * 100).toStringAsFixed(0),
                  builder: (_, val, __) => Text('$val%'),
                ),
                divider: const Divider(height: 1),
                onTap: () {
                  Utils.showPicker(
                    title: 'Pixel Scale',
                    list:
                        numList.map((e) => Text('$e%')).toList(growable: false),
                    defaultIndex: numList.indexWhere((scale) =>
                        scale >=
                        ImageJointSettingData.instance.pixelScale * 100),
                    onSelect: (index) {
                      ImageJointSettingData.instance
                          .setPixelScale(numList[index] / 100);
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ImageJointSettingData with ChangeNotifier {
  static final ImageJointSettingData instance = ImageJointSettingData();

  late int quality; // jpg
  late int level; // png
  late double pixelScale;
  late String fileType;

  ImageJointSettingData() {
    quality = Utils.prefs.getInt("imageJointSetting.quality") ?? 80;
    level = Utils.prefs.getInt("imageJointSetting.level") ?? 1;
    pixelScale = Utils.prefs.getDouble("imageJointSetting.pixelScale") ?? 0.5;
    fileType = Utils.prefs.getString("imageJointSetting.fileType") ?? 'jpg';
  }

  setQuality(int val) {
    quality = val;
    notifyListeners();
  }

  setPixelScale(double val) {
    pixelScale = val;
    notifyListeners();
  }

  setFileType(String ty) {
    fileType = ty;
    notifyListeners();
  }

  setLevel(int lv) {
    level = lv;
    notifyListeners();
  }

  Future<File?> encodeFile(img.Image image) async {
    final dir = (await getTemporaryDirectory()).path;
    final name = DateTime.now().millisecond;
    final file = File('$dir/$name.$fileType');
    late List<int> bytes;
    switch (fileType) {
      case 'jpg':
        bytes = img.encodeJpg(
          image,
          quality: ImageJointSettingData.instance.quality,
        );
        break;
      case 'png':
        bytes = img.encodePng(
          image,
          singleFrame: true,
          level: level, // BEST_SPEED
        );
        break;
      default:
        return null;
    }
    file.writeAsBytes(bytes);
    return file;
  }
}
