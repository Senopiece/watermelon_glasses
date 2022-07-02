import 'package:get/get.dart';
import 'package:watermelon_glasses/datatypes/time_interval.dart';
import 'package:watermelon_glasses/helpers/watermelon.dart';

import 'time_page_controller.dart';

/// NOTE: this class delegates all the context work to the TimePageController,
/// so like the connection setup into not manual mode etc...
class ScheduleController extends GetxController {
  Watermelon get watermelon => Get.find<TimePageController>().watermelon!;
  List<List<TimeInterval>> get channels => watermelon.immediateChannels;
  int get channelCapacity => watermelon.channelScheduleCapacity;

  // TODO: close any dialogs when state is disconnected

  void addTimeInterval() {
    //update();
  }

  // TODO: add edit dialog
  // it's better to have long press to drag time interval between channels, and
  // short press to enable edit/delete/cancel question dialog,
  // which then redirects to edit or delete dialogs correspondingly

  void removeTimeInterval(int channel, TimeInterval interval) {
    Get.defaultDialog(
      title: "Approve action",
      middleText: 'Remove?',
      onConfirm: () async {
        await watermelon.pull(interval, channel);
        Get.back();
        update();
      },
      onCancel: () {},
    );
  }
}
