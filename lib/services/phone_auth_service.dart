import 'dart:async';
import 'clerk_phone_auth_service.dart';
import '../core/models/user_model.dart';

class PhoneAuthService {
  // Send OTP to phone number (using Clerk)
  static Future<void> sendOTP(String phone) async {
    // Validate phone number format
    if (!ClerkPhoneAuthService.isValidPhoneNumber(phone)) {
      throw Exception('Invalid phone number format');
    }

    await ClerkPhoneAuthService.sendOTP(phone);
  }

  // Verify OTP and sign in/up (using Clerk)
  static Future<UserModel> verifyOTP({
    required String phone,
    required String otp,
  }) async {
    if (otp.length != 6) {
      throw Exception('OTP must be 6 digits');
    }

    return await ClerkPhoneAuthService.verifyOTP(phone: phone, otp: otp);
  }

  // Format phone number (add country code if missing)
  static String formatPhoneNumber(String phone) {
    return ClerkPhoneAuthService.formatPhoneNumber(phone);
  }

  // Resend OTP with cooldown
  static Future<void> resendOTP(String phone, {Duration? cooldown}) async {
    if (cooldown != null) {
      await Future.delayed(cooldown);
    }
    await sendOTP(phone);
  }
}

