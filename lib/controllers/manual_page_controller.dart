import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:watermelon_glasses/datatypes/bluetooth_connection_manager.dart';
import 'package:watermelon_glasses/datatypes/watermelon.dart';

import 'connection_page_controller.dart';

class ManualPageController extends GetxController {
  final _watermelon = Rxn<Watermelon>();
  final channels = <bool>[].obs;

  late final ConnectionPageController? connectionController;
  late final StreamSubscription<BluetoothConnectionManagerState>?
      statesStreamListener;

  Future<void>? preparator;

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
  void _instantiateWatermelon() {
    watermelon = connectionController!.getWatermelon;

    if (watermelon != null) {
      preparator = Future(
        () async {
          channels.value = List.filled(
            await watermelon!.channelsCount,
            false,
          );
          await watermelon!.enterManualMode();
        },
      );
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
          preparator = null;

          // if there is a new descriptor, pick it
          _instantiateWatermelon();
        },
      );
    }
  }

  @override
  void onClose() {
    statesStreamListener?.cancel();
    Future(
      () async {
        if (preparator != null) {
          await preparator;
        }
        await watermelon?.exitManualMode();
      },
    );
    super.onClose();
  }
}
