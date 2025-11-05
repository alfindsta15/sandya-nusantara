// import 'package:flutter/material.dart';
// import 'package:sandya_nusantara/utils/app_theme.dart';
//
// class ChallengeScreen extends StatefulWidget {
//   final String moduleType;
//
//   const ChallengeScreen({
//     Key? key,
//     required this.moduleType,
//   }) : super(key: key);
//
//   @override
//   State<ChallengeScreen> createState() => _ChallengeScreenState();
// }
//
// class _ChallengeScreenState extends State<ChallengeScreen> {
//   final TextEditingController _answerController = TextEditingController();
//   int _currentQuestion = 3;
//   int _selectedAnswerIndex = -1;
//   bool _isAnswerSubmitted = false;
//
//   final List<String> _answerOptions = [
//     'Punika, Bapak/Ibu, kula dipun jini mulih nyin amargi wulangan dinten punika sampun cekap. Kula badhe nyinaoni tugas-tugas sekolah',
//     'Biasa wae, Bu/Pak. Pelajarane ana sing angel, tapi ya aku ora mikir banget.',
//   ];
//
//   @override
//   void dispose() {
//     _answerController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         title: Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             IconButton(
//               icon: const Icon(
//                 Icons.chevron_left,
//                 color: Colors.black,
//               ),
//               onPressed: () {
//                 if (_currentQuestion > 1) {
//                   setState(() {
//                     _currentQuestion--;
//                     _selectedAnswerIndex = -1;
//                     _isAnswerSubmitted = false;
//                   });
//                 }
//               },
//             ),
//             Text(
//               'Piwulang - $_currentQuestion',
//               style: const TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.black,
//               ),
//             ),
//             IconButton(
//               icon: const Icon(
//                 Icons.chevron_right,
//                 color: Colors.black,
//               ),
//               onPressed: () {
//                 if (_currentQuestion < 5) {
//                   setState(() {
//                     _currentQuestion++;
//                     _selectedAnswerIndex = -1;
//                     _isAnswerSubmitted = false;
//                   });
//                 }
//               },
//             ),
//           ],
//         ),
//         leading: IconButton(
//           icon: const Icon(
//             Icons.close,
//             color: Colors.black,
//           ),
//           onPressed: () {
//             Navigator.pop(context);
//           },
//         ),
//       ),
//       body: Column(
//         children: [
//           Container(
//             width: double.infinity,
//             height: 4,
//             decoration: const BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [Colors.red, Colors.orange],
//               ),
//             ),
//           ),
//           const SizedBox(height: 16),
//           const Padding(
//             padding: EdgeInsets.symmetric(horizontal: 16.0),
//             child: Text(
//               'Lengkapana ukarane!',
//               style: TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ),
//           const SizedBox(height: 16),
//           _buildChatBubble(
//             'Ibuk',
//             'Nak, kok bali awan-awan? Ana opo ing sekolah?',
//             '12.00',
//             isSender: false,
//           ),
//           const SizedBox(height: 8),
//           _buildChatBubble(
//             '',
//             '.........',
//             '12.00',
//             isSender: true,
//           ),
//           const SizedBox(height: 16),
//           Expanded(
//             child: Container(
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: Colors.grey.shade100,
//                 borderRadius: const BorderRadius.only(
//                   topLeft: Radius.circular(24),
//                   topRight: Radius.circular(24),
//                 ),
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   _buildAnswerOption(
//                     _answerOptions[0],
//                     0,
//                   ),
//                   const SizedBox(height: 16),
//                   _buildAnswerOption(
//                     _answerOptions[1],
//                     1,
//                   ),
//                   const Spacer(),
//                   SizedBox(
//                     width: double.infinity,
//                     child: ElevatedButton(
//                       onPressed: _selectedAnswerIndex >= 0
//                           ? () {
//                         setState(() {
//                           _isAnswerSubmitted = true;
//                         });
//
//                         // If this is the last question or answer is submitted, go to results
//                         if (_currentQuestion >= 5 || _isAnswerSubmitted) {
//                           Future.delayed(const Duration(milliseconds: 500), () {
//                             Navigator.pushNamed(
//                               context,
//                               '/challenge_result',
//                               arguments: widget.moduleType,
//                             );
//                           });
//                         }
//                       }
//                           : null,
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: _selectedAnswerIndex >= 0
//                             ? AppTheme.primaryColor
//                             : Colors.grey,
//                         foregroundColor: Colors.white,
//                         padding: const EdgeInsets.symmetric(vertical: 16),
//                       ),
//                       child: const Text('Periksa'),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildChatBubble(String sender, String message, String time,
//       {bool isSender = false}) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
//       child: Row(
//         mainAxisAlignment:
//         isSender ? MainAxisAlignment.end : MainAxisAlignment.start,
//         children: [
//           if (!isSender)
//             Container(
//               width: 40,
//               height: 40,
//               margin: const EdgeInsets.only(right: 8),
//               decoration: BoxDecoration(
//                 color: Colors.grey.shade300,
//                 borderRadius: BorderRadius.circular(20),
//               ),
//               child: const Center(
//                 child: Text(
//                   'I',
//                   style: TextStyle(
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//             ),
//           Flexible(
//             child: Container(
//               padding: const EdgeInsets.all(12),
//               decoration: BoxDecoration(
//                 color: isSender ? Colors.green.shade700 : Colors.grey.shade800,
//                 borderRadius: BorderRadius.circular(16),
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   if (!isSender && sender.isNotEmpty)
//                     Padding(
//                       padding: const EdgeInsets.only(bottom: 4.0),
//                       child: Text(
//                         sender,
//                         style: const TextStyle(
//                           fontWeight: FontWeight.bold,
//                           color: Colors.white,
//                         ),
//                       ),
//                     ),
//                   Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Flexible(
//                         child: Text(
//                           message,
//                           style: const TextStyle(
//                             color: Colors.white,
//                           ),
//                         ),
//                       ),
//                       const SizedBox(width: 8),
//                       Text(
//                         time,
//                         style: TextStyle(
//                           fontSize: 10,
//                           color: Colors.white.withOpacity(0.7),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildAnswerOption(String text, int index) {
//     final bool isSelected = _selectedAnswerIndex == index;
//     final bool isCorrect = index == 0; // First answer is correct for this example
//
//     return GestureDetector(
//       onTap: _isAnswerSubmitted ? null : () {
//         setState(() {
//           _selectedAnswerIndex = index;
//         });
//       },
//       child: Container(
//         padding: const EdgeInsets.all(12),
//         decoration: BoxDecoration(
//           color: _isAnswerSubmitted
//               ? (isSelected
//               ? (isCorrect ? Colors.green.shade100 : Colors.red.shade100)
//               : Colors.white)
//               : (isSelected ? Colors.blue.shade50 : Colors.white),
//           borderRadius: BorderRadius.circular(8),
//           border: Border.all(
//             color: _isAnswerSubmitted
//                 ? (isSelected
//                 ? (isCorrect ? Colors.green : Colors.red)
//                 : Colors.grey.shade300)
//                 : (isSelected ? Colors.blue : Colors.grey.shade300),
//             width: isSelected ? 2 : 1,
//           ),
//         ),
//         child: Row(
//           children: [
//             Expanded(
//               child: Text(
//                 text,
//                 style: TextStyle(
//                   fontSize: 14,
//                   color: _isAnswerSubmitted && isSelected && !isCorrect
//                       ? Colors.red.shade800
//                       : Colors.black87,
//                 ),
//               ),
//             ),
//             if (_isAnswerSubmitted && isSelected)
//               Icon(
//                 isCorrect ? Icons.check_circle : Icons.cancel,
//                 color: isCorrect ? Colors.green : Colors.red,
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }
