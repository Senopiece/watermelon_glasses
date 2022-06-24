import 'dart:typed_data';

import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:get/get.dart';

enum WatermelonConnectionStates { none, connecting, connected }

class Watermelon extends GetxService {
  /// bluetooth device references
  BluetoothConnection? connection;
  String selected = '';

  /// states:
  ///   none       : selected == '' && connection == null
  ///   connecting : selected != '' && connection == null
  ///   connected  : selected != '' && connection != null
  WatermelonConnectionStates get state {
    if (selected == '' && connection == null) {
      return WatermelonConnectionStates.none;
    } else if (selected != '' && connection == null) {
      return WatermelonConnectionStates.connecting;
    } else if (selected != '' && connection != null) {
      return WatermelonConnectionStates.connected;
    } else {
      throw Error();
    }
  }

  /// the current executing mode
  bool isManualMode = false;

  /// must use internally
  Future<void> sendRaw(String data) async {
    connection!.output.add(Uint8List.fromList(data.codeUnits));
    await connection!.output.allSent;
  }

  /// set state into none
  void throwDevice() {
    assert(state != WatermelonConnectionStates.connecting);
    connection?.close();
    connection = null;
    selected = '';
  }

  /// note that the previous connection would be irrevocable thrown,
  /// so if the connection to the new device fails,
  /// the service state becomes none
  Future<void> setupDevice(String address) {
    assert(state != WatermelonConnectionStates.connecting);

    if (connection != null) {
      connection!.close();
      connection = null;
      selected = address;
    }

    return Future(() async {
      try {
        connection = await BluetoothConnection.toAddress(address);
        isManualMode = false;
      } catch (e) {
        selected = '';
        rethrow;
      }
    });
  }

  /// switch isManualMode
  Future<void> enterManualMode() async {
    if (connection != null) {
      await sendRaw("manual mode");
      isManualMode = true;
    }
  }

  /// switch isManualMode
  Future<void> exitManualMode() async {
    if (connection != null) {
      await sendRaw("exit manual mode");
      isManualMode = false;
    }
  }

  /// works only for manual mode
  Future<void> open(int index) async {
    if (connection != null) {
      assert(isManualMode);
      await sendRaw("open $index");
    }
  }

  /// works only for manual mode
  Future<void> close(int index) async {
    if (connection != null) {
      assert(isManualMode);
      await sendRaw("close $index");
    }
  }

  /// set the time on the device
  Future<void> setTime(String time) async {
    if (connection != null) {
      assert(!isManualMode);
      await sendRaw("set time $time");
    }
  }
}
