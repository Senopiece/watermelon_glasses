import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:get/get.dart';
import 'package:watermelon_glasses/controllers/bluetooth_page_controller.dart';
import 'package:watermelon_glasses/datatypes/bluetooth_connection_manager.dart';

class ConnectionPageController extends GetxController {
  final BluetoothDevice device;
  final BluetoothConnectionManager connector;

  ConnectionPageController(this.device)
      : connector = BluetoothConnectionManager(device.address);

  // TODO: rx connection updates

  void gotoDiscoverySubPage() {
    Get.find<BluetoothPageController>().gotoDiscoverySubPage();
  }

  @override
  void onClose() {
    if (connector.state is Connected) {
      (connector.state as Connected).connection.close();
    }
    super.onClose();
  }

  @override
  void onInit() {
    super.onInit();
    connector.connect();
  }
}
