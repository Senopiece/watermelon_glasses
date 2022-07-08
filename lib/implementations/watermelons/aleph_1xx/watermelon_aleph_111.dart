import 'package:watermelon_glasses/datatypes/time.dart';
import 'package:watermelon_glasses/datatypes/time_interval.dart';
import 'package:watermelon_glasses/datatypes/time_pick.dart';

import 'watermelon_aleph_100.dart';

// -> external exceptions

class UnexpectedResponse extends Error {
  final String data;
  UnexpectedResponse(this.data);
}

// -> implementation

class WatermelonAleph111 extends WatermelonAleph100 {
  WatermelonAleph111(super.connection) : super();

  Future<void> expectResponse(String msg) async {
    final res = await getRaw();
    if (res != msg) throw UnexpectedResponse(res);
  }

  Future<void> expectOk() async {
    expectResponse('ok');
  }

  @override
  int get middleVersion => 1;

  @override
  int get minorVersion => 1;

  @override
  Future<void> closeChannel(int index) => asyncSafe(
        () async {
          assert(isManualMode!);
          await sendRaw("close ${index + 1}");
          await expectResponse('recognized ${index + 1}');
        },
      );

  @override
  Future<void> openChannel(int index) => asyncSafe(
        () async {
          assert(isManualMode!);
          await sendRaw("open ${index + 1}");
          await expectResponse('recognized ${index + 1}');
        },
      );

  @override
  Future<void> setTime(Time time) => asyncSafe(
        () async {
          assert(!isManualMode!);
          await sendRaw(
              "set time to ${time.hour}:${time.minute}:${time.second}");
          await expectOk();
          deviceTimePick = TimePick.makePick(time);
        },
      );

  @override
  Future<void> enterManualMode() => asyncSafe(
        () async {
          await sendRaw("manual mode");
          await expectOk();
          manualModeFlag = true;
        },
      );

  @override
  Future<void> exitManualMode() => asyncSafe(
        () async {
          await sendRaw("exit manual mode");
          await expectOk();
          manualModeFlag = false;
        },
      );

  @override
  Future<List<List<TimeInterval>>> getSchedule() => asyncSafe(
        () async {
          assert(!isManualMode!);
          await sendRaw("get schedule");
          final lines = (await getRaw()).split(';');

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
  Future<void> pull(TimeInterval interval, int channelIndex) => asyncSafe(
        () async {
          assert(interval.endTime.second == 59);
          assert(interval.startTime.second == 0);

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
          await expectOk();
          intervals.remove(interval);
        },
      );

  @override
  Future<void> put(TimeInterval interval, int channelIndex) => asyncSafe(
        () async {
          assert(interval.endTime.second == 59);
          assert(interval.startTime.second == 0);

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
          await expectOk();
          intervals.insert(i, interval);
        },
      );
}
