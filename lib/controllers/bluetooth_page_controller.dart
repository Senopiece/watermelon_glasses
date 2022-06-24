import 'dart:async';

import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:get/get.dart';
import 'package:watermelon_glasses/services/watermelon.dart';

// TODO: test bluetooth is not setup
// TODO: test not bounded
// TODO: test setup externally
// TODO: use another device
// TODO: too many devices connected error

// TODO: adapter turn off catch
// TODO: device does not follow protocol catch

class SelectedDevice {
  final bool isConnected;
  final String address;
  SelectedDevice(this.isConnected, this.address);
  static get none => SelectedDevice(false, '');
}

class BluetoothPageController extends GetxController {
  final watermelon = Get.find<Watermelon>();
  StreamSubscription<BluetoothDiscoveryResult>? _discoveryStreamSubscription;

  final results = <BluetoothDiscoveryResult>[].obs;
  final current = SelectedDevice.none.obs;
  final isDiscovering = false.obs;

  @override
  void onClose() {
    _discoveryStreamSubscription?.cancel();
    super.onClose();
  }

  @override
  void onInit() {
    super.onInit();
    startDiscovery();
  }

  Future<void> selectDevice(String address) async {
    current.value = SelectedDevice(false, address);
    try {
      await watermelon.setupDevice(address);
      current.value = SelectedDevice(true, address);
    } catch (e) {
      current.value = SelectedDevice.none;
    }
  }

  void startDiscovery() {
    if (isDiscovering.value) {
      throw Error();
    }

    // flush data
    watermelon.throwDevice();
    current.value = SelectedDevice.none;
    results.clear();
    isDiscovering.value = true;

    // subscribe
    _discoveryStreamSubscription =
        FlutterBluetoothSerial.instance.startDiscovery().listen((r) {
      final existingIndex = results
          .indexWhere((element) => element.device.address == r.device.address);

      if (r.device.name == null) {
        if (existingIndex >= 0) {
          results.removeAt(existingIndex);
        }
      } else if (existingIndex >= 0) {
        results[existingIndex] = r;
      } else {
        results.add(r);
      }
    });

    // make sure done
    _discoveryStreamSubscription!.onDone(() {
      isDiscovering.value = false;
    });
  }
}
