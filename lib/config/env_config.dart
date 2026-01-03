import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';

class EnvConfig {
  static bool _initialized = false;
  static late bool _useMockData;
  static late bool _useMockAuth; // Separate flag for authentication
  static late String _backendUrl;
  static late String _supabaseUrl;
  static late String _supabaseAnonKey;
  static late String _razorpayKeyId;
  static late String _agoraAppId;
  static late String _agoraAppCertificate;
  
  // Runtime override flags (allows changing without recompile)
  static bool? _runtimeMockOverride;
  static bool? _runtimeMockAuthOverride;

  // Initialize from environment or defaults
  static Future<void> initialize() async {
    if (_initialized) return;

    // In production, these would come from environment variables
    // DEFAULT: false = use real backend for astrology calculations
    // DEFAULT: true = use mock auth (no backend auth needed for testing)
    // Set _runtimeMockOverride to override at runtime
    _useMockData = const bool.fromEnvironment('USE_MOCK_DATA', defaultValue: false);
    _useMockAuth = const bool.fromEnvironment('USE_MOCK_AUTH', defaultValue: true);
    _backendUrl = const String.fromEnvironment('BACKEND_URL', defaultValue: 'http://localhost:3000');
    _supabaseUrl = const String.fromEnvironment('SUPABASE_URL', defaultValue: '');
    _supabaseAnonKey = const String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: '');
    _razorpayKeyId = const String.fromEnvironment('RAZORPAY_KEY_ID', defaultValue: '');
    _agoraAppId = const String.fromEnvironment('AGORA_APP_ID', defaultValue: '');
    _agoraAppCertificate = const String.fromEnvironment('AGORA_APP_CERTIFICATE', defaultValue: '');

    // Try to load from package info or other sources
    try {
      await PackageInfo.fromPlatform();
      // Could load from packageInfo.buildNumber or other metadata if needed
    } catch (e) {
      debugPrint('Could not load package info: $e');
    }

    _initialized = true;
    
    debugPrint('✅ EnvConfig initialized:');
    debugPrint('  - useMockData: $_useMockData');
    debugPrint('  - useMockAuth: $_useMockAuth');
    debugPrint('  - backendUrl: $_backendUrl');
  }

  // Getters - runtime override takes precedence
  static bool get useMockData => _runtimeMockOverride ?? _useMockData;
  static bool get useMockAuth => _runtimeMockAuthOverride ?? _useMockAuth;
  static String get backendUrl => _backendUrl;
  static String get supabaseUrl => _supabaseUrl;
  static String get supabaseAnonKey => _supabaseAnonKey;
  static String get razorpayKeyId => _razorpayKeyId;
  static String get agoraAppId => _agoraAppId;
  static String get agoraAppCertificate => _agoraAppCertificate;

  // Check if production APIs are configured
  static bool get hasSupabaseConfig => _supabaseUrl.isNotEmpty && _supabaseAnonKey.isNotEmpty;
  static bool get hasRazorpayConfig => _razorpayKeyId.isNotEmpty;
  static bool get hasAgoraConfig => _agoraAppId.isNotEmpty && _agoraAppCertificate.isNotEmpty;

  // Force override at runtime (useful for testing/debugging)
  // This takes effect immediately without recompile
  static void overrideMockData(bool value) {
    _runtimeMockOverride = value;
    debugPrint('🔧 overrideMockData: $value (useMockData now: ${useMockData})');
  }
  
  static void overrideMockAuth(bool value) {
    _runtimeMockAuthOverride = value;
    debugPrint('🔧 overrideMockAuth: $value (useMockAuth now: ${useMockAuth})');
  }
  
  // Clear runtime override to use compile-time value
  static void clearMockOverride() {
    _runtimeMockOverride = null;
  }
  
  static void clearMockAuthOverride() {
    _runtimeMockAuthOverride = null;
  }

  static void overrideBackendUrl(String value) {
    _backendUrl = value;
  }
}

