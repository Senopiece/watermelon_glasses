import 'package:get/get.dart';
import 'package:watermelon_glasses/datatypes/time_interval.dart';
import 'package:watermelon_glasses/helpers/watermelon.dart';

import 'time_page_controller.dart';

class ReturnData {
  final TimeInterval interval;
  final Set<int> channelsToPut;
  ReturnData(this.interval, this.channelsToPut);
}

class AddIntervalDialogController extends GetxController {
  Watermelon get watermelon => Get.find<TimePageController>().watermelon!;
  List<List<TimeInterval>> get channels => watermelon.immediateChannels;
  int get channelCapacity => watermelon.channelScheduleCapacity;

  final initialTimeInterval = TimeInterval.parse('12:00 - 13:00');
  final matches = <int>[].obs; // list of channel indices
  final selected = <int>{}.obs; // set of channel indices

  late TimeInterval selectedInterval;

  void intervalUpdate(TimeInterval interval) {
    matches.clear();
    for (final channelIndex in watermelon.putDoesNotIntersect(interval)) {
      if (channels[channelIndex].length != channelCapacity) {
        matches.add(channelIndex);
      } else if (selected.contains(channelIndex)) {
        // make sure there is nothing off-selected
        selected.remove(channelIndex);
      }
    }
    selectedInterval = interval;
  }

  void submit() async {
    assert(selected.isNotEmpty);
    Get.back(result: ReturnData(selectedInterval, selected));
  }

  void cancel() {
    Get.back();
  }

  void switchSelect(int channelIndex) {
    if (selected.contains(channelIndex)) {
      selected.remove(channelIndex);
    } else {
      selected.add(channelIndex);
    }
  }

  @override
  void onInit() {
    super.onInit();
    selected.clear();
    intervalUpdate(initialTimeInterval);
  }
}
