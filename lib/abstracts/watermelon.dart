import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:watermelon_glasses/abstracts/rrc.dart';
import 'package:watermelon_glasses/implementations/watermelons/aleph_1xx/watermelon_aleph_100.dart';
import 'package:watermelon_glasses/implementations/watermelons/aleph_1xx/watermelon_aleph_111.dart';

class UnknownWatermelonVersion extends Error {}

/// wrapper over RRC to support watermelon commands
class Watermelon {
  final RRC connection;

  Watermelon(this.connection);

  int get minorVersion => 0; // internal changes, no external problems
  int get middleVersion => 0; // exceptions changes, should be considered in UI
  int get majorVersion => 0; // interface changes, must be separate UI
  String get name => ''; // alternative solutions for the same digit version
  String get version => '$name-$majorVersion.$middleVersion.$minorVersion';

  Future<void> initialize() => throw UnimplementedError();
  void free() => throw UnimplementedError();

  /// must use internally
  Future<String> getRaw() async {
    return ascii.decode(await connection.getLine());
  }

  /// must use internally
  Future<String> getRawMultilines() async {
    String tmp = '';
    while (true) {
      try {
        tmp += await getRaw();
      } on TimeoutException {
        break;
      }
    }
    return tmp;
  }

  /// must use internally
  Future<void> sendRaw(String data) async {
    await connection.send(Uint8List.fromList('$data\n'.codeUnits));
  }

  Future<Watermelon> determineVersion() async {
    await sendRaw('get version');
    late final String versionString;
    try {
      versionString = (await getRaw()).trimRight();
    } on TimeoutException {
      versionString = 'aleph-1.0.0';
    }

    if (version == versionString) {
      return this;
    }

    switch (versionString) {
      case 'aleph-1.0.0':
        return WatermelonAleph100(connection);
      case 'aleph-1.1.1':
        return WatermelonAleph111(connection);
      default:
        throw UnknownWatermelonVersion();
    }
  }
}
