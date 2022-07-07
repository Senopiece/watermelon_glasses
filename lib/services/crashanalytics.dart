import 'package:get/get.dart';

class Crashanalytics extends GetxService {
  final Future<void> Function(Object, StackTrace, {bool fatal}) delegate;

  Crashanalytics(this.delegate);

  Future<void> recordError(Object error, StackTrace stackTrace) =>
      delegate(error, stackTrace, fatal: true);
}
