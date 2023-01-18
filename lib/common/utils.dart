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

class VMSelector<T> extends StatelessWidget {
  final VM<T> model;
  final T Function(BuildContext, VM<T>)? selector;
  final ValueWidgetBuilder<T> builder;
  final Widget? child;

  const VMSelector({
    Key? key,
    required this.model,
    required this.builder,
    this.selector,
    this.child,
  }) : super(key: key);

  const VMSelector.value({
    Key? key,
    required VM<T> value,
    required this.builder,
    this.selector,
    this.child,
  })  : model = value,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Selector<VM<T>, T>(
      selector: selector ?? (context, m) => m.value,
      builder: builder,
      child: child,
    );
  }
}
