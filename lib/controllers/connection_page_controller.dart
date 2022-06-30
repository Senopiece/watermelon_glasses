import 'dart:async';

import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:get/get.dart';
import 'package:watermelon_glasses/controllers/bluetooth_page_controller.dart';
import 'package:watermelon_glasses/datatypes/bluetooth_connection_manager.dart';
import 'package:watermelon_glasses/datatypes/listenable.dart';
import 'package:watermelon_glasses/datatypes/watermelon.dart';

enum ConnectionSate { connecting, connected, disconnected }

class ConnectionPageController extends GetxController {
  final BluetoothDevice device;
  final BluetoothConnectionManager _connector;
  late final StreamSubscription<BluetoothConnectionManagerState>
      _statesStreamListener;
  Watermelon? _watermelon;

  final _connectionStateRetranslator =
      StreamController<BluetoothConnectionManagerState>.broadcast();

  /// retranslation of _connector.statesStream
  /// reasoning:
  /// 1) unbind references for garbage collection
  /// 2) retranslate safe connection if it's [Connected] state
  Stream<BluetoothConnectionManagerState> get statesStream =>
      _connectionStateRetranslator.stream;

  Watermelon? get getWatermelon => _watermelon;

  ConnectionSate get currentState {
    switch (_connector.currentState.runtimeType) {
      case Connected:
        return ConnectionSate.connected;
      case Connecting:
        return ConnectionSate.connecting;
      case Disconnected:
        return ConnectionSate.disconnected;
      default:
        throw TypeError();
    }
  }

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
    _connector.connect();
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
              await _watermelon!.exitManualMode();
              await _watermelon!.channelsCount;

              // retranslate state after all the work of this class is done,
              // so others can pick it up safely
              _connectionStateRetranslator.add(newState);
            },
          );
        } else {
          // fully dispose watermelon according to doc of [actions] parameter
          _watermelon?.free();
          _watermelon = null;

          // retranslate
          _connectionStateRetranslator.add(newState);
        }

        // update view
        update();
      },
    );
  }
}
