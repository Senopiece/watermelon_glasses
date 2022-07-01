import 'dart:async';

import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:get/get.dart';
import 'package:watermelon_glasses/controllers/bluetooth_page_controller.dart';

// 4) on the auto page add buttons like the cli interface does,
// also provide a plus button to the time picker which cannot allow you to pick incorrect time,
// so we always expect empty output from the device

class DiscoveryPageController extends GetxController {
  final _discovery = Rxn<StreamSubscription<BluetoothDiscoveryResult>?>();

  StreamSubscription<BluetoothDiscoveryResult>? get discovery =>
      _discovery.value;
  set discovery(StreamSubscription<BluetoothDiscoveryResult>? val) =>
      _discovery.value = val;

  final results = <BluetoothDiscoveryResult>[].obs;
  final _isBlueEnabled = Rxn<bool>();
  final _isDiscovering = false.obs;

  bool? get isBlueEnabled => _isBlueEnabled.value;
  set isBlueEnabled(bool? newVal) => _isBlueEnabled.value = newVal;

  bool get isDiscovering => _isDiscovering.value;
  set isDiscovering(bool newVal) => _isDiscovering.value = newVal;

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
    isDiscovering = true;

    // flush data
    results.clear();

    Future(() async {
      isBlueEnabled = (await FlutterBluetoothSerial.instance.isEnabled) == true;
      if (!isBlueEnabled!) {
        isDiscovering = false;
        return;
      }

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
        isDiscovering = false;
      });
    });
  }
}
