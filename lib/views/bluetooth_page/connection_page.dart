import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:watermelon_glasses/controllers/connection_page_controller.dart';
import 'package:watermelon_glasses/datatypes/bluetooth_connection_manager.dart';

class ConnectionPage extends GetView<ConnectionPageController> {
  const ConnectionPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO: add observable variables to the ConnectionPageController
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Device Name: ${controller.device.address}',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: (controller.connector.state is Connected)
                  ? Colors.green
                  : null,
            ),
          ),
          Text(
            'Address: ${controller.device.address}',
          ),
          ElevatedButton(
            onPressed: controller.gotoDiscoverySubPage,
            child: const Text('disconnect'),
          ),
        ],
      ),
    );
  }
}
