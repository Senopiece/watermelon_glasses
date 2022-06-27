import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:watermelon_glasses/controllers/discovery_page_controller.dart';

class DiscoveryPage extends GetView<DiscoveryPageController> {
  const DiscoveryPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Stack(
        children: [
          // TODO: upper line like in browser instead of it
          Center(
            child: CircularProgressIndicator(
              color: controller.isDiscovering ? null : Colors.transparent,
            ),
          ),
          // TODO: animated add/remove
          ListView.separated(
            itemCount: controller.results.length,
            itemBuilder: (context, index) {
              final device = controller.results[index].device;
              return ElevatedButton(
                onPressed: () => controller.gotoConnectionPage(device),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Device Name: ${device.name}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
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
    );
  }
}
