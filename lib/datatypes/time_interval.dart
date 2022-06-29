class TimeInterval {
  final DateTime startTime;
  final DateTime endTime;

  TimeInterval(this.startTime, this.endTime);

  /// a string in a format: "hh:mm - hh:mm"
  factory TimeInterval.parse(String str) {
    final parts = str.split('-');
    final boundaries = <DateTime>[];
    for (String part in parts) {
      part = part.trim();
      final subParts = part.split(':');
      final h = int.parse(subParts[0]);
      final m = int.parse(subParts[1]);
      boundaries.add(DateTime(2000, 1, 1, h, m));
    }
    return TimeInterval(boundaries[0], boundaries[1]);
  }
}
