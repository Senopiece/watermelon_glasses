import 'package:flutter/material.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:watermelon_glasses/datatypes/time.dart';
import 'package:watermelon_glasses/datatypes/time_interval.dart';

class TimePicker extends StatefulWidget {
  final Time initialTime; // affects only initState
  final void Function(Time)? onChanged;

  const TimePicker({
    Key? key,
    this.onChanged,
    required this.initialTime,
  }) : super(key: key);

  @override
  State<TimePicker> createState() => _TimePickerState();
}

class _TimePickerState extends State<TimePicker> {
  late Time current;

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
          value: current.hour,
          infiniteLoop: true,
          onChanged: (value) {
            setState(() {
              current = Time.fromHMS(value, current.minute, 0);
              if (widget.onChanged != null) widget.onChanged!(current);
            });
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
          value: current.minute,
          infiniteLoop: true,
          onChanged: (value) {
            setState(() {
              current = Time.fromHMS(current.hour, value, 0);
              if (widget.onChanged != null) widget.onChanged!(current);
            });
          },
        ),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    assert(widget.initialTime.second == 0);
    current = widget.initialTime;
  }
}
