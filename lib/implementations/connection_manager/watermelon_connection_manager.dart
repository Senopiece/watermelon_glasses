import 'dart:async';

import 'package:watermelon_glasses/abstracts/connection_manager.dart';
import 'package:watermelon_glasses/abstracts/rrc_connection_manager.dart';
import 'package:watermelon_glasses/abstracts/watermelon.dart';
import 'package:watermelon_glasses/helpers/listenable.dart';

class WatermelonConnectionManager extends ConnectionManager {
  final RrcConnectionManager _connector;

  final _state = Listenable<ConnectionManagerState>(
    Disconnected(NotInitialized()),
  );

  /// to listen to [_connector]
  late final StreamSubscription<ConnectionManagerState> _statesStreamListener;

  WatermelonConnectionManager(this._connector) {
    _statesStreamListener = _connector.statesStream.listen(
      (newState) {
        if (newState is! Connected) {
          // fully dispose watermelon
          if (currentState is ConnectedWatermelon) {
            (currentState as ConnectedWatermelon).watermelon.free();
          }

          // retranslate immediately
          _updateState(newState);
        }
      },
    );
  }

  @override
  ConnectionManagerState get currentState => _state.data;

  @override
  Stream<ConnectionManagerState> get statesStream => _state.stream;

  @override
  Future<Connected> connect() async {
    assert(currentState is Disconnected);

    final connectorState = await _connector.connect();
    final state = (connectorState as ConnectedRRC);
    var watermelon = Watermelon(state.rrc);

    try {
      watermelon = await watermelon.determineVersion();
      await watermelon.initialize();

      _updateState(
        ConnectedWatermelon(
          watermelon,
          state.close,
        ),
      );
    } catch (e) {
      state.close();
      throw FailedToConnect(e);
    }

    return currentState as Connected;
  }

  /// private because external modification may cause undefined behaviour
  void _updateState(ConnectionManagerState newState) {
    _state.data = newState;
  }

  /// Important: do not forget to call it before freeing
  @override
  void finalize() {
    _statesStreamListener.cancel();
    _connector.finalize();
  }
}

// ---> states

class ConnectedWatermelon extends Connected {
  final Watermelon _watermelon;
  final Future<void> Function() _close;

  ConnectedWatermelon(
    this._watermelon,
    this._close,
  );

  Watermelon get watermelon => _watermelon;

  @override
  Future<void> close() => _close();
}
