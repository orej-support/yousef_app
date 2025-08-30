import 'package:flutter/material.dart';

class ScreenSize {
  static late double screenWidth;
  static late double screenHeight;

  // دالة التهيئة تأخذ BuildContext لمرة واحدة
  static void init(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    screenWidth = mediaQuery.size.width;
    screenHeight = mediaQuery.size.height;
  }

  // يمكن إضافة دوال مساعدة أخرى لحساب النسب
  static double getWidth(double percentage) {
    return screenWidth * (percentage / 100);
  }

  static double getHeight(double percentage) {
    return screenHeight * (percentage / 100);
  }
}