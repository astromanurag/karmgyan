import 'dart:async';
import 'auth_service.dart';
import '../core/models/user_model.dart';

class PhoneAuthService {
  // Send OTP to phone number
  static Future<void> sendOTP(String phone) async {
    // Validate phone number format
    if (!_isValidPhoneNumber(phone)) {
      throw Exception('Invalid phone number format');
    }

    await AuthService.sendPhoneOTP(phone);
  }

  // Verify OTP and sign in/up
  static Future<UserModel> verifyOTP({
    required String phone,
    required String otp,
  }) async {
    if (otp.length != 6) {
      throw Exception('OTP must be 6 digits');
    }

    return await AuthService.verifyPhoneOTP(phone: phone, otp: otp);
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
  static bool _isValidPhoneNumber(String phone) {
    final cleaned = formatPhoneNumber(phone);
    // Basic validation: should start with + and have 10-15 digits
    return RegExp(r'^\+\d{10,15}$').hasMatch(cleaned);
  }

  // Resend OTP with cooldown
  static Future<void> resendOTP(String phone, {Duration? cooldown}) async {
    if (cooldown != null) {
      await Future.delayed(cooldown);
    }
    await sendOTP(phone);
  }
}

