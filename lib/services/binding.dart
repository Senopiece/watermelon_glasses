import 'package:get/get.dart';

import 'device.dart';

class ServicesBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(Device());
  }
}
