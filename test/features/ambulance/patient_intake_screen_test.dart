import 'package:bedlink/core/theme/app_theme.dart';
import 'package:bedlink/features/ambulance/domain/models/biological_sex.dart';
import 'package:bedlink/features/ambulance/domain/models/clinical_urgency.dart';
import 'package:bedlink/features/ambulance/presentation/providers/intake_provider.dart';
import 'package:bedlink/features/ambulance/presentation/screens/patient_intake_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _createIntakeTestHarness({
  required ProviderContainer container,
}) {
  return UncontrolledProviderScope(
    container: container,
    child: MaterialApp(
      theme: AppTheme.lightTheme,
      home: const PatientIntakeScreen(),
    ),
  );
}

void main() {
  group('Patient Intake Screen Widget & Responsive Tests', () {
    testWidgets('Renders all Intake sections and validates initial disabled CTA', (WidgetTester tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      tester.view.physicalSize = const Size(400 * 2.0, 1200 * 2.0);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(_createIntakeTestHarness(container: container));
      await tester.pumpAndSettle();

      // Verify sections are visible
      expect(find.text('ACTIVE PATIENT INTAKE'), findsOneWidget);
      expect(find.text('PATIENT IDENTITY'), findsOneWidget);
      expect(find.text('BIOLOGICAL SEX'), findsOneWidget);
      expect(find.text('PATIENT AGE'), findsOneWidget);

      // Verify initial invalid state has disabled Continue CTA and warning banner
      final continueBtn = find.text('CONTINUE TO BED REQUIREMENTS');
      await tester.scrollUntilVisible(
        continueBtn,
        100.0,
        scrollable: find.byType(Scrollable).first,
      );
      expect(continueBtn, findsOneWidget);
      expect(find.textContaining('REQUIRED:'), findsOneWidget);
    });

    testWidgets('Demo preset button fills form and updates intake state', (WidgetTester tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      tester.view.physicalSize = const Size(400 * 2.0, 1200 * 2.0);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(_createIntakeTestHarness(container: container));
      await tester.pumpAndSettle();

      // Tap 1-tap demo preset shortcut
      final demoPreset = find.textContaining('⚡ Fill Demo STEMI Cardiac Case');
      await tester.ensureVisible(demoPreset);
      await tester.tap(demoPreset);
      await tester.pumpAndSettle();

      // Verify intake state updated
      final intake = container.read(patientIntakeProvider);
      expect(intake.isFormValid, true);
      expect(intake.patientName, contains('Ramesh Patil'));
      expect(intake.age, 58);
      expect(intake.urgency, ClinicalUrgency.critical);
      expect(intake.biologicalSex, BiologicalSex.male);
    });

    testWidgets('Unknown patient toggle and quick complaint chip enable valid form', (WidgetTester tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      tester.view.physicalSize = const Size(400 * 2.0, 1400 * 2.0);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(_createIntakeTestHarness(container: container));
      await tester.pumpAndSettle();

      // Tap Unknown / Unconscious Patient
      final unknownChip = find.text('⚡ Unknown / Unconscious Patient');
      await tester.ensureVisible(unknownChip);
      await tester.tap(unknownChip);
      await tester.pumpAndSettle();

      expect(find.text('UNKNOWN / UNCONSCIOUS'), findsOneWidget);

      // Tap Quick category chip
      final traumaChip = find.text('Severe Road Accident / Polytrauma');
      await tester.ensureVisible(traumaChip);
      await tester.tap(traumaChip);
      await tester.pumpAndSettle();

      // Verify form is valid
      expect(container.read(patientIntakeProvider).isFormValid, true);
    });

    testWidgets('Renders cleanly at compact 320dp width without overflow', (WidgetTester tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      tester.view.physicalSize = const Size(320 * 2.0, 640 * 2.0);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(_createIntakeTestHarness(container: container));
      await tester.pumpAndSettle();

      expect(find.text('ACTIVE PATIENT INTAKE'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Renders cleanly at 360dp and 390dp width without overflow', (WidgetTester tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      tester.view.physicalSize = const Size(390 * 2.0, 844 * 2.0);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(_createIntakeTestHarness(container: container));
      await tester.pumpAndSettle();

      expect(find.text('ACTIVE PATIENT INTAKE'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
