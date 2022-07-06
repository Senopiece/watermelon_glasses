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
        late final String label;
        switch (controller.currentState.runtimeType) {
          case Connecting:
            label = 'connecting...';
            break;
          case Connected:
            label = 'connected';
            break;
          case Disconnected:
            final state = controller.currentState as Disconnected;
            switch (state.reason.runtimeType) {
              case FailedToConnect:
                label = 'failed to connect';
                break;
              case StationaryDisconnection:
                label = 'disconnected';
                break;
              case NotInitialized:
                label = 'starting connection...';
                break;
              default:
                throw TypeError();
            }
            break;
          default:
            throw TypeError();
        }

        final content = <Widget>[
          Text(
            'Device Name: ${controller.device.name}',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color:
                  (controller.currentState is Connected) ? Colors.green : null,
            ),
          ),
          Text(
            'Address: ${controller.device.address}',
          ),
          Text(label),
          ElevatedButton(
            onPressed: controller.gotoDiscoverySubPage,
            child: (controller.currentState is Connecting)
                ? const Text('cancel')
                : const Text('close'),
          )
        ];

        if (controller.currentState is Disconnected) {
          content.add(
            ElevatedButton(
              onPressed: controller.reconnect,
              child: const Text('reconnect'),
            ),
          );
        }

        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: content,
          ),
        );
      },
    );
  }
}
