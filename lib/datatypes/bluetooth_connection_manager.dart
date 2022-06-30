import 'dart:async';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:watermelon_glasses/datatypes/rrc.dart';

import 'delegate_rrc.dart';
import 'listenable.dart';

/// state machine over BluetoothConnection
class BluetoothConnectionManager {
  final String address;
  final _state = Listenable<BluetoothConnectionManagerState>(Disconnected());

  BluetoothConnectionManager(this.address);

  BluetoothConnectionManagerState get currentState => _state.data;
  Stream<BluetoothConnectionManagerState> get statesStream => _state.stream;

  void connect() {
    // assert guarantees that there is no other future modifying state
    assert(currentState is Disconnected);

    // prepare to run future
    Future<BluetoothConnection> connf = BluetoothConnection.toAddress(address);
    _updateState(Connecting(connf));

    // run auto state flow
    Future(
      () async {
        late final BluetoothConnection conn;
        try {
          conn = await connf;
        } catch (e) {
          _updateState(Disconnected());
          return;
        }

        _updateState(
          Connected(
            conn,
            whenDisconnected: () {
              // it will come here if
              // - bluetooth was disabled
              // - device disconnected
              // - host disconnected
              _updateState(Disconnected());
            },
          ),
        );
      },
    );
  }

  /// private because external modification may cause undefined behaviour
  void _updateState(BluetoothConnectionManagerState newState) {
    _state.data = newState;
  }
}

/// disconnected <-auto- -connect-> connecting -auto-> connected -auto-> disconnected
abstract class BluetoothConnectionManagerState {}

class Connected implements BluetoothConnectionManagerState {
  final BluetoothConnection _connection;
  final VoidCallback? _whenDisconnected;
  final _buff = <int>[];

  Connected(
    this._connection, {
    VoidCallback? whenDisconnected,
  }) : _whenDisconnected = whenDisconnected {
    _connection.input!.listen(
      (Uint8List data) {
        _buff.addAll(data);
      },
    ).onDone(_whenDisconnected);
  }

  RRC get rrc => DelegateRRC(
        // input (passed to DelegateRRC.get())
        () async {
          // will block until buffer becomes filled
          while (_buff.isEmpty) {
            await Future.delayed(const Duration(milliseconds: 10));
          }
          final tmp = <int>[];
          tmp.addAll(_buff);
          _buff.clear();
          return Uint8List.fromList(tmp);
        },
        // output (passed to DelegateRRC.send())
        (Uint8List msg) async {
          _connection.output.add(msg);
          await _connection.output.allSent;
        },
      );

  Future<void> close() => _connection.close();
}

class Connecting implements BluetoothConnectionManagerState {
  final Future<void> _futureConnection;
  Connecting(this._futureConnection);
  Future<void> get futureConnection => _futureConnection;
}

class Disconnected implements BluetoothConnectionManagerState {
  // TODO: add reasoning (e.g. 'failed to connect', 'disconnected by the device', 'disconnected by the host')
}
