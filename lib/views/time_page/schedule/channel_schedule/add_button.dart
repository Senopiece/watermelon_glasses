import 'package:flutter/material.dart';

class AddButton extends StatelessWidget {
  final VoidCallback onTap;

  const AddButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      width: 50,
      height: 50,
      child: ElevatedButton(
        onPressed: onTap,
        child: const Text('+'),
      ),
    );
  }
}
