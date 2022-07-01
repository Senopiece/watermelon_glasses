import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:typed_data';

import 'rrc.dart';
import 'time_interval.dart';

// TODO: custom DateTime with period of one day

// TODO: versioning of protocols support

// TODO: check error response (eg listen to a responce)

class Cancelled extends Error {}

class Advance {}

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

  DateTime? _deviceTime;
  Future<DateTime>? _deviceTimeFuture;
  bool _tick = true;

  Watermelon(this.connection) {
    // queue processor
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

    // ticker
    Future(
      () async {
        await Future.delayed(const Duration(seconds: 1));
        while (_tick) {
          _deviceTime = _deviceTime?.add(const Duration(seconds: 1));
          await Future.delayed(const Duration(seconds: 1));
        }
      },
    );
  }

  /// slow on the first access, immediate after
  /// uses a dynamically changing cache,
  /// so next immediate returns would be
  /// as correct as the honest invocation of [getTime]
  ///
  /// Note that if it throws on the first access,
  /// the second will retry the bluetooth call, if the second throws,
  /// the third will act without cache and so on until any successful operation
  ///
  /// Important: ensure mode is not manual,
  /// before calling this thing the first time,
  /// otherwise the returned future will newer complete
  ///
  /// Note that usage of this function is more preferable then [getTime]
  Future<DateTime> get deviceTime {
    assert(_deviceTimeFuture == null || _deviceTime == null);

    // if in auto sync state
    if (_deviceTime != null) return Future(() => _deviceTime!);

    // create new future to fill _deviceTime
    _deviceTimeFuture ??= Future(
      () async {
        try {
          // get the actual time (slow)
          if (_deviceTime != null) throw Advance();
          final res = await getTime(); // may throw error
          if (_deviceTime != null) throw Advance();

          // goto auto sync state
          _deviceTime = res;

          // return to the first awaiters
          _deviceTimeFuture = null;
          return res;
        } on Advance {
          // so _deviceTime was set somewhere externally while we process
          _deviceTimeFuture = null;
          return _deviceTime!;
        } catch (e) {
          // ensure not to cache fails
          assert(_deviceTime == null);
          _deviceTimeFuture = null;
          rethrow;
        }
      },
    );

    // if in calling for actual time state,
    // returns the same future as the first invocation
    return _deviceTimeFuture!;
  }

  Future<int>? _channelsCount;

  /// slow on the first access, immediate after
  ///
  /// Note that if it throws on the first access,
  /// the second will retry the bluetooth call, if the second throws,
  /// the third will act without cache and so on until any successful operation
  ///
  /// Important: ensure mode is not manual,
  /// before calling this thing the first time,
  /// otherwise the returned future will newer complete
  Future<int> get channelsCount {
    _channelsCount ??= Future(
      () async {
        try {
          return (await getSchedule()).length;
        } catch (e) {
          // ensure not to cache fails
          _channelsCount = null;
          rethrow;
        }
      },
    );
    return _channelsCount!;
  }

  Queue<Task>? _actions = Queue<Task>();

  /// Important: call this before freeing the instance completely
  void free() {
    flushActions();
    _actions = null;
    _tick = false;
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
          _deviceTime = time;
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
