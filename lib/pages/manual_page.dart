import 'package:get/get.dart';
import 'package:watermelon_glasses/controllers/manual_page_controller.dart';
import 'package:watermelon_glasses/views/manual_page_root.dart';

final manualPage = GetPage(
  name: '/manual',
  page: () => const ManualPageRoot(),
  binding: BindingsBuilder(() {
    Get.put(ManualPageController());
  }),
);
