import 'package:flutter/material.dart';
import 'package:sandya_nusantara/utils/app_theme.dart';
import 'package:sandya_nusantara/widgets/learning_module_card.dart';
import 'package:sandya_nusantara/widgets/history_item.dart';

import '../utils/app_theme.dart';
import '../widgets/history_item.dart';
import '../widgets/learning_module_card.dart';

class LearningSelectionScreen extends StatelessWidget {
  const LearningSelectionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            Scaffold.of(context).openDrawer();
          },
        ),
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Icon(
              Icons.school,
              size: 40,
              color: Colors.white,
            ),
            SizedBox(width: 8),
            Text(
              'SANDYA\nNUSANTARA',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sugeng Rawuh Alfin!',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Monggo pilih menu ing ngandhap punika',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 24),
                  Text(
                    'Pilih Pelajaranmu',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.2,
                children: [
                  LearningModuleCard(
                    title: 'Sinau Bahasa Krama',
                    description: 'Mantenangi penguasaan Ngoko, Krama Madya, lan Krama Inggil',
                    progress: 0.7,
                    isAvailable: true,
                    onTap: () {
                      Navigator.pushNamed(context, '/learning_activity', arguments: 'bahasa_krama');
                    },
                  ),
                  LearningModuleCard(
                    title: 'Sinau Aksara Jawa',
                    description: 'Belajar menulis kata, kalimat, dan paragraf menggunakan aksara Jawa serta aksaranya',
                    progress: 0.4,
                    isAvailable: true,
                    onTap: () {
                      Navigator.pushNamed(context, '/learning_activity', arguments: 'aksara_jawa');
                    },
                  ),
                  LearningModuleCard(
                    title: 'Sinau Sastra Indonesia',
                    description: 'Belajar tentang karya sastra Indonesia serta bentuk-bentuk karya sastra',
                    progress: 0.2,
                    isAvailable: true,
                    onTap: () {
                      Navigator.pushNamed(context, '/learning_activity', arguments: 'sastra_indonesia');
                    },
                  ),
                  LearningModuleCard(
                    title: 'Sinau Sastra Jawa',
                    description: 'Belajar tentang karya sastra Jawa seperti tembang, parikan, geguritan, lan serat',
                    progress: 0.5,
                    isAvailable: true,
                    onTap: () {
                      Navigator.pushNamed(context, '/learning_activity', arguments: 'sastra_jawa');
                    },
                  ),
                  LearningModuleCard(
                    title: 'BELUM TERSEDIA',
                    description: '',
                    progress: 0.0,
                    isAvailable: false,
                    onTap: () {},
                  ),
                  LearningModuleCard(
                    title: 'BELUM TERSEDIA',
                    description: '',
                    progress: 0.0,
                    isAvailable: false,
                    onTap: () {},
                  ),
                  LearningModuleCard(
                    title: 'BELUM TERSEDIA',
                    description: '',
                    progress: 0.0,
                    isAvailable: false,
                    onTap: () {},
                  ),
                  LearningModuleCard(
                    title: 'BELUM TERSEDIA',
                    description: '',
                    progress: 0.0,
                    isAvailable: false,
                    onTap: () {},
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.grey.shade200,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Riwayat Sinau ->',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF3E2723),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          _showHistoryDialog(context);
                        },
                        child: const Text(
                          'Tingali Sedoyo',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF3E2712),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const HistoryItem(
                    title: 'Bahasa Krama Inggil',
                    date: '5 Maret 2025 | 11:26 AM',
                    score: 100.00,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: AppTheme.primaryColor,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Schedule',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  void _showHistoryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Riwayat Sinau ->',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF3E2723),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const HistoryItem(
                title: 'Bahasa Krama Inggil',
                date: '5 Maret 2025 | 11:26 AM',
                score: 100.00,
              ),
              const SizedBox(height: 12),
              const HistoryItem(
                title: 'Sastra Indonesia',
                date: '5 Maret 2025 | 11:58 AM',
                score: 92.00,
              ),
              const SizedBox(height: 12),
              const HistoryItem(
                title: 'Aksara Jawa',
                date: '7 Maret 2025 | 07:24 AM',
                score: 77.00,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
