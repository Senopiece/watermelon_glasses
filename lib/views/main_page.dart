import 'package:flutter/material.dart';
import 'package:watermelon_glasses/views/bluetooth_page_root.dart';
import 'package:watermelon_glasses/views/manual_page_root.dart';
import 'package:watermelon_glasses/views/timer_page_root.dart';
import 'package:watermelon_glasses/views/settings_page_root.dart';
import 'package:intl/intl.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return MyHomePageState();
  }
}

class MyHomePageState extends State<MyHomePage> {
  int selectedIndex = 0;
  final Widget _timer = const TimerPageRoot();
  final Widget _manual = const ManualPageRoot();
  final Widget _bluetooth = BluetoothPageRoot();
  final Widget _settings = SettingsPageRoot();

  @override
  Widget build(BuildContext context) {
    int selectedIndex = 0;
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('kk:mm').format(now);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text(formattedDate, style: const TextStyle(fontSize: 30)),
      ),
      body: getBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.access_time),
            label: 'Timer',
            backgroundColor: Colors.green,
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.back_hand),
              label: 'Manual',
              backgroundColor: Colors.green),
          BottomNavigationBarItem(
              icon: Icon(Icons.bluetooth),
              label: 'Bluetooth',
              backgroundColor: Colors.green),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Settings',
              backgroundColor: Colors.green),
        ],
        onTap: onTapHandler,
      ),
    );
  }

  Widget getBody() {
    switch (selectedIndex) {
      case 0:
        return _timer;
      case 1:
        return _manual;
      case 2:
        return _bluetooth;
      default:
        return _settings;
    }
  }

  void onTapHandler(int index) {
    setState(() {
      selectedIndex = index;
    });
  }
}
