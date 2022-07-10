import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'controllers/root_controller.dart';
import 'datatypes/setting_store.dart';
import 'firebase_options.dart';
import 'pages/bluetooth_page.dart';
import 'pages/manual_page.dart';
import 'pages/settings_page.dart';
import 'pages/time_page.dart';
import 'services/crashanalytics.dart';
import 'translations/localization.dart';
import 'views/root.dart';

late SettingsStore settings;

Future<void> main() async {
  settings = SettingsStore();
  await runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;

      await settings.initSettings();
      runApp(const WatermelonGlasses());
      await settings.saveSettings();
    },
    (error, stackTrace) {
      FirebaseCrashlytics.instance.recordError(error, stackTrace, fatal: true);
    },
  );
}

class WatermelonGlasses extends StatelessWidget {
  const WatermelonGlasses({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Watermelon Glasses',
      translations: AppLocalization(),
      theme: ThemeData.light(), // TODO: custom
      darkTheme: ThemeData.dark(), // TODO: custom
      themeMode: settings.getTheme,
      locale: settings.getLocale,
      fallbackLocale: const Locale('en', 'US'),
      debugShowCheckedModeBanner: false,
      initialBinding: BindingsBuilder(() {
        Get.put(Crashanalytics(FirebaseCrashlytics.instance.recordError));
        Get.put(RootController());
      }),
      initialRoute: bluePage.name,
      getPages: [
        bluePage,
        timePage,
        manualPage,
        settingsPage,
      ],
      builder: (context, content) {
        return Overlay(
          initialEntries: [
            OverlayEntry(
              builder: (context) => ApplicationRoot(child: content!),
            )
          ],
        );
      },
    );
  }
}
