import 'package:flutter/material.dart';

class BonusIcon extends StatelessWidget {
  final IconData icon;
  final String label;

  const BonusIcon({super.key, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Column(
        children: [
          Icon(icon, size: 22, color: Colors.amber.shade700),
          Text(label, style: const TextStyle(fontSize: 10)),
        ],
      ),
    );
  }
}
