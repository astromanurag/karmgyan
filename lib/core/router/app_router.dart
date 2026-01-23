import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../presentation/screens/home/home_screen.dart';
import '../../presentation/screens/auth/login_screen.dart';
import '../../presentation/screens/auth/signup_screen.dart';
import '../../presentation/screens/auth/forgot_password_screen.dart';
import '../../presentation/screens/auth/phone_verification_screen.dart';
import '../../presentation/screens/charts/birth_chart_screen.dart';
import '../../presentation/screens/charts/divisional_charts_screen.dart';
import '../../presentation/screens/charts/chart_demo_screen.dart';
import '../../presentation/screens/services/services_screen.dart';
import '../../presentation/screens/orders/orders_screen.dart';
import '../../presentation/screens/reports/reports_screen.dart';
import '../../presentation/screens/reports/report_detail_screen.dart';
import '../../presentation/screens/consultations/consultations_screen.dart';
import '../../presentation/screens/calendar/calendar_screen.dart';
import '../../presentation/screens/matching/matching_screen.dart';
import '../../presentation/screens/profile/profile_screen.dart';
import '../../presentation/screens/admin/admin_dashboard_screen.dart';
import '../../presentation/screens/admin/consultant_list_screen.dart';
import '../../presentation/screens/admin/consultant_detail_screen.dart';
import '../../presentation/screens/admin/consultant_onboarding_screen.dart';
import '../../presentation/screens/admin/data_management_screen.dart';
import '../../presentation/screens/consultant/consultant_dashboard_screen.dart';
import '../../presentation/screens/consultant/earnings_screen.dart';
import '../../presentation/screens/consultant/consultation_schedule_screen.dart';
import '../../presentation/screens/predictions/dasha_predictions_screen.dart';
import '../../presentation/screens/predictions/yearly_forecast_screen.dart';
import '../../presentation/screens/matching/kundli_milan_screen.dart';
import '../../presentation/screens/panchang/muhurat_screen.dart';
import '../../presentation/screens/cart/cart_screen.dart';
import '../../presentation/screens/checkout/checkout_screen.dart';
import '../../presentation/screens/orders/order_confirmation_screen.dart';
import '../../presentation/screens/consultations/consultation_room_screen.dart';
import '../../presentation/screens/charts/all_varga_charts_screen.dart';
import '../../presentation/screens/horoscope/daily_horoscope_screen.dart';
import '../../presentation/screens/numerology/numerology_screen.dart';
import '../../presentation/screens/ai/ai_hub_screen.dart';
import '../../presentation/screens/ai/ai_chat_screen.dart';
import '../../presentation/screens/ai/ai_reports_screen.dart';
import '../../presentation/widgets/main_scaffold.dart';
import '../../core/providers/auth_provider.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);
  
  String? getRedirect() {
    if (!authState.isAuthenticated) {
      return '/login';
    }
    final role = authState.userRole;
    switch (role) {
      case 'admin':
        return '/admin/dashboard';
      case 'consultant':
        return '/consultant/dashboard';
      case 'client':
      default:
        return '/home';
    }
  }
  
  return GoRouter(
    initialLocation: authState.isAuthenticated 
        ? getRedirect() ?? '/home'
        : '/login',
    redirect: (context, state) {
      final isAuthenticated = authState.isAuthenticated;
      final location = state.matchedLocation;
      final isAuthRoute = location.startsWith('/login') || 
                          location.startsWith('/signup') ||
                          location.startsWith('/forgot-password') ||
                          location.startsWith('/phone-verification');
      
      if (!isAuthenticated && !isAuthRoute) {
        return '/login';
      }
      
      if (isAuthenticated && isAuthRoute) {
        return getRedirect();
      }
      
      // Role-based route protection
      if (isAuthenticated) {
        if (location.startsWith('/admin') && !authState.isAdmin) {
          return '/home';
        }
        if (location.startsWith('/consultant') && !authState.isConsultant) {
          return '/home';
        }
      }
      
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignUpScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/phone-verification',
        builder: (context, state) => const PhoneVerificationScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) {
          int currentIndex = 0;
          final location = state.matchedLocation;
          if (location == '/home') currentIndex = 0;
          else if (location == '/services') currentIndex = 1;
          else if (location == '/consultations') currentIndex = 2;
          else if (location == '/calendar') currentIndex = 3;
          else if (location == '/profile') currentIndex = 4;
          
          return MainScaffold(
            currentIndex: currentIndex,
            child: child,
          );
        },
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: '/services',
            builder: (context, state) => const ServicesScreen(),
          ),
          GoRoute(
            path: '/consultations',
            builder: (context, state) => const ConsultationsScreen(),
          ),
          GoRoute(
            path: '/calendar',
            builder: (context, state) => const CalendarScreen(),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileScreen(),
          ),
          GoRoute(
            path: '/birth-chart',
            builder: (context, state) => const BirthChartScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/birth-chart',
        builder: (context, state) => const BirthChartScreen(),
      ),
      GoRoute(
        path: '/chart-demo',
        builder: (context, state) => const ChartDemoScreen(),
      ),
      GoRoute(
        path: '/divisional-charts',
        builder: (context, state) => const DivisionalChartsScreen(),
      ),
      GoRoute(
        path: '/varga-charts',
        builder: (context, state) => const AllVargaChartsScreen(),
      ),
      GoRoute(
        path: '/horoscope',
        builder: (context, state) {
          final sign = state.uri.queryParameters['sign'];
          return DailyHoroscopeScreen(zodiacSign: sign);
        },
      ),
      GoRoute(
        path: '/numerology',
        builder: (context, state) => const NumerologyScreen(),
      ),
      // AI Predictions routes
      GoRoute(
        path: '/ai',
        builder: (context, state) => const AIHubScreen(),
      ),
      GoRoute(
        path: '/ai-chat',
        builder: (context, state) {
          final chartData = state.extra as Map<String, dynamic>?;
          return AIChatScreen(chartData: chartData);
        },
      ),
      GoRoute(
        path: '/ai-reports',
        builder: (context, state) {
          final chartData = state.extra as Map<String, dynamic>?;
          return AIReportsScreen(chartData: chartData);
        },
      ),
      GoRoute(
        path: '/orders',
        builder: (context, state) => const OrdersScreen(),
      ),
      GoRoute(
        path: '/reports',
        builder: (context, state) => const ReportsScreen(),
      ),
      GoRoute(
        path: '/reports/:id',
        builder: (context, state) {
          final report = state.extra as Map<String, dynamic>?;
          return ReportDetailScreen(
            reportType: state.pathParameters['id'] ?? 'birth_chart',
            birthData: report,
          );
        },
      ),
      GoRoute(
        path: '/matching',
        builder: (context, state) => const MatchingScreen(),
      ),
      // Admin routes
      GoRoute(
        path: '/admin/dashboard',
        builder: (context, state) => const AdminDashboardScreen(),
      ),
      GoRoute(
        path: '/admin/consultants',
        builder: (context, state) => const ConsultantListScreen(),
      ),
      GoRoute(
        path: '/admin/consultants/onboard',
        builder: (context, state) => const ConsultantOnboardingScreen(),
      ),
      GoRoute(
        path: '/admin/consultants/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return ConsultantDetailScreen(consultantId: id);
        },
      ),
      GoRoute(
        path: '/admin/data-management',
        builder: (context, state) => const DataManagementScreen(),
      ),
      // Consultant routes
      GoRoute(
        path: '/consultant/dashboard',
        builder: (context, state) => const ConsultantDashboardScreen(),
      ),
      GoRoute(
        path: '/consultant/earnings',
        builder: (context, state) => const EarningsScreen(),
      ),
      GoRoute(
        path: '/consultant/schedule',
        builder: (context, state) => const ConsultationScheduleScreen(),
      ),
      // Predictions routes
      GoRoute(
        path: '/predictions/dasha',
        builder: (context, state) => const DashaPredictionsScreen(),
      ),
      GoRoute(
        path: '/predictions/yearly',
        builder: (context, state) => const YearlyForecastScreen(),
      ),
      // Kundli Milan route
      GoRoute(
        path: '/kundli-milan',
        builder: (context, state) => const KundliMilanScreen(),
      ),
      // Panchang routes
      GoRoute(
        path: '/muhurat',
        builder: (context, state) => const MuhuratScreen(),
      ),
      // E-commerce routes
      GoRoute(
        path: '/cart',
        builder: (context, state) => const CartScreen(),
      ),
      GoRoute(
        path: '/checkout',
        builder: (context, state) => const CheckoutScreen(),
      ),
      GoRoute(
        path: '/order-confirmation',
        builder: (context, state) {
          final order = state.extra as Map<String, dynamic>?;
          return OrderConfirmationScreen(order: order ?? {});
        },
      ),
      GoRoute(
        path: '/consultation-room/:id',
        builder: (context, state) {
          final params = state.uri.queryParameters;
          return ConsultationRoomScreen(
            consultationId: state.pathParameters['id'] ?? '',
            consultantName: params['name'] ?? 'Consultant',
            type: params['type'] ?? 'video',
            isConsultant: params['isConsultant'] == 'true',
          );
        },
      ),
    ],
  );
});

