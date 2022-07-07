import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:watermelon_glasses/datatypes/time.dart';
import 'package:watermelon_glasses/datatypes/time_interval.dart';
import 'package:watermelon_glasses/views/time_range_picker.dart';

class AddIntervalDialog extends StatefulWidget {
  final VoidCallback onCancel;
  final void Function(TimeInterval, Iterable<int>) submit;
  final Iterable<int> Function(TimeInterval) matchesFilter;
  final TimeInterval Function(TimeInterval, TimeInterval) timeSync;
  final TimeInterval initialData;

  const AddIntervalDialog({
    Key? key,
    required this.onCancel,
    required this.submit,
    required this.matchesFilter,
    required this.timeSync,
    required this.initialData,
  }) : super(key: key);

  @override
  State<AddIntervalDialog> createState() => _AddIntervalDialogState();
}

class _AddIntervalDialogState extends State<AddIntervalDialog> {
  late var data = widget.initialData;

  var matches = <int>[]; // list of channel indices
  var selected = <int>{}; // set of channel indices (subset of matches)

  /// MUST be applied synchronously after startTime or endTime changes,
  /// requires to be wrapped into setState()
  void _applyMatchesFiler() {
    // update matches list
    matches = widget
        .matchesFilter(
          TimeInterval(data.startTime, data.endTime),
        )
        .toList();

    // deselect anything that is not matched
    selected.removeWhere(
      (element) => !matches.contains(element),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
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
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 20, 0, 15),
                child: Text(
                  'select interval'.tr,
                  style: const TextStyle(
                    fontSize: 20,
                  ),
                ),
              ),
              // time picker
              const Divider(),
              TimeRangePicker(
                endTime: data.endTime,
                startTime: data.startTime,
                onStartTimeChanged: (Time newStartTime) {
                  setState(() {
                    data = widget.timeSync(
                      data,
                      data.copyWith(startTime: newStartTime),
                    );
                    _applyMatchesFiler();
                  });
                },
                onEndTimeChanged: (Time newEndTime) {
                  setState(() {
                    data = widget.timeSync(
                      data,
                      data.copyWith(endTime: newEndTime),
                    );
                    _applyMatchesFiler();
                  });
                },
              ),
              const Divider(),
              // selectable matches
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Wrap(
                    spacing: 10,
                    children: matches
                        .map(
                          (channelIndex) => Container(
                            decoration: selected.contains(channelIndex)
                                ? BoxDecoration(
                                    border: Border.all(
                                        color: const Color.fromARGB(
                                            255, 174, 73, 33)),
                                  )
                                : BoxDecoration(
                                    border: Border.all(
                                      color:
                                          const Color.fromARGB(20, 77, 102, 88),
                                    ),
                                  ),
                            height: 50,
                            width: 50,
                            child: ElevatedButton(
                              onPressed: () {
                                assert(matches.contains(channelIndex));

                                // switch selection of channelIndex
                                setState(() {
                                  if (selected.contains(channelIndex)) {
                                    selected.remove(channelIndex);
                                  } else {
                                    selected.add(channelIndex);
                                  }
                                });
                              },
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
                        onPressed: selected.isNotEmpty
                            ? () => widget.submit(
                                  TimeInterval(data.startTime, data.endTime),
                                  selected,
                                )
                            : null,
                        child: Text('submit'.tr),
                      ),
                    ),
                    const SizedBox(width: 30),
                    SizedBox(
                      height: 50,
                      width: 100,
                      child: ElevatedButton(
                        onPressed: widget.onCancel,
                        child: Text('cancel'.tr),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
