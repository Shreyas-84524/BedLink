import 'package:bedlink/app/app.dart';
import 'package:bedlink/app/router.dart';
import 'package:bedlink/features/ambulance/presentation/providers/intake_provider.dart';
import 'package:bedlink/features/ambulance/presentation/providers/requirement_provider.dart';
import 'package:bedlink/shared/providers/session_provider.dart';
import 'package:bedlink/shared/widgets/buttons/bedlink_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Bed Requirements Screen Widget & Responsive Tests (Sub-phase 5.8)', () {
    testWidgets('Renders all Phase 5 sections and validates initial disabled CTA', (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      tester.view.physicalSize = const Size(400 * 2.0, 1200 * 2.0);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      // Authenticate as Ambulance Crew
      await container.read(sessionProvider.notifier).loginAsAmbulance();

      // Populate demo patient intake
      container.read(patientIntakeProvider.notifier).fillQuickDemoPreset();

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const BedLinkApp(),
        ),
      );
      await tester.pumpAndSettle();

      container.read(routerProvider).go('/ambulance/requirements');
      await tester.pumpAndSettle();

      // 5.1 Patient Summary Banner
      expect(find.text('ACTIVE PATIENT SUMMARY'), findsOneWidget);
      expect(find.text('Ramesh Patil (Cardiac Case)'), findsOneWidget);
      expect(find.text('CRITICAL'), findsOneWidget);

      // 5.5 Preset bundles
      expect(find.text('EMERGENCY PRESET BUNDLES'), findsOneWidget);
      expect(find.text('Cardiac Emergency'), findsOneWidget);
      expect(find.text('Polytrauma ICU'), findsOneWidget);

      // 5.3 Suggestions
      expect(find.text('SUGGESTED FOR THIS COMPLAINT'), findsOneWidget);

      // 5.2 Search
      expect(find.text('SEARCH CLINICAL CATALOGUE'), findsOneWidget);

      // 5.4 Active requirements initial empty state
      expect(find.text('No Clinical Resources Selected'), findsOneWidget);

      // Bottom CTA disabled
      final discoverButton = tester.widget<BedLinkButton>(
        find.widgetWithText(BedLinkButton, 'DISCOVER MATCHING HOSPITALS'),
      );
      expect(discoverButton.onPressed, isNull);
    });

    testWidgets('Tapping Cardiac Emergency preset populates requirements and enables CTA', (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      tester.view.physicalSize = const Size(400 * 2.0, 1200 * 2.0);
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

      container.read(routerProvider).go('/ambulance/requirements');
      await tester.pumpAndSettle();

      // Tap 'Cardiac Emergency' preset
      await tester.tap(find.text('Cardiac Emergency'));
      await tester.pumpAndSettle();

      // Verify active chips appear
      expect(find.text('ICU Bed'), findsWidgets);
      expect(find.text('Cath Lab / CCU'), findsWidgets);

      // CTA should now be enabled
      final discoverButton = tester.widget<BedLinkButton>(
        find.widgetWithText(BedLinkButton, 'DISCOVER MATCHING HOSPITALS'),
      );
      expect(discoverButton.onPressed, isNotNull);

      // Tap Discover Matching Hospitals and verify navigation
      await tester.tap(find.widgetWithText(BedLinkButton, 'DISCOVER MATCHING HOSPITALS'));
      await tester.pumpAndSettle();

      // Should navigate to /ambulance/hospitals
      expect(find.textContaining('HOSPITAL MATCHES'), findsOneWidget);
    });

    testWidgets('Hard filter rule: Selecting ONLY care capability disables CTA with warning', (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      tester.view.physicalSize = const Size(400 * 2.0, 1200 * 2.0);
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

      container.read(routerProvider).go('/ambulance/requirements');
      await tester.pumpAndSettle();

      // Add only cardiac_care (capability, non-countable)
      container.read(bedRequirementProvider.notifier).addResource('cardiac_care');
      await tester.pumpAndSettle();

      // Active chips should show Cath Lab / CCU
      expect(find.text('Cath Lab / CCU'), findsWidgets);

      // Hard filter warning should be visible
      expect(find.textContaining('Hard Filter Rule'), findsOneWidget);

      // CTA should remain disabled
      final discoverButton = tester.widget<BedLinkButton>(
        find.widgetWithText(BedLinkButton, 'DISCOVER MATCHING HOSPITALS'),
      );
      expect(discoverButton.onPressed, isNull);

      // Add countable bed (icu_bed)
      container.read(bedRequirementProvider.notifier).addResource('icu_bed');
      await tester.pumpAndSettle();

      // CTA should now be enabled
      final enabledButton = tester.widget<BedLinkButton>(
        find.widgetWithText(BedLinkButton, 'DISCOVER MATCHING HOSPITALS'),
      );
      expect(enabledButton.onPressed, isNotNull);
    });

    testWidgets('Renders cleanly at compact 320dp width without layout overflow', (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      tester.view.physicalSize = const Size(320 * 2.0, 750 * 2.0);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await container.read(sessionProvider.notifier).loginAsAmbulance();
      container.read(patientIntakeProvider.notifier).fillQuickDemoPreset();
      container.read(bedRequirementProvider.notifier).applyPreset('cardiac_emergency');

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const BedLinkApp(),
        ),
      );
      container.read(routerProvider).go('/ambulance/requirements');
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('BED REQUIREMENTS'), findsOneWidget);
      expect(find.text('ACTIVE PATIENT SUMMARY'), findsOneWidget);
      expect(find.text('ACTIVE PATIENT SUMMARY'), findsOneWidget);
    });
  });
}
