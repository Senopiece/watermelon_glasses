import 'dart:async';

import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

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

        // TODO: make sure no exceptions
        _updateState(Connected(conn));

        // TODO: auto goto disconnected
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
  Connected(this._connection);
  BluetoothConnection get connection => _connection;
}

class Connecting implements BluetoothConnectionManagerState {
  final Future<BluetoothConnection> _futureConnection;
  Connecting(this._futureConnection);
  Future<BluetoothConnection> get futureConnection => _futureConnection;
}

class Disconnected implements BluetoothConnectionManagerState {}
