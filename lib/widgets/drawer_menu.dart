import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:convert';
import 'dart:io';
import 'package:timezone/timezone.dart' as tz;

class DrawerMenu extends StatefulWidget {
  final String userName;
  final String userEmail;
  final String userPhone;
  final String userAddress;
  final String userSchool;
  final String userClass;
  final Map<String, double> moduleProgress;
  final VoidCallback onUserDataUpdated;

  const DrawerMenu({
    Key? key,
    required this.userName,
    required this.userEmail,
    required this.userPhone,
    required this.userAddress,
    required this.userSchool,
    required this.userClass,
    required this.moduleProgress,
    required this.onUserDataUpdated, required String userProfileImage, required String userRanking, required List<String> earnedTitles, String? activeTitle, required Null Function(dynamic title) onTitleChanged,
  }) : super(key: key);

  @override
  State<DrawerMenu> createState() => _DrawerMenuState();
}

class _DrawerMenuState extends State<DrawerMenu> {
  String? _profileImagePath;
  List<String> _earnedTitles = [];
  String _currentRank = 'SD';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _profileImagePath = prefs.getString('profile_image_path');
        _currentRank = prefs.getString('user_rank') ?? _calculateRank();

        final titlesJson = prefs.getString('earned_titles') ?? '[]';
        _earnedTitles = List<String>.from(json.decode(titlesJson));
      });
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  String _calculateRank() {
    double totalProgress = widget.moduleProgress.values.fold(0.0, (sum, progress) => sum + progress);
    double averageProgress = totalProgress / widget.moduleProgress.length;

    if (averageProgress >= 0.8) return 'SMP';
    if (averageProgress >= 0.5) return 'SD Kelas 6';
    if (averageProgress >= 0.3) return 'SD Kelas 5';
    if (averageProgress >= 0.2) return 'SD Kelas 4';
    if (averageProgress >= 0.1) return 'SD Kelas 3';
    return 'SD Kelas 1';
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF5D3A1D),
              Color(0xFF8B4513),
            ],
          ),
        ),
        child: Column(
          children: [
            // Enhanced Header with profile photo
            Container(
              padding: const EdgeInsets.fromLTRB(16, 50, 16, 20),
              child: Column(
                children: [
                  // Profile Photo with edit option
                  GestureDetector(
                    onTap: _showProfilePhotoOptions,
                    child: Stack(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(40),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(40),
                            child: _profileImagePath != null
                                ? Image.file(
                              File(_profileImagePath!),
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => _buildDefaultAvatar(),
                            )
                                : _buildDefaultAvatar(),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              size: 16,
                              color: Color(0xFF5D3A1D),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // User info
                  Text(
                    widget.userName.isNotEmpty ? widget.userName : 'Pengguna',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),

                  if (widget.userEmail.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      widget.userEmail,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                  ],

                  // School and Class
                  if (widget.userSchool.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${widget.userSchool} ${widget.userClass.isNotEmpty ? '- Kelas ${widget.userClass}' : ''}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],

                  // Rank badge
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getRankColor(_currentRank),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Tingkat $_currentRank',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  // Current title display
                  if (_earnedTitles.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.amber,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _earnedTitles.last, // Show latest earned title
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Menu items
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  children: [
                    _buildMenuItem(
                      icon: Icons.person,
                      title: 'Profil Saya',
                      subtitle: 'Kelola informasi pribadi',
                      onTap: () {
                        Navigator.pop(context);
                        _showProfileDialog(context);
                      },
                    ),

                    _buildMenuItem(
                      icon: Icons.emoji_events,
                      title: 'Prestasi & Gelar',
                      subtitle: 'Lihat pencapaian dan gelar Anda',
                      badge: _earnedTitles.length.toString(),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const EnhancedAchievementsScreen()),
                        );
                      },
                    ),

                    _buildMenuItem(
                      icon: Icons.school,
                      title: 'Progress Sinau',
                      subtitle: 'Lihat kemajuan pembelajaran',
                      onTap: () {
                        Navigator.pop(context);
                        _showProgressDialog(context);
                      },
                    ),

                    _buildMenuItem(
                      icon: Icons.leaderboard,
                      title: 'Ranking Tingkat',
                      subtitle: 'SD Kelas 1 - SMP',
                      badge: _currentRank,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const EnhancedLeaderboardScreen()),
                        );
                      },
                    ),

                    _buildMenuItem(
                      icon: Icons.history,
                      title: 'Riwayat Pembelajaran',
                      subtitle: 'Lihat aktivitas belajar',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const LearningHistoryScreen()),
                        );
                      },
                    ),

                    _buildMenuItem(
                      icon: Icons.calendar_today,
                      title: 'Jadwal Sinau',
                      subtitle: 'Atur jadwal pembelajaran',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const StudyScheduleScreen()),
                        );
                      },
                    ),

                    _buildMenuItem(
                      icon: Icons.bookmark,
                      title: 'Materi Favorit',
                      subtitle: 'Koleksi materi tersimpan',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const FavoritesScreen()),
                        );
                      },
                    ),

                    _buildMenuItem(
                      icon: Icons.settings,
                      title: 'Pengaturan',
                      subtitle: 'Konfigurasi aplikasi',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const SettingsScreen()),
                        );
                      },
                    ),

                    const Divider(height: 32),

                    _buildMenuItem(
                      icon: Icons.help,
                      title: 'Bantuan',
                      subtitle: 'FAQ dan panduan',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const HelpScreen()),
                        );
                      },
                    ),

                    _buildMenuItem(
                      icon: Icons.feedback,
                      title: 'Kirim Masukan',
                      subtitle: 'Berikan feedback',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const FeedbackScreen()),
                        );
                      },
                    ),

                    _buildMenuItem(
                      icon: Icons.info,
                      title: 'Tentang Aplikasi',
                      subtitle: 'Informasi aplikasi',
                      onTap: () {
                        Navigator.pop(context);
                        _showAboutDialog(context);
                      },
                    ),

                    _buildMenuItem(
                      icon: Icons.logout,
                      title: 'Keluar',
                      subtitle: 'Logout dari aplikasi',
                      onTap: () {
                        Navigator.pop(context);
                        _showLogoutDialog(context);
                      },
                      isDestructive: true,
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

  Widget _buildDefaultAvatar() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF5D3A1D), Color(0xFF8B4513)],
        ),
        borderRadius: BorderRadius.circular(40),
      ),
      child: Center(
        child: Text(
          widget.userName.isNotEmpty ? widget.userName[0].toUpperCase() : 'P',
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Color _getRankColor(String rank) {
    if (rank.contains('SMP')) return Colors.purple;
    if (rank.contains('6')) return Colors.blue;
    if (rank.contains('5')) return Colors.green;
    if (rank.contains('4')) return Colors.orange;
    if (rank.contains('3')) return Colors.red;
    return Colors.grey;
  }

  void _showProfilePhotoOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Pilih Foto Profil',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF3E2723),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildPhotoOption(
                  icon: Icons.camera_alt,
                  label: 'Kamera',
                  onTap: () => _pickImage(ImageSource.camera),
                ),
                _buildPhotoOption(
                  icon: Icons.photo_library,
                  label: 'Galeri',
                  onTap: () => _pickImage(ImageSource.gallery),
                ),
                if (_profileImagePath != null)
                  _buildPhotoOption(
                    icon: Icons.delete,
                    label: 'Hapus',
                    onTap: _removeProfilePhoto,
                    isDestructive: true,
                  ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDestructive
                  ? Colors.red.withOpacity(0.1)
                  : const Color(0xFF5D3A1D).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              size: 32,
              color: isDestructive ? Colors.red : const Color(0xFF5D3A1D),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: isDestructive ? Colors.red : const Color(0xFF3E2723),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );

      if (image != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('profile_image_path', image.path);

        setState(() {
          _profileImagePath = image.path;
        });

        widget.onUserDataUpdated();
      }
    } catch (e) {
      print('Error picking image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal memilih foto'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _removeProfilePhoto() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('profile_image_path');

      setState(() {
        _profileImagePath = null;
      });

      widget.onUserDataUpdated();
    } catch (e) {
      print('Error removing profile photo: $e');
    }
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
    String? badge,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isDestructive
              ? Colors.red.withOpacity(0.1)
              : const Color(0xFF5D3A1D).withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: isDestructive ? Colors.red : const Color(0xFF5D3A1D),
          size: 24,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: isDestructive ? Colors.red : const Color(0xFF3E2723),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          fontSize: 12,
          color: Colors.grey,
        ),
      ),
      trailing: badge != null
          ? Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFF5D3A1D),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          badge,
          style: const TextStyle(
            fontSize: 10,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      )
          : const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
    );
  }

  void _showProfileDialog(BuildContext context) {
    final nameController = TextEditingController(text: widget.userName);
    final emailController = TextEditingController(text: widget.userEmail);
    final phoneController = TextEditingController(text: widget.userPhone);
    final addressController = TextEditingController(text: widget.userAddress);
    final schoolController = TextEditingController(text: widget.userSchool);
    final classController = TextEditingController(text: widget.userClass);

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          constraints: const BoxConstraints(maxHeight: 600),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Edit Profil',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF3E2723),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                _buildValidatedTextField(
                  controller: nameController,
                  label: 'Nama Lengkap',
                  icon: Icons.person,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Nama tidak boleh kosong';
                    }
                    if (value.trim().length < 2) {
                      return 'Nama minimal 2 karakter';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                _buildValidatedTextField(
                  controller: emailController,
                  label: 'Email',
                  icon: Icons.email,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                        return 'Format email tidak valid';
                      }
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                _buildValidatedTextField(
                  controller: phoneController,
                  label: 'Nomor Telepon',
                  icon: Icons.phone,
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      if (!RegExp(r'^[0-9+\-\s]+$').hasMatch(value)) {
                        return 'Nomor telepon tidak valid';
                      }
                      if (value.replaceAll(RegExp(r'[^0-9]'), '').length < 10) {
                        return 'Nomor telepon minimal 10 digit';
                      }
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                _buildValidatedTextField(
                  controller: schoolController,
                  label: 'Sekolah',
                  icon: Icons.school,
                  validator: (value) {
                    if (value != null && value.isNotEmpty && value.trim().length < 3) {
                      return 'Nama sekolah minimal 3 karakter';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                _buildValidatedTextField(
                  controller: classController,
                  label: 'Kelas',
                  icon: Icons.class_,
                  validator: (value) {
                    if (value != null && value.isNotEmpty && value.trim().isEmpty) {
                      return 'Kelas tidak boleh kosong';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                _buildValidatedTextField(
                  controller: addressController,
                  label: 'Alamat',
                  icon: Icons.location_on,
                  maxLines: 3,
                  validator: (value) {
                    if (value != null && value.isNotEmpty && value.trim().length < 5) {
                      return 'Alamat minimal 5 karakter';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_validateProfileForm(
                        nameController.text,
                        emailController.text,
                        phoneController.text,
                        schoolController.text,
                        classController.text,
                        addressController.text,
                      )) {
                        await _saveUserProfile(
                          nameController.text.trim(),
                          emailController.text.trim(),
                          phoneController.text.trim(),
                          schoolController.text.trim(),
                          classController.text.trim(),
                          addressController.text.trim(),
                        );

                        Navigator.pop(context);
                        widget.onUserDataUpdated();

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Profil berhasil diperbarui'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5D3A1D),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Simpan Perubahan',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
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

  Widget _buildValidatedTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF5D3A1D), width: 2),
        ),
      ),
      validator: validator,
      autovalidateMode: AutovalidateMode.onUserInteraction,
    );
  }

  bool _validateProfileForm(
      String name,
      String email,
      String phone,
      String school,
      String className,
      String address,
      ) {
    if (name.trim().isEmpty) {
      _showValidationError('Nama tidak boleh kosong');
      return false;
    }
    if (name.trim().length < 2) {
      _showValidationError('Nama minimal 2 karakter');
      return false;
    }

    if (email.isNotEmpty && !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      _showValidationError('Format email tidak valid');
      return false;
    }

    if (phone.isNotEmpty) {
      if (!RegExp(r'^[0-9+\-\s]+$').hasMatch(phone)) {
        _showValidationError('Nomor telepon tidak valid');
        return false;
      }
      if (phone.replaceAll(RegExp(r'[^0-9]'), '').length < 10) {
        _showValidationError('Nomor telepon minimal 10 digit');
        return false;
      }
    }

    if (school.isNotEmpty && school.trim().length < 3) {
      _showValidationError('Nama sekolah minimal 3 karakter');
      return false;
    }

    if (address.isNotEmpty && address.trim().length < 5) {
      _showValidationError('Alamat minimal 5 karakter');
      return false;
    }

    return true;
  }

  void _showValidationError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  Future<void> _saveUserProfile(
      String name,
      String email,
      String phone,
      String school,
      String className,
      String address,
      ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_name', name);
      await prefs.setString('user_email', email);
      await prefs.setString('user_phone', phone);
      await prefs.setString('user_school', school);
      await prefs.setString('user_class', className);
      await prefs.setString('user_address', address);
    } catch (e) {
      print('Error saving user profile: $e');
    }
  }

  void _showProgressDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Progress Sinau',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF3E2723),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              ...widget.moduleProgress.entries.map((entry) {
                return _buildProgressItem(
                  _getModuleName(entry.key),
                  entry.value,
                );
              }).toList(),

              const SizedBox(height: 16),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF5D3A1D).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.emoji_events,
                      color: Color(0xFF5D3A1D),
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tingkat $_currentRank',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF3E2723),
                            ),
                          ),
                          Text(
                            'Total Progress: ${(widget.moduleProgress.values.fold(0.0, (sum, progress) => sum + progress) / widget.moduleProgress.length * 100).toInt()}%',
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
        ),
      ),
    );
  }

  Widget _buildProgressItem(String moduleName, double progress) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                moduleName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3E2723),
                ),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF5D3A1D),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey.shade300,
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF5D3A1D)),
          ),
        ],
      ),
    );
  }

  String _getModuleName(String moduleKey) {
    switch (moduleKey) {
      case 'bahasa_krama':
        return 'Bahasa Krama';
      case 'aksara_jawa':
        return 'Aksara Jawa';
      case 'sastra_indonesia':
        return 'Sastra Indonesia';
      case 'sastra_jawa':
        return 'Sastra Jawa';
      default:
        return moduleKey;
    }
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Image.asset(
              'assets/logo/logo.png',
              width: 40,
              height: 40,
              errorBuilder: (context, error, stackTrace) => const Icon(
                Icons.school,
                size: 40,
                color: Color(0xFF5D3A1D),
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Sandya Nusantara',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF3E2723),
              ),
            ),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Aplikasi pembelajaran bahasa dan budaya Jawa untuk melestarikan warisan nusantara.',
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 16),
            Text(
              'Versi: 1.0.0',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
            Text(
              'Dikembangkan dengan ❤️ untuk Indonesia',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
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

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'Keluar dari Aplikasi',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF3E2723),
          ),
        ),
        content: const Text(
          'Apakah Anda yakin ingin keluar dari aplikasi?',
          style: TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();

              Navigator.pop(context);
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                    (route) => false,
              );
            },
            child: const Text(
              'Keluar',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}

// Enhanced Achievements Screen with titles display
class EnhancedAchievementsScreen extends StatefulWidget {
  const EnhancedAchievementsScreen({Key? key}) : super(key: key);

  @override
  State<EnhancedAchievementsScreen> createState() => _EnhancedAchievementsScreenState();
}

class _EnhancedAchievementsScreenState extends State<EnhancedAchievementsScreen> {
  List<String> _earnedTitles = [];
  String? _selectedTitle;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTitles();
  }

  Future<void> _loadTitles() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final titlesJson = prefs.getString('earned_titles') ?? '[]';
      final selectedTitle = prefs.getString('selected_title');

      setState(() {
        _earnedTitles = List<String>.from(json.decode(titlesJson));
        _selectedTitle = selectedTitle;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _selectTitle(String title) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('selected_title', title);

      setState(() {
        _selectedTitle = title;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gelar "$title" telah dipasang!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print('Error selecting title: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Prestasi & Gelar'),
        backgroundColor: const Color(0xFF5D3A1D),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          // Current selected title
          if (_selectedTitle != null) ...[
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF5D3A1D), Color(0xFF8B4513)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.emoji_events,
                    color: Colors.white,
                    size: 48,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Gelar Aktif',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                  Text(
                    _selectedTitle!,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Earned titles list
          Expanded(
            child: _earnedTitles.isEmpty
                ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.emoji_events_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Belum ada gelar yang diraih',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Selesaikan kuis dengan skor sempurna untuk mendapat gelar',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _earnedTitles.length,
              itemBuilder: (context, index) {
                final title = _earnedTitles[index];
                final isSelected = title == _selectedTitle;

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? const Color(0xFF5D3A1D) : Colors.grey.shade300,
                      width: isSelected ? 2 : 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF5D3A1D)
                            : const Color(0xFF5D3A1D).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.emoji_events,
                        color: isSelected ? Colors.white : const Color(0xFF5D3A1D),
                        size: 24,
                      ),
                    ),
                    title: Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? const Color(0xFF5D3A1D) : const Color(0xFF3E2723),
                      ),
                    ),
                    subtitle: Text(
                      isSelected ? 'Gelar aktif' : 'Tap untuk pasang gelar',
                      style: TextStyle(
                        fontSize: 12,
                        color: isSelected ? const Color(0xFF5D3A1D) : Colors.grey,
                      ),
                    ),
                    trailing: isSelected
                        ? const Icon(
                      Icons.check_circle,
                      color: Color(0xFF5D3A1D),
                    )
                        : const Icon(
                      Icons.radio_button_unchecked,
                      color: Colors.grey,
                    ),
                    onTap: isSelected ? null : () => _selectTitle(title),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// Enhanced Leaderboard with ranking system
class EnhancedLeaderboardScreen extends StatefulWidget {
  const EnhancedLeaderboardScreen({Key? key}) : super(key: key);

  @override
  State<EnhancedLeaderboardScreen> createState() => _EnhancedLeaderboardScreenState();
}

class _EnhancedLeaderboardScreenState extends State<EnhancedLeaderboardScreen> {
  List<Map<String, dynamic>> _leaderboard = [];
  bool _isLoading = true;
  String _selectedRank = 'Semua';

  @override
  void initState() {
    super.initState();
    _loadLeaderboard();
  }

  Future<void> _loadLeaderboard() async {
    // Simulate loading leaderboard data with ranking system
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _leaderboard = [
        {
          'name': 'Sari Dewi',
          'school': 'SMA Negeri 1 Yogyakarta',
          'score': 2850,
          'rank': 'SMP',
          'avatar': null,
        },
        {
          'name': 'Budi Santoso',
          'school': 'SMA Negeri 2 Solo',
          'score': 2720,
          'rank': 'SMP',
          'avatar': null,
        },
        {
          'name': 'Anda',
          'school': 'SMA Negeri 3 Semarang',
          'score': 2650,
          'rank': 'SD Kelas 6',
          'avatar': null,
          'isCurrentUser': true,
        },
        {
          'name': 'Rina Kusuma',
          'school': 'SMA Negeri 1 Surabaya',
          'score': 2580,
          'rank': 'SD Kelas 6',
          'avatar': null,
        },
        {
          'name': 'Ahmad Fauzi',
          'school': 'SMA Negeri 5 Jakarta',
          'score': 2450,
          'rank': 'SD Kelas 5',
          'avatar': null,
        },
      ];
      _isLoading = false;
    });
  }

  List<Map<String, dynamic>> get _filteredLeaderboard {
    if (_selectedRank == 'Semua') return _leaderboard;
    return _leaderboard.where((user) => user['rank'] == _selectedRank).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ranking Tingkat'),
        backgroundColor: const Color(0xFF5D3A1D),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          // Rank filter
          Container(
            margin: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['Semua', 'SD Kelas 1', 'SD Kelas 2', 'SD Kelas 3', 'SD Kelas 4', 'SD Kelas 5', 'SD Kelas 6', 'SMP']
                    .map((rank) => Container(
                  margin: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(rank),
                    selected: _selectedRank == rank,
                    onSelected: (selected) {
                      setState(() {
                        _selectedRank = rank;
                      });
                    },
                    selectedColor: const Color(0xFF5D3A1D).withOpacity(0.2),
                    checkmarkColor: const Color(0xFF5D3A1D),
                  ),
                ))
                    .toList(),
              ),
            ),
          ),

          // Leaderboard list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _filteredLeaderboard.length,
              itemBuilder: (context, index) {
                final user = _filteredLeaderboard[index];
                return _buildLeaderboardItem(user, index + 1);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderboardItem(Map<String, dynamic> user, int rank) {
    final isCurrentUser = user['isCurrentUser'] == true;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCurrentUser ? const Color(0xFF5D3A1D).withOpacity(0.1) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCurrentUser ? const Color(0xFF5D3A1D) : Colors.grey.shade200,
          width: isCurrentUser ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Rank
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: _getRankColor(rank),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                '$rank',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          const SizedBox(width: 16),

          // Avatar
          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.grey.shade300,
            child: Text(
              user['name'][0].toUpperCase(),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),

          const SizedBox(width: 16),

          // User info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      user['name'],
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isCurrentUser ? const Color(0xFF5D3A1D) : const Color(0xFF3E2723),
                      ),
                    ),
                    if (isCurrentUser) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF5D3A1D),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Anda',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  user['school'],
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getRankBadgeColor(user['rank']),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    user['rank'],
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Score
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${user['score']}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3E2723),
                ),
              ),
              const Text(
                'Poin',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return Colors.amber;
      case 2:
        return Colors.grey;
      case 3:
        return Colors.brown;
      default:
        return const Color(0xFF5D3A1D);
    }
  }

  Color _getRankBadgeColor(String rank) {
    if (rank.contains('SMP')) return Colors.purple;
    if (rank.contains('6')) return Colors.blue;
    if (rank.contains('5')) return Colors.green;
    if (rank.contains('4')) return Colors.orange;
    if (rank.contains('3')) return Colors.red;
    return Colors.grey;
  }
}

// Learning History Screen
class LearningHistoryScreen extends StatefulWidget {
  const LearningHistoryScreen({Key? key}) : super(key: key);

  @override
  State<LearningHistoryScreen> createState() => _LearningHistoryScreenState();
}

class _LearningHistoryScreenState extends State<LearningHistoryScreen> {
  List<Map<String, dynamic>> _history = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getString('learning_history') ?? '[]';
      final history = json.decode(historyJson) as List;

      setState(() {
        _history = history.cast<Map<String, dynamic>>()
          ..sort((a, b) => b['timestamp'].compareTo(a['timestamp']));
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Pembelajaran'),
        backgroundColor: const Color(0xFF5D3A1D),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _history.isEmpty
          ? const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'Belum ada riwayat pembelajaran',
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
        itemCount: _history.length,
        itemBuilder: (context, index) {
          final item = _history[index];
          return _buildHistoryItem(item);
        },
      ),
    );
  }

  Widget _buildHistoryItem(Map<String, dynamic> item) {
    final date = DateTime.fromMillisecondsSinceEpoch(item['timestamp']);
    final percentage = item['percentage'] ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _getScoreColor(percentage).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getScoreIcon(percentage),
              color: _getScoreColor(percentage),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getModuleName(item['module']),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3E2723),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Skor: ${item['score']}/${item['total']} ($percentage%)',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _getScoreColor(percentage),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$percentage%',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getModuleName(String moduleKey) {
    switch (moduleKey) {
      case 'bahasa_krama':
        return 'Bahasa Krama';
      case 'aksara_jawa':
        return 'Aksara Jawa';
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
    return Icons.trending_down;
  }
}

// Study Schedule Screen with Notifications
class StudyScheduleScreen extends StatefulWidget {
  const StudyScheduleScreen({Key? key}) : super(key: key);

  @override
  State<StudyScheduleScreen> createState() => _StudyScheduleScreenState();
}

class _StudyScheduleScreenState extends State<StudyScheduleScreen> {
  List<Map<String, dynamic>> _schedules = [];
  bool _isLoading = true;
  late FlutterLocalNotificationsPlugin _notificationsPlugin;

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    _loadSchedules();
  }

  Future<void> _initializeNotifications() async {
    _notificationsPlugin = FlutterLocalNotificationsPlugin();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notificationsPlugin.initialize(initSettings);
  }

  Future<void> _scheduleNotification(Map<String, dynamic> schedule) async {
    final scheduledDate = DateTime.parse(schedule['date']);
    final time = schedule['time'].split(':');
    final notificationTime = DateTime(
      scheduledDate.year,
      scheduledDate.month,
      scheduledDate.day,
      int.parse(time[0]),
      int.parse(time[1]),
    ).subtract(const Duration(minutes: 15)); // 15 minutes before

    if (notificationTime.isAfter(DateTime.now())) {
      final scheduledDate = tz.TZDateTime.from(notificationTime, tz.getLocation('Asia/Jakarta'));

      await _notificationsPlugin.zonedSchedule(
        schedule['id'].hashCode,
        'Waktune Sinau!',
        'Saiki wektune sinau ${schedule['title']}. Ayo disiapake!',
        scheduledDate,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'study_schedule',
            'Study Schedule',
            channelDescription: 'Notifications for study schedule reminders',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
  }

  Future<void> _loadSchedules() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final schedulesJson = prefs.getString('study_schedules') ?? '[]';
      final schedules = json.decode(schedulesJson) as List;

      setState(() {
        _schedules = schedules.cast<Map<String, dynamic>>();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveSchedules() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('study_schedules', json.encode(_schedules));
    } catch (e) {
      print('Error saving schedules: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Jadwal Sinau'),
        backgroundColor: const Color(0xFF5D3A1D),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _showAddScheduleDialog,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _schedules.isEmpty
          ? const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_today,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'Belum ada jadwal pembelajaran',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Tap + untuk menambah jadwal',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _schedules.length,
        itemBuilder: (context, index) {
          final schedule = _schedules[index];
          return _buildScheduleItem(schedule, index);
        },
      ),
    );
  }

  Widget _buildScheduleItem(Map<String, dynamic> schedule, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF5D3A1D).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.schedule,
              color: Color(0xFF5D3A1D),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  schedule['title'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3E2723),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${schedule['day']} - ${schedule['time']}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                if (schedule['description'] != null && schedule['description'].isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    schedule['description'],
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ],
            ),
          ),
          PopupMenuButton(
            onSelected: (value) {
              if (value == 'edit') {
                _showEditScheduleDialog(schedule, index);
              } else if (value == 'delete') {
                _deleteSchedule(index);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit, size: 16),
                    SizedBox(width: 8),
                    Text('Edit'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, size: 16, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Hapus', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showAddScheduleDialog() {
    _showScheduleDialog();
  }

  void _showEditScheduleDialog(Map<String, dynamic> schedule, int index) {
    _showScheduleDialog(schedule: schedule, index: index);
  }

  void _showScheduleDialog({Map<String, dynamic>? schedule, int? index}) {
    final titleController = TextEditingController(text: schedule?['title'] ?? '');
    final descriptionController = TextEditingController(text: schedule?['description'] ?? '');
    String selectedDay = schedule?['day'] ?? 'Senin';
    TimeOfDay selectedTime = schedule != null
        ? TimeOfDay.fromDateTime(DateTime.parse('2023-01-01 ${schedule['time']}:00'))
        : const TimeOfDay(hour: 9, minute: 0);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(schedule == null ? 'Tambah Jadwal' : 'Edit Jadwal'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Judul',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedDay,
                decoration: const InputDecoration(
                  labelText: 'Hari',
                  border: OutlineInputBorder(),
                ),
                items: ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu']
                    .map((day) => DropdownMenuItem(value: day, child: Text(day)))
                    .toList(),
                onChanged: (value) {
                  setDialogState(() {
                    selectedDay = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: () async {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: selectedTime,
                  );
                  if (time != null) {
                    setDialogState(() {
                      selectedTime = time;
                    });
                  }
                },
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Waktu',
                    border: OutlineInputBorder(),
                  ),
                  child: Text(selectedTime.format(context)),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Deskripsi (opsional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (titleController.text.trim().isNotEmpty) {
                  final newSchedule = {
                    'id': schedule?['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
                    'title': titleController.text.trim(),
                    'day': selectedDay,
                    'time': '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}',
                    'description': descriptionController.text.trim(),
                    'date': DateTime.now().add(Duration(days: _getDaysUntilNext(selectedDay))).toIso8601String(),
                  };

                  setState(() {
                    if (index != null) {
                      _schedules[index] = newSchedule;
                    } else {
                      _schedules.add(newSchedule);
                    }
                  });

                  await _saveSchedules();
                  await _scheduleNotification(newSchedule);
                  Navigator.pop(context);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(schedule == null
                          ? 'Jadwal berhasil ditambahkan dengan notifikasi!'
                          : 'Jadwal berhasil diperbarui!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              child: Text(schedule == null ? 'Tambah' : 'Simpan'),
            ),
          ],
        ),
      ),
    );
  }

  int _getDaysUntilNext(String dayName) {
    final days = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
    final targetDay = days.indexOf(dayName);
    final currentDay = DateTime.now().weekday - 1;

    if (targetDay >= currentDay) {
      return targetDay - currentDay;
    } else {
      return 7 - currentDay + targetDay;
    }
  }

  void _deleteSchedule(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Jadwal'),
        content: const Text('Apakah Anda yakin ingin menghapus jadwal ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              final schedule = _schedules[index];
              await _notificationsPlugin.cancel(schedule['id'].hashCode);

              setState(() {
                _schedules.removeAt(index);
              });
              _saveSchedules();
              Navigator.pop(context);
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

// Favorites Screen
class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({Key? key}) : super(key: key);

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  List<Map<String, dynamic>> _favorites = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoritesJson = prefs.getString('favorites') ?? '[]';
      final favorites = json.decode(favoritesJson) as List;

      setState(() {
        _favorites = favorites.cast<Map<String, dynamic>>();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Materi Favorit'),
        backgroundColor: const Color(0xFF5D3A1D),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _favorites.isEmpty
          ? const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bookmark_border,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'Belum ada materi favorit',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Tandai materi yang Anda sukai',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _favorites.length,
        itemBuilder: (context, index) {
          final favorite = _favorites[index];
          return _buildFavoriteItem(favorite, index);
        },
      ),
    );
  }

  Widget _buildFavoriteItem(Map<String, dynamic> favorite, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF5D3A1D).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getModuleIcon(favorite['module']),
              color: const Color(0xFF5D3A1D),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  favorite['title'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3E2723),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getModuleName(favorite['module']),
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                if (favorite['description'] != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    favorite['description'],
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            onPressed: () => _removeFavorite(index),
            icon: const Icon(
              Icons.bookmark,
              color: Color(0xFF5D3A1D),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getModuleIcon(String module) {
    switch (module) {
      case 'aksara_jawa':
        return Icons.text_fields;
      case 'bahasa_krama':
        return Icons.language;
      case 'sastra_indonesia':
        return Icons.book;
      case 'sastra_jawa':
        return Icons.menu_book;
      default:
        return Icons.bookmark;
    }
  }

  String _getModuleName(String moduleKey) {
    switch (moduleKey) {
      case 'bahasa_krama':
        return 'Bahasa Krama';
      case 'aksara_jawa':
        return 'Aksara Jawa';
      case 'sastra_indonesia':
        return 'Sastra Indonesia';
      case 'sastra_jawa':
        return 'Sastra Jawa';
      default:
        return moduleKey;
    }
  }

  void _removeFavorite(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Favorit'),
        content: const Text('Apakah Anda yakin ingin menghapus dari favorit?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              setState(() {
                _favorites.removeAt(index);
              });

              final prefs = await SharedPreferences.getInstance();
              await prefs.setString('favorites', json.encode(_favorites));

              Navigator.pop(context);
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

// Settings Screen
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _soundEnabled = true;
  bool _notificationsEnabled = true;
  bool _darkMode = false;
  String _language = 'Bahasa Indonesia';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _soundEnabled = prefs.getBool('sound_enabled') ?? true;
      _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
      _darkMode = prefs.getBool('dark_mode') ?? false;
      _language = prefs.getString('language') ?? 'Bahasa Indonesia';
    });
  }

  Future<void> _saveSetting(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value is bool) {
      await prefs.setBool(key, value);
    } else if (value is String) {
      await prefs.setString(key, value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan'),
        backgroundColor: const Color(0xFF5D3A1D),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSettingsSection(
            'Audio & Visual',
            [
              _buildSwitchTile(
                'Suara',
                'Aktifkan efek suara',
                Icons.volume_up,
                _soundEnabled,
                    (value) {
                  setState(() {
                    _soundEnabled = value;
                  });
                  _saveSetting('sound_enabled', value);
                },
              ),
              _buildSwitchTile(
                'Mode Gelap',
                'Gunakan tema gelap',
                Icons.dark_mode,
                _darkMode,
                    (value) {
                  setState(() {
                    _darkMode = value;
                  });
                  _saveSetting('dark_mode', value);
                },
              ),
            ],
          ),

          const SizedBox(height: 24),

          _buildSettingsSection(
            'Notifikasi',
            [
              _buildSwitchTile(
                'Notifikasi',
                'Terima pengingat belajar',
                Icons.notifications,
                _notificationsEnabled,
                    (value) {
                  setState(() {
                    _notificationsEnabled = value;
                  });
                  _saveSetting('notifications_enabled', value);
                },
              ),
            ],
          ),

          const SizedBox(height: 24),

          _buildSettingsSection(
            'Bahasa',
            [
              _buildLanguageTile(),
            ],
          ),

          const SizedBox(height: 24),

          _buildSettingsSection(
            'Data',
            [
              _buildActionTile(
                'Hapus Cache',
                'Bersihkan data sementara',
                Icons.cleaning_services,
                _clearCache,
              ),
              _buildActionTile(
                'Reset Progress',
                'Hapus semua progress pembelajaran',
                Icons.refresh,
                _resetProgress,
                isDestructive: true,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF3E2723),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildSwitchTile(
      String title,
      String subtitle,
      IconData icon,
      bool value,
      Function(bool) onChanged,
      ) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF5D3A1D)),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: const Color(0xFF5D3A1D),
      ),
    );
  }

  Widget _buildLanguageTile() {
    return ListTile(
      leading: const Icon(Icons.language, color: Color(0xFF5D3A1D)),
      title: const Text('Bahasa Aplikasi'),
      subtitle: Text(_language),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Pilih Bahasa'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                RadioListTile<String>(
                  title: const Text('Bahasa Indonesia'),
                  value: 'Bahasa Indonesia',
                  groupValue: _language,
                  onChanged: (value) {
                    setState(() {
                      _language = value!;
                    });
                    _saveSetting('language', value!);
                    Navigator.pop(context);
                  },
                ),
                RadioListTile<String>(
                  title: const Text('Bahasa Jawa'),
                  value: 'Bahasa Jawa',
                  groupValue: _language,
                  onChanged: (value) {
                    setState(() {
                      _language = value!;
                    });
                    _saveSetting('language', value!);
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionTile(
      String title,
      String subtitle,
      IconData icon,
      VoidCallback onTap, {
        bool isDestructive = false,
      }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive ? Colors.red : const Color(0xFF5D3A1D),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isDestructive ? Colors.red : null,
        ),
      ),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  void _clearCache() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Cache'),
        content: const Text('Apakah Anda yakin ingin menghapus cache aplikasi?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              // Simulate cache clearing
              await Future.delayed(const Duration(seconds: 1));
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Cache berhasil dihapus'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  void _resetProgress() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Progress'),
        content: const Text(
          'Apakah Anda yakin ingin menghapus semua progress pembelajaran? Tindakan ini tidak dapat dibatalkan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.remove('quiz_history');
              await prefs.remove('module_progress');
              await prefs.remove('earned_titles');

              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Progress berhasil direset'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text(
              'Reset',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}

// Help Screen
class HelpScreen extends StatelessWidget {
  const HelpScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bantuan'),
        backgroundColor: const Color(0xFF5D3A1D),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildHelpSection(
            'Cara Menggunakan Aplikasi',
            [
              _buildHelpItem(
                'Bagaimana cara memulai pembelajaran?',
                'Pilih modul yang ingin dipelajari dari halaman utama, lalu tap "Mulai Sinau" untuk memulai kuis.',
              ),
              _buildHelpItem(
                'Bagaimana cara melihat progress?',
                'Buka menu drawer dan pilih "Progress Sinau" untuk melihat kemajuan pembelajaran Anda.',
              ),
              _buildHelpItem(
                'Apa itu sistem nyawa?',
                'Setiap kuis memiliki 3 nyawa. Jika jawaban salah, nyawa akan berkurang. Jika nyawa habis, kuis akan berakhir.',
              ),
            ],
          ),

          const SizedBox(height: 24),

          _buildHelpSection(
            'Fitur Aplikasi',
            [
              _buildHelpItem(
                'Apa itu jadwal sinau?',
                'Fitur untuk mengatur jadwal pembelajaran harian agar belajar lebih teratur dan konsisten.',
              ),
              _buildHelpItem(
                'Bagaimana cara mendapat prestasi?',
                'Prestasi didapat dengan menyelesaikan berbagai tantangan seperti menyelesaikan kuis pertama, mendapat skor sempurna, dll.',
              ),
              _buildHelpItem(
                'Apa fungsi papan peringkat?',
                'Papan peringkat menampilkan ranking pengguna berdasarkan total skor dari semua kuis yang telah diselesaikan.',
              ),
            ],
          ),

          const SizedBox(height: 24),

          _buildHelpSection(
            'Troubleshooting',
            [
              _buildHelpItem(
                'Aplikasi berjalan lambat',
                'Coba hapus cache aplikasi melalui menu Pengaturan > Hapus Cache.',
              ),
              _buildHelpItem(
                'Suara tidak keluar',
                'Pastikan volume perangkat tidak dalam mode silent dan pengaturan suara aplikasi aktif.',
              ),
              _buildHelpItem(
                'Progress hilang',
                'Progress disimpan secara lokal. Pastikan tidak menghapus data aplikasi atau melakukan reset progress.',
              ),
            ],
          ),

          const SizedBox(height: 32),

          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF5D3A1D).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Column(
              children: [
                Icon(
                  Icons.support_agent,
                  size: 48,
                  color: Color(0xFF5D3A1D),
                ),
                SizedBox(height: 16),
                Text(
                  'Butuh Bantuan Lebih Lanjut?',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3E2723),
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Hubungi tim support kami melalui menu "Kirim Masukan" untuk mendapat bantuan lebih lanjut.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHelpSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF3E2723),
          ),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _buildHelpItem(String question, String answer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ExpansionTile(
        title: Text(
          question,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF3E2723),
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(
              answer,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Feedback Screen
class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({Key? key}) : super(key: key);

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _messageController = TextEditingController();
  String _feedbackType = 'Saran';
  int _rating = 5;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kirim Masukan'),
        backgroundColor: const Color(0xFF5D3A1D),
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF5D3A1D).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Column(
                children: [
                  Icon(
                    Icons.feedback,
                    size: 48,
                    color: Color(0xFF5D3A1D),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Masukan Anda Sangat Berharga',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF3E2723),
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Bantu kami meningkatkan aplikasi dengan memberikan masukan dan saran Anda.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Rating
            const Text(
              'Berikan Rating',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF3E2723),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  onPressed: () {
                    setState(() {
                      _rating = index + 1;
                    });
                  },
                  icon: Icon(
                    index < _rating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 32,
                  ),
                );
              }),
            ),

            const SizedBox(height: 24),

            // Feedback Type
            const Text(
              'Jenis Masukan',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF3E2723),
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _feedbackType,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF5D3A1D), width: 2),
                ),
              ),
              items: ['Saran', 'Keluhan', 'Bug Report', 'Fitur Request', 'Lainnya']
                  .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _feedbackType = value!;
                });
              },
            ),

            const SizedBox(height: 16),

            // Name
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nama (Opsional)',
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF5D3A1D), width: 2),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Email
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email (Opsional)',
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF5D3A1D), width: 2),
                ),
              ),
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                    return 'Format email tidak valid';
                  }
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Message
            TextFormField(
              controller: _messageController,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Pesan',
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF5D3A1D), width: 2),
                ),
                alignLabelWithHint: true,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Pesan tidak boleh kosong';
                }
                if (value.trim().length < 10) {
                  return 'Pesan minimal 10 karakter';
                }
                return null;
              },
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitFeedback,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5D3A1D),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Kirim Masukan',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submitFeedback() {
    if (_formKey.currentState!.validate()) {
      // Simulate sending feedback
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 32),
              SizedBox(width: 12),
              Text('Terima Kasih!'),
            ],
          ),
          content: const Text(
            'Masukan Anda telah berhasil dikirim. Tim kami akan meninjau dan merespons secepatnya.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _messageController.dispose();
    super.dispose();
  }
}