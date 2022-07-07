import 'package:get/get.dart';
import 'package:watermelon_glasses/translations/ru_RU.dart';
import 'en_us.dart';

class AppLocalization extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {'en_US': enUs, "ru_RU": ruRU};
}
