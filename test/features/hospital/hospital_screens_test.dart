import 'package:bedlink/app/app.dart';
import 'package:bedlink/app/router.dart';
import 'package:bedlink/features/hospital/presentation/providers/hospital_state_provider.dart';
import 'package:bedlink/features/hospital/presentation/screens/hospital_dashboard_screen.dart';
import 'package:bedlink/features/hospital/presentation/screens/hospital_holds_screen.dart';
import 'package:bedlink/features/hospital/presentation/screens/hospital_requests_screen.dart';
import 'package:bedlink/features/hospital/presentation/screens/hospital_resources_screen.dart';
import 'package:bedlink/shared/providers/session_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _buildTestApp({
  required Widget child,
  ProviderContainer? container,
}) {
  return UncontrolledProviderScope(
    container: container ?? ProviderContainer(),
    child: MaterialApp(
      home: child,
    ),
  );
}

void main() {
  group('Hospital Staff Screens Widget & Interaction Tests', () {
    testWidgets('HospitalDashboardScreen renders operational metrics and responds to actions', (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        _buildTestApp(
          container: container,
          child: const HospitalDashboardScreen(),
        ),
      );
      await tester.pump();

      expect(find.text('HOSPITAL TRIAGE DESK'), findsOneWidget);
      expect(find.text('LIVE EMERGENCY CAPACITY SNAPSHOT'), findsOneWidget);
      expect(find.text('ICU BEDS'), findsOneWidget);
      expect(find.text('O2 BEDS'), findsOneWidget);
      expect(find.text('TRAUMA'), findsOneWidget);
      expect(find.text('CONFIRM NO CHANGE'), findsOneWidget);

      // Tap Confirm No Change
      await tester.tap(find.text('CONFIRM NO CHANGE'));
      await tester.pump();
      expect(find.textContaining('confirmed with no changes'), findsOneWidget);
    });

    testWidgets('HospitalResourcesScreen displays categorized inventory and stepper adjustments', (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        _buildTestApp(
          container: container,
          child: const HospitalResourcesScreen(),
        ),
      );
      await tester.pump();

      expect(find.text('RESOURCE INVENTORY'), findsOneWidget);
      expect(find.text('CRITICAL CARE INVENTORY'), findsOneWidget);

      // Scroll to verify Acute & Emergency and Specialized units
      await tester.scrollUntilVisible(find.text('ACUTE & EMERGENCY CARE'), 200);
      expect(find.text('ACUTE & EMERGENCY CARE'), findsOneWidget);

      await tester.scrollUntilVisible(find.text('SPECIALIZED CLINICAL UNITS'), 200);
      expect(find.text('SPECIALIZED CLINICAL UNITS'), findsOneWidget);

      // Scroll back to top to interact with critical care stepper
      await tester.scrollUntilVisible(find.text('CRITICAL CARE INVENTORY'), -200);
      await tester.pump();

      // Check initial ICU count: 3 available
      expect(container.read(hospitalStateProvider).resources['icu_bed']!.available, 3);

      // Tap decrement on the first stepper (-)
      final minusButtons = find.byIcon(Icons.remove_rounded);
      expect(minusButtons, findsWidgets);
      await tester.tap(minusButtons.first);
      await tester.pump();

      // Available should now be 2
      expect(container.read(hospitalStateProvider).resources['icu_bed']!.available, 2);

      // Tap increment (+)
      final plusButtons = find.byIcon(Icons.add_rounded);
      expect(plusButtons, findsWidgets);
      await tester.tap(plusButtons.first);
      await tester.pump();

      // Available should now be 3
      expect(container.read(hospitalStateProvider).resources['icu_bed']!.available, 3);
    });

    testWidgets('HospitalRequestsScreen displays incoming triage offer and allows accept / decline flows', (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        _buildTestApp(
          container: container,
          child: const HospitalRequestsScreen(),
        ),
      );
      await tester.pump();

      expect(find.text('INCOMING REQUESTS'), findsOneWidget);
      expect(find.textContaining('SERVER-AUTHORITATIVE'), findsOneWidget);
      expect(find.text('Ramesh Patil'), findsOneWidget);
      expect(find.textContaining('AMB-108'), findsOneWidget);
      expect(find.text('ACCEPT EMERGENCY'), findsOneWidget);
      expect(find.text('DECLINE / DIVERT'), findsOneWidget);

      // Accept the request
      await tester.tap(find.text('ACCEPT EMERGENCY'));
      await tester.pump();

      expect(find.textContaining('BED RESERVED'), findsOneWidget);
      expect(container.read(hospitalStateProvider).activeHoldCount, 1);
    });

    testWidgets('HospitalRequestsScreen simulates timeout expiration', (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        _buildTestApp(
          container: container,
          child: const HospitalRequestsScreen(),
        ),
      );
      await tester.pump();

      // Tap simulate 120s timeout
      final simulateBtn = find.text('Simulate 120s Expiry Timeout');
      expect(simulateBtn, findsOneWidget);
      await tester.tap(simulateBtn);
      await tester.pump();

      expect(find.textContaining('OFFER TIMED OUT'), findsOneWidget);
    });

    testWidgets('HospitalHoldsScreen displays empty state when no holds, then displays active hold after accept', (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        _buildTestApp(
          container: container,
          child: const HospitalHoldsScreen(),
        ),
      );
      await tester.pump();

      expect(find.text('ACTIVE HOLDS'), findsOneWidget);
      expect(find.text('NO ACTIVE BED HOLDS'), findsOneWidget);

      // Accept a request programmatically
      container.read(hospitalStateProvider.notifier).acceptRequest('REQ-AMB-108');
      await tester.pump();

      expect(find.text('NO ACTIVE BED HOLDS'), findsNothing);
      expect(find.text('Ramesh Patil'), findsOneWidget);
      expect(find.textContaining('BL-HOLD-001'), findsOneWidget);
      expect(find.text('CONFIRM ARRIVED'), findsOneWidget);
      expect(find.text('RELEASE HOLD'), findsOneWidget);

      // Mark arrived
      await tester.tap(find.text('CONFIRM ARRIVED'));
      await tester.pump();

      expect(find.textContaining('PATIENT ARRIVED'), findsWidgets);
    });

    testWidgets('All Hospital screens render without overflow at 320dp width', (tester) async {
      tester.view.physicalSize = const Size(320 * 2.0, 700 * 2.0);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Test Dashboard at 320dp
      await tester.pumpWidget(_buildTestApp(container: container, child: const HospitalDashboardScreen()));
      await tester.pump();
      expect(tester.takeException(), isNull);

      // Test Resources at 320dp
      await tester.pumpWidget(_buildTestApp(container: container, child: const HospitalResourcesScreen()));
      await tester.pump();
      expect(tester.takeException(), isNull);

      // Test Requests at 320dp
      await tester.pumpWidget(_buildTestApp(container: container, child: const HospitalRequestsScreen()));
      await tester.pump();
      expect(tester.takeException(), isNull);

      // Test Holds at 320dp
      await tester.pumpWidget(_buildTestApp(container: container, child: const HospitalHoldsScreen()));
      await tester.pump();
      expect(tester.takeException(), isNull);
    });

    testWidgets('Hospital user role navigation isolates staff from ambulance intake routes', (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const BedLinkApp(),
        ),
      );
      await tester.pumpAndSettle();

      // Log in as hospital
      await container.read(sessionProvider.notifier).loginAsHospital();
      await tester.pumpAndSettle();

      expect(find.text('HOSPITAL TRIAGE DESK'), findsOneWidget);

      // Attempt navigating to ambulance route
      container.read(routerProvider).go('/ambulance/intake');
      await tester.pumpAndSettle();

      // Should be redirected back to /hospital or access denied due to role isolation
      expect(find.text('HOSPITAL TRIAGE DESK'), findsOneWidget);
    });
  });
}
