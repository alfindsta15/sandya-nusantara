import 'package:flutter/material.dart';
import 'package:sandya_nusantara/screens/splash_screen.dart';
import 'package:sandya_nusantara/screens/welcome_screen.dart';
import 'package:sandya_nusantara/screens/login_screen.dart';
import 'package:sandya_nusantara/screens/register_screen.dart';
import 'package:sandya_nusantara/screens/main_screen.dart';
import 'package:sandya_nusantara/screens/learning_selection_screen.dart';
import 'package:sandya_nusantara/screens/learning_activity_screen.dart';
import 'package:sandya_nusantara/screens/challenge_result_screen.dart';
import 'package:sandya_nusantara/screens/duolingo_quiz_screen.dart' hide ChallengeResultScreen;
import 'package:sandya_nusantara/screens/challenge_history_screen.dart';
import 'package:sandya_nusantara/screens/challenge_activity_screen.dart';
import 'package:sandya_nusantara/utils/app_theme.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sandya Nusantara',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/welcome': (context) => const WelcomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/main': (context) => const MainScreen(),
        '/learning_selection': (context) => const LearningSelectionScreen(),
        '/challenge_history': (context) => const EnhancedChallengeHistoryScreen(),
      },
      onGenerateRoute: (settings) {
        // Learning Activity Routes
        if (settings.name == '/learning_activity') {
          final moduleType = settings.arguments as String;
          return MaterialPageRoute(
            builder: (context) => LearningActivityScreen(moduleType: moduleType),
          );
        } else if (settings.name == '/enhanced_learning_activity') {
          final moduleType = settings.arguments as String;
          return MaterialPageRoute(
            builder: (context) => LearningActivityScreen(moduleType: moduleType),
          );
        }

        // Challenge Routes
        else if (settings.name == '/challenge') {
          final moduleType = settings.arguments as String;
          return MaterialPageRoute(
            builder: (context) => EnhancedDuolingoQuizScreen(moduleType: moduleType),
          );
        } else if (settings.name == '/challenge_result') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) => ChallengeResultScreen(
              moduleType: args['moduleType'],
              score: args['score'],
              totalQuestions: args['totalQuestions'],
              percentage: args['percentage'],
              earnedTitle: args['earnedTitle'],
            ),
          );
        } else if (settings.name == '/challenge_activity') {
          final moduleType = settings.arguments as String;
          return MaterialPageRoute(
            builder: (context) => ChallengeActivityScreen(moduleType: moduleType),
          );
        }

        // Quiz Routes
        else if (settings.name == '/quiz') {
          final moduleType = settings.arguments as String;
          return MaterialPageRoute(
            builder: (context) => EnhancedDuolingoQuizScreen(moduleType: moduleType),
          );
        }

        // Profile and Settings Routes
        else if (settings.name == '/profile') {
          return MaterialPageRoute(
            builder: (context) => const ProfileScreen(),
          );
        } else if (settings.name == '/settings') {
          return MaterialPageRoute(
            builder: (context) => const SettingsScreen(),
          );
        }

        // Search Route
        else if (settings.name == '/search') {
          return MaterialPageRoute(
            builder: (context) => const SearchScreen(),
          );
        }

        // Help and About Routes
        else if (settings.name == '/help') {
          return MaterialPageRoute(
            builder: (context) => const HelpScreen(),
          );
        } else if (settings.name == '/achievements') {
          return MaterialPageRoute(
            builder: (context) => const EnhancedChallengeHistoryScreen(),
          );
        }

        // Calendar Routes
        else if (settings.name == '/schedule') {
          return MaterialPageRoute(
            builder: (context) => const ScheduleScreen(),
          );
        } else if (settings.name == '/full_calendar') {
          return MaterialPageRoute(
            builder: (context) => const FullCalendarScreen(),
          );
        }

        // History Routes
        else if (settings.name == '/history') {
          return MaterialPageRoute(
            builder: (context) => const EnhancedChallengeHistoryScreen(),
          );
        } else if (settings.name == '/all_challenges') {
          return MaterialPageRoute(
            builder: (context) => const AllChallengesScreen(),
          );
        }

        return null;
      },
    );
  }
}

// Enhanced placeholder screens with better UI
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF5D3A1D),
      appBar: AppBar(
        backgroundColor: const Color(0xFF5D3A1D),
        elevation: 0,
        title: const Text('Profil', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Container(
          margin: const EdgeInsets.all(32),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
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
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.person,
                size: 64,
                color: Color(0xFF5D3A1D),
              ),
              const SizedBox(height: 16),
              const Text(
                'Halaman Profil',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3E2723),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Fitur ini akan segera hadir!\nAnda dapat mengelola profil dan preferensi di sini.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5D3A1D),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Kembali'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF5D3A1D),
      appBar: AppBar(
        backgroundColor: const Color(0xFF5D3A1D),
        elevation: 0,
        title: const Text('Pengaturan', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Container(
          margin: const EdgeInsets.all(32),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
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
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.settings,
                size: 64,
                color: Color(0xFF5D3A1D),
              ),
              const SizedBox(height: 16),
              const Text(
                'Pengaturan',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3E2723),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Fitur ini akan segera hadir!\nAnda dapat mengatur preferensi aplikasi di sini.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5D3A1D),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Kembali'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SearchScreen extends StatelessWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF5D3A1D),
      appBar: AppBar(
        backgroundColor: const Color(0xFF5D3A1D),
        elevation: 0,
        title: const Text('Pencarian', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Container(
          margin: const EdgeInsets.all(32),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
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
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.search,
                size: 64,
                color: Color(0xFF5D3A1D),
              ),
              const SizedBox(height: 16),
              const Text(
                'Pencarian',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3E2723),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Fitur ini akan segera hadir!\nAnda dapat mencari materi pembelajaran di sini.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5D3A1D),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Kembali'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HelpScreen extends StatelessWidget {
  const HelpScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF5D3A1D),
      appBar: AppBar(
        backgroundColor: const Color(0xFF5D3A1D),
        elevation: 0,
        title: const Text('Bantuan', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Container(
          margin: const EdgeInsets.all(32),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
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
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.help,
                size: 64,
                color: Color(0xFF5D3A1D),
              ),
              const SizedBox(height: 16),
              const Text(
                'Bantuan',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3E2723),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Fitur ini akan segera hadir!\nAnda dapat menemukan panduan dan FAQ di sini.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5D3A1D),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Kembali'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF5D3A1D),
      appBar: AppBar(
        backgroundColor: const Color(0xFF5D3A1D),
        elevation: 0,
        title: const Text('Prestasi', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Container(
          margin: const EdgeInsets.all(32),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
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
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.emoji_events,
                size: 64,
                color: Color(0xFF5D3A1D),
              ),
              const SizedBox(height: 16),
              const Text(
                'Prestasi',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3E2723),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Lihat prestasi dan pencapaian Anda di halaman Riwayat & Pencapaian!',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Kembali'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/challenge_history');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5D3A1D),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Lihat Prestasi'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ScheduleScreen extends StatelessWidget {
  const ScheduleScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF5D3A1D),
      appBar: AppBar(
        backgroundColor: const Color(0xFF5D3A1D),
        elevation: 0,
        title: const Text('Jadwal', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Container(
          margin: const EdgeInsets.all(32),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
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
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.schedule,
                size: 64,
                color: Color(0xFF5D3A1D),
              ),
              const SizedBox(height: 16),
              const Text(
                'Jadwal',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3E2723),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Fitur ini akan segera hadir!\nAnda dapat mengatur jadwal belajar di sini.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5D3A1D),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Kembali'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FullCalendarScreen extends StatelessWidget {
  const FullCalendarScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF5D3A1D),
      appBar: AppBar(
        backgroundColor: const Color(0xFF5D3A1D),
        elevation: 0,
        title: const Text('Kalender Lengkap', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Container(
          margin: const EdgeInsets.all(32),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
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
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.calendar_month,
                size: 64,
                color: Color(0xFF5D3A1D),
              ),
              const SizedBox(height: 16),
              const Text(
                'Kalender Lengkap',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3E2723),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Fitur ini akan segera hadir!\nAnda dapat melihat kalender pembelajaran lengkap di sini.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5D3A1D),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Kembali'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF5D3A1D),
      appBar: AppBar(
        backgroundColor: const Color(0xFF5D3A1D),
        elevation: 0,
        title: const Text('Riwayat', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Container(
          margin: const EdgeInsets.all(32),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
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
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.history,
                size: 64,
                color: Color(0xFF5D3A1D),
              ),
              const SizedBox(height: 16),
              const Text(
                'Riwayat',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3E2723),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Lihat riwayat pembelajaran lengkap di halaman Riwayat & Pencapaian!',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Kembali'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/challenge_history');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5D3A1D),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Lihat Riwayat'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AllChallengesScreen extends StatelessWidget {
  const AllChallengesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF5D3A1D),
      appBar: AppBar(
        backgroundColor: const Color(0xFF5D3A1D),
        elevation: 0,
        title: const Text('Semua Tantangan', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Container(
          margin: const EdgeInsets.all(32),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
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
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.quiz,
                size: 64,
                color: Color(0xFF5D3A1D),
              ),
              const SizedBox(height: 16),
              const Text(
                'Semua Tantangan',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3E2723),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Pilih modul pembelajaran untuk memulai tantangan!',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Kembali'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/learning_selection');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5D3A1D),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Pilih Modul'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
