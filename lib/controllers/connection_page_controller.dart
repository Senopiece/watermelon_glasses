import 'dart:async';

import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:get/get.dart';
import 'package:watermelon_glasses/controllers/bluetooth_page_controller.dart';
import 'package:watermelon_glasses/datatypes/bluetooth_connection_manager.dart';
import 'package:watermelon_glasses/datatypes/rrc.dart';

enum ConnectionSate { connecting, connected, disconnected }

class ConnectionPageController extends GetxController {
  final BluetoothDevice device;
  final BluetoothConnectionManager connector;
  late final StreamSubscription<BluetoothConnectionManagerState>
      statesStreamListener;

  /// throws if not in Connected state
  RRC get getRRC => (connector.currentState as Connected).rrc;

  ConnectionSate get currentState {
    switch (connector.currentState.runtimeType) {
      case Connected:
        return ConnectionSate.connected;
      case Connecting:
        return ConnectionSate.connecting;
      case Disconnected:
        return ConnectionSate.disconnected;
      default:
        throw TypeError();
    }
  }

  ConnectionPageController(this.device)
      : connector = BluetoothConnectionManager(device.address);

  void gotoDiscoverySubPage() {
    Get.find<BluetoothPageController>().gotoDiscoverySubPage();
  }

  @override
  void onClose() {
    statesStreamListener.cancel();
    if (connector.currentState is Connected) {
      (connector.currentState as Connected).close();
    }
    super.onClose();
  }

  @override
  void onInit() {
    super.onInit();
    connector.connect();
    statesStreamListener = connector.statesStream.listen(
      (newState) {
        update();
      },
    );
  }
}
