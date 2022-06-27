import 'dart:async';

import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:get/get.dart';
import 'package:watermelon_glasses/controllers/bluetooth_page_controller.dart';

class DiscoveryPageController extends GetxController {
  final results = <BluetoothDiscoveryResult>[].obs;
  final _discovery = Rxn<StreamSubscription<BluetoothDiscoveryResult>?>();

  StreamSubscription<BluetoothDiscoveryResult>? get discovery =>
      _discovery.value;
  set discovery(StreamSubscription<BluetoothDiscoveryResult>? val) =>
      _discovery.value = val;
  bool get isDiscovering => discovery != null;

  void gotoConnectionSubPage(BluetoothDevice arg) {
    Get.find<BluetoothPageController>().gotoConnectionSubPage(arg);
  }

  @override
  void onClose() {
    discovery?.cancel();
    super.onClose();
  }

  @override
  void onInit() {
    super.onInit();
    startDiscovery();
  }

  void startDiscovery() {
    assert(!isDiscovering);

    // flush data
    results.clear();

    // subscribe device detection
    discovery = FlutterBluetoothSerial.instance.startDiscovery().listen(
      (r) {
        final existingIndex = results.indexWhere(
            (element) => element.device.address == r.device.address);

        if (r.device.name == null) {
          if (existingIndex >= 0) {
            results.removeAt(existingIndex);
          }
        } else if (existingIndex >= 0) {
          results[existingIndex] = r;
        } else {
          results.add(r);
        }
      },
    );

    // make sure done to free after it's done
    discovery!.onDone(() {
      discovery = null;
    });
  }
}
