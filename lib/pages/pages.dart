import 'package:get/get.dart';
import 'package:watermelon_glasses/views/bluetooth_page_root.dart';
import 'package:watermelon_glasses/views/manual_page_root.dart';
import 'package:watermelon_glasses/views/settings_page_root.dart';
import 'package:watermelon_glasses/views/timer_page_root.dart';


final timerPage = GetPage(
  name: '/timer',
  page: () => const TimerPageRoot(),
  binding: BindingsBuilder(() {}),
);

final manualPage = GetPage(
  name: '/manual',
  page: () => const ManualPageRoot(),
  binding: BindingsBuilder(() {}),
);

final bluetoothPage = GetPage(
  name: '/bluetooth',
  page: () => const BluetoothPageRoot(),
  binding: BindingsBuilder(() {}),
);

final settingsPage = GetPage(
  name: '/settings',
  page: () => const SettingsPageRoot(),
  binding: BindingsBuilder(() {}),
);