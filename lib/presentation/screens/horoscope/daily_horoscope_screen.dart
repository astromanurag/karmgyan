import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/app_theme.dart';
import '../../../services/horoscope_service.dart';
import '../../widgets/cosmic_background.dart';

class DailyHoroscopeScreen extends ConsumerStatefulWidget {
  final String? zodiacSign;
  
  const DailyHoroscopeScreen({super.key, this.zodiacSign});

  @override
  ConsumerState<DailyHoroscopeScreen> createState() => _DailyHoroscopeScreenState();
}

class _DailyHoroscopeScreenState extends ConsumerState<DailyHoroscopeScreen> {
  Map<String, dynamic>? _horoscopeData;
  bool _isLoading = true;
  String _selectedSign = 'Aries';

  final List<String> _zodiacSigns = [
    'Aries', 'Taurus', 'Gemini', 'Cancer', 'Leo', 'Virgo',
    'Libra', 'Scorpio', 'Sagittarius', 'Capricorn', 'Aquarius', 'Pisces'
  ];

  @override
  void initState() {
    super.initState();
    _selectedSign = widget.zodiacSign ?? 'Aries';
    _loadHoroscope();
  }

  Future<void> _loadHoroscope() async {
    setState(() => _isLoading = true);
    
    try {
      final data = await HoroscopeService.getDailyHoroscope(_selectedSign);
      setState(() {
        _horoscopeData = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading horoscope: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CosmicBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.stars_rounded,
                      color: AppTheme.accentGold,
                      size: 32,
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Daily Horoscope',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              // Zodiac Sign Selector
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButton<String>(
                  value: _selectedSign,
                  isExpanded: true,
                  dropdownColor: AppTheme.primaryNavy,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                  items: _zodiacSigns.map((sign) {
                    return DropdownMenuItem(
                      value: sign,
                      child: Text(sign),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedSign = value);
                      _loadHoroscope();
                    }
                  },
                ),
              ),

              const SizedBox(height: 16),

              // Horoscope Content
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator(color: AppTheme.accentGold))
                    : _horoscopeData == null
                        ? const Center(child: Text('No horoscope data available', style: TextStyle(color: Colors.white)))
                        : _buildHoroscopeContent(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHoroscopeContent() {
    final content = _horoscopeData!['content'] as Map<String, dynamic>? ?? {};
    final date = _horoscopeData!['date'] as String? ?? DateTime.now().toString().split(' ')[0];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date
          Center(
            child: Text(
              date,
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Overall Forecast
          if (content['overall_forecast'] != null && content['overall_forecast'].toString().isNotEmpty)
            _buildSection(
              'Overall Forecast',
              Icons.auto_awesome,
              content['overall_forecast'].toString(),
            ),

          // Love & Relationships
          if (content['love'] != null && content['love'].toString().isNotEmpty)
            _buildSection(
              'Love & Relationships',
              Icons.favorite,
              content['love'].toString(),
            ),

          // Career & Finance
          if (content['career'] != null && content['career'].toString().isNotEmpty)
            _buildSection(
              'Career & Finance',
              Icons.work,
              content['career'].toString(),
            ),

          // Health & Wellness
          if (content['health'] != null && content['health'].toString().isNotEmpty)
            _buildSection(
              'Health & Wellness',
              Icons.health_and_safety,
              content['health'].toString(),
            ),

          // Personal Growth
          if (content['personal_growth'] != null && content['personal_growth'].toString().isNotEmpty)
            _buildSection(
              'Personal Growth',
              Icons.self_improvement,
              content['personal_growth'].toString(),
            ),

          const SizedBox(height: 16),

          // Lucky Numbers & Colors
          Row(
            children: [
              // Lucky Numbers
              if (content['lucky_numbers'] != null)
                Expanded(
                  child: _buildLuckySection(
                    'Lucky Numbers',
                    Icons.numbers,
                    content['lucky_numbers'] as List?,
                  ),
                ),
              const SizedBox(width: 12),
              // Lucky Colors
              if (content['lucky_colors'] != null)
                Expanded(
                  child: _buildLuckySection(
                    'Lucky Colors',
                    Icons.palette,
                    content['lucky_colors'] as List?,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, IconData icon, String content) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.accentGold.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppTheme.accentGold, size: 24),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: AppTheme.accentGold,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLuckySection(String title, IconData icon, List? items) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.accentGold.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: AppTheme.accentGold, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: AppTheme.accentGold,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (items != null && items.isNotEmpty)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: items.map((item) {
                if (icon == Icons.palette) {
                  // Color chips
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.accentGold.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppTheme.accentGold),
                    ),
                    child: Text(
                      item.toString(),
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  );
                } else {
                  // Number chips
                  return Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppTheme.accentGold,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        item.toString(),
                        style: const TextStyle(
                          color: AppTheme.primaryNavy,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                }
              }).toList(),
            )
          else
            const Text(
              'N/A',
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
        ],
      ),
    );
  }
}
