import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:watermelon_glasses/controllers/root_controller.dart';

class ApplicationRoot extends GetWidget<RootController> {
  final Widget child;

  const ApplicationRoot({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
      ),
      body: child,
      bottomNavigationBar: Obx(
        () => BottomNavigationBar(
          currentIndex: controller.currentIndex,
          items:  [
            BottomNavigationBarItem(
              icon: const Icon(Icons.bluetooth),
              label: "Bluetooth".tr,
              backgroundColor: Colors.green,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.access_time),
              label: 'Time'.tr,
              backgroundColor: Colors.green,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.back_hand),
              label: 'Manual'.tr,
              backgroundColor: Colors.green,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.settings),
              label: 'Settings'.tr,
              backgroundColor: Colors.green,
            ),
          ],
          onTap: controller.switchPage,
        ),
      ),
    );
  }
}
