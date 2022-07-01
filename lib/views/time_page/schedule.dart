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
        int index = 0;
        return ListView(
          children: controller.channels
              .map(
                (e) => Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8, 8, 0, 8),
                      child: Container(
                        width: 50,
                        height: 50,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.black,
                          ),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(10)),
                        ),
                        child: Text(
                          '${++index}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: ChannelSchedule(
                        schedule: e,
                        addButtonPressed: () {},
                      ),
                    ),
                  ],
                ),
              )
              .toList(),
        );
      },
    );
  }
}
