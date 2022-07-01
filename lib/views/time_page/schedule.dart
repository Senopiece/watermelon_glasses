import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:watermelon_glasses/controllers/schedule_controller.dart';

import 'schedule/channel_schedule.dart';

/// NOTE: this widget requires TimePageController to have `watermelon != null`
/// and the watermelon must have cached channels
class Schedule extends GetView<ScheduleController> {
  const Schedule({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ScheduleController>(
      builder: (controller) {
        if (controller.channels.isEmpty) {
          return const Center(
            child: Text('no channels'),
          );
        }
        return ListView.separated(
          separatorBuilder: (context, index) => const Divider(),
          itemCount: controller.channels.length,
          itemBuilder: (context, channelIndex) {
            return Row(
              children: [
                // leading number
                Container(
                  width: 50,
                  height: 50,
                  margin: const EdgeInsets.only(left: 10),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.black,
                    ),
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                  ),
                  child: Text(
                    '${channelIndex + 1}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                // horizontally scrollable channel schedule
                Expanded(
                  child: ChannelSchedule(
                    schedule: controller.channels[channelIndex],
                    addButtonPressed: () =>
                        controller.addTimeInterval(channelIndex),
                    onElementLongPress: (elementData) => controller
                        .removeTimeInterval(channelIndex, elementData),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
