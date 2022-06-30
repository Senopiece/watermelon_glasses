import 'package:get/get.dart';
import 'package:watermelon_glasses/controllers/time_page_controller.dart';
import 'package:watermelon_glasses/controllers/time_sync_controller.dart';
import 'package:watermelon_glasses/views/time_page_root.dart';

final timePage = GetPage(
  name: '/time',
  page: () => const TimePageRoot(),
  binding: BindingsBuilder(() {
    Get.put(TimePageController());
    Get.lazyPut(() => TimeSyncController());
  }),
);
