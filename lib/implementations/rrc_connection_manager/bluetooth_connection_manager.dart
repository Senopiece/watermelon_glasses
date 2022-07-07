import 'dart:async';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:watermelon_glasses/abstracts/connection_manager.dart';
import 'package:watermelon_glasses/abstracts/rrc.dart';
import 'package:watermelon_glasses/abstracts/rrc_connection_manager.dart';
import 'package:watermelon_glasses/helpers/listenable.dart';
import 'package:watermelon_glasses/implementations/rcc/delegate_rrc.dart';

/// state machine over BluetoothConnection
class BluetoothConnectionManager extends RrcConnectionManager {
  final String address;
  final _state = Listenable<ConnectionManagerState>(
    Disconnected(NotInitialized()),
  );

  BluetoothConnectionManager(this.address);

  @override
  ConnectionManagerState get currentState => _state.data;

  @override
  Stream<ConnectionManagerState> get statesStream => _state.stream;

  @override
  Future<Connected> connect() {
    // assert guarantees that there is no other future modifying state
    assert(currentState is Disconnected);

    // prepare to run future
    Future<BluetoothConnection> connf = BluetoothConnection.toAddress(address);
    _updateState(_Connecting(connf));

    // run auto state flow
    return Future(
      () async {
        late final BluetoothConnection conn;
        try {
          await (currentState as _Connecting).futureConnection;
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
          _Connected(
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

        return currentState as Connected;
      },
    );
  }

  @override
  void finalize() {
    if (currentState is Connected) {
      (currentState as Connected).close();
    } else if (currentState is Connecting) {
      (currentState as Connecting).cancel();
    }
  }

  /// private because external modification may cause undefined behaviour
  void _updateState(ConnectionManagerState newState) {
    _state.data = newState;
  }
}

class _Connected extends ConnectedRRC {
  final BluetoothConnection _connection;
  final VoidCallback? _whenDisconnected;
  final _buff = <int>[];

  _Connected(
    this._connection, {
    VoidCallback? whenDisconnected,
  }) : _whenDisconnected = whenDisconnected {
    _connection.input!.listen(
      (Uint8List data) {
        _buff.addAll(data);
      },
    ).onDone(_whenDisconnected);
  }

  @override
  RRC get rrc => DelegateRRC(
        // input (passed to DelegateRRC.getLine())
        ({required Duration timeout}) async {
          // will block until buffer becomes filled to the first income of \n
          // will return the amount of data until the first \n,
          // so buffer will be drained until the first income of \n
          final start = DateTime.now();
          final tmp = <int>[];
          while (tmp.isEmpty || tmp.last != 10) {
            while (_buff.isEmpty) {
              if (DateTime.now().difference(start) > timeout) {
                throw TimeoutException('timeout');
              }
              await Future.delayed(const Duration(milliseconds: 10));
            }
            while ((tmp.isEmpty || tmp.last != 10) && _buff.isNotEmpty) {
              tmp.add(_buff.first);
              _buff.removeAt(0);
            }
          }
          return Uint8List.fromList(tmp);
        },
        // output (passed to DelegateRRC.send())
        (Uint8List msg) async {
          _connection.output.add(msg);
          await _connection.output.allSent;
        },
        // drain
        () {
          final tmp = <int>[];
          tmp.addAll(_buff);
          _buff.clear();
          return Uint8List.fromList(tmp);
        },
        // isBufferEmpty
        () => _buff.isEmpty,
      );

  @override
  Future<void> close() => _connection.close();
}

class _Connecting extends Connecting {
  final _completer = Completer<BluetoothConnection>();

  _Connecting(Future<BluetoothConnection> futureConnection) {
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
  @override
  Future<void> get futureConnection => _completer.future;

  @override
  void cancel() {
    assert(!_completer.isCompleted);
    _completer.completeError(CancelledConnection());
  }
}
