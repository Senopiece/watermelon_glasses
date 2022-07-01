/// time in a period of one day
class Time {
  final int _seconds;

  int get hour => (_seconds ~/ 3600) % 24;
  int get minute => (_seconds ~/ 60) % 60;
  int get second => (_seconds % 60);

  Time(int seconds) : _seconds = seconds % (86400);
  factory Time.fromHMS(int h, int m, int s) => Time(h * 3600 + m * 60 + s);
  factory Time.now() {
    final now = DateTime.now();
    return Time.fromHMS(now.hour, now.minute, now.second);
  }

  Time advance(int seconds) => Time(_seconds + seconds);
  int diff(Time time) => (time._seconds - _seconds).abs();
}
