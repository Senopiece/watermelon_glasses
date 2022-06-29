import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';

import 'rrc.dart';
import 'time_interval.dart';

// TODO: versioning of protocols support

// TODO: check error response (eg listen to a responce)

class Occupied extends Error {}

/// wrapper over BluetoothConnection to support watermelon commands,
/// see https://github.com/Senopiece/watermelon/blob/main/README.md
class Watermelon {
  final RRC connection;
  bool _busy = false;
  bool isManualMode = false; // TODO: check it's state dynamically

  Watermelon(this.connection);

  /// must use internally
  Future<void> sendRaw(String data) async {
    await connection.send(Uint8List.fromList(data.codeUnits));
  }

  /// must use internally
  Future<String> getRaw() async {
    return ascii.decode(await connection.get());
  }

  /// internal protector
  Future<T> _asyncSafe<T>(Future<T> Function() f) {
    if (_busy) {
      throw Occupied();
    }
    _busy = true;
    return Future(
      () async {
        late final T res;
        try {
          res = await f();
        } catch (e) {
          _busy = false;
          rethrow;
        } finally {
          _busy = false;
        }
        return res;
      },
    );
  }

  Future<void> enterManualMode() => _asyncSafe(
        () async {
          await sendRaw("manual mode");
          isManualMode = true;
        },
      );

  Future<void> exitManualMode() => _asyncSafe(
        () async {
          await sendRaw("exit manual mode");
          isManualMode = false;
        },
      );

  Future<void> openChannel(int index) => _asyncSafe(
        () async {
          assert(isManualMode);
          await sendRaw("open $index");
        },
      );

  Future<void> closeChannel(int index) => _asyncSafe(
        () async {
          assert(isManualMode);
          await sendRaw("close $index");
        },
      );

  Future<void> setTime(DateTime time) => _asyncSafe(
        () async {
          assert(!isManualMode);
          await sendRaw("set time ${time.hour}:${time.minute}:${time.second}");
        },
      );

  Future<DateTime> getTime() => _asyncSafe(
        () async {
          await sendRaw("get time");
          final parts = (await getRaw()).split(':');
          final h = int.parse(parts[0]);
          final m = int.parse(parts[1]);
          final s = int.parse(parts[2]);
          return DateTime(2000, 1, 1, h, m, s);
        },
      );

  /// return example:
  /// [
  ///   [11:00 - 12:00, 14:00 - 15:00]
  ///   [15:00 - 16:00, 16:00 - 17:00]
  ///   []
  ///   []
  ///   [22:00 - 22:30]
  /// ]
  Future<List<List<TimeInterval>>> getSchedule() => _asyncSafe(
        () async {
          await sendRaw("get shedule");
          final lines = (await getRaw()).split('\n');

          final res = <List<TimeInterval>>[];
          for (String line in lines) {
            final channelSchedule = <TimeInterval>[];
            line = line.substring(3); // cut "n: "
            final parts = line.split(',');
            for (String part in parts) {
              part = part.trim();
              channelSchedule.add(TimeInterval.parse(part));
            }
            res.add(channelSchedule);
          }

          return res;
        },
      );
}
