import 'dart:async';

import 'package:watermelon_glasses/abstracts/watermelons/watermelon_aleph_1xx.dart';
import 'package:watermelon_glasses/datatypes/time.dart';
import 'package:watermelon_glasses/datatypes/time_interval.dart';
import 'package:watermelon_glasses/datatypes/time_pick.dart';

// -> internal exceptions

class Advance {}

// -> external exceptions

class ChannelScheduleOverflow extends Error {}

class IncorrectTimeInterval extends Error {}

class IntervalIntersection extends Error {}

class InvalidChannelIndex extends Error {}

// -> implementation

class WatermelonAleph100 extends WatermelonAleph1xx {
  @override
  int get middleVersion => 0;

  @override
  int get minorVersion => 0;

  bool? _manualModeFlag = false;
  TimePick? _deviceTimePick;

  Future<Time>? _deviceTimeFuture;
  List<List<TimeInterval>>? _channels;

  Future<List<List<TimeInterval>>>? _channelsFuture;

  WatermelonAleph100(super.connection) : super();

  @override
  Future<void> initialize() async {
    // ensure no manual mode for the next invocations
    await exitManualMode();

    // invoke this things firstly,
    // so they will be cached for the further fast access
    await channelsCount;
    await deviceTime;
  }

  @override
  bool get canGetImmediateChannels => _channels != null;

  @override
  bool get canGetImmediateDeviceTime => _deviceTimePick != null;

  @override
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

  @override
  int get channelScheduleCapacity => 16;

  @override
  Future<int> get channelsCount async => (await channels).length;

  @override
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

  @override
  List<List<TimeInterval>> get immediateChannels => _channels!;

  @override
  Time get immediateDeviceTime => _deviceTimePick!.picked
      .advance(_deviceTimePick!.elapsedSincePick.inSeconds);

  @override
  bool? get isManualMode => _manualModeFlag;

  @override
  Future<void> closeChannel(int index) => asyncSafe(
        () async {
          assert(isManualMode!);
          await sendRaw("close ${index + 1}");
        },
      );

  @override
  Future<void> enterManualMode() => asyncSafe(
        () async {
          await sendRaw("manual mode");
          _manualModeFlag = true;
        },
      );

  @override
  Future<void> exitManualMode() => asyncSafe(
        () async {
          await sendRaw("exit manual mode");
          _manualModeFlag = false;
        },
      );

  @override
  Future<List<List<TimeInterval>>> getSchedule() => asyncSafe(
        () async {
          assert(!isManualMode!);
          await sendRaw("get shedule");
          final lines = (await getRawMultilines()).split('\n');
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

  @override
  Future<Time> getTime() => asyncSafe(
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

  @override
  Future<void> openChannel(int index) => asyncSafe(
        () async {
          assert(isManualMode!);
          await sendRaw("open ${index + 1}");
        },
      );

  @override
  Future<void> pull(TimeInterval interval, int channelIndex) => asyncSafe(
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

  @override
  Future<void> put(TimeInterval interval, int channelIndex) => asyncSafe(
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

          int? i = findPutIndex(interval, intervals);
          if (i == null) {
            throw IntervalIntersection();
          }

          await sendRaw('put $interval to ${channelIndex + 1}');
          intervals.insert(i, interval);
        },
      );

  @override
  Iterable<int> putDoesNotIntersect(TimeInterval interval) sync* {
    if (!interval.isCorrect) return;
    int channelIndex = 0;
    for (final channelSchedule in immediateChannels) {
      if (findPutIndex(interval, channelSchedule) != null) {
        yield channelIndex;
      }
      channelIndex++;
    }
  }

  @override
  Future<void> setTime(Time time) => asyncSafe(
        () async {
          assert(!isManualMode!);
          await sendRaw(
              "set time to ${time.hour}:${time.minute}:${time.second}");
          _deviceTimePick = TimePick.makePick(time);
        },
      );

  int? findPutIndex(TimeInterval interval, List<TimeInterval> intervals) {
    int i = 0;
    for (i = 0; i != intervals.length; i++) {
      if (intervals[i] > interval) break;
    }

    if ((i > 0) && !(interval > intervals[i - 1])) {
      return null;
    }

    return i;
  }
}
