import 'package:get/get.dart';
import 'package:watermelon_glasses/datatypes/watermelon.dart';

import 'connection_page_controller.dart';

class ManualPageController extends GetxController {
  late final Future<void> watermelonCreator;
  final _watermelon = Rxn<Watermelon>();
  final channels = <bool>[].obs;

  Watermelon? get watermelon => _watermelon.value;
  set watermelon(Watermelon? val) => _watermelon.value = val;

  Future<void> switchChannel(int index) async {
    try {
      if (channels[index]) {
        await watermelon!.closeChannel(index);
      } else {
        await watermelon!.openChannel(index);
      }
      channels[index] = !channels[index];
    } catch (e) {
      Get.snackbar(
        "error",
        "failed to ${channels[index] ? 'close' : 'open'} channel",
      );
      rethrow;
    }
  }

  @override
  void onInit() {
    super.onInit();
    watermelonCreator = Future(
      () async {
        try {
          // wrap connection into descriptor
          watermelon = Watermelon(Get.find<ConnectionPageController>().getRRC);

          // collect channels number
          await watermelon!.exitManualMode();
          final schedule = await watermelon!.getSchedule();
          channels.value = schedule.map<bool>((e) => false).toList();
          await watermelon!.enterManualMode();
        } on Occupied {
          rethrow;
        } catch (e) {
          watermelon = null;
          print(e); // TODO: rm
        }
      },
    );
  }

  @override
  void onClose() {
    Future(
      () async {
        await watermelonCreator;
        watermelon?.exitManualMode();
      },
    );
    super.onClose();
  }
}