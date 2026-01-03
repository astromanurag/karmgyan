import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Role-based route guard
bool requireAuth(WidgetRef ref, String? requiredRole) {
  final authState = ref.read(authProvider);
  
  if (!authState.isAuthenticated) {
    return false;
  }
  
  if (requiredRole != null) {
    final userRole = authState.userRole;
    if (userRole != requiredRole) {
      return false;
    }
  }
  
  return true;
}

// Redirect based on role
String? getRoleBasedRedirect(WidgetRef ref) {
  final authState = ref.read(authProvider);
  
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

