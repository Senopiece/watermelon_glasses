import 'package:flutter/material.dart';
import 'package:flutter_placeholder_textlines/flutter_placeholder_textlines.dart';
import 'package:get/get.dart';

import '../../controllers/discovery_page_controller.dart';

class DevicesList extends StatelessWidget {
  final DiscoveryPageController controller;
  const DevicesList({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    int numberOfPlaceHolder =
        MediaQuery.of(context).size.height ~/ (10 * 3 + 20 + 35);
    return controller.results.isEmpty
        ? ListView.builder(
            itemCount: numberOfPlaceHolder,
            itemBuilder: (context, _) => Container(
              margin: const EdgeInsets.only(top: 20),
              alignment: Alignment.center,
              child: const PlaceholderLines(
                count: 3,
                animate: true,
                minWidth: 0.90,
                maxWidth: 0.90,
                align: TextAlign.center,
                lineHeight: 10,
                rebuildOnStateChange: true,
                color: Color.fromARGB(255, 175, 175, 175),
              ),
            ),
          )
        : ListView.separated(
            itemCount: controller.results.length,
            itemBuilder: (context, index) {
              final device = controller.results[index].device;
              return Container(
                margin: const EdgeInsets.symmetric(vertical: 7, horizontal: 7),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: const Color.fromARGB(255, 155, 219, 157),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: TextButton(
                  style: TextButton.styleFrom(alignment: Alignment.centerLeft),
                  onPressed: () => controller.gotoConnectionSubPage(device),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: TextSpan(
                          text: '${"Devise Name".tr}: ',
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                            fontStyle: FontStyle.italic,
                          ),
                          children: [
                            TextSpan(
                                text: device.name,
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ))
                          ],
                        ),
                      ),
                      Text(
                        '${"Address".tr}: ${device.address}',
                      ),
                    ],
                  ),
                ),
              );
            },
            separatorBuilder: (context, int index) => const Divider(
              height: 10,
            ),
          );
  }
}
