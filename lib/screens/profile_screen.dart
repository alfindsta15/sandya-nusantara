// import 'package:flutter/material.dart';
//
// class UserProfileScreen extends StatefulWidget {
//   const UserProfileScreen({Key? key}) : super(key: key);
//
//   @override
//   State<UserProfileScreen> createState() => _UserProfileScreenState();
// }
//
// class _UserProfileScreenState extends State<UserProfileScreen> {
//   int _currentIndex = 3;
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SafeArea(
//         child: SingleChildScrollView(
//           child: Column(
//             children: [
//               Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text(
//                       'ExyLearn',
//                       style: Theme.of(context).textTheme.headlineMedium,
//                     ),
//                     Row(
//                       children: [
//                         IconButton(
//                           icon: const Icon(Icons.notifications_outlined),
//                           onPressed: () {
//                             Navigator.pushNamed(context, '/notifications');
//                           },
//                         ),
//                         IconButton(
//                           icon: const Icon(Icons.favorite_border),
//                           onPressed: () {
//                             Navigator.pushNamed(context, '/wishlist');
//                           },
//                         ),
//                         GestureDetector(
//                           onTap: () {},
//                           child: CircleAvatar(
//                             radius: 20,
//                             backgroundColor: Colors.grey[400],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 16),
//               CircleAvatar(
//                 radius: 60,
//                 backgroundColor: Colors.grey[400],
//                 backgroundImage: const AssetImage('assets/images/user.png'),
//               ),
//               const SizedBox(height: 16),
//               const Text(
//                 'Melon Musk',
//                 style: TextStyle(
//                   fontSize: 24,
//                   fontWeight: FontWeight.bold,
//                   color: Color(0xFF0A3251),
//                 ),
//               ),
//               const SizedBox(height: 16),
//               ElevatedButton(
//                 onPressed: () {
//                   Navigator.pushNamed(context, '/edit-profile');
//                 },
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: const Color(0xFF0A3251),
//                   foregroundColor: Colors.white,
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 24,
//                     vertical: 12,
//                   ),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                 ),
//                 child: const Text('Edit Profile'),
//               ),
//               const SizedBox(height: 24),
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 16.0),
//                 child: Row(
//                   children: [
//                     Expanded(
//                       child: _buildProfileCard(
//                         Icons.book,
//                         'Courses',
//                         '30 courses owned',
//                         Colors.blue[100]!,
//                             () {
//                           Navigator.pushNamed(context, '/my-courses');
//                         },
//                       ),
//                     ),
//                     const SizedBox(width: 16),
//                     Expanded(
//                       child: _buildProfileCard(
//                         Icons.trending_up,
//                         'Progress',
//                         'View your progress',
//                         Colors.blue[100]!,
//                             () {
//                           Navigator.pushNamed(context, '/progress');
//                         },
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 16),
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 16.0),
//                 child: Row(
//                   children: [
//                     Expanded(
//                       child: _buildProfileCard(
//                         Icons.workspace_premium,
//                         'Certificates',
//                         '30 certification',
//                         Colors.blue[100]!,
//                             () {
//                           Navigator.pushNamed(context, '/certificates-list');
//                         },
//                       ),
//                     ),
//                     const SizedBox(width: 16),
//                     Expanded(
//                       child: _buildProfileCard(
//                         Icons.receipt_long,
//                         'Payment History',
//                         'Your purchase history',
//                         Colors.blue[100]!,
//                             () {
//                           Navigator.pushNamed(context, '/payment-history');
//                         },
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 24),
//               _buildSettingsItem(Icons.settings, 'Settings', () {
//                 Navigator.pushNamed(context, '/settings');
//               }),
//               _buildSettingsItem(Icons.help, 'Frequently Asked Questions', () {
//                 Navigator.pushNamed(context, '/faq');
//               }),
//               _buildSettingsItem(Icons.language, 'Language & Themes', () {
//                 Navigator.pushNamed(context, '/language-theme');
//               }),
//               _buildSettingsItem(Icons.help_center, 'Help Center', () {
//                 Navigator.pushNamed(context, '/help-center');
//               }),
//               _buildSettingsItem(Icons.support_agent, 'Contact Support', () {
//                 Navigator.pushNamed(context, '/contact-support');
//               }),
//               _buildSettingsItem(Icons.star, 'Feedback & Rating', () {
//                 Navigator.pushNamed(context, '/feedback-rating');
//               }),
//               _buildSettingsItem(Icons.school, 'Become an Instructor', () {
//                 Navigator.pushNamed(context, '/become-instructor');
//               }),
//               Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: SizedBox(
//                   width: double.infinity,
//                   child: ElevatedButton(
//                     onPressed: () {
//                       Navigator.pushReplacementNamed(context, '/login');
//                     },
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.blue[100],
//                       foregroundColor: const Color(0xFF0A3251),
//                       padding: const EdgeInsets.symmetric(vertical: 16),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                     ),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: const [
//                         Icon(Icons.logout),
//                         SizedBox(width: 8),
//                         Text(
//                           'Log Out',
//                           style: TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 80),
//             ],
//           ),
//         ),
//       ),
//       bottomNavigationBar: BottomNavigationBarType(
//       ),
//     );
//   }
//
//   Widget _buildProfileCard(
//       IconData icon,
//       String title,
//       String subtitle,
//       Color color,
//       VoidCallback onTap,
//       ) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         padding: const EdgeInsets.all(16),
//         decoration: BoxDecoration(
//           color: color,
//           borderRadius: BorderRadius.circular(16),
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Icon(icon, size: 32, color: const Color(0xFF0A3251)),
//             const SizedBox(height: 16),
//             Text(
//               title,
//               style: const TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//                 color: Color(0xFF0A3251),
//               ),
//             ),
//             const SizedBox(height: 4),
//             Text(
//               subtitle,
//               style: TextStyle(fontSize: 14, color: Colors.grey[600]),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildSettingsItem(IconData icon, String title, VoidCallback onTap) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
//       child: GestureDetector(
//         onTap: onTap,
//         child: Container(
//           padding: const EdgeInsets.all(16),
//           decoration: BoxDecoration(
//             border: Border.all(color: Colors.grey[300]!),
//             borderRadius: BorderRadius.circular(8),
//           ),
//           child: Row(
//             children: [
//               Icon(icon, color: const Color(0xFF0A3251)),
//               const SizedBox(width: 16),
//               Text(
//                 title,
//                 style: const TextStyle(fontSize: 16, color: Color(0xFF0A3251)),
//               ),
//               const Spacer(),
//               const Icon(
//                 Icons.arrow_forward_ios,
//                 size: 16,
//                 color: Color(0xFF0A3251),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }