import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'config/app_theme.dart';
import 'config/env_config.dart';
import 'core/router/app_router.dart';
import 'core/services/local_storage_service.dart';
import 'core/services/notification_service.dart';
import 'core/providers/auth_provider.dart';
import 'services/supabase_service.dart';
import 'services/enhanced_payment_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize environment configuration
  await EnvConfig.initialize();
  
  // Configuration:
  // - Use REAL BACKEND for astrology calculations (charts, panchang, etc.)
  // - Use MOCK AUTH for easy testing without backend authentication
  EnvConfig.overrideMockData(false);  // false = real backend for astrology
  EnvConfig.overrideMockAuth(true);   // true = mock auth (test@test.com works)
  
  debugPrint('🔧 App Mode: ${EnvConfig.useMockData ? "MOCK DATA" : "LIVE BACKEND"}');
  debugPrint('🔐 Auth Mode: ${EnvConfig.useMockAuth ? "MOCK AUTH" : "LIVE AUTH"}');
  debugPrint('🌐 Backend URL: ${EnvConfig.backendUrl}');
  
  // Initialize Hive for local storage
  await Hive.initFlutter();
  await LocalStorageService.initialize();
  
  // Initialize Easy Localization
  await EasyLocalization.ensureInitialized();
  
  // Initialize Supabase if configured
  try {
    await SupabaseService.initialize();
  } catch (e) {
    debugPrint('Supabase initialization failed (using mock data): $e');
  }
  
  // Initialize payment service if configured
  try {
    EnhancedPaymentService.initialize();
  } catch (e) {
    debugPrint('Payment service initialization failed: $e');
  }
  
  // Initialize notifications (with error handling for web)
  try {
    await NotificationService.initialize();
  } catch (e) {
    debugPrint('Notification initialization failed (may be expected on web): $e');
  }
  
  runApp(
    EasyLocalization(
      supportedLocales: const [
        Locale('en'),
        Locale('hi'),
        Locale('ta'),
        Locale('te'),
        Locale('kn'),
        Locale('ml'),
      ],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      useOnlyLangCode: true,
      child: const ProviderScope(
        child: karmgyanApp(),
      ),
    ),
  );
}

class karmgyanApp extends ConsumerWidget {
  const karmgyanApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'karmgyan - Personal Advisory Platform',
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        // Clamp text scale to keep UI consistent across platforms and high-DPI displays
        final mq = MediaQuery.of(context);
        final clampedTextScale = mq.textScaler.clamp(minScaleFactor: 0.9, maxScaleFactor: 1.1);
        return MediaQuery(
          data: mq.copyWith(textScaler: clampedTextScale),
          child: child ?? const SizedBox.shrink(),
        );
      },
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}

