import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

class LearningActivityScreen extends StatefulWidget {
  final String moduleType;

  const LearningActivityScreen({
    Key? key,
    required this.moduleType,
  }) : super(key: key);

  @override
  State<LearningActivityScreen> createState() => _LearningActivityScreenState();
}

class _LearningActivityScreenState extends State<LearningActivityScreen> {
  bool _isReading = false;
  bool _isExpanded = false;
  Timer? _readingTimer;
  double _progress = 0.0;
  final ScrollController _scrollController = ScrollController();
  int _readingTimeSeconds = 0;
  Timer? _progressTimer;
  PageController _videoPageController = PageController();

  @override
  void initState() {
    super.initState();
    _loadProgress();
    _videoPageController = PageController();
  }

  @override
  void dispose() {
    _readingTimer?.cancel();
    _progressTimer?.cancel();
    _scrollController.dispose();
    _videoPageController.dispose();
    super.dispose();
  }

  Future<void> _loadProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final progress = prefs.getDouble('progress_${widget.moduleType}') ?? 0.0;
      setState(() {
        _progress = progress;
      });
    } catch (e) {
      print('Error loading progress: $e');
    }
  }

  Future<void> _saveProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('progress_${widget.moduleType}', _progress);
    } catch (e) {
      print('Error saving progress: $e');
    }
  }

  void _startReadingTracking() {
    if (_isReading) return;

    setState(() {
      _isReading = true;
      _readingTimeSeconds = 0;
    });

    _progressTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _readingTimeSeconds++;
      });

      if (_readingTimeSeconds % 60 == 0) {
        setState(() {
          _progress += 0.10;
          if (_progress > 1.0) {
            _progress = 1.0;
          }
        });
        _saveProgress();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Progress bertambah 10%! Total: ${(_progress * 100).toInt()}%'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    });
  }

  void _stopReadingTracking() {
    setState(() {
      _isReading = false;
    });
    _progressTimer?.cancel();
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
    });

    if (_isExpanded) {
      _startReadingTracking();
    } else {
      _stopReadingTracking();
    }
  }

  @override
  Widget build(BuildContext context) {
    String title = '';
    Widget content = Container();

    switch (widget.moduleType) {
      case 'aksara_jawa':
        title = 'AKSARA JAWA';
        content = _buildAksaraJawaContent();
        break;
      case 'bahasa_krama':
        title = 'BAHASA KRAMA';
        content = _buildBahasaKramaContent();
        break;
      case 'sastra_indonesia':
        title = 'SASTRA INDONESIA';
        content = _buildSastraIndonesiaContent();
        break;
      case 'sastra_jawa':
        title = 'SASTRA JAWA';
        content = _buildSastraJawaContent();
        break;
      default:
        title = 'MATERI PEMBELAJARAN';
        content = const Center(
          child: Text(
            'Materi belum tersedia',
            style: TextStyle(color: Colors.white),
          ),
        );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF2D1607),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2D1607),
        elevation: 0,
        title: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'AYO SINAU',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
            const Spacer(),
            // Progress indicator
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${(_progress * 100).toInt()}%',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(
                Icons.arrow_forward_ios,
                color: Colors.red,
              ),
              onPressed: () {
                Navigator.pushNamed(context, '/quiz', arguments: widget.moduleType);
              },
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            _stopReadingTracking();
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: content,
      ),
      bottomNavigationBar: Container(
        height: 80,
        color: const Color(0xFF2D1607),
        child: Column(
          children: [
            // Reading time indicator
            if (_isReading) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                color: Colors.green.withOpacity(0.8),
                child: Text(
                  'Waktu membaca: ${_readingTimeSeconds ~/ 60}:${(_readingTimeSeconds % 60).toString().padLeft(2, '0')} - Progress akan bertambah setiap 2 menit',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
            const Divider(
              color: Colors.white24,
              height: 1,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  children: [
                    Image.asset(
                      'assets/logo/logo.png',
                      width: 40,
                      height: 40,
                      errorBuilder: (context, error, stackTrace) => Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.white, width: 1)
                          ),
                          child: Icon(Icons.school, color: Colors.white)
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'SANDYA NUSANTARA',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'KANTOR: Jl. Ketintang Wiyata Gedung A10',
                            style: TextStyle(
                              fontSize: 8,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.chat,
                        color: Colors.white,
                      ),
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

  Widget _buildExpandableContent(String title, String shortContent, String fullContent) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                  decoration: TextDecoration.underline,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _isExpanded ? fullContent : shortContent,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: _toggleExpanded,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _isExpanded ? 'Tutup' : 'Baca Selengkapnya',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  color: Colors.white,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAksaraJawaContent() {
    const shortContent = 'Aksara Jawa utawa sing keren diarani Hanacaraka, iku salah sawijining sistem tulisan tradisional sing digunakake kanggo nulis basa Jawa...';
    const fullContent = '''Aksara Jawa utawa sing keren diarani Hanacaraka, iku salah sawijining sistem tulisan tradisional sing digunakake kanggo nulis basa Jawa. Aksara iki asale saka aksara Brahmi sing berkembang ing India lan duwé gegayutan raket karo aksara Kawi sing dienggo ing jaman kerajaan-kerajaan Hindu-Budha ing Nusantara. Béreng lumakune jaman, aksara iki ngalami rupa-rupa modifikasi lan dadi sistem tulisan utama ing macem-macem naskah kuna Jawa, kayata babat, serat, lan manuskrip sastra liyane.''';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildExpandableContent('DEFINISI AKSARA JAWA', shortContent, fullContent),
        const SizedBox(height: 16),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            'AKSARA JAWA DASAR',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
        ),
        // Aksara Jawa Basic Grid with white background
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              _buildAksaraGrid(),
              const SizedBox(height: 20),
              _buildAksaraPasangan(),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Long text explanation
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Aksara Jawa iku sistem tulisan tradisional sing dienggo kanggo nulis basa Jawa lan nduweni ciri khas unik kaya aksara dhasar (carakan), sandhangan, pasangan, lan aksara angka. Aksara dhasar kasusun saka 20 huruf, kaya tha (ꦛ), nga (ꦔ), ma (ꦩ), ga (ꦒ), ba (ꦧ), tha (ꦛ), lan sapanunggale. Sing saben-saben nduweni vokal bawahan "a". Sandhangan digunakake kanggo ngganti vokal "a" dadi nduweni vokal liyane. Saka aksara sepasang supaya bisa nggabung langsung marang aksara sadurunge, kaya ing tembung "kulak" (ꦏꦸꦭꦏ꧀) ing lembaran. "Panjingan" digunakake supaya "r" dadi nduweni vokal. Saliyane kuwi, aksara angka Jawa nduweni lambang khas kaya ing (0), m (1), n (2), lan sateruse, sing dienggo kanggo nulis angka. Wong bisa maca lan nulis kanggo aksara Jawa kanthi bener lan jangkep.',
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white,
            ),
          ),
        ),

        // Task section
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Tuladha:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Tulis tembung Cahaya Nusantara nganggo aksara Jawa',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.orange,
                  fontStyle: FontStyle.italic,
                ),
              ),
              Text(
                'Wangsulan: pasangan jegogan',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),

        // Video Learning Section
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'SINAU LEWAT VIDEO',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),

        // Video thumbnails in horizontal scrollview
        Container(
          height: 110,
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: PageView(
            controller: _videoPageController,
            children: [
              _buildVideoThumbnail(
                'AKSARA JAWA #23 - Latihan',
                'Menulis Pasangan & Sandangan',
                'assets/videos/aksara1.jpg',
              ),
              _buildVideoThumbnail(
                'Belajar Aksara Jawa',
                'Pengenalan Huruf Dasar',
                'assets/videos/aksara2.jpg',
              ),
              _buildVideoThumbnail(
                'AKSARA JAWA - Pasangan Huruf',
                'Latihan Menulis',
                'assets/videos/aksara3.jpg',
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Daily Challenge Section
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'TANTANGAN HARIAN',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.brown.shade800,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Endi susunan ulang tembung Raja Wisesa ing aksara Jawa nganggo pasangan sing bener?',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _ChallengeOption(
                          text: 'ꦫꦗꦮꦶꦱꦺꦱ',
                          isCorrect: false,
                        ),
                        _ChallengeOption(
                          text: 'ꦫꦗꦮꦶꦯꦺꦯ',
                          isCorrect: true,
                        ),
                        _ChallengeOption(
                          text: 'ꦫꦰꦮꦶꦱꦺꦱ',
                          isCorrect: false,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildBahasaKramaContent() {
    const shortContent = 'Basa Krama utawa Basa Alus yaiku salah sawijining tingkatan basa Jawa sing digunakake kanggo ngurmati wong sing luwih tuwa...';
    const fullContent = '''Basa Krama utawa Basa Alus yaiku salah sawijining tingkatan basa Jawa sing digunakake kanggo ngurmati wong sing luwih tuwa utawa wong sing nduweni status sosial luwih dhuwur. Basa Krama iki minangka wujud unggah-ungguh ing budaya Jawa sing isih diugemi nganti saiki. Basa Krama diperang dadi telung tingkatan, yaiku Krama Ngoko, Krama Madya, lan Krama Inggil.

Unggah-ungguh basa Jawa iki nduweni fungsi sosial sing wigati banget ing masyarakat Jawa. Kanthi nggunakake basa Krama, wong Jawa nuduhake rasa hormat lan sopan santun marang wong liya. Iki uga minangka cara kanggo njaga harmoni sosial lan nglestarekake nilai-nilai budaya Jawa sing adiluhung.''';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildExpandableContent('DEFINISI BAHASA KRAMA', shortContent, fullContent),
        const SizedBox(height: 16),

        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            'BASA KRAMA INGGIL',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
        ),

        // Bahasa Krama Table with white background
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: _buildKramaTable(),
        ),

        // Long text explanation
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Basa Krama utawa Basa Alus minangka bentuk unggah-ungguh lan tatakrama ing budaya Jawa. Basa iki digunakake nalika ngomong karo wong sing luwih tuwa, wong sing luwih dhuwur pangkate, utawa wong sing durung akrab. Ana telung tingkatan basa Jawa, yaiku Ngoko (digunakake antarane kanca sebaya), Krama Madya (tengah-tengah, rada alus), lan Krama Inggil (paling alus, kanggo ngurmati banget).',
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white,
            ),
          ),
        ),

        // Video Learning Section
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'SINAU LEWAT VIDEO',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),

        // Video thumbnails in horizontal scrollview
        Container(
          height: 110,
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: PageView(
            children: [
              _buildVideoThumbnail(
                'Basa Krama Inggil',
                'Tata Cara Penggunaan',
                'assets/videos/krama1.jpg',
              ),
              _buildVideoThumbnail(
                'Percakapan Basa Krama',
                'Contoh Penerapan',
                'assets/videos/krama2.jpg',
              ),
              _buildVideoThumbnail(
                'Panduan Basa Alus',
                'Untuk Pemula',
                'assets/videos/krama3.jpg',
              ),
            ],
          ),
        ),

        // Daily Challenge Section
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'TANTANGAN HARIAN',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.brown.shade800,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Kalimat "Ayo tuku sega" ing basa krama inggil sing bener yaiku?',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _ChallengeOption(
                          text: 'Mangga mundhut sekul',
                          isCorrect: true,
                        ),
                        _ChallengeOption(
                          text: 'Mangga tumbas sega',
                          isCorrect: false,
                        ),
                        _ChallengeOption(
                          text: 'Sumangga tumbas sekul',
                          isCorrect: false,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildSastraIndonesiaContent() {
    const shortContent = 'Sastra Indonesia adalah karya tulis yang jika dibandingkan dengan karya tulis lain memiliki berbagai ciri keunggulan...';
    const fullContent = '''Sastra Indonesia adalah karya tulis yang jika dibandingkan dengan karya tulis lain memiliki berbagai ciri keunggulan seperti keaslian, keartistikan, serta keindahan dalam isi dan ungkapannya. Sastra Indonesia merupakan hasil karya sastra yang ditulis dalam bahasa Indonesia dan mengandung nilai-nilai budaya, sosial, dan sejarah bangsa Indonesia.

Perkembangan sastra Indonesia dapat dibagi menjadi beberapa periode, mulai dari sastra lama (sebelum abad ke-20), sastra modern (abad ke-20), hingga sastra kontemporer (abad ke-21). Setiap periode memiliki karakteristik dan ciri khas tersendiri yang mencerminkan kondisi sosial, politik, dan budaya pada masanya.''';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildExpandableContent('DEFINISI SASTRA INDONESIA', shortContent, fullContent),
        const SizedBox(height: 16),

        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            'PERIODISASI SASTRA INDONESIA',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
        ),

        // Sastra Indonesia Table with white background
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: _buildSastraIndonesiaTable(),
        ),

        // Long text explanation
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Sastra Indonesia memiliki peran penting dalam pembentukan identitas bangsa dan pelestarian nilai-nilai budaya. Melalui karya sastra, para pengarang dapat mengekspresikan kritik sosial, aspirasi masyarakat, dan pandangan tentang masa depan bangsa. Sastra Indonesia telah berkembang dari masa ke masa, merefleksikan perubahan sosial, politik, dan budaya yang terjadi di Indonesia.',
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white,
            ),
          ),
        ),

        // Video Learning Section
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'SINAU LEWAT VIDEO',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),

        // Video thumbnails in horizontal scrollview
        Container(
          height: 110,
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: PageView(
            children: [
              _buildVideoThumbnail(
                'Sejarah Sastra Indonesia',
                'Perkembangan dari Masa ke Masa',
                'assets/videos/sastra1.jpg',
              ),
              _buildVideoThumbnail(
                'Analisis Karya Sastra',
                'Teknik dan Metode',
                'assets/videos/sastra2.jpg',
              ),
              _buildVideoThumbnail(
                'Sastra Kontemporer',
                'Perkembangan Terbaru',
                'assets/videos/sastra3.jpg',
              ),
            ],
          ),
        ),

        // Daily Challenge Section
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'TANTANGAN HARIAN',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.brown.shade800,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Siapakah penulis novel "Tenggelamnya Kapal Van Der Wijck"?',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _ChallengeOption(
                          text: 'Pramoedya Ananta Toer',
                          isCorrect: false,
                        ),
                        _ChallengeOption(
                          text: 'HAMKA',
                          isCorrect: true,
                        ),
                        _ChallengeOption(
                          text: 'Chairil Anwar',
                          isCorrect: false,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildSastraJawaContent() {
    const shortContent = 'Sastra Jawa yaiku karya tulis sing nggunakake basa Jawa lan ngandhut nilai-nilai budaya, sosial, lan sejarah masyarakat Jawa...';
    const fullContent = '''Sastra Jawa yaiku karya tulis sing nggunakake basa Jawa lan ngandhut nilai-nilai budaya, sosial, lan sejarah masyarakat Jawa. Sastra Jawa wis ana wiwit jaman Mataram Kuna lan terus berkembang nganti saiki. Sastra Jawa nduweni maneka warna jinis, kayata tembang, geguritan, parikan, lan serat.

Sastra Jawa klasik biasane awujud tembang macapat, serat, lan kidung sing ngandhut piwulang moral lan spiritual. Dene sastra Jawa modern luwih bebas lan ekspresif, kaya geguritan lan crita cekak sing nggunakake basa Jawa kontemporer.''';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildExpandableContent('DEFINISI SASTRA JAWA', shortContent, fullContent),
        const SizedBox(height: 16),

        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            'JENIS-JENIS TEMBANG MACAPAT',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
        ),

        // Sastra Jawa Table with white background
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: _buildSastraJawaTable(),
        ),

        // Long text explanation
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Nilai-nilai sing ana ing sastra Jawa antara liyane yaiku tepa slira, gotong royong, lan harmoni karo alam. Sastra Jawa uga dadi sarana kanggo nularake kawruh lan piwulang marang generasi mudha supaya tetep njaga lan nglestarekake budaya Jawa. Sastra Jawa isih relevan ing jaman modern amarga ngandhut nilai-nilai universal sing bisa ditrapake ing urip padinan.',
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white,
            ),
          ),
        ),

        // Video Learning Section
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'SINAU LEWAT VIDEO',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),

        // Video thumbnails in horizontal scrollview
        Container(
          height: 110,
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: PageView(
            children: [
              _buildVideoThumbnail(
                'Tembang Macapat',
                'Cara Nembang sing Bener',
                'assets/videos/sastra_jawa1.jpg',
              ),
              _buildVideoThumbnail(
                'Geguritan Jawa',
                'Teknik Nulis lan Macakake',
                'assets/videos/sastra_jawa2.jpg',
              ),
              _buildVideoThumbnail(
                'Parikan lan Wangsalan',
                'Contoh lan Maknane',
                'assets/videos/sastra_jawa3.jpg',
              ),
            ],
          ),
        ),

        // Daily Challenge Section
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'TANTANGAN HARIAN',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.brown.shade800,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tembang Pocung iku nduweni paugeran guru wilangan lan guru gatra pira?',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _ChallengeOption(
                          text: '12, 6, 8, 12',
                          isCorrect: false,
                        ),
                        _ChallengeOption(
                          text: '12, 6, 8, 8',
                          isCorrect: false,
                        ),
                        _ChallengeOption(
                          text: '4, 8, 12, 8',
                          isCorrect: true,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildVideoThumbnail(String title, String subtitle, String imagePath) {
    return Container(
      width: 150,
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white24),
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              imagePath,
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                color: Colors.grey.shade800,
                child: const Icon(Icons.movie, color: Colors.white, size: 40),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withOpacity(0.8),
                    Colors.transparent,
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(8),
                  bottomRight: Radius.circular(8),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.white70,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
          // Play button overlay
          Positioned.fill(
            child: Center(
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.play_arrow,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAksaraGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Center(
          child: Text(
            'ha na ca ra ka da ta sa wa la',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildAksaraItem('ꦲ', 'ha'),
            _buildAksaraItem('ꦤ', 'na'),
            _buildAksaraItem('ꦕ', 'ca'),
            _buildAksaraItem('ꦫ', 'ra'),
            _buildAksaraItem('ꦏ', 'ka'),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildAksaraItem('ꦢ', 'da'),
            _buildAksaraItem('ꦠ', 'ta'),
            _buildAksaraItem('ꦱ', 'sa'),
            _buildAksaraItem('ꦮ', 'wa'),
            _buildAksaraItem('ꦭ', 'la'),
          ],
        ),
        const SizedBox(height: 12),
        const Center(
          child: Text(
            'pa dha ja ya nya ma ga ba tha nga',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildAksaraItem('ꦥ', 'pa'),
            _buildAksaraItem('ꦝ', 'dha'),
            _buildAksaraItem('ꦗ', 'ja'),
            _buildAksaraItem('ꦪ', 'ya'),
            _buildAksaraItem('ꦚ', 'nya'),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildAksaraItem('ꦩ', 'ma'),
            _buildAksaraItem('ꦒ', 'ga'),
            _buildAksaraItem('ꦧ', 'ba'),
            _buildAksaraItem('ꦛ', 'tha'),
            _buildAksaraItem('ꦔ', 'nga'),
          ],
        ),
      ],
    );
  }

  Widget _buildAksaraItem(String aksara, String latin) {
    return Column(
      children: [
        Text(
          aksara,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          latin,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildAksaraPasangan() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Center(
          child: Text(
            'Pasangan Aksara Jawa',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  for (var i = 0; i < 5; i++)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text(
                            ['ꦲ꧀', 'ꦤ꧀', 'ꦕ꧀', 'ꦫ꧀', 'ꦏ꧀'][i],
                            style: const TextStyle(
                              fontSize: 20,
                              color: Colors.black,
                            ),
                          ),
                          Text(
                            ['ha', 'na', 'ca', 'ra', 'ka'][i],
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  for (var i = 0; i < 5; i++)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text(
                            ['ꦢ꧀', 'ꦠ꧀', 'ꦱ꧀', 'ꦮ꧀', 'ꦭ꧀'][i],
                            style: const TextStyle(
                              fontSize: 20,
                              color: Colors.black,
                            ),
                          ),
                          Text(
                            ['da', 'ta', 'sa', 'wa', 'la'][i],
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildKramaTable() {
    return Table(
      border: TableBorder.all(color: Colors.grey.shade300),
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: [
        TableRow(
          decoration: BoxDecoration(color: Colors.grey.shade200),
          children: const [
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('Ngoko', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('Krama Madya', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('Krama Inggil', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        const TableRow(
          children: [
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('Tuku'),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('Tumbas'),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('Mundhut'),
            ),
          ],
        ),
        const TableRow(
          children: [
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('Mangan'),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('Nedha'),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('Dhahar'),
            ),
          ],
        ),
        const TableRow(
          children: [
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('Omah'),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('Griya'),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('Dalem'),
            ),
          ],
        ),
        const TableRow(
          children: [
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('Turu'),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('Tilem'),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('Sare'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSastraIndonesiaTable() {
    return Table(
      border: TableBorder.all(color: Colors.grey.shade300),
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: [
        TableRow(
          decoration: BoxDecoration(color: Colors.grey.shade200),
          children: const [
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('Periode', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('Ciri Khas', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        const TableRow(
          children: [
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('Balai Pustaka\n(1920-1933)'),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('Tema tentang adat istiadat yang kaku, pertentangan nilai tradisional dan modern'),
            ),
          ],
        ),
        const TableRow(
          children: [
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('Pujangga Baru\n(1933-1942)'),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('Semangat nasionalisme, penggunaan bahasa yang indah dan romantis'),
            ),
          ],
        ),
        const TableRow(
          children: [
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('Angkatan 45\n(1942-1955)'),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('Tema revolusi dan kemerdekaan, bahasa yang lugas dan tegas'),
            ),
          ],
        ),
        const TableRow(
          children: [
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('Angkatan 66 - Kini'),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('Beragam tema sosial, politik, dan budaya, eksplorasi bentuk dan gaya'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSastraJawaTable() {
    return Table(
      border: TableBorder.all(color: Colors.grey.shade300),
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: [
        TableRow(
          decoration: BoxDecoration(color: Colors.grey.shade200),
          children: const [
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('Tembang', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('Guru Wilangan', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('Guru Lagu', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        const TableRow(
          children: [
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('Maskumambang'),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('12, 6, 8, 8'),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('i, a, i, a'),
            ),
          ],
        ),
        const TableRow(
          children: [
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('Pocung'),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('12, 6, 8, 12'),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('u, a, i, a'),
            ),
          ],
        ),
        const TableRow(
          children: [
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('Asmaradana'),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('8, 8, 8, 8, 7, 8, 8'),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('i, a, e, a, a, u, a'),
            ),
          ],
        ),
        const TableRow(
          children: [
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('Sinom'),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('8, 8, 8, 8, 7, 8, 7, 8, 12'),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('a, i, a, i, i, u, a, i, a'),
            ),
          ],
        ),
      ],
    );
  }

  void _playAksaraSound(String sound) {
    // Placeholder for audio playback
    // Will be implemented with actual audio files from assets/sounds/
    print('Playing sounds: $sound');

    // Show visual feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Memainkan suara: $sound'),
        duration: const Duration(milliseconds: 500),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _showAksaraDetail(Map<String, String> aksara) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Aksara ${aksara['latin']!.toUpperCase()}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              aksara['aksara']!,
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Color(0xFF3E2723),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Dibaca: ${aksara['latin']}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _playAksaraSound(aksara['sounds']!),
              icon: const Icon(Icons.volume_up),
              label: const Text('Putar Suara'),
            ),
          ],
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
}

class _ChallengeOption extends StatefulWidget {
  final String text;
  final bool isCorrect;

  const _ChallengeOption({
    Key? key,
    required this.text,
    required this.isCorrect,
  }) : super(key: key);

  @override
  State<_ChallengeOption> createState() => _ChallengeOptionState();
}

class _ChallengeOptionState extends State<_ChallengeOption> {
  bool _isSelected = false;
  bool _hasAnswered = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (_hasAnswered) return;

        setState(() {
          _isSelected = true;
          _hasAnswered = true;
        });

        if (widget.isCorrect) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Jawaban benar!'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Jawaban salah!'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: _isSelected
              ? widget.isCorrect
              ? Colors.green
              : Colors.red
              : Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          widget.text,
          style: TextStyle(
            fontSize: 10,
            color: _isSelected ? Colors.white : Colors.white,
            fontWeight: _isSelected && widget.isCorrect ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
