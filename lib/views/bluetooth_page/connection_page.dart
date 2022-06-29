import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:watermelon_glasses/controllers/connection_page_controller.dart';
import 'package:watermelon_glasses/datatypes/bluetooth_connection_manager.dart';

class ConnectionPage extends GetView<ConnectionPageController> {
  const ConnectionPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      initialData: Disconnected(),
      stream: controller.connector.statesStream,
      builder: (context, AsyncSnapshot<BluetoothConnectionManagerState> snap) {
        if (snap.hasData) {
          BluetoothConnectionManagerState state = snap.data!;
          late final Text label;
          switch (state.runtimeType) {
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
                  'Device Name: ${controller.device.address}',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: (state is Connected) ? Colors.green : null,
                  ),
                ),
                Text(
                  'Address: ${controller.device.address}',
                ),
                label,
                (state is Connecting)
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
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}
