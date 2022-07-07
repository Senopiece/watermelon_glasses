import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:watermelon_glasses/controllers/time_page_controller.dart';

import 'time_page/schedule.dart';
import 'time_page/time_sync.dart';

class TimePageRoot extends GetView<TimePageController> {
  const TimePageRoot({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(
        () => controller.watermelon == null
            ? Center(
                child: controller.connecting
                    ? const CircularProgressIndicator()
                    : Text('no device connected'.tr),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  TimeSync(),
                  Expanded(child: Schedule()),
                ],
              ),
      ),
    );
  }
}
