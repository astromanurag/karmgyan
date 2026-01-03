import 'package:flutter_test/flutter_test.dart';
import 'package:karmgyan/core/middleware/auth_middleware.dart';
import 'package:karmgyan/core/providers/auth_provider.dart';
import 'package:karmgyan/core/models/user_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  group('Role-Based Access Tests', () {
    test('requireAuth with authenticated user', () {
      final container = ProviderContainer();
      final user = UserModel(
        id: 'user_001',
        email: 'test@example.com',
        role: 'client',
        createdAt: DateTime.now(),
      );
      
      container.read(authProvider.notifier).state = AuthState(user: user);
      
      final result = requireAuth(container.read, null);
      expect(result, true);
    });

    test('requireAuth with unauthenticated user', () {
      final container = ProviderContainer();
      container.read(authProvider.notifier).state = AuthState();
      
      final result = requireAuth(container.read, null);
      expect(result, false);
    });

    test('requireAuth with role check', () {
      final container = ProviderContainer();
      final adminUser = UserModel(
        id: 'admin_001',
        email: 'admin@example.com',
        role: 'admin',
        createdAt: DateTime.now(),
      );
      
      container.read(authProvider.notifier).state = AuthState(user: adminUser);
      
      final result = requireAuth(container.read, 'admin');
      expect(result, true);
      
      final wrongRoleResult = requireAuth(container.read, 'consultant');
      expect(wrongRoleResult, false);
    });

    test('getRoleBasedRedirect', () {
      final container = ProviderContainer();
      
      // Unauthenticated
      container.read(authProvider.notifier).state = AuthState();
      expect(getRoleBasedRedirect(container.read), '/login');
      
      // Admin
      final adminUser = UserModel(
        id: 'admin_001',
        email: 'admin@example.com',
        role: 'admin',
        createdAt: DateTime.now(),
      );
      container.read(authProvider.notifier).state = AuthState(user: adminUser);
      expect(getRoleBasedRedirect(container.read), '/admin/dashboard');
      
      // Consultant
      final consultantUser = UserModel(
        id: 'consultant_001',
        email: 'consultant@example.com',
        role: 'consultant',
        createdAt: DateTime.now(),
      );
      container.read(authProvider.notifier).state = AuthState(user: consultantUser);
      expect(getRoleBasedRedirect(container.read), '/consultant/dashboard');
      
      // Client
      final clientUser = UserModel(
        id: 'client_001',
        email: 'client@example.com',
        role: 'client',
        createdAt: DateTime.now(),
      );
      container.read(authProvider.notifier).state = AuthState(user: clientUser);
      expect(getRoleBasedRedirect(container.read), '/home');
    });
  });
}

