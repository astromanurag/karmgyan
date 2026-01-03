import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../core/models/consultant_model.dart';

class AdminService {
  static String get _baseUrl => AppConfig.backendUrl;

  // Consultant Management
  static Future<List<ConsultantModel>> getConsultants({
    String? status,
  }) async {
    if (AppConfig.useMockData) {
      await Future.delayed(const Duration(milliseconds: 500));
      return _mockConsultants.where((c) {
        if (status != null) return c.status == status;
        return true;
      }).toList();
    }

    final query = status != null ? '?status=$status' : '';
    final response = await http.get(
      Uri.parse('$_baseUrl/api/admin/consultants$query'),
      headers: {'Authorization': 'Bearer ${_getToken()}'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data['consultants'] as List)
          .map((json) => ConsultantModel.fromJson(json))
          .toList();
    } else {
      throw Exception('Failed to fetch consultants: ${response.body}');
    }
  }

  static Future<ConsultantModel> getConsultant(String id) async {
    if (AppConfig.useMockData) {
      await Future.delayed(const Duration(milliseconds: 500));
      return _mockConsultants.firstWhere((c) => c.id == id);
    }

    final response = await http.get(
      Uri.parse('$_baseUrl/api/admin/consultants/$id'),
      headers: {'Authorization': 'Bearer ${_getToken()}'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return ConsultantModel.fromJson(data['consultant']);
    } else {
      throw Exception('Failed to fetch consultant: ${response.body}');
    }
  }

  static Future<ConsultantModel> approveConsultant(String id) async {
    if (AppConfig.useMockData) {
      await Future.delayed(const Duration(seconds: 1));
      final consultant = _mockConsultants.firstWhere((c) => c.id == id);
      return consultant.copyWith(
        status: 'approved',
        approvedAt: DateTime.now(),
        approvedBy: 'admin_001',
      );
    }

    final response = await http.post(
      Uri.parse('$_baseUrl/api/admin/consultants/$id/approve'),
      headers: {'Authorization': 'Bearer ${_getToken()}'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return ConsultantModel.fromJson(data['consultant']);
    } else {
      throw Exception('Failed to approve consultant: ${response.body}');
    }
  }

  static Future<ConsultantModel> rejectConsultant(String id, String reason) async {
    if (AppConfig.useMockData) {
      await Future.delayed(const Duration(seconds: 1));
      final consultant = _mockConsultants.firstWhere((c) => c.id == id);
      return consultant.copyWith(status: 'rejected');
    }

    final response = await http.post(
      Uri.parse('$_baseUrl/api/admin/consultants/$id/reject'),
      headers: {
        'Authorization': 'Bearer ${_getToken()}',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'reason': reason}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return ConsultantModel.fromJson(data['consultant']);
    } else {
      throw Exception('Failed to reject consultant: ${response.body}');
    }
  }

  static Future<ConsultantModel> updateConsultantStatus(
    String id,
    String status,
  ) async {
    if (AppConfig.useMockData) {
      await Future.delayed(const Duration(seconds: 1));
      final consultant = _mockConsultants.firstWhere((c) => c.id == id);
      return consultant.copyWith(status: status);
    }

    final response = await http.patch(
      Uri.parse('$_baseUrl/api/admin/consultants/$id/status'),
      headers: {
        'Authorization': 'Bearer ${_getToken()}',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'status': status}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return ConsultantModel.fromJson(data['consultant']);
    } else {
      throw Exception('Failed to update consultant: ${response.body}');
    }
  }

  // Data Management
  static Future<void> uploadServices(List<Map<String, dynamic>> services) async {
    if (AppConfig.useMockData) {
      await Future.delayed(const Duration(seconds: 1));
      return;
    }

    final response = await http.post(
      Uri.parse('$_baseUrl/api/admin/data/services'),
      headers: {
        'Authorization': 'Bearer ${_getToken()}',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'services': services}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to upload services: ${response.body}');
    }
  }

  static Future<void> uploadReports(List<Map<String, dynamic>> reports) async {
    if (AppConfig.useMockData) {
      await Future.delayed(const Duration(seconds: 1));
      return;
    }

    final response = await http.post(
      Uri.parse('$_baseUrl/api/admin/data/reports'),
      headers: {
        'Authorization': 'Bearer ${_getToken()}',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'reports': reports}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to upload reports: ${response.body}');
    }
  }

  // Analytics
  static Future<Map<String, dynamic>> getAnalytics() async {
    if (AppConfig.useMockData) {
      await Future.delayed(const Duration(milliseconds: 500));
      return {
        'total_users': 1250,
        'total_consultants': 45,
        'total_orders': 320,
        'total_revenue': 125000.0,
        'pending_consultants': 5,
        'active_consultations': 12,
      };
    }

    final response = await http.get(
      Uri.parse('$_baseUrl/api/admin/analytics'),
      headers: {'Authorization': 'Bearer ${_getToken()}'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch analytics: ${response.body}');
    }
  }

  // Helper
  static String? _getToken() {
    // In production, get from auth service
    return null;
  }

  // Mock data
  static final List<ConsultantModel> _mockConsultants = [
    ConsultantModel(
      id: 'consultant_001',
      userId: 'user_001',
      name: 'Dr. Priya Sharma',
      specialization: 'Vedic Astrology',
      experienceYears: 15,
      hourlyRate: 999.0,
      bio: 'Expert in Vedic astrology with 15 years of experience',
      status: 'approved',
      availability: {
        'monday': ['09:00-12:00', '14:00-18:00'],
        'tuesday': ['09:00-12:00', '14:00-18:00'],
      },
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      approvedAt: DateTime.now().subtract(const Duration(days: 25)),
      approvedBy: 'admin_001',
    ),
    ConsultantModel(
      id: 'consultant_002',
      userId: 'user_002',
      name: 'Dr. Rajesh Kumar',
      specialization: 'Numerology',
      experienceYears: 10,
      hourlyRate: 799.0,
      bio: 'Numerology expert',
      status: 'pending',
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
  ];
}

extension ConsultantModelExtension on ConsultantModel {
  ConsultantModel copyWith({
    String? id,
    String? userId,
    String? name,
    String? specialization,
    int? experienceYears,
    double? hourlyRate,
    String? bio,
    String? profilePhotoUrl,
    String? status,
    Map<String, dynamic>? availability,
    List<Map<String, dynamic>>? qualifications,
    DateTime? createdAt,
    DateTime? approvedAt,
    String? approvedBy,
  }) {
    return ConsultantModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      specialization: specialization ?? this.specialization,
      experienceYears: experienceYears ?? this.experienceYears,
      hourlyRate: hourlyRate ?? this.hourlyRate,
      bio: bio ?? this.bio,
      profilePhotoUrl: profilePhotoUrl ?? this.profilePhotoUrl,
      status: status ?? this.status,
      availability: availability ?? this.availability,
      qualifications: qualifications ?? this.qualifications,
      createdAt: createdAt ?? this.createdAt,
      approvedAt: approvedAt ?? this.approvedAt,
      approvedBy: approvedBy ?? this.approvedBy,
    );
  }
}

