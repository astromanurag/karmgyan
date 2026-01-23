import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvConfig {
  static bool _initialized = false;
  static late bool _useMockData;
  static late bool _useMockAuth; // Separate flag for authentication
  static late String _backendUrl;
  static late String _supabaseUrl;
  static late String _supabaseAnonKey; // Legacy: anon key or new publishable key
  static late String _supabasePublishableKey; // New key system
  static late String _supabaseSecretKey; // New key system (backend only)
  static late String _razorpayKeyId;
  static late String _agoraAppId;
  static late String _agoraAppCertificate;
  static late String _googlePlacesApiKey;
  static late String _googleOAuthClientIdWeb;
  static late String _googleOAuthClientIdAndroid;
  static late String _googleOAuthClientIdIos;
  static late String _cashfreeAppId;
  static late String _cashfreeSecretKey;
  static late String _cashfreeMode;
  static late String _clerkPublishableKey;
  static late String _clerkSecretKey;
  static late String _perplexityApiKey;
  
  // Runtime override flags (allows changing without recompile)
  static bool? _runtimeMockOverride;
  static bool? _runtimeMockAuthOverride;

  // Helper to get compile-time environment variables
  // These are set via --dart-define flags during build
  static String _getCompileTimeEnv(String key) {
    // We can't use String.fromEnvironment with dynamic keys at runtime
    // So we check each known key explicitly
    switch (key) {
      case 'USE_MOCK_DATA':
        return const String.fromEnvironment('USE_MOCK_DATA', defaultValue: '');
      case 'USE_MOCK_AUTH':
        return const String.fromEnvironment('USE_MOCK_AUTH', defaultValue: '');
      case 'BACKEND_URL':
        return const String.fromEnvironment('BACKEND_URL', defaultValue: '');
      case 'SUPABASE_URL':
        return const String.fromEnvironment('SUPABASE_URL', defaultValue: '');
      case 'SUPABASE_PUBLISHABLE_KEY':
        return const String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY', defaultValue: '');
      case 'SUPABASE_ANON_KEY':
        return const String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: '');
      case 'SUPABASE_SECRET_KEY':
        return const String.fromEnvironment('SUPABASE_SECRET_KEY', defaultValue: '');
      case 'RAZORPAY_KEY_ID':
        return const String.fromEnvironment('RAZORPAY_KEY_ID', defaultValue: '');
      case 'AGORA_APP_ID':
        return const String.fromEnvironment('AGORA_APP_ID', defaultValue: '');
      case 'AGORA_APP_CERTIFICATE':
        return const String.fromEnvironment('AGORA_APP_CERTIFICATE', defaultValue: '');
      case 'GOOGLE_PLACES_API_KEY':
        return const String.fromEnvironment('GOOGLE_PLACES_API_KEY', defaultValue: '');
      case 'GOOGLE_OAUTH_CLIENT_ID_WEB':
        return const String.fromEnvironment('GOOGLE_OAUTH_CLIENT_ID_WEB', defaultValue: '');
      case 'GOOGLE_OAUTH_CLIENT_ID_ANDROID':
        return const String.fromEnvironment('GOOGLE_OAUTH_CLIENT_ID_ANDROID', defaultValue: '');
      case 'GOOGLE_OAUTH_CLIENT_ID_IOS':
        return const String.fromEnvironment('GOOGLE_OAUTH_CLIENT_ID_IOS', defaultValue: '');
      case 'CASHFREE_APP_ID':
        return const String.fromEnvironment('CASHFREE_APP_ID', defaultValue: '');
      case 'CASHFREE_SECRET_KEY':
        return const String.fromEnvironment('CASHFREE_SECRET_KEY', defaultValue: '');
      case 'CASHFREE_MODE':
        return const String.fromEnvironment('CASHFREE_MODE', defaultValue: '');
      case 'CLERK_PUBLISHABLE_KEY':
        return const String.fromEnvironment('CLERK_PUBLISHABLE_KEY', defaultValue: '');
      case 'CLERK_SECRET_KEY':
        return const String.fromEnvironment('CLERK_SECRET_KEY', defaultValue: '');
      case 'PERPLEXITY_API_KEY':
        return const String.fromEnvironment('PERPLEXITY_API_KEY', defaultValue: '');
      default:
        return '';
    }
  }

  // Initialize from environment or defaults
  static Future<void> initialize() async {
    if (_initialized) return;

    // Try to load .env file (for local development)
    try {
      await dotenv.load(fileName: '.env');
      debugPrint('✅ Loaded .env file');
    } catch (e) {
      debugPrint('⚠️  .env file not found (using defaults or compile-time env vars): $e');
    }

    // Load from .env file first, then fallback to compile-time env vars, then defaults
    // For production: Use --dart-define flags (converted from Render env vars by build script)
    // For local dev: Use .env file
    String getEnv(String key, {String defaultValue = ''}) {
      // First try .env file (local development)
      final envValue = dotenv.get(key, fallback: '');
      if (envValue.isNotEmpty) {
        return envValue;
      }
      // Then try compile-time environment variable (production)
      // Note: This requires the variable to be passed via --dart-define during build
      // The build script converts Render env vars to --dart-define flags
      try {
        // Use const constructor with known keys - this works at compile time
        final compileTimeValue = _getCompileTimeEnv(key);
        if (compileTimeValue.isNotEmpty) {
          return compileTimeValue;
        }
      } catch (e) {
        // Ignore - compile-time vars may not be available
      }
      // Fallback to default
      return defaultValue;
    }
    
    bool getBoolEnv(String key, {bool defaultValue = false}) {
      // First try .env file
      final envValue = dotenv.get(key, fallback: '');
      if (envValue.isNotEmpty) {
        return envValue.toLowerCase() == 'true' || envValue == '1';
      }
      // Then try compile-time variable
      try {
        final compileTimeValue = _getCompileTimeEnv(key);
        if (compileTimeValue.isNotEmpty) {
          return compileTimeValue.toLowerCase() == 'true' || compileTimeValue == '1';
        }
      } catch (e) {
        // Ignore
      }
      // Fallback to default
      return defaultValue;
    }

    // In production, these would come from environment variables
    // DEFAULT: false = use real backend for astrology calculations
    // DEFAULT: true = use mock auth (no backend auth needed for testing)
    // Set _runtimeMockOverride to override at runtime
    _useMockData = getBoolEnv('USE_MOCK_DATA', defaultValue: false);
    _useMockAuth = getBoolEnv('USE_MOCK_AUTH', defaultValue: true);
    _backendUrl = getEnv('BACKEND_URL', defaultValue: 'http://localhost:3000');
    _supabaseUrl = getEnv('SUPABASE_URL');
    // Support both new and legacy key systems
    _supabasePublishableKey = getEnv('SUPABASE_PUBLISHABLE_KEY');
    _supabaseAnonKey = getEnv('SUPABASE_ANON_KEY');
    _supabaseSecretKey = getEnv('SUPABASE_SECRET_KEY');
    _razorpayKeyId = getEnv('RAZORPAY_KEY_ID');
    _agoraAppId = getEnv('AGORA_APP_ID');
    _agoraAppCertificate = getEnv('AGORA_APP_CERTIFICATE');
    _googlePlacesApiKey = getEnv('GOOGLE_PLACES_API_KEY');
    _googleOAuthClientIdWeb = getEnv('GOOGLE_OAUTH_CLIENT_ID_WEB');
    _googleOAuthClientIdAndroid = getEnv('GOOGLE_OAUTH_CLIENT_ID_ANDROID');
    _googleOAuthClientIdIos = getEnv('GOOGLE_OAUTH_CLIENT_ID_IOS');
    _cashfreeAppId = getEnv('CASHFREE_APP_ID');
    _cashfreeSecretKey = getEnv('CASHFREE_SECRET_KEY');
    _cashfreeMode = getEnv('CASHFREE_MODE', defaultValue: 'sandbox');
    _clerkPublishableKey = getEnv('CLERK_PUBLISHABLE_KEY');
    _clerkSecretKey = getEnv('CLERK_SECRET_KEY');
    _perplexityApiKey = getEnv('PERPLEXITY_API_KEY');

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
  // Use publishable key if available, fallback to anon key (legacy)
  static String get supabaseAnonKey => _supabasePublishableKey.isNotEmpty 
      ? _supabasePublishableKey 
      : _supabaseAnonKey;
  static String get supabasePublishableKey => _supabasePublishableKey;
  static String get supabaseSecretKey => _supabaseSecretKey;
  static String get razorpayKeyId => _razorpayKeyId;
  static String get agoraAppId => _agoraAppId;
  static String get agoraAppCertificate => _agoraAppCertificate;
  static String get googlePlacesApiKey => _googlePlacesApiKey;
  static String get googleOAuthClientIdWeb => _googleOAuthClientIdWeb;
  static String get googleOAuthClientIdAndroid => _googleOAuthClientIdAndroid;
  static String get googleOAuthClientIdIos => _googleOAuthClientIdIos;
  static String get cashfreeAppId => _cashfreeAppId;
  static String get cashfreeSecretKey => _cashfreeSecretKey;
  static String get cashfreeMode => _cashfreeMode;
  static String get clerkPublishableKey => _clerkPublishableKey;
  static String get clerkSecretKey => _clerkSecretKey;
  static String get perplexityApiKey => _perplexityApiKey;

  // Check if production APIs are configured
  // Support both new (publishable) and legacy (anon) key systems
  static bool get hasSupabaseConfig => _supabaseUrl.isNotEmpty && 
      (_supabasePublishableKey.isNotEmpty || _supabaseAnonKey.isNotEmpty);
  static bool get hasRazorpayConfig => _razorpayKeyId.isNotEmpty;
  static bool get hasAgoraConfig => _agoraAppId.isNotEmpty && _agoraAppCertificate.isNotEmpty;
  static bool get hasGooglePlacesConfig => _googlePlacesApiKey.isNotEmpty;
  static bool get hasGoogleOAuthConfig => _googleOAuthClientIdWeb.isNotEmpty;
  static bool get hasCashfreeConfig => _cashfreeAppId.isNotEmpty && _cashfreeSecretKey.isNotEmpty;
  static bool get hasClerkConfig => _clerkPublishableKey.isNotEmpty && _clerkSecretKey.isNotEmpty;
  static bool get hasPerplexityConfig => _perplexityApiKey.isNotEmpty;

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

