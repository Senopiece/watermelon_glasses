import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:watermelon_glasses/controllers/bluetooth_page_controller.dart';
import 'package:watermelon_glasses/services/device.dart';

class BluetoothPageRoot extends StatelessWidget {
  final controller = Get.put(BluetoothPageController());
  final device = Get.find<Device>();
  BluetoothPageRoot({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BluetoothPageController>(
      builder: (controller) => Scaffold(
        body: ListView.separated(
          itemCount: controller.results.length,
          itemBuilder: (context, index) {
            return ElevatedButton(
              onPressed: () =>
                  device.setupDevice(controller.results[index].device.address),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                margin: const EdgeInsets.only(top: 10),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.black,
                  ),
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                  color: controller.results[index].device.address ==
                          device.selected
                      ? Colors.amber
                      : Colors.white,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        'Device Name: ${controller.results[index].device.name}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        )),
                    Text(
                        'Address: ${controller.results[index].device.address}'),
                  ],
                ),
              ),
            );
          },
          separatorBuilder: (context, int index) => const Divider(
            height: 10,
          ),
        ),
      ),
    );
  }
}
