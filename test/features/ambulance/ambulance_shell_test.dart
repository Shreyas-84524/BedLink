import 'package:bedlink/app/app.dart';
import 'package:bedlink/shared/providers/session_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Ambulance Shell Widget & Responsive Tests', () {
    testWidgets('Renders Ambulance Shell with all workflow step cards', (WidgetTester tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const BedLinkApp(),
        ),
      );
      await tester.pumpAndSettle();

      await container.read(sessionProvider.notifier).loginAsAmbulance();
      await tester.pumpAndSettle();

      expect(find.text('AMBULANCE DISPATCH'), findsOneWidget);
      expect(find.text('START NEW PATIENT INTAKE'), findsOneWidget);
      expect(find.text('Patient Intake & Triage'), findsOneWidget);
      expect(find.text('Bed Need Assessment'), findsOneWidget);
      expect(find.text('Hospital Match Grid'), findsOneWidget);
      expect(find.text('Hold Confirmation'), findsOneWidget);
      await tester.scrollUntilVisible(find.text('En-Route Navigation'), 100.0);
      expect(find.text('En-Route Navigation'), findsOneWidget);
    });

    testWidgets('Renders cleanly at compact 320dp width without overflow', (WidgetTester tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      tester.view.physicalSize = const Size(320 * 2.0, 640 * 2.0);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const BedLinkApp(),
        ),
      );
      await tester.pumpAndSettle();

      await container.read(sessionProvider.notifier).loginAsAmbulance();
      await tester.pumpAndSettle();

      expect(find.text('AMBULANCE DISPATCH'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
