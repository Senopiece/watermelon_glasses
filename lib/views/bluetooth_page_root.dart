import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:watermelon_glasses/controllers/bluetooth_page_controller.dart';
import 'package:watermelon_glasses/services/watermelon.dart';

class BluetoothPageRoot extends StatelessWidget {
  final controller = Get.put(BluetoothPageController());
  BluetoothPageRoot({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        body: Stack(
          children: [
            Center(
              child: CircularProgressIndicator(
                color:
                    controller.isDiscovering.value ? null : Colors.transparent,
              ),
            ),
            ListView.separated(
              itemCount: controller.results.length,
              itemBuilder: (context, index) {
                final device = controller.results[index].device;
                final connecting = false;
                final connected = false;
                return ElevatedButton(
                  onPressed: () => controller.selectDevice(device.address),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Device Name: ${device.name}',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: connected ? Colors.green : null,
                        ),
                      ),
                      Text(
                        'Address: ${device.address}',
                      ),
                    ],
                  ),
                );
              },
              separatorBuilder: (context, int index) => const Divider(
                height: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
