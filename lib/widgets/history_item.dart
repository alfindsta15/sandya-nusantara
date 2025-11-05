import 'package:flutter/material.dart';

class HistoryItem extends StatelessWidget {
  final String title;
  final String date;
  final double score;
  final Color iconColor;
  final IconData iconData;

  const HistoryItem({
    Key? key,
    required this.title,
    required this.date,
    required this.score,
    this.iconColor = Colors.red,
    this.iconData = Icons.person,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: iconColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            iconData,
            color: Colors.white,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3E2723),
                ),
              ),
              Text(
                date,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: score >= 80 ? Colors.green : (score >= 60 ? Colors.orange : Colors.red),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            '${score.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
