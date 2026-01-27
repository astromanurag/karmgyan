import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:go_router/go_router.dart';
import '../../../config/app_theme.dart';
import '../../../services/panchang_service.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic>? sampleData;
  
  const CalendarScreen({super.key, this.sampleData});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.month;
  Map<String, dynamic>? _panchangData;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Use sample data date if provided
    if (widget.sampleData != null && widget.sampleData!['date'] != null) {
      _selectedDay = widget.sampleData!['date'] as DateTime;
      _focusedDay = _selectedDay;
    }
    _loadPanchang(forDay: _selectedDay);
  }

  Future<void> _loadPanchang({required DateTime forDay}) async {
    print('📆 Loading panchang for: ${forDay.toIso8601String().split('T')[0]}');
    
    setState(() {
      _isLoading = true;
      _panchangData = null; // Clear old data while loading
    });
    
    try {
      final result = await PanchangService().getDailyPanchang(
        date: forDay,
      );
      
      print('✅ Panchang loaded successfully: ${result['nakshatra']}, ${result['tithi']}');
      
      if (mounted) {
        setState(() {
          _panchangData = result;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('❌ Failed to load panchang: $e');
      
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load Panchang: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0D1B2A),
              Color(0xFF1B263B),
              Color(0xFF415A77),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.calendar_month, color: AppTheme.accentGold, size: 28),
                    const SizedBox(width: 12),
                    Text(
                      'Panchang Calendar',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => context.push('/muhurat'),
                      icon: Icon(Icons.access_time, color: AppTheme.accentGold),
                    ),
                  ],
                ),
              ),
              
              // Calendar
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Color(0xFF1F2833),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: TableCalendar(
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
                  focusedDay: _focusedDay,
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  calendarFormat: _calendarFormat,
                  onFormatChanged: (format) {
                    setState(() => _calendarFormat = format);
                  },
                  onDaySelected: (selectedDay, focusedDay) {
                    if (!isSameDay(_selectedDay, selectedDay)) {
                      setState(() {
                        _selectedDay = selectedDay;
                        _focusedDay = focusedDay;
                      });
                      // Load panchang for the newly selected day
                      _loadPanchang(forDay: selectedDay);
                    }
                  },
                  calendarStyle: CalendarStyle(
                    defaultTextStyle: TextStyle(color: Colors.white),
                    weekendTextStyle: TextStyle(color: Colors.white70),
                    outsideTextStyle: TextStyle(color: Colors.white30),
                    selectedDecoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppTheme.accentGold, AppTheme.accentGoldLight],
                      ),
                      shape: BoxShape.circle,
                    ),
                    selectedTextStyle: TextStyle(color: AppTheme.primaryNavy, fontWeight: FontWeight.bold),
                    todayDecoration: BoxDecoration(
                      color: AppTheme.cosmicPurple.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    todayTextStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  daysOfWeekStyle: DaysOfWeekStyle(
                    weekdayStyle: TextStyle(color: AppTheme.accentGold, fontWeight: FontWeight.w600),
                    weekendStyle: TextStyle(color: AppTheme.accentGold.withOpacity(0.7), fontWeight: FontWeight.w600),
                  ),
                  headerStyle: HeaderStyle(
                    formatButtonVisible: true,
                    titleCentered: true,
                    formatButtonShowsNext: false,
                    titleTextStyle: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    leftChevronIcon: Icon(Icons.chevron_left, color: AppTheme.accentGold),
                    rightChevronIcon: Icon(Icons.chevron_right, color: AppTheme.accentGold),
                    formatButtonDecoration: BoxDecoration(
                      gradient: LinearGradient(colors: [AppTheme.accentGold, AppTheme.accentGoldLight]),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    formatButtonTextStyle: TextStyle(color: AppTheme.primaryNavy, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Panchang Data
              Expanded(
                child: _isLoading
                    ? Center(child: CircularProgressIndicator(color: AppTheme.accentGold))
                    : _buildPanchangView(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPanchangView() {
    // Show placeholder if no data
    if (_panchangData == null) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.calendar_today, size: 64, color: Colors.white30),
              const SizedBox(height: 16),
              Text(
                'Select a date to view Panchang',
                style: TextStyle(color: Colors.white54, fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date Header with debug info
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [AppTheme.accentGold.withOpacity(0.2), Colors.transparent]),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '${_selectedDay.day}',
                      style: TextStyle(color: AppTheme.accentGold, fontSize: 32, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getMonthName(_selectedDay.month),
                          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                        Text(
                          '${_getDayName(_selectedDay.weekday)}, ${_selectedDay.year}',
                          style: TextStyle(color: Colors.white54, fontSize: 12),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Text(
                      _panchangData?['vara'] ?? '',
                      style: TextStyle(color: AppTheme.accentGold, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                // Show the date from panchang data for debugging
                if (_panchangData != null && _panchangData!['date'] != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      'Data for: ${_panchangData!['date']}',
                      style: TextStyle(color: Colors.white30, fontSize: 10),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          // Panchang Grid
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Main Panchang Elements
                  Row(
                    children: [
                      Expanded(child: _buildPanchangTile('Tithi', _panchangData?['tithi'] ?? 'N/A', Icons.brightness_3)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildPanchangTile('Nakshatra', _panchangData?['nakshatra'] ?? 'N/A', Icons.star)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _buildPanchangTile('Yoga', _panchangData?['yoga'] ?? 'N/A', Icons.spa)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildPanchangTile('Karana', _panchangData?['karana'] ?? 'N/A', Icons.nights_stay)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Sun & Moon Times
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Color(0xFF1F2833),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Sun & Moon', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildTimeItem('Sunrise', _panchangData?['sunrise'] ?? '06:30', Icons.wb_sunny, Colors.orange),
                            _buildTimeItem('Sunset', _panchangData?['sunset'] ?? '18:00', Icons.nights_stay, Colors.purple),
                            _buildTimeItem('Moonrise', _panchangData?['moonrise'] ?? '14:00', Icons.brightness_2, Colors.blue),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // Inauspicious Times
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Color(0xFF2D1A30),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.red.withOpacity(0.2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.warning_amber, color: Colors.orange, size: 20),
                            const SizedBox(width: 8),
                            Text('Inauspicious Times', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildBadTime('Rahu Kaal', _panchangData?['rahu_kaal'] ?? '10:30-12:00'),
                            _buildBadTime('Gulika', _panchangData?['gulika_kaal'] ?? '13:30-15:00'),
                            _buildBadTime('Yamaghanda', _panchangData?['yamaghanda'] ?? '07:30-09:00'),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPanchangTile(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFF1F2833),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: AppTheme.accentGold),
              const SizedBox(width: 6),
              Text(label, style: TextStyle(color: Colors.white54, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildTimeItem(String label, String time, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 6),
        Text(label, style: TextStyle(color: Colors.white54, fontSize: 10)),
        Text(time, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
      ],
    );
  }

  Widget _buildBadTime(String label, String time) {
    return Column(
      children: [
        Text(label, style: TextStyle(color: Colors.white54, fontSize: 10)),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(time, style: TextStyle(color: Colors.red.shade300, fontWeight: FontWeight.w600, fontSize: 12)),
        ),
      ],
    );
  }

  String _getDayName(int weekday) {
    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return days[weekday - 1];
  }

  String _getMonthName(int month) {
    const months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
    return months[month - 1];
  }
}
