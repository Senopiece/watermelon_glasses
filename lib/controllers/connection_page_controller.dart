import 'dart:async';

import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:get/get.dart';
import 'package:watermelon_glasses/controllers/bluetooth_page_controller.dart';
import 'package:watermelon_glasses/helpers/bluetooth_connection_manager.dart';
import 'package:watermelon_glasses/helpers/listenable.dart';
import 'package:watermelon_glasses/helpers/watermelon.dart';

class ConnectionPageController extends GetxController {
  final BluetoothDevice device;
  final BluetoothConnectionManager _connector;
  late final StreamSubscription<BluetoothConnectionManagerState>
      _statesStreamListener;
  Watermelon? _watermelon;

  /// retranslation of _connector.statesStream
  /// reasoning:
  /// 1) unbind references for garbage collection
  /// 2) retranslate state [Connected] only after done some work on it
  final _state = Listenable<BluetoothConnectionManagerState>(Disconnected());
  BluetoothConnectionManagerState get currentState => _state.data;
  Stream<BluetoothConnectionManagerState> get statesStream => _state.stream;

  void _updateState(BluetoothConnectionManagerState newState) {
    _state.data = newState;

    // update view as it must display the same state
    update();
  }

  /// hide watermelon in case it is still occupied
  Watermelon? get getWatermelon =>
      (currentState is Connected) ? _watermelon : null;

  ConnectionPageController(this.device)
      : _connector = BluetoothConnectionManager(device.address);

  void gotoDiscoverySubPage() {
    Get.find<BluetoothPageController>().gotoDiscoverySubPage();
  }

  @override
  void onClose() {
    _statesStreamListener.cancel();
    if (_connector.currentState is Connected) {
      (_connector.currentState as Connected).close();
    }
    super.onClose();
  }

  @override
  void onInit() {
    super.onInit();
    _statesStreamListener = _connector.statesStream.listen(
      (newState) {
        if (newState is Connected) {
          _watermelon = Watermelon(
            (_connector.currentState as Connected).rrc,
          );

          // start channels getter right here,
          // so it further can be accessed immediately
          Future(
            () async {
              try {
                // ensure no manual mode for the next invocations
                await _watermelon!.exitManualMode();

                // invoke this things firstly,
                // so they will be cached for the further fast access
                await _watermelon!.channelsCount;
                await _watermelon!.deviceTime;

                // retranslate state after all the work of this class is done,
                // so others can pick it up safely
                _updateState(newState);
              } catch (e) {
                (_connector.currentState as Connected).close();
              }
            },
          );
        } else {
          // fully dispose watermelon according to doc of [actions] parameter
          _watermelon?.free();
          _watermelon = null;

          // retranslate immediately
          _updateState(newState);
        }
      },
    );
    _connector.connect();
  }
}
