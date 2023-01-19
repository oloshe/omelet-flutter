part of './index.dart';

/// 方便设置文字颜色和大小
/// Text("字符串", style: R.sc(20, Colors.white));
/// Text("字符串", style: R.sc(20, Colors.white) | TextStyle(height: 2);
class Ts {
  Ts._();

  static const TextStyle s8 = TextStyle(fontSize: 8);
  static const TextStyle s9 = TextStyle(fontSize: 9);
  static const TextStyle s10 = TextStyle(fontSize: 10);
  static const TextStyle s11 = TextStyle(fontSize: 11);
  static const TextStyle s12 = TextStyle(fontSize: 12);
  static const TextStyle s13 = TextStyle(fontSize: 13);
  static const TextStyle s14 = TextStyle(fontSize: 14);
  static const TextStyle s15 = TextStyle(fontSize: 15);
  static const TextStyle s16 = TextStyle(fontSize: 16);
  static const TextStyle s17 = TextStyle(fontSize: 17);
  static const TextStyle s18 = TextStyle(fontSize: 18);
  static const TextStyle s19 = TextStyle(fontSize: 19);
  static const TextStyle s20 = TextStyle(fontSize: 20);
  static const TextStyle s21 = TextStyle(fontSize: 21);
  static const TextStyle s22 = TextStyle(fontSize: 22);
  static const TextStyle s23 = TextStyle(fontSize: 23);
  static const TextStyle s24 = TextStyle(fontSize: 24);
  static const TextStyle s25 = TextStyle(fontSize: 25);
  static const TextStyle s26 = TextStyle(fontSize: 26);

  static const TextStyle white = TextStyle(color: Colors.white);
  static const TextStyle black = TextStyle(color: Colors.black);
  static const TextStyle blue = TextStyle(color: Colors.blue);
  static const TextStyle red = TextStyle(color: Colors.red);
  static const TextStyle grey = TextStyle(color: Colors.grey);

  /// 字体大小 单位为rpx
  static TextStyle size(double size) => TextStyle(fontSize: size);

  /// 字体颜色
  static TextStyle color(Color color) => TextStyle(color: color);

  /// 同时设置字体大小和颜色
  static TextStyle sc(double size, Color color) =>
      TextStyle(fontSize: size, color: color);

  /// 行高
  static TextStyle height(double height) => TextStyle(height: height);

  // ========================== 字体粗细 ==========================

  /// Thin, the least thick
  static TextStyle get w100 => const TextStyle(fontWeight: FontWeight.w100);

  /// Extra-light
  static TextStyle get w200 => const TextStyle(fontWeight: FontWeight.w200);

  /// Light
  static TextStyle get w300 => const TextStyle(fontWeight: FontWeight.w300);

  /// Normal / regular / plain
  static TextStyle get w400 => const TextStyle(fontWeight: FontWeight.w400);

  /// Medium
  static TextStyle get w500 => const TextStyle(fontWeight: FontWeight.w500);

  /// Semi-bold
  static TextStyle get w600 => const TextStyle(fontWeight: FontWeight.w600);

  /// Bold
  static TextStyle get w700 => const TextStyle(fontWeight: FontWeight.w700);

  /// Extra-bold
  static TextStyle get w800 => const TextStyle(fontWeight: FontWeight.w800);

  /// Black, the most thick
  static TextStyle get w900 => const TextStyle(fontWeight: FontWeight.w900);

  /// The default font weight.
  static TextStyle get normal => const TextStyle(fontWeight: FontWeight.normal);

  /// A commonly used font weight that is heavier than normal.
  static TextStyle get bold => const TextStyle(fontWeight: FontWeight.bold);

  static TextStyle get underline => const TextStyle(
    decoration: TextDecoration.underline,
  );
}

extension TextStyleExt on TextStyle {
  /// 方便合并 TextStyle
  /// [Ts.s26] | [Ts.white]
  /// 等价于
  /// TextStyle(fontSize: 26.rpx).merge(TextStyle(color: Colors.white))
  TextStyle operator |(TextStyle style) => merge(style);
}
