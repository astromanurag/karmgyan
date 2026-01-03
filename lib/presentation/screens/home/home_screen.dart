import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:math' as math;
import '../../../config/app_theme.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../services/panchang_service.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

// Zodiac signs data - defined outside the State class for stability
const List<Map<String, dynamic>> _kZodiacSigns = [
  {'name': 'Aries', 'symbol': '♈', 'hindi': 'मेष', 'colorValue': 0xFFE53935},
  {'name': 'Taurus', 'symbol': '♉', 'hindi': 'वृषभ', 'colorValue': 0xFF43A047},
  {'name': 'Gemini', 'symbol': '♊', 'hindi': 'मिथुन', 'colorValue': 0xFFFDD835},
  {'name': 'Cancer', 'symbol': '♋', 'hindi': 'कर्क', 'colorValue': 0xFF90CAF9},
  {'name': 'Leo', 'symbol': '♌', 'hindi': 'सिंह', 'colorValue': 0xFFFF9800},
  {'name': 'Virgo', 'symbol': '♍', 'hindi': 'कन्या', 'colorValue': 0xFF8D6E63},
  {'name': 'Libra', 'symbol': '♎', 'hindi': 'तुला', 'colorValue': 0xFFEC407A},
  {'name': 'Scorpio', 'symbol': '♏', 'hindi': 'वृश्चिक', 'colorValue': 0xFF7B1FA2},
  {'name': 'Sagittarius', 'symbol': '♐', 'hindi': 'धनु', 'colorValue': 0xFF5C6BC0},
  {'name': 'Capricorn', 'symbol': '♑', 'hindi': 'मकर', 'colorValue': 0xFF455A64},
  {'name': 'Aquarius', 'symbol': '♒', 'hindi': 'कुंभ', 'colorValue': 0xFF00ACC1},
  {'name': 'Pisces', 'symbol': '♓', 'hindi': 'मीन', 'colorValue': 0xFF26A69A},
];

class _HomeScreenState extends ConsumerState<HomeScreen> with TickerProviderStateMixin {
  Map<String, dynamic>? _panchangData;
  bool _isLoading = true;
  AnimationController? _starController;

  @override
  void initState() {
    super.initState();
    _starController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
    _loadPanchang();
  }

  @override
  void dispose() {
    _starController?.dispose();
    super.dispose();
  }

  Future<void> _loadPanchang() async {
    setState(() => _isLoading = true);
    try {
      final data = await PanchangService().getTodayPanchang();
      if (mounted) {
        setState(() {
          _panchangData = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          // Use mock data if service fails
          _panchangData = {
            'tithi': 'Shukla Ekadashi',
            'nakshatra': 'Rohini',
            'yoga': 'Siddhi',
            'karana': 'Bava',
            'sunrise': '06:42',
            'sunset': '17:58',
            'moonrise': '14:23',
            'vara': _getDayName(),
          };
        });
      }
    }
  }

  String _getDayName() {
    final days = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
    return days[DateTime.now().weekday % 7];
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  double _getMoonPhase() {
    // Simplified moon phase calculation
    final now = DateTime.now();
    final newMoon = DateTime(2024, 1, 11); // Known new moon
    final diff = now.difference(newMoon).inDays;
    return (diff % 29.5) / 29.5;
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0D1B2A),  // Deep space blue
              Color(0xFF1B263B),
              Color(0xFF415A77),
            ],
          ),
        ),
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: _loadPanchang,
            child: CustomScrollView(
              slivers: [
                // Cosmic Header
                SliverToBoxAdapter(
                  child: _buildCosmicHeader(user?.name ?? 'Seeker'),
                ),
                
                // Today's Panchang
                SliverToBoxAdapter(
                  child: _buildTodaysPanchang(),
                ),
                
                // Moon Phase & Auspicious Time
                SliverToBoxAdapter(
                  child: _buildMoonAndTime(),
                ),
                
                // Daily Horoscope
                SliverToBoxAdapter(
                  child: _buildDailyHoroscope(),
                ),
                
                // AI Predictions Banner
                SliverToBoxAdapter(
                  child: _buildAIPredictionsBanner(),
                ),
                
                // Quick Features
                SliverToBoxAdapter(
                  child: _buildQuickFeatures(),
                ),
                
                // Explore Services
                SliverToBoxAdapter(
                  child: _buildExploreServices(),
                ),
                
                const SliverToBoxAdapter(
                  child: SizedBox(height: 100),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCosmicHeader(String userName) {
    final now = DateTime.now();
    final dateStr = '${_getWeekday(now.weekday)}, ${now.day} ${_getMonth(now.month)} ${now.year}';

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppTheme.accentGold, AppTheme.accentGoldLight],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.auto_awesome, color: AppTheme.primaryNavy, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'karmgyan',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: () {},
                    icon: Icon(Icons.notifications_outlined, color: Colors.white70),
                  ),
                  GestureDetector(
                    onTap: () => context.push('/profile'),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppTheme.accentGold, AppTheme.accentGoldLight],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          userName[0].toUpperCase(),
                          style: TextStyle(
                            color: AppTheme.primaryNavy,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Greeting with stars
          Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getGreeting(),
                    style: TextStyle(
                      color: AppTheme.accentGold,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    userName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppTheme.accentGold.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.calendar_today, size: 14, color: AppTheme.accentGold),
                        const SizedBox(width: 8),
                        Text(
                          dateStr,
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              // Animated stars
              if (_starController != null)
                Positioned(
                  right: 0,
                  top: 0,
                  child: AnimatedBuilder(
                    animation: _starController!,
                    builder: (context, child) {
                      // Use (sin + 1) / 2 to get 0-1 range, then scale to 0.3-1.0
                      final sinValue = (math.sin(_starController!.value * math.pi * 2) + 1) / 2;
                      return Opacity(
                        opacity: 0.3 + 0.7 * sinValue,
                        child: Icon(
                          Icons.star,
                          color: AppTheme.accentGold,
                          size: 20,
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTodaysPanchang() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF2D3A4A),
            Color(0xFF1F2833),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.accentGold.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.accentGold.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.wb_sunny_outlined, color: AppTheme.accentGold),
              ),
              const SizedBox(width: 12),
              Text(
                "Today's Panchang",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () => context.push('/calendar'),
                child: Text('View Calendar →', style: TextStyle(color: AppTheme.accentGold)),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (_isLoading)
            Center(child: CircularProgressIndicator(color: AppTheme.accentGold))
          else
            _buildPanchangGrid(),
        ],
      ),
    );
  }

  Widget _buildPanchangGrid() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildPanchangItem('Tithi', _panchangData?['tithi'] ?? 'N/A', Icons.brightness_3)),
            const SizedBox(width: 12),
            Expanded(child: _buildPanchangItem('Nakshatra', _panchangData?['nakshatra'] ?? 'N/A', Icons.star)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildPanchangItem('Yoga', _panchangData?['yoga'] ?? 'N/A', Icons.spa)),
            const SizedBox(width: 12),
            Expanded(child: _buildPanchangItem('Karana', _panchangData?['karana'] ?? 'N/A', Icons.nights_stay)),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildTimeInfo('Sunrise', _panchangData?['sunrise'] ?? '06:30', Icons.wb_twilight, Colors.orange),
              Container(width: 1, height: 30, color: Colors.white24),
              _buildTimeInfo('Sunset', _panchangData?['sunset'] ?? '18:00', Icons.nights_stay, Colors.purple),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPanchangItem(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: AppTheme.accentGold),
              const SizedBox(width: 6),
              Text(label, style: TextStyle(color: Colors.white54, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildTimeInfo(String label, String time, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: Colors.white54, fontSize: 11)),
        Text(time, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildMoonAndTime() {
    final moonPhase = _getMoonPhase();
    final moonName = _getMoonPhaseName(moonPhase);
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          // Moon Phase
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF2C3E50), Color(0xFF1A252F)],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: Column(
                children: [
                  _buildMoonIcon(moonPhase),
                  const SizedBox(height: 8),
                  Text(
                    'Moon Phase',
                    style: TextStyle(color: Colors.white54, fontSize: 11),
                  ),
                  Text(
                    moonName,
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Rahukaal
          Expanded(
            child: GestureDetector(
              onTap: () => context.push('/muhurat'),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF4A1C40), Color(0xFF2D1A30)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.purple.withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
                    const SizedBox(height: 8),
                    Text('Rahu Kaal', style: TextStyle(color: Colors.white54, fontSize: 11)),
                    Text('10:30 - 12:00', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoonIcon(double phase) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [Colors.white, Colors.grey.shade400],
          center: Alignment(phase < 0.5 ? -0.3 : 0.3, 0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withOpacity(0.3),
            blurRadius: 10,
          ),
        ],
      ),
    );
  }

  String _getMoonPhaseName(double phase) {
    if (phase < 0.03) return 'New Moon';
    if (phase < 0.22) return 'Waxing Crescent';
    if (phase < 0.28) return 'First Quarter';
    if (phase < 0.47) return 'Waxing Gibbous';
    if (phase < 0.53) return 'Full Moon';
    if (phase < 0.72) return 'Waning Gibbous';
    if (phase < 0.78) return 'Last Quarter';
    if (phase < 0.97) return 'Waning Crescent';
    return 'New Moon';
  }

  Widget _buildDailyHoroscope() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome, color: AppTheme.accentGold, size: 20),
              const SizedBox(width: 8),
              Text(
                'Daily Horoscope',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _kZodiacSigns.length,
              itemBuilder: (context, index) {
                final sign = _kZodiacSigns[index];
                final signColor = Color(sign['colorValue'] as int);
                return GestureDetector(
                  onTap: () {
                    context.push('/horoscope?sign=${sign['name']}');
                  },
                  child: Container(
                    width: 85,
                    margin: EdgeInsets.only(right: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          signColor.withOpacity(0.3),
                          signColor.withOpacity(0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: signColor.withOpacity(0.3)),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          sign['symbol'] as String,
                          style: TextStyle(fontSize: 28, color: signColor),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          sign['name'] as String,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          sign['hindi'] as String,
                          style: TextStyle(color: Colors.white54, fontSize: 9),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAIPredictionsBanner() {
    return GestureDetector(
      onTap: () => context.push('/ai'),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF6366F1),
              const Color(0xFF8B5CF6),
              const Color(0xFFD946EF),
            ],
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF8B5CF6).withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.auto_awesome, color: Colors.white, size: 14),
                        SizedBox(width: 4),
                        Text(
                          'NEW',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'AI Predictions',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Ask any question about your chart. Get personalized predictions powered by AI.',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Try Now',
                          style: TextStyle(
                            color: Color(0xFF6366F1),
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(width: 6),
                        Icon(Icons.arrow_forward, color: Color(0xFF6366F1), size: 18),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            AnimatedBuilder(
              animation: _starController!,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _starController!.value * 2 * math.pi,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.psychology,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickFeatures() {
    final features = [
      {'icon': Icons.auto_graph, 'title': 'Birth Chart', 'route': '/birth-chart', 'color': const Color(0xFFFF6B6B)},
      {'icon': Icons.grid_view, 'title': 'Varga Charts', 'route': '/varga-charts', 'color': const Color(0xFF9C27B0)},
      {'icon': Icons.calculate, 'title': 'Numerology', 'route': '/numerology', 'color': const Color(0xFFFFD700)},
      {'icon': Icons.favorite, 'title': 'Match', 'route': '/matching', 'color': const Color(0xFFFF8E53)},
      {'icon': Icons.chat_bubble, 'title': 'AI Chat', 'route': '/ai-chat', 'color': const Color(0xFF8B5CF6)},
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.flash_on, color: AppTheme.accentGold, size: 20),
              const SizedBox(width: 8),
              Text(
                'Quick Access',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: features.map((f) {
              return Expanded(
                child: GestureDetector(
                  onTap: () => context.push(f['route'] as String),
                  child: Container(
                    margin: EdgeInsets.only(right: f == features.last ? 0 : 10),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: (f['color'] as Color).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: (f['color'] as Color).withOpacity(0.3)),
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: (f['color'] as Color).withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(f['icon'] as IconData, color: f['color'] as Color, size: 22),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          f['title'] as String,
                          style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w500),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildExploreServices() {
    final services = [
      {
        'title': 'Generate Kundli',
        'desc': 'Create your detailed birth chart',
        'icon': Icons.stars,
        'gradient': [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
        'route': '/birth-chart',
      },
      {
        'title': 'Kundli Matching',
        'desc': '36 Gunas compatibility analysis',
        'icon': Icons.favorite,
        'gradient': [Color(0xFF4ECDC4), Color(0xFF556270)],
        'route': '/matching',
      },
      {
        'title': 'Talk to Astrologer',
        'desc': 'Get expert guidance',
        'icon': Icons.headset_mic,
        'gradient': [Color(0xFF667EEA), Color(0xFF764BA2)],
        'route': '/consultations',
      },
      {
        'title': 'Detailed Reports',
        'desc': 'Career, Marriage, Health & more',
        'icon': Icons.description,
        'gradient': [Color(0xFFF093FB), Color(0xFFF5576C)],
        'route': '/reports',
      },
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.explore, color: AppTheme.accentGold, size: 20),
              const SizedBox(width: 8),
              Text(
                'Explore Services',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...services.map((s) => _buildServiceCard(s)).toList(),
        ],
      ),
    );
  }

  Widget _buildServiceCard(Map<String, dynamic> service) {
    return GestureDetector(
      onTap: () => context.push(service['route'] as String),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              (service['gradient'] as List<Color>)[0].withOpacity(0.2),
              (service['gradient'] as List<Color>)[1].withOpacity(0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: (service['gradient'] as List<Color>)[0].withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: service['gradient'] as List<Color>),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(service['icon'] as IconData, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    service['title'] as String,
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    service['desc'] as String,
                    style: TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: Colors.white38, size: 16),
          ],
        ),
      ),
    );
  }

  String _getWeekday(int weekday) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[weekday - 1];
  }

  String _getMonth(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }
}
