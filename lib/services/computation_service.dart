import 'package:dio/dio.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import '../config/app_config.dart';
import '../core/utils/app_logger.dart';

class ComputationService {
  static final ComputationService _instance = ComputationService._internal();
  factory ComputationService() => _instance;
  ComputationService._internal();

  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: AppConfig.backendUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        if (AppConfig.hasApiKey) 'X-API-Key': AppConfig.apiKey,
      },
    ),
  );

  Future<Map<String, dynamic>> _loadMockChartData() async {
    try {
      final String jsonString = await rootBundle.loadString('${AppConfig.mockDataPath}/charts.json');
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      final sampleChart = jsonData['sample_birth_chart'] as Map<String, dynamic>?;
      if (sampleChart != null) {
        return {
          'success': true,
          ...sampleChart,
        };
      }
    } catch (e) {
      print('Error loading mock chart data: $e');
    }
    // Fallback hardcoded data
    return {
      'success': true,
      'name': 'Sample User',
      'planets': {
        'Sun': {'longitude': 30.5, 'house': 1, 'degrees_in_house': 0.5, 'sign': 'Aries'},
        'Moon': {'longitude': 120.3, 'house': 4, 'degrees_in_house': 0.3, 'sign': 'Leo'},
        'Mercury': {'longitude': 45.2, 'house': 2, 'degrees_in_house': 15.2, 'sign': 'Taurus'},
        'Venus': {'longitude': 60.8, 'house': 2, 'degrees_in_house': 0.8, 'sign': 'Gemini'},
        'Mars': {'longitude': 180.5, 'house': 7, 'degrees_in_house': 0.5, 'sign': 'Libra'},
        'Jupiter': {'longitude': 240.2, 'house': 9, 'degrees_in_house': 0.2, 'sign': 'Sagittarius'},
        'Saturn': {'longitude': 300.7, 'house': 11, 'degrees_in_house': 0.7, 'sign': 'Aquarius'},
        'Rahu': {'longitude': 150.1, 'house': 6, 'degrees_in_house': 0.1, 'sign': 'Virgo'},
        'Ketu': {'longitude': 330.9, 'house': 12, 'degrees_in_house': 0.9, 'sign': 'Pisces'},
      },
      'houses': {
        'Ascendant': 30.0,
        'House 1': 30.0,
        'House 2': 60.0,
        'House 3': 90.0,
        'House 4': 120.0,
        'House 5': 150.0,
        'House 6': 180.0,
        'House 7': 210.0,
        'House 8': 240.0,
        'House 9': 270.0,
        'House 10': 300.0,
        'House 11': 330.0,
        'House 12': 360.0,
      },
      'ascendant': 30.0,
    };
  }

  Future<Map<String, dynamic>> generateBirthChart({
    required String name,
    required DateTime date,
    required double latitude,
    required double longitude,
    String timezone = 'Asia/Kolkata',
  }) async {
    // Use mock data if backend is not available or in mock mode
    if (AppConfig.useMockData) {
      AppLogger.i('📊 [ComputationService] Using MOCK data mode');
      await Future.delayed(const Duration(seconds: 1)); // Simulate API call
      final mockData = await _loadMockChartData();
      return {
        ...mockData,
        'name': name,
        'date': '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}',
        'time': '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}:00',
        'latitude': latitude,
        'longitude': longitude,
      };
    }
    
    AppLogger.i('🌐 [ComputationService] Using BACKEND at: ${AppConfig.backendUrl}', null, null, {
      'name': name,
      'date': date.toString(),
      'latitude': latitude,
      'longitude': longitude,
      'timezone': timezone,
    });

    try {
      final dateStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      final timeStr = '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}:00';

      AppLogger.logRequest(
        method: 'POST',
        url: '${AppConfig.backendUrl}/birth-chart',
        body: {
          'date': dateStr,
          'time': timeStr,
          'latitude': latitude,
          'longitude': longitude,
          'timezone': timezone,
        },
      );

      final stopwatch = Stopwatch()..start();
      // Use new API endpoint structure: /birth-chart (not /api/computation/birth-chart)
      final response = await _dio.post(
        '/birth-chart',
        data: {
          'date': dateStr,
          'time': timeStr,
          'latitude': latitude,
          'longitude': longitude,
          'timezone': timezone,
        },
      );
      stopwatch.stop();

      AppLogger.logResponse(
        method: 'POST',
        url: '${AppConfig.backendUrl}/birth-chart',
        statusCode: response.statusCode ?? 0,
        body: response.data,
        duration: stopwatch.elapsed,
      );

      // New API response format - check for success or planets data
      if (response.statusCode == 200) {
        // API may return success: true or directly return chart data
        if (response.data['success'] == true || response.data.containsKey('planets')) {
          AppLogger.i('✅ [ComputationService] Chart generated successfully', null, null, {
            'hasPlanets': response.data.containsKey('planets'),
            if (response.data.containsKey('planets')) 'planets': response.data['planets'].keys.toList(),
          });
          return response.data;
        } else {
          // If no success field and no planets, treat as error
          final errorMsg = response.data['error'] ?? 'Invalid response format';
          AppLogger.e('❌ [ComputationService] Backend returned invalid response', null, null, {
            'response': response.data,
          });
          throw Exception(errorMsg);
        }
      } else {
        final errorMsg = response.data['error'] ?? 'Failed to generate birth chart';
        AppLogger.e('❌ [ComputationService] Backend returned error: $errorMsg', null, null, {
          'response': response.data,
        });
        throw Exception(errorMsg);
      }
    } on DioException catch (e, stackTrace) {
      // Enhanced error logging for network errors
      AppLogger.logApiError(
        method: 'POST',
        url: '${AppConfig.backendUrl}/birth-chart',
        error: e,
        stackTrace: stackTrace,
        statusCode: e.response?.statusCode,
        responseBody: e.response?.data,
      );
      
      AppLogger.w('🔄 [ComputationService] Falling back to mock data due to network error', e, stackTrace, {
        'errorType': e.type.toString(),
        'requestPath': e.requestOptions.path,
        'baseUrl': e.requestOptions.baseUrl,
      });
      
      final mockData = await _loadMockChartData();
      return {
        ...mockData,
        'name': name,
        'date': '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}',
        'time': '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}:00',
        'latitude': latitude,
        'longitude': longitude,
        '_fallback_reason': 'network_error',
        '_error_details': e.message,
      };
    } catch (e, stackTrace) {
      // Enhanced error logging for all other errors
      AppLogger.e('❌ [ComputationService] UNEXPECTED ERROR', e, stackTrace, {
        'errorType': e.runtimeType.toString(),
        'operation': 'generateBirthChart',
      });
      
      AppLogger.w('🔄 [ComputationService] Falling back to mock data due to error', e, stackTrace);
      
      final mockData = await _loadMockChartData();
      return {
        ...mockData,
        'name': name,
        'date': '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}',
        'time': '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}:00',
        'latitude': latitude,
        'longitude': longitude,
        '_fallback_reason': 'unexpected_error',
        '_error_details': e.toString(),
      };
    }
  }

  Map<String, dynamic> _generateMockDashaData(DateTime date) {
    // Mock dasha data based on birth date
    // Vimshottari Dasha sequence
    const dashaSequence = ['Ketu', 'Venus', 'Sun', 'Moon', 'Mars', 'Rahu', 'Jupiter', 'Saturn', 'Mercury'];
    const dashaPeriods = {'Ketu': 7, 'Venus': 20, 'Sun': 6, 'Moon': 10, 'Mars': 7, 'Rahu': 18, 'Jupiter': 16, 'Saturn': 19, 'Mercury': 17};
    
    // Calculate starting dasha based on Moon position (simplified)
    final dayOfYear = date.difference(DateTime(date.year, 1, 1)).inDays;
    final startIndex = (dayOfYear % 9);
    
    // Generate mahadasha list
    final mahadashas = <Map<String, dynamic>>[];
    var currentDate = date;
    final birthJd = _dateToJd(date);
    var currentJd = birthJd;
    
    for (int cycle = 0; cycle < 2; cycle++) {
      for (int i = 0; i < 9; i++) {
        final lord = dashaSequence[(startIndex + i) % 9];
        final years = dashaPeriods[lord]!.toDouble();
        final endJd = currentJd + (years * 365.25);
        
        mahadashas.add({
          'lord': lord,
          'start_date': _jdToDateString(currentJd),
          'end_date': _jdToDateString(endJd),
          'years': years,
          'start_jd': currentJd,
          'end_jd': endJd,
        });
        
        currentJd = endJd;
      }
    }
    
    // Find current periods
    final nowJd = _dateToJd(DateTime.now());
    Map<String, dynamic>? currentMaha;
    
    for (final maha in mahadashas) {
      if ((maha['start_jd'] as double) <= nowJd && nowJd < (maha['end_jd'] as double)) {
        currentMaha = maha;
        break;
      }
    }
    
    return {
      'moon_nakshatra': 'Ashwini',
      'nakshatra_lord': dashaSequence[startIndex],
      'nakshatra_pada': 1,
      'moon_longitude': 15.5,
      'mahadashas': mahadashas.take(18).toList(),
      'current': {
        'mahadasha': currentMaha,
        'antardasha': null,
        'pratyantardasha': null,
        'sookshma': null,
      },
    };
  }
  
  double _dateToJd(DateTime date) {
    final a = ((14 - date.month) / 12).floor();
    final y = date.year + 4800 - a;
    final m = date.month + 12 * a - 3;
    return date.day + ((153 * m + 2) / 5).floor() + 365 * y + (y / 4).floor() - (y / 100).floor() + (y / 400).floor() - 32045 + (date.hour + date.minute / 60.0) / 24.0;
  }
  
  String _jdToDateString(double jd) {
    final z = (jd + 0.5).floor();
    final f = jd + 0.5 - z;
    int a;
    if (z < 2299161) {
      a = z;
    } else {
      final alpha = ((z - 1867216.25) / 36524.25).floor();
      a = z + 1 + alpha - (alpha / 4).floor();
    }
    final b = a + 1524;
    final c = ((b - 122.1) / 365.25).floor();
    final d = (365.25 * c).floor();
    final e = ((b - d) / 30.6001).floor();
    
    final day = b - d - (30.6001 * e).floor();
    final month = e < 14 ? e - 1 : e - 13;
    final year = month > 2 ? c - 4716 : c - 4715;
    
    return '$year-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
  }

  Future<Map<String, dynamic>> generateDasha({
    required DateTime date,
    required double latitude,
    required double longitude,
    String timezone = 'Asia/Kolkata',
  }) async {
    // Use mock data if backend is not available
    if (AppConfig.useMockData) {
      await Future.delayed(const Duration(milliseconds: 500));
      return _generateMockDashaData(date);
    }

    try {
      final dateStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      final timeStr = '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}:00';

      // Use API endpoint: /dasha/mahadasha (returns all mahadashas with current)
      // This endpoint accepts BirthDataRequest directly (not nested in birth_data)
      final response = await _dio.post(
        '/dasha/mahadasha',
        data: {
          'date': dateStr,
          'time': timeStr,
          'latitude': latitude,
          'longitude': longitude,
          'timezone': timezone,
          'ayanamsha': 'lahiri',  // Default ayanamsha
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        // Transform the response to match expected format
        // The API returns: { success: true, mahadashas: [...], current_mahadasha: {...}, ... }
        // We need: { mahadashas: [...], current: { mahadasha: {...} }, ... }
        return {
          'moon_nakshatra': data['moon_nakshatra'] ?? '',
          'nakshatra_lord': data['nakshatra_lord'] ?? '',
          'nakshatra_pada': data['nakshatra_pada'] ?? 0,
          'moon_longitude': data['moon_longitude'] ?? 0.0,
          'mahadashas': (data['mahadashas'] as List<dynamic>?)?.map((md) => {
            'lord': md['lord'] ?? '',
            'start_date': md['start_date'] ?? '',
            'end_date': md['end_date'] ?? '',
            'years': md['years'] ?? 0,
          }).toList() ?? [],
          'current': {
            'mahadasha': data['current_mahadasha'] ?? null,
          },
        };
      } else {
        throw Exception(response.data['error'] ?? 'Failed to generate dasha');
      }
    } on DioException catch (e) {
      // Fallback to mock data
      print('Network error, using mock dasha data: ${e.message}');
      return _generateMockDashaData(date);
    } catch (e) {
      // Fallback to mock data
      print('Error generating dasha, using mock data: $e');
      return _generateMockDashaData(date);
    }
  }

  Future<Map<String, dynamic>> generateDivisionalCharts({
    required DateTime date,
    required double latitude,
    required double longitude,
    String chartType = 'D9',
    String timezone = 'Asia/Kolkata',
  }) async {
    try {
      final dateStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      final timeStr = '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}:00';

      // Use new API endpoint: /divisional
      final response = await _dio.post(
        '/divisional',
        data: {
          'birth_data': {
            'date': dateStr,
            'time': timeStr,
            'latitude': latitude,
            'longitude': longitude,
            'timezone': timezone,
          },
          'chart_type': chartType,
        },
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data;
      } else {
        throw Exception(response.data['error'] ?? 'Failed to generate divisional charts');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Error generating divisional charts: $e');
    }
  }
}

