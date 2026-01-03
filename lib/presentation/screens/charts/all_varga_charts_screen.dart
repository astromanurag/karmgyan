import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/app_theme.dart';
import '../../../core/services/local_storage_service.dart';
import '../../widgets/diamond_chart_widget.dart';

/// All 16 main Varga (Divisional) Charts
class AllVargaChartsScreen extends ConsumerStatefulWidget {
  const AllVargaChartsScreen({super.key});

  @override
  ConsumerState<AllVargaChartsScreen> createState() => _AllVargaChartsScreenState();
}

class _AllVargaChartsScreenState extends ConsumerState<AllVargaChartsScreen> {
  Map<String, dynamic>? _birthData;
  String _selectedVarga = 'D1';
  bool _isLoading = true;

  // Varga chart definitions
  static const List<Map<String, dynamic>> _vargaCharts = [
    {'code': 'D1', 'name': 'Rashi', 'division': 1, 'signifies': 'Physical body, overall life'},
    {'code': 'D2', 'name': 'Hora', 'division': 2, 'signifies': 'Wealth and prosperity'},
    {'code': 'D3', 'name': 'Drekkana', 'division': 3, 'signifies': 'Siblings, courage, communication'},
    {'code': 'D4', 'name': 'Chaturthamsa', 'division': 4, 'signifies': 'Fortune, property, fixed assets'},
    {'code': 'D5', 'name': 'Panchamsa', 'division': 5, 'signifies': 'Spiritual inclination'},
    {'code': 'D6', 'name': 'Shashthamsa', 'division': 6, 'signifies': 'Health and diseases'},
    {'code': 'D7', 'name': 'Saptamsa', 'division': 7, 'signifies': 'Children and progeny'},
    {'code': 'D8', 'name': 'Ashtamsa', 'division': 8, 'signifies': 'Unexpected troubles'},
    {'code': 'D9', 'name': 'Navamsa', 'division': 9, 'signifies': 'Marriage, spouse, dharma'},
    {'code': 'D10', 'name': 'Dasamsa', 'division': 10, 'signifies': 'Career and profession'},
    {'code': 'D11', 'name': 'Ekadamsa', 'division': 11, 'signifies': 'Gains and income'},
    {'code': 'D12', 'name': 'Dwadasamsa', 'division': 12, 'signifies': 'Parents and lineage'},
    {'code': 'D16', 'name': 'Shodasamsa', 'division': 16, 'signifies': 'Vehicles and comforts'},
    {'code': 'D20', 'name': 'Vimsamsa', 'division': 20, 'signifies': 'Spiritual progress'},
    {'code': 'D24', 'name': 'Chaturvimsamsa', 'division': 24, 'signifies': 'Education and learning'},
    {'code': 'D27', 'name': 'Saptavimsamsa', 'division': 27, 'signifies': 'Strength and weakness'},
    {'code': 'D30', 'name': 'Trimsamsa', 'division': 30, 'signifies': 'Evils and misfortunes'},
    {'code': 'D40', 'name': 'Khavedamsa', 'division': 40, 'signifies': 'Auspicious/inauspicious effects'},
    {'code': 'D45', 'name': 'Akshavedamsa', 'division': 45, 'signifies': 'General well-being'},
    {'code': 'D60', 'name': 'Shashtiamsa', 'division': 60, 'signifies': 'Past life karma'},
  ];

  @override
  void initState() {
    super.initState();
    _loadBirthData();
  }

  Future<void> _loadBirthData() async {
    setState(() => _isLoading = true);
    
    // Try to load from local storage
    final storedData = LocalStorageService.get('birth_chart_data');
    if (storedData != null && storedData is Map<String, dynamic>) {
      setState(() {
        _birthData = storedData;
        _isLoading = false;
      });
    } else {
      // Use sample data for demo
      setState(() {
        _birthData = _getSampleData();
        _isLoading = false;
      });
    }
  }

  Map<String, dynamic> _getSampleData() {
    return {
      'ascendant_sign': 'Libra',
      'ascendant_sign_index': 6,
      'planets': [
        {'name': 'Sun', 'sign': 'Libra', 'sign_index': 6, 'degrees_in_sign': 14.2, 'house': 1, 'nakshatra': 'Swati'},
        {'name': 'Moon', 'sign': 'Aries', 'sign_index': 0, 'degrees_in_sign': 8.5, 'house': 7, 'nakshatra': 'Ashwini'},
        {'name': 'Mars', 'sign': 'Virgo', 'sign_index': 5, 'degrees_in_sign': 22.3, 'house': 12, 'nakshatra': 'Hasta'},
        {'name': 'Mercury', 'sign': 'Libra', 'sign_index': 6, 'degrees_in_sign': 28.7, 'house': 1, 'nakshatra': 'Vishakha'},
        {'name': 'Jupiter', 'sign': 'Pisces', 'sign_index': 11, 'degrees_in_sign': 5.1, 'house': 6, 'nakshatra': 'Uttara Bhadrapada'},
        {'name': 'Venus', 'sign': 'Virgo', 'sign_index': 5, 'degrees_in_sign': 17.8, 'house': 12, 'nakshatra': 'Hasta'},
        {'name': 'Saturn', 'sign': 'Scorpio', 'sign_index': 7, 'degrees_in_sign': 24.9, 'house': 2, 'nakshatra': 'Jyeshtha'},
        {'name': 'Rahu', 'sign': 'Pisces', 'sign_index': 11, 'degrees_in_sign': 12.4, 'house': 6, 'nakshatra': 'Uttara Bhadrapada'},
        {'name': 'Ketu', 'sign': 'Virgo', 'sign_index': 5, 'degrees_in_sign': 12.4, 'house': 12, 'nakshatra': 'Hasta'},
      ],
      'houses': [
        {'number': 1, 'sign': 'Libra', 'sign_index': 6},
        {'number': 2, 'sign': 'Scorpio', 'sign_index': 7},
        {'number': 3, 'sign': 'Sagittarius', 'sign_index': 8},
        {'number': 4, 'sign': 'Capricorn', 'sign_index': 9},
        {'number': 5, 'sign': 'Aquarius', 'sign_index': 10},
        {'number': 6, 'sign': 'Pisces', 'sign_index': 11},
        {'number': 7, 'sign': 'Aries', 'sign_index': 0},
        {'number': 8, 'sign': 'Taurus', 'sign_index': 1},
        {'number': 9, 'sign': 'Gemini', 'sign_index': 2},
        {'number': 10, 'sign': 'Cancer', 'sign_index': 3},
        {'number': 11, 'sign': 'Leo', 'sign_index': 4},
        {'number': 12, 'sign': 'Virgo', 'sign_index': 5},
      ],
    };
  }

  // Calculate divisional chart positions
  Map<String, dynamic> _calculateVargaChart(String vargaCode) {
    if (_birthData == null) return {};
    
    final division = _vargaCharts.firstWhere((v) => v['code'] == vargaCode)['division'] as int;
    final planets = _birthData!['planets'] as List<dynamic>? ?? [];
    final ascSignIndex = _birthData!['ascendant_sign_index'] as int? ?? 0;
    
    // Calculate new positions based on division
    final vargaPlanets = planets.map((p) {
      final degreesInSign = (p['degrees_in_sign'] as num?)?.toDouble() ?? 0.0;
      final originalSignIndex = (p['sign_index'] as int?) ?? 0;
      
      // Calculate varga sign
      final portion = (degreesInSign * division / 30).floor();
      int vargaSignIndex;
      
      if (vargaCode == 'D9') {
        // Navamsa calculation
        vargaSignIndex = (originalSignIndex * 9 + portion) % 12;
      } else if (vargaCode == 'D2') {
        // Hora calculation
        vargaSignIndex = portion == 0 ? 3 : 4; // Cancer or Leo
      } else {
        // General calculation
        vargaSignIndex = (originalSignIndex + portion) % 12;
      }
      
      // Calculate house in varga
      final vargaHouse = (vargaSignIndex - ascSignIndex + 12) % 12 + 1;
      
      return {
        ...Map<String, dynamic>.from(p),
        'sign_index': vargaSignIndex,
        'sign': _getSignName(vargaSignIndex),
        'house': vargaHouse,
        'degrees_in_sign': (degreesInSign * division) % 30,
      };
    }).toList();
    
    // Calculate varga houses
    final vargaHouses = List.generate(12, (i) {
      final signIndex = (ascSignIndex + i) % 12;
      return {
        'number': i + 1,
        'sign': _getSignName(signIndex),
        'sign_index': signIndex,
      };
    });
    
    return {
      'planets': vargaPlanets,
      'houses': vargaHouses,
      'ascendant_sign_index': ascSignIndex,
    };
  }
  
  String _getSignName(int index) {
    const signs = ['Aries', 'Taurus', 'Gemini', 'Cancer', 'Leo', 'Virgo',
                   'Libra', 'Scorpio', 'Sagittarius', 'Capricorn', 'Aquarius', 'Pisces'];
    return signs[index % 12];
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
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.arrow_back_ios, color: Colors.white),
                    ),
                    Icon(Icons.grid_view, color: AppTheme.accentGold, size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Varga Charts',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'All 20 Divisional Charts',
                            style: TextStyle(color: Colors.white54, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              // Varga Selector
              SizedBox(
                height: 50,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _vargaCharts.length,
                  itemBuilder: (context, index) {
                    final varga = _vargaCharts[index];
                    final isSelected = _selectedVarga == varga['code'];
                    return GestureDetector(
                      onTap: () => setState(() => _selectedVarga = varga['code']),
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          gradient: isSelected
                              ? LinearGradient(colors: [AppTheme.accentGold, AppTheme.accentGoldLight])
                              : null,
                          color: isSelected ? null : Color(0xFF1F2833),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? AppTheme.accentGold : Colors.white.withOpacity(0.1),
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              varga['code'],
                              style: TextStyle(
                                color: isSelected ? AppTheme.primaryNavy : Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
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
              
              // Selected Varga Info
              _buildVargaInfo(),
              
              // Chart Display
              Expanded(
                child: _isLoading
                    ? Center(child: CircularProgressIndicator(color: AppTheme.accentGold))
                    : _buildChartDisplay(),
              ),
              
              // Bottom Grid View
              _buildBottomGrid(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVargaInfo() {
    final varga = _vargaCharts.firstWhere((v) => v['code'] == _selectedVarga);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFF1F2833),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.accentGold.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [AppTheme.accentGold, AppTheme.accentGoldLight]),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                varga['code'],
                style: TextStyle(
                  color: AppTheme.primaryNavy,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${varga['name']} Chart',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  varga['signifies'],
                  style: TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.accentGold.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '1/${varga['division']}',
              style: TextStyle(color: AppTheme.accentGold, fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartDisplay() {
    final vargaData = _selectedVarga == 'D1' ? _birthData! : _calculateVargaChart(_selectedVarga);
    final planetsList = (vargaData['planets'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [];
    final housesList = (vargaData['houses'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [];
    final ascSignIndex = vargaData['ascendant_sign_index'] as int? ?? 0;
    
    // Convert List to Map format expected by DiamondChartWidget
    final planetsMap = <String, dynamic>{};
    for (final p in planetsList) {
      final name = p['name'] as String? ?? '';
      if (name.isNotEmpty) {
        planetsMap[name] = p;
      }
    }
    
    final housesMap = <String, dynamic>{
      'Ascendant_Sign': _getSignName(ascSignIndex),
    };
    for (final h in housesList) {
      housesMap['House_${h['number']}'] = h;
    }
    
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Expanded(
            child: DiamondChartWidget(
              planets: planetsMap,
              houses: housesMap,
              ascendant: ascSignIndex.toDouble(),
            ),
          ),
          const SizedBox(height: 12),
          // Planet positions summary
          Wrap(
            spacing: 8,
            runSpacing: 4,
            alignment: WrapAlignment.center,
            children: planetsList.take(9).map((p) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.primaryNavy.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${_getPlanetAbbr(p['name'])} ${p['sign'].toString().substring(0, 3)}',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  String _getPlanetAbbr(String name) {
    const abbr = {
      'Sun': 'Su', 'Moon': 'Mo', 'Mars': 'Ma', 'Mercury': 'Me',
      'Jupiter': 'Ju', 'Venus': 'Ve', 'Saturn': 'Sa', 'Rahu': 'Ra', 'Ketu': 'Ke',
    };
    return abbr[name] ?? name.substring(0, 2);
  }

  Widget _buildBottomGrid() {
    return Container(
      height: 100,
      margin: const EdgeInsets.all(16),
      child: GridView.builder(
        scrollDirection: Axis.horizontal,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 0.5,
        ),
        itemCount: _vargaCharts.length,
        itemBuilder: (context, index) {
          final varga = _vargaCharts[index];
          final isSelected = _selectedVarga == varga['code'];
          return GestureDetector(
            onTap: () => setState(() => _selectedVarga = varga['code']),
            child: Container(
              decoration: BoxDecoration(
                gradient: isSelected
                    ? LinearGradient(colors: [AppTheme.accentGold.withOpacity(0.3), AppTheme.accentGoldLight.withOpacity(0.2)])
                    : null,
                color: isSelected ? null : Color(0xFF1F2833),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isSelected ? AppTheme.accentGold : Colors.white.withOpacity(0.1),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    varga['code'],
                    style: TextStyle(
                      color: isSelected ? AppTheme.accentGold : Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    varga['name'],
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 8,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

