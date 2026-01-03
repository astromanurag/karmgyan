import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';

class ConsultantService {
  static String get _baseUrl => AppConfig.backendUrl;

  // Get consultant dashboard data
  static Future<Map<String, dynamic>> getDashboardData() async {
    if (AppConfig.useMockData) {
      await Future.delayed(const Duration(milliseconds: 500));
      return {
        'upcoming_consultations': 3,
        'today_schedule': [
          {
            'id': 'consultation_001',
            'client_name': 'John Doe',
            'time': '10:00 AM',
            'type': 'video',
          },
        ],
        'earnings_summary': {
          'this_month': 25000.0,
          'total': 125000.0,
        },
        'pending_requests': 2,
      };
    }

    final response = await http.get(
      Uri.parse('$_baseUrl/api/consultant/dashboard'),
      headers: {'Authorization': 'Bearer ${_getToken()}'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch dashboard data: ${response.body}');
    }
  }

  // Get earnings
  static Future<Map<String, dynamic>> getEarnings({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    if (AppConfig.useMockData) {
      await Future.delayed(const Duration(milliseconds: 500));
      return {
        'earnings': [
          {
            'id': 'earning_001',
            'date': DateTime.now().subtract(const Duration(days: 5)).toIso8601String(),
            'amount': 1998.0,
            'consultation_id': 'consultation_001',
            'client_name': 'John Doe',
          },
        ],
        'total': 125000.0,
        'pending_payout': 15000.0,
      };
    }

    final query = startDate != null && endDate != null
        ? '?start_date=${startDate.toIso8601String()}&end_date=${endDate.toIso8601String()}'
        : '';
    final response = await http.get(
      Uri.parse('$_baseUrl/api/consultant/earnings$query'),
      headers: {'Authorization': 'Bearer ${_getToken()}'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch earnings: ${response.body}');
    }
  }

  // Update availability
  static Future<void> updateAvailability(Map<String, dynamic> availability) async {
    if (AppConfig.useMockData) {
      await Future.delayed(const Duration(seconds: 1));
      return;
    }

    final response = await http.post(
      Uri.parse('$_baseUrl/api/consultant/availability'),
      headers: {
        'Authorization': 'Bearer ${_getToken()}',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'availability': availability}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update availability: ${response.body}');
    }
  }

  // Get consultations
  static Future<List<Map<String, dynamic>>> getConsultations({
    String? status,
  }) async {
    if (AppConfig.useMockData) {
      await Future.delayed(const Duration(milliseconds: 500));
      return [
        {
          'id': 'consultation_001',
          'client_name': 'John Doe',
          'date': DateTime.now().add(const Duration(days: 1)).toIso8601String(),
          'time': '10:00 AM',
          'type': 'video',
          'status': 'scheduled',
        },
      ];
    }

    final query = status != null ? '?status=$status' : '';
    final response = await http.get(
      Uri.parse('$_baseUrl/api/consultant/consultations$query'),
      headers: {'Authorization': 'Bearer ${_getToken()}'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data['consultations']);
    } else {
      throw Exception('Failed to fetch consultations: ${response.body}');
    }
  }

  // Accept/Reject consultation request
  static Future<void> respondToConsultationRequest(
    String consultationId,
    bool accept,
  ) async {
    if (AppConfig.useMockData) {
      await Future.delayed(const Duration(seconds: 1));
      return;
    }

    final response = await http.post(
      Uri.parse('$_baseUrl/api/consultant/consultations/$consultationId/respond'),
      headers: {
        'Authorization': 'Bearer ${_getToken()}',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'accept': accept}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to respond to request: ${response.body}');
    }
  }

  static String? _getToken() {
    // In production, get from auth service
    return null;
  }
}

