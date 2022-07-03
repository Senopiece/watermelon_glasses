import 'package:flutter/material.dart';
import 'package:watermelon_glasses/datatypes/time.dart';

import 'time_picker.dart';

class TimeRangePicker extends StatelessWidget {
  final Time startTime;
  final Time endTime;
  final void Function(Time)? onStartTimeChanged;
  final void Function(Time)? onEndTimeChanged;

  const TimeRangePicker({
    Key? key,
    required this.startTime,
    required this.endTime,
    this.onStartTimeChanged,
    this.onEndTimeChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      width: 300,
      child: Row(
        children: [
          TimePicker(
            time: startTime,
            onChanged: onStartTimeChanged,
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
            onChanged: onEndTimeChanged,
          ),
        ],
      ),
    );
  }
}
