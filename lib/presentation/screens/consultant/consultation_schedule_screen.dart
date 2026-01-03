import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../config/app_theme.dart';
import '../../../services/consultant_service.dart';

class ConsultationScheduleScreen extends StatefulWidget {
  const ConsultationScheduleScreen({super.key});

  @override
  State<ConsultationScheduleScreen> createState() =>
      _ConsultationScheduleScreenState();
}

class _ConsultationScheduleScreenState
    extends State<ConsultationScheduleScreen> {
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  Map<DateTime, List<String>> _events = {};

  @override
  void initState() {
    super.initState();
    _loadSchedule();
  }

  Future<void> _loadSchedule() async {
    // Load schedule data
    final availability = {
      'monday': ['09:00-12:00', '14:00-18:00'],
      'tuesday': ['09:00-12:00', '14:00-18:00'],
    };
    // In production, fetch from API
  }

  List<String> _getEventsForDay(DateTime day) {
    return _events[DateTime(day.year, day.month, day.day)] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Schedule Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Navigate to availability settings
            },
          ),
        ],
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            eventLoader: _getEventsForDay,
            calendarStyle: CalendarStyle(
              selectedDecoration: BoxDecoration(
                color: AppTheme.primaryBlue,
                shape: BoxShape.circle,
              ),
              todayDecoration: BoxDecoration(
                color: AppTheme.accentGold,
                shape: BoxShape.circle,
              ),
            ),
            headerStyle: HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  'Available Time Slots',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),
                _TimeSlotChip('09:00 AM - 12:00 PM', true),
                _TimeSlotChip('02:00 PM - 06:00 PM', true),
                _TimeSlotChip('07:00 PM - 09:00 PM', false),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TimeSlotChip extends StatelessWidget {
  final String time;
  final bool available;

  const _TimeSlotChip(this.time, this.available);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: available ? Colors.green.shade50 : Colors.grey.shade200,
      child: ListTile(
        title: Text(time),
        trailing: available
            ? const Icon(Icons.check_circle, color: Colors.green)
            : const Icon(Icons.cancel, color: Colors.grey),
      ),
    );
  }
}

