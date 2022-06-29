import 'dart:async';
import 'dart:typed_data';

import 'package:watermelon_glasses/datatypes/rrc.dart';

/// request-response connection
class DelegateRRC extends RRC {
  final Future<Uint8List> Function() input;
  final Future<void> Function(Uint8List) output;

  DelegateRRC(this.input, this.output);

  @override
  Future<void> send(Uint8List msg) => output(msg);

  @override
  Future<Uint8List> get() => input();
}
