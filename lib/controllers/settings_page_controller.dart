import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../datatypes/setting_store.dart';

// TODO: persist settings
class SettingsPageController extends GetxController {
  final _isDarkTheme = false.obs;
  late SettingsStore settings;

  int _languageNumber = 0;
  final _numberOfLanguage = 2;
  /*
  * 0 - English
  * 1 - Russian
   */

  @override
  void onInit() async {
    super.onInit();
    settings = SettingsStore();
    await settings.initSettings();
    _isDarkTheme.value = settings.isDarkTheme;
    _languageNumber = settings.languageNumber; // next language on click
    changeLanguage(value: _languageNumber + 1, change: false);
  }

  bool get isDarkTheme => _isDarkTheme.value;
  set isDarkTheme(bool val) => _isDarkTheme.value = val;

  void switchTheme({bool? value, change = true}) {
    value ??= isDarkTheme;
    if (change) {
      _isDarkTheme.value = !value;
      settings.setTheme(_isDarkTheme.value);
    }
    Get.changeThemeMode(isDarkTheme ? ThemeMode.dark : ThemeMode.light);
  }

  void changeLanguage({int? value, change = true}) {
    value ??= _languageNumber;
    switch (value % _numberOfLanguage) {
      case 0:
        Get.updateLocale(const Locale("en", "US"));
        break;
      case 1:
        Get.updateLocale(const Locale("ru", "RU"));
        break;
    }
    if (change) {
      _languageNumber++;
      settings.setLanguageNumber(_languageNumber);
    }
  }

  bool getIsDarkTheme(value) {
    return _isDarkTheme.isFalse;
  }
}
