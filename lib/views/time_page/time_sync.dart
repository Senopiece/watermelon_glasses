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
      width: 200,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.black,
        ),
        borderRadius: const BorderRadius.all(Radius.circular(10)),
      ),
      // TODO: beautifully animate when data becomes rendered
      child: GetBuilder<TimeSyncController>(
        builder: (controller) {
          final row = <Widget>[
            Text(
              style: controller.isUnsynced
                  ? const TextStyle(color: Colors.red)
                  : null,
              controller.time.toString(),
            )
          ];
          if (controller.isUnsynced) {
            row.add(
              ElevatedButton(
                onPressed: controller.sync,
                child: const Text('sync'),
              ),
            );
          }
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: row,
          );
        },
      ),
    );
  }
}
