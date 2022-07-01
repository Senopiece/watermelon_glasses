import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:watermelon_glasses/controllers/connection_page_controller.dart';
import 'package:watermelon_glasses/helpers/bluetooth_connection_manager.dart';

class ConnectionPage extends GetView<ConnectionPageController> {
  const ConnectionPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ConnectionPageController>(
      builder: (controller) {
        late final Text label;
        switch (controller.currentState.runtimeType) {
          case Connecting:
            label = const Text('connecting');
            break;
          case Connected:
            label = const Text('connected');
            break;
          case Disconnected:
            label = const Text('disconnected');
            break;
          default:
            throw TypeError();
        }
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Device Name: ${controller.device.name}',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: (controller.currentState is Connected)
                      ? Colors.green
                      : null,
                ),
              ),
              Text(
                'Address: ${controller.device.address}',
              ),
              label,
              (controller.currentState is Connecting)
                  ? const Expanded(
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    )
                  : ElevatedButton(
                      onPressed: controller.gotoDiscoverySubPage,
                      child: const Text('close'),
                    )
              // TODO: reconnect button in Disconnetced state
            ],
          ),
        );
      },
    );
  }
}
