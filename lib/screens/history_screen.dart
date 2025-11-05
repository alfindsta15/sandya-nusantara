import 'package:flutter/material.dart';
import 'package:sandya_nusantara/utils/app_theme.dart';
import 'package:sandya_nusantara/widgets/history_item.dart';

import '../widgets/history_item.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black54,
      body: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Riwayat Sinau ->',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF3E2723),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.close, color: Colors.red),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, thickness: 1),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: const [
                    HistoryItem(
                      title: 'Bahasa Krama Inggil',
                      date: '5 Maret 2025 | 11:26 AM',
                      score: 100.00,
                      iconColor: Colors.red,
                    ),
                    SizedBox(height: 16),
                    HistoryItem(
                      title: 'Sastra Indonesia',
                      date: '5 Maret 2025 | 11:58 AM',
                      score: 92.00,
                      iconColor: Colors.orange,
                      iconData: Icons.book,
                    ),
                    SizedBox(height: 16),
                    HistoryItem(
                      title: 'Aksara Jawa',
                      date: '7 Maret 2025 | 07:24 AM',
                      score: 77.00,
                      iconColor: Colors.deepOrange,
                      iconData: Icons.text_fields,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
