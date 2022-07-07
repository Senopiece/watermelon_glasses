import 'package:get/get.dart';
import 'package:watermelon_glasses/abstracts/watermelon.dart';
import 'package:watermelon_glasses/datatypes/time.dart';

import 'time_page_controller.dart';

/// NOTE: this class delegates all the context work to the TimePageController,
/// so like the connection setup into not manual mode etc...
class TimeSyncController extends GetxController {
  Time get time => duckWatermelon.immediateDeviceTime;
  bool get isUnsynced => Time.now().diff(time).abs() > 5;

  get duckWatermelon => watermelon;
  Watermelon get watermelon => Get.find<TimePageController>().watermelon!;

  bool _tick = true;
  bool _syncing = false;

  void sync() {
    if (_syncing) return;
    _syncing = true;
    duckWatermelon.setTime(Time.now()).whenComplete(
      () {
        _syncing = false;
        update();
      },
    );
  }

  @override
  void onInit() {
    super.onInit();

    // ticker
    Future(
      () async {
        while (_tick) {
          update();
          await Future.delayed(const Duration(milliseconds: 100));
        }
      },
    );
  }

  @override
  void onClose() {
    _tick = false; // disable ticker
    super.onClose();
  }
}
