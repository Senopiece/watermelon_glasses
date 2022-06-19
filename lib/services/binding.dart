import 'package:get/get.dart';
import 'package:watermelon_glasses/controllers/bluetooth_page_controller.dart';

class ServicesBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(BluetoothPageController());
  }
}
