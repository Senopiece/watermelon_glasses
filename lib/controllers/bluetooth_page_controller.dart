import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:get/get.dart';
import 'package:watermelon_glasses/controllers/connection_page_controller.dart';
import 'package:watermelon_glasses/views/bluetooth_page/connection_page.dart';
import 'package:watermelon_glasses/views/bluetooth_page/discovery_page.dart';

/// controls switches between ConnectionPage and DiscoveryPage
class BluetoothPageController extends GetxController {
  final _page = Rxn<Widget>();

  Widget get page => _page.value!;
  set page(Widget newPage) => _page.value = newPage;

  void gotoConnectionSubPage(BluetoothDevice arg) {
    Get.put(ConnectionPageController(arg), permanent: true);
    page = const ConnectionPage();
  }

  void gotoDiscoverySubPage() {
    Get.delete<ConnectionPageController>(force: true);
    page = const DiscoveryPage();
  }

  @override
  void onInit() {
    super.onInit();
    page = const DiscoveryPage();
  }
}
