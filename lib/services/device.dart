import 'dart:typed_data';

import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:get/get.dart';

class Device extends GetxService {
  BluetoothConnection? connection;
  bool isManualMode = false;

  Future<void> sendRaw(String data) async {
    connection!.output.add(Uint8List.fromList(data.codeUnits));
    await connection!.output.allSent;
  }

  void setupDevice(String address) {
    connection = null;
    Future(() async {
      connection = await BluetoothConnection.toAddress(address);
      isManualMode = false;

      // connection!.input?.listen((Uint8List data) {
      //   //Data entry point
      //   print(ascii.decode(data));
      // });
    });
  }

  Future<void> enterManualMode() async {
    if (connection != null) {
      await sendRaw("manual mode");
      isManualMode = true;
    }
  }

  Future<void> exitManualMode() async {
    if (connection != null) {
      await sendRaw("exit manual mode");
      isManualMode = false;
    }
  }

  Future<void> open(int index) async {
    if (connection != null) {
      assert(isManualMode);
      await sendRaw("open $index");
    }
  }

  Future<void> close(int index) async {
    if (connection != null) {
      assert(isManualMode);
      await sendRaw("close $index");
    }
  }

  Future<void> setTime(String time) async {
    if (connection != null) {
      assert(!isManualMode);
      await sendRaw("set time $time");
    }
  }
}
