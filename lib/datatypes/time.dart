/// time in a period of one day
class Time {
  final int _seconds;

  int get hour => (_seconds ~/ 3600) % 24;
  int get minute => (_seconds ~/ 60) % 60;
  int get second => (_seconds % 60);

  String get padHour => hour.toString();
  String get padMinute => minute.toString().padLeft(2, '0');
  String get padSecond => second.toString().padLeft(2, '0');

  String get hm => '$padHour:$padMinute';

  Time(int seconds) : _seconds = seconds % 86400;
  factory Time.fromHMS(int h, int m, int s) => Time(h * 3600 + m * 60 + s);
  factory Time.now() {
    final now = DateTime.now();
    return Time.fromHMS(now.hour, now.minute, now.second);
  }

  Time advance(int seconds) => Time(_seconds + seconds);
  int diff(Time time) => time._seconds - _seconds;

  @override
  String toString() => '$padHour:$padMinute:$padSecond';

  bool operator >=(Time other) {
    return _seconds >= other._seconds;
  }

  bool operator >(Time other) {
    return _seconds > other._seconds;
  }

  @override
  bool operator ==(covariant Time other) {
    return _seconds == other._seconds;
  }

  @override
  int get hashCode => _seconds;
}
