import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:bedlink/core/theme/app_theme.dart';
import 'package:bedlink/features/ambulance/domain/models/clinical_urgency.dart';
import 'package:bedlink/features/ambulance/presentation/providers/intake_provider.dart';
import 'package:bedlink/features/ambulance/presentation/providers/requirement_provider.dart';
import 'package:bedlink/features/matching/presentation/providers/matching_provider.dart';
import 'package:bedlink/features/matching/presentation/providers/selected_hospital_provider.dart';
import 'package:bedlink/features/matching/presentation/screens/hospital_discovery_screen.dart';
import 'package:bedlink/features/matching/presentation/widgets/hospital_match_tile.dart';
import 'package:bedlink/features/matching/presentation/widgets/matching_search_indicator.dart';
import 'package:bedlink/features/matching/presentation/widgets/patient_requirement_summary_bar.dart';
import 'package:bedlink/features/matching/presentation/widgets/primary_hospital_card.dart';

void main() {
  Widget createTestWidget({
    ProviderContainer? container,
    Size surfaceSize = const Size(375, 812),
  }) {
    final router = GoRouter(
      initialLocation: '/ambulance/hospitals',
      routes: [
        GoRoute(
          path: '/ambulance/hospitals',
          builder: (context, state) => const HospitalDiscoveryScreen(),
        ),
        GoRoute(
          path: '/ambulance/requirements',
          builder: (context, state) => const Scaffold(body: Text('Requirements Screen')),
        ),
        GoRoute(
          path: '/ambulance/hold',
          builder: (context, state) => const Scaffold(body: Text('Hold Confirmation Screen')),
        ),
      ],
    );

    return UncontrolledProviderScope(
      container: container ?? ProviderContainer(),
      child: MaterialApp.router(
        theme: AppTheme.lightTheme,
        routerConfig: router,
      ),
    );
  }

  group('Hospital Discovery Screen Widget Tests (Sub-phases 6.1 - 6.8)', () {
    testWidgets('Renders all Phase 6 components: summary bar, primary card, and candidate tiles', (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Preload patient and requirements
      container.read(patientIntakeProvider.notifier).setChiefComplaint('Severe Chest Pain / Acute MI');
      container.read(patientIntakeProvider.notifier).setUrgency(ClinicalUrgency.critical);
      container.read(bedRequirementProvider.notifier).addResource('icu_bed', quantity: 1);
      container.read(bedRequirementProvider.notifier).addResource('ventilator', quantity: 1);
      container.read(bedRequirementProvider.notifier).addResource('cardiac_care');

      await tester.binding.setSurfaceSize(const Size(375, 1200));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(createTestWidget(container: container));
      await tester.pumpAndSettle();

      // Screen Header
      expect(find.text('HOSPITAL MATCHES'), findsOneWidget);
      expect(find.text('Step 3 of 5 • Multi-Criteria Ranking'), findsOneWidget);

      // 6.2 Patient Requirement Summary Bar
      expect(find.byType(PatientRequirementSummaryBar), findsOneWidget);
      expect(find.text('CRITICAL'), findsOneWidget);
      expect(find.text('Severe Chest Pain / Acute MI'), findsOneWidget);

      // 6.3 Primary Recommended Hospital Card (KEM Hospital)
      expect(find.byType(PrimaryHospitalCard), findsOneWidget);
      expect(find.text('King Edward Memorial Hospital (KEM)'), findsOneWidget);
      expect(find.text('#1 TOP RECOMMENDATION'), findsOneWidget);
      expect(find.text('8'), findsOneWidget); // 8 MIN ETA
      expect(find.text('REQUEST 2-MIN BED HOLD'), findsWidgets);

      // 6.7 Secondary Candidates Tiles
      expect(find.byType(HospitalMatchTile), findsNWidgets(4));
      expect(find.text('P.D. Hinduja National Hospital'), findsOneWidget);
      expect(find.text('Lilavati Hospital & Research Centre'), findsOneWidget);
      expect(find.text('Lokmanya Tilak Municipal General Hospital (Sion)'), findsOneWidget);
      expect(find.text('Tata Memorial Hospital'), findsOneWidget);
    });

    testWidgets('Tapping REQUEST 2-MIN BED HOLD selects hospital and navigates to /ambulance/hold', (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.binding.setSurfaceSize(const Size(375, 1000));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(createTestWidget(container: container));
      await tester.pumpAndSettle();

      expect(container.read(selectedHospitalProvider), isNull);

      // Tap on primary card's Request Hold button
      final holdBtn = find.text('REQUEST 2-MIN BED HOLD').first;
      await tester.ensureVisible(holdBtn);
      await tester.tap(holdBtn);
      await tester.pumpAndSettle();

      // Verify selected hospital was recorded in provider
      final selected = container.read(selectedHospitalProvider);
      expect(selected, isNotNull);
      expect(selected?.id, equals('kem_parel'));
      expect(selected?.name, contains('King Edward Memorial Hospital'));

      // Verify navigation to Hold Confirmation
      expect(find.text('Hold Confirmation Screen'), findsOneWidget);
    });

    testWidgets('Tapping EDIT on summary bar navigates back to requirements screen', (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(createTestWidget(container: container));
      await tester.pumpAndSettle();

      final editBtn = find.text('EDIT');
      expect(editBtn, findsOneWidget);
      await tester.tap(editBtn);
      await tester.pumpAndSettle();

      expect(find.text('Requirements Screen'), findsOneWidget);
    });

    testWidgets('Fixture switcher allows switching to 1 Match or 0 Matches (Sub-phase 6.8)', (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.binding.setSurfaceSize(const Size(375, 1000));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(createTestWidget(container: container));
      await tester.pumpAndSettle();

      // Switch to 1 Match
      await tester.tap(find.text('1 Match'));
      await tester.pumpAndSettle();

      expect(find.byType(PrimaryHospitalCard), findsOneWidget);
      expect(find.byType(HospitalMatchTile), findsNothing);

      // Switch to 0 Matches (Empty state)
      await tester.tap(find.text('0 Matches'));
      await tester.pumpAndSettle();

      expect(find.text('NO COMPATIBLE HOSPITALS FOUND'), findsOneWidget);
      expect(find.text('EXPAND SEARCH RADIUS TO 30 KM'), findsOneWidget);
      expect(find.byType(PrimaryHospitalCard), findsNothing);

      // Tap Expand Radius
      await tester.tap(find.text('EXPAND SEARCH RADIUS TO 30 KM'));
      await tester.pumpAndSettle();

      // Restores candidate list and updates radius
      expect(find.byType(PrimaryHospitalCard), findsOneWidget);
      expect(container.read(matchingProvider).searchRadiusKm, equals(30));
    });

    testWidgets('MatchingSearchIndicator displays active searching telemetry (Sub-phase 6.1)', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(
            body: MatchingSearchIndicator(
              radiusKm: 10,
              statusMessage: 'Scanning 10km radius for ICU beds...',
              candidateCount: 3,
            ),
          ),
        ),
      );

      expect(find.text('SEARCHING NEARBY HOSPITALS'), findsOneWidget);
      expect(find.text('Scanning 10km radius for ICU beds...'), findsOneWidget);
      expect(find.text('10 KM RADIUS'), findsOneWidget);
      expect(find.text('3 CANDIDATES FOUND'), findsOneWidget);
    });

    testWidgets('Renders cleanly at compact 320dp width without layout overflow', (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(patientIntakeProvider.notifier).fillQuickDemoPreset();
      container.read(bedRequirementProvider.notifier).addResource('icu_bed', quantity: 2);
      container.read(bedRequirementProvider.notifier).addResource('ventilator', quantity: 1);

      await tester.binding.setSurfaceSize(const Size(320, 1400));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(createTestWidget(container: container));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('HOSPITAL MATCHES'), findsOneWidget);
      expect(find.byType(PrimaryHospitalCard), findsOneWidget);
      expect(find.byType(HospitalMatchTile), findsWidgets);
    });
  });
}
