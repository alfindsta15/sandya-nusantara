import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    // Delay sedikit untuk memastikan widget sudah ter-render
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _playWelcomeAudio();
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playWelcomeAudio() async {
    try {
      if (!mounted) return;

      setState(() {
        _isPlaying = true;
      });

      print('Attempting to play welcome audio...'); // Debug log
      await _audioPlayer.setAsset('assets/sounds/sugeng_rawuh_ing_sandya_nusantara.mp3');
      await _audioPlayer.durationFuture;

      print('Audio loaded successfully, starting playback...'); // Debug log

      // Mulai pemutaran
      await _audioPlayer.play();

      // Listen untuk completion
      _audioPlayer.playerStateStream.listen((state) {
        if (state.processingState == ProcessingState.completed) {
          if (mounted) {
            setState(() {
              _isPlaying = false;
            });
          }
        }
      });

    } catch (e) {
      print('Error playing welcome audio: $e');
      if (mounted) {
        setState(() {
          _isPlaying = false;
        });

        // Tampilkan snackbar error untuk debugging
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Audio error: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  // Method untuk replay audio manual (untuk testing)
  Future<void> _replayAudio() async {
    await _audioPlayer.stop();
    await _playWelcomeAudio();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // Background Image
            Positioned.fill(
              child: Image.asset(
                'assets/images/welcome_background.png',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFF8B4513), Color(0xFF5D3A1D)],
                    ),
                  ),
                ),
              ),
            ),
            // Content
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(height: 300),
                    Column(
                      children: [
                        // Audio indicator and greeting
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (_isPlaying) ...[
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Memutar audio...',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                            ],
                            GestureDetector(
                              onTap: _replayAudio,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF5D4037),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(color: Colors.white.withOpacity(0.3)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const SizedBox(width: 4),
                                    const Text(
                                      'SUGENG RAWUH ING SANDYA NUSANTARA',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Sugeng rawuh, para siswa ing Sandya Nusantara! Punapa panjenengan sampun siyap sinau aksara Jawa, basa krama, lan sastra Indonesia kanthi cara ingkang nyenengake? Ing ngriki, panjenengan saged nglumpukake piwulang kanthi interaktif, nglewati tantangan, lan nampi ganjaran saking kawruh ingkang dipun gadang-gadang.',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF5D4037),
                            height: 1.4,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        // LOGIN dengan gradasi
                        SizedBox(
                          width: double.infinity,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFF5D4037), // Coklat gelap
                                  Color(0xFFD7A74F), // Emas
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pushNamed(context, '/login');
                              },
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'MLEBET/LOGIN',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // REGISTER (outline)
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/register');
                            },
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              side: const BorderSide(color: Color(0xFF6D4C41), width: 2),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'NDHAFTAR/REGISTER',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF6D4C41),
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'All Right Reserved @2025',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF5D4037),
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}