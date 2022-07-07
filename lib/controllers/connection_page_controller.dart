import 'dart:async';

import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:get/get.dart';
import 'package:watermelon_glasses/abstracts/connection_manager.dart';
import 'package:watermelon_glasses/controllers/bluetooth_page_controller.dart';
import 'package:watermelon_glasses/implementations/connection_manager/watermelon_connection_manager.dart';
import 'package:watermelon_glasses/implementations/rrc_connection_manager/bluetooth_connection_manager.dart';

class ConnectionPageController extends GetxController {
  final BluetoothDevice device;
  WatermelonConnectionManager? connector;

  /// listen to [connector] to perform view updates
  StreamSubscription<ConnectionManagerState>? _statesStreamListener;

  ConnectionPageController(this.device);

  void gotoDiscoverySubPage() {
    Get.find<BluetoothPageController>().gotoDiscoverySubPage();
  }

  void reconnect() {
    assert(connector!.currentState is Disconnected);
    Future(() async {
      try {
        await connector!.connect();
      } on DisconnectionReason {
        // all is fine, the state was set automatically,
        // user can see that something went wrong in details,
        // just ignore
      }
    });
  }

  @override
  void onClose() {
    _statesStreamListener?.cancel();
    _statesStreamListener = null;

    connector?.finalize();
    connector = null;

    super.onClose();
  }

  @override
  void onInit() {
    super.onInit();

    assert(connector == null);
    assert(_statesStreamListener == null);

    connector = WatermelonConnectionManager(
      BluetoothConnectionManager(device.address),
    );
    _statesStreamListener = connector!.statesStream.listen(
      (newState) => update(),
    );

    reconnect();
  }
}
