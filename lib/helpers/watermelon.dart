import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:typed_data';

import '../datatypes/Time.dart';
import '../abstracts/rrc.dart';
import '../datatypes/time_interval.dart';

// TODO: versioning of protocols support

class Cancelled extends Error {}

class Advance {}

typedef FutureProducer<T> = Future<T> Function();

class Task<T> {
  final FutureProducer<T> f;
  final Completer<T> c;
  Task(this.f, this.c);
}

class TimePick {
  final Time picked;
  final DateTime when;

  Duration get elapsedSincePick => DateTime.now().difference(when);

  TimePick(this.picked, this.when);

  factory TimePick.makePick(Time picked) => TimePick(picked, DateTime.now());
}

class BufferNotEmptyError extends Error {
  final String drained;
  BufferNotEmptyError(this.drained);
}

class InvalidChannelIndex extends Error {}

class IncorrectTimeInterval extends Error {}

class ChannelScheduleOverflow extends Error {}

class IntervalIntersection extends Error {}

/// wrapper over BluetoothConnection to support watermelon commands,
/// see https://github.com/Senopiece/watermelon/blob/main/README.md
class Watermelon {
  final RRC connection;

  bool? _isManualMode = false;
  bool? get isManualMode => _isManualMode;

  TimePick? _deviceTimePick;
  Future<Time>? _deviceTimeFuture;

  List<List<TimeInterval>>? _channels;
  Future<List<List<TimeInterval>>>? _channelsFuture;

  int get channelScheduleCapacity => 16;

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
            if (!connection.isBufferEmpty) {
              throw BufferNotEmptyError(await getRaw());
            }
            final res = await nextTask.f();
            nextTask.c.complete(res);
          } catch (e) {
            nextTask.c.completeError(e);
          }
        }
      },
    );
  }

  /// use it only if you sure that the time was already cached
  Time get immediateDeviceTime => _deviceTimePick!.picked
      .advance(_deviceTimePick!.elapsedSincePick.inSeconds);
  bool get canGetImmediateDeviceTime => _deviceTimePick != null;

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
  Future<Time> get deviceTime {
    assert(_deviceTimeFuture == null || _deviceTimePick == null);

    // if in auto sync state
    if (_deviceTimePick != null) return Future(() => immediateDeviceTime);

    // create new future to fill _deviceTime
    _deviceTimeFuture ??= Future(
      () async {
        try {
          // get the actual time (slow)
          if (_deviceTimePick != null) throw Advance();
          final res = await getTime(); // may throw error
          if (_deviceTimePick != null) throw Advance();

          // goto auto sync state
          _deviceTimePick = TimePick.makePick(res);

          // return to the first awaiters
          _deviceTimeFuture = null;
          return res;
        } on Advance {
          // so _deviceTime was set somewhere externally while we process
          _deviceTimeFuture = null;
          return immediateDeviceTime;
        } catch (e) {
          // ensure not to cache fails
          _deviceTimeFuture = null;
          rethrow;
        }
      },
    );

    // if in calling for actual time state,
    // returns the same future as the first invocation
    return _deviceTimeFuture!;
  }

  /// slow on the first access, immediate after
  ///
  /// Note that if it throws on the first access,
  /// the second will retry the bluetooth call, if the second throws,
  /// the third will act without cache and so on until any successful operation
  ///
  /// Important: ensure mode is not manual,
  /// before calling this thing the first time,
  /// otherwise the returned future will newer complete
  ///
  /// Note that usage of this function is more preferable then [channels]
  Future<int> get channelsCount async => (await channels).length;

  /// use it only if you sure that the time was already cached
  List<List<TimeInterval>> get immediateChannels => _channels!;
  bool get canGetImmediateChannels => _channels != null;

  /// slow on the first access, immediate after
  ///
  /// Note that if it throws on the first access,
  /// the second will retry the bluetooth call, if the second throws,
  /// the third will act without cache and so on until any successful operation
  ///
  /// Important: ensure mode is not manual,
  /// before calling this thing the first time,
  /// otherwise the returned future will newer complete
  ///
  /// Note that usage of this function is more preferable then [getSchedule]
  Future<List<List<TimeInterval>>> get channels {
    assert(_channelsFuture == null || _channels == null);

    // if in auto sync state
    if (_channels != null) return Future(() => _channels!);

    // create new future to fill _channels
    _channelsFuture ??= Future(
      () async {
        try {
          // get the actual schedule (slow)
          assert(_channels == null);
          final res = await getSchedule(); // may throw error
          assert(_channels == null);

          // goto auto sync state
          _channels = res;

          // return to the first awaiters
          _channelsFuture = null;
          return res;
        } catch (e) {
          // ensure not to cache fails
          assert(_channels == null);
          _channelsFuture = null;
          rethrow;
        }
      },
    );

    // if in calling for actual schedule state,
    // returns the same future as the first invocation
    return _channelsFuture!;
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

  Future<void> setTime(Time time) => _asyncSafe(
        () async {
          assert(!isManualMode!);
          await sendRaw(
              "set time to ${time.hour}:${time.minute}:${time.second}");
          _deviceTimePick = TimePick.makePick(time);
        },
      );

  Future<Time> getTime() => _asyncSafe(
        () async {
          assert(!isManualMode!);
          await sendRaw("get time");
          final parts = (await getRaw()).split(':');
          final h = int.parse(parts[0]);
          final m = int.parse(parts[1]);
          final s = int.parse(parts[2]);
          return Time.fromHMS(h, m, s);
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

  int? _findPutIndex(TimeInterval interval, List<TimeInterval> intervals) {
    int i = 0;
    for (i = 0; i != intervals.length; i++) {
      if (intervals[i] > interval) break;
    }

    if ((i > 0) && !(interval > intervals[i - 1])) {
      return null;
    }

    return i;
  }

  Future<void> put(TimeInterval interval, int channelIndex) => _asyncSafe(
        () async {
          assert(!isManualMode!);
          final schedule = await channels;

          late final List<TimeInterval> intervals;
          try {
            intervals = schedule[channelIndex];
          } catch (e) {
            throw InvalidChannelIndex();
          }

          if (!interval.isCorrect) {
            throw IncorrectTimeInterval();
          }

          if (intervals.length == channelScheduleCapacity) {
            throw ChannelScheduleOverflow();
          }

          int? i = _findPutIndex(interval, intervals);
          if (i == null) {
            throw IntervalIntersection();
          }

          // TODO: too many channels working at the same time check (next versions of watermelon)

          await sendRaw('put $interval to ${channelIndex + 1}');
          intervals.insert(i, interval);
        },
      );

  /// check for no interval intersections,
  /// returns what channels can accept this interval
  /// Note: requires [immediateChannels]
  /// Note: there is not check of channel schedule capacity overflow
  Iterable<int> putDoesNotIntersect(TimeInterval interval) sync* {
    if (!interval.isCorrect) return;
    int channelIndex = 0;
    for (final channelSchedule in immediateChannels) {
      if (_findPutIndex(interval, channelSchedule) != null) {
        yield channelIndex;
      }
      channelIndex++;
    }
  }

  Future<void> pull(TimeInterval interval, int channelIndex) => _asyncSafe(
        () async {
          assert(!isManualMode!);
          final schedule = await channels;

          late final List<TimeInterval> intervals;
          try {
            intervals = schedule[channelIndex];
          } catch (e) {
            throw InvalidChannelIndex();
          }

          if (!interval.isCorrect) {
            throw IncorrectTimeInterval();
          }

          if (!intervals.contains(interval)) {
            return; // ignore if there is nothing to delete
          }

          await sendRaw('pull $interval from ${channelIndex + 1}');
          intervals.remove(interval);
        },
      );
}
