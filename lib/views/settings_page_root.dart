import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:watermelon_glasses/controllers/settings_page_controller.dart';

class SettingsPageRoot extends GetView<SettingsPageController> {
  const SettingsPageRoot({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        body: Center(
          child: SettingsList(
            sections: [
              SettingsSection(
                title: const Text('Common'),
                tiles: <SettingsTile>[
                  SettingsTile.navigation(
                    leading: const Icon(Icons.language),
                    title: const Text('Language'),
                    value: const Text('English'),
                  ),
                  SettingsTile.switchTile(
                    onToggle: controller.switchTheme,
                    initialValue: controller.isDarkTheme,
                    leading: const Icon(Icons.format_paint),
                    title: const Text('Dark theme'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
