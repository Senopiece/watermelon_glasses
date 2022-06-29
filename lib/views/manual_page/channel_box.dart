import 'package:flutter/material.dart';

class ChannelBox extends StatelessWidget {
  final String name;
  final bool enabled;
  final VoidCallback onSwitch;

  const ChannelBox({
    super.key,
    required this.name,
    required this.enabled,
    required this.onSwitch,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.black,
        ),
        borderRadius: const BorderRadius.all(Radius.circular(10)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            name,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Switch(
            value: enabled,
            onChanged: (_) => onSwitch(),
          ),
        ],
      ),
    );
  }
}
