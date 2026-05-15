import 'package:flutter/material.dart';

/// Khoảng cách & kích thước theo màn hình điện thoại.
class MobileLayout {
  MobileLayout._();

  static EdgeInsets pagePadding(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final hPad = w < 360 ? 16.0 : 20.0;
    return EdgeInsets.fromLTRB(hPad, 8, hPad, 24 + MediaQuery.paddingOf(context).bottom);
  }

  /// Chiều cao vùng đỏ (không tính status bar).
  static double headerExpandedHeight(BuildContext context) {
    final h = MediaQuery.sizeOf(context).height;
    if (h < 640) return 88;
    if (h < 750) return 96;
    return 104;
  }

  static bool narrowScreen(BuildContext context) =>
      MediaQuery.sizeOf(context).width < 360;
}
