import 'package:get/get.dart';

import 'watermelon.dart';

class ServicesBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(Watermelon());
  }
}
