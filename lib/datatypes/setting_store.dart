import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsStore {
  int _cntFuture = 0;
  late bool isDarkTheme;
  late int languageNumber;
  final _numberOfLanguage = 2;

  Future<void> initSettings() async {
    await _ensureAllFutureDone();

    final prefs = await SharedPreferences.getInstance();
    languageNumber = prefs.getInt("languageNumber") ?? 0;
    isDarkTheme = prefs.getBool("isDarkTheme") ?? false;
  }

  void setTheme(bool isDarkTheme) {
    _cntFuture++;
    Future(() async {
      final prefs = await SharedPreferences.getInstance();
      prefs.setBool('isDarkTheme', isDarkTheme);

      _cntFuture--;
    });
  }

  void setLanguageNumber(int languageNumber) {
    _cntFuture++;
    Future(() async {
      final prefs = await SharedPreferences.getInstance();
      prefs.setInt('languageNumber', languageNumber);

      _cntFuture--;
    });
  }

  // be ensure that all set(s) are finished.
  saveSettings() async => _ensureAllFutureDone();

  ThemeMode get getTheme => (isDarkTheme ? ThemeMode.dark : ThemeMode.light);

  Locale get getLocale {
    switch (languageNumber % _numberOfLanguage) {
      case 0:
        return const Locale("en", "US");
      case 1:
        return const Locale("ru", "RU");
      default:
        return const Locale("en", "US"); // default locale
    }
  }

  Future<void> _ensureAllFutureDone() async {
    if (_cntFuture == 0) {
      return;
    }
    await Future.delayed(const Duration(seconds: 1));
    _ensureAllFutureDone();
  }
}
