import 'dart:async';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:watermelon_glasses/abstracts/rrc.dart';

import 'delegate_rrc.dart';
import 'listenable.dart';

class DisconnectionReason extends Error {
  final dynamic internalReason;
  DisconnectionReason(this.internalReason);
}

class FailedToConnect extends DisconnectionReason {
  FailedToConnect(super.internalReason);
}

class StationaryDisconnection extends DisconnectionReason {
  StationaryDisconnection() : super(null);
}

class NotInitialized extends DisconnectionReason {
  NotInitialized() : super(null);
}

class CancelledConnection extends DisconnectionReason {
  CancelledConnection() : super(null);
}

/// state machine over BluetoothConnection
class BluetoothConnectionManager {
  final String address;
  final _state = Listenable<BluetoothConnectionManagerState>(Disconnected(
    NotInitialized(),
  ));

  BluetoothConnectionManager(this.address);

  BluetoothConnectionManagerState get currentState => _state.data;
  Stream<BluetoothConnectionManagerState> get statesStream => _state.stream;

  Future<void> connect() {
    // assert guarantees that there is no other future modifying state
    assert(currentState is Disconnected);

    // prepare to run future
    Future<BluetoothConnection> connf = BluetoothConnection.toAddress(address);
    _updateState(Connecting(connf));

    // run auto state flow
    return Future(
      () async {
        late final BluetoothConnection conn;
        try {
          await (currentState as Connecting).futureConnection;
          conn = await connf; // must return immediately as
          // previous await already waited for it
        } on DisconnectionReason catch (reason) {
          _updateState(Disconnected(reason));
          rethrow;
        } catch (e) {
          // must NOT enter here
          _updateState(Disconnected(FailedToConnect(e)));
          rethrow;
        }

        _updateState(
          Connected(
            conn,
            whenDisconnected: () {
              // it will come here if
              // - bluetooth was disabled
              // - device disconnected
              // - host disconnected
              _updateState(Disconnected(StationaryDisconnection()));
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
          // will block until buffer becomes filled to \n
          final tmp = <int>[];
          while (tmp.isEmpty || tmp.last != 10) {
            while (_buff.isEmpty) {
              await Future.delayed(const Duration(milliseconds: 10));
            }
            tmp.addAll(_buff);
            _buff.clear();
          }
          return Uint8List.fromList(tmp);
        },
        // output (passed to DelegateRRC.send())
        (Uint8List msg) async {
          _connection.output.add(msg);
          await _connection.output.allSent;
        },
        // isBufferEmpty
        () => _buff.isEmpty,
      );

  Future<void> close() => _connection.close();
}

class Connecting implements BluetoothConnectionManagerState {
  final _completer = Completer<BluetoothConnection>();

  Connecting(Future<BluetoothConnection> futureConnection) {
    Future(() async {
      try {
        final conn = await futureConnection;
        if (_completer.isCompleted) {
          conn.close();
        } else {
          _completer.complete(conn);
        }
      } catch (reason) {
        if (!_completer.isCompleted) {
          _completer.completeError(FailedToConnect(reason));
        }
      }
    });
  }

  // in case of error returns one of CancelledConnection/FailedToConnect
  Future<void> get futureConnection => _completer.future;

  void cancel() {
    assert(!_completer.isCompleted);
    _completer.completeError(CancelledConnection());
  }
}

class Disconnected implements BluetoothConnectionManagerState {
  final DisconnectionReason reason;
  Disconnected(this.reason);
}
