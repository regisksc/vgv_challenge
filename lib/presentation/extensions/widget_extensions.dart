import 'package:flutter/material.dart';

extension WidgetExtensions on Widget {
  Widget overBlackBackground({double? padding}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black45,
        borderRadius: BorderRadius.circular(8),
      ),
      padding: EdgeInsets.all(padding ?? 8),
      child: this,
    );
  }

  Widget copyWithColor(Color? color) {
    return IconTheme(
      key: const ValueKey('copyWithColorIconTheme'),
      data: IconThemeData(color: color),
      child: this,
    );
  }
}
