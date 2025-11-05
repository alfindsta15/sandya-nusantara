import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ScheduleCalendar extends StatefulWidget {
  const ScheduleCalendar({Key? key, required Map<DateTime, List<Map<String, dynamic>>> events, required Null Function(dynamic selectedDay) onDaySelected}) : super(key: key);

  @override
  State<ScheduleCalendar> createState() => _ScheduleCalendarState();
}

class _ScheduleCalendarState extends State<ScheduleCalendar> {
  late final ValueNotifier<List<Event>> _selectedEvents;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<Event>> _events = {};

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay!));
    _loadEvents();
  }

  @override
  void dispose() {
    _selectedEvents.dispose();
    super.dispose();
  }

  Future<void> _loadEvents() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final schedulesJson = prefs.getString('learning_schedules') ?? '[]';
      final schedulesList = json.decode(schedulesJson) as List;

      final Map<DateTime, List<Event>> events = {};

      for (var schedule in schedulesList) {
        final date = DateTime.parse(schedule['date']);
        final dateKey = DateTime(date.year, date.month, date.day);

        final event = Event(
          title: schedule['title'] ?? 'Jadwal Sinau',
          time: schedule['time'] ?? '00:00',
          moduleKey: schedule['moduleKey'] ?? 'general',
        );

        if (events[dateKey] != null) {
          events[dateKey]!.add(event);
        } else {
          events[dateKey] = [event];
        }
      }

      setState(() {
        _events = events;
        _selectedEvents.value = _getEventsForDay(_selectedDay!);
      });
    } catch (e) {
      print('Error loading events: $e');
    }
  }

  List<Event> _getEventsForDay(DateTime day) {
    final dateKey = DateTime(day.year, day.month, day.day);
    return _events[dateKey] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: Column(
        children: [
          TableCalendar<Event>(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            eventLoader: _getEventsForDay,
            startingDayOfWeek: StartingDayOfWeek.monday,
            calendarStyle: const CalendarStyle(
              outsideDaysVisible: false,
              weekendTextStyle: TextStyle(color: Colors.red),
              holidayTextStyle: TextStyle(color: Colors.red),
              selectedDecoration: BoxDecoration(
                color: Color(0xFF5D3A1D),
                shape: BoxShape.circle,
              ),
              todayDecoration: BoxDecoration(
                color: Colors.orange,
                shape: BoxShape.circle,
              ),
              markerDecoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
            ),
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              titleTextStyle: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF3E2723),
              ),
              leftChevronIcon: Icon(
                Icons.chevron_left,
                color: Color(0xFF5D3A1D),
              ),
              rightChevronIcon: Icon(
                Icons.chevron_right,
                color: Color(0xFF5D3A1D),
              ),
            ),
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              if (!isSameDay(_selectedDay, selectedDay)) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
                _selectedEvents.value = _getEventsForDay(selectedDay);
              }
            },
            onFormatChanged: (format) {
              if (_calendarFormat != format) {
                setState(() {
                  _calendarFormat = format;
                });
              }
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
          ),
          const SizedBox(height: 8),
          ValueListenableBuilder<List<Event>>(
            valueListenable: _selectedEvents,
            builder: (context, value, _) {
              return Container(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Jadwal ${_selectedDay != null ? "${_selectedDay!.day}/${_selectedDay!.month}/${_selectedDay!.year}" : ""}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF3E2723),
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (value.isEmpty) ...[
                      const Text(
                        'Durung wonten jadwal ing dino iki',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ] else ...[
                      ...value.map((event) => _buildEventItem(event)),
                    ],
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEventItem(Event event) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: _getModuleColor(event.moduleKey).withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: _getModuleColor(event.moduleKey).withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            _getModuleIcon(event.moduleKey),
            size: 16,
            color: _getModuleColor(event.moduleKey),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3E2723),
                  ),
                ),
                Text(
                  event.time,
                  style: const TextStyle(
                    fontSize: 10,
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

  Color _getModuleColor(String moduleKey) {
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

  IconData _getModuleIcon(String moduleKey) {
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
}

class Event {
  final String title;
  final String time;
  final String moduleKey;

  const Event({
    required this.title,
    required this.time,
    required this.moduleKey,
  });

  @override
  String toString() => title;
}
