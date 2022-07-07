import 'package:watermelon_glasses/abstracts/watermelon.dart';
import 'package:watermelon_glasses/datatypes/time.dart';
import 'package:watermelon_glasses/datatypes/time_interval.dart';

/// wrapper over RRC to support watermelon commands,
/// see https://github.com/Senopiece/watermelon/blob/217028deeeb6f91774c44bc090ddcc1d0e1a113e/README.md
class WatermelonAleph1xx extends Watermelon {
  WatermelonAleph1xx(super.connection);

  bool get canGetImmediateChannels => throw UnimplementedError();
  bool get canGetImmediateDeviceTime => throw UnimplementedError();

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
  Future<List<List<TimeInterval>>> get channels => throw UnimplementedError();
  int get channelScheduleCapacity => throw UnimplementedError();

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
  Future<int> get channelsCount async => throw UnimplementedError();

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
  Future<Time> get deviceTime => throw UnimplementedError();

  /// use it only if you sure that the time was already cached
  List<List<TimeInterval>> get immediateChannels => throw UnimplementedError();

  /// use it only if you sure that the time was already cached
  Time get immediateDeviceTime => throw UnimplementedError();

  bool? get isManualMode => throw UnimplementedError();

  @override
  int get majorVersion => 1;

  @override
  int get middleVersion => throw UnimplementedError();

  @override
  int get minorVersion => throw UnimplementedError();

  @override
  String get name => 'aleph';

  Future<void> closeChannel(int index) => throw UnimplementedError();

  Future<void> enterManualMode() => throw UnimplementedError();

  Future<void> exitManualMode() => throw UnimplementedError();

  void flushActions() => throw UnimplementedError();

  /// return example:
  /// [
  ///   [11:00 - 12:00, 14:00 - 15:00]
  ///   [15:00 - 16:00, 16:00 - 17:00]
  ///   []
  ///   []
  ///   [22:00 - 22:30]
  /// ]
  Future<List<List<TimeInterval>>> getSchedule() => throw UnimplementedError();

  Future<Time> getTime() => throw UnimplementedError();

  Future<void> openChannel(int index) => throw UnimplementedError();

  Future<void> pull(TimeInterval interval, int channelIndex) =>
      throw UnimplementedError();

  Future<void> put(TimeInterval interval, int channelIndex) =>
      throw UnimplementedError();

  /// check for no interval intersections,
  /// returns what channels can accept this interval
  /// Note: requires [immediateChannels]
  /// Note: there is not check of channel schedule capacity overflow
  Iterable<int> putDoesNotIntersect(TimeInterval interval) sync* {
    throw UnimplementedError();
  }

  Future<void> setTime(Time time) => throw UnimplementedError();
}
