import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:watermelon_glasses/abstracts/watermelon.dart';
import 'package:watermelon_glasses/datatypes/time.dart';
import 'package:watermelon_glasses/datatypes/time_interval.dart';
import 'package:watermelon_glasses/implementations/watermelons/aleph_1xx/watermelon_aleph_100.dart';
import 'package:watermelon_glasses/services/crashanalytics.dart';
import 'package:watermelon_glasses/views/time_page/dialogs/add_interval.dart';

import 'time_page_controller.dart';

/// NOTE: this class delegates all the context work to the TimePageController,
/// so like the connection setup into not manual mode etc...
class ScheduleController extends GetxController {
  get duckWatermelon => Get.find<TimePageController>().watermelon!;
  Watermelon get watermelon => Get.find<TimePageController>().watermelon!;

  List<List<TimeInterval>> get channels => duckWatermelon.immediateChannels;
  int get channelCapacity => duckWatermelon.channelScheduleCapacity;

  /// will newer throw any errors,
  /// but rather redirect them to crashanalytics and show fail toast
  Future<void> _safeAction(Future<void> action) async {
    try {
      await action;
      update();
    } catch (e, s) {
      // don't let it be a stopper, send report directly to crashanalytics
      Get.find<Crashanalytics>().recordError(e, s);

      // notify user by error toast
      Fluttertoast.cancel();
      Fluttertoast.showToast(
        msg: "action failed".tr,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

  void addTimeInterval() {
    if (watermelon is WatermelonAleph100) {
      final wmelon = watermelon as WatermelonAleph100;

      Get.dialog(
        AddIntervalDialog(
          matchesFilter: (TimeInterval interval) sync* {
            for (final int channelIndex
                in wmelon.putDoesNotIntersect(interval)) {
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
                wmelon.put(interval, channelIndex),
              );
            }
          },
          onCancel: () => Get.back(),
          initialData: TimeInterval.parse('12:00 - 12:59'),
          timeSync: (TimeInterval prev, TimeInterval next) {
            Time startTime = next.startTime;
            Time endTime = next.endTime;

            if (!(next.endTime > next.startTime)) {
              if (prev.endTime > next.startTime) {
                endTime = prev.endTime;
              } else {
                endTime = startTime.advance(60);
              }
            }

            return TimeInterval(startTime, endTime);
          },
        ),
      );
    } else {
      Fluttertoast.cancel();
      Fluttertoast.showToast(
        msg: "Unsupported hardware version".tr,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

  // TODO: add edit dialog
  // it's better to have long press to drag time interval between channels, and
  // short press to enable edit/delete/cancel question dialog,
  // which then redirects to edit or delete dialogs correspondingly

  void removeTimeInterval(int channel, TimeInterval interval) {
    Get.defaultDialog(
      title: "Approve action".tr,
      middleText: '${'Remove'.tr}?',
      onConfirm: () async {
        Get.back();
        await _safeAction(
          duckWatermelon.pull(interval, channel),
        );
      },
      onCancel: () {},
    );
  }
}
