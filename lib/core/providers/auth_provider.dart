import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../../services/auth_service.dart';
import '../../services/google_auth_service.dart';
import '../../services/phone_auth_service.dart';

// Auth state
class AuthState {
  final UserModel? user;
  final bool isLoading;
  final String? error;

  AuthState({
    this.user,
    this.isLoading = false,
    this.error,
  });

  bool get isAuthenticated => user != null;
  String get userRole => user?.role ?? 'client';
  bool get isAdmin => userRole == 'admin';
  bool get isConsultant => userRole == 'consultant';
  bool get isClient => userRole == 'client';

  AuthState copyWith({
    UserModel? user,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// Auth provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(AuthState()) {
    _loadUser();
  }

  Future<void> _loadUser() async {
    try {
      final user = await AuthService.getCurrentUser();
      if (user != null) {
        state = state.copyWith(user: user);
      }
    } catch (e) {
      // Ignore errors on initial load
    }
  }

  // Email/Password Sign In
  Future<void> signIn(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final user = await AuthService.signInWithEmail(
        email: email,
        password: password,
      );
      state = state.copyWith(user: user, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  // Email/Password Sign Up
  Future<void> signUp({
    required String email,
    required String password,
    String? name,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final user = await AuthService.signUpWithEmail(
        email: email,
        password: password,
        name: name,
      );
      state = state.copyWith(user: user, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  // Phone OTP Sign In/Up
  Future<void> sendPhoneOTP(String phone) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      await PhoneAuthService.sendOTP(phone);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  Future<void> verifyPhoneOTP(String phone, String otp) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final user = await PhoneAuthService.verifyOTP(phone: phone, otp: otp);
      state = state.copyWith(user: user, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  // Google Sign In
  Future<void> signInWithGoogle() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final user = await GoogleAuthService.signIn();
      state = state.copyWith(user: user, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  // Forgot Password
  Future<void> forgotPassword(String emailOrPhone) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      await AuthService.forgotPassword(emailOrPhone);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  // Reset Password
  Future<void> resetPassword({
    required String emailOrPhone,
    required String code,
    required String newPassword,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      await AuthService.resetPassword(
        emailOrPhone: emailOrPhone,
        code: code,
        newPassword: newPassword,
      );
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  // Sign Out
  Future<void> signOut() async {
    state = state.copyWith(isLoading: true);
    
    try {
      await GoogleAuthService.signOut();
      await AuthService.signOut();
      state = AuthState();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Current user provider
final currentUserProvider = Provider<UserModel?>((ref) {
  return ref.watch(authProvider).user;
});

// Theme mode provider
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.light);

