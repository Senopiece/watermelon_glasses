import 'package:get/get.dart';
import 'package:watermelon_glasses/datatypes/watermelon.dart';

import 'time_page_controller.dart';

/// NOTE: this class delegates all the context work to the TimePageController,
/// so like the connection setup into not manual mode etc...
class TimeSyncController extends GetxController {
  final _time = Rxn<DateTime>();
  final _unsynced = false.obs;

  DateTime? get time => _time.value;
  set time(DateTime? newValue) => _time.value = newValue;

  String get text =>
      time == null ? '' : '${time!.hour}:${time!.minute}:${time!.second}';

  bool get isUnsynced => _unsynced.value;
  set isUnsynced(bool newValue) => _unsynced.value = newValue;

  DateTime get now {
    DateTime now = DateTime.now();
    return DateTime(2000, 1, 1, now.hour, now.minute, now.second);
  }

  Watermelon? get watermelon => Get.find<TimePageController>().watermelon;

  void sync() {
    watermelon!.setTime(now);
    time = now;
    isUnsynced = false;
  }

  @override
  void onInit() {
    super.onInit();

    // get the initial time
    Future(
      () async {
        time = await watermelon!.getTime();

        // error rate: +-5 sec
        if (now.difference(time!) > const Duration(seconds: 5)) {
          isUnsynced = true;
        }

        // ticker
        Future(
          () async {
            await Future.delayed(const Duration(seconds: 1));
            while (time != null) {
              time = time!.add(const Duration(seconds: 1));
              await Future.delayed(const Duration(seconds: 1));
            }
          },
        );
      },
    );
  }

  @override
  void onClose() {
    time = null; // to disable ticker
    super.onClose();
  }
}
