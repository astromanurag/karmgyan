import 'package:dio/dio.dart';
import '../config/app_config.dart';

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
      print('🔢 Analyzing name: $name');
      
      final response = await _dio.post(
        '/api/numerology/analyze',
        data: {
          'name': name,
          if (birthDate != null) 'birthDate': birthDate,
          'system': system,
        },
      );

      print('✅ Name analysis completed: ${response.data['destiny_number']?['number']}');
      
      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data;
      } else {
        throw Exception(response.data['error'] ?? 'Failed to analyze name');
      }
    } on DioException catch (e) {
      print('❌ Network error: ${e.message}');
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      print('❌ Error analyzing name: $e');
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
      print('🔢 Checking compatibility: $number1 & $number2');
      
      final response = await _dio.get(
        '/api/numerology/compatibility',
        queryParameters: {
          'number1': number1,
          'number2': number2,
          'system': system,
        },
      );

      print('✅ Compatibility: ${response.data['compatibility']}');
      
      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data;
      } else {
        throw Exception(response.data['error'] ?? 'Failed to check compatibility');
      }
    } on DioException catch (e) {
      print('❌ Network error: ${e.message}');
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      print('❌ Error checking compatibility: $e');
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
      print('🔢 Suggesting names for: $name, target: $targetNumber');
      
      final response = await _dio.post(
        '/api/numerology/suggest-names',
        data: {
          'name': name,
          'targetNumber': targetNumber,
          'system': system,
        },
      );

      print('✅ Suggestions generated: ${response.data['suggestions']?.length ?? 0}');
      
      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data;
      } else {
        throw Exception(response.data['error'] ?? 'Failed to suggest names');
      }
    } on DioException catch (e) {
      print('❌ Network error: ${e.message}');
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      print('❌ Error suggesting names: $e');
      throw Exception('Error suggesting names: $e');
    }
  }

  /// Calculate number for a name
  Future<Map<String, dynamic>> calculateNameNumber({
    required String name,
    String system = 'pythagorean',
  }) async {
    try {
      print('🔢 Calculating number for name: $name');
      
      final response = await _dio.post(
        '/api/numerology/calculate-name-number',
        data: {
          'name': name,
          'system': system,
        },
      );

      print('✅ Name number calculated: ${response.data['number']}');
      
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
      print('🔢 Calculating Loshu grid for date: $dateStr');
      
      final response = await _dio.post(
        '/api/numerology/loshu-grid',
        data: {
          'birthDate': dateStr,
        },
      );

      print('✅ Loshu grid calculated');
      
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
      print('🔢 Suggesting names for number: $targetNumber');
      
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

      print('✅ Names suggested: ${response.data['suggestions']?.length ?? 0}');
      print('Response data: ${response.data}');
      
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
      print('❌ Network error: ${e.message}');
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      print('❌ Error suggesting names: $e');
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

