import 'Time.dart';

class TimeInterval {
  final Time startTime;
  final Time endTime;

  TimeInterval(this.startTime, this.endTime);

  /// a string in a format: "hh:mm - hh:mm"
  factory TimeInterval.parse(String str) {
    final parts = str.split('-');
    final boundaries = <Time>[];
    for (String part in parts) {
      part = part.trim();
      final subParts = part.split(':');
      final h = int.parse(subParts[0]);
      final m = int.parse(subParts[1]);
      boundaries.add(Time.fromHMS(h, m, 0));
    }
    return TimeInterval(boundaries[0], boundaries[1]);
  }
}
