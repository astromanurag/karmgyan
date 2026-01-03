import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../config/env_config.dart';

/// Service for AI-powered astrological predictions
class AIService {
  static final AIService _instance = AIService._internal();
  factory AIService() => _instance;
  AIService._internal();

  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: EnvConfig.backendUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 120), // AI responses take time
      headers: {
        'Content-Type': 'application/json',
      },
    ),
  );

  String? _userId;

  /// Set current user ID for credit tracking
  void setUserId(String userId) {
    _userId = userId;
    _dio.options.headers['X-User-Id'] = userId;
  }

  /// Ask AI a question about the chart
  Future<AIResponse> askQuestion({
    required Map<String, dynamic> chartData,
    required String question,
    String? conversationId,
  }) async {
    try {
      debugPrint('🤖 Asking AI: ${question.substring(0, question.length.clamp(0, 50))}...');
      
      final response = await _dio.post(
        '/api/ai/ask',
        data: {
          'chartData': chartData,
          'question': question,
          if (conversationId != null) 'conversationId': conversationId,
          if (_userId != null) 'userId': _userId,
        },
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        debugPrint('✅ AI response received');
        return AIResponse.fromJson(response.data);
      } else if (response.statusCode == 402) {
        return AIResponse(
          success: false,
          error: 'Insufficient credits',
          creditsRequired: response.data['credits_required'],
          creditsAvailable: response.data['credits_available'],
        );
      } else {
        throw Exception(response.data['error'] ?? 'Failed to get AI response');
      }
    } on DioException catch (e) {
      debugPrint('❌ AI request error: ${e.message}');
      return AIResponse(
        success: false,
        error: _getErrorMessage(e),
      );
    } catch (e) {
      debugPrint('❌ AI error: $e');
      return AIResponse(
        success: false,
        error: e.toString(),
      );
    }
  }

  /// Generate AI report
  Future<AIReportResponse> generateReport({
    required Map<String, dynamic> chartData,
    required ReportType reportType,
  }) async {
    try {
      debugPrint('🤖 Generating ${reportType.name} report...');
      
      final response = await _dio.post(
        '/api/ai/generate-report',
        data: {
          'chartData': chartData,
          'reportType': reportType.apiValue,
          if (_userId != null) 'userId': _userId,
        },
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        debugPrint('✅ Report generated');
        return AIReportResponse.fromJson(response.data);
      } else if (response.statusCode == 402) {
        return AIReportResponse(
          success: false,
          error: 'Insufficient credits',
          creditsRequired: response.data['credits_required'],
          creditsAvailable: response.data['credits_available'],
        );
      } else {
        throw Exception(response.data['error'] ?? 'Failed to generate report');
      }
    } on DioException catch (e) {
      debugPrint('❌ Report generation error: ${e.message}');
      return AIReportResponse(
        success: false,
        error: _getErrorMessage(e),
      );
    } catch (e) {
      debugPrint('❌ Report error: $e');
      return AIReportResponse(
        success: false,
        error: e.toString(),
      );
    }
  }

  /// Get user credits
  Future<CreditsInfo> getCredits() async {
    try {
      final response = await _dio.get('/api/ai/credits');
      
      if (response.statusCode == 200 && response.data['success'] == true) {
        return CreditsInfo.fromJson(response.data);
      }
      throw Exception('Failed to get credits');
    } on DioException catch (e) {
      debugPrint('❌ Credits fetch error: ${e.message}');
      // Return mock credits on error
      return CreditsInfo(credits: 10, pricing: {
        'question': 1,
        'report_basic': 5,
        'report_comprehensive': 10,
        'report_yearly': 15,
      });
    } catch (e) {
      debugPrint('❌ Credits error: $e');
      return CreditsInfo(credits: 0, pricing: {});
    }
  }

  /// Get available credit packages
  Future<List<CreditPackage>> getCreditPackages() async {
    try {
      final response = await _dio.get('/api/ai/credit-packages');
      
      if (response.statusCode == 200 && response.data['success'] == true) {
        final packages = (response.data['packages'] as List)
            .map((p) => CreditPackage.fromJson(p))
            .toList();
        return packages;
      }
      return _getDefaultPackages();
    } on DioException catch (e) {
      debugPrint('❌ Packages fetch error: ${e.message}');
      return _getDefaultPackages();
    }
  }

  /// Purchase credits (integrate with payment gateway)
  Future<bool> purchaseCredits({
    required String packageId,
    required String paymentId,
  }) async {
    try {
      final package = (await getCreditPackages())
          .firstWhere((p) => p.id == packageId, orElse: () => throw Exception('Invalid package'));
      
      final response = await _dio.post(
        '/api/ai/credits/purchase',
        data: {
          'amount': package.credits,
          'paymentId': paymentId,
          if (_userId != null) 'userId': _userId,
        },
      );

      return response.statusCode == 200 && response.data['success'] == true;
    } catch (e) {
      debugPrint('❌ Purchase error: $e');
      return false;
    }
  }

  /// Get conversation history
  Future<List<ChatMessage>> getConversationHistory({String? conversationId}) async {
    try {
      final response = await _dio.get(
        '/api/ai/conversations',
        queryParameters: {
          if (conversationId != null) 'conversationId': conversationId,
        },
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return (response.data['messages'] as List)
            .map((m) => ChatMessage.fromJson(m))
            .toList();
      }
      return [];
    } catch (e) {
      debugPrint('❌ Conversation fetch error: $e');
      return [];
    }
  }

  /// Get saved reports
  Future<List<SavedReport>> getSavedReports() async {
    try {
      final response = await _dio.get('/api/ai/reports');

      if (response.statusCode == 200 && response.data['success'] == true) {
        return (response.data['reports'] as List)
            .map((r) => SavedReport.fromJson(r))
            .toList();
      }
      return [];
    } catch (e) {
      debugPrint('❌ Reports fetch error: $e');
      return [];
    }
  }

  /// Get specific report by ID
  Future<SavedReport?> getReport(String reportId) async {
    try {
      final response = await _dio.get('/api/ai/reports/$reportId');

      if (response.statusCode == 200 && response.data['success'] == true) {
        return SavedReport.fromJson(response.data['report']);
      }
      return null;
    } catch (e) {
      debugPrint('❌ Report fetch error: $e');
      return null;
    }
  }

  List<CreditPackage> _getDefaultPackages() {
    return [
      CreditPackage(id: 'pack_10', credits: 10, priceInr: 99, priceUsd: 1.50),
      CreditPackage(id: 'pack_50', credits: 50, priceInr: 399, priceUsd: 6.00, savings: '20%', isPopular: true),
      CreditPackage(id: 'pack_100', credits: 100, priceInr: 699, priceUsd: 10.00, savings: '30%'),
    ];
  }

  String _getErrorMessage(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return 'Request timed out. AI is taking too long to respond.';
    } else if (e.type == DioExceptionType.connectionError) {
      return 'No internet connection. Please check your network.';
    } else {
      return e.message ?? 'An error occurred';
    }
  }
}

/// Report types
enum ReportType {
  comprehensive('comprehensive', 'Comprehensive Life Reading', 10),
  career('career', 'Career Guidance', 5),
  marriage('marriage', 'Marriage & Relationships', 5),
  yearly('yearly', 'Yearly Forecast', 15);

  final String apiValue;
  final String displayName;
  final int creditCost;

  const ReportType(this.apiValue, this.displayName, this.creditCost);
}

/// AI Response model
class AIResponse {
  final bool success;
  final String? answer;
  final String? error;
  final Map<String, dynamic>? usage;
  final String? model;
  final bool isMock;
  final int? creditsUsed;
  final int? creditsRemaining;
  final int? creditsRequired;
  final int? creditsAvailable;
  final String? conversationId;
  final String? timestamp;

  AIResponse({
    required this.success,
    this.answer,
    this.error,
    this.usage,
    this.model,
    this.isMock = false,
    this.creditsUsed,
    this.creditsRemaining,
    this.creditsRequired,
    this.creditsAvailable,
    this.conversationId,
    this.timestamp,
  });

  factory AIResponse.fromJson(Map<String, dynamic> json) {
    return AIResponse(
      success: json['success'] ?? false,
      answer: json['answer'],
      error: json['error'],
      usage: json['usage'],
      model: json['model'],
      isMock: json['is_mock'] ?? false,
      creditsUsed: json['credits_used'],
      creditsRemaining: json['credits_remaining'],
      conversationId: json['conversation_id'],
      timestamp: json['timestamp'],
    );
  }
}

/// AI Report Response model
class AIReportResponse {
  final bool success;
  final String? reportId;
  final String? reportType;
  final String? content;
  final String? error;
  final Map<String, dynamic>? usage;
  final int? creditsUsed;
  final int? creditsRemaining;
  final int? creditsRequired;
  final int? creditsAvailable;
  final bool isMock;

  AIReportResponse({
    required this.success,
    this.reportId,
    this.reportType,
    this.content,
    this.error,
    this.usage,
    this.creditsUsed,
    this.creditsRemaining,
    this.creditsRequired,
    this.creditsAvailable,
    this.isMock = false,
  });

  factory AIReportResponse.fromJson(Map<String, dynamic> json) {
    return AIReportResponse(
      success: json['success'] ?? false,
      reportId: json['report_id'],
      reportType: json['report_type'],
      content: json['content'],
      error: json['error'],
      usage: json['usage'],
      creditsUsed: json['credits_used'],
      creditsRemaining: json['credits_remaining'],
      isMock: json['is_mock'] ?? false,
    );
  }
}

/// Credits info model
class CreditsInfo {
  final int credits;
  final Map<String, dynamic> pricing;

  CreditsInfo({required this.credits, required this.pricing});

  factory CreditsInfo.fromJson(Map<String, dynamic> json) {
    return CreditsInfo(
      credits: json['credits'] ?? 0,
      pricing: json['pricing'] ?? {},
    );
  }
}

/// Credit package model
class CreditPackage {
  final String id;
  final int credits;
  final double priceInr;
  final double priceUsd;
  final String? savings;
  final bool isPopular;

  CreditPackage({
    required this.id,
    required this.credits,
    required this.priceInr,
    required this.priceUsd,
    this.savings,
    this.isPopular = false,
  });

  factory CreditPackage.fromJson(Map<String, dynamic> json) {
    return CreditPackage(
      id: json['id'],
      credits: json['credits'],
      priceInr: (json['price_inr'] as num).toDouble(),
      priceUsd: (json['price_usd'] as num).toDouble(),
      savings: json['savings'],
      isPopular: json['popular'] ?? false,
    );
  }
}

/// Chat message model
class ChatMessage {
  final String role;
  final String content;
  final DateTime? timestamp;

  ChatMessage({
    required this.role,
    required this.content,
    this.timestamp,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      role: json['role'],
      content: json['content'],
      timestamp: json['timestamp'] != null ? DateTime.parse(json['timestamp']) : null,
    );
  }

  bool get isUser => role == 'user';
  bool get isAssistant => role == 'assistant';
}

/// Saved report model
class SavedReport {
  final String id;
  final String reportType;
  final String content;
  final String? preview;
  final DateTime createdAt;
  final Map<String, dynamic>? usage;

  SavedReport({
    required this.id,
    required this.reportType,
    required this.content,
    this.preview,
    required this.createdAt,
    this.usage,
  });

  factory SavedReport.fromJson(Map<String, dynamic> json) {
    return SavedReport(
      id: json['id'],
      reportType: json['report_type'],
      content: json['content'] ?? json['preview'] ?? '',
      preview: json['preview'],
      createdAt: DateTime.parse(json['created_at']),
      usage: json['usage'],
    );
  }
}

