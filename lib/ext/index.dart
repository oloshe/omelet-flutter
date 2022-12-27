import 'package:flutter/material.dart';

extension AsyncSnapshotExt<T> on AsyncSnapshot<T> {
  bool get isDone {
      return connectionState == ConnectionState.done;
  }
}