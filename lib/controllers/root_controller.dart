import 'package:get/get.dart';

class RootController extends GetxController {
  final _currentIndex = 0.obs;

  int get currentIndex => _currentIndex.value;
  set currentIndex(int newValue) => _currentIndex.value = newValue;

  void switchPage(int index) {
    // ignore if we are already on the page
    if (index == currentIndex) return;

    // update body
    final getPages = Get.routeTree.routes;
    getPages[index] = getPages[index].copy(
      transition: currentIndex < index
          ? Transition.rightToLeft
          : Transition.leftToRight,
    );
    Get.offNamed(getPages[index].name);

    // update bottom bar
    currentIndex = index;
  }
}
