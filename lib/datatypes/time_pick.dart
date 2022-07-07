import 'time.dart';

class TimePick {
  final Time picked;
  final DateTime when;

  Duration get elapsedSincePick => DateTime.now().difference(when);

  TimePick(this.picked, this.when);

  factory TimePick.makePick(Time picked) => TimePick(picked, DateTime.now());
}
