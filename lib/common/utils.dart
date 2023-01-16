part of './index.dart';

class Utils {
  static final GlobalKey<NavigatorState> _navigatorKey =
      GlobalKey<NavigatorState>();
  static GlobalKey<NavigatorState> get navigatorKey => _navigatorKey;

  // static void previewImage(
  //   List<Uint8List> images, {
  //   BuildContext? context,
  //   int initialIndex = 0,
  // }) {
  //
  // }

  static Future<bool?> toast(String  msg) {
    return Fluttertoast.showToast(msg: msg);
  }
}

class VM<T> with ChangeNotifier {
  T _value;
  T get value => _value;

  VM(this._value);

  setValue(T value) {
    _value = value;
  }

  forceUpdate() {
    notifyListeners();
  }
}