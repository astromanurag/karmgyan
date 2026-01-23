import 'env_config.dart';

class AppConfig {
  // Use environment-based configuration
  static bool get useMockData => EnvConfig.useMockData;
  
  // Backend API URL
  static String get backendUrl => EnvConfig.backendUrl;
  
  // Mock data path
  static const String mockDataPath = 'assets/mock_data';
  
  // Supabase configuration
  static String get supabaseUrl => EnvConfig.supabaseUrl;
  static String get supabaseAnonKey => EnvConfig.supabaseAnonKey;
  static bool get hasSupabaseConfig => EnvConfig.hasSupabaseConfig;
  
  // Razorpay configuration
  static String get razorpayKeyId => EnvConfig.razorpayKeyId;
  static bool get hasRazorpayConfig => EnvConfig.hasRazorpayConfig;
  
  // Agora configuration
  static String get agoraAppId => EnvConfig.agoraAppId;
  static String get agoraAppCertificate => EnvConfig.agoraAppCertificate;
  static bool get hasAgoraConfig => EnvConfig.hasAgoraConfig;
  
  // Google Places configuration
  static String get googlePlacesApiKey => EnvConfig.googlePlacesApiKey;
  static bool get hasGooglePlacesConfig => EnvConfig.hasGooglePlacesConfig;
  
  // Google OAuth configuration
  static String get googleOAuthClientIdWeb => EnvConfig.googleOAuthClientIdWeb;
  static String get googleOAuthClientIdAndroid => EnvConfig.googleOAuthClientIdAndroid;
  static String get googleOAuthClientIdIos => EnvConfig.googleOAuthClientIdIos;
  static bool get hasGoogleOAuthConfig => EnvConfig.hasGoogleOAuthConfig;
  
  // Cashfree configuration
  static String get cashfreeAppId => EnvConfig.cashfreeAppId;
  static String get cashfreeSecretKey => EnvConfig.cashfreeSecretKey;
  static String get cashfreeMode => EnvConfig.cashfreeMode;
  static bool get hasCashfreeConfig => EnvConfig.hasCashfreeConfig;
  
  // Clerk configuration
  static String get clerkPublishableKey => EnvConfig.clerkPublishableKey;
  static String get clerkSecretKey => EnvConfig.clerkSecretKey;
  static bool get hasClerkConfig => EnvConfig.hasClerkConfig;
  
  // Perplexity configuration
  static String get perplexityApiKey => EnvConfig.perplexityApiKey;
  static bool get hasPerplexityConfig => EnvConfig.hasPerplexityConfig;
}

