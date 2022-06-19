import './bluetooth.dart';

class Device {
  String name;
  String id;
  Bluetooth bluetooth;
  Device({
    this.name = 'not specified',
    required this.id,
    required this.bluetooth,
  });
}
