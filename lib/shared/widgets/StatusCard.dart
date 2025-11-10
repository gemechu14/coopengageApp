// lib/screens/dashboard/widgets/status_card.dart
import 'package:flutter/material.dart';

class StatusCard extends StatelessWidget {
  final String title;
  final int count;
  final Color color;
  final IconData icon;

  const StatusCard({
    required this.title,
    required this.count,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(6.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 33),
            Text(title,
                style:
                    const TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
            Text(count.toString(),
                style:
                    const TextStyle(fontSize: 29, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
