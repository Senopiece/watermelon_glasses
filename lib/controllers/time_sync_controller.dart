import 'package:get/get.dart';
import 'package:watermelon_glasses/datatypes/Time.dart';
import 'package:watermelon_glasses/datatypes/watermelon.dart';

import 'time_page_controller.dart';

/// NOTE: this class delegates all the context work to the TimePageController,
/// so like the connection setup into not manual mode etc...
class TimeSyncController extends GetxController {
  Time get time => watermelon!.immediateDeviceTime;
  String get text => '${time.hour}:${time.minute}:${time.second}';
  bool get isUnsynced => Time.now().diff(time) > 5;

  Watermelon? get watermelon => Get.find<TimePageController>().watermelon;

  bool _tick = true;
  bool _syncing = false;

  void sync() {
    if (_syncing) return;
    _syncing = true;
    watermelon!.setTime(Time.now()).whenComplete(
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
        await Future.delayed(const Duration(seconds: 1));
        while (_tick) {
          update();
          await Future.delayed(const Duration(seconds: 1));
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
