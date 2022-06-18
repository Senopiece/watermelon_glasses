import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:watermelon_glasses/views/bluetooth_page_root.dart';
import 'package:watermelon_glasses/views/manual_page_root.dart';
import 'package:watermelon_glasses/views/timer_page_root.dart';
import 'package:watermelon_glasses/views/settings_page_root.dart';

class MyHomePage extends StatefulWidget {

  @override
  State<StatefulWidget> createState() {
    return MyHomePageState();
  }

}

class MyHomePageState extends State<MyHomePage> {
  int selectedIndex = 0;
  Widget _timer = TimerPageRoot();
  Widget _manual = ManualPageRoot();
  Widget _bluetooth = BluetoothPageRoot();
  Widget _settings = SettingsPageRoot();

  @override
  Widget build(BuildContext context) {
    int selectedIndex = 0;
    DateTime now = DateTime.now();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text("$now"),
      ),
      body:  getBody(),
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
              backgroundColor: Colors.green
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.bluetooth),
              label: 'Bluetooth',
              backgroundColor: Colors.green
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Settings',
              backgroundColor: Colors.green
          ),
        ],
        onTap: onTapHandler,
      ),
    );
  }

  Widget getBody( )  {
    switch(selectedIndex) {
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

  void onTapHandler(int index)  {
    setState(() {
      selectedIndex = index;
    });
  }
}


