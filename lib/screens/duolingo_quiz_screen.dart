import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:just_audio/just_audio.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:convert';
import 'dart:math';

class EnhancedDuolingoQuizScreen extends StatefulWidget {
  final String moduleType;

  const EnhancedDuolingoQuizScreen({
    Key? key,
    required this.moduleType,
  }) : super(key: key);

  @override
  State<EnhancedDuolingoQuizScreen> createState() => _EnhancedDuolingoQuizScreenState();
}

class _EnhancedDuolingoQuizScreenState extends State<EnhancedDuolingoQuizScreen>
    with TickerProviderStateMixin {
  int _currentQuestionIndex = 0;
  int _score = 0;
  int _lives = 3;
  bool _isAnswered = false;
  String? _selectedAnswer;
  List<Map<String, dynamic>> _questions = [];
  late AnimationController _progressController;
  late AnimationController _heartController;
  late AnimationController _bounceController;
  late Animation<double> _progressAnimation;
  late Animation<double> _bounceAnimation;

  // Enhanced Audio player instance
  final AudioPlayer _audioPlayer = AudioPlayer();

  // Matching game state
  List<String> _leftItems = [];
  List<String> _rightItems = [];
  Map<String, String> _userMatches = {};
  Map<String, String> _correctMatches = {};

  // Selected items for matching
  String? _selectedLeftItem;
  String? _selectedRightItem;

  // Animation controllers for magnet effect
  late AnimationController _magnetController;
  late Animation<double> _magnetAnimation;

  // Word arrangement state
  List<String> _availableWords = [];
  List<String> _arrangedWords = [];

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _heartController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _magnetController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _progressAnimation = Tween<double>(begin: 0, end: 1).animate(_progressController);
    _bounceAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.elasticOut),
    );
    _magnetAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _magnetController, curve: Curves.easeInOut),
    );
    _loadQuestions();
  }

  @override
  void dispose() {
    _progressController.dispose();
    _heartController.dispose();
    _bounceController.dispose();
    _magnetController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  void _loadQuestions() {
    setState(() {
      _questions = _getQuestionsForModule(widget.moduleType);
      // Shuffle questions to avoid repetition
      _questions.shuffle();
    });
    _progressController.animateTo(0);
  }

  List<Map<String, dynamic>> _getQuestionsForModule(String moduleType) {
    switch (moduleType) {
      case 'aksara_jawa':
        return [
          {
            'type': 'multiple_choice',
            'question': 'Apa aksara Jawa untuk huruf "ha"?',
            'options': ['ꦲ', 'ꦤ', 'ꦕ', 'ꦫ'],
            'correct': 'ꦲ',
            'explanation': 'Aksara ꦲ (ha) adalah aksara pertama dalam urutan Hanacaraka.',
            'has_sound': true,
            'sound': 'ha.mp3',
            'option_sounds': ['ha.mp3', 'na.mp3', 'ca.mp3', 'ra.mp3']
          },
          {
            'type': 'multiple_choice',
            'question': 'Tulisan "Jawa" dalam aksara Jawa adalah?',
            'options': ['ꦗꦮ', 'ꦗꦸꦮ', 'ꦗꦮꦸ', 'ꦗꦺꦮ'],
            'correct': 'ꦗꦮ',
            'explanation': 'Kata "Jawa" ditulis ꦗꦮ dalam aksara Jawa.',
            'has_sound': true,
            'sound': 'jawa.mp3',
            'option_sounds': ['jawa.mp3', 'jawu.mp3', 'jawau.mp3', 'jawe.mp3']
          },
          {
            'type': 'audio_choice',
            'question': 'Dengarkan suara berikut, aksara apa yang tepat?',
            'options': ['ꦤ', 'ꦩ', 'ꦒ', 'ꦧ'],
            'correct': 'ꦤ',
            'has_sound': true,
            'sound': 'na.mp3',
            'explanation': 'Suara "na" ditulis dengan aksara ꦤ.',
            'option_sounds': ['na.mp3', 'ma.mp3', 'ga.mp3', 'ba.mp3']
          },
          {
            'type': 'matching',
            'question': 'Pasangkan aksara dengan bunyinya!',
            'pairs': [
              {'aksara': 'ꦕ', 'sound': 'ca', 'has_sound': true, 'audio': 'ca.mp3'},
              {'aksara': 'ꦫ', 'sound': 'ra', 'has_sound': true, 'audio': 'ra.mp3'},
              {'aksara': 'ꦏ', 'sound': 'ka', 'has_sound': true, 'audio': 'ka.mp3'},
            ],
            'explanation': 'Setiap aksara memiliki bunyi yang sesuai dengan urutan Hanacaraka.'
          },
          {
            'type': 'fill_blank',
            'question': 'Lengkapi urutan Hanacaraka: ꦲ ꦤ ꦕ __ ꦏ',
            'options': ['ꦫ', 'ꦢ', 'ꦠ', 'ꦱ'],
            'correct': 'ꦫ',
            'explanation': 'Urutan Hanacaraka: Ha Na Ca Ra Ka.',
            'has_sound': true,
            'sound': 'hanacaraka.mp3',
            'option_sounds': ['ra.mp3', 'da.mp3', 'ta.mp3', 'sa.mp3']
          },
          {
            'type': 'multiple_choice',
            'question': 'Aksara ꦔ dibaca sebagai?',
            'options': ['nga', 'ga', 'na', 'ma'],
            'correct': 'nga',
            'explanation': 'Aksara ꦔ dibaca "nga".',
            'has_sound': true,
            'sound': 'nga.mp3',
            'option_sounds': ['nga.mp3', 'ga.mp3', 'na.mp3', 'ma.mp3']
          },
          {
            'type': 'audio_word_arrangement',
            'question': 'Dengarkan kalimat berikut, susun aksara yang tepat!',
            'words': ['ꦲꦏꦸ', 'ꦱꦶꦤꦸ', 'ꦧꦱ', 'ꦗꦮ'],
            'correct_order': ['ꦲꦏꦸ', 'ꦱꦶꦤꦸ', 'ꦧꦱ', 'ꦗꦮ'],
            'correct_sentence': 'ꦲꦏꦸ ꦱꦶꦤꦸ ꦧꦱ ꦗꦮ',
            'explanation': 'Kalimat "Aku sinau basa Jawa" (Saya belajar bahasa Jawa) dalam aksara Jawa.',
            'has_sound': true,
            'sound': 'aku_sinau_basa_jawa.mp3'
          },
          {
            'type': 'multiple_choice',
            'question': 'Pasangan aksara ꦏ adalah?',
            'options': ['꧀ꦏ', 'ꦏ꧀', 'ꦏꦸ', 'ꦏꦶ'],
            'correct': 'ꦏ꧀',
            'explanation': 'Pasangan aksara ꦏ adalah ꦏ꧀.',
            'has_sound': true,
            'sound': 'ka_pasangan.mp3',
            'option_sounds': ['ka_pasangan1.mp3', 'ka_pasangan.mp3', 'ku.mp3', 'ki.mp3']
          },
          {
            'type': 'audio_choice',
            'question': 'Dengarkan kata berikut, tulisan yang benar adalah?',
            'options': ['ꦧꦸꦏꦸ', 'ꦧꦸꦏ', 'ꦧꦏꦸ', 'ꦧꦸꦏꦸꦸ'],
            'correct': 'ꦧꦸꦏꦸ',
            'has_sound': true,
            'sound': 'buku.mp3',
            'explanation': 'Kata "buku" ditulis ꦧꦸꦏꦸ.',
            'option_sounds': ['buku.mp3', 'buk.mp3', 'baku.mp3', 'bukuu.mp3']
          },
          {
            'type': 'matching',
            'question': 'Pasangkan aksara dengan sandhangan yang tepat!',
            'pairs': [
              {'aksara': 'ꦏꦶ', 'sound': 'ki', 'has_sound': true, 'audio': 'ki.mp3'},
              {'aksara': 'ꦏꦸ', 'sound': 'ku', 'has_sound': true, 'audio': 'ku.mp3'},
              {'aksara': 'ꦏꦺ', 'sound': 'ke', 'has_sound': true, 'audio': 'ke.mp3'},
            ],
            'explanation': 'Sandhangan mengubah vokal dasar aksara.'
          },
        ];

      case 'bahasa_krama':
        return [
          {
            'type': 'multiple_choice',
            'question': 'Kata "makan" dalam Krama Inggil adalah?',
            'options': ['mangan', 'nedha', 'dhahar', 'maem'],
            'correct': 'dhahar',
            'explanation': 'Dalam Krama Inggil, "makan" disebut "dhahar".',
            'has_sound': true,
            'sound': 'kata makan.mp3',
            'option_sounds': ['mangan.mp3', 'nedha.mp3', 'dhahar.mp3', 'maem.mp3']
          },
          {
            'type': 'multiple_choice',
            'question': '"Bapak lenggah wonten ing ruang tamu". Kata "lenggah" artinya?',
            'options': ['duduk', 'berdiri', 'tidur', 'berjalan'],
            'correct': 'duduk',
            'has_sound': true,
            'sound': 'bapak_lenggah_wonten_ing_ruang_tamu.mp3',
            'explanation': 'Lenggah adalah kata Krama Inggil yang artinya duduk.',
            'option_sounds': ['duduk.mp3', 'berdiri.mp3', 'tidur.mp3', 'berjalan.mp3']
          },
          {
            'type': 'multiple_choice',
            'question': 'Tingkatan bahasa Jawa yang paling halus adalah?',
            'options': ['Ngoko', 'Krama Madya', 'Krama Inggil', 'Krama Ngoko'],
            'correct': 'Krama Inggil',
            'explanation': 'Krama Inggil adalah tingkatan bahasa Jawa yang paling halus dan sopan.',
            'has_sound': true,
            'option_sounds': ['ngoko.mp3', 'krama_madya.mp3', 'krama_inggil.mp3', 'krama_ngoko.mp3']
          },
          {
            'type': 'matching',
            'question': 'Pasangkan kata Ngoko dengan Krama Inggil!',
            'pairs': [
              {'ngoko': 'aku', 'krama': 'kula', 'has_sound': true, 'audio': 'kula.mp3'},
              {'ngoko': 'kowe', 'krama': 'panjenengan', 'has_sound': true, 'audio': 'panjenengan.mp3'},
              {'ngoko': 'omah', 'krama': 'griya', 'has_sound': true, 'audio': 'griya.mp3'}
            ],
            'explanation': 'Setiap kata Ngoko memiliki padanan dalam Krama Inggil.'
          },
          {
            'type': 'audio_choice',
            'question': 'Dengarkan kalimat berikut, terjemahan yang benar adalah?',
            'options': ['Saya mau pergi', 'Saya sudah makan', 'Saya sedang belajar', 'Saya akan tidur'],
            'correct': 'Saya mau pergi',
            'has_sound': true,
            'sound': 'kula_badhe_tindak.mp3',
            'explanation': '"Kula badhe tindak" artinya "Saya mau pergi".',
            'option_sounds': ['pergi.mp3', 'makan.mp3', 'belajar.mp3', 'tidur.mp3']
          },
          {
            'type': 'audio_word_arrangement',
            'question': 'Dengarkan kalimat berikut, susun kata yang tepat!',
            'words': ['Kula', 'badhe', 'dhahar', 'sekul'],
            'correct_order': ['Kula', 'badhe', 'dhahar', 'sekul'],
            'correct_sentence': 'Kula badhe dhahar sekul',
            'explanation': 'Kalimat "Kula badhe dhahar sekul" artinya "Saya akan makan nasi".',
            'has_sound': true,
            'sound': 'kula_badhe_dhahar_sekul.mp3'
          },
          {
            'type': 'multiple_choice',
            'question': 'Kata "rumah" dalam Krama Inggil adalah?',
            'options': ['omah', 'griya', 'dalem', 'wisma'],
            'correct': 'griya',
            'explanation': 'Dalam Krama Inggil, "rumah" disebut "griya".',
            'has_sound': true,
            'sound': 'griya.mp3',
            'option_sounds': ['omah.mp3', 'griya.mp3', 'dalem.mp3', 'wisma.mp3']
          },
          {
            'type': 'fill_blank',
            'question': 'Lengkapi kalimat: "Bapak __ wonten kantor" (Bapak bekerja di kantor)',
            'options': ['nyambut gawe', 'makarya', 'damel', 'kerja'],
            'correct': 'damel',
            'explanation': '"Damel" adalah kata Krama Inggil untuk "bekerja".',
            'has_sound': true,
            'option_sounds': ['nyambut_gawe.mp3', 'makarya.mp3', 'bapak_damel_wonten_kantor.mp3', 'kerja.mp3']
          },
          {
            'type': 'multiple_choice',
            'question': 'Ungkapan "sugeng enjing" digunakan untuk?',
            'options': ['selamat siang', 'selamat pagi', 'selamat malam', 'selamat sore'],
            'correct': 'selamat pagi',
            'explanation': '"Sugeng enjing" artinya "selamat pagi".',
            'has_sound': true,
            'sound': 'pagi.mp3',
            'option_sounds': ['siang.mp3', 'pagi.mp3', 'malam.mp3', 'sore.mp3']
          },
          {
            'type': 'matching',
            'question': 'Pasangkan waktu dengan sapaan yang tepat!',
            'pairs': [
              {'waktu': 'Pagi', 'sapaan': 'Sugeng enjing', 'has_sound': true, 'audio': 'pagi.mp3'},
              {'waktu': 'Siang', 'sapaan': 'Sugeng siang', 'has_sound': true, 'audio': 'siang.mp3'},
              {'waktu': 'Malam', 'sapaan': 'Sugeng dalu', 'has_sound': true, 'audio': 'malam.mp3'}
            ],
            'explanation': 'Setiap waktu memiliki sapaan yang sesuai dalam bahasa Jawa.'
          },
        ];

      case 'sastra_indonesia':
        return [
          {
            'type': 'multiple_choice',
            'question': 'Siapa penulis puisi "Aku"?',
            'options': ['Chairil Anwar', 'W.S. Rendra', 'Sapardi Djoko Damono', 'Taufiq Ismail'],
            'correct': 'Chairil Anwar',
            'explanation': 'Puisi "Aku" ditulis oleh Chairil Anwar, penyair angkatan 45.',
            'has_sound': true,
            'sound': 'chairil_anwar.mp3'
          },
          {
            'type': 'multiple_choice',
            'question': 'Apa yang dimaksud dengan puisi?',
            'options': ['Cerita panjang', 'Karya sastra berima', 'Drama pendek', 'Esai ilmiah'],
            'correct': 'Karya sastra berima',
            'explanation': 'Puisi adalah karya sastra yang menggunakan kata-kata indah dan berirama.',
            'has_sound': true,
            'sound': 'puisi_definition.mp3'
          },
          {
            'type': 'fill_blank',
            'question': 'Lengkapi baris puisi Chairil Anwar: "Aku ini binatang ___"',
            'options': ['liar', 'jalang', 'buas', 'ganas'],
            'correct': 'jalang',
            'has_sound': true,
            'sound': 'aku_ini_binatang.mp3',
            'explanation': 'Baris lengkapnya: "Aku ini binatang jalang".'
          },
          {
            'type': 'audio_choice',
            'question': 'Dengarkan pembacaan puisi berikut, siapa penulisnya?',
            'options': ['Chairil Anwar', 'Amir Hamzah', 'Sutan Takdir Alisjahbana', 'Sanusi Pane'],
            'correct': 'Chairil Anwar',
            'has_sound': true,
            'sound': 'aku_poem.mp3',
            'explanation': 'Puisi tersebut adalah karya Chairil Anwar.'
          },
          {
            'type': 'multiple_choice',
            'question': 'Novel "Sitti Nurbaya" ditulis oleh?',
            'options': ['Marah Rusli', 'Abdul Muis', 'Nur Sutan Iskandar', 'Merari Siregar'],
            'correct': 'Marah Rusli',
            'explanation': 'Novel "Sitti Nurbaya" ditulis oleh Marah Rusli pada tahun 1922.',
            'has_sound': true,
            'sound': 'sitti_nurbaya.mp3'
          },
          {
            'type': 'matching',
            'question': 'Pasangkan penulis dengan karyanya!',
            'pairs': [
              {'penulis': 'Pramoedya Ananta Toer', 'karya': 'Bumi Manusia'},
              {'penulis': 'Andrea Hirata', 'karya': 'Laskar Pelangi'},
              {'penulis': 'Habiburrahman El Shirazy', 'karya': 'Ayat-Ayat Cinta'}
            ],
            'explanation': 'Setiap penulis memiliki karya yang terkenal.'
          },
          {
            'type': 'audio_word_arrangement',
            'question': 'Dengarkan puisi berikut, susun baris yang tepat!',
            'words': ['Aku', 'ini', 'binatang', 'jalang'],
            'correct_order': ['Aku', 'ini', 'binatang', 'jalang'],
            'correct_sentence': 'Aku ini binatang jalang',
            'explanation': 'Baris puisi terkenal dari Chairil Anwar.',
            'has_sound': true,
            'sound': 'aku_ini_binatang_jalang.mp3'
          },
          {
            'type': 'multiple_choice',
            'question': 'Angkatan sastra yang muncul setelah kemerdekaan adalah?',
            'options': ['Angkatan Balai Pustaka', 'Angkatan Pujangga Baru', 'Angkatan 45', 'Angkatan 66'],
            'correct': 'Angkatan 45',
            'explanation': 'Angkatan 45 muncul setelah kemerdekaan Indonesia.',
            'has_sound': true,
            'sound': 'angkatan_45.mp3'
          },
          {
            'type': 'fill_blank',
            'question': 'Majas yang membandingkan dua hal tanpa kata pembanding adalah?',
            'options': ['simile', 'metafora', 'personifikasi', 'hiperbola'],
            'correct': 'metafora',
            'explanation': 'Metafora adalah majas perbandingan tanpa kata pembanding.',
            'has_sound': true,
            'sound': 'metafora.mp3'
          },
          {
            'type': 'audio_choice',
            'question': 'Dengarkan kutipan novel berikut, genre apa yang tepat?',
            'options': ['Romantis', 'Horor', 'Petualangan', 'Sejarah'],
            'correct': 'Romantis',
            'has_sound': true,
            'sound': 'novel_romantis.mp3',
            'explanation': 'Kutipan tersebut menunjukkan ciri-ciri novel romantis.'
          },
        ];

      case 'sastra_jawa':
        return [
          {
            'type': 'multiple_choice',
            'question': 'Apa yang dimaksud dengan tembang macapat?',
            'options': ['Puisi bebas', 'Puisi tradisional Jawa', 'Cerita rakyat', 'Drama Jawa'],
            'correct': 'Puisi tradisional Jawa',
            'explanation': 'Tembang macapat adalah puisi tradisional Jawa dengan aturan tertentu.',
            'has_sound': true,
            'sound': 'macapat_definition.mp3'
          },
          {
            'type': 'multiple_choice',
            'question': 'Salah satu jenis tembang macapat adalah?',
            'options': ['Pocung', 'Parikan', 'Geguritan', 'Serat'],
            'correct': 'Pocung',
            'explanation': 'Pocung adalah salah satu dari 11 jenis tembang macapat.',
            'has_sound': true,
            'sound': 'pocung_definition.mp3'
          },
          {
            'type': 'audio_choice',
            'question': 'Dengarkan tembang berikut, jenis tembang apa ini?',
            'options': ['Pocung', 'Sinom', 'Gambuh', 'Mijil'],
            'correct': 'Pocung',
            'has_sound': true,
            'sound': 'pocung_song.mp3',
            'explanation': 'Tembang tersebut adalah Pocung dengan ciri khas 4 baris.'
          },
          {
            'type': 'fill_blank',
            'question': 'Lengkapi tembang Pocung: "Ngelmu iku kalakone kanthi ___"',
            'options': ['laku', 'karya', 'usaha', 'doa'],
            'correct': 'laku',
            'explanation': 'Baris lengkapnya: "Ngelmu iku kalakone kanthi laku".',
            'has_sound': true,
            'sound': 'ngelmu_iku.mp3'
          },
          {
            'type': 'matching',
            'question': 'Pasangkan jenis sastra Jawa dengan cirinya!',
            'pairs': [
              {'jenis': 'Tembang', 'ciri': 'Puisi beraturan'},
              {'jenis': 'Geguritan', 'ciri': 'Puisi bebas'},
              {'jenis': 'Parikan', 'ciri': 'Pantun Jawa'},
            ],
            'explanation': 'Setiap jenis sastra Jawa memiliki karakteristik yang berbeda.'
          },
          {
            'type': 'audio_word_arrangement',
            'question': 'Dengarkan tembang berikut, susun baris yang tepat!',
            'words': ['Ngelmu', 'iku', 'kalakone', 'kanthi', 'laku'],
            'correct_order': ['Ngelmu', 'iku', 'kalakone', 'kanthi', 'laku'],
            'correct_sentence': 'Ngelmu iku kalakone kanthi laku',
            'explanation': 'Baris tembang Pocung yang terkenal tentang ilmu.',
            'has_sound': true,
            'sound': 'ngelmu_iku_kalakone.mp3'
          },
          {
            'type': 'multiple_choice',
            'question': 'Tembang Sinom memiliki berapa baris?',
            'options': ['7 baris', '8 baris', '9 baris', '10 baris'],
            'correct': '9 baris',
            'explanation': 'Tembang Sinom memiliki 9 baris dengan pola tertentu.',
            'has_sound': true,
            'sound': 'sinom_definition.mp3'
          },
          {
            'type': 'audio_choice',
            'question': 'Dengarkan tembang Asmaradana berikut, tema apa yang disampaikan?',
            'options': ['Cinta', 'Nasihat', 'Duka', 'Kegembiraan'],
            'correct': 'Cinta',
            'has_sound': true,
            'sound': 'asmaradana_cinta.mp3',
            'explanation': 'Asmaradana biasanya bertemakan cinta dan asmara.'
          },
          {
            'type': 'fill_blank',
            'question': 'Guru wilangan tembang Maskumambang adalah?',
            'options': ['12, 6, 8, 8', '8, 8, 8, 8', '10, 6, 10, 6', '12, 8, 8, 8'],
            'correct': '12, 6, 8, 8',
            'explanation': 'Tembang Maskumambang memiliki guru wilangan 12, 6, 8, 8.',
            'has_sound': true,
            'sound': 'maskumambang_wilangan.mp3'
          },
          {
            'type': 'multiple_choice',
            'question': 'Serat Wedhatama ditulis oleh?',
            'options': ['KGPAA Mangkunegara IV', 'Ronggowarsito', 'Yasadipura I', 'Pakubuwono IV'],
            'correct': 'KGPAA Mangkunegara IV',
            'explanation': 'Serat Wedhatama ditulis oleh KGPAA Mangkunegara IV.',
            'has_sound': true,
            'sound': 'wedhatama.mp3'
          },
        ];

      default:
        return [];
    }
  }

  Future<void> _playSound(String soundFile) async {
    try {
      setState(() {
      });

      _bounceController.forward().then((_) => _bounceController.reverse());

      await _audioPlayer.setAsset('assets/sounds/$soundFile');      await _audioPlayer.play();
      await Future.delayed(const Duration(milliseconds: 500));

      setState(() {
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.volume_up, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text('Memutar audio: $soundFile'),
              ],
            ),
            backgroundColor: const Color(0xFF5D3A1D),
            duration: const Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      }
    } catch (e) {
      setState(() {
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.volume_off, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text('Audio tidak tersedia: $soundFile'),
              ],
            ),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      }
    }
  }

  void _selectAnswer(String answer) {
    if (_isAnswered) return;

    setState(() {
      _selectedAnswer = answer;
      _isAnswered = true;
    });

    final currentQuestion = _questions[_currentQuestionIndex];
    final isCorrect = answer == currentQuestion['correct'];

    if (isCorrect) {
      _score++;
      _showFeedback(true, currentQuestion['explanation']);
    } else {
      _lives--;
      _heartController.forward().then((_) => _heartController.reverse());
      _showFeedback(false, currentQuestion['explanation']);
    }

    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) {
        _nextQuestion();
      }
    });
  }

  void _showFeedback(bool isCorrect, String explanation) {
    final color = isCorrect ? Colors.green : Colors.red;
    final message = isCorrect ? 'Benar! 🎉' : 'Salah! 😔';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 4),
            Text(
              explanation,
              style: const TextStyle(fontFamily: 'Poppins'),
            ),
          ],
        ),
        backgroundColor: color,
        duration: const Duration(milliseconds: 2500),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _nextQuestion() {
    if (_lives <= 0) {
      _showGameOverDialog();
      return;
    }

    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _isAnswered = false;
        _selectedAnswer = null;
        _userMatches.clear();
        _selectedLeftItem = null;
        _selectedRightItem = null;
        _availableWords.clear();
        _arrangedWords.clear();
      });
      _progressController.animateTo((_currentQuestionIndex + 1) / _questions.length);
    } else {
      _showCompletionDialog();
    }
  }

  void _showGameOverDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Game Over',
          textAlign: TextAlign.center,
          style: TextStyle(fontFamily: 'Poppins'),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.sentiment_dissatisfied, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Skor Anda: $_score/${_questions.length}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Jangan menyerah! Coba lagi untuk hasil yang lebih baik.',
              textAlign: TextAlign.center,
              style: TextStyle(fontFamily: 'Poppins'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _restartQuiz();
            },
            child: const Text('Coba Lagi'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Kembali'),
          ),
        ],
      ),
    );
  }

  void _showCompletionDialog() {
    final percentage = (_score / _questions.length * 100).round();
    String? earnedTitle;

    if (percentage == 100) {
      earnedTitle = _getTitleForModule(widget.moduleType);
      _saveEarnedTitle(earnedTitle);
    }

    _saveQuizResult();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ChallengeResultScreen(
          moduleType: widget.moduleType,
          score: _score,
          totalQuestions: _questions.length,
          percentage: percentage,
          earnedTitle: earnedTitle,
        ),
      ),
    );
  }

  String _getTitleForModule(String moduleType) {
    switch (moduleType) {
      case 'aksara_jawa':
        return 'Pendekar Aksara';
      case 'bahasa_krama':
        return 'Pendekar Krama';
      case 'sastra_indonesia':
        return 'Pendekar Sastra';
      case 'sastra_jawa':
        return 'Pendekar Tembang';
      default:
        return 'Pendekar Jawa';
    }
  }

  Future<void> _saveEarnedTitle(String title) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final titlesJson = prefs.getString('earned_titles') ?? '[]';
      final titles = json.decode(titlesJson) as List;

      if (!titles.contains(title)) {
        titles.add(title);
        await prefs.setString('earned_titles', json.encode(titles));
      }
    } catch (e) {
      print('Error saving earned title: $e');
    }
  }

  Future<void> _saveQuizResult() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getString('quiz_history') ?? '[]';
      final history = json.decode(historyJson) as List;

      final result = {
        'module': widget.moduleType,
        'score': _score,
        'total': _questions.length,
        'percentage': (_score / _questions.length * 100).round(),
        'date': DateTime.now().toString(),
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };

      history.add(result);
      await prefs.setString('quiz_history', json.encode(history));

      final currentProgress = prefs.getDouble('progress_${widget.moduleType}') ?? 0.0;
      final newProgress = (currentProgress + 0.1).clamp(0.0, 1.0);
      await prefs.setDouble('progress_${widget.moduleType}', newProgress);
    } catch (e) {
      print('Error saving quiz result: $e');
    }
  }

  void _restartQuiz() {
    setState(() {
      _currentQuestionIndex = 0;
      _score = 0;
      _lives = 3;
      _isAnswered = false;
      _selectedAnswer = null;
      _userMatches.clear();
      _selectedLeftItem = null;
      _selectedRightItem = null;
      _availableWords.clear();
      _arrangedWords.clear();
    });
    _progressController.reset();
    _loadQuestions();
  }

  @override
  Widget build(BuildContext context) {
    if (_questions.isEmpty) {
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF8B4513), Color(0xFF5D3A1D)],
            ),
          ),
          child: const Center(
            child: CircularProgressIndicator(color: Colors.white),
          ),
        ),
      );
    }

    final currentQuestion = _questions[_currentQuestionIndex];

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF4E342E), Color(0xFF3E2723)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Container(
          color: Colors.black.withOpacity(0.3),
          child: SafeArea(
            child: Column(
              children: [
                // Header with progress and lives
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.arrow_back, color: Colors.white),
                          ),
                          Expanded(
                            child: Text(
                              'Piwulang - ${_currentQuestionIndex + 1}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Poppins',
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Row(
                            children: List.generate(3, (index) {
                              return AnimatedBuilder(
                                animation: _heartController,
                                builder: (context, child) {
                                  return Transform.scale(
                                    scale: index >= _lives ? 0.5 + (_heartController.value * 0.5) : 1.0,
                                    child: Icon(
                                      Icons.favorite,
                                      color: index < _lives ? Colors.red : Colors.grey,
                                      size: 24,
                                    ),
                                  );
                                },
                              );
                            }),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      AnimatedBuilder(
                        animation: _progressAnimation,
                        builder: (context, child) {
                          return LinearProgressIndicator(
                            value: _progressAnimation.value,
                            backgroundColor: Colors.white.withOpacity(0.3),
                            valueColor: const AlwaysStoppedAnimation<Color>(Colors.orange),
                            minHeight: 8,
                          );
                        },
                      ),
                    ],
                  ),
                ),

                // Main content area
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Question counter
                          Text(
                            'Soal ${_currentQuestionIndex + 1} dari ${_questions.length}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                              fontFamily: 'Poppins',
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Question with audio capability (no visible icon)
                          GestureDetector(
                            onTap: () {
                              if (currentQuestion['has_sound'] == true &&
                                  currentQuestion['sound'] != null) {
                                _playSound(currentQuestion['sound']);
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: currentQuestion['has_sound'] == true
                                    ? Colors.blue.withOpacity(0.05)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                                border: currentQuestion['has_sound'] == true
                                    ? Border.all(color: Colors.blue.withOpacity(0.2), width: 1)
                                    : null,
                              ),
                              child: Text(
                                currentQuestion['question'],
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF3E2723),
                                  fontFamily: 'Poppins',
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Answer options
                          Expanded(
                            child: _buildAnswerOptions(currentQuestion),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnswerOptions(Map<String, dynamic> question) {
    switch (question['type']) {
      case 'multiple_choice':
      case 'audio_choice':
      case 'fill_blank':
        return _buildMultipleChoiceOptions(question);
      case 'matching':
        _initializeMatchingGame(question['pairs']);
        return _buildEnhancedMatchingOptions(question['pairs']);
      case 'audio_word_arrangement':
        _initializeWordArrangement(question);
        return _buildWordArrangementOptions(question);
      default:
        return const SizedBox();
    }
  }

  void _initializeMatchingGame(List<Map<String, dynamic>> pairs) {
    if (_leftItems.isEmpty && _rightItems.isEmpty) {
      for (var pair in pairs) {
        final leftKey = pair.keys.first;
        final rightKey = pair.keys
            .where((key) => key != leftKey && !key.contains('audio') && !key.contains('has_sound'))
            .first;
        _leftItems.add(pair[leftKey]!);
        _rightItems.add(pair[rightKey]!);
        _correctMatches[pair[leftKey]!] = pair[rightKey]!;
      }
      _rightItems.shuffle();
    }
  }

  void _initializeWordArrangement(Map<String, dynamic> question) {
    if (_availableWords.isEmpty) {
      _availableWords = List<String>.from(question['words']);
      _availableWords.shuffle(); // Shuffle to make it challenging
      _arrangedWords.clear();
    }
  }

  Widget _buildMultipleChoiceOptions(Map<String, dynamic> question) {
    final options = question['options'];
    final optionSounds = question['option_sounds'] as List<String>?;

    return ListView.builder(
      itemCount: options.length,
      itemBuilder: (context, index) {
        final option = options[index];
        final optionText = option is Map ? option['text'] : option;
        final isSelected = _selectedAnswer == optionText;
        final isCorrect = optionText == question['correct'];
        final hasOptionSound = optionSounds != null && index < optionSounds.length;

        Color backgroundColor;
        Color textColor;
        Color borderColor;

        if (_isAnswered) {
          if (isSelected) {
            backgroundColor = isCorrect ? Colors.green.shade100 : Colors.red.shade100;
            textColor = isCorrect ? Colors.green.shade800 : Colors.red.shade800;
            borderColor = isCorrect ? Colors.green : Colors.red;
          } else if (isCorrect) {
            backgroundColor = Colors.green.shade100;
            textColor = Colors.green.shade800;
            borderColor = Colors.green;
          } else {
            backgroundColor = Colors.grey.shade100;
            textColor = Colors.grey.shade600;
            borderColor = Colors.grey.shade300;
          }
        } else {
          backgroundColor = isSelected ? Colors.blue.shade50 : Colors.white;
          textColor = const Color(0xFF3E2723);
          borderColor = isSelected ? Colors.blue : Colors.grey.shade300;
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: Material(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: _isAnswered
                  ? null
                  : () {
                if (hasOptionSound) {
                  _playSound(optionSounds![index]);
                }
                _selectAnswer(optionText);
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: borderColor, width: 2),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected ? borderColor : Colors.transparent,
                        border: Border.all(color: borderColor, width: 2),
                      ),
                      child: isSelected
                          ? const Icon(Icons.check, color: Colors.white, size: 16)
                          : null,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        optionText,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: textColor,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                    if (_isAnswered && isCorrect) ...[
                      const SizedBox(width: 8),
                      const Icon(Icons.check_circle, color: Colors.green),
                    ] else if (_isAnswered && isSelected && !isCorrect) ...[
                      const SizedBox(width: 8),
                      const Icon(Icons.cancel, color: Colors.red),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEnhancedMatchingOptions(List<Map<String, dynamic>> pairs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Ketuk untuk mendengar suara, lalu pilih pasangan yang tepat!',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
            fontWeight: FontWeight.w500,
            fontFamily: 'Poppins',
          ),
        ),
        const SizedBox(height: 16),

        Expanded(
          child: Stack(
            children: [
              CustomPaint(
                size: Size.infinite,
                painter: EnhancedConnectionPainter(
                  userMatches: _userMatches,
                  leftItems: _leftItems,
                  rightItems: _rightItems,
                  selectedLeftItem: _selectedLeftItem,
                  selectedRightItem: _selectedRightItem,
                  magnetAnimation: _magnetAnimation,
                ),
              ),

              Row(
                children: [
                  // Left column
                  Expanded(
                    child: Column(
                      children: List.generate(_leftItems.length, (index) {
                        final leftItem = _leftItems[index];
                        final isMatched = _userMatches.containsKey(leftItem);
                        final isSelected = _selectedLeftItem == leftItem;
                        final pair = pairs.firstWhere(
                                (p) => p.values.contains(leftItem),
                            orElse: () => <String, Object>{}
                        );
                        final hasSound = pair['has_sound'] == true;
                        final audioFile = hasSound ? pair['audio'] : null;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: Material(
                            color: isSelected
                                ? Colors.blue.shade200
                                : (isMatched ? Colors.blue.shade100 : Colors.white),
                            borderRadius: BorderRadius.circular(12),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () {
                                if (hasSound && audioFile != null) {
                                  _playSound(audioFile);
                                }

                                if (!isMatched) {
                                  setState(() {
                                    _selectedLeftItem = leftItem;

                                    if (_selectedLeftItem != null && _selectedRightItem != null) {
                                      _createMatch(_selectedLeftItem!, _selectedRightItem!);
                                      _selectedLeftItem = null;
                                      _selectedRightItem = null;
                                    }
                                  });
                                }
                              },
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isSelected
                                        ? Colors.blue.shade700
                                        : (isMatched ? Colors.blue : Colors.grey.shade300),
                                    width: isSelected ? 3 : 2,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        leftItem,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: isMatched
                                              ? Colors.blue.shade800
                                              : const Color(0xFF3E2723),
                                          fontFamily: 'Poppins',
                                        ),
                                      ),
                                    ),
                                    if (isMatched) ...[
                                      const Icon(Icons.link, color: Colors.blue, size: 20),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Right column
                  Expanded(
                    child: Column(
                      children: List.generate(_rightItems.length, (index) {
                        final rightItem = _rightItems[index];
                        final isMatched = _userMatches.containsValue(rightItem);
                        final isSelected = _selectedRightItem == rightItem;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: Material(
                            color: isSelected
                                ? Colors.green.shade200
                                : (isMatched ? Colors.green.shade100 : Colors.white),
                            borderRadius: BorderRadius.circular(12),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () {
                                if (!isMatched) {
                                  setState(() {
                                    _selectedRightItem = rightItem;

                                    if (_selectedLeftItem != null && _selectedRightItem != null) {
                                      _createMatch(_selectedLeftItem!, _selectedRightItem!);
                                      _selectedLeftItem = null;
                                      _selectedRightItem = null;
                                    }
                                  });
                                }
                              },
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isSelected
                                        ? Colors.green.shade700
                                        : (isMatched ? Colors.green : Colors.grey.shade300),
                                    width: isSelected ? 3 : 2,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        rightItem,
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: isMatched
                                              ? Colors.green.shade800
                                              : const Color(0xFF3E2723),
                                          fontFamily: 'Poppins',
                                        ),
                                      ),
                                    ),
                                    if (isMatched) ...[
                                      const Icon(Icons.link, color: Colors.green, size: 20),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        ElevatedButton(
          onPressed: _userMatches.length == _leftItems.length && !_isAnswered
              ? _checkMatchingAnswers
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF8B4513),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: Text(
            'Periksa Jawaban (${_userMatches.length}/${_leftItems.length})',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildWordArrangementOptions(Map<String, dynamic> question) {
    return Column(
      children: [
        // Audio instruction
        GestureDetector(
          onTap: () {
            if (question['has_sound'] == true && question['sound'] != null) {
              _playSound(question['sound']);
            }
          },
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.headphones, color: Colors.blue),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Ketuk untuk mendengar kalimat, lalu susun kata-kata di bawah!',
                    style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Available words
        Container(
          height: 100,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.withOpacity(0.3)),
          ),
          child: _availableWords.isEmpty
              ? const Center(
            child: Text(
              'Semua kata telah digunakan',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          )
              : Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _availableWords.map((word) => Draggable<String>(
              data: word,
              feedback: Material(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    word,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
              childWhenDragging: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  word,
                  style: TextStyle(color: Colors.grey[400], fontSize: 16),
                ),
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue),
                ),
                child: Text(
                  word,
                  style: const TextStyle(color: Colors.blue, fontSize: 16),
                ),
              ),
            )).toList(),
          ),
        ),

        const SizedBox(height: 16),

        // Drop zone
        DragTarget<String>(
          onAccept: (word) {
            setState(() {
              _arrangedWords.add(word);
              _availableWords.remove(word);

              // Check  {
              _arrangedWords.add(word);
              _availableWords.remove(word);

              // Check if arrangement is complete
              if (_availableWords.isEmpty) {
                _checkWordArrangement(_arrangedWords, question);
              }
            });
          },
          builder: (context, candidateData, rejectedData) {
            return Container(
              width: double.infinity,
              height: 100,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: candidateData.isNotEmpty ? Colors.green : Colors.green.withOpacity(0.3),
                  width: candidateData.isNotEmpty ? 3 : 1,
                ),
              ),
              child: _arrangedWords.isEmpty
                  ? const Center(
                child: Text(
                  'Letakkan kata-kata di sini',
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
              )
                  : Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _arrangedWords.asMap().entries.map((entry) {
                  final index = entry.key;
                  final word = entry.value;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _arrangedWords.removeAt(index);
                        _availableWords.add(word);
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        word,
                        style: const TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  );
                }).toList(),
              ),
            );
          },
        ),

        const SizedBox(height: 16),

        // Reset button
        if (_arrangedWords.isNotEmpty)
          ElevatedButton(
            onPressed: () {
              setState(() {
                _availableWords.addAll(_arrangedWords);
                _arrangedWords.clear();
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey,
              foregroundColor: Colors.white,
            ),
            child: const Text('Reset'),
          ),
      ],
    );
  }

  void _createMatch(String leftItem, String rightItem) {
    setState(() {
      _userMatches[leftItem] = rightItem;
    });

    _magnetController.forward().then((_) => _magnetController.reverse());
    _playSound('match.mp3');
  }

  void _checkWordArrangement(List<String> arrangedWords, Map<String, dynamic> question) {
    final correctOrder = List<String>.from(question['correct_order']);
    final isCorrect = arrangedWords.length == correctOrder.length &&
        arrangedWords.asMap().entries.every((entry) => entry.value == correctOrder[entry.key]);

    if (isCorrect) {
      _score++;
      _playSound('correct.mp3');
      _showFeedback(true, question['explanation']);
    } else {
      _lives--;
      _heartController.forward().then((_) => _heartController.reverse());
      _playSound('incorrect.mp3');
      _showFeedback(false, question['explanation']);
    }

    setState(() {
      _isAnswered = true;
    });

    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) {
        _nextQuestion();
      }
    });
  }

  void _checkMatchingAnswers() {
    bool allCorrect = true;
    for (var entry in _userMatches.entries) {
      if (_correctMatches[entry.key] != entry.value) {
        allCorrect = false;
        break;
      }
    }

    setState(() {
      _isAnswered = true;
    });

    if (allCorrect) {
      _score++;
      _playSound('correct.mp3');
      _showFeedback(true, _questions[_currentQuestionIndex]['explanation']);
    } else {
      _lives--;
      _heartController.forward().then((_) => _heartController.reverse());
      _playSound('incorrect.mp3');
      _showFeedback(false, _questions[_currentQuestionIndex]['explanation']);
    }

    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) {
        _nextQuestion();
      }
    });
  }
}

// Enhanced connection painter with cleaner cable connections
class EnhancedConnectionPainter extends CustomPainter {
  final Map<String, String> userMatches;
  final List<String> leftItems;
  final List<String> rightItems;
  final String? selectedLeftItem;
  final String? selectedRightItem;
  final Animation<double> magnetAnimation;

  EnhancedConnectionPainter({
    required this.userMatches,
    required this.leftItems,
    required this.rightItems,
    this.selectedLeftItem,
    this.selectedRightItem,
    required this.magnetAnimation,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Draw connection lines for matched items with cleaner curves
    for (var entry in userMatches.entries) {
      final leftIndex = leftItems.indexOf(entry.key);
      final rightIndex = rightItems.indexOf(entry.value);

      if (leftIndex != -1 && rightIndex != -1) {
        final itemHeight = size.height / leftItems.length;
        final leftY = (leftIndex + 0.5) * itemHeight;
        final rightY = (rightIndex + 0.5) * itemHeight;

        paint.color = Colors.blue.withOpacity(0.8);

        final startPoint = Offset(size.width * 0.48, leftY);
        final endPoint = Offset(size.width * 0.52, rightY);

        // Create smoother bezier curve
        final controlPoint1 = Offset(size.width * 0.5, leftY);
        final controlPoint2 = Offset(size.width * 0.5, rightY);

        final path = Path()
          ..moveTo(startPoint.dx, startPoint.dy)
          ..cubicTo(
            controlPoint1.dx, controlPoint1.dy,
            controlPoint2.dx, controlPoint2.dy,
            endPoint.dx, endPoint.dy,
          );

        canvas.drawPath(path, paint);

        // Draw enhanced arrow head
        _drawEnhancedArrowHead(canvas, startPoint, endPoint, paint);

        // Draw magnet effect with pulsing animation
        if (magnetAnimation.value > 0) {
          final magnetPaint = Paint()
            ..color = Colors.orange.withOpacity(magnetAnimation.value * 0.6)
            ..style = PaintingStyle.fill;

          final pulseRadius = 6 + (4 * magnetAnimation.value);
          canvas.drawCircle(startPoint, pulseRadius, magnetPaint);
          canvas.drawCircle(endPoint, pulseRadius, magnetPaint);
        }
      }
    }

    // Draw selection indicators with glow effect
    if (selectedLeftItem != null) {
      final leftIndex = leftItems.indexOf(selectedLeftItem!);
      if (leftIndex != -1) {
        final itemHeight = size.height / leftItems.length;
        final leftY = (leftIndex + 0.5) * itemHeight;
        final selectionPaint = Paint()
          ..color = Colors.blue.withOpacity(0.4)
          ..style = PaintingStyle.fill;

        canvas.drawCircle(Offset(size.width * 0.48, leftY), 8, selectionPaint);
      }
    }

    if (selectedRightItem != null) {
      final rightIndex = rightItems.indexOf(selectedRightItem!);
      if (rightIndex != -1) {
        final itemHeight = size.height / rightItems.length;
        final rightY = (rightIndex + 0.5) * itemHeight;
        final selectionPaint = Paint()
          ..color = Colors.green.withOpacity(0.4)
          ..style = PaintingStyle.fill;

        canvas.drawCircle(Offset(size.width * 0.52, rightY), 8, selectionPaint);
      }
    }
  }

  void _drawEnhancedArrowHead(Canvas canvas, Offset start, Offset end, Paint paint) {
    const arrowSize = 10.0;
    final direction = (end - start).direction;

    final arrowP1 = Offset(
      end.dx - arrowSize * cos(direction - pi / 6),
      end.dy - arrowSize * sin(direction - pi / 6),
    );

    final arrowP2 = Offset(
      end.dx - arrowSize * cos(direction + pi / 6),
      end.dy - arrowSize * sin(direction + pi / 6),
    );

    final arrowPath = Path()
      ..moveTo(end.dx, end.dy)
      ..lineTo(arrowP1.dx, arrowP1.dy)
      ..lineTo(arrowP2.dx, arrowP2.dy)
      ..close();

    paint.style = PaintingStyle.fill;
    canvas.drawPath(arrowPath, paint);
    paint.style = PaintingStyle.stroke;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Challenge Result Screen (keeping the existing implementation)
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

  void _launchURL(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        debugPrint('Tidak bisa membuka URL: $url');
      }
    } catch (e) {
      debugPrint('Error membuka URL: $e');
    }
  }


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
                        const SizedBox(height: 4),
                        Image.asset(
                          'assets/images/logo.png',
                          width: 60,
                          height: 60,
                          fit: BoxFit.contain,
                        )
                      ],
                    ),
                  ],
                ),
              ),

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
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: const [
                                Text(
                                  'Ayo ',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  'Sinau! ',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.normal,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  '->',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              'Tingali Sedoyo',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      ),


                      const SizedBox(height: 24),
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

        Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
          color: const Color(0xFF3E2723),
          borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [

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
          'Jl. Ketintang Wiyata Gedung A10, Ketintang, Gayungan,\nSurabaya, East Java 60231',
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
          showModalBottomSheet(
          context: context,
          shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          backgroundColor: const Color(0xFF5D3A1D),
          builder: (context) {
          return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const FaIcon(FontAwesomeIcons.instagram, color: Colors.white),
              title: const Text('Instagram', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                _launchURL('https://instagram.com/alfindsta_');
              },
            ),

            ListTile(
              leading: const FaIcon(FontAwesomeIcons.whatsapp, color: Colors.white),
              title: const Text('WhatsApp', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);

                final phone = '6285253341121';
                final message = Uri.encodeComponent("Halo, saya ingin bertanya tentang program Sandya Nusantara.");
                final waUrl = "https://wa.me/$phone?text=$message";
                _launchURL(waUrl);
              },
            ),

            ListTile(
              leading: const FaIcon(FontAwesomeIcons.locationDot, color: Colors.white),
              title: const Text('Location', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                _launchURL('https://maps.google.com/?q=Ketintang+Wiyata+Gedung+A10+Surabaya');
              },
            ),
          ],
          );
          },
          );
          },
          ),
          ],
          ),
          )
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
    Navigator.pushNamed(context, '/challenge', arguments: moduleType);
  }

  void _navigateToMainMenu(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/main',
          (route) => false,
    );
  }

  void _navigateToChallengeHistory(BuildContext context) {
    Navigator.pushNamed(context, '/challenge_history');
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
}