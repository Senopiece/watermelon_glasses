import 'package:get/get.dart';
import 'package:watermelon_glasses/views/settings_page_root.dart';

final settingsPage = GetPage(
  name: '/settings',
  page: () => const SettingsPageRoot(),
);
