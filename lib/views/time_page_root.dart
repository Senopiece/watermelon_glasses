import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:watermelon_glasses/controllers/time_page_controller.dart';

import 'time_page/time_sync.dart';

class TimePageRoot extends GetView<TimePageController> {
  const TimePageRoot({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Obx(
          () => controller.watermelon == null
              ? controller.connecting
                  ? const CircularProgressIndicator()
                  : Text('no device connected'.tr)
              : const TimeSync(),
        ),
      ),
    );
  }
}
