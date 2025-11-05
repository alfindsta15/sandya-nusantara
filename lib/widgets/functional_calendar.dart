import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class FunctionalCalendar extends StatefulWidget {
  const FunctionalCalendar({Key? key}) : super(key: key);

  @override
  State<FunctionalCalendar> createState() => _FunctionalCalendarState();
}

class _FunctionalCalendarState extends State<FunctionalCalendar> {
  DateTime _selectedDate = DateTime.now();
  DateTime _focusedDate = DateTime.now();
  Map<String, List<Map<String, dynamic>>> _scheduleData = {};

  @override
  void initState() {
    super.initState();
    _loadScheduleData();
  }

  Future<void> _loadScheduleData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final scheduleJson = prefs.getString('learning_schedule') ?? '{}';
      final scheduleMap = json.decode(scheduleJson) as Map<String, dynamic>;

      setState(() {
        _scheduleData = scheduleMap.map((key, value) =>
            MapEntry(key, List<Map<String, dynamic>>.from(value))
        );
      });
    } catch (e) {
      print('Error loading schedule data: $e');
    }
  }

  Future<void> _saveScheduleData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final scheduleJson = json.encode(_scheduleData);
      await prefs.setString('learning_schedule', scheduleJson);
    } catch (e) {
      print('Error saving schedule data: $e');
    }
  }

  String _getDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  List<Map<String, dynamic>> _getEventsForDay(DateTime day) {
    final dateKey = _getDateKey(day);
    return _scheduleData[dateKey] ?? [];
  }

  bool _hasEventsForDay(DateTime day) {
    return _getEventsForDay(day).isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
          // Calendar Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () {
                  setState(() {
                    _focusedDate = DateTime(_focusedDate.year, _focusedDate.month - 1);
                  });
                },
                icon: const Icon(Icons.chevron_left),
              ),
              Text(
                '${_getMonthName(_focusedDate.month)} ${_focusedDate.year}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3E2723),
                ),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    _focusedDate = DateTime(_focusedDate.year, _focusedDate.month + 1);
                  });
                },
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Days of week header
          Row(
            children: ['Min', 'Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab']
                .map((day) => Expanded(
              child: Center(
                child: Text(
                  day,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              ),
            ))
                .toList(),
          ),

          const SizedBox(height: 8),

          // Calendar Grid
          ..._buildCalendarWeeks(),

          const SizedBox(height: 16),

          // Selected date events
          if (_getEventsForDay(_selectedDate).isNotEmpty) ...[
            const Divider(),
            const SizedBox(height: 8),
            Text(
              'Jadwal ${_selectedDate.day} ${_getMonthName(_selectedDate.month)}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF3E2723),
              ),
            ),
            const SizedBox(height: 8),
            ..._getEventsForDay(_selectedDate).map((event) => _buildEventItem(event)),
          ],

          const SizedBox(height: 16),

          // Add schedule button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _showAddScheduleDialog(),
              icon: const Icon(Icons.add),
              label: const Text('Tambah Jadwal'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5D3A1D),
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildCalendarWeeks() {
    final firstDayOfMonth = DateTime(_focusedDate.year, _focusedDate.month, 1);
    final lastDayOfMonth = DateTime(_focusedDate.year, _focusedDate.month + 1, 0);
    final firstDayOfWeek = firstDayOfMonth.weekday % 7;

    List<Widget> weeks = [];
    List<Widget> currentWeek = [];

    // Add empty cells for days before the first day of the month
    for (int i = 0; i < firstDayOfWeek; i++) {
      currentWeek.add(const Expanded(child: SizedBox()));
    }

    // Add days of the month
    for (int day = 1; day <= lastDayOfMonth.day; day++) {
      final date = DateTime(_focusedDate.year, _focusedDate.month, day);
      final isSelected = _isSameDay(date, _selectedDate);
      final isToday = _isSameDay(date, DateTime.now());
      final hasEvents = _hasEventsForDay(date);

      currentWeek.add(
        Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                _selectedDate = date;
              });
            },
            child: Container(
              height: 40,
              margin: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF5D3A1D)
                    : isToday
                    ? Colors.red.withOpacity(0.3)
                    : null,
                borderRadius: BorderRadius.circular(8),
                border: hasEvents
                    ? Border.all(color: Colors.orange, width: 2)
                    : null,
              ),
              child: Center(
                child: Text(
                  day.toString(),
                  style: TextStyle(
                    color: isSelected
                        ? Colors.white
                        : isToday
                        ? Colors.red
                        : Colors.black,
                    fontWeight: isSelected || isToday || hasEvents
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      if (currentWeek.length == 7) {
        weeks.add(Row(children: currentWeek));
        currentWeek = [];
      }
    }

    // Add empty cells for remaining days
    while (currentWeek.length < 7) {
      currentWeek.add(const Expanded(child: SizedBox()));
    }
    if (currentWeek.isNotEmpty) {
      weeks.add(Row(children: currentWeek));
    }

    return weeks;
  }

  Widget _buildEventItem(Map<String, dynamic> event) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            _getEventIcon(event['type'] ?? 'study'),
            color: Colors.orange,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event['title'] ?? 'Jadwal Belajar',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3E2723),
                  ),
                ),
                if (event['time'] != null)
                  Text(
                    event['time'],
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _deleteEvent(event),
            icon: const Icon(Icons.delete, color: Colors.red, size: 16),
          ),
        ],
      ),
    );
  }

  IconData _getEventIcon(String type) {
    switch (type) {
      case 'quiz':
        return Icons.quiz;
      case 'reading':
        return Icons.book;
      case 'practice':
        return Icons.edit;
      default:
        return Icons.school;
    }
  }

  void _showAddScheduleDialog() {
    final titleController = TextEditingController();
    final timeController = TextEditingController();
    String selectedType = 'study';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tambah Jadwal Belajar'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Judul Kegiatan',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: timeController,
              decoration: const InputDecoration(
                labelText: 'Waktu (contoh: 14:00)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: selectedType,
              decoration: const InputDecoration(
                labelText: 'Jenis Kegiatan',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'study', child: Text('Belajar')),
                DropdownMenuItem(value: 'quiz', child: Text('Kuis')),
                DropdownMenuItem(value: 'reading', child: Text('Membaca')),
                DropdownMenuItem(value: 'practice', child: Text('Latihan')),
              ],
              onChanged: (value) {
                selectedType = value ?? 'study';
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.isNotEmpty) {
                _addEvent(titleController.text, timeController.text, selectedType);
                Navigator.pop(context);
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _addEvent(String title, String time, String type) {
    final dateKey = _getDateKey(_selectedDate);
    final event = {
      'title': title,
      'time': time,
      'type': type,
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
    };

    setState(() {
      if (_scheduleData[dateKey] == null) {
        _scheduleData[dateKey] = [];
      }
      _scheduleData[dateKey]!.add(event);
    });

    _saveScheduleData();
  }

  void _deleteEvent(Map<String, dynamic> event) {
    final dateKey = _getDateKey(_selectedDate);
    setState(() {
      _scheduleData[dateKey]?.removeWhere((e) => e['id'] == event['id']);
      if (_scheduleData[dateKey]?.isEmpty == true) {
        _scheduleData.remove(dateKey);
      }
    });
    _saveScheduleData();
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String _getMonthName(int month) {
    const months = [
      '', 'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return months[month];
  }
}