import 'dart:typed_data';

import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

/// wrapper over BluetoothConnection to support watermelon commands,
/// see https://github.com/Senopiece/watermelon/blob/main/README.md
class Watermelon {
  final BluetoothConnection connection;
  bool isManualMode = false; // TODO: check it's state dynamically

  Watermelon(this.connection);

  /// must use internally
  Future<void> sendRaw(String data) async {
    connection.output.add(Uint8List.fromList(data.codeUnits));
    await connection.output.allSent;
  }

  Future<void> enterManualMode() async {
    assert(!isManualMode);
    await sendRaw("manual mode");
    isManualMode = true;
  }

  Future<void> exitManualMode() async {
    assert(isManualMode);
    await sendRaw("exit manual mode");
    isManualMode = false;
  }

  Future<void> openChannel(int index) async {
    assert(isManualMode);
    await sendRaw("open $index");
  }

  Future<void> closeChannel(int index) async {
    assert(isManualMode);
    await sendRaw("close $index");
  }

  Future<void> setTime(String time) async {
    assert(!isManualMode);
    await sendRaw("set time $time");
  }
}
