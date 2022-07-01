import 'dart:async';

import 'package:get/get.dart';
import 'package:watermelon_glasses/controllers/connection_page_controller.dart';
import 'package:watermelon_glasses/helpers/bluetooth_connection_manager.dart';
import 'package:watermelon_glasses/helpers/watermelon.dart';

class TimePageController extends GetxController {
  final _watermelon = Rxn<Watermelon>();
  final _connecting = false.obs;

  late final ConnectionPageController? connectionController;
  late final StreamSubscription<BluetoothConnectionManagerState>?
      statesStreamListener;

  bool get connecting => _connecting.value;
  set connecting(bool val) => _connecting.value = val;

  Watermelon? get watermelon => _watermelon.value;
  set watermelon(Watermelon? val) => _watermelon.value = val;

  /// NOTE: ensure connectionController is not null
  void _instantiateWatermelon() {
    watermelon = connectionController!.getWatermelon;
    if (watermelon != null) {
      connecting = !(watermelon!.canGetImmediateDeviceTime);
    } else {
      connecting = connectionController!.currentState is Connecting;
    }
    watermelon?.exitManualMode(); // ensure auto mode
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
      _instantiateWatermelon();

      // listen to the further states
      statesStreamListener = connectionController!.statesStream.listen(
        (newState) {
          // there is a good place to cancel [preparator],
          // but dart Futures cannot be cancelled

          // so we don't mind what happens to the prev connection,
          // it's now not in our area of response

          // throw the prev descriptor
          watermelon = null;

          // if there is a new descriptor, pick it
          _instantiateWatermelon();
        },
      );
    } else {
      connecting = false;
    }
  }

  @override
  void onClose() {
    statesStreamListener?.cancel();
    watermelon?.flushActions();
    super.onClose();
  }
}
