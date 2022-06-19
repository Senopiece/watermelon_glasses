import 'package:flutter/material.dart';

import '../datatypes/device.dart';
import '../datatypes/bluetooth.dart';

class BluetoothPageRoot extends StatelessWidget {
  BluetoothPageRoot({Key? key}) : super(key: key);
  final _bluetoothDevices = [
    Device(name: 'device1', id: '0', bluetooth: Bluetooth()),
    Device(name: 'device2', id: '1', bluetooth: Bluetooth()),
    Device(name: 'device3', id: '2', bluetooth: Bluetooth()),
    Device(name: 'device4', id: '3', bluetooth: Bluetooth()),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.separated(
        itemCount: _bluetoothDevices.length,
        itemBuilder: (context, index) {
          return Container(
            width: double.infinity,
            padding: EdgeInsets.all(10),
            margin: EdgeInsets.only(top: 10),
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.black,
              ),
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Device Name: ${_bluetoothDevices[index].name}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    )),
                Text(
                    'Bluetooth Name: ${_bluetoothDevices[index].bluetooth.name}'),
              ],
            ),
          );
        },
        separatorBuilder: (context, int index) => Divider(
          height: 10,
        ),
      ),
    );
  }
}
