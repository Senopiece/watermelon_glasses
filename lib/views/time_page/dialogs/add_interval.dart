import 'package:flutter/material.dart';
import 'package:watermelon_glasses/datatypes/time.dart';
import 'package:watermelon_glasses/datatypes/time_interval.dart';
import 'package:watermelon_glasses/views/time_range_picker.dart';

class AddIntervalDialog extends StatefulWidget {
  final VoidCallback onCancel;
  final void Function(TimeInterval, Iterable<int>) submit;
  final Iterable<int> Function(TimeInterval) matchesFilter;

  const AddIntervalDialog({
    Key? key,
    required this.onCancel,
    required this.submit,
    required this.matchesFilter,
  }) : super(key: key);

  @override
  State<AddIntervalDialog> createState() => _AddIntervalDialogState();
}

class _AddIntervalDialogState extends State<AddIntervalDialog> {
  var startTime = Time.fromHMS(12, 0, 0);
  var endTime = Time.fromHMS(13, 0, 0);

  var matches = <int>[]; // list of channel indices
  var selected = <int>{}; // set of channel indices (subset of matches)

  /// MUST be applied synchronously after startTime or endTime changes,
  /// requires to be wrapped into setState()
  void _applyMatchesFiler() {
    // update matches list
    matches = widget
        .matchesFilter(
          TimeInterval(startTime, endTime),
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
                endTime: endTime,
                startTime: startTime,
                onStartTimeChanged: (Time newStartTime) {
                  setState(() {
                    startTime = newStartTime;

                    // sync endTime to always have correct interval
                    if (!(endTime > startTime)) {
                      endTime = startTime.advance(60);
                    }

                    _applyMatchesFiler();
                  });
                },
                onEndTimeChanged: (Time newEndTime) {
                  if (newEndTime > startTime) {
                    setState(() {
                      endTime = newEndTime;
                      _applyMatchesFiler();
                    });
                  }
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
                                  TimeInterval(startTime, endTime),
                                  selected,
                                )
                            : null,
                        child: const Text('submit'),
                      ),
                    ),
                    const SizedBox(width: 30),
                    SizedBox(
                      height: 50,
                      width: 100,
                      child: ElevatedButton(
                        onPressed: widget.onCancel,
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
    );
  }
}
