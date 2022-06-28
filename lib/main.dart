import 'package:flutter/material.dart';
import 'package:flutter/services.dart' as flutter_services;
import 'package:get/get.dart';
import 'package:watermelon_glasses/controllers/root_controller.dart';
import 'package:watermelon_glasses/pages/manual_page.dart';
import 'package:watermelon_glasses/pages/settings_page.dart';
import 'package:watermelon_glasses/pages/time_page.dart';
import 'package:watermelon_glasses/views/root.dart';
import 'pages/bluetooth_page.dart';
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
      //key: UniqueKey(),
      title: 'Watermelon Glasses',
      translations: AppLocalization(),
      theme: ThemeData.light(), // TODO: custom
      darkTheme: ThemeData.dark(), // TODO: custom
      locale: Get.deviceLocale,
      fallbackLocale: const Locale('en', 'US'),
      debugShowCheckedModeBanner: false,
      initialBinding: BindingsBuilder(() {
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
