import 'package:get/get.dart';
import 'package:watermelon_glasses/views/device_lookup_root.dart';

final deviceLookupPage = GetPage(
  name: '/device_lookup',
  page: () => const DeviceLookupRoot(),
  binding: BindingsBuilder(() {}),
);
