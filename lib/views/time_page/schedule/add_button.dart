import 'package:flutter/material.dart';

class AddButton extends StatelessWidget {
  final VoidCallback onTap;

  const AddButton({
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      width: 200,
      height: 70,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
            primary: const Color.fromARGB(255, 155, 219, 157)),
        onPressed: onTap,
        child: const Text(
          '+',
          style: TextStyle(fontSize: 30, color: Colors.black),
        ),
      ),
    );
  }
}
