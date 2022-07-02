import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:watermelon_glasses/controllers/add_interval_controller.dart';
import 'package:watermelon_glasses/views/time_range_picker.dart';

class AddIntervalDialog extends GetView<AddIntervalDialogController> {
  const AddIntervalDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Center(
        child: Card(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(20),
            ),
          ),
          child: SizedBox(
            height: 450,
            width: 350,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                // title
                const Padding(
                  padding: EdgeInsets.fromLTRB(0, 20, 0, 15),
                  child: Text(
                    'select interval',
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                ),
                // time picker
                const Divider(),
                TimeRangePicker(
                  onChanged: controller.intervalUpdate,
                  initial: controller.initialTimeInterval,
                ),
                const Divider(),
                // selectable matches
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Wrap(
                      spacing: 10,
                      children: controller.matches
                          .map(
                            (channelIndex) => Container(
                              decoration:
                                  controller.selected.contains(channelIndex)
                                      ? BoxDecoration(
                                          border: Border.all(
                                              color: const Color.fromARGB(
                                                  255, 174, 73, 33)),
                                        )
                                      : BoxDecoration(
                                          border: Border.all(
                                            color: const Color.fromARGB(
                                                20, 77, 102, 88),
                                          ),
                                        ),
                              height: 50,
                              width: 50,
                              child: ElevatedButton(
                                onPressed: () =>
                                    controller.switchSelect(channelIndex),
                                child: Text('${channelIndex + 1}'),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ),
                // submit/cancel button
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 50,
                        width: 100,
                        child: ElevatedButton(
                          onPressed: controller.selected.isNotEmpty
                              ? controller.submit
                              : null,
                          child: const Text('submit'),
                        ),
                      ),
                      const SizedBox(width: 30),
                      SizedBox(
                        height: 50,
                        width: 100,
                        child: ElevatedButton(
                          onPressed: controller.cancel,
                          child: const Text('cancel'),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
