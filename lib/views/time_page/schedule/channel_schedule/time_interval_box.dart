import 'package:flutter/material.dart';
import 'package:watermelon_glasses/datatypes/time_interval.dart';

class TimeIntervalBox extends StatelessWidget {
  final TimeInterval timeInterval;

  // TODO: long tap invokes dialog that asks if you want to delete this interval

  const TimeIntervalBox({
    Key? key,
    required this.timeInterval,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Container(
        width: 145,
        height: 50,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.black,
          ),
          borderRadius: const BorderRadius.all(Radius.circular(10)),
        ),
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
