import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../config/env_config.dart';
import '../config/env_config.dart' as env;
import 'auth_service.dart';
import '../core/models/user_model.dart';

class ClerkPhoneAuthService {
  static String? _sessionId;
  
  // Send OTP to phone number using Clerk API
  static Future<void> sendOTP(String phone) async {
    if (EnvConfig.useMockAuth) {
      // Mock OTP
      await Future.delayed(const Duration(milliseconds: 500));
      return;
    }

    if (!AppConfig.hasClerkConfig) {
      throw Exception('Clerk not configured');
    }

    try {
      final formattedPhone = formatPhoneNumber(phone);
      
      // Call backend to send OTP via Clerk
      final response = await http.post(
        Uri.parse('${env.EnvConfig.backendUrl}/api/auth/clerk/send-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phone': formattedPhone}),
      );

      if (response.statusCode != 200) {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Failed to send OTP');
      }

      final data = jsonDecode(response.body);
      _sessionId = data['session_id'] as String?;
    } catch (e) {
      throw Exception('Failed to send OTP: ${e.toString()}');
    }
  }

  // Verify OTP and sign in/up using Clerk
  static Future<UserModel> verifyOTP({
    required String phone,
    required String otp,
  }) async {
    if (EnvConfig.useMockAuth) {
      // Mock verification
      if (otp != '123456') {
        throw Exception('Invalid OTP');
      }
      await Future.delayed(const Duration(seconds: 1));
      final user = UserModel(
        id: 'user_${DateTime.now().millisecondsSinceEpoch}',
        phone: phone,
        role: 'client',
        authProvider: 'clerk',
        phoneVerified: true,
        createdAt: DateTime.now(),
      );
      await AuthService.saveUser(user);
      return user;
    }

    if (!AppConfig.hasClerkConfig) {
      throw Exception('Clerk not configured');
    }

    try {
      final formattedPhone = formatPhoneNumber(phone);
      
      // Call backend to verify OTP via Clerk
      final response = await http.post(
        Uri.parse('${env.EnvConfig.backendUrl}/api/auth/clerk/verify-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'phone': formattedPhone,
          'code': otp,
          'session_id': _sessionId,
        }),
      );

      if (response.statusCode != 200) {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'OTP verification failed');
      }

      final data = jsonDecode(response.body);
      final user = UserModel.fromJson(data['user']);
      await AuthService.saveToken(data['token']);
      await AuthService.saveUser(user);
      _sessionId = null; // Clear session after successful verification
      return user;
    } catch (e) {
      throw Exception('OTP verification failed: ${e.toString()}');
    }
  }

  // Format phone number (add country code if missing)
  static String formatPhoneNumber(String phone) {
    String cleaned = phone.replaceAll(RegExp(r'[^\d+]'), '');
    
    // If doesn't start with +, assume Indian number and add +91
    if (!cleaned.startsWith('+')) {
      if (cleaned.length == 10) {
        cleaned = '+91$cleaned';
      } else if (cleaned.startsWith('91') && cleaned.length == 12) {
        cleaned = '+$cleaned';
      }
    }
    
    return cleaned;
  }

  // Validate phone number
  static bool isValidPhoneNumber(String phone) {
    final cleaned = formatPhoneNumber(phone);
    // Basic validation: should start with + and have 10-15 digits
    return RegExp(r'^\+\d{10,15}$').hasMatch(cleaned);
  }

  // Resend OTP
  static Future<void> resendOTP(String phone, {Duration? cooldown}) async {
    if (cooldown != null) {
      await Future.delayed(cooldown);
    }
    await sendOTP(phone);
  }

  // Sign out
  static Future<void> signOut() async {
    _sessionId = null;
    await AuthService.signOut();
  }
}

