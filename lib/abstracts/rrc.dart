import 'dart:typed_data';

/// request-response connection
class RRC {
  Future<void> send(Uint8List msg) => throw UnimplementedError();
  Future<Uint8List> getLine({Duration timeout = const Duration(seconds: 1)}) =>
      throw UnimplementedError();
  Uint8List drainBuff() => throw UnimplementedError();
  bool get isBufferEmpty => throw UnimplementedError();
}
