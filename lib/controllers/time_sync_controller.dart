import 'package:get/get.dart';
import 'package:watermelon_glasses/datatypes/watermelon.dart';

import 'time_page_controller.dart';

/// NOTE: this class delegates all the context work to the TimePageController,
/// so like the connection setup into not manual mode etc...
class TimeSyncController extends GetxController {
  DateTime get time => watermelon!.immediateDeviceTime;
  String get text => '${time.hour}:${time.minute}:${time.second}';
  bool get isUnsynced => now.difference(time) > const Duration(seconds: 5);

  DateTime get now {
    DateTime now = DateTime.now();
    return DateTime(2000, 1, 1, now.hour, now.minute, now.second);
  }

  Watermelon? get watermelon => Get.find<TimePageController>().watermelon;

  bool _tick = true;
  bool _syncing = false;

  void sync() {
    if (_syncing) return;
    _syncing = true;
    watermelon!.setTime(now).whenComplete(
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
