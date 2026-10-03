import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bedlink/app/app.dart';
import 'package:bedlink/app/router.dart';
import 'package:bedlink/features/ambulance/presentation/providers/intake_provider.dart';
import 'package:bedlink/features/ambulance/presentation/providers/requirement_provider.dart';
import 'package:bedlink/features/matching/data/mock_hospital_data.dart';
import 'package:bedlink/features/matching/presentation/providers/selected_hospital_provider.dart';
import 'package:bedlink/features/navigation/presentation/providers/navigation_state_provider.dart';
import 'package:bedlink/features/navigation/presentation/widgets/arrival_confirmation_card.dart';
import 'package:bedlink/features/navigation/presentation/widgets/bed_held_banner.dart';
import 'package:bedlink/features/navigation/presentation/widgets/completed_handoff_card.dart';
import 'package:bedlink/features/navigation/presentation/widgets/confirmed_destination_card.dart';
import 'package:bedlink/features/navigation/presentation/widgets/mock_route_map.dart';
import 'package:bedlink/features/navigation/presentation/widgets/route_instruction_card.dart';
import 'package:bedlink/features/reservation/presentation/providers/hold_timer_provider.dart';
import 'package:bedlink/shared/providers/session_provider.dart';

void main() {
  setUp(() {
    HoldTimerNotifier.disablePeriodicTickerForTesting = true;
  });

  tearDown(() {
    HoldTimerNotifier.disablePeriodicTickerForTesting = false;
  });

  group('NavigationScreen Widget Tests (Phase 9)', () {
    testWidgets('Displays fallback recovery card when no destination hospital is selected', (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      tester.view.physicalSize = const Size(400 * 2.0, 1000 * 2.0);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await container.read(sessionProvider.notifier).loginAsAmbulance();

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const BedLinkApp(),
        ),
      );
      await tester.pumpAndSettle();

      container.read(routerProvider).go('/ambulance/navigation');
      await tester.pumpAndSettle();

      expect(find.text('TRANSIT NAVIGATION'), findsOneWidget);
      expect(find.text('NO ACTIVE DESTINATION SELECTED'), findsOneWidget);
      expect(find.text('GO TO HOSPITAL DISCOVERY'), findsOneWidget);
      expect(find.text('RETURN TO INTAKE'), findsOneWidget);

      await tester.tap(find.text('GO TO HOSPITAL DISCOVERY'));
      await tester.pumpAndSettle();

      expect(
        container.read(routerProvider).routerDelegate.currentConfiguration.uri.toString(),
        equals('/ambulance/hospitals'),
      );
    });

    testWidgets('Renders all Phase 9 components when target hospital is selected', (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      tester.view.physicalSize = const Size(400 * 2.0, 1400 * 2.0);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await container.read(sessionProvider.notifier).loginAsAmbulance();
      container.read(patientIntakeProvider.notifier).fillQuickDemoPreset();
      container.read(bedRequirementProvider.notifier).applyPreset('cardiac_emergency');
      container.read(selectedHospitalProvider.notifier).selectHospital(MockHospitalData.kemHospital);
      container.read(holdTimerProvider.notifier).simulateAccept();

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const BedLinkApp(),
        ),
      );
      await tester.pumpAndSettle();

      container.read(routerProvider).go('/ambulance/navigation');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // 1. Header & Patient Triage Strip
      expect(find.text('TRANSIT NAVIGATION'), findsOneWidget);
      expect(find.textContaining('Ramesh Patil'), findsOneWidget);
      expect(find.text('AMBULANCE EN ROUTE'), findsOneWidget);

      // 2. High-Visibility Bed Hold Active Banner
      expect(find.byType(BedHeldBanner), findsOneWidget);
      expect(find.text('BED HOLD ACTIVE • RESOURCE LOCKED'), findsOneWidget);

      // 3. Mock Vector Route Map Canvas
      expect(find.byType(MockRouteMap), findsOneWidget);
      expect(find.text('VECTOR ROUTE MOCK'), findsOneWidget);

      // 4. Turn-by-Turn Route Guidance Card
      expect(find.byType(RouteInstructionCard), findsOneWidget);
      expect(find.text('STEP 1 OF 5'), findsOneWidget);
      expect(find.textContaining('Senapati Bapat Marg'), findsWidgets);

      // 5. Arrival Confirmation Card (in Armed / En Route status)
      expect(find.byType(ArrivalConfirmationCard), findsOneWidget);
      expect(find.text('ARRIVAL PROTOCOL ARMED'), findsOneWidget);

      // 6. Confirmed Destination Summary Card
      expect(find.byType(ConfirmedDestinationCard), findsOneWidget);
      expect(find.text('CONFIRMED DESTINATION'), findsOneWidget);
      expect(find.textContaining('King Edward Memorial'), findsWidgets);

      // 7. Developer Simulation Controls & Back Button
      expect(find.text('DEVELOPER TRANSIT FIXTURES'), findsOneWidget);
      expect(find.text('BACK TO HOLD STATUS'), findsOneWidget);
    });

    testWidgets('Simulating arrival near hospital bay enables one-tap arrival confirmation', (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      tester.view.physicalSize = const Size(400 * 2.0, 1400 * 2.0);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await container.read(sessionProvider.notifier).loginAsAmbulance();
      container.read(patientIntakeProvider.notifier).fillQuickDemoPreset();
      container.read(selectedHospitalProvider.notifier).selectHospital(MockHospitalData.kemHospital);
      container.read(holdTimerProvider.notifier).simulateAccept();

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const BedLinkApp(),
        ),
      );
      await tester.pumpAndSettle();

      container.read(routerProvider).go('/ambulance/navigation');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Simulate near arrival via notifier
      container.read(navigationStateProvider.notifier).simulateNearArrival();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('APPROACHING HOSPITAL BAY (< 200M)'), findsOneWidget);
      expect(find.text('CONFIRM ARRIVAL AT HOSPITAL'), findsOneWidget);

      // Tap Confirm Arrival
      await tester.tap(find.text('CONFIRM ARRIVAL AT HOSPITAL'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('ARRIVED AT EMERGENCY BAY'), findsOneWidget);
      expect(find.text('COMPLETE PATIENT HANDOFF'), findsOneWidget);
    });

    testWidgets('Completing handoff displays summary card and resets workflow on new emergency', (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      tester.view.physicalSize = const Size(400 * 2.0, 1400 * 2.0);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await container.read(sessionProvider.notifier).loginAsAmbulance();
      container.read(patientIntakeProvider.notifier).fillQuickDemoPreset();
      container.read(bedRequirementProvider.notifier).applyPreset('cardiac_emergency');
      container.read(selectedHospitalProvider.notifier).selectHospital(MockHospitalData.kemHospital);
      container.read(holdTimerProvider.notifier).simulateAccept();

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const BedLinkApp(),
        ),
      );
      await tester.pumpAndSettle();

      container.read(routerProvider).go('/ambulance/navigation');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Directly mark handoff complete
      container.read(navigationStateProvider.notifier).completeHandoff();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Verify CompletedHandoffCard is visible
      expect(find.byType(CompletedHandoffCard), findsOneWidget);
      expect(find.text('PATIENT HANDOFF FINALIZED'), findsOneWidget);
      expect(find.text('MISSION LOG SUMMARY'), findsOneWidget);
      expect(find.text('START NEW EMERGENCY'), findsOneWidget);
      expect(find.text('RETURN TO DISPATCH HOME'), findsOneWidget);

      // Tap Start New Emergency
      await tester.tap(find.text('START NEW EMERGENCY'));
      await tester.pumpAndSettle();

      // Should navigate to /ambulance/intake and have empty patient state
      expect(
        container.read(routerProvider).routerDelegate.currentConfiguration.uri.toString(),
        equals('/ambulance/intake'),
      );
      expect(container.read(patientIntakeProvider).patientName.isEmpty, isTrue);
      expect(container.read(selectedHospitalProvider), isNull);
      expect(container.read(sessionProvider).isAuthenticated, isTrue);
    });

    testWidgets('Responsive Layout: Renders on narrow 320dp viewport without pixel overflow', (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      tester.view.physicalSize = const Size(320.0, 800.0);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await container.read(sessionProvider.notifier).loginAsAmbulance();
      container.read(patientIntakeProvider.notifier).fillQuickDemoPreset();
      container.read(selectedHospitalProvider.notifier).selectHospital(MockHospitalData.kemHospital);
      container.read(holdTimerProvider.notifier).simulateAccept();

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const BedLinkApp(),
        ),
      );
      await tester.pumpAndSettle();

      container.read(routerProvider).go('/ambulance/navigation');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(tester.takeException(), isNull);
      expect(find.text('TRANSIT NAVIGATION'), findsOneWidget);
      expect(find.byType(MockRouteMap), findsOneWidget);
    });
  });
}
