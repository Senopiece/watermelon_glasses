import 'package:flutter/material.dart';
import 'package:watermelon_glasses/datatypes/time.dart';
import 'package:watermelon_glasses/datatypes/time_interval.dart';

import 'time_picker.dart';

class TimeRangePicker extends StatefulWidget {
  final TimeInterval initial; // affects only initState
  final void Function(TimeInterval)? onChanged;

  const TimeRangePicker({
    Key? key,
    this.onChanged,
    required this.initial,
  }) : super(key: key);

  @override
  State<TimeRangePicker> createState() => _TimeRangePickerState();
}

class _TimeRangePickerState extends State<TimeRangePicker> {
  late Time startTime;
  late Time endTime;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      width: 300,
      child: Row(
        children: [
          TimePicker(
            time: startTime,
            onChanged: (newStartTime) {
              startTime = newStartTime;

              // sync endTime to always have correct interval
              if (!(endTime > startTime)) {
                endTime = startTime.advance(60);
              }

              if (widget.onChanged != null) {
                widget.onChanged!(TimeInterval(startTime, endTime));
              }
            },
          ),
          const Padding(
            padding: EdgeInsets.all(20),
            child: Text(
              "-",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          TimePicker(
            time: endTime,
            onChanged: (newEndTime) {
              if (newEndTime > startTime) {
                endTime = newEndTime;
              }

              if (widget.onChanged != null) {
                widget.onChanged!(TimeInterval(startTime, endTime));
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    startTime = widget.initial.startTime;
    endTime = widget.initial.endTime;
  }
}
