import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:watermelon_glasses/controllers/connection_page_controller.dart';

class ConnectionPage extends GetView<ConnectionPageController> {
  const ConnectionPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ConnectionPageController>(
      builder: (controller) {
        late final Text label;
        switch (controller.currentState) {
          case ConnectionSate.connecting:
            label = const Text('connecting');
            break;
          case ConnectionSate.connected:
            label = const Text('connected');
            break;
          case ConnectionSate.disconnected:
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
                  color: (controller.currentState == ConnectionSate.connected)
                      ? Colors.green
                      : null,
                ),
              ),
              Text(
                'Address: ${controller.device.address}',
              ),
              label,
              (controller.currentState == ConnectionSate.connecting)
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
