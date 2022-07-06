import 'dart:async';
import 'dart:typed_data';

import 'package:watermelon_glasses/abstracts/rrc.dart';

/// request-response connection
class DelegateRRC extends RRC {
  final Future<Uint8List> Function({required Duration timeout}) input;
  final Future<void> Function(Uint8List) output;
  final Uint8List Function() drain;
  final bool Function() bufferCheck;

  DelegateRRC(
    this.input,
    this.output,
    this.drain,
    this.bufferCheck,
  );

  @override
  Future<void> send(Uint8List msg) => output(msg);

  @override
  Future<Uint8List> getLine({Duration timeout = const Duration(seconds: 1)}) =>
      input(timeout: timeout);

  @override
  Uint8List drainBuff() => drain();

  @override
  bool get isBufferEmpty => bufferCheck();
}
