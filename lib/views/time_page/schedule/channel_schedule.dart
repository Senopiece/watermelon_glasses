import 'package:flutter/material.dart';
import 'package:watermelon_glasses/datatypes/time_interval.dart';
import 'package:watermelon_glasses/views/time_page/schedule/channel_schedule/time_interval_box.dart';

import 'channel_schedule/add_button.dart';

class ChannelSchedule extends StatelessWidget {
  final List<TimeInterval> schedule;
  final VoidCallback addButtonPressed;
  final void Function(TimeInterval data) onElementLongPress;

  const ChannelSchedule({
    Key? key,
    required this.schedule,
    required this.addButtonPressed,
    required this.onElementLongPress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final list = <Widget>[];
    list.addAll(
      schedule
          .map(
            (e) => TimeIntervalBox(
              timeInterval: e,
              onLongPress: () => onElementLongPress(e),
            ),
          )
          .toList(),
    );
    list.add(
      AddButton(onTap: addButtonPressed),
    );

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: list,
      ),
    );
  }
}
