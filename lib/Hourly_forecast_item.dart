import 'package:flutter/material.dart';

class HourlyForecustItem extends StatelessWidget {
  final String time;
  final String tempreture;
  final IconData icon;
  const HourlyForecustItem({
    super.key,
    required this.time,
    required this.tempreture,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      child: Container(
        width: 100,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
        padding: EdgeInsets.all(10.0),
        child: Column(
          children: [
            Text(
              time,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              maxLines: 1,
              overflow:TextOverflow.visible,
            ),

            const SizedBox(height: 10),
            Icon(icon, size: 26),
            const SizedBox(height: 10),
            Text(tempreture, style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
