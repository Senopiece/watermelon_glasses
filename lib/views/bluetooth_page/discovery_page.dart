import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:watermelon_glasses/controllers/discovery_page_controller.dart';

import 'bluetooth_disabled.dart';
import 'devices_list.dart';

class DiscoveryPage extends GetView<DiscoveryPageController> {
  const DiscoveryPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        body: (controller.isBlueEnabled ?? false
            ?
            // TODO: animated add/remove

            RefreshIndicator(
                onRefresh: () async => controller.startDiscovery(),
                child: const DevicesList(),
              )
            : RefreshIndicator(
                onRefresh: () async => controller.startDiscovery(),
                child: ListView(
                  children: [
                    SizedBox(height: (MediaQuery.of(context).size.height) / 3),
                    const BluetoothDisabled(),
                  ],
                ),
              )),
      ),
    );
  }
}
