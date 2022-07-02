import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:watermelon_glasses/controllers/add_interval_controller.dart';
import 'package:watermelon_glasses/datatypes/time_interval.dart';
import 'package:watermelon_glasses/helpers/watermelon.dart';
import 'package:watermelon_glasses/views/time_page/dialogs/add_interval.dart';

import 'time_page_controller.dart';

/// NOTE: this class delegates all the context work to the TimePageController,
/// so like the connection setup into not manual mode etc...
class ScheduleController extends GetxController {
  Watermelon get watermelon => Get.find<TimePageController>().watermelon!;
  List<List<TimeInterval>> get channels => watermelon.immediateChannels;
  int get channelCapacity => watermelon.channelScheduleCapacity;

  // TODO: close any dialogs when state is disconnected

  Future<void> _safeWatermelonAction(Future<void> action) async {
    try {
      await action;
      update();
    } catch (e) {
      Fluttertoast.cancel();
      Fluttertoast.showToast(
        msg: "a command to watermelon failed",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      // todo: be further handled by crashanalytics
    }
  }

  void addTimeInterval() async {
    dynamic ret = await Get.dialog(
      const AddIntervalDialog(),
    );
    if (ret is ReturnData) {
      for (final channelIndex in ret.channelsToPut) {
        await _safeWatermelonAction(
          watermelon.put(ret.interval, channelIndex),
        );
      }
    }
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
        Get.back();
        await _safeWatermelonAction(
          watermelon.pull(interval, channel),
        );
      },
      onCancel: () {},
    );
  }
}
