import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ChallengeActivityScreen extends StatefulWidget {
  final String moduleType;

  const ChallengeActivityScreen({Key? key, required this.moduleType}) : super(key: key);

  @override
  State<ChallengeActivityScreen> createState() => _ChallengeActivityScreenState();
}

class _ChallengeActivityScreenState extends State<ChallengeActivityScreen> {
  List<Map<String, dynamic>> _quizHistory = [];
  Map<String, int> _moduleQuestionCounts = {
    'aksara_jawa': 3,
    'bahasa_krama': 3,
    'sastra_indonesia': 3,
    'sastra_jawa': 3,
  };

  @override
  void initState() {
    super.initState();
    _loadQuizHistory();
  }

  Future<void> _loadQuizHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getString('quiz_history') ?? '[]';
      final history = json.decode(historyJson) as List;

      setState(() {
        _quizHistory = history.map((e) => Map<String, dynamic>.from(e)).toList();
        // Sort by timestamp, newest first
        _quizHistory.sort((a, b) => ((b['timestamp'] ?? 0) as int).compareTo((a['timestamp'] ?? 0) as int));
      });
    } catch (e) {
      print('Error loading quiz history: $e');
    }
  }

  String _getModuleName(String moduleKey) {
    switch (moduleKey) {
      case 'aksara_jawa':
        return 'Aksara Jawa';
      case 'bahasa_krama':
        return 'Bahasa Krama';
      case 'sastra_indonesia':
        return 'Sastra Indonesia';
      case 'sastra_jawa':
        return 'Sastra Jawa';
      default:
        return moduleKey;
    }
  }

  Color _getScoreColor(int percentage) {
    if (percentage >= 80) return Colors.green;
    if (percentage >= 60) return Colors.orange;
    return Colors.red;
  }

  IconData _getScoreIcon(int percentage) {
    if (percentage >= 80) return Icons.emoji_events;
    if (percentage >= 60) return Icons.thumb_up;
    return Icons.school;
  }

  String _getScoreMessage(int percentage) {
    if (percentage >= 80) return 'Luar Biasa!';
    if (percentage >= 60) return 'Bagus!';
    return 'Perlu Latihan';
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final months = [
        '', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
        'Jul', 'Ags', 'Sep', 'Okt', 'Nov', 'Des'
      ];
      return '${date.day} ${months[date.month]} ${date.year}';
    } catch (e) {
      return 'Tanggal tidak valid';
    }
  }

  Map<String, dynamic> _getModuleStats(String moduleKey) {
    final moduleHistory = _quizHistory.where((h) => h['module'] == moduleKey).toList();

    if (moduleHistory.isEmpty) {
      return {
        'totalAttempts': 0,
        'averageScore': 0,
        'bestScore': 0,
        'lastAttempt': null,
        'totalQuestions': _moduleQuestionCounts[moduleKey] ?? 0,
      };
    }

    int totalScore = 0;
    int bestScore = 0;

    for (final history in moduleHistory) {
      final score = (history['score'] ?? 0) as int;
      totalScore += score;
      if (score > bestScore) {
        bestScore = score;
      }
    }

    final averageScore = (totalScore / moduleHistory.length).round();

    return {
      'totalAttempts': moduleHistory.length,
      'averageScore': averageScore,
      'bestScore': bestScore,
      'lastAttempt': moduleHistory.first,
      'totalQuestions': _moduleQuestionCounts[moduleKey] ?? 0,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF5D3A1D),
      appBar: AppBar(
        backgroundColor: const Color(0xFF5D3A1D),
        elevation: 0,
        title: Text(
          'Riwayat ${_getModuleName(widget.moduleType)}',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadQuizHistory,
          ),
        ],
      ),
      body: _quizHistory.isEmpty ? _buildEmptyState() : _buildHistoryContent(),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(60),
            ),
            child: const Icon(
              Icons.quiz_outlined,
              size: 60,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Belum Ada Riwayat Tantangan',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Mulai mengerjakan kuis ${_getModuleName(widget.moduleType)} untuk melihat riwayat tantangan Anda di sini',
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white70,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/challenge', arguments: widget.moduleType);
            },
            icon: const Icon(Icons.school),
            label: const Text('Mulai Kuis'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF5D3A1D),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryContent() {
    // Filter history for current module
    final moduleHistory = _quizHistory.where((h) => h['module'] == widget.moduleType).toList();
    final moduleStats = _getModuleStats(widget.moduleType);

    return SingleChildScrollView(
      child: Column(
        children: [
          // Module Statistics
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
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
                  'Statistik ${_getModuleName(widget.moduleType)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3E2723),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'Total Kuis',
                        moduleHistory.length.toString(),
                        Icons.quiz,
                        Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        'Skor Terbaik',
                        '${moduleStats['bestScore']}/${moduleStats['totalQuestions']}',
                        Icons.emoji_events,
                        Colors.orange,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Recent History
          if (moduleHistory.isNotEmpty) ...[
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
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
                  const Text(
                    'Riwayat Terbaru',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF3E2723),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...moduleHistory.take(10).map((history) => _buildHistoryItem(history)).toList(),
                ],
              ),
            ),
          ],

          // Action Buttons
          Container(
            margin: const EdgeInsets.all(16),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(context, '/challenge', arguments: widget.moduleType);
                    },
                    icon: const Icon(Icons.play_arrow),
                    label: Text('Mulai Kuis ${_getModuleName(widget.moduleType)}'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8B4513),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(context, '/challenge_history');
                    },
                    icon: const Icon(Icons.history),
                    label: const Text('Lihat Semua Riwayat'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF5D3A1D),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: Color(0xFF5D3A1D)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(Map<String, dynamic> history) {
    final score = (history['score'] ?? 0) as int;
    final total = (history['total'] ?? 0) as int;
    final percentage = (history['percentage'] ?? 0) as int;
    final date = _formatDate(history['date'] ?? '');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _getScoreColor(percentage),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(
              _getScoreIcon(percentage),
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Skor: $score/$total soal ($percentage%)',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3E2723),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  date,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _getScoreColor(percentage),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              _getScoreMessage(percentage),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
