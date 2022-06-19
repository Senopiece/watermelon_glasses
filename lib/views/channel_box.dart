import 'package:flutter/material.dart';

class ChannelBox extends StatefulWidget {
  final String name;

  const ChannelBox({super.key, required this.name});

  @override
  State<ChannelBox> createState() => _ChannelBoxState();
}

class _ChannelBoxState extends State<ChannelBox> {
  bool value = false;

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
            widget.name,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Switch(
              value: value,
              onChanged: (state) {
                setState(() {
                  value = state;
                });
              }),
        ],
      ),
    );
  }
}
