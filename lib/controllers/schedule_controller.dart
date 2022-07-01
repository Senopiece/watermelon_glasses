import 'dart:async';

import 'package:get/get.dart';
import 'package:watermelon_glasses/datatypes/Time.dart';
import 'package:watermelon_glasses/datatypes/time_interval.dart';
import 'package:watermelon_glasses/helpers/watermelon.dart';

import 'time_page_controller.dart';

/// NOTE: this class delegates all the context work to the TimePageController,
/// so like the connection setup into not manual mode etc...
class ScheduleController extends GetxController {
  Watermelon get watermelon => Get.find<TimePageController>().watermelon!;
  List<List<TimeInterval>> get channels => watermelon.immediateChannels;

  void addTimeInterval(int channel) {
    // TODO: pop a dialog to add new interval
    print(channel);
    //update();
  }

  void removeTimeInterval(int channel, TimeInterval interval) {
    Get.defaultDialog(
      title: "Are you sure you want to remove it?",
      onConfirm: () async {
        await watermelon.pull(interval, channel);
        update();
      },
      onCancel: () {},
    );
  }
}
