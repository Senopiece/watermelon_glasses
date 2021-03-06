import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BluetoothDisabled extends StatelessWidget {
  const BluetoothDisabled({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      // color: const Color.fromARGB(255, 241, 237, 237),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bluetooth_disabled, color: Colors.red[600], size: 60),
          const SizedBox(
            height: 30,
          ),
          Text(
            'bluetooth is disabled'.tr,
            style: const TextStyle(
              fontSize: 20,
              color: Colors.red,
            ),
          ),
        ],
      ),
    );
  }
}
