import 'package:flutter/material.dart';
import 'package:flutter/services.dart' as flutter_services;
import 'package:get/get.dart';

import 'pages/pages.dart';
import 'services/binding.dart';
import 'translations/localization.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  flutter_services.SystemChrome.setPreferredOrientations([
    flutter_services.DeviceOrientation.portraitUp,
  ]);
  runApp(const WatermelonGlasses());
}

class WatermelonGlasses extends StatelessWidget {
  const WatermelonGlasses({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Watermelon Glasses',
      translations: AppLocalization(),
      locale: Get.deviceLocale,
      fallbackLocale: const Locale('en', 'US'),
      initialBinding: ServicesBinding(),
      initialRoute: mainPage.name,
      getPages: [
        mainPage,
      ],
    );
  }
}
