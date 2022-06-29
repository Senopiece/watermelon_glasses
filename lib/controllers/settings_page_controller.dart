import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SettingsPageController extends GetxController {
  final _isDarkTheme = true.obs;

  int _languageNumber = 0;
  final _numberOfLanguage = 2;
  /*
  * 0 - English
  * 1 - Russian
   */



  bool get isDarkTheme => _isDarkTheme.value;
  set isDarkTheme(bool val) => _isDarkTheme.value = val;

  void switchTheme(value) {
    isDarkTheme = !isDarkTheme;
    // TODO: persist theme after reload
    Get.changeThemeMode(isDarkTheme ? ThemeMode.dark : ThemeMode.light);
  }

  void changeLanguage(value) {
    switch(_languageNumber % _numberOfLanguage) {
      case 0:
        Get.updateLocale(const Locale("en", "US"));
        break;
      case 1:
        Get.updateLocale(const Locale("ru", "RU"));
        break;
    }
    _languageNumber++;
  }
}
