import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvConfig {
  static bool _initialized = false;
  static bool _dotenvLoaded = false; // Track if .env was successfully loaded
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
  static late String _apiKey; // API key for karmgyan-api.onrender.com
  
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
        // Default to external API even for compile-time vars
        return const String.fromEnvironment('BACKEND_URL', defaultValue: 'https://karmgyan-api.onrender.com');
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
      case 'API_KEY':
        return const String.fromEnvironment('API_KEY', defaultValue: '');
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
      _dotenvLoaded = true;
      debugPrint('✅ Loaded .env file');
    } catch (e) {
      _dotenvLoaded = false;
      debugPrint('⚠️  .env file not found (using defaults or compile-time env vars)');
    }

    // Load from .env file first, then fallback to compile-time env vars, then defaults
    // For production: Use --dart-define flags (converted from Render env vars by build script)
    // For local dev: Use .env file
    String getEnv(String key, {String defaultValue = ''}) {
      // Special handling for BACKEND_URL - always default to external API unless explicitly set to external URL
      if (key == 'BACKEND_URL' && defaultValue.isEmpty) {
        defaultValue = 'https://karmgyan-api.onrender.com';
      }
      
      // First try .env file (local development) - only if it was loaded
      if (_dotenvLoaded) {
        try {
          final envValue = dotenv.get(key, fallback: '');
          if (envValue.isNotEmpty) {
            // For BACKEND_URL, ignore localhost values (force external API)
            if (key == 'BACKEND_URL' && (envValue.contains('localhost') || envValue.contains('127.0.0.1'))) {
              debugPrint('⚠️  Ignoring localhost BACKEND_URL from .env, using external API instead');
              // Continue to use default (external API)
            } else {
              return envValue;
            }
          }
        } catch (e) {
          // dotenv not initialized, continue to fallback
        }
      }
      // Then try compile-time environment variable (production)
      // Note: This requires the variable to be passed via --dart-define during build
      // The build script converts Render env vars to --dart-define flags
      try {
        // Use const constructor with known keys - this works at compile time
        final compileTimeValue = _getCompileTimeEnv(key);
        if (compileTimeValue.isNotEmpty) {
          // For BACKEND_URL, ignore localhost values (force external API)
          if (key == 'BACKEND_URL' && (compileTimeValue.contains('localhost') || compileTimeValue.contains('127.0.0.1'))) {
            debugPrint('⚠️  Ignoring localhost BACKEND_URL from compile-time vars, using external API instead');
            // Continue to use default (external API)
          } else {
            return compileTimeValue;
          }
        }
      } catch (e) {
        // Ignore - compile-time vars may not be available
      }
      // Fallback to default (which is now always external API for BACKEND_URL)
      return defaultValue;
    }
    
    bool getBoolEnv(String key, {bool defaultValue = false}) {
      // First try .env file - only if it was loaded
      if (_dotenvLoaded) {
        try {
          final envValue = dotenv.get(key, fallback: '');
          if (envValue.isNotEmpty) {
            return envValue.toLowerCase() == 'true' || envValue == '1';
          }
        } catch (e) {
          // dotenv not initialized, continue to fallback
        }
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
    // Always use external API (karmgyan-api.onrender.com) - localhost is ignored
    // This ensures local testing also uses the deployed API
    _backendUrl = getEnv('BACKEND_URL', defaultValue: 'https://karmgyan-api.onrender.com');
    
    // Force external API if somehow localhost got through
    if (_backendUrl.contains('localhost') || _backendUrl.contains('127.0.0.1')) {
      debugPrint('⚠️  BACKEND_URL was set to localhost, forcing external API instead');
      _backendUrl = 'https://karmgyan-api.onrender.com';
    }
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
    // API key for karmgyan-api.onrender.com
    // Default to demo professional key for testing (10,000 requests/day)
    // Override with API_KEY env var for production
    _apiKey = getEnv('API_KEY', defaultValue: 'demo_pro_key_123456789');

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
    if (_apiKey.isNotEmpty) {
      final keyType = _apiKey.startsWith('demo') ? 'DEMO' : _apiKey.startsWith('sk_') ? 'PRODUCTION' : 'CUSTOM';
      debugPrint('  - apiKey: ${_apiKey.substring(0, _apiKey.length > 20 ? 20 : _apiKey.length)}... ($keyType)');
    } else {
      debugPrint('  - apiKey: NOT SET');
    }
    
    // Warn about missing production keys
    _validateProductionKeys();
  }
  
  /// Validate production keys and warn about missing ones
  static void _validateProductionKeys() {
    if (kDebugMode) {
      // Only warn in debug mode to avoid spam in production
      final missingKeys = <String>[];
      
      if (!hasSupabaseConfig) {
        missingKeys.add('Supabase (URL, Publishable Key, Secret Key)');
      }
      if (!hasCashfreeConfig) {
        missingKeys.add('Cashfree (App ID, Secret Key)');
      }
      if (!hasGoogleOAuthConfig) {
        missingKeys.add('Google OAuth (Client IDs)');
      }
      if (!hasClerkConfig) {
        missingKeys.add('Clerk (Publishable Key, Secret Key)');
      }
      if (!hasPerplexityConfig) {
        missingKeys.add('Perplexity (API Key)');
      }
      if (!hasAgoraConfig) {
        missingKeys.add('Agora (App ID, Certificate)');
      }
      
      if (missingKeys.isNotEmpty && !_useMockData) {
        debugPrint('⚠️  WARNING: Missing production API keys:');
        for (final key in missingKeys) {
          debugPrint('   - $key');
        }
        debugPrint('   The app may not function correctly without these keys.');
        debugPrint('   See KEYS_SETUP_GUIDE.md for setup instructions.');
      }
      
      // Warn if using mock mode with production keys
      if (_useMockData && hasSupabaseConfig) {
        debugPrint('⚠️  WARNING: Mock data mode is enabled but production keys are configured.');
        debugPrint('   Consider setting USE_MOCK_DATA=false for production.');
      }
    }
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
  static String get apiKey => _apiKey;

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
  static bool get hasApiKey => _apiKey.isNotEmpty;

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

