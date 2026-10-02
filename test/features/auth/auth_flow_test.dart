import 'package:bedlink/app/app.dart';
import 'package:bedlink/shared/models/user_role.dart';
import 'package:bedlink/shared/providers/session_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Auth Flow Widget Tests', () {
    testWidgets('LoginScreen switches roles and updates autofill values', (WidgetTester tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const BedLinkApp(),
        ),
      );
      await tester.pumpAndSettle();

      // Navigate to Login
      await tester.tap(find.text('PROCEED TO LOGIN'));
      await tester.pumpAndSettle();

      expect(find.text('EMERGENCY NETWORK ACCESS'), findsOneWidget);
      expect(find.text('AUTHENTICATE AS AMBULANCE'), findsOneWidget);

      // Tap Hospital Staff role tab
      final hospitalTab = find.text('Hospital Staff');
      await tester.ensureVisible(hospitalTab);
      await tester.tap(hospitalTab);
      await tester.pumpAndSettle();

      expect(find.text('AUTHENTICATE AS HOSPITAL'), findsOneWidget);
      expect(find.text('9090909090'), findsOneWidget);

      // Tap Demo Ambulance autofill shortcut
      final demoChip = find.text('⚡ Fill Demo Crew (101)');
      await tester.ensureVisible(demoChip);
      await tester.tap(demoChip);
      await tester.pumpAndSettle();

      expect(find.text('AUTHENTICATE AS AMBULANCE'), findsOneWidget);
      expect(find.text('1010101010'), findsOneWidget);
    });

    testWidgets('LoginScreen submits credentials and navigates to Ambulance Shell', (WidgetTester tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const BedLinkApp(),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('PROCEED TO LOGIN'));
      await tester.pumpAndSettle();

      // Submit ambulance login
      final authBtn = find.text('AUTHENTICATE AS AMBULANCE');
      await tester.ensureVisible(authBtn);
      await tester.tap(authBtn);
      await tester.pumpAndSettle();

      // Verify Ambulance Shell is displayed
      expect(find.text('AMBULANCE DISPATCH'), findsOneWidget);
      expect(find.text('MUMBAI EMS UNIT 101'), findsOneWidget);
      expect(find.text('ON DUTY • STANDBY'), findsOneWidget);

      // Verify session provider state
      final session = container.read(sessionProvider);
      expect(session.isAuthenticated, true);
      expect(session.role, UserRole.ambulanceCrew);

      // Tap logout button in app bar
      await tester.tap(find.byIcon(Icons.logout_rounded));
      await tester.pumpAndSettle();

      // Verify redirected back to Login
      expect(find.text('EMERGENCY NETWORK ACCESS'), findsOneWidget);
      expect(container.read(sessionProvider).isAuthenticated, false);
    });

    testWidgets('LoginScreen submits hospital credentials and navigates to Hospital Shell', (WidgetTester tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const BedLinkApp(),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('PROCEED TO LOGIN'));
      await tester.pumpAndSettle();

      // Switch to Hospital Staff
      final hospitalTab = find.text('Hospital Staff');
      await tester.ensureVisible(hospitalTab);
      await tester.tap(hospitalTab);
      await tester.pumpAndSettle();

      // Submit hospital login
      final authBtn = find.text('AUTHENTICATE AS HOSPITAL');
      await tester.ensureVisible(authBtn);
      await tester.tap(authBtn);
      await tester.pumpAndSettle();

      // Verify Hospital Shell is displayed
      expect(find.text('HOSPITAL TRIAGE DESK'), findsOneWidget);
      expect(find.text('KEM HOSPITAL MUMBAI'), findsOneWidget);
      expect(find.text('LIVE EMERGENCY CAPACITY SNAPSHOT'), findsOneWidget);

      // Verify session provider state
      final session = container.read(sessionProvider);
      expect(session.isAuthenticated, true);
      expect(session.role, UserRole.hospitalStaff);

      // Tap logout button in app bar
      await tester.tap(find.byIcon(Icons.logout_rounded));
      await tester.pumpAndSettle();

      // Verify redirected back to Login
      expect(find.text('EMERGENCY NETWORK ACCESS'), findsOneWidget);
      expect(container.read(sessionProvider).isAuthenticated, false);
    });
  });
}
