import 'package:flutter/material.dart';
import 'package:watermelon_glasses/datatypes/time_interval.dart';
import 'package:watermelon_glasses/views/time_page/schedule/channel_schedule/time_interval_box.dart';

class ChannelSchedule extends StatelessWidget {
  final List<TimeInterval> schedule;
  final void Function(TimeInterval data) onElementShortPress;
  final void Function(TimeInterval data) onElementLongPress;

  const ChannelSchedule({
    Key? key,
    required this.schedule,
    required this.onElementLongPress,
    required this.onElementShortPress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Wrap(
          spacing: 10,
          children: schedule
              .map(
                (e) => TimeIntervalBox(
                  timeInterval: e,
                  onPress: () => onElementShortPress(e),
                  onLongPress: () => onElementLongPress(e),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}
