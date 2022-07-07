import 'package:flutter/material.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:watermelon_glasses/datatypes/time.dart';

class TimePicker extends StatelessWidget {
  /// affects each rebuild, given as approve of value passed by onChanged
  final Time time;
  final void Function(Time)? onChanged;

  const TimePicker({
    Key? key,
    this.onChanged,
    required this.time,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        NumberPicker(
          itemWidth: 50,
          minValue: 0,
          maxValue: 23,
          zeroPad: true,
          value: time.hour,
          infiniteLoop: true,
          onChanged: (value) {
            final current = Time.fromHMS(value, time.minute, time.second);
            if (onChanged != null) onChanged!(current);
          },
        ),
        const Text(
          ":",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
        NumberPicker(
          itemWidth: 50,
          minValue: 0,
          maxValue: 59,
          zeroPad: true,
          value: time.minute,
          infiniteLoop: true,
          onChanged: (value) {
            final current = Time.fromHMS(time.hour, value, time.second);
            if (onChanged != null) onChanged!(current);
          },
        ),
      ],
    );
  }
}
