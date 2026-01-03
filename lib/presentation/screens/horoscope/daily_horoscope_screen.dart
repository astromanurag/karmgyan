import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/app_theme.dart';
import '../../../services/horoscope_service.dart';

class DailyHoroscopeScreen extends ConsumerStatefulWidget {
  final String? initialSign;
  
  const DailyHoroscopeScreen({super.key, this.initialSign});

  @override
  ConsumerState<DailyHoroscopeScreen> createState() => _DailyHoroscopeScreenState();
}

class _DailyHoroscopeScreenState extends ConsumerState<DailyHoroscopeScreen> {
  late String _selectedSign;
  Map<String, dynamic>? _horoscope;
  bool _isLoading = true;

  final List<int> _signColors = [
    0xFFE53935, 0xFF43A047, 0xFFFDD835, 0xFF90CAF9, 0xFFFF9800, 0xFF8D6E63,
    0xFFEC407A, 0xFF7B1FA2, 0xFF5C6BC0, 0xFF455A64, 0xFF00ACC1, 0xFF26A69A,
  ];

  @override
  void initState() {
    super.initState();
    _selectedSign = widget.initialSign ?? 'Aries';
    _loadHoroscope();
  }

  void _loadHoroscope() {
    setState(() => _isLoading = true);
    final horoscope = HoroscopeService().getDailyHoroscope(_selectedSign);
    setState(() {
      _horoscope = horoscope;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0D1B2A), Color(0xFF1B263B), Color(0xFF415A77)],
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
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.arrow_back_ios, color: Colors.white),
                    ),
                    Icon(Icons.auto_awesome, color: AppTheme.accentGold, size: 28),
                    const SizedBox(width: 12),
                    Text(
                      'Daily Horoscope',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Sign Selector
              SizedBox(
                height: 90,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: HoroscopeService.zodiacSigns.length,
                  itemBuilder: (context, index) {
                    final sign = HoroscopeService.zodiacSigns[index];
                    final isSelected = _selectedSign == sign['name'];
                    final color = Color(_signColors[index]);
                    
                    return GestureDetector(
                      onTap: () {
                        setState(() => _selectedSign = sign['name']);
                        _loadHoroscope();
                      },
                      child: Container(
                        width: 70,
                        margin: const EdgeInsets.only(right: 10),
                        decoration: BoxDecoration(
                          gradient: isSelected
                              ? LinearGradient(colors: [color.withOpacity(0.5), color.withOpacity(0.2)])
                              : null,
                          color: isSelected ? null : Color(0xFF1F2833),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected ? color : Colors.white.withOpacity(0.1),
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              sign['symbol'],
                              style: TextStyle(fontSize: 24, color: color),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              sign['name'],
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.white70,
                                fontSize: 10,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              
              // Horoscope Content
              Expanded(
                child: _isLoading
                    ? Center(child: CircularProgressIndicator(color: AppTheme.accentGold))
                    : _horoscope == null
                        ? Center(child: Text('Error loading horoscope', style: TextStyle(color: Colors.white)))
                        : _buildHoroscopeContent(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHoroscopeContent() {
    final signIndex = HoroscopeService.zodiacSigns.indexWhere((s) => s['name'] == _selectedSign);
    final signColor = Color(_signColors[signIndex >= 0 ? signIndex : 0]);
    final predictions = _horoscope!['predictions'] as Map<String, dynamic>;
    final ratings = _horoscope!['ratings'] as Map<String, dynamic>;
    final lucky = _horoscope!['lucky'] as Map<String, dynamic>;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sign Header Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [signColor.withOpacity(0.3), signColor.withOpacity(0.1)],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: signColor.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [signColor, signColor.withOpacity(0.7)]),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      _horoscope!['symbol'],
                      style: TextStyle(fontSize: 36, color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _horoscope!['sign'],
                        style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${_horoscope!['hindi']} • ${_horoscope!['element']}',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                      Text(
                        _horoscope!['dates'],
                        style: TextStyle(color: Colors.white54, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    Text('Overall', style: TextStyle(color: Colors.white54, fontSize: 10)),
                    Row(
                      children: List.generate(5, (i) => Icon(
                        i < (ratings['overall'] as double) ? Icons.star : Icons.star_border,
                        color: AppTheme.accentGold,
                        size: 16,
                      )),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          
          // Today's Prediction
          Text('Today\'s Prediction', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Color(0xFF1F2833),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Text(
              predictions['general'] ?? '',
              style: TextStyle(color: Colors.white, fontSize: 15, height: 1.5),
            ),
          ),
          const SizedBox(height: 20),
          
          // Category Predictions
          _buildCategoryCard('Love & Relationships', Icons.favorite, predictions['love'], ratings['love'], Colors.pink),
          _buildCategoryCard('Career & Work', Icons.work, predictions['career'], ratings['career'], Colors.blue),
          _buildCategoryCard('Health & Wellness', Icons.health_and_safety, predictions['health'], ratings['health'], Colors.green),
          _buildCategoryCard('Finance & Money', Icons.attach_money, predictions['finance'], null, Colors.amber),
          
          const SizedBox(height: 20),
          
          // Lucky Section
          Text('Lucky For Today', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildLuckyItem('Number', '${lucky['number']}', Icons.tag, signColor)),
              const SizedBox(width: 12),
              Expanded(child: _buildLuckyItem('Color', '${lucky['color']}', Icons.palette, signColor)),
              const SizedBox(width: 12),
              Expanded(child: _buildLuckyItem('Time', '${lucky['time']}', Icons.access_time, signColor)),
            ],
          ),
          const SizedBox(height: 20),
          
          // Compatible Signs
          Text('Compatible Signs', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: (_horoscope!['compatibility'] as List<dynamic>).map<Widget>((sign) {
              final idx = HoroscopeService.zodiacSigns.indexWhere((s) => s['name'] == sign);
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Color(_signColors[idx >= 0 ? idx : 0]).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Color(_signColors[idx >= 0 ? idx : 0]).withOpacity(0.5)),
                ),
                child: Text(
                  '$sign ${HoroscopeService.zodiacSigns[idx >= 0 ? idx : 0]['symbol']}',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(String title, IconData icon, String? prediction, double? rating, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFF1F2833),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Text(title, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              if (rating != null) ...[
                const Spacer(),
                Row(
                  children: List.generate(5, (i) => Icon(
                    i < rating ? Icons.star : Icons.star_border,
                    color: color,
                    size: 14,
                  )),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          Text(
            prediction ?? '',
            style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _buildLuckyItem(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Color(0xFF1F2833),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 6),
          Text(label, style: TextStyle(color: Colors.white54, fontSize: 10)),
          Text(value, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
        ],
      ),
    );
  }
}

