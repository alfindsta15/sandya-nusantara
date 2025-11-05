import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class EnhancedChallengeHistoryScreen extends StatefulWidget {
  const EnhancedChallengeHistoryScreen({Key? key}) : super(key: key);

  @override
  State<EnhancedChallengeHistoryScreen> createState() => _EnhancedChallengeHistoryScreenState();
}

class _EnhancedChallengeHistoryScreenState extends State<EnhancedChallengeHistoryScreen>
    with TickerProviderStateMixin {
  List<Map<String, dynamic>> _quizHistory = [];
  List<String> _earnedTitles = [];
  Map<String, int> _moduleQuestionCounts = {
    'aksara_jawa': 3,
    'bahasa_krama': 3,
    'sastra_indonesia': 3,
    'sastra_jawa': 3,
  };

  late TabController _tabController;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    await Future.wait([
      _loadQuizHistory(),
      _loadEarnedTitles(),
    ]);

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _loadQuizHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getString('quiz_history') ?? '[]';
      final history = json.decode(historyJson) as List;

      setState(() {
        _quizHistory = history.map((e) => Map<String, dynamic>.from(e)).toList();
        _quizHistory.sort((a, b) => (b['timestamp'] ?? 0).compareTo(a['timestamp'] ?? 0));
      });
    } catch (e) {
      print('Error loading quiz history: $e');
    }
  }

  Future<void> _loadEarnedTitles() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final titlesJson = prefs.getString('earned_titles') ?? '[]';
      final titles = json.decode(titlesJson) as List;

      setState(() {
        _earnedTitles = titles.map((e) => e.toString()).toList();
      });
    } catch (e) {
      print('Error loading earned titles: $e');
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

  String _formatTime(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return '';
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
        'averagePercentage': 0,
        'bestPercentage': 0,
        'improvement': 0,
      };
    }

    final totalScore = moduleHistory.fold<int>(0, (sum, h) {
      final score = h['score'];
      return sum + (score is int ? score : 0);
    });

    final totalPercentage = moduleHistory.fold<int>(0, (sum, h) {
      final percentage = h['percentage'];
      return sum + (percentage is int ? percentage : 0);
    });

    final averageScore = (totalScore / moduleHistory.length).round();
    final averagePercentage = (totalPercentage / moduleHistory.length).round();
    final bestScore = moduleHistory.fold<int>(0, (max, h) =>
    (h['score'] ?? 0) > max ? (h['score'] ?? 0) : max);
    final bestPercentage = moduleHistory.fold<int>(0, (max, h) =>
    (h['percentage'] ?? 0) > max ? (h['percentage'] ?? 0) : max);

    // Calculate improvement (compare first vs last 3 attempts)
    int improvement = 0;
    if (moduleHistory.length >= 6) {
      final recent = moduleHistory.take(3).map((h) => h['percentage'] ?? 0).toList();
      final old = moduleHistory.skip(moduleHistory.length - 3).map((h) => h['percentage'] ?? 0).toList();
      final recentAvg = recent.fold<int>(0, (sum, p) => sum + (p as int)) / recent.length;
      final oldAvg = old.fold<int>(0, (sum, p) => sum + (p as int)) / old.length;
      improvement = (recentAvg - oldAvg).round();
    }

    return {
      'totalAttempts': moduleHistory.length,
      'averageScore': averageScore,
      'bestScore': bestScore,
      'lastAttempt': moduleHistory.first,
      'totalQuestions': _moduleQuestionCounts[moduleKey] ?? 0,
      'averagePercentage': averagePercentage,
      'bestPercentage': bestPercentage,
      'improvement': improvement,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF5D3A1D),
      appBar: AppBar(
        backgroundColor: const Color(0xFF5D3A1D),
        elevation: 0,
        title: const Text(
          'Riwayat & Pencapaian',
          style: TextStyle(
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
            onPressed: _loadData,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.analytics), text: 'Statistik'),
            Tab(icon: Icon(Icons.history), text: 'Riwayat'),
            Tab(icon: Icon(Icons.emoji_events), text: 'Pencapaian'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(
        child: CircularProgressIndicator(color: Colors.white),
      )
          : _quizHistory.isEmpty
          ? _buildEmptyState()
          : TabBarView(
        controller: _tabController,
        children: [
          _buildStatisticsTab(),
          _buildHistoryTab(),
          _buildAchievementsTab(),
        ],
      ),
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
          const Text(
            'Mulai mengerjakan kuis untuk melihat riwayat tantangan Anda di sini',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white70,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.school),
            label: const Text('Mulai Belajar'),
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

  Widget _buildStatisticsTab() {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Overall Statistics
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
                  'Statistik Keseluruhan',
                  style: TextStyle(
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
                        _quizHistory.length.toString(),
                        Icons.quiz,
                        Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        'Rata-rata Skor',
                        '${_calculateOverallAverage()}%',
                        Icons.trending_up,
                        Colors.green,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'Gelar Diraih',
                        _earnedTitles.length.toString(),
                        Icons.emoji_events,
                        Colors.orange,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        'Hari Aktif',
                        _calculateActiveDays().toString(),
                        Icons.calendar_today,
                        Colors.purple,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Module Statistics
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
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
                  'Statistik per Modul',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3E2723),
                  ),
                ),
                const SizedBox(height: 16),
                ..._moduleQuestionCounts.keys.map((moduleKey) {
                  final stats = _getModuleStats(moduleKey);
                  return _buildEnhancedModuleStatCard(moduleKey, stats);
                }).toList(),
              ],
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildHistoryTab() {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Filter and Sort Options
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.filter_list, color: Color(0xFF5D3A1D)),
                const SizedBox(width: 8),
                const Text(
                  'Riwayat Terbaru',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF5D3A1D),
                  ),
                ),
                const Spacer(),
                Text(
                  '${_quizHistory.length} kuis',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),

          // History List
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
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
              children: [
                ..._quizHistory.map((history) => _buildEnhancedHistoryItem(history)).toList(),
              ],
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildAchievementsTab() {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Earned Titles
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
                Row(
                  children: [
                    const Icon(Icons.emoji_events, color: Colors.orange),
                    const SizedBox(width: 8),
                    const Text(
                      'Gelar yang Diraih',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF3E2723),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (_earnedTitles.isEmpty) ...[
                  Container(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Icon(
                          Icons.emoji_events_outlined,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Belum ada gelar yang diraih',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Selesaikan kuis dengan skor 100% untuk mendapatkan gelar!',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: _earnedTitles.map((title) => _buildTitleBadge(title)).toList(),
                  ),
                ],
              ],
            ),
          ),

          // Achievements Progress
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
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
                Row(
                  children: [
                    const Icon(Icons.trending_up, color: Colors.green),
                    const SizedBox(width: 8),
                    const Text(
                      'Progress Pencapaian',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF3E2723),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ..._buildAchievementProgress(),
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
              fontSize: 24,
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

  Widget _buildEnhancedModuleStatCard(String moduleKey, Map<String, dynamic> stats) {
    final moduleName = _getModuleName(moduleKey);
    final totalQuestions = stats['totalQuestions'] as int;
    final bestScore = stats['bestScore'] as int;
    final bestPercentage = stats['bestPercentage'] as int;
    final improvement = stats['improvement'] as int;
    final totalAttempts = stats['totalAttempts'] as int;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  moduleName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3E2723),
                  ),
                ),
              ),
              Row(
                children: [
                  if (improvement > 0) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.trending_up, color: Colors.white, size: 12),
                          const SizedBox(width: 2),
                          Text(
                            '+$improvement%',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getScoreColor(bestPercentage),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$bestPercentage%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Percobaan: $totalAttempts',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),
              Expanded(
                child: Text(
                  'Skor Terbaik: $bestScore/$totalQuestions',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),
            ],
          ),
          if (totalAttempts > 0) ...[
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: bestPercentage / 100,
              backgroundColor: Colors.grey.shade300,
              valueColor: AlwaysStoppedAnimation<Color>(_getScoreColor(bestPercentage)),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEnhancedHistoryItem(Map<String, dynamic> history) {
    final moduleName = _getModuleName(history['module'] ?? '');
    final score = history['score'] ?? 0;
    final total = history['total'] ?? 0;
    final percentage = history['percentage'] ?? 0;
    final date = _formatDate(history['date'] ?? '');
    final time = _formatTime(history['date'] ?? '');

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
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
                  moduleName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3E2723),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Skor: $score/$total soal ($percentage%)',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      date,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    if (time.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      Text(
                        time,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          Column(
            children: [
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
        ],
      ),
    );
  }

  Widget _buildTitleBadge(String title) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.orange, Colors.deepOrange],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.emoji_events,
            color: Colors.white,
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildAchievementProgress() {
    final achievements = [
      {
        'title': 'Pemula',
        'description': 'Selesaikan 1 kuis',
        'current': _quizHistory.length,
        'target': 1,
        'icon': Icons.play_arrow,
      },
      {
        'title': 'Pembelajar',
        'description': 'Selesaikan 5 kuis',
        'current': _quizHistory.length,
        'target': 5,
        'icon': Icons.school,
      },
      {
        'title': 'Ahli',
        'description': 'Selesaikan 10 kuis',
        'current': _quizHistory.length,
        'target': 10,
        'icon': Icons.star,
      },
      {
        'title': 'Master',
        'description': 'Dapatkan 3 gelar',
        'current': _earnedTitles.length,
        'target': 3,
        'icon': Icons.emoji_events,
      },
    ];

    return achievements.map((achievement) {
      final current = achievement['current'] as int;
      final target = achievement['target'] as int;
      final progress = (current / target).clamp(0.0, 1.0);
      final isCompleted = current >= target;

      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isCompleted ? Colors.green.shade50 : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isCompleted ? Colors.green.shade200 : Colors.grey.shade200,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isCompleted ? Colors.green : Colors.grey.shade400,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                achievement['icon'] as IconData,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    achievement['title'] as String,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isCompleted ? Colors.green.shade800 : const Color(0xFF3E2723),
                    ),
                  ),
                  Text(
                    achievement['description'] as String,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.grey.shade300,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isCompleted ? Colors.green : Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$current/$target',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            if (isCompleted) ...[
              const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 24,
              ),
            ],
          ],
        ),
      );
    }).toList();
  }

  int _calculateOverallAverage() {
    if (_quizHistory.isEmpty) return 0;

    final totalPercentage = _quizHistory.fold<num>(0, (sum, h) {
      final p = h['percentage'];
      return sum + (p is num ? p : 0);
    });
    return (totalPercentage / _quizHistory.length).round();
  }

  int _calculateActiveDays() {
    if (_quizHistory.isEmpty) return 0;

    final uniqueDates = <String>{};
    for (final history in _quizHistory) {
      final dateString = history['date'] ?? '';
      if (dateString.isNotEmpty) {
        try {
          final date = DateTime.parse(dateString);
          uniqueDates.add('${date.year}-${date.month}-${date.day}');
        } catch (e) {
          // Ignore invalid dates
        }
      }
    }
    return uniqueDates.length;
  }
}
