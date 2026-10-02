import 'package:bedlink/app/app.dart';
import 'package:bedlink/shared/providers/session_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Hospital Shell Widget & Responsive Tests', () {
    testWidgets('Renders Hospital Shell with capacity snapshot and operational modules', (WidgetTester tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const BedLinkApp(),
        ),
      );
      await tester.pumpAndSettle();

      await container.read(sessionProvider.notifier).loginAsHospital();
      await tester.pumpAndSettle();

      expect(find.text('HOSPITAL TRIAGE DESK'), findsOneWidget);
      expect(find.text('LIVE EMERGENCY CAPACITY SNAPSHOT'), findsOneWidget);
      expect(find.text('ICU BEDS'), findsOneWidget);
      expect(find.text('O2 BEDS'), findsOneWidget);
      expect(find.text('TRAUMA'), findsOneWidget);
      expect(find.text('Resource Inventory & Capacity'), findsOneWidget);
      expect(find.text('Incoming Emergency Requests'), findsOneWidget);
      expect(find.text('Active Holds & Inbound Transit'), findsOneWidget);
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

      await container.read(sessionProvider.notifier).loginAsHospital();
      await tester.pumpAndSettle();

      expect(find.text('HOSPITAL TRIAGE DESK'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
