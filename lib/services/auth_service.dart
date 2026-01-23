import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../config/env_config.dart';
import '../core/models/user_model.dart';
import '../core/services/local_storage_service.dart';

class AuthService {
  static String get _baseUrl => AppConfig.backendUrl;
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';

  // Email/Password Sign Up
  static Future<UserModel> signUpWithEmail({
    required String email,
    required String password,
    String? name,
  }) async {
    if (EnvConfig.useMockAuth) {
      await Future.delayed(const Duration(seconds: 1));
      final user = UserModel(
        id: 'user_${DateTime.now().millisecondsSinceEpoch}',
        email: email,
        name: name,
        role: 'client',
        authProvider: 'email',
        emailVerified: false,
        createdAt: DateTime.now(),
      );
      await _saveUser(user);
      return user;
    }

    final response = await http.post(
      Uri.parse('$_baseUrl/api/auth/signup'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
        'name': name,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      final user = UserModel.fromJson(data['user']);
      await _saveToken(data['token']);
      await _saveUser(user);
      return user;
    } else {
      throw Exception('Sign up failed: ${response.body}');
    }
  }

  // Email/Password Sign In
  static Future<UserModel> signInWithEmail({
    required String email,
    required String password,
  }) async {
    print('🔐 signInWithEmail called');
    print('🔐 Email: $email');
    print('🔐 EnvConfig.useMockAuth: ${EnvConfig.useMockAuth}');
    
    if (EnvConfig.useMockAuth) {
      print('✅ Using MOCK AUTH - Login will succeed');
      await Future.delayed(const Duration(seconds: 1));
      final user = UserModel(
        id: 'user_${DateTime.now().millisecondsSinceEpoch}',
        email: email,
        name: email.split('@')[0],
        role: 'client',
        authProvider: 'email',
        emailVerified: true,
        createdAt: DateTime.now(),
      );
      await _saveUser(user);
      print('✅ Mock user created and saved: ${user.email}');
      return user;
    }

    final response = await http.post(
      Uri.parse('$_baseUrl/api/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final user = UserModel.fromJson(data['user']);
      await _saveToken(data['token']);
      await _saveUser(user);
      return user;
    } else {
      throw Exception('Sign in failed: ${response.body}');
    }
  }

  // Phone OTP - Send OTP
  static Future<void> sendPhoneOTP(String phone) async {
    if (EnvConfig.useMockAuth) {
      await Future.delayed(const Duration(milliseconds: 500));
      return;
    }

    final response = await http.post(
      Uri.parse('$_baseUrl/api/auth/phone/send-otp'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'phone': phone}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to send OTP: ${response.body}');
    }
  }

  // Phone OTP - Verify and Sign In/Up
  static Future<UserModel> verifyPhoneOTP({
    required String phone,
    required String otp,
  }) async {
    if (EnvConfig.useMockAuth) {
      // Mock: Accept OTP "123456" for any phone
      if (otp != '123456') {
        throw Exception('Invalid OTP');
      }
      await Future.delayed(const Duration(seconds: 1));
      final user = UserModel(
        id: 'user_${DateTime.now().millisecondsSinceEpoch}',
        phone: phone,
        role: 'client',
        authProvider: 'phone',
        phoneVerified: true,
        createdAt: DateTime.now(),
      );
      await _saveUser(user);
      return user;
    }

    final response = await http.post(
      Uri.parse('$_baseUrl/api/auth/phone/verify-otp'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'phone': phone,
        'otp': otp,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final user = UserModel.fromJson(data['user']);
      await _saveToken(data['token']);
      await _saveUser(user);
      return user;
    } else {
      throw Exception('OTP verification failed: ${response.body}');
    }
  }

  // Google Sign In
  static Future<UserModel> signInWithGoogle(String googleToken) async {
    if (EnvConfig.useMockAuth) {
      await Future.delayed(const Duration(seconds: 1));
      final user = UserModel(
        id: 'user_${DateTime.now().millisecondsSinceEpoch}',
        email: 'google_user@example.com',
        name: 'Google User',
        role: 'client',
        authProvider: 'google',
        googleId: 'google_${DateTime.now().millisecondsSinceEpoch}',
        emailVerified: true,
        createdAt: DateTime.now(),
      );
      await _saveUser(user);
      return user;
    }

    final response = await http.post(
      Uri.parse('$_baseUrl/api/auth/google'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'token': googleToken}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final user = UserModel.fromJson(data['user']);
      await _saveToken(data['token']);
      await _saveUser(user);
      return user;
    } else {
      throw Exception('Google sign in failed: ${response.body}');
    }
  }

  // Forgot Password - Send Reset Email/OTP
  static Future<void> forgotPassword(String emailOrPhone) async {
    if (EnvConfig.useMockAuth) {
      await Future.delayed(const Duration(milliseconds: 500));
      return;
    }

    final response = await http.post(
      Uri.parse('$_baseUrl/api/auth/forgot-password'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email_or_phone': emailOrPhone}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to send reset code: ${response.body}');
    }
  }

  // Reset Password
  static Future<void> resetPassword({
    required String emailOrPhone,
    required String code,
    required String newPassword,
  }) async {
    if (EnvConfig.useMockAuth) {
      // Mock: Accept code "123456"
      if (code != '123456') {
        throw Exception('Invalid reset code');
      }
      await Future.delayed(const Duration(seconds: 1));
      return;
    }

    final response = await http.post(
      Uri.parse('$_baseUrl/api/auth/reset-password'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email_or_phone': emailOrPhone,
        'code': code,
        'new_password': newPassword,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Password reset failed: ${response.body}');
    }
  }

  // Get Current User
  static Future<UserModel?> getCurrentUser() async {
    final userJson = LocalStorageService.getString(_userKey);
    if (userJson == null) return null;
    return UserModel.fromJson(jsonDecode(userJson));
  }

  // Sign Out
  static Future<void> signOut() async {
    await LocalStorageService.remove(_tokenKey);
    await LocalStorageService.remove(_userKey);
  }

  // Clerk Sign In
  static Future<UserModel> signInWithClerk({
    required String clerkId,
    String? phone,
    String? email,
    String? name,
  }) async {
    if (EnvConfig.useMockAuth) {
      await Future.delayed(const Duration(seconds: 1));
      final user = UserModel(
        id: 'user_${DateTime.now().millisecondsSinceEpoch}',
        email: email,
        phone: phone,
        name: name ?? 'User',
        role: 'client',
        authProvider: 'clerk',
        emailVerified: email != null,
        phoneVerified: phone != null,
        createdAt: DateTime.now(),
      );
      await _saveUser(user);
      return user;
    }

    final response = await http.post(
      Uri.parse('$_baseUrl/api/auth/clerk/verify'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'clerk_id': clerkId,
        'phone': phone,
        'email': email,
        'name': name,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final user = UserModel.fromJson(data['user']);
      await _saveToken(data['token']);
      await _saveUser(user);
      return user;
    } else {
      throw Exception('Clerk sign in failed: ${response.body}');
    }
  }

  // Helper methods
  static Future<void> _saveToken(String token) async {
    await LocalStorageService.saveString(_tokenKey, token);
  }

  static Future<void> _saveUser(UserModel user) async {
    await LocalStorageService.saveString(_userKey, jsonEncode(user.toJson()));
  }
  
  // Public methods for saving (used by Clerk service)
  static Future<void> saveToken(String token) async {
    await _saveToken(token);
  }
  
  static Future<void> saveUser(UserModel user) async {
    await _saveUser(user);
  }

  static String? getToken() {
    return LocalStorageService.getString(_tokenKey);
  }
}

