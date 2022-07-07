import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:watermelon_glasses/controllers/manual_page_controller.dart';

import 'manual_page/channel_box.dart';

class ManualPageRoot extends GetView<ManualPageController> {
  const ManualPageRoot({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(
        () => controller.duckWatermelon == null
            ? controller.connecting
                ? const Center(child: CircularProgressIndicator())
                : Center(child: Text('no device connected'.tr))
            : (controller.channels.isEmpty)
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : ListView.separated(
                    itemCount: controller.channels.length,
                    itemBuilder: (context, index) {
                      return Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(10),
                        margin: const EdgeInsets.only(top: 10),
                        child: ChannelBox(
                          name: '${'Channel'.tr} ${index + 1}',
                          enabled: controller.channels[index],
                          onSwitch: () => controller.switchChannel(index),
                        ),
                      );
                    },
                    separatorBuilder: (context, index) => const Divider(),
                  ),
      ),
    );
  }
}
