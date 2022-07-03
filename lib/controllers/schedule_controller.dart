import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
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

  /// will newer throw any errors,
  /// but rather redirect them to crashanalytics and show fail toast
  Future<void> _safeAction(Future<void> action) async {
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

  void addTimeInterval() {
    Get.dialog(
      AddIntervalDialog(
        matchesFilter: (TimeInterval interval) sync* {
          for (final channelIndex in watermelon.putDoesNotIntersect(interval)) {
            if (channels[channelIndex].length != channelCapacity) {
              yield channelIndex;
            }
          }
        },
        submit: (TimeInterval interval, Iterable<int> selected) async {
          // assert(selected is a subset of matchesFilter(interval))
          Get.back();
          for (final channelIndex in selected) {
            await _safeAction(
              watermelon.put(interval, channelIndex),
            );
          }
        },
        onCancel: () => Get.back(),
      ),
    );
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
        await _safeAction(
          watermelon.pull(interval, channel),
        );
      },
      onCancel: () {},
    );
  }
}
