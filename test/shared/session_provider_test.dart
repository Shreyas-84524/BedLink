import 'package:bedlink/features/auth/domain/models/auth_credentials.dart';
import 'package:bedlink/shared/models/user_role.dart';
import 'package:bedlink/shared/providers/session_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SessionProvider Tests', () {
    test('Initial state is unauthenticated', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final session = container.read(sessionProvider);
      expect(session.role, UserRole.unauthenticated);
      expect(session.role.isAuthenticated, false);
      expect(session.userId, isNull);
      expect(session.isAuthenticated, false);
    });

    test('loginAsAmbulance updates state correctly', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await container.read(sessionProvider.notifier).loginAsAmbulance();

      final session = container.read(sessionProvider);
      expect(session.role, UserRole.ambulanceCrew);
      expect(session.role.isAmbulance, true);
      expect(session.role.isHospital, false);
      expect(session.organizationId, 'amb-101');
      expect(session.isAuthenticated, true);
    });

    test('loginAsHospital updates state correctly', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await container.read(sessionProvider.notifier).loginAsHospital();

      final session = container.read(sessionProvider);
      expect(session.role, UserRole.hospitalStaff);
      expect(session.role.isHospital, true);
      expect(session.role.isAmbulance, false);
      expect(session.organizationId, 'hosp-kem-01');
      expect(session.isAuthenticated, true);
    });

    test('login with valid credentials succeeds', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final success = await container.read(sessionProvider.notifier).login(
            const AuthCredentials(
              identifier: '1010101010',
              password: 'password123',
              role: UserRole.ambulanceCrew,
            ),
          );

      expect(success, true);
      final session = container.read(sessionProvider);
      expect(session.isAuthenticated, true);
      expect(session.role, UserRole.ambulanceCrew);
      expect(session.errorMessage, isNull);
    });

    test('login with invalid password records error message', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final success = await container.read(sessionProvider.notifier).login(
            const AuthCredentials(
              identifier: '1010101010',
              password: 'wrongpassword',
              role: UserRole.ambulanceCrew,
            ),
          );

      expect(success, false);
      final session = container.read(sessionProvider);
      expect(session.isAuthenticated, false);
      expect(session.errorMessage, isNotNull);
    });

    test('login with role mismatch fails with informative error', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Unit 101 ID submitted under hospital staff role
      final success = await container.read(sessionProvider.notifier).login(
            const AuthCredentials(
              identifier: '1010101010',
              password: 'password123',
              role: UserRole.hospitalStaff,
            ),
          );

      expect(success, false);
      final session = container.read(sessionProvider);
      expect(session.isAuthenticated, false);
      expect(session.errorMessage, contains('Role mismatch'));
    });

    test('logout resets session back to unauthenticated', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await container.read(sessionProvider.notifier).loginAsAmbulance();
      expect(container.read(sessionProvider).role, UserRole.ambulanceCrew);

      await container.read(sessionProvider.notifier).logout();
      expect(container.read(sessionProvider).role, UserRole.unauthenticated);
      expect(container.read(sessionProvider).userId, isNull);
    });
  });
}
