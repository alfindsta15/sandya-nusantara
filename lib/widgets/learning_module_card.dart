import 'package:flutter/material.dart';
import 'package:sandya_nusantara/utils/app_theme.dart';

class LearningModuleCard extends StatelessWidget {
  final String title;
  final String description;
  final double progress;
  final bool isAvailable;
  final VoidCallback onTap;

  const LearningModuleCard({
    Key? key,
    required this.title,
    required this.description,
    required this.progress,
    required this.isAvailable,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var ElevatedButton;
    return GestureDetector(
      onTap: isAvailable ? onTap : null,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF5E6CE),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isAvailable ? const Color(0xFF3E2723) : Colors.grey,
              ),
            ),
            if (isAvailable && description.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 10,
                  color: Color(0xFF3E2723),
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const Spacer(),
            if (isAvailable) ...[
              LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.grey.shade300,
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.red),
                borderRadius: BorderRadius.circular(4),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: onTap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(80, 30),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  child: const Text(
                    'TEKAN',
                    style: TextStyle(fontSize: 10),
                  ),
                ),
              ),
            ] else ...[
              const SizedBox(height: 8),
              Center(
                child: Container(
                  width: 80,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
