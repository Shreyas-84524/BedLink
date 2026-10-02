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
    });

    test('loginAsAmbulance updates state correctly', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(sessionProvider.notifier).loginAsAmbulance();

      final session = container.read(sessionProvider);
      expect(session.role, UserRole.ambulanceCrew);
      expect(session.role.isAmbulance, true);
      expect(session.role.isHospital, false);
      expect(session.organizationId, 'amb-101');
    });

    test('loginAsHospital updates state correctly', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(sessionProvider.notifier).loginAsHospital();

      final session = container.read(sessionProvider);
      expect(session.role, UserRole.hospitalStaff);
      expect(session.role.isHospital, true);
      expect(session.role.isAmbulance, false);
      expect(session.organizationId, 'hosp-kem-01');
    });

    test('logout resets session back to unauthenticated', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(sessionProvider.notifier).loginAsAmbulance();
      expect(container.read(sessionProvider).role, UserRole.ambulanceCrew);

      container.read(sessionProvider.notifier).logout();
      expect(container.read(sessionProvider).role, UserRole.unauthenticated);
    });
  });
}
