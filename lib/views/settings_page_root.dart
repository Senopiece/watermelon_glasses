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
                title: Text('Common'.tr),
                tiles: <SettingsTile>[
                  SettingsTile.navigation(
                    leading: const Icon(Icons.language),
                    title: Text('Language'.tr),
                    value: Text('Language label'.tr),
                  ),
                  SettingsTile.switchTile(
                    leading: const Icon(Icons.format_paint),
                    title: Text('Dark theme'.tr),
                    initialValue: controller.isDarkTheme,
                    onToggle: controller.switchTheme,
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
