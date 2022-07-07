import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:watermelon_glasses/controllers/discovery_page_controller.dart';

class DiscoveryPage extends GetView<DiscoveryPageController> {
  const DiscoveryPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => controller.isBlueEnabled == null
          ? const Center(child: CircularProgressIndicator())
          : Scaffold(
              floatingActionButton: IconButton(
                // TODO: make it via smth like "pull down to reload"
                onPressed: controller.startDiscovery,
                icon: const Icon(Icons.refresh_outlined),
                iconSize: 40,
              ),
              body: Stack(
                children: [
                  Center(
                    child: controller.isBlueEnabled!
                        ? CircularProgressIndicator(
                            color: controller.isDiscovering
                                ? null
                                : Colors.transparent,
                          ) // TODO: upper line like in browser instead of CircularProgressIndicator
                        : Text(
                            'bluetooth is disabled'.tr,
                          ), // this case controller.results.length will be 0 guaranteed
                  ),
                  // TODO: animated add/remove
                  // TODO: center text "no devices found" when controller.results.length == 0
                  ListView.separated(
                    itemCount: controller.results.length,
                    itemBuilder: (context, index) {
                      final device = controller.results[index].device;
                      return ElevatedButton(
                        onPressed: () =>
                            controller.gotoConnectionSubPage(device),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${"Device Name:".tr} ${device.name}',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${"Address:".tr} ${device.address}',
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
