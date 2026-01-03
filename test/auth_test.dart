import 'package:flutter_test/flutter_test.dart';
import 'package:karmgyan/core/providers/auth_provider.dart';
import 'package:karmgyan/services/auth_service.dart';
import 'package:karmgyan/core/models/user_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  group('Auth Tests', () {
    test('User model from JSON', () {
      final json = {
        'id': 'user_001',
        'email': 'test@example.com',
        'name': 'Test User',
        'role': 'client',
        'auth_provider': 'email',
        'email_verified': true,
        'phone_verified': false,
        'created_at': '2024-01-01T00:00:00Z',
      };

      final user = UserModel.fromJson(json);
      expect(user.id, 'user_001');
      expect(user.email, 'test@example.com');
      expect(user.role, 'client');
      expect(user.emailVerified, true);
    });

    test('Auth state isAuthenticated', () {
      final state = AuthState();
      expect(state.isAuthenticated, false);

      final user = UserModel(
        id: 'user_001',
        email: 'test@example.com',
        role: 'client',
        createdAt: DateTime.now(),
      );
      final stateWithUser = AuthState(user: user);
      expect(stateWithUser.isAuthenticated, true);
      expect(stateWithUser.userRole, 'client');
    });

    test('Role checks', () {
      final adminUser = UserModel(
        id: 'admin_001',
        email: 'admin@example.com',
        role: 'admin',
        createdAt: DateTime.now(),
      );
      final adminState = AuthState(user: adminUser);
      expect(adminState.isAdmin, true);
      expect(adminState.isConsultant, false);
      expect(adminState.isClient, false);

      final consultantUser = UserModel(
        id: 'consultant_001',
        email: 'consultant@example.com',
        role: 'consultant',
        createdAt: DateTime.now(),
      );
      final consultantState = AuthState(user: consultantUser);
      expect(consultantState.isAdmin, false);
      expect(consultantState.isConsultant, true);
      expect(consultantState.isClient, false);
    });
  });
}

