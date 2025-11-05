import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'dart:async';
import 'dart:convert';
import '../widgets/challenge_card.dart';
import '../widgets/schedule_calendar.dart';
import '../widgets/drawer_menu.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedIndex = 0;
  final TextEditingController _searchController = TextEditingController();

  // User data from preferences
  String _userName = "Pengguna";
  String _userEmail = "";
  String _userPhone = "";
  String _userAddress = "";
  String _userSchool = "";
  String _userClass = "";
  String _userProfileImage = "";
  String _userRanking = "SD"; // SD, SMP levels
  List<String> _earnedTitles = [];
  String? _activeTitle;

  final Map<String, double> _moduleProgress = {
    'bahasa_krama': 0.0,
    'aksara_jawa': 0.0,
    'sastra_indonesia': 0.0,
    'sastra_jawa': 0.0,
  };

  // Enhanced schedule data with notifications
  List<Map<String, dynamic>> _schedules = [];
  Map<DateTime, List<Map<String, dynamic>>> _scheduledEvents = {};
  FlutterLocalNotificationsPlugin? _notificationsPlugin;

  // Challenge data for horizontal scrolling
  List<Map<String, dynamic>> _challenges = [];
  List<Map<String, dynamic>> _learningHistory = [];

  // Search functionality
  List<Map<String, dynamic>> _searchResults = [];

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    _loadUserData();
    _loadModuleProgress();
    _loadChallenges();
    _loadEnhancedLearningHistory();
    _loadSchedules();
    _loadEarnedTitles();
  }

  Future<void> _initializeNotifications() async {
    _notificationsPlugin = FlutterLocalNotificationsPlugin();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notificationsPlugin?.initialize(initSettings);
  }

  Future<void> _loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _userName = prefs.getString('user_name') ?? 'Pengguna';
        _userEmail = prefs.getString('user_email') ?? '';
        _userPhone = prefs.getString('user_phone') ?? '';
        _userAddress = prefs.getString('user_address') ?? '';
        _userSchool = prefs.getString('user_school') ?? '';
        _userClass = prefs.getString('user_class') ?? '';
        _userProfileImage = prefs.getString('user_profile_image') ?? '';
        _userRanking = prefs.getString('user_ranking') ?? 'SD';
        _activeTitle = prefs.getString('active_title');
      });
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  Future<void> _loadEarnedTitles() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final titlesJson = prefs.getString('earned_titles') ?? '[]';
      final titles = json.decode(titlesJson) as List;
      setState(() {
        _earnedTitles = titles.cast<String>();
      });
    } catch (e) {
      print('Error loading earned titles: $e');
    }
  }

  Future<void> _loadModuleProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _moduleProgress['bahasa_krama'] = prefs.getDouble('progress_bahasa_krama') ?? 0.0;
        _moduleProgress['aksara_jawa'] = prefs.getDouble('progress_aksara_jawa') ?? 0.0;
        _moduleProgress['sastra_indonesia'] = prefs.getDouble('progress_sastra_indonesia') ?? 0.0;
        _moduleProgress['sastra_jawa'] = prefs.getDouble('progress_sastra_jawa') ?? 0.0;
      });
    } catch (e) {
      print('Error loading module progress: $e');
    }
  }

  Future<void> _loadSchedules() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final schedulesJson = prefs.getString('learning_schedules') ?? '[]';
      final schedulesList = json.decode(schedulesJson) as List;

      setState(() {
        _schedules = schedulesList.map((e) => Map<String, dynamic>.from(e)).toList();
        _buildScheduledEvents();
      });

      // Schedule notifications for upcoming study sessions
      _scheduleNotifications();
    } catch (e) {
      print('Error loading schedules: $e');
    }
  }

  Future<void> _scheduleNotifications() async {
    if (_notificationsPlugin == null) return;

    // Cancel existing notifications
    await _notificationsPlugin!.cancelAll();

    for (var schedule in _schedules) {
      final scheduleDate = DateTime.parse(schedule['date']);
      final timeParts = schedule['time'].split(':');
      final scheduleDateTime = DateTime(
        scheduleDate.year,
        scheduleDate.month,
        scheduleDate.day,
        int.parse(timeParts[0]),
        int.parse(timeParts[1]),
      );

      // Schedule notification 15 minutes before
      final notificationTime = tz.TZDateTime.from(scheduleDateTime, tz.local)
          .subtract(Duration(minutes: 15));
      final now = tz.TZDateTime.now(tz.local);

      if (notificationTime.isAfter(now)) {
        await _notificationsPlugin?.zonedSchedule(
          schedule['id'].hashCode,
          'Waktune Sinau!',
          'Ayo siap-siap sinau ${schedule['title']}',
          notificationTime,
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'study_reminder',
              'Study Reminders',
              channelDescription: 'Notifications for study schedule reminders',
              importance: Importance.high,
              priority: Priority.high,
            ),
          ),
          androidAllowWhileIdle: true,
          uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
        );
      }
    }
  }

  Future<void> _saveSchedules() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final schedulesJson = json.encode(_schedules);
      await prefs.setString('learning_schedules', schedulesJson);

      final eventsMap = <String, List<Map<String, dynamic>>>{};
      for (var schedule in _schedules) {
        final date = DateTime.parse(schedule['date']);
        final dateKey = DateTime(date.year, date.month, date.day);
        final key = dateKey.toIso8601String();

        if (eventsMap[key] == null) {
          eventsMap[key] = [];
        }
        eventsMap[key]!.add(schedule);
      }

      await prefs.setString('calendar_events', json.encode(eventsMap));
      _scheduleNotifications(); // Reschedule notifications
    } catch (e) {
      print('Error saving schedules: $e');
    }
  }

  void _buildScheduledEvents() {
    _scheduledEvents.clear();
    for (var schedule in _schedules) {
      final date = DateTime.parse(schedule['date']);
      final dateKey = DateTime(date.year, date.month, date.day);

      if (_scheduledEvents[dateKey] == null) {
        _scheduledEvents[dateKey] = [];
      }
      _scheduledEvents[dateKey]!.add(schedule);
    }
  }

  Future<void> _loadChallenges() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final challengesJson = prefs.getString('user_challenges') ?? '[]';
      final challengesList = json.decode(challengesJson) as List;

      setState(() {
        _challenges = challengesList.map((e) => Map<String, dynamic>.from(e)).toList();
      });

      if (_challenges.isEmpty) {
        _challenges = [
          {
            'category': 'Bahasa Krama',
            'title': 'Tantangan Dino Menika',
            'description': 'Tulis ukara nganggo Basa Krama Inggil kangge ndherekaken tiyang sepuh.',
            'progress': _moduleProgress['bahasa_krama'] ?? 0.0,
            'moduleKey': 'bahasa_krama',
            'isCompleted': false,
            'dateCreated': DateTime.now().millisecondsSinceEpoch,
          },
          {
            'category': 'Aksara Jawa',
            'title': 'Latihan Nulis Aksara',
            'description': 'Tulis tembung-tembung ing ngisor iki nganggo aksara Jawa kanthi bener lan rapi.',
            'progress': _moduleProgress['aksara_jawa'] ?? 0.0,
            'moduleKey': 'aksara_jawa',
            'isCompleted': false,
            'dateCreated': DateTime.now().millisecondsSinceEpoch,
          },
          {
            'category': 'Sastra Jawa',
            'title': 'Geguritan Challenge',
            'description': 'Gawe geguritan cekak kanthi tema alam lan gunakane basa Jawa alus.',
            'progress': _moduleProgress['sastra_jawa'] ?? 0.0,
            'moduleKey': 'sastra_jawa',
            'isCompleted': false,
            'dateCreated': DateTime.now().millisecondsSinceEpoch,
          },
        ];
        _saveChallenges();
      }
    } catch (e) {
      print('Error loading challenges: $e');
    }
  }

  Future<void> _loadEnhancedLearningHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getString('learning_history') ?? '[]';
      final historyList = json.decode(historyJson) as List;

      setState(() {
        _learningHistory = historyList.map((e) => Map<String, dynamic>.from(e)).toList()
          ..sort((a, b) => b['timestamp'].compareTo(a['timestamp']));
      });

      // Add sample activities if empty
      if (_learningHistory.isEmpty) {
        _addSampleLearningHistory();
      }
    } catch (e) {
      print('Error loading learning history: $e');
    }
  }

  void _addSampleLearningHistory() {
    final sampleHistory = [
      {
        'title': 'Akses Tantangan Harian',
        'description': 'Menyelesaikan tantangan Bahasa Krama',
        'date': DateTime.now().subtract(const Duration(hours: 2)).toString(),
        'timestamp': DateTime.now().subtract(const Duration(hours: 2)).millisecondsSinceEpoch,
        'type': 'challenge',
        'module': 'bahasa_krama',
        'icon': 'quiz',
      },
      {
        'title': 'Membaca Materi Ayo Sinau',
        'description': 'Mempelajari materi Aksara Jawa dasar',
        'date': DateTime.now().subtract(const Duration(hours: 5)).toString(),
        'timestamp': DateTime.now().subtract(const Duration(hours: 5)).millisecondsSinceEpoch,
        'type': 'reading',
        'module': 'aksara_jawa',
        'icon': 'book',
      },
      {
        'title': 'Mengatur Jadwal Belajar',
        'description': 'Menambahkan jadwal sinau untuk hari Senin',
        'date': DateTime.now().subtract(const Duration(days: 1)).toString(),
        'timestamp': DateTime.now().subtract(const Duration(days: 1)).millisecondsSinceEpoch,
        'type': 'schedule',
        'module': 'general',
        'icon': 'schedule',
      },
    ];

    _learningHistory.addAll(sampleHistory);
    _saveLearningHistory();
  }

  Future<void> _saveLearningHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('learning_history', json.encode(_learningHistory));
    } catch (e) {
      print('Error saving learning history: $e');
    }
  }

  Future<void> _saveChallenges() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final challengesJson = json.encode(_challenges);
      await prefs.setString('user_challenges', challengesJson);
    } catch (e) {
      print('Error saving challenges: $e');
    }
  }

  void _addNewSchedule(Map<String, dynamic> schedule) {
    setState(() {
      _schedules.add(schedule);
      _buildScheduledEvents();
    });
    _saveSchedules();

    // Add to learning history
    _addToLearningHistory(
      'Mengatur Jadwal Belajar',
      'Menambahkan jadwal ${schedule['title']}',
      'schedule',
      'general',
    );
  }

  void _addToLearningHistory(String title, String description, String type, String module, {Map<String, dynamic>? extraData}) {
    final historyItem = {
      'title': title,
      'description': description,
      'date': DateTime.now().toString(),
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'type': type,
      'module': module,
      'icon': _getIconForType(type),
      if (extraData != null) ...extraData,
    };

    setState(() {
      _learningHistory.insert(0, historyItem);
      // Keep only last 50 items
      if (_learningHistory.length > 50) {
        _learningHistory = _learningHistory.take(50).toList();
      }
    });

    _saveLearningHistory();
  }

  String _getIconForType(String type) {
    switch (type) {
      case 'challenge':
        return 'quiz';
      case 'reading':
        return 'book';
      case 'schedule':
        return 'schedule';
      case 'achievement':
        return 'trophy';
      case 'title_earned':
        return 'emoji_events';
      case 'quiz_result':
        return 'assessment';
      default:
        return 'school';
    }
  }

  void _removeSchedule(int index) {
    setState(() {
      _schedules.removeAt(index);
      _buildScheduledEvents();
    });
    _saveSchedules();
  }

  // Enhanced search functionality
  void _performSearch(String query) {
    if (query.isEmpty) {
      setState(() {
        _searchResults.clear();
      });
      return;
    }

    final results = <Map<String, dynamic>>[];

    // Search in modules
    final modules = [
      {'name': 'Bahasa Krama', 'key': 'bahasa_krama', 'type': 'module'},
      {'name': 'Aksara Jawa', 'key': 'aksara_jawa', 'type': 'module'},
      {'name': 'Sastra Indonesia', 'key': 'sastra_indonesia', 'type': 'module'},
      {'name': 'Sastra Jawa', 'key': 'sastra_jawa', 'type': 'module'},
    ];

    for (var module in modules) {
      if (module['name']!.toLowerCase().contains(query.toLowerCase())) {
        results.add(module);
      }
    }

    // Search in learning history
    for (var item in _learningHistory) {
      if (item['title'].toLowerCase().contains(query.toLowerCase()) ||
          item['description'].toLowerCase().contains(query.toLowerCase())) {
        results.add({
          'name': item['title'],
          'description': item['description'],
          'type': 'history',
          'data': item,
        });
      }
    }

    // Search in schedules
    for (var schedule in _schedules) {
      if (schedule['title'].toLowerCase().contains(query.toLowerCase())) {
        results.add({
          'name': schedule['title'],
          'description': 'Jadwal: ${schedule['time']}',
          'type': 'schedule',
          'data': schedule,
        });
      }
    }

    setState(() {
      _searchResults = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFF1B1101),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B1101),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Image.asset(
              'assets/images/logo.png',
              width: 100,
              height: 40,
              errorBuilder: (context, error, stackTrace) => const Text(
                'SANDYA NUSANTARA',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
      drawer: DrawerMenu(
        userName: _userName,
        userEmail: _userEmail,
        userPhone: _userPhone,
        userAddress: _userAddress,
        userSchool: _userSchool,
        userClass: _userClass,
        moduleProgress: _moduleProgress,
        onUserDataUpdated: _loadUserData, userProfileImage: '', userRanking: '', earnedTitles: [], onTitleChanged: (title) {  },
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildHomeScreen(),
          _buildSearchScreen(),
          _buildHistoryScreen(),
          _buildScheduleScreen(),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildHomeScreen() {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/background.png'),
          fit: BoxFit.cover,
          opacity: 0.1,
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Enhanced header section with user info and active title
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: const Color(0xFF1B1101).withOpacity(0.9),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // Enhanced profile avatar with image support
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(25),
                          child: _userProfileImage.isNotEmpty
                              ? Image.asset(
                            _userProfileImage,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                _buildDefaultAvatar(),
                          )
                              : _buildDefaultAvatar(),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Sugeng Rawuh $_userName!',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.normal,
                                    color: Colors.white,
                                  ),
                                ),
                                if (_activeTitle != null) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.amber,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      _activeTitle!,
                                      style: const TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            Row(
                              children: [
                                if (_userSchool.isNotEmpty)
                                  Text(
                                    'Saking $_userSchool',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.white70,
                                    ),
                                  ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: _getRankingColor(_userRanking),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    _userRanking,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (_userClass.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Kelas $_userClass',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Daily Challenges Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Tantangan Harian ->',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 240,
                    child: _challenges.isEmpty
                        ? _buildEmptyChallenges()
                        : ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _challenges.length,
                      itemBuilder: (context, index) {
                        return ChallengeCard(
                          category: _challenges[index]['category'] ?? 'Tantangan',
                          title: _challenges[index]['title'] ?? 'Tantangan',
                          description: _challenges[index]['description'] ?? 'Deskripsi tantangan',
                          progress: (_challenges[index]['progress'] ?? 0.0).toDouble(),
                          onTap: () {
                            // Add to learning history
                            _addToLearningHistory(
                              'Akses Tantangan Harian',
                              'Memulai tantangan ${_challenges[index]['title']}',
                              'challenge',
                              _challenges[index]['moduleKey'],
                            );

                            Navigator.pushNamed(
                              context,
                              '/challenge',
                              arguments: _challenges[index]['moduleKey'],
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            // Learning Modules Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Text(
                        'Ayo ',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Sinau! ->',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.normal,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/learning_selection');
                    },
                    child: const Text(
                      'Tingali Sedoyo',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Learning Module Cards
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildLearningModuleCard(
                          'Sinau Bahasa Krama',
                          'Mantenangi penguasaan Ngoko, Krama Madya, lan Krama Inggil',
                          _moduleProgress['bahasa_krama']!,
                          'bahasa_krama',
                          Icons.chat_bubble_outline,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildLearningModuleCard(
                          'Sinau Aksara Jawa',
                          'Belajar menulis kata, kalimat, dan paragraf menggunakan aksara Jawa serta aksaranya',
                          _moduleProgress['aksara_jawa']!,
                          'aksara_jawa',
                          Icons.edit,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildLearningModuleCard(
                          'Sinau Sastra Indonesia',
                          'Belajar tentang karya sastra Indonesia serta bentuk-bentuk karya sastra',
                          _moduleProgress['sastra_indonesia']!,
                          'sastra_indonesia',
                          Icons.library_books,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildLearningModuleCard(
                          'Sinau Sastra Jawa',
                          'Belajar tentang karya sastra Jawa seperti tembang, parikan, geguritan, lan serat',
                          _moduleProgress['sastra_jawa']!,
                          'sastra_jawa',
                          Icons.auto_stories,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Enhanced History Section showing all activities
            Container(
              margin: const EdgeInsets.only(top: 24),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.95),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Text(
                            'Riwayat ',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF3E2723),
                            ),
                          ),
                          Text(
                            'Sinau ->',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.normal,
                              color: Color(0xFF3E2723),
                            ),
                          ),
                        ],
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _selectedIndex = 2; // Switch to history tab
                          });
                        },
                        child: const Text(
                          'Tingali Sedoyo',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF3E2723),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _learningHistory.isEmpty
                      ? _buildEmptyHistory()
                      : Column(
                    children: _learningHistory.take(3).map((item) =>
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: _buildEnhancedHistoryItem(item),
                        )
                    ).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchScreen() {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1B1101),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                const SizedBox(height: 20),
                const Text(
                  'Cari Materi Sinau',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _searchController,
                  style: const TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    hintText: 'Cari materi, jadwal, riwayat...',
                    hintStyle: const TextStyle(color: Colors.grey),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                      icon: const Icon(Icons.clear, color: Colors.grey),
                      onPressed: () {
                        _searchController.clear();
                        _performSearch('');
                      },
                    )
                        : null,
                  ),
                  onChanged: _performSearch,
                ),
              ],
            ),
          ),
          Expanded(
            child: _searchResults.isEmpty
                ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.search,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Ketik untuk mencari materi',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _searchResults.length,
              itemBuilder: (context, index) {
                final result = _searchResults[index];
                return Card(
                  child: ListTile(
                    leading: Icon(_getSearchResultIcon(result['type'])),
                    title: Text(result['name']),
                    subtitle: result['description'] != null ? Text(result['description']) : null,
                    onTap: () => _handleSearchResultTap(result),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryScreen() {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1B1101),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: const Column(
              children: [
                SizedBox(height: 20),
                Text(
                  'Riwayat Sinau Lengkap',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Semua aktivitas pembelajaran Anda',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _learningHistory.isEmpty
                ? _buildEmptyHistory()
                : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _learningHistory.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _buildEnhancedHistoryItem(_learningHistory[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleScreen() {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1B1101),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Jadwal Sinau',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    IconButton(
                      onPressed: () => _showAddScheduleDialog(context),
                      icon: const Icon(
                        Icons.add_circle,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ],
                ),
                const Text(
                  'Atur dan kelola jadwal pembelajaran',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildTodaySchedulePreview(),
                  const SizedBox(height: 16),
                  ScheduleCalendar(
                    events: _scheduledEvents,
                    onDaySelected: (selectedDay) {
                      final dayEvents = _scheduledEvents[selectedDay] ?? [];
                      if (dayEvents.isNotEmpty) {
                        _showDayEventsDialog(context, selectedDay, dayEvents);
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultAvatar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Center(
        child: Text(
          _userName.isNotEmpty ? _userName[0].toUpperCase() : 'P',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Color _getRankingColor(String ranking) {
    switch (ranking) {
      case 'SD':
        return Colors.green;
      case 'SMP':
        return Colors.blue;
      case 'SMA':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  IconData _getSearchResultIcon(String type) {
    switch (type) {
      case 'module':
        return Icons.school;
      case 'history':
        return Icons.history;
      case 'schedule':
        return Icons.schedule;
      default:
        return Icons.search;
    }
  }

  void _handleSearchResultTap(Map<String, dynamic> result) {
    switch (result['type']) {
      case 'module':
        Navigator.pushNamed(context, '/learning_activity', arguments: result['key']);
        break;
      case 'history':
        setState(() {
          _selectedIndex = 2; // Switch to history tab
        });
        break;
      case 'schedule':
        setState(() {
          _selectedIndex = 3; // Switch to schedule tab
        });
        break;
    }

    _searchController.clear();
    _searchResults.clear();
  }

  Widget _buildEnhancedHistoryItem(Map<String, dynamic> historyItem) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _getActivityColor(historyItem['type']),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getActivityIcon(historyItem['type']),
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
                  historyItem['title'] ?? 'Aktivitas',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3E2723),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  historyItem['description'] ?? 'Deskripsi tidak tersedia',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  _formatDate(historyItem['date']),
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.grey,
                  ),
                ),
                // Show additional info for quiz results and earned titles
                if (historyItem['type'] == 'quiz_result' && historyItem['score'] != null) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: _getScoreColor(historyItem['percentage'] ?? 0),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Skor: ${historyItem['score']}/${historyItem['total']} (${historyItem['percentage']}%)',
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
                if (historyItem['type'] == 'title_earned' && historyItem['earnedTitle'] != null) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.amber,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Gelar: ${historyItem['earnedTitle']}',
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _getActivityColor(historyItem['type']).withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _getActivityTypeLabel(historyItem['type']),
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: _getActivityColor(historyItem['type']),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getActivityColor(String type) {
    switch (type) {
      case 'challenge':
        return Colors.orange;
      case 'reading':
        return Colors.blue;
      case 'schedule':
        return Colors.green;
      case 'achievement':
        return Colors.purple;
      case 'title_earned':
        return Colors.amber.shade700;
      case 'quiz_result':
        return Colors.indigo;
      default:
        return Colors.grey;
    }
  }

  IconData _getActivityIcon(String type) {
    switch (type) {
      case 'challenge':
        return Icons.quiz;
      case 'reading':
        return Icons.book;
      case 'schedule':
        return Icons.schedule;
      case 'achievement':
        return Icons.emoji_events;
      case 'title_earned':
        return Icons.emoji_events;
      case 'quiz_result':
        return Icons.assessment;
      default:
        return Icons.school;
    }
  }

  String _getActivityTypeLabel(String type) {
    switch (type) {
      case 'challenge':
        return 'Tantangan';
      case 'reading':
        return 'Materi';
      case 'schedule':
        return 'Jadwal';
      case 'achievement':
        return 'Prestasi';
      case 'title_earned':
        return 'Gelar';
      case 'quiz_result':
        return 'Hasil Kuis';
      default:
        return 'Lainnya';
    }
  }

  Color _getScoreColor(int percentage) {
    if (percentage >= 80) return Colors.green;
    if (percentage >= 60) return Colors.orange;
    return Colors.red;
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'Tanggal tidak tersedia';

    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays == 0) {
        return 'Hari ini ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
      } else if (difference.inDays == 1) {
        return 'Kemarin';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} hari yang lalu';
      } else {
        return '${date.day}/${date.month}/${date.year}';
      }
    } catch (e) {
      return 'Tanggal tidak valid';
    }
  }

  Widget _buildTodaySchedulePreview() {
    final today = DateTime.now();
    final todayKey = DateTime(today.year, today.month, today.day);
    final todayEvents = _scheduledEvents[todayKey] ?? [];

    if (todayEvents.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          children: [
            const Icon(
              Icons.event_available,
              size: 40,
              color: Colors.grey,
            ),
            const SizedBox(height: 8),
            const Text(
              'Durung wonten jadwal dino iki',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF3E2723),
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Tambahake jadwal sinau kanggo dino iki',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () => _showAddScheduleDialog(context),
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Tambah Jadwal'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1B1101),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Jadwal Dino Iki:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF3E2723),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.notifications_active, size: 12, color: Colors.white),
                  SizedBox(width: 4),
                  Text(
                    'Notifikasi Aktif',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...todayEvents.map((event) => _buildScheduleItem(event)),
      ],
    );
  }

  Widget _buildScheduleItem(Map<String, dynamic> schedule) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _getModuleColor(schedule['moduleKey']),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getModuleIcon(schedule['moduleKey']),
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  schedule['title'] ?? 'Jadwal Sinau',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3E2723),
                  ),
                ),
                Text(
                  '${schedule['time']} - ${schedule['moduleKey']?.replaceAll('_', ' ').toUpperCase()}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              _removeSchedule(_schedules.indexOf(schedule));
            },
            icon: const Icon(
              Icons.delete_outline,
              color: Colors.red,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Color _getModuleColor(String? moduleKey) {
    switch (moduleKey) {
      case 'bahasa_krama':
        return Colors.blue;
      case 'aksara_jawa':
        return Colors.green;
      case 'sastra_indonesia':
        return Colors.orange;
      case 'sastra_jawa':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  IconData _getModuleIcon(String? moduleKey) {
    switch (moduleKey) {
      case 'bahasa_krama':
        return Icons.chat_bubble_outline;
      case 'aksara_jawa':
        return Icons.edit;
      case 'sastra_indonesia':
        return Icons.library_books;
      case 'sastra_jawa':
        return Icons.auto_stories;
      default:
        return Icons.book;
    }
  }

  void _showAddScheduleDialog(BuildContext context) {
    final titleController = TextEditingController();
    String selectedModule = 'aksara_jawa';
    DateTime selectedDate = DateTime.now();
    TimeOfDay selectedTime = TimeOfDay.now();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text(
            'Tambah Jadwal Sinau',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF3E2723),
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Judul Jadwal:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3E2723),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    hintText: 'Contoh: Sinau Aksara Jawa',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
                const SizedBox(height: 16),

                const Text(
                  'Pilih Modul:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3E2723),
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: selectedModule,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'aksara_jawa',
                      child: Text('Aksara Jawa'),
                    ),
                    DropdownMenuItem(
                      value: 'bahasa_krama',
                      child: Text('Bahasa Krama'),
                    ),
                    DropdownMenuItem(
                      value: 'sastra_indonesia',
                      child: Text('Sastra Indonesia'),
                    ),
                    DropdownMenuItem(
                      value: 'sastra_jawa',
                      child: Text('Sastra Jawa'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedModule = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),

                const Text(
                  'Tanggal:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3E2723),
                  ),
                ),
                const SizedBox(height: 8),
                InkWell(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) {
                      setState(() {
                        selectedDate = date;
                      });
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                const Text(
                  'Waktu:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3E2723),
                  ),
                ),
                const SizedBox(height: 8),
                InkWell(
                  onTap: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: selectedTime,
                    );
                    if (time != null) {
                      setState(() {
                        selectedTime = time;
                      });
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.access_time, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          selectedTime.format(context),
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.notifications, color: Colors.blue, size: 20),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Notifikasi akan dikirim 15 menit sebelum jadwal dimulai',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                if (titleController.text.isNotEmpty) {
                  final schedule = {
                    'id': DateTime.now().millisecondsSinceEpoch.toString(),
                    'title': titleController.text,
                    'moduleKey': selectedModule,
                    'date': selectedDate.toIso8601String(),
                    'time': selectedTime.format(context),
                    'isCompleted': false,
                    'createdAt': DateTime.now().toIso8601String(),
                  };

                  _addNewSchedule(schedule);
                  Navigator.pop(context);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.white),
                          SizedBox(width: 8),
                          Text('Jadwal berhasil ditambahkan dengan notifikasi!'),
                        ],
                      ),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1B1101),
                foregroundColor: Colors.white,
              ),
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDayEventsDialog(BuildContext context, DateTime selectedDay, List<Map<String, dynamic>> events) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Jadwal ${selectedDay.day}/${selectedDay.month}/${selectedDay.year}',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF3E2723),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: events.map((event) => _buildScheduleItem(event)).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyChallenges() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.quiz_outlined,
            size: 48,
            color: Colors.white70,
          ),
          const SizedBox(height: 16),
          const Text(
            'Durung wonten tantangan',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'Mulai sinau kanggo nggawe tantangan anyar',
            style: TextStyle(
              fontSize: 12,
              color: Colors.white70,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/learning_selection');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF1B1101),
            ),
            child: const Text('Mulai Sinau'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyHistory() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.history,
            size: 48,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          const Text(
            'Durung wonten riwayat sinau',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF3E2723),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'Mulai sinau kanggo nggawe riwayat',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLearningModuleCard(
      String title,
      String description,
      double progress,
      String moduleKey,
      IconData icon,
      ) {
    return GestureDetector(
      onTap: () {
        // Add to learning history
        _addToLearningHistory(
          'Membaca Materi Ayo Sinau',
          'Mengakses materi $title',
          'reading',
          moduleKey,
        );

        Navigator.pushNamed(context, '/learning_activity', arguments: moduleKey);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF5E6CE),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: const Color(0xFF3E2723),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF3E2723),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              description,
              style: const TextStyle(
                fontSize: 10,
                color: Color(0xFF3E2723),
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Progress',
                      style: TextStyle(
                        fontSize: 10,
                        color: Color(0xFF3E2723),
                      ),
                    ),
                    Text(
                      '${(progress * 100).toInt()}%',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF3E2723),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.grey.shade300,
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF3E2723)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF1B1101),
        unselectedItemColor: Colors.grey,
        selectedFontSize: 12,
        unselectedFontSize: 10,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Cari',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Riwayat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.schedule),
            label: 'Jadwal',
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
