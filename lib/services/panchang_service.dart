import 'package:dio/dio.dart';
import '../config/app_config.dart';
import '../config/env_config.dart';

class PanchangService {
  static final PanchangService _instance = PanchangService._internal();
  factory PanchangService() => _instance;
  PanchangService._internal();

  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: AppConfig.backendUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Cache-Control': 'no-cache, no-store, must-revalidate',
        'Pragma': 'no-cache',
        'Expires': '0',
      },
    ),
  );

  // Tithi data for mock
  static const List<String> _tithis = [
    'Pratipada', 'Dwitiya', 'Tritiya', 'Chaturthi', 'Panchami',
    'Shashthi', 'Saptami', 'Ashtami', 'Navami', 'Dashami',
    'Ekadashi', 'Dwadashi', 'Trayodashi', 'Chaturdashi', 'Purnima/Amavasya'
  ];

  static const List<String> _nakshatras = [
    'Ashwini', 'Bharani', 'Krittika', 'Rohini', 'Mrigashira',
    'Ardra', 'Punarvasu', 'Pushya', 'Ashlesha', 'Magha',
    'Purva Phalguni', 'Uttara Phalguni', 'Hasta', 'Chitra', 'Swati',
    'Vishakha', 'Anuradha', 'Jyeshtha', 'Mula', 'Purva Ashadha',
    'Uttara Ashadha', 'Shravana', 'Dhanishta', 'Shatabhisha',
    'Purva Bhadrapada', 'Uttara Bhadrapada', 'Revati'
  ];

  static const List<String> _yogas = [
    'Vishkumbha', 'Priti', 'Ayushman', 'Saubhagya', 'Shobhana',
    'Atiganda', 'Sukarma', 'Dhriti', 'Shula', 'Ganda',
    'Vriddhi', 'Dhruva', 'Vyaghata', 'Harshana', 'Vajra',
    'Siddhi', 'Vyatipata', 'Variyan', 'Parigha', 'Shiva',
    'Siddha', 'Sadhya', 'Shubha', 'Shukla', 'Brahma',
    'Indra', 'Vaidhriti'
  ];

  static const List<String> _karanas = [
    'Bava', 'Balava', 'Kaulava', 'Taitila', 'Gara',
    'Vanija', 'Vishti', 'Shakuni', 'Chatushpada', 'Naga', 'Kimstughna'
  ];

  /// Get today's panchang with mock fallback
  Future<Map<String, dynamic>> getTodayPanchang() async {
    try {
      if (AppConfig.useMockData) {
        return _getMockPanchang(DateTime.now());
      }
      return await getDailyPanchang(date: DateTime.now());
    } catch (e) {
      // Fallback to mock data
      return _getMockPanchang(DateTime.now());
    }
  }

  Map<String, dynamic> _getMockPanchang(DateTime date) {
    // Calculate approximate values based on date
    final dayOfYear = date.difference(DateTime(date.year, 1, 1)).inDays;
    
    print('🔢 Mock calculation for ${date.toIso8601String().split('T')[0]}: dayOfYear=$dayOfYear, day=${date.day}, month=${date.month}');
    
    // Create a unique day number that changes daily
    final uniqueDayNumber = (date.year * 366) + dayOfYear;
    
    // Lunar month is ~29.5 days, so we calculate position in lunar cycle
    final lunarDay = uniqueDayNumber % 30;
    
    final tithiIndex = lunarDay % 15;
    final paksha = lunarDay < 15 ? 'Shukla' : 'Krishna';
    
    // Nakshatra: moon moves through 27 nakshatras
    // Simple: just cycle through based on day number
    final nakshatraIndex = uniqueDayNumber % 27;
    
    // Yoga also cycles through 27
    final yogaIndex = (uniqueDayNumber + 7) % 27;
    
    // Karana (half of tithi)
    final karanaIndex = (lunarDay * 2) % 11;
    
    print('🔢 Calculated indices: nakshatra=$nakshatraIndex (${_nakshatras[nakshatraIndex]}), tithi=$tithiIndex ($paksha ${_tithis[tithiIndex]}), yoga=$yogaIndex, karana=$karanaIndex');
    
    // Calculate sunrise/sunset based on month (approximate for India)
    final month = date.month;
    int sunriseHour = 6;
    int sunriseMin = 0;
    int sunsetHour = 18;
    int sunsetMin = 0;
    
    if (month >= 4 && month <= 9) {
      sunriseHour = 5;
      sunriseMin = 30 + ((month - 4) * 5);
      sunsetHour = 18;
      sunsetMin = 30 + ((month - 4) * 5);
    } else {
      sunriseHour = 6;
      sunriseMin = 30 - ((month > 9 ? month - 10 : month + 2) * 5);
      sunsetHour = 17;
      sunsetMin = 30 + ((month > 9 ? month - 10 : month + 2) * 5);
    }
    
    // Moonrise varies with lunar day
    final moonriseHour = (lunarDay + 6) % 24;
    final moonriseMin = (date.day * 4) % 60;
    
    final dateStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    
    final result = {
      'tithi': '$paksha ${_tithis[tithiIndex]}',
      'nakshatra': _nakshatras[nakshatraIndex],
      'yoga': _yogas[yogaIndex],
      'karana': _karanas[karanaIndex],
      'sunrise': '${sunriseHour.toString().padLeft(2, '0')}:${(sunriseMin % 60).toString().padLeft(2, '0')}',
      'sunset': '${sunsetHour.toString().padLeft(2, '0')}:${(sunsetMin % 60).toString().padLeft(2, '0')}',
      'moonrise': '${moonriseHour.toString().padLeft(2, '0')}:${moonriseMin.toString().padLeft(2, '0')}',
      'vara': _getDayName(date.weekday),
      'rahu_kaal': _getRahuKaal(date.weekday),
      'gulika_kaal': _getGulikaKaal(date.weekday),
      'yamaghanda': _getYamaghanda(date.weekday),
      'date': dateStr,
      'success': true,
    };
    
    // Debug log to verify data is changing
    print('📅 Generated panchang for $dateStr: Nakshatra=${result['nakshatra']}, Tithi=${result['tithi']}, Vara=${result['vara']}');
    
    return result;
  }

  String _getDayName(int weekday) {
    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return days[weekday - 1];
  }

  String _getRahuKaal(int weekday) {
    const rahuKaal = [
      '07:30-09:00', // Monday
      '15:00-16:30', // Tuesday
      '12:00-13:30', // Wednesday
      '13:30-15:00', // Thursday
      '10:30-12:00', // Friday
      '09:00-10:30', // Saturday
      '16:30-18:00', // Sunday
    ];
    return rahuKaal[weekday - 1];
  }

  String _getGulikaKaal(int weekday) {
    const gulikaKaal = [
      '13:30-15:00', // Monday
      '12:00-13:30', // Tuesday
      '10:30-12:00', // Wednesday
      '09:00-10:30', // Thursday
      '07:30-09:00', // Friday
      '06:00-07:30', // Saturday
      '15:00-16:30', // Sunday
    ];
    return gulikaKaal[weekday - 1];
  }

  String _getYamaghanda(int weekday) {
    const yamaghanda = [
      '10:30-12:00', // Monday
      '09:00-10:30', // Tuesday
      '07:30-09:00', // Wednesday
      '06:00-07:30', // Thursday
      '15:00-16:30', // Friday
      '13:30-15:00', // Saturday
      '12:00-13:30', // Sunday
    ];
    return yamaghanda[weekday - 1];
  }

  Future<Map<String, dynamic>> getDailyPanchang({
    required DateTime date,
    double? latitude,
    double? longitude,
    String timezone = 'Asia/Kolkata',
  }) async {
    final dateStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    
    print('🔍 getDailyPanchang called for: $dateStr');
    print('🔍 AppConfig.useMockData: ${AppConfig.useMockData}');
    
    try {
      // Use mock data if configured
      if (AppConfig.useMockData) {
        print('⚠️ Using mock data (configured)');
        return _getMockPanchang(date);
      }

      print('🌐 Attempting to fetch from backend: ${EnvConfig.backendUrl}/api/panchang/daily');

      final response = await _dio.get(
        '/api/panchang/daily',
        queryParameters: {
          'date': dateStr,
          if (latitude != null) 'latitude': latitude,
          if (longitude != null) 'longitude': longitude,
          'timezone': timezone,
          '_t': DateTime.now().millisecondsSinceEpoch, // Cache buster
        },
      );

      print('✅ Backend response status: ${response.statusCode}');

      if (response.statusCode == 200 && response.data['success'] == true) {
        print('✅ Backend data received: Nakshatra=${response.data['nakshatra']}');
        return response.data;
      } else {
        throw Exception(response.data['error'] ?? 'Failed to get panchang');
      }
    } on DioException catch (e) {
      // Fallback to mock data on network error
      print('❌ Network error (${e.type}), using mock data: ${e.message}');
      return _getMockPanchang(date);
    } catch (e) {
      // Fallback to mock data on any error
      print('❌ Error getting panchang, using mock data: $e');
      return _getMockPanchang(date);
    }
  }

  Future<Map<String, dynamic>> getMuhurat({
    required DateTime date,
    double? latitude,
    double? longitude,
    String eventType = 'general',
    String timezone = 'Asia/Kolkata',
  }) async {
    try {
      final dateStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

      final response = await _dio.get(
        '/api/panchang/muhurat',
        queryParameters: {
          'date': dateStr,
          if (latitude != null) 'latitude': latitude,
          if (longitude != null) 'longitude': longitude,
          'eventType': eventType,
          'timezone': timezone,
        },
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data;
      } else {
        throw Exception(response.data['error'] ?? 'Failed to get muhurat');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Error getting muhurat: $e');
    }
  }
}

