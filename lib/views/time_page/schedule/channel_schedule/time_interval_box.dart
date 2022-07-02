import 'package:flutter/material.dart';
import 'package:watermelon_glasses/datatypes/time_interval.dart';

class TimeIntervalBox extends StatelessWidget {
  final TimeInterval timeInterval;
  final VoidCallback onLongPress;
  final VoidCallback onPress;

  const TimeIntervalBox({
    Key? key,
    required this.timeInterval,
    required this.onLongPress,
    required this.onPress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPress,
      onLongPress: onLongPress,
      child: Text(
        timeInterval.toString(),
        style: const TextStyle(
          fontSize: 15,
        ),
      ),
    );
  }
}
