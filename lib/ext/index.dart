import 'package:flutter/material.dart';

extension AsyncSnapshotExt<T> on AsyncSnapshot<T> {
  bool get isDone {
      return connectionState == ConnectionState.done;
  }
}

extension InvertColor on Color {
  Color get invert {
    final r = 0xff - red;
    final g = 0xff - green;
    final b = 0xff - blue;
    return Color.fromARGB((opacity * 0xff).round(), r, g, b);
  }
}