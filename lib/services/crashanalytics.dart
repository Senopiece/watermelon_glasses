import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:get/get.dart';

class Crashanalytics extends GetxService {
  Future<void> recordError(Object error, StackTrace stackTrace) =>
      FirebaseCrashlytics.instance.recordError(error, stackTrace, fatal: true);
}
