import 'package:bedlink/app/app.dart';
import 'package:bedlink/app/router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DesignSystemScreen Showcase & Responsive Tests', () {
    testWidgets('Renders all design system sections at standard 375dp mobile width', (tester) async {
      tester.view.physicalSize = const Size(375 * 3.0, 812 * 3.0);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const BedLinkApp(),
        ),
      );
      await tester.pumpAndSettle();

      container.read(routerProvider).go('/design-system');
      await tester.pumpAndSettle();

      expect(find.text('Design System Catalog'), findsOneWidget);
      expect(find.text('01. BRAND & CHROME COMPONENTS'), findsOneWidget);
      expect(find.text('02. COLOR TOKENS & SURFACE PALETTE'), findsOneWidget);
      expect(find.text('03. TYPOGRAPHY & TABULAR FIGURES'), findsOneWidget);

      await tester.scrollUntilVisible(
        find.text('04. ACTION BUTTONS SYSTEM'),
        150.0,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('04. ACTION BUTTONS SYSTEM'), findsOneWidget);

      await tester.scrollUntilVisible(
        find.text('05. CARDS & CLINICAL SURFACES'),
        150.0,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('05. CARDS & CLINICAL SURFACES'), findsOneWidget);

      await tester.scrollUntilVisible(
        find.text('06. STATUS BADGES & TELEMETRY CHIPS'),
        150.0,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('06. STATUS BADGES & TELEMETRY CHIPS'), findsOneWidget);

      await tester.scrollUntilVisible(
        find.text('07. RAPID INVENTORY COUNTER & FORM CONTROLS'),
        150.0,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('07. RAPID INVENTORY COUNTER & FORM CONTROLS'), findsOneWidget);

      await tester.scrollUntilVisible(
        find.text('08. OPTION CARDS & CLINICAL REQUIREMENT CHIPS'),
        150.0,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('08. OPTION CARDS & CLINICAL REQUIREMENT CHIPS'), findsOneWidget);
    });

    testWidgets('Renders cleanly at compact 320dp width without layout overflow', (tester) async {
      tester.view.physicalSize = const Size(320 * 2.0, 568 * 2.0);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const BedLinkApp(),
        ),
      );
      await tester.pumpAndSettle();

      container.read(routerProvider).go('/design-system');
      await tester.pumpAndSettle();

      // Scroll through the entire catalog to ensure no RenderFlex overflow
      await tester.drag(find.byType(ListView), const Offset(0, -400));
      await tester.pumpAndSettle();
      await tester.drag(find.byType(ListView), const Offset(0, -400));
      await tester.pumpAndSettle();
      await tester.drag(find.byType(ListView), const Offset(0, -400));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });
}
