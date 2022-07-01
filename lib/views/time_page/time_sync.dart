import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:watermelon_glasses/controllers/time_sync_controller.dart';

/// NOTE: this widget requires TimePageController to have `watermelon != null`
/// and the watermelon must have cached deviceTime
class TimeSync extends GetView<TimeSyncController> {
  const TimeSync({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 10),
      width: 200,
      height: 50,
      // TODO: beautifully animate when data becomes rendered
      child: GetBuilder<TimeSyncController>(
        builder: (controller) {
          final row = <Widget>[
            Text(
              style: controller.isUnsynced
                  ? const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    )
                  : const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
              controller.time.toString(),
            )
          ];
          if (controller.isUnsynced) {
            row.add(
              const SizedBox(width: 8),
            );
            row.add(
              ElevatedButton(
                onPressed: controller.sync,
                child: const Text('sync'),
              ),
            );
          }
          return Row(
            children: row,
          );
        },
      ),
    );
  }
}
