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

abstract class PageBuilder {
  Widget build() => throw UnimplementedError();
}

class ConnectionPageBuilder implements PageBuilder {
  @override
  Widget build() => const ConnectionPage();
}

class DiscoveryPageBuilder implements PageBuilder {
  @override
  Widget build() => const DiscoveryPage();
}

/// controls switches between ConnectionPage and DiscoveryPage
class BluetoothPageController extends GetxController {
  final Rx<PageBuilder> _page = DiscoveryPageBuilder().obs;

  PageBuilder get page => _page.value;
  set page(PageBuilder newPage) => _page.value = newPage;

  void gotoConnectionPage(BluetoothDevice arg) {
    Get.put(ConnectionPageController(arg));
    page = ConnectionPageBuilder();
  }

  void gotoDiscoveryPage() {
    Get.delete<ConnectionPageController>();
    page = DiscoveryPageBuilder();
  }
}
