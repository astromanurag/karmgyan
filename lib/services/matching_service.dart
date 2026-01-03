import 'package:dio/dio.dart';
import '../config/app_config.dart';

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
      },
    ),
  );

  Future<Map<String, dynamic>> computeCompatibility({
    required Map<String, dynamic> person1,
    required Map<String, dynamic> person2,
  }) async {
    try {
      if (AppConfig.useMockData) {
        await Future.delayed(const Duration(seconds: 2));
        return _getMockCompatibility();
      }

      final response = await _dio.post(
        '/api/matching/compatibility',
        data: {
          'person1': person1,
          'person2': person2,
        },
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data;
      } else {
        throw Exception(response.data['error'] ?? 'Failed to compute compatibility');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
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

