import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bedlink/app/app.dart';
import 'package:bedlink/app/router.dart';
import 'package:bedlink/features/ambulance/presentation/providers/intake_provider.dart';
import 'package:bedlink/features/ambulance/presentation/providers/requirement_provider.dart';
import 'package:bedlink/features/matching/data/mock_hospital_data.dart';
import 'package:bedlink/features/matching/presentation/providers/selected_hospital_provider.dart';
import 'package:bedlink/features/reservation/domain/models/hold_status.dart';
import 'package:bedlink/features/reservation/presentation/providers/hold_timer_provider.dart';
import 'package:bedlink/shared/providers/session_provider.dart';

void main() {
  setUp(() {
    HoldTimerNotifier.disablePeriodicTickerForTesting = true;
  });

  tearDown(() {
    HoldTimerNotifier.disablePeriodicTickerForTesting = false;
  });

  group('Hold Confirmation Screen Widget Tests (Sub-phases 7.1 - 7.8)', () {
    testWidgets('Displays missing hospital recovery card when no hospital is selected', (tester) async {
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

      container.read(routerProvider).go('/ambulance/hold');
      await tester.pumpAndSettle();

      expect(find.text('HOLD CONFIRMATION'), findsOneWidget);
      expect(find.text('NO HOSPITAL SELECTED'), findsOneWidget);
      expect(find.text('BACK TO HOSPITAL MATCHES'), findsOneWidget);

      await tester.tap(find.text('BACK TO HOSPITAL MATCHES'));
      await tester.pumpAndSettle();

      expect(container.read(routerProvider).routerDelegate.currentConfiguration.uri.toString(),
          equals('/ambulance/hospitals'));
    });

    testWidgets('Renders all Phase 7 components when target hospital is selected', (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      tester.view.physicalSize = const Size(400 * 2.0, 1400 * 2.0);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await container.read(sessionProvider.notifier).loginAsAmbulance();
      container.read(patientIntakeProvider.notifier).fillQuickDemoPreset();
      container.read(bedRequirementProvider.notifier).applyPreset('cardiac_arrest');
      container.read(selectedHospitalProvider.notifier).selectHospital(MockHospitalData.kemHospital);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const BedLinkApp(),
        ),
      );
      await tester.pumpAndSettle();

      container.read(routerProvider).go('/ambulance/hold');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Sub-phase 7.1: Header
      expect(find.text('HOLD CONFIRMATION'), findsOneWidget);
      expect(find.text('Step 4 of 5 • 2-Min Lock Protocol'), findsOneWidget);

      // Sub-phase 7.2: Circular Countdown
      expect(find.text('02:00'), findsOneWidget);
      expect(find.text('2-MIN WINDOW'), findsOneWidget);

      // Sub-phase 7.3: Target Hospital Hold Card
      expect(find.textContaining('King Edward Memorial'), findsWidgets);
      expect(find.textContaining('8 MIN'), findsWidgets);
      expect(find.textContaining('3.8 km'), findsWidgets);
      expect(find.text('HOLD REQUEST SUBMITTED'), findsOneWidget);
      expect(find.textContaining('Trauma Desk:'), findsOneWidget);

      // Sub-phase 7.4: Inbound Patient Summary Card
      expect(find.text('INBOUND PATIENT SUMMARY'), findsOneWidget);
      expect(find.textContaining('Ramesh Patil'), findsOneWidget);
      expect(find.text('CRITICAL'), findsOneWidget);

      // Sub-phase 7.5: Fallback Progress Tracker
      expect(find.text('AUTOMATED SAFETY FALLBACK'), findsOneWidget);
      expect(find.text('STANDBY ACTIVE'), findsOneWidget);
      expect(find.textContaining('Hinduja'), findsWidgets);

      // Simulation Controls & Cancel Button
      expect(find.text('DEMO SIMULATION CONTROLS'), findsOneWidget);
      expect(find.text('Accept & Lock'), findsOneWidget);
      expect(find.text('Reject Offer'), findsOneWidget);
      expect(find.text('Simulate 00:00'), findsOneWidget);
      expect(find.text('CANCEL HOLD REQUEST'), findsOneWidget);
    });

    testWidgets('Simulate Accept transitions state to locked and enables En-Route CTA', (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      tester.view.physicalSize = const Size(400 * 2.0, 1400 * 2.0);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await container.read(sessionProvider.notifier).loginAsAmbulance();
      container.read(patientIntakeProvider.notifier).fillQuickDemoPreset();
      container.read(selectedHospitalProvider.notifier).selectHospital(MockHospitalData.kemHospital);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const BedLinkApp(),
        ),
      );
      await tester.pumpAndSettle();

      container.read(routerProvider).go('/ambulance/hold');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Simulate hospital acceptance directly on provider
      container.read(holdTimerProvider.notifier).simulateAccept();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // 7.6 Mock Accepted State
      expect(find.text('BED HOLD CONFIRMED • LOCKED'), findsOneWidget);
      expect(find.text('LOCKED'), findsOneWidget);
      expect(find.text('BED LOCKED'), findsOneWidget);
      expect(find.text('START EN-ROUTE NAVIGATION'), findsOneWidget);

      // Tap navigation button to test route transition
      await tester.tap(find.text('START EN-ROUTE NAVIGATION'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(container.read(routerProvider).routerDelegate.currentConfiguration.uri.toString(),
          equals('/ambulance/navigation'));
    });

    testWidgets('Simulate Reject transitions to declined state and offers next standby fallback', (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      tester.view.physicalSize = const Size(400 * 2.0, 1400 * 2.0);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await container.read(sessionProvider.notifier).loginAsAmbulance();
      container.read(patientIntakeProvider.notifier).fillQuickDemoPreset();
      container.read(selectedHospitalProvider.notifier).selectHospital(MockHospitalData.kemHospital);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const BedLinkApp(),
        ),
      );
      await tester.pumpAndSettle();

      container.read(routerProvider).go('/ambulance/hold');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Simulate hospital rejection directly on provider
      container.read(holdTimerProvider.notifier).simulateReject();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // 7.7 Mock Rejected State
      expect(find.text('HOLD REQUEST DECLINED'), findsOneWidget);
      expect(find.text('OFFER DECLINED'), findsOneWidget);
      expect(find.textContaining('OFFER TO'), findsWidgets);
      expect(find.text('RETURN TO HOSPITAL MATCHES'), findsOneWidget);

      // Tap advance to fallback (first OFFER TO button)
      await tester.tap(find.textContaining('OFFER TO').first);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Should now target Hinduja Hospital (#2)
      final currentOffer = container.read(holdTimerProvider);
      expect(currentOffer?.hospital.id, equals('hinduja_mahim'));
      expect(currentOffer?.status, equals(HoldLifecycleState.pending));
      expect(currentOffer?.attemptNumber, equals(2));
      expect(currentOffer?.fallbackHospital?.id, equals('lilavati_bandra'));
    });

    testWidgets('Simulate Timeout transitions to expired state with fallback option', (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      tester.view.physicalSize = const Size(400 * 2.0, 1400 * 2.0);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await container.read(sessionProvider.notifier).loginAsAmbulance();
      container.read(selectedHospitalProvider.notifier).selectHospital(MockHospitalData.kemHospital);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const BedLinkApp(),
        ),
      );
      await tester.pumpAndSettle();

      container.read(routerProvider).go('/ambulance/hold');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Simulate timeout directly on provider
      container.read(holdTimerProvider.notifier).simulateTimeout();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // 7.7 Mock Timed-Out State
      expect(find.text('HOLD WINDOW EXPIRED (120S)'), findsOneWidget);
      expect(find.text('HOLD EXPIRED'), findsWidgets);
      expect(find.text('00:00'), findsOneWidget);
      expect(find.textContaining('OFFER TO'), findsWidgets);
    });

    testWidgets('Sub-phase 7.8: Responsive layout verification on 320dp narrow viewport', (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Restrict viewport to 320dp width
      tester.view.physicalSize = const Size(320 * 2.0, 800 * 2.0);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await container.read(sessionProvider.notifier).loginAsAmbulance();
      container.read(patientIntakeProvider.notifier).fillQuickDemoPreset();
      container.read(bedRequirementProvider.notifier).applyPreset('cardiac_arrest');
      container.read(selectedHospitalProvider.notifier).selectHospital(MockHospitalData.kemHospital);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const BedLinkApp(),
        ),
      );
      await tester.pumpAndSettle();

      container.read(routerProvider).go('/ambulance/hold');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Must build and render cleanly without any Flutter layout overflow errors
      expect(find.text('HOLD CONFIRMATION'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
