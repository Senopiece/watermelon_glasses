import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SettingsPageController extends GetxController {
  final _isDarkTheme = false.obs;

  bool get isDarkTheme => _isDarkTheme.value;
  set isDarkTheme(bool val) => _isDarkTheme.value = val;

  void switchTheme(value) {
    isDarkTheme = !isDarkTheme;
    // TODO: persist theme after reload
    Get.changeThemeMode(isDarkTheme ? ThemeMode.dark : ThemeMode.light);
  }
}
