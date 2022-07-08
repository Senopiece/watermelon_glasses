import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:watermelon_glasses/abstracts/connection_manager.dart';
import 'package:watermelon_glasses/controllers/connection_page_controller.dart';

class ConnectionPage extends GetView<ConnectionPageController> {
  const ConnectionPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ConnectionPageController>(
      builder: (controller) {
        late final String label;
        final state = controller.connector!.currentState;

        if (state is Connecting) {
          label = 'connecting...'.tr;
        } else if (state is Connected) {
          label = 'connected'.tr;
        } else if (state is Disconnected) {
          final reasoning = controller.connector!.currentState as Disconnected;
          switch (reasoning.reason.runtimeType) {
            case FailedToConnect:
              label = 'failed to connect'.tr;
              break;
            case StationaryDisconnection:
              label = 'disconnected'.tr;
              break;
            case NotInitialized:
              label = 'starting connection...'.tr;
              break;
            case CancelledConnection:
              label = 'connection cancelled'.tr;
              break;
            default:
              throw TypeError();
          }
        } else {
          throw TypeError();
        }

        final content = <Widget>[
          Text(
            '${"Devise Name".tr}: ${controller.device.name}',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: (controller.connector!.currentState is Connected)
                  ? Colors.green
                  : null,
            ),
          ),
          Text(
            '${"Address".tr}: ${controller.device.address}',
          ),
          Text(label),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                primary: const Color.fromARGB(255, 155, 219, 157)),
            onPressed: controller.gotoDiscoverySubPage,
            child: (controller.connector!.currentState is Connecting)
                ? Text('cancel'.tr, style: const TextStyle(color: Colors.green))
                : Text('close'.tr, style: const TextStyle(color: Colors.black)),
          )
        ];

        if (controller.connector!.currentState is Disconnected) {
          content.add(
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  primary: const Color.fromARGB(255, 155, 219, 157)),
              onPressed: controller.reconnect,
              child: Text(
                'reconnect'.tr,
                style: const TextStyle(color: Colors.black),
              ),
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
