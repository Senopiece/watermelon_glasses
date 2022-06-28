import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:get/get.dart';
import 'package:watermelon_glasses/controllers/connection_page_controller.dart';
import 'package:watermelon_glasses/views/bluetooth_page/connection_page.dart';
import 'package:watermelon_glasses/views/bluetooth_page/discovery_page.dart';

// TODO: test bluetooth is not setup
// TODO: test not bounded
// TODO: test setup externally
// TODO: use another device
// TODO: too many devices connected error
// TODO: check if the device was already connected but try to connect here

// TODO: adapter turn off catch
// TODO: device does not follow protocol catch
// TODO: device disconnection catch

/// controls switches between ConnectionPage and DiscoveryPage
class BluetoothPageController extends GetxController {
  final _page = Rxn<Widget>();

  Widget get page => _page.value!;
  set page(Widget newPage) => _page.value = newPage;

  void gotoConnectionSubPage(BluetoothDevice arg) {
    Get.put(ConnectionPageController(arg));
    page = const ConnectionPage();
  }

  void gotoDiscoverySubPage() {
    Get.delete<ConnectionPageController>();
    page = const DiscoveryPage();
  }

  @override
  void onInit() {
    super.onInit();
    page = const DiscoveryPage();
  }
}
