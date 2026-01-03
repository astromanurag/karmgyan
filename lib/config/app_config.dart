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
}

