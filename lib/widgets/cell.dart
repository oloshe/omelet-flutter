
import 'package:flutter/material.dart';
import 'package:omelet/common/index.dart';
import 'package:omelet/widgets/hover.dart';

class Cell extends StatelessWidget {
  final Widget? leading;
  final Widget? trailing;
  final Widget? title;
  final EdgeInsets? padding;
  final TextStyle? textStyle;
  final VoidCallback? onTap;

  /// 是否有箭头
  final bool arrow;
  final Color? hoverColor;
  final double? height;
  final double? width;

  /// 分割线
  final Divider? divider;

  /// 是否展示下滑线，一般给列表最后一个元素用的
  final bool showDivider;

  /// 箭头左边的空间
  final double? arrowLeft;

  final Color? color;

  final BorderRadiusGeometry? borderRadius;

  final Widget? tips;

  const Cell({
    Key? key,
    this.leading,
    this.trailing,
    this.title,
    this.padding,
    this.textStyle,
    this.onTap,
    this.hoverColor,
    this.height,
    this.width,
    this.arrow = false,
    this.divider,
    this.showDivider = true,
    this.arrowLeft,
    this.color,
    this.borderRadius,
    this.tips,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final titleTextStyle = Ts.black | Ts.s14;
    final padding_ = padding ??
        const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 10,
        );
    Widget result = Padding(
      padding: padding_,
      child: Row(
        children: [
          if (leading != null)
            DefaultTextStyle(
              style: Ts.s14 | Ts.black,
              child: leading!,
            ),
          if (leading != null) const SizedBox(width: 10),
          Expanded(
            child: title != null
                ? DefaultTextStyle(
              style: textStyle == null
                  ? titleTextStyle
                  : titleTextStyle | textStyle!,
              child: title!,
            )
                : const SizedBox(),
          ),
          if (trailing != null) trailing!,
          if (arrow && arrowLeft != null) SizedBox(width: arrowLeft),
          if (arrow)
            const Icon(
              Icons.arrow_forward_ios_outlined,
              color: Color(0xFF7368e0),
              size: 16,
            ),
        ],
      ),
    );

    if (divider != null || tips != null) {
      result = Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 有高度的时候延展
          height != null ? Expanded(child: result) : result,
          if (tips != null)
            Padding(
              padding: EdgeInsets.fromLTRB(
                padding_.left,
                0,
                padding_.right,
                padding_.bottom,
              ),
              child: tips!,
            ),
          if (showDivider && divider != null) divider!,
        ],
      );
    }

    if (height != null || width != null) {
      result = SizedBox(
        height: height,
        width: width,
        child: result,
      );
    }

    if (onTap != null) {
      result = Hover(
        color: hoverColor,
        child: InkWell(
          onTap: onTap,
          child: result,
        ),
      );
    }

    if (color != null) {
      result = Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: borderRadius,
        ),
        clipBehavior: Clip.hardEdge,
        child: result,
      );
    }

    return result;
  }
}
