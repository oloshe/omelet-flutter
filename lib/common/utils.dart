part of './index.dart';

class Utils {
  static final GlobalKey<NavigatorState> _navigatorKey =
      GlobalKey<NavigatorState>();
  static GlobalKey<NavigatorState> get navigatorKey => _navigatorKey;

  static late SharedPreferences _prefs;
  static SharedPreferences get prefs => _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // static void previewImage(
  //   List<Uint8List> images, {
  //   BuildContext? context,
  //   int initialIndex = 0,
  // }) {
  //
  // }

  static Future<bool?> toast(String msg) {
    return Fluttertoast.showToast(msg: msg);
  }

  /// 等待下一帧执行，通常用来规避build时同步执行setState导致的报错
  static Future<void> nextFrame() {
    Completer<void> completer = Completer();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      completer.complete();
    });
    return completer.future;
  }

  /// 等待下一帧执行，通常用来规避build时同步执行setState导致的报错
  static void nextFrameCall(Function func) {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      func();
    });
  }

  static Future<CroppedFile?> cropImage(String imgPath) async {
    return await ImageCropper().cropImage(
      sourcePath: imgPath,
      compressQuality: 100,
      aspectRatioPresets: [
        CropAspectRatioPreset.square,
        CropAspectRatioPreset.ratio3x2,
        CropAspectRatioPreset.original,
        CropAspectRatioPreset.ratio4x3,
        CropAspectRatioPreset.ratio16x9
      ],
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Cropper',
          toolbarColor: Colors.black,
          cropFrameColor: Colors.blue,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: false,
        ),
        IOSUiSettings(
          title: 'Cropper',
        ),
      ],
    );
  }

  static Future<bool?> showConfirm({
    String? title = 'Tips',
    String? content = '',
    String cancelText = 'Cancel',
    String confirmText = 'Confirm',
  }) {
    return showDialog<bool>(
      context: navigatorKey.currentContext!,
      builder: (context) {
        return AlertDialog(
          title: title != null ? Text(title) : null,
          content: content != null ? Text(content) : null,
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: Text(cancelText, style: Ts.grey),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: Text(confirmText),
            ),
          ],
        );
      },
    );
  }

  /// 从底部弹起的滚动选择器
  static Future<int?> showPicker({
    String? title, // 标题
    required List<Widget> list, // 选择列表
    int? defaultIndex = 0, // 初始下标
    void Function(int)? onSelect, // 选择回调
    Duration duration = const Duration(milliseconds: 400), // picker 弹出动画时长
    bool mask = true, // 是否有蒙层
    bool maskClickClose = true, // 蒙层点击关闭
    double itemHeight = 50, // picker 每一项的高度 单位为 rpx
    double pickerHeightRatio = 2 / 5, // picker 区域的高度占屏幕的比例，如果写死固定写死容易超出边界。
    double? minHeight,
    String? confirmText, // 确认按钮文本
    String? cancelText, // 取消按钮文本
  }) {
    assert(pickerHeightRatio < 1, "picker高度占比太高，pickerHeightRatio值应该小于1");
    var complete = Completer<int?>();
    int selectIndex = defaultIndex ?? 0;

    var height = ScreenAdaptor.screenHeight * pickerHeightRatio;
    if (minHeight != null && height < minHeight) {
      height = minHeight;
    }
    showModalBottomSheet(
      context: navigatorKey.currentContext!,
      backgroundColor: Colors.white,
      builder: (context) {
        return SizedBox(
          height: height,
          child: Column(
            children: [
              PickerHeader(
                confirmText: confirmText,
                cancelText: cancelText,
                title: title,
                onCancel: () {
                  complete.complete(null);
                  Navigator.pop(context);
                },
                onConfirm: () {
                  complete.complete(selectIndex);
                  onSelect?.call(selectIndex);
                  Navigator.pop(context);
                },
              ),
              Expanded(
                child: Builder(
                  // 不加这个 builder 会报错
                  builder: (context) {
                    return CupertinoPicker.builder(
                      key: const Key("Picker"),
                      childCount: list.length,
                      itemBuilder: (context, index) => SizedBox(
                        height: itemHeight,
                        child: Center(
                          child: DefaultTextStyle(
                            style: Ts.s16 | Ts.black,
                            child: list[index],
                          ),
                        ),
                      ),
                      itemExtent: itemHeight,
                      scrollController: FixedExtentScrollController(
                        initialItem: selectIndex,
                      ),
                      selectionOverlay: const _PickerSelectionOverlay(),
                      onSelectedItemChanged: (index) {
                        selectIndex = index;
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
    return complete.future;
  }

  /// 选取颜色
  static Future<Color?> showColorPicker(
    BuildContext context,
    Color initialColor,
  ) {
    Color selectColor = initialColor;
    return showDialog<Color?>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Pick a Color!'),
          content: SingleChildScrollView(
            child: SlidePicker(
              pickerColor: initialColor,
              onColorChanged: (clr) {
                selectColor = clr;
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(selectColor);
              },
              child: const Text('Got it'),
            ),
          ],
        );
      },
    );
  }
}

class VM<T> with ChangeNotifier {
  T _value;
  T get value => _value;

  VM(this._value);

  setValue(T value) {
    _value = value;
    notifyListeners();
  }

  forceUpdate() {
    notifyListeners();
  }
}

class VMSelector<T, V> extends StatelessWidget {
  final V Function(BuildContext, VM<T>)? selector;
  final ValueWidgetBuilder<V> builder;
  final Widget? child;

  const VMSelector({
    Key? key,
    required this.builder,
    this.selector,
    this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Selector<VM<T>, V>(
      selector: selector ?? (context, m) => m.value as V,
      builder: builder,
      child: child,
    );
  }
}

class PickerHeader extends StatelessWidget {
  final String? title;
  final void Function()? onCancel;
  final void Function()? onConfirm;

  final String? confirmText;
  final String? cancelText;

  const PickerHeader({
    Key? key,
    this.title,
    this.onCancel,
    this.onConfirm,
    this.confirmText,
    this.cancelText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 5,
        right: 5,
        top: 5,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton(
            onPressed: () {
              onCancel?.call();
            },
            style: ButtonStyle(
              foregroundColor: MaterialStateProperty.all(Colors.grey),
            ),
            child: Text(cancelText ?? "Cancel"),
          ),
          // 标题
          if (title != null) Text(title!, style: Ts.black | Ts.bold),
          TextButton(
            onPressed: () {
              onConfirm?.call();
            },
            style: ButtonStyle(
              foregroundColor: MaterialStateProperty.all(
                Colors.blue.shade300,
              ),
            ),
            child: Text(confirmText ?? "Confirm"),
          ),
        ],
      ),
    );
  }
}

class _PickerSelectionOverlay extends StatelessWidget {
  const _PickerSelectionOverlay({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30,
      decoration: BoxDecoration(
        border: BorderDirectional(
          top: BorderSide(color: Colors.yellow.shade700),
          bottom: BorderSide(color: Colors.yellow.shade700),
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: const [
          Positioned(
            left: 10,
            child: Icon(Icons.arrow_right, color: Colors.orange),
          ),
          Positioned(
            right: 10,
            child: Icon(Icons.arrow_left, color: Colors.orange),
          ),
        ],
      ),
    );
  }
}
