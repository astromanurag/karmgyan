import 'package:dio/dio.dart';
import '../config/app_config.dart';
import '../core/utils/app_logger.dart';

class MatchingService {
  static final MatchingService _instance = MatchingService._internal();
  factory MatchingService() => _instance;
  MatchingService._internal();

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

  Future<Map<String, dynamic>> computeCompatibility({
    required Map<String, dynamic> person1,
    required Map<String, dynamic> person2,
  }) async {
    try {
      if (AppConfig.useMockData) {
        AppLogger.i('📊 [MatchingService] Using mock data for compatibility');
        await Future.delayed(const Duration(seconds: 2));
        return _getMockCompatibility();
      }

      AppLogger.i('💑 [MatchingService] Computing compatibility');
      AppLogger.logRequest(
        method: 'POST',
        url: '${AppConfig.backendUrl}/api/matching/compatibility',
        body: {
          'person1': person1,
          'person2': person2,
        },
      );

      final stopwatch = Stopwatch()..start();
      // Use new API endpoint: /compatibility
      // Ensure time format is HH:MM:SS (backend expects this format)
      String formatTime(String timeStr) {
        if (timeStr.contains(':')) {
          final parts = timeStr.split(':');
          if (parts.length == 2) {
            // Add seconds if missing
            return '${parts[0]}:${parts[1]}:00';
          }
        }
        return timeStr;
      }
      
      final requestData = {
        'person1': {
          'date': person1['date'],
          'time': formatTime(person1['time'] ?? '12:00:00'),
          'latitude': (person1['latitude'] as num).toDouble(),
          'longitude': (person1['longitude'] as num).toDouble(),
          'timezone': person1['timezone'] ?? 'Asia/Kolkata',
        },
        'person2': {
          'date': person2['date'],
          'time': formatTime(person2['time'] ?? '12:00:00'),
          'latitude': (person2['latitude'] as num).toDouble(),
          'longitude': (person2['longitude'] as num).toDouble(),
          'timezone': person2['timezone'] ?? 'Asia/Kolkata',
        },
      };
      
      AppLogger.d('📤 [MatchingService] Request data: $requestData');
      
      final response = await _dio.post(
        '/compatibility',
        data: requestData,
      );
      stopwatch.stop();

      AppLogger.logResponse(
        method: 'POST',
        url: '${AppConfig.backendUrl}/compatibility',
        statusCode: response.statusCode ?? 0,
        body: response.data,
        duration: stopwatch.elapsed,
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        AppLogger.i('✅ [MatchingService] Compatibility computed successfully', null, null, {
          'totalPoints': response.data['guna_milan']?['total_points'],
          'percentage': response.data['guna_milan']?['percentage'],
        });
        return response.data;
      } else {
        final error = response.data['error'] ?? response.data['detail'] ?? 'Failed to compute compatibility';
        AppLogger.e('❌ [MatchingService] Compatibility computation failed', null, null, {'error': error});
        throw Exception(error);
      }
    } on DioException catch (e, stackTrace) {
      AppLogger.logApiError(
        method: 'POST',
        url: '${AppConfig.backendUrl}/compatibility',
        error: e,
        stackTrace: stackTrace,
        statusCode: e.response?.statusCode,
        responseBody: e.response?.data,
      );
      throw Exception('Network error: ${e.message}');
    } catch (e, stackTrace) {
      AppLogger.e('❌ [MatchingService] Error computing compatibility', e, stackTrace);
      throw Exception('Error computing compatibility: $e');
    }
  }

  Map<String, dynamic> _getMockCompatibility() {
    return {
      'success': true,
      'guna_milan': {
        'total_points': 28,
        'out_of': 36,
        'percentage': 77.8,
        'details': [
          {'guna': 'Varna', 'points': 1, 'max_points': 1, 'description': 'Compatible'},
          {'guna': 'Vashya', 'points': 2, 'max_points': 2, 'description': 'Very Compatible'},
          {'guna': 'Tara', 'points': 3, 'max_points': 3, 'description': 'Excellent'},
          {'guna': 'Yoni', 'points': 2, 'max_points': 4, 'description': 'Moderate'},
          {'guna': 'Graha Maitri', 'points': 5, 'max_points': 5, 'description': 'Excellent'},
          {'guna': 'Gana', 'points': 6, 'max_points': 6, 'description': 'Perfect Match'},
          {'guna': 'Bhakut', 'points': 0, 'max_points': 7, 'description': 'Incompatible'},
          {'guna': 'Nadi', 'points': 8, 'max_points': 8, 'description': 'Perfect Match'},
        ],
      },
      'doshas': {
        'mangal_dosha': {
          'person1': false,
          'person2': false,
          'compatible': true,
        },
        'nadi_dosha': {
          'present': false,
          'compatible': true,
        },
        'bhakut_dosha': {
          'present': true,
          'severity': 'high',
          'compatible': false,
        },
      },
      'overall_compatibility': 'Good',
      'recommendation': 'Marriage is recommended with some remedies for Bhakut Dosha.',
    };
  }
}

