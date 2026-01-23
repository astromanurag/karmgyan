import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../config/env_config.dart';
import '../core/services/local_storage_service.dart';
import 'supabase_service.dart';

class HoroscopeService {
  static const String _cacheKeyPrefix = 'horoscope_';

  // Get daily horoscope for a zodiac sign
  static Future<Map<String, dynamic>> getDailyHoroscope(String zodiacSign, {DateTime? date}) async {
    final dateStr = date != null 
        ? '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}'
        : DateTime.now().toString().split(' ')[0];
    
    final cacheKey = '${_cacheKeyPrefix}${dateStr}_$zodiacSign';

    // Try to load from cache first
    final cached = LocalStorageService.get(cacheKey);
    if (cached != null && cached is Map<String, dynamic>) {
      return cached;
    }

    // Try to load from Supabase
    if (AppConfig.hasSupabaseConfig) {
      try {
        final horoscopes = await SupabaseService.queryWithCache(
          table: 'daily_horoscopes',
          cacheKey: 'horoscopes_$dateStr',
          filters: {
            'date': dateStr,
            'zodiac_sign': zodiacSign,
          },
        );

        if (horoscopes.isNotEmpty) {
          final horoscope = horoscopes.first;
          final contentJson = horoscope['content_json'];
          Map<String, dynamic> content;
          
          if (contentJson is String) {
            // Parse JSON string
            content = jsonDecode(contentJson) as Map<String, dynamic>;
          } else if (contentJson is Map) {
            content = Map<String, dynamic>.from(contentJson);
          } else {
            content = {};
          }
          
          final result = {
            'date': dateStr,
            'zodiac_sign': zodiacSign,
            'content': content,
          };
          
          // Cache it
          await LocalStorageService.save(cacheKey, result);
          return result;
        }
      } catch (e) {
        print('Error loading from Supabase: $e');
      }
    }

    // Fetch from backend API
    try {
      final url = Uri.parse('${EnvConfig.backendUrl}/api/horoscope/daily/$zodiacSign?date=$dateStr');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        if (data['success'] == true) {
          final result = {
            'date': data['date'] as String,
            'zodiac_sign': data['zodiac_sign'] as String,
            'content': data['content_json'] as Map<String, dynamic>,
          };
          
          // Cache it
          await LocalStorageService.save(cacheKey, result);
          
          return result;
        } else {
          throw Exception(data['error'] ?? 'Failed to fetch horoscope');
        }
      } else {
        throw Exception('HTTP error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching horoscope: $e');
      // Return default/empty horoscope on error
      return {
        'date': dateStr,
        'zodiac_sign': zodiacSign,
        'content': {
          'love': 'Check back later for today\'s horoscope.',
          'career': '',
          'health': '',
          'personal_growth': '',
          'lucky_numbers': [],
          'lucky_colors': [],
          'overall_forecast': '',
        },
      };
    }
  }

  // Get zodiac sign from birth date
  static String getZodiacSign(DateTime birthDate) {
    final month = birthDate.month;
    final day = birthDate.day;

    if ((month == 3 && day >= 21) || (month == 4 && day <= 19)) return 'Aries';
    if ((month == 4 && day >= 20) || (month == 5 && day <= 20)) return 'Taurus';
    if ((month == 5 && day >= 21) || (month == 6 && day <= 20)) return 'Gemini';
    if ((month == 6 && day >= 21) || (month == 7 && day <= 22)) return 'Cancer';
    if ((month == 7 && day >= 23) || (month == 8 && day <= 22)) return 'Leo';
    if ((month == 8 && day >= 23) || (month == 9 && day <= 22)) return 'Virgo';
    if ((month == 9 && day >= 23) || (month == 10 && day <= 22)) return 'Libra';
    if ((month == 10 && day >= 23) || (month == 11 && day <= 21)) return 'Scorpio';
    if ((month == 11 && day >= 22) || (month == 12 && day <= 21)) return 'Sagittarius';
    if ((month == 12 && day >= 22) || (month == 1 && day <= 19)) return 'Capricorn';
    if ((month == 1 && day >= 20) || (month == 2 && day <= 18)) return 'Aquarius';
    return 'Pisces'; // (month == 2 && day >= 19) || (month == 3 && day <= 20)
  }
}
