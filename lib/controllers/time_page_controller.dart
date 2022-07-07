import 'dart:async';

import 'package:get/get.dart';
import 'package:watermelon_glasses/abstracts/connection_manager.dart';
import 'package:watermelon_glasses/abstracts/watermelon.dart';
import 'package:watermelon_glasses/controllers/connection_page_controller.dart';
import 'package:watermelon_glasses/implementations/connection_manager/watermelon_connection_manager.dart';

class TimePageController extends GetxController {
  final _watermelon = Rxn<Watermelon>();
  final _connecting = false.obs;

  ConnectionPageController? connectionController;
  StreamSubscription<ConnectionManagerState>? statesStreamListener;

  bool get connecting => _connecting.value;
  set connecting(bool val) => _connecting.value = val;

  get duckWatermelon => _watermelon.value;
  Watermelon? get watermelon => _watermelon.value;
  set watermelon(Watermelon? val) => _watermelon.value = val;

  /// NOTE: ensure connectionController is not null
  void _instantiateWatermelon(ConnectionManagerState newState) {
    watermelon = null;
    if (newState is Connected) {
      watermelon = (newState as ConnectedWatermelon).watermelon;
      connecting = !(duckWatermelon.canGetImmediateDeviceTime);
    } else {
      connecting = newState is Connecting;
    }
    duckWatermelon?.exitManualMode(); // ensure auto mode
  }

  @override
  void onInit() {
    super.onInit();
    try {
      connectionController = Get.find<ConnectionPageController>();
    } on String {
      connectionController = null;
      statesStreamListener = null;
    }

    if (connectionController != null) {
      // consume initial state
      _instantiateWatermelon(connectionController!.connector!.currentState);

      // listen to the further states
      statesStreamListener =
          connectionController!.connector!.statesStream.listen(
        (newState) {
          // close dialogs when the device is not connected
          if (newState is! Connected) {
            while (Get.isDialogOpen!) {
              Get.back();
            }
          }

          // if there is a new descriptor, pick it
          _instantiateWatermelon(newState);
        },
      );
    } else {
      connecting = false;
    }
  }

  @override
  void onClose() {
    statesStreamListener?.cancel();
    duckWatermelon?.flushActions();
    super.onClose();
  }
}
