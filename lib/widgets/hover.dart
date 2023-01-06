import 'package:flutter/material.dart';

class Hover extends StatelessWidget {
  const Hover({
    Key? key,
    this.color,
    required this.child,
    // this.withMaterial = false,
  }) : super(key: key);

  final Color? color;
  final Widget child;

  /// 配合InkWell使用时 (改为自动识别)
  // final bool withMaterial;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        highlightColor: color,
      ),
      child: child is InkWell
          ? Material(
        type: MaterialType.transparency,
        child: child,
      )
          : child,
    );
  }
}
