import 'package:get/get.dart';
import 'package:watermelon_glasses/controllers/bluetooth_page_controller.dart';
import 'package:watermelon_glasses/controllers/discovery_page_controller.dart';
import 'package:watermelon_glasses/views/bluetooth_page_root.dart';

final bluePage = GetPage(
  name: '/blue',
  page: () => const BluetoothPageRoot(),
  binding: BindingsBuilder(() {
    Get.put(DiscoveryPageController(), permanent: true);
    Get.put(BluetoothPageController(), permanent: true);
  }),
);
