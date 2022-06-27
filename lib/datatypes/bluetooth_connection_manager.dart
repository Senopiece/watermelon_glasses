import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

/// disconnected <-auto- -connect-> connecting -auto-> connected -auto-> disconnected
abstract class BluetoothConnectionManagerState {}

class Disconnected implements BluetoothConnectionManagerState {}

class Connecting implements BluetoothConnectionManagerState {
  final Future<BluetoothConnection> _futureConnection;
  Future<BluetoothConnection> get futureConnection => _futureConnection;
  Connecting(this._futureConnection);
}

class Connected implements BluetoothConnectionManagerState {
  final BluetoothConnection _connection;
  BluetoothConnection get connection => _connection;
  Connected(this._connection);

  // TODO: detect disconnection 2
}

/// state machine over BluetoothConnection
class BluetoothConnectionManager {
  final String address;
  BluetoothConnectionManagerState _state;

  BluetoothConnectionManagerState get state => _state; // TODO: states stream 3
  BluetoothConnectionManager(this.address) : _state = Disconnected();

  void connect() {
    assert(_state is Disconnected);
    _state = Connecting(BluetoothConnection.toAddress(address));
    // TODO: await connection 1
  }
}
