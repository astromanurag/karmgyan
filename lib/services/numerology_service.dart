import 'package:dio/dio.dart';
import '../config/app_config.dart';
import '../core/utils/app_logger.dart';

class NumerologyService {
  static final NumerologyService _instance = NumerologyService._internal();
  factory NumerologyService() => _instance;
  NumerologyService._internal();

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

  /// Analyze a name to get all numerology numbers
  Future<Map<String, dynamic>> analyzeName({
    required String name,
    String? birthDate,
    String system = 'pythagorean',
  }) async {
    try {
      AppLogger.i('🔢 [NumerologyService] Analyzing name: $name', null, null, {
        'name': name,
        'birthDate': birthDate,
        'system': system,
      });
      
      AppLogger.logRequest(
        method: 'POST',
        url: '${AppConfig.backendUrl}/api/numerology/analyze',
        body: {
          'name': name,
          if (birthDate != null) 'birthDate': birthDate,
          'system': system,
        },
      );

      final stopwatch = Stopwatch()..start();
      final response = await _dio.post(
        '/api/numerology/analyze',
        data: {
          'name': name,
          if (birthDate != null) 'birthDate': birthDate,
          'system': system,
        },
      );
      stopwatch.stop();

      AppLogger.logResponse(
        method: 'POST',
        url: '${AppConfig.backendUrl}/api/numerology/analyze',
        statusCode: response.statusCode ?? 0,
        body: response.data,
        duration: stopwatch.elapsed,
      );
      
      if (response.statusCode == 200 && response.data['success'] == true) {
        AppLogger.i('✅ [NumerologyService] Name analysis completed', null, null, {
          'destinyNumber': response.data['destiny_number']?['number'],
        });
        return response.data;
      } else {
        final error = response.data['error'] ?? 'Failed to analyze name';
        AppLogger.e('❌ [NumerologyService] Analysis failed', null, null, {'error': error});
        throw Exception(error);
      }
    } on DioException catch (e, stackTrace) {
      AppLogger.logApiError(
        method: 'POST',
        url: '${AppConfig.backendUrl}/api/numerology/analyze',
        error: e,
        stackTrace: stackTrace,
        statusCode: e.response?.statusCode,
        responseBody: e.response?.data,
      );
      throw Exception('Network error: ${e.message}');
    } catch (e, stackTrace) {
      AppLogger.e('❌ [NumerologyService] Error analyzing name', e, stackTrace);
      throw Exception('Error analyzing name: $e');
    }
  }

  /// Check compatibility between two numbers
  Future<Map<String, dynamic>> checkCompatibility({
    required int number1,
    required int number2,
    String system = 'pythagorean',
  }) async {
    try {
      AppLogger.i('🔢 [NumerologyService] Checking compatibility: $number1 & $number2');
      
      AppLogger.logRequest(
        method: 'GET',
        url: '${AppConfig.backendUrl}/api/numerology/compatibility',
        queryParams: {
          'number1': number1.toString(),
          'number2': number2.toString(),
          'system': system,
        },
      );

      final stopwatch = Stopwatch()..start();
      final response = await _dio.get(
        '/api/numerology/compatibility',
        queryParameters: {
          'number1': number1,
          'number2': number2,
          'system': system,
        },
      );
      stopwatch.stop();

      AppLogger.logResponse(
        method: 'GET',
        url: '${AppConfig.backendUrl}/api/numerology/compatibility',
        statusCode: response.statusCode ?? 0,
        body: response.data,
        duration: stopwatch.elapsed,
      );
      
      if (response.statusCode == 200 && response.data['success'] == true) {
        AppLogger.i('✅ [NumerologyService] Compatibility checked', null, null, {
          'compatibility': response.data['compatibility'],
        });
        return response.data;
      } else {
        final error = response.data['error'] ?? 'Failed to check compatibility';
        AppLogger.e('❌ [NumerologyService] Compatibility check failed', null, null, {'error': error});
        throw Exception(error);
      }
    } on DioException catch (e, stackTrace) {
      AppLogger.logApiError(
        method: 'GET',
        url: '${AppConfig.backendUrl}/api/numerology/compatibility',
        error: e,
        stackTrace: stackTrace,
        statusCode: e.response?.statusCode,
        responseBody: e.response?.data,
      );
      throw Exception('Network error: ${e.message}');
    } catch (e, stackTrace) {
      AppLogger.e('❌ [NumerologyService] Error checking compatibility', e, stackTrace);
      throw Exception('Error checking compatibility: $e');
    }
  }

  /// Suggest name spellings for a target number
  Future<Map<String, dynamic>> suggestNames({
    required String name,
    required int targetNumber,
    String system = 'pythagorean',
  }) async {
    try {
      AppLogger.i('🔢 [NumerologyService] Suggesting names for: $name, target: $targetNumber');
      
      AppLogger.logRequest(
        method: 'POST',
        url: '${AppConfig.backendUrl}/api/numerology/suggest-names',
        body: {
          'name': name,
          'targetNumber': targetNumber,
          'system': system,
        },
      );

      final stopwatch = Stopwatch()..start();
      final response = await _dio.post(
        '/api/numerology/suggest-names',
        data: {
          'name': name,
          'targetNumber': targetNumber,
          'system': system,
        },
      );
      stopwatch.stop();

      AppLogger.logResponse(
        method: 'POST',
        url: '${AppConfig.backendUrl}/api/numerology/suggest-names',
        statusCode: response.statusCode ?? 0,
        body: response.data,
        duration: stopwatch.elapsed,
      );

      AppLogger.i('✅ [NumerologyService] Suggestions generated', null, null, {
        'count': response.data['suggestions']?.length ?? 0,
      });
      
      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data;
      } else {
        throw Exception(response.data['error'] ?? 'Failed to suggest names');
      }
    } on DioException catch (e) {
      AppLogger.logApiError(
        method: 'POST',
        url: '${AppConfig.backendUrl}/api/numerology/suggest-names',
        error: e,
        stackTrace: null,
        statusCode: e.response?.statusCode,
        responseBody: e.response?.data,
      );
      throw Exception('Network error: ${e.message}');
    } catch (e, stackTrace) {
      AppLogger.e('❌ [NumerologyService] Error suggesting names', e, stackTrace);
      throw Exception('Error suggesting names: $e');
    }
  }

  /// Calculate number for a name
  Future<Map<String, dynamic>> calculateNameNumber({
    required String name,
    String system = 'pythagorean',
  }) async {
    try {
      AppLogger.i('🔢 [NumerologyService] Calculating number for name: $name');
      
      AppLogger.logRequest(
        method: 'POST',
        url: '${AppConfig.backendUrl}/api/numerology/calculate-name-number',
        body: {'name': name, 'system': system},
      );

      final stopwatch = Stopwatch()..start();
      final response = await _dio.post(
        '/api/numerology/calculate-name-number',
        data: {
          'name': name,
          'system': system,
        },
      );
      stopwatch.stop();

      AppLogger.logResponse(
        method: 'POST',
        url: '${AppConfig.backendUrl}/api/numerology/calculate-name-number',
        statusCode: response.statusCode ?? 0,
        body: response.data,
        duration: stopwatch.elapsed,
      );

      AppLogger.i('✅ [NumerologyService] Name number calculated', null, null, {
        'number': response.data['number'],
      });
      
      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data;
      } else {
        throw Exception(response.data['error'] ?? 'Failed to calculate name number');
      }
    } on DioException catch (e) {
      print('❌ Network error: ${e.message}');
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      print('❌ Error calculating name number: $e');
      throw Exception('Error calculating name number: $e');
    }
  }

  /// Get Loshu grid for a birth date
  Future<Map<String, dynamic>> getLoshuGrid({
    required DateTime birthDate,
  }) async {
    try {
      final dateStr = '${birthDate.year}-${birthDate.month.toString().padLeft(2, '0')}-${birthDate.day.toString().padLeft(2, '0')}';
      AppLogger.i('🔢 [NumerologyService] Calculating Loshu grid for date: $dateStr');
      
      AppLogger.logRequest(
        method: 'POST',
        url: '${AppConfig.backendUrl}/api/numerology/loshu-grid',
        body: {'birthDate': dateStr},
      );

      final stopwatch = Stopwatch()..start();
      final response = await _dio.post(
        '/api/numerology/loshu-grid',
        data: {
          'birthDate': dateStr,
        },
      );
      stopwatch.stop();

      AppLogger.logResponse(
        method: 'POST',
        url: '${AppConfig.backendUrl}/api/numerology/loshu-grid',
        statusCode: response.statusCode ?? 0,
        body: response.data,
        duration: stopwatch.elapsed,
      );

      AppLogger.i('✅ [NumerologyService] Loshu grid calculated');
      
      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data;
      } else {
        throw Exception(response.data['error'] ?? 'Failed to calculate Loshu grid');
      }
    } on DioException catch (e) {
      print('❌ Network error: ${e.message}');
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      print('❌ Error calculating Loshu grid: $e');
      throw Exception('Error calculating Loshu grid: $e');
    }
  }

  /// Suggest names by number (without base name)
  Future<Map<String, dynamic>> suggestNamesByNumber({
    required int targetNumber,
    String system = 'pythagorean',
    int? nameLength,
    String language = 'en',
    String? religion,
    String? gender,
    List<String>? excludeNames,
  }) async {
    try {
      AppLogger.i('🔢 [NumerologyService] Suggesting names for number: $targetNumber', null, null, {
        'targetNumber': targetNumber,
        'system': system,
        'language': language,
      });
      
      AppLogger.logRequest(
        method: 'POST',
        url: '${AppConfig.backendUrl}/api/numerology/suggest-names-by-number',
        body: {
          'targetNumber': targetNumber,
          'system': system,
          if (nameLength != null) 'nameLength': nameLength,
          'language': language,
          if (religion != null) 'religion': religion,
          if (gender != null) 'gender': gender,
          if (excludeNames != null && excludeNames.isNotEmpty) 'excludeNames': excludeNames,
        },
      );

      final stopwatch = Stopwatch()..start();
      final response = await _dio.post(
        '/api/numerology/suggest-names-by-number',
        data: {
          'targetNumber': targetNumber,
          'system': system,
          if (nameLength != null) 'nameLength': nameLength,
          'language': language,
          if (religion != null) 'religion': religion,
          if (gender != null) 'gender': gender,
          if (excludeNames != null && excludeNames.isNotEmpty) 'excludeNames': excludeNames,
        },
      );
      stopwatch.stop();

      AppLogger.logResponse(
        method: 'POST',
        url: '${AppConfig.backendUrl}/api/numerology/suggest-names-by-number',
        statusCode: response.statusCode ?? 0,
        body: response.data,
        duration: stopwatch.elapsed,
      );

      AppLogger.i('✅ [NumerologyService] Names suggested', null, null, {
        'count': response.data['suggestions']?.length ?? 0,
      });
      
      if (response.statusCode == 200) {
        // Handle both success: true and direct result formats
        if (response.data['success'] == true || response.data['suggestions'] != null) {
          return response.data;
        } else {
          throw Exception(response.data['error'] ?? 'Failed to suggest names');
        }
      } else {
        throw Exception(response.data['error'] ?? 'Failed to suggest names');
      }
    } on DioException catch (e) {
      AppLogger.logApiError(
        method: 'POST',
        url: '${AppConfig.backendUrl}/api/numerology/suggest-names',
        error: e,
        stackTrace: null,
        statusCode: e.response?.statusCode,
        responseBody: e.response?.data,
      );
      throw Exception('Network error: ${e.message}');
    } catch (e, stackTrace) {
      AppLogger.e('❌ [NumerologyService] Error suggesting names', e, stackTrace);
      throw Exception('Error suggesting names: $e');
    }
  }

  /// Get number meanings (1-9, 11, 22, 33)
  Map<String, dynamic> getNumberMeaning(int number) {
    final meanings = {
      1: {
        'title': 'The Leader',
        'keywords': ['Independence', 'Leadership', 'Ambition', 'Originality'],
        'emoji': '👑',
        'color': 0xFFE74C3C, // Red
      },
      2: {
        'title': 'The Peacemaker',
        'keywords': ['Harmony', 'Cooperation', 'Diplomacy', 'Sensitivity'],
        'emoji': '☮️',
        'color': 0xFFECF0F1, // White
      },
      3: {
        'title': 'The Creative',
        'keywords': ['Creativity', 'Expression', 'Joy', 'Communication'],
        'emoji': '🎨',
        'color': 0xFFF1C40F, // Yellow
      },
      4: {
        'title': 'The Builder',
        'keywords': ['Stability', 'Hard work', 'Discipline', 'Organization'],
        'emoji': '🏗️',
        'color': 0xFF3498DB, // Blue
      },
      5: {
        'title': 'The Free Spirit',
        'keywords': ['Freedom', 'Adventure', 'Change', 'Versatility'],
        'emoji': '🌟',
        'color': 0xFF2ECC71, // Green
      },
      6: {
        'title': 'The Nurturer',
        'keywords': ['Love', 'Responsibility', 'Harmony', 'Service'],
        'emoji': '💖',
        'color': 0xFFE91E63, // Pink
      },
      7: {
        'title': 'The Seeker',
        'keywords': ['Wisdom', 'Spirituality', 'Analysis', 'Introspection'],
        'emoji': '🔮',
        'color': 0xFF9B59B6, // Purple
      },
      8: {
        'title': 'The Powerhouse',
        'keywords': ['Power', 'Success', 'Abundance', 'Authority'],
        'emoji': '💼',
        'color': 0xFF2C3E50, // Dark blue
      },
      9: {
        'title': 'The Humanitarian',
        'keywords': ['Compassion', 'Wisdom', 'Idealism', 'Service'],
        'emoji': '🌍',
        'color': 0xFFE74C3C, // Red
      },
      11: {
        'title': 'Spiritual Messenger',
        'keywords': ['Intuition', 'Inspiration', 'Spirituality', 'Illumination'],
        'emoji': '✨',
        'color': 0xFFBDC3C7, // Silver
      },
      22: {
        'title': 'Master Builder',
        'keywords': ['Vision', 'Achievement', 'Power', 'Manifestation'],
        'emoji': '🏆',
        'color': 0xFFFF6B6B, // Coral
      },
      33: {
        'title': 'Master Teacher',
        'keywords': ['Service', 'Love', 'Healing', 'Teaching'],
        'emoji': '🙏',
        'color': 0xFFFFD700, // Gold
      },
    };

    return meanings[number] ?? meanings[1]!;
  }
}

