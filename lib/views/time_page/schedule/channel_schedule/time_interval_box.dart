import 'package:flutter/material.dart';
import 'package:watermelon_glasses/datatypes/time_interval.dart';

class TimeIntervalBox extends StatelessWidget {
  final TimeInterval timeInterval;
  final VoidCallback onLongPress;

  const TimeIntervalBox({
    Key? key,
    required this.timeInterval,
    required this.onLongPress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 10),
      child: ElevatedButton(
        onPressed: () {},
        onLongPress: onLongPress,
        child: Text(
          timeInterval.toString(),
          style: const TextStyle(
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}
