import 'package:flutter/material.dart';

import './channel_box.dart';

class ManualPageRoot extends StatelessWidget {
  const ManualPageRoot({Key? key}) : super(key: key);
  final _buttonName = const [
    'button1',
    'button2',
    'button3',
    'button4',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.separated(
        itemBuilder: (context, index) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            margin: const EdgeInsets.only(top: 10),
            child: ChannelBox(name: _buttonName[index]),
          );
        },
        separatorBuilder: (context, index) => const Divider(),
        itemCount: _buttonName.length,
      ),
    );
  }
}
