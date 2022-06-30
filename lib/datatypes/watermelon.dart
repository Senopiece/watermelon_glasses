import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:typed_data';

import 'rrc.dart';
import 'time_interval.dart';

// TODO: versioning of protocols support

// TODO: check error response (eg listen to a responce)

class Cancelled extends Error {}

typedef FutureProducer<T> = Future<T> Function();

class Task<T> {
  final FutureProducer<T> f;
  final Completer<T> c;
  Task(this.f, this.c);
}

/// wrapper over BluetoothConnection to support watermelon commands,
/// see https://github.com/Senopiece/watermelon/blob/main/README.md
class Watermelon {
  final RRC connection;

  bool? _isManualMode = false;
  bool? get isManualMode => _isManualMode;

  Future<int>? _channelsCount;

  /// slow on the first access, immediate after
  ///
  /// Important: ensure manual mode is not manual,
  /// before calling this thing the first time,
  /// otherwise the returned future will newer complete
  Future<int> get channelsCount {
    _channelsCount ??= Future(
      () async => (await getSchedule()).length,
    );
    return _channelsCount!;
  }

  Queue<Task>? _actions = Queue<Task>();

  /// Important: call this before freeing the instance completely
  void free() {
    flushActions();
    _actions = null;
  }

  /// Note: if you added too many actions and don't want to do them all,
  /// you can call `flushActions()`,
  /// it will complete all the pending with exception [Cancelled]
  void flushActions() {
    if (_actions != null) {
      for (final action in _actions!) {
        action.c.completeError(Cancelled());
      }
      _actions!.clear();
    }
  }

  Watermelon(this.connection) {
    Future(
      () async {
        while (_actions != null) {
          // pick task
          while (_actions!.isEmpty) {
            await Future.delayed(const Duration(milliseconds: 10));
            if (_actions == null) return;
          }
          Task nextTask = _actions!.first;
          _actions!.removeFirst();

          // do task
          try {
            final res = await nextTask.f();
            nextTask.c.complete(res);
          } catch (e) {
            nextTask.c.completeError(e);
          }
        }
      },
    );
  }

  /// must use internally
  Future<void> sendRaw(String data) async {
    await connection.send(Uint8List.fromList('$data\n'.codeUnits));
  }

  /// must use internally
  Future<String> getRaw() async {
    return ascii.decode(await connection.get());
  }

  /// internal protector
  /// methods protected by him cannot be invoked in parallel
  Future<T> _asyncSafe<T>(FutureProducer<T> f) {
    final completer = Completer<T>();
    _actions!.add(Task<T>(f, completer));
    return completer.future;
  }

  Future<void> enterManualMode() => _asyncSafe(
        () async {
          await sendRaw("manual mode");
          _isManualMode = true;
        },
      );

  Future<void> exitManualMode() => _asyncSafe(
        () async {
          await sendRaw("exit manual mode");
          _isManualMode = false;
        },
      );

  Future<void> openChannel(int index) => _asyncSafe(
        () async {
          assert(isManualMode!);
          await sendRaw("open ${index + 1}");
        },
      );

  Future<void> closeChannel(int index) => _asyncSafe(
        () async {
          assert(isManualMode!);
          await sendRaw("close ${index + 1}");
        },
      );

  Future<void> setTime(DateTime time) => _asyncSafe(
        () async {
          assert(!isManualMode!);
          await sendRaw(
              "set time to ${time.hour}:${time.minute}:${time.second}");
        },
      );

  Future<DateTime> getTime() => _asyncSafe(
        () async {
          assert(!isManualMode!);
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
          assert(!isManualMode!);
          await sendRaw("get shedule");
          final lines = (await getRaw()).split('\n');
          lines.removeLast();

          final res = <List<TimeInterval>>[];
          for (String line in lines) {
            final channelSchedule = <TimeInterval>[];
            line = line.substring(3); // cut "n: "
            final parts = line.split(',');
            for (String part in parts) {
              part = part.trim();
              try {
                channelSchedule.add(TimeInterval.parse(part));
              } catch (e) {
                // do nothing
              }
            }
            res.add(channelSchedule);
          }

          return res;
        },
      );
}
