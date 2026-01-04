import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/app_theme.dart';
import '../../../config/app_config.dart';
import '../../../core/services/local_storage_service.dart';
import '../../../services/computation_service.dart';
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

  // Varga chart definitions - Shodasamsa vargas only (main divisional charts)
  // Removed D5, D6, D8, D11 as per requirements
  static const List<Map<String, dynamic>> _vargaCharts = [
    {'code': 'D1', 'name': 'Rashi', 'division': 1, 'signifies': 'Physical body, overall life'},
    {'code': 'D2', 'name': 'Hora', 'division': 2, 'signifies': 'Wealth and prosperity'},
    {'code': 'D3', 'name': 'Drekkana', 'division': 3, 'signifies': 'Siblings, courage, communication'},
    {'code': 'D4', 'name': 'Chaturthamsa', 'division': 4, 'signifies': 'Fortune, property, fixed assets'},
    {'code': 'D7', 'name': 'Saptamsa', 'division': 7, 'signifies': 'Children and progeny'},
    {'code': 'D9', 'name': 'Navamsa', 'division': 9, 'signifies': 'Marriage, spouse, dharma'},
    {'code': 'D10', 'name': 'Dasamsa', 'division': 10, 'signifies': 'Career and profession'},
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
    
    try {
      // First, try to load stored computed birth chart data
      final storedChartData = LocalStorageService.get('birth_chart_data');
      if (storedChartData != null && storedChartData is Map<String, dynamic>) {
        // Check if it has the expected format
        if (storedChartData.containsKey('planets') && storedChartData.containsKey('houses')) {
          setState(() {
            _birthData = _convertBackendFormatToVargaFormat(storedChartData);
            _isLoading = false;
          });
          return;
        }
      }
      
      // If no stored chart data, try to load birth details and compute chart
      final birthDetails = LocalStorageService.get('birth_data');
      if (birthDetails != null && birthDetails is Map<String, dynamic>) {
        final dateStr = birthDetails['date'] as String? ?? '';
        final timeStr = birthDetails['time'] as String? ?? '';
        final lat = (birthDetails['latitude'] as num?)?.toDouble();
        final lon = (birthDetails['longitude'] as num?)?.toDouble();
        
        if (dateStr.isNotEmpty && timeStr.isNotEmpty && lat != null && lon != null) {
          // Parse date and time
          final dateParts = dateStr.split('-');
          final timeParts = timeStr.split(':');
          
          if (dateParts.length == 3 && timeParts.length >= 2) {
            final dateTime = DateTime(
              int.parse(dateParts[0]),
              int.parse(dateParts[1]),
              int.parse(dateParts[2]),
              int.parse(timeParts[0]),
              timeParts.length > 1 ? int.parse(timeParts[1]) : 0,
            );
            
            // Fetch birth chart from backend (or use mock if in mock mode)
            final chartResult = await ComputationService().generateBirthChart(
              name: birthDetails['name'] as String? ?? 'User',
              date: dateTime,
              latitude: lat,
              longitude: lon,
            );
            
            // Check if chart result has planets data (either from backend or mock)
            if (chartResult.containsKey('planets')) {
              // Store the computed chart for future use
              await LocalStorageService.save('birth_chart_data', chartResult);
              
              setState(() {
                _birthData = _convertBackendFormatToVargaFormat(chartResult);
                _isLoading = false;
              });
              return;
            }
          }
        }
      }
      
      // Only use sample data as last resort
      if (AppConfig.useMockData) {
        setState(() {
          _birthData = _getSampleData();
          _isLoading = false;
        });
      } else {
        // In real mode, show error if no data available
        setState(() {
          _birthData = null;
          _isLoading = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please generate a birth chart first to view varga charts'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      print('Error loading birth data: $e');
      // Fallback to sample data only in mock mode
      if (AppConfig.useMockData) {
        setState(() {
          _birthData = _getSampleData();
          _isLoading = false;
        });
      } else {
        setState(() {
          _birthData = null;
          _isLoading = false;
        });
      }
    }
  }
  
  // Convert backend format to varga chart format
  Map<String, dynamic> _convertBackendFormatToVargaFormat(Map<String, dynamic> backendData) {
    final planetsMap = backendData['planets'] as Map<String, dynamic>? ?? {};
    final housesMap = backendData['houses'] as Map<String, dynamic>? ?? {};
    
    // Get ascendant sign index - try multiple sources
    int ascSignIndex = backendData['ascendant_sign_index'] as int? ?? 0;
    if (ascSignIndex == 0) {
      // Try to get from ascendant sign name
      final ascSignName = backendData['ascendant_sign'] as String? ?? '';
      if (ascSignName.isNotEmpty) {
        ascSignIndex = _getSignIndex(ascSignName);
      } else {
        // Try to calculate from ascendant longitude
        final ascLongitude = (backendData['ascendant'] as num?)?.toDouble();
        if (ascLongitude != null) {
          ascSignIndex = (ascLongitude ~/ 30) % 12;
        }
      }
    }
    
    // Get ascendant degrees in sign (needed for varga calculations)
    double ascDegreesInSign = (backendData['ascendant_degrees'] as num?)?.toDouble() ?? 0.0;
    if (ascDegreesInSign == 0.0) {
      // Calculate from ascendant longitude if available
      final ascLongitude = (backendData['ascendant'] as num?)?.toDouble();
      if (ascLongitude != null) {
        ascDegreesInSign = ascLongitude % 30;
      }
    }
    
    // Convert planets from map to list
    final planetsList = <Map<String, dynamic>>[];
    final planetOrder = ['Sun', 'Moon', 'Mars', 'Mercury', 'Jupiter', 'Venus', 'Saturn', 'Rahu', 'Ketu'];
    
    for (final planetName in planetOrder) {
      final planetData = planetsMap[planetName] as Map<String, dynamic>?;
      if (planetData != null) {
        // Get sign index - try multiple sources
        int signIndex = planetData['sign_index'] as int? ?? 0;
        if (signIndex == 0) {
          final signName = planetData['sign'] as String? ?? '';
          if (signName.isNotEmpty) {
            signIndex = _getSignIndex(signName);
          } else {
            // Calculate from longitude if available
            final longitude = (planetData['longitude'] as num?)?.toDouble();
            if (longitude != null) {
              signIndex = (longitude ~/ 30) % 12;
            }
          }
        }
        
        // Get degrees in sign
        double degreesInSign = (planetData['degrees_in_sign'] as num?)?.toDouble() ?? 0.0;
        if (degreesInSign == 0.0) {
          // Try to calculate from longitude
          final longitude = (planetData['longitude'] as num?)?.toDouble();
          if (longitude != null) {
            degreesInSign = longitude % 30;
          } else {
            // Try degrees_in_house as fallback
            degreesInSign = (planetData['degrees_in_house'] as num?)?.toDouble() ?? 0.0;
          }
        }
        
        // Calculate absolute longitude for varga calculations
        final longitude = (planetData['longitude'] as num?)?.toDouble();
        final absoluteLongitude = longitude ?? (signIndex * 30.0 + degreesInSign);
        
        planetsList.add({
          'name': planetName,
          'sign': planetData['sign'] as String? ?? _getSignName(signIndex),
          'sign_index': signIndex,
          'degrees_in_sign': degreesInSign,
          'longitude': absoluteLongitude, // Preserve for varga calculations
          'house': planetData['house'] as int? ?? 1,
          'nakshatra': planetData['nakshatra'] as String? ?? '',
        });
      }
    }
    
    // Convert houses from map to list
    final housesList = <Map<String, dynamic>>[];
    final ascSign = backendData['ascendant_sign'] as String? ?? _getSignName(ascSignIndex);
    
    for (int i = 1; i <= 12; i++) {
      final houseSignIndex = (ascSignIndex + i - 1) % 12;
      housesList.add({
        'number': i,
        'sign': _getSignName(houseSignIndex),
        'sign_index': houseSignIndex,
      });
    }
    
    return {
      'planets': planetsList,
      'houses': housesList,
      'ascendant_sign': ascSign,
      'ascendant_sign_index': ascSignIndex,
      'ascendant_degrees': ascDegreesInSign,
      'ascendant': backendData['ascendant'], // Preserve original longitude if available
    };
  }
  
  int _getSignIndex(String signName) {
    const signs = ['Aries', 'Taurus', 'Gemini', 'Cancer', 'Leo', 'Virgo',
                   'Libra', 'Scorpio', 'Sagittarius', 'Capricorn', 'Aquarius', 'Pisces'];
    return signs.indexWhere((s) => s.toLowerCase() == signName.toLowerCase()) % 12;
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
  // Optionally fetch from backend API for accuracy (set to true to use backend)
  static const bool _useBackendForVarga = false; // TODO: Set to true if client-side calculation has issues
  
  Map<String, dynamic> _calculateVargaChart(String vargaCode) {
    if (_birthData == null) return {};
    
    // If using backend, fetch from API (not implemented yet - would need birth details)
    // For now, calculate client-side
    
    final division = _vargaCharts.firstWhere((v) => v['code'] == vargaCode)['division'] as int;
    final planets = _birthData!['planets'] as List<dynamic>? ?? [];
    final d1AscSignIndex = _birthData!['ascendant_sign_index'] as int? ?? 0;
    
    // Get D1 ascendant degrees in sign (needed for varga ascendant calculation)
    // Try to get from stored data, or calculate from ascendant longitude if available
    double d1AscDegreesInSign = 0.0;
    if (_birthData!.containsKey('ascendant_degrees')) {
      d1AscDegreesInSign = (_birthData!['ascendant_degrees'] as num?)?.toDouble() ?? 0.0;
    } else if (_birthData!.containsKey('ascendant')) {
      final ascLongitude = (_birthData!['ascendant'] as num?)?.toDouble() ?? 0.0;
      d1AscDegreesInSign = ascLongitude % 30;
    }
    
    // Calculate varga ascendant sign (same formula as planets)
    final divisionSize = 30.0 / division;
    // Use truncating division to match Python's int() behavior exactly
    // Ensure ascDivisionNum is in valid range [0, division-1]
    var ascDivisionNum = (d1AscDegreesInSign / divisionSize).truncate();
    if (ascDivisionNum >= division) ascDivisionNum = division - 1;
    if (ascDivisionNum < 0) ascDivisionNum = 0;
    int vargaAscSignIndex;
    
    if (vargaCode == 'D9') {
      // Navamsa ascendant calculation
      vargaAscSignIndex = (d1AscSignIndex * 9 + ascDivisionNum) % 12;
    } else if (vargaCode == 'D2') {
      // Hora ascendant calculation - depends on whether D1 ascendant sign is odd or even
      if (d1AscSignIndex % 2 == 0) {
        // Odd signs (Aries=0, Gemini=2, Leo=4, Libra=6, Sagittarius=8, Aquarius=10)
        vargaAscSignIndex = ascDivisionNum == 0 ? 4 : 3; // Leo or Cancer
      } else {
        // Even signs (Taurus=1, Cancer=3, Virgo=5, Scorpio=7, Capricorn=9, Pisces=11)
        vargaAscSignIndex = ascDivisionNum == 0 ? 3 : 4; // Cancer or Leo
      }
    } else if (vargaCode == 'D3') {
      // Drekkana ascendant
      if (ascDivisionNum == 0) {
        vargaAscSignIndex = d1AscSignIndex;
      } else if (ascDivisionNum == 1) {
        vargaAscSignIndex = (d1AscSignIndex + 5) % 12;
      } else {
        vargaAscSignIndex = (d1AscSignIndex + 9) % 12;
      }
    } else if (vargaCode == 'D4') {
      // Chaturthamsa ascendant
      vargaAscSignIndex = (d1AscSignIndex + ascDivisionNum) % 12;
    } else if (vargaCode == 'D7') {
      // Saptamsa ascendant
      vargaAscSignIndex = (d1AscSignIndex + ascDivisionNum) % 12;
    } else if (vargaCode == 'D10') {
      // Dasamsa ascendant
      vargaAscSignIndex = (d1AscSignIndex + ascDivisionNum) % 12;
    } else if (vargaCode == 'D12') {
      // Dwadasamsa ascendant
      vargaAscSignIndex = (d1AscSignIndex + ascDivisionNum) % 12;
    } else if (vargaCode == 'D16') {
      // Shodasamsa ascendant
      // TODO: Update based on chartcalculation.pdf and astrocalculation 2.pdf
      // Current: sequential mapping (d1AscSignIndex + ascDivisionNum) % 12
      // Issue: Showing Taurus instead of Scorpio (6 signs off)
      // Check PDF for correct formula or lookup table
      vargaAscSignIndex = (d1AscSignIndex + ascDivisionNum) % 12;
    } else if (vargaCode == 'D20') {
      // Vimsamsa ascendant
      // TODO: Update based on chartcalculation.pdf and astrocalculation 2.pdf
      // Current: sequential mapping (d1AscSignIndex + ascDivisionNum) % 12
      // Issue: Showing Cancer instead of Capricorn (6 signs off)
      // Check PDF for correct formula or lookup table
      vargaAscSignIndex = (d1AscSignIndex + ascDivisionNum) % 12;
    } else if (vargaCode == 'D24') {
      // Chaturvimsamsa ascendant
      vargaAscSignIndex = (d1AscSignIndex + ascDivisionNum) % 12;
    } else if (vargaCode == 'D27') {
      // Saptavimsamsa ascendant
      vargaAscSignIndex = (d1AscSignIndex + ascDivisionNum) % 12;
    } else if (vargaCode == 'D30') {
      // Trimsamsa ascendant - special calculation
      if (d1AscSignIndex % 2 == 0) {
        final trimDivision = (d1AscDegreesInSign / 5).floor();
        vargaAscSignIndex = trimDivision % 12;
      } else {
        final trimDivision = (d1AscDegreesInSign / 5).floor();
        vargaAscSignIndex = (6 + trimDivision) % 12;
      }
    } else if (vargaCode == 'D40') {
      // Khavedamsa ascendant
      vargaAscSignIndex = (d1AscSignIndex + ascDivisionNum) % 12;
    } else if (vargaCode == 'D45') {
      // Akshavedamsa ascendant
      vargaAscSignIndex = (d1AscSignIndex + ascDivisionNum) % 12;
    } else if (vargaCode == 'D60') {
      // Shashtiamsa ascendant
      vargaAscSignIndex = (d1AscSignIndex + ascDivisionNum) % 12;
    } else {
      // Fallback: General formula
      final multiplier = (12 % division == 0) ? (12 ~/ division) : 1;
      vargaAscSignIndex = (d1AscSignIndex + ascDivisionNum * multiplier) % 12;
    }
    
    // Calculate new positions based on division
    // (divisionSize already calculated above)
    final vargaPlanets = planets.map((p) {
      // Use absolute longitude if available, otherwise calculate from sign_index + degrees_in_sign
      double absoluteLongitude;
      if (p.containsKey('longitude') && p['longitude'] != null) {
        absoluteLongitude = (p['longitude'] as num).toDouble();
      } else {
        // Calculate from sign_index and degrees_in_sign
        final signIndex = (p['sign_index'] as int?) ?? 0;
        final degreesInSign = (p['degrees_in_sign'] as num?)?.toDouble() ?? 0.0;
        absoluteLongitude = signIndex * 30.0 + degreesInSign;
      }
      
      // Calculate sign index and degrees in sign from absolute longitude (matching backend)
      final originalSignIndex = (absoluteLongitude ~/ 30) % 12;
      final degreesInSign = absoluteLongitude % 30;
      
      // Calculate which division within the sign (0 to division-1)
      // Backend: division_num = int(degrees_in_sign / division_size)
      // Use truncating division to match Python's int() behavior exactly
      // Ensure division_num is in valid range [0, division-1]
      var divisionNum = (degreesInSign / divisionSize).truncate();
      if (divisionNum >= division) divisionNum = division - 1;
      if (divisionNum < 0) divisionNum = 0;
      
      // Calculate varga sign based on division type
      int vargaSignIndex;
      
      if (vargaCode == 'D9') {
        // Navamsa calculation: (sign_index * 9 + division_num) % 12
        vargaSignIndex = (originalSignIndex * 9 + divisionNum) % 12;
      } else if (vargaCode == 'D2') {
        // Hora calculation - depends on whether original sign is odd or even
        if (originalSignIndex % 2 == 0) {
          // Odd signs (Aries=0, Gemini=2, Leo=4, Libra=6, Sagittarius=8, Aquarius=10)
          vargaSignIndex = divisionNum == 0 ? 4 : 3; // Leo or Cancer
        } else {
          // Even signs (Taurus=1, Cancer=3, Virgo=5, Scorpio=7, Capricorn=9, Pisces=11)
          vargaSignIndex = divisionNum == 0 ? 3 : 4; // Cancer or Leo
        }
      } else if (vargaCode == 'D3') {
        // Drekkana (D3): First 10° = same sign, next 10° = 5th sign, last 10° = 9th sign
        if (divisionNum == 0) {
          vargaSignIndex = originalSignIndex; // First 10° = same sign
        } else if (divisionNum == 1) {
          vargaSignIndex = (originalSignIndex + 5) % 12; // Next 10° = 5th sign
        } else {
          vargaSignIndex = (originalSignIndex + 9) % 12; // Last 10° = 9th sign
        }
      } else if (vargaCode == 'D4') {
        // Chaturthamsa (D4): Each 7.5° maps to next sign sequentially
        vargaSignIndex = (originalSignIndex + divisionNum) % 12;
      } else if (vargaCode == 'D7') {
        // Saptamsa (D7): Each division maps to signs in sequence
        vargaSignIndex = (originalSignIndex + divisionNum) % 12;
      } else if (vargaCode == 'D10') {
        // Dasamsa (D10): Each 3° maps to next sign sequentially
        vargaSignIndex = (originalSignIndex + divisionNum) % 12;
      } else if (vargaCode == 'D12') {
        // Dwadasamsa (D12): Each 2.5° maps to next sign sequentially (12 parts = 12 signs)
        vargaSignIndex = (originalSignIndex + divisionNum) % 12;
      } else if (vargaCode == 'D16') {
        // Shodasamsa (D16): Each 1.875° (30/16) maps to signs
        // TODO: Validate with chartcalculation.pdf and astrocalculation 2.pdf
        // Current implementation uses sequential mapping, but may need specific sequence
        // If D16 ascendant is wrong (e.g., showing Taurus instead of Scorpio),
        // check PDF for correct sequence/offset
        vargaSignIndex = (originalSignIndex + divisionNum) % 12;
      } else if (vargaCode == 'D20') {
        // Vimsamsa (D20): Each 1.5° (30/20) maps to signs
        // TODO: Validate with chartcalculation.pdf and astrocalculation 2.pdf
        // Current implementation uses sequential mapping, but may need specific sequence
        // If D20 ascendant is wrong (e.g., showing Cancer instead of Capricorn),
        // check PDF for correct sequence/offset
        vargaSignIndex = (originalSignIndex + divisionNum) % 12;
      } else if (vargaCode == 'D24') {
        // Chaturvimsamsa (D24): Each 1.25° maps to signs in sequence
        vargaSignIndex = (originalSignIndex + divisionNum) % 12;
      } else if (vargaCode == 'D27') {
        // Saptavimsamsa (D27): Each 1.111° maps to signs in sequence
        vargaSignIndex = (originalSignIndex + divisionNum) % 12;
      } else if (vargaCode == 'D30') {
        // Trimsamsa (D30): Special calculation - each 1° maps differently based on sign
        // Odd signs: 0-5°=Aries, 5-10°=Taurus, 10-15°=Gemini, 15-20°=Cancer, 20-25°=Leo, 25-30°=Virgo
        // Even signs: 0-5°=Libra, 5-10°=Scorpio, 10-15°=Sagittarius, 15-20°=Capricorn, 20-25°=Aquarius, 25-30°=Pisces
        if (originalSignIndex % 2 == 0) {
          // Odd signs (Aries, Gemini, Leo, Libra, Sagittarius, Aquarius)
          final trimDivision = (degreesInSign / 5).floor();
          vargaSignIndex = trimDivision % 12; // 0-5: Aries(0), 5-10: Taurus(1), etc.
        } else {
          // Even signs (Taurus, Cancer, Virgo, Scorpio, Capricorn, Pisces)
          final trimDivision = (degreesInSign / 5).floor();
          vargaSignIndex = (6 + trimDivision) % 12; // 0-5: Libra(6), 5-10: Scorpio(7), etc.
        }
      } else if (vargaCode == 'D40') {
        // Khavedamsa (D40): Each 0.75° maps to signs in sequence
        vargaSignIndex = (originalSignIndex + divisionNum) % 12;
      } else if (vargaCode == 'D45') {
        // Akshavedamsa (D45): Each 0.667° maps to signs in sequence
        vargaSignIndex = (originalSignIndex + divisionNum) % 12;
      } else if (vargaCode == 'D60') {
        // Shashtiamsa (D60): Each 0.5° maps to signs in sequence
        vargaSignIndex = (originalSignIndex + divisionNum) % 12;
      } else {
        // Fallback: General formula (should not reach here for known varga charts)
        final multiplier = (12 % division == 0) ? (12 ~/ division) : 1;
        vargaSignIndex = (originalSignIndex + divisionNum * multiplier) % 12;
      }
      
      // Calculate new degrees in sign for varga chart
      // Backend: new_longitude = new_sign_index * 30 + (degrees_in_sign % division_size) * division
      // Then: degrees_in_sign = new_longitude % 30
      final newLongitude = vargaSignIndex * 30.0 + (degreesInSign % divisionSize) * division;
      final newDegreesInSign = newLongitude % 30;
      
      // Calculate house in varga (relative to varga ascendant, not D1 ascendant)
      final vargaHouse = (vargaSignIndex - vargaAscSignIndex + 12) % 12 + 1;
      
      return {
        ...Map<String, dynamic>.from(p),
        'sign_index': vargaSignIndex,
        'sign': _getSignName(vargaSignIndex),
        'house': vargaHouse,
        'degrees_in_sign': newDegreesInSign % 30,
      };
    }).toList();
    
    // Calculate varga houses (based on varga ascendant, not D1 ascendant)
    final vargaHouses = List.generate(12, (i) {
      final signIndex = (vargaAscSignIndex + i) % 12;
      return {
        'number': i + 1,
        'sign': _getSignName(signIndex),
        'sign_index': signIndex,
      };
    });
    
    return {
      'planets': vargaPlanets,
      'houses': vargaHouses,
      'ascendant_sign_index': vargaAscSignIndex,
      'ascendant_sign': _getSignName(vargaAscSignIndex),
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
    if (_birthData == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.info_outline, color: Colors.white54, size: 48),
            const SizedBox(height: 16),
            Text(
              'No birth chart data available',
              style: TextStyle(color: Colors.white54, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Please generate a birth chart first',
              style: TextStyle(color: Colors.white38, fontSize: 12),
            ),
          ],
        ),
      );
    }
    
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

