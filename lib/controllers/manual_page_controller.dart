import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:watermelon_glasses/abstracts/connection_manager.dart';
import 'package:watermelon_glasses/abstracts/watermelon.dart';
import 'package:watermelon_glasses/implementations/connection_manager/watermelon_connection_manager.dart';

import 'connection_page_controller.dart';

class ManualPageController extends GetxController {
  final _watermelon = Rxn<Watermelon>();
  final _connecting = false.obs;
  final channels = <bool>[].obs;

  ConnectionPageController? connectionController;
  StreamSubscription<ConnectionManagerState>? statesStreamListener;

  bool get connecting => _connecting.value;
  set connecting(bool val) => _connecting.value = val;

  get duckWatermelon => _watermelon.value;
  set watermelon(Watermelon? val) => _watermelon.value = val;

  Future<void> switchChannel(int index) async {
    try {
      if (channels[index]) {
        await duckWatermelon.closeChannel(index);
      } else {
        await duckWatermelon.openChannel(index);
      }
      channels[index] = !channels[index];
    } catch (e) {
      Fluttertoast.cancel();
      Fluttertoast.showToast(
        msg: "failed to ${channels[index] ? 'close' : 'open'} channel",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      rethrow; // to be further handled by crashanalytics
    }
  }

  /// NOTE: ensure connectionController is not null
  void _instantiateWatermelon(ConnectionManagerState newState) {
    watermelon = null;
    connecting = newState is Connecting;

    if (newState is Connected) {
      watermelon = (newState as ConnectedWatermelon).watermelon;
      channels.value = List.filled(
        duckWatermelon.immediateChannels.length,
        false,
      );
      duckWatermelon.enterManualMode();
    }
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
        (newState) => _instantiateWatermelon(newState),
      );
    } else {
      connecting = false;
    }
  }

  @override
  void onClose() {
    statesStreamListener?.cancel();
    duckWatermelon?.flushActions();
    duckWatermelon?.exitManualMode();
    super.onClose();
  }
}
