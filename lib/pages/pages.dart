import 'package:get/get.dart';
import 'package:watermelon_glasses/views/bluetooth_page_root.dart';
import 'package:watermelon_glasses/views/main_page.dart';

final mainPage = GetPage(
  name: '/main',
  page: () => MyHomePage(),
  binding: BindingsBuilder(() {
    Get.put(BluetoothPageRoot());
  }),
);
