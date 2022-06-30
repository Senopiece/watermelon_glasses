import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:watermelon_glasses/datatypes/bluetooth_connection_manager.dart';
import 'package:watermelon_glasses/datatypes/watermelon.dart';

import 'connection_page_controller.dart';

class ManualPageController extends GetxController {
  late final Future<void> watermelonCreator;
  final _watermelon = Rxn<Watermelon>();
  final channels = <bool>[].obs;

  late final StreamSubscription<BluetoothConnectionManagerState>
      statesStreamListener;

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
          await watermelon!.enterManualMode();
          channels.value = schedule.map<bool>((e) => false).toList();
        } catch (e) {
          watermelon = null;
          print(e);
          // TODO: report to the crashanlytics
        }
      },
    );

    statesStreamListener =
        Get.find<ConnectionPageController>().connector.statesStream.listen(
      (newState) {
        if (newState is Disconnected) {
          watermelon = null;
        }
      },
    );
  }

  @override
  void onClose() {
    statesStreamListener.cancel();
    Future(
      () async {
        await watermelonCreator;
        watermelon?.exitManualMode();
      },
    );
    super.onClose();
  }
}
