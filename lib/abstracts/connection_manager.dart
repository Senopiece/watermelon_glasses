abstract class ConnectionManager {
  ConnectionManagerState get currentState => throw UnimplementedError();
  Stream<ConnectionManagerState> get statesStream => throw UnimplementedError();
  Future<Connected> connect() => throw UnimplementedError();
  void finalize() => throw UnimplementedError();
}

// ---> states

/// disconnected <-auto- -connect-> connecting -auto-> connected -auto-> disconnected
abstract class ConnectionManagerState {}

class Connected implements ConnectionManagerState {
  Future<void> close() => throw UnimplementedError();
}

class Connecting implements ConnectionManagerState {
  // in case of error returns one of CancelledConnection/FailedToConnect
  Future<void> get futureConnection => throw UnimplementedError();
  void cancel() => throw UnimplementedError();
}

class Disconnected implements ConnectionManagerState {
  final DisconnectionReason reason;
  Disconnected(this.reason);
}

// ---> exceptions

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
