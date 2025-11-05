import 'package:flutter/material.dart';
import 'package:sandya_nusantara/screens/challenge_history_screen.dart';
import 'package:sandya_nusantara/screens/duolingo_quiz_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ChallengeResultScreen extends StatelessWidget {
  final String moduleType;
  final int score;
  final int totalQuestions;
  final int percentage;
  final String? earnedTitle;

  const ChallengeResultScreen({
    Key? key,
    required this.moduleType,
    required this.score,
    required this.totalQuestions,
    required this.percentage,
    this.earnedTitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF5D3A1D), Color(0xFF3E2723)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header with logo
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                color: const Color(0xFF5D3A1D),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.menu, color: Colors.white),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Menu pressed')),
                        );
                      },
                    ),
                    const Spacer(),
                    Column(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.school,
                            color: Color(0xFF5D3A1D),
                            size: 24,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'SANDYA\nNUSANTARA',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            height: 1.0,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Main content
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 40),

                      // Hexagonal check icon
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.check,
                          size: 50,
                          color: Color(0xFF5D3A1D),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Title
                      Text(
                        earnedTitle ?? _getModuleTitle(moduleType),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 12),

                      // Subtitle
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Text(
                          _getCongratulationMessage(moduleType),
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Score card
                      GestureDetector(
                        onTap: () => _navigateToChallengeHistory(context),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 24),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5E6D3),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'Raport ${_getModuleName(moduleType)}',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF5D3A1D),
                                    ),
                                  ),
                                  const Spacer(),
                                  const Icon(
                                    Icons.arrow_forward,
                                    color: Color(0xFF5D3A1D),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  _buildScoreItem('$percentage', 'Nilai'),
                                  _buildScoreItem('$score/$totalQuestions', 'Benar'),
                                  _buildScoreItem('${totalQuestions - score}/$totalQuestions', 'Salah'),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Motivational text
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Ayo ',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const Text(
                            'Sinau! ',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const Text(
                            '->',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),

                      Align(
                        alignment: Alignment.centerRight,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 24.0),
                          child: Text(
                            'Tingali Sedoyo',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.7),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Learning buttons
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: _buildLearningButton(
                                    context,
                                    'Sinau Bahasa Krama',
                                        () => _navigateToLearning(context, 'bahasa_krama'),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: _buildLearningButton(
                                    context,
                                    'Sinau Aksara Jawa',
                                        () => _navigateToLearning(context, 'aksara_jawa'),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildLearningButton(
                                    context,
                                    'Sinau Sastra Jawa',
                                        () => _navigateToLearning(context, 'sastra_jawa'),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: _buildLearningButton(
                                    context,
                                    'Sinau Sastra Indonesia',
                                        () => _navigateToLearning(context, 'sastra_indonesia'),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Main menu button
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => _navigateToMainMenu(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF8B4513),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: const Text(
                              'Menu Utama',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),

              // Footer with logo and contact
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                color: const Color(0xFF3E2723),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.school,
                        color: Color(0xFF5D3A1D),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'KANTOR:',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.white70,
                            ),
                          ),
                          Text(
                            'Jl. Ketintang Wiyata Gedung A10, Surabaya, Jawa Timur, Indonesia',
                            style: TextStyle(
                              fontSize: 9,
                              color: Colors.white60,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.chat_bubble, color: Colors.white70),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Chat support pressed')),
                        );
                      },
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

  Widget _buildScoreItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF5D3A1D),
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: const Color(0xFF5D3A1D).withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildLearningButton(BuildContext context, String title, VoidCallback onTap) {
    return Material(
      color: const Color(0xFFF5E6D3),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          alignment: Alignment.center,
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF5D3A1D),
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  void _navigateToLearning(BuildContext context, String moduleType) {
    // Navigate to specific module quiz
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EnhancedDuolingoQuizScreen(moduleType: moduleType),
      ),
    );
  }

  void _navigateToMainMenu(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/home',
          (route) => false,
    );
  }

  String _getModuleTitle(String moduleType) {
    switch (moduleType) {
      case 'aksara_jawa':
        return 'PENDEKAR AKSARA';
      case 'bahasa_krama':
        return 'PENDEKAR KRAMA';
      case 'sastra_indonesia':
        return 'PENDEKAR SASTRA';
      case 'sastra_jawa':
        return 'PENDEKAR TEMBANG';
      default:
        return 'PENDEKAR JAWA';
    }
  }

  String _getModuleName(String moduleType) {
    switch (moduleType) {
      case 'aksara_jawa':
        return 'Aksara Jawa';
      case 'bahasa_krama':
        return 'Bahasa Krama Inggil';
      case 'sastra_indonesia':
        return 'Sastra Indonesia';
      case 'sastra_jawa':
        return 'Sastra Jawa';
      default:
        return 'Pembelajaran';
    }
  }

  String _getCongratulationMessage(String moduleType) {
    switch (moduleType) {
      case 'bahasa_krama':
        return 'Sugeng atas kasil panjenengan angsal gelar \'Pendekar Krama\'. Mugi tansah dados suri tauladan ing tata krama lan basa Jawa';
      case 'aksara_jawa':
        return 'Sugeng atas kasil panjenengan angsal gelar \'Pendekar Aksara\'. Mugi tansah nguri-uri aksara Jawa';
      case 'sastra_indonesia':
        return 'Selamat atas keberhasilan Anda mendapat gelar \'Pendekar Sastra\'. Semoga terus melestarikan sastra Indonesia';
      case 'sastra_jawa':
        return 'Sugeng atas kasil panjenengan angsal gelar \'Pendekar Tembang\'. Mugi tansah nguri-uri sastra lan tembang Jawa';
      default:
        return 'Selamat atas pencapaian Anda!';
    }
  }

  void _navigateToChallengeHistory(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EnhancedChallengeHistoryScreen(),
      ),
    );
  }
}
