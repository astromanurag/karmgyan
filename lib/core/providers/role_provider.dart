import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';

// Role-based providers
final userRoleProvider = Provider<String>((ref) {
  return ref.watch(authProvider).userRole;
});

final isAdminProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isAdmin;
});

final isConsultantProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isConsultant;
});

final isClientProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isClient;
});

