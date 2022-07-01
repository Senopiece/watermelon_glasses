import 'dart:typed_data';

/// request-response connection
class RRC {
  Future<void> send(Uint8List msg) => throw UnimplementedError();
  // TODO: add timeout parameter
  Future<Uint8List> get() => throw UnimplementedError();
  bool get isBufferEmpty => throw UnimplementedError();
}
