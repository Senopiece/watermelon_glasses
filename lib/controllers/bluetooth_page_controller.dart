import 'dart:async';

import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:get/get.dart';

class BluetoothPageController extends GetxController {
  List<BluetoothDiscoveryResult> results = <BluetoothDiscoveryResult>[];
  StreamSubscription<BluetoothDiscoveryResult>? streamSubscription;
  bool isDiscovering = false;

  void startDiscovery() {
    streamSubscription =
        FlutterBluetoothSerial.instance.startDiscovery().listen((r) {
      final existingIndex = results
          .indexWhere((element) => element.device.address == r.device.address);
      if (existingIndex >= 0) {
        results[existingIndex] = r;
      } else {
        results.add(r);
      }
      update();
    });

    streamSubscription!.onDone(() {
      isDiscovering = false;
    });
  }

  @override
  void onClose() {
    streamSubscription?.cancel();
    super.onClose();
  }

  @override
  void onInit() {
    super.onInit();

    isDiscovering = true;
    if (isDiscovering) {
      startDiscovery();
    }
  }
}
