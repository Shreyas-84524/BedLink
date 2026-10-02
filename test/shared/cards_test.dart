import 'package:bedlink/core/theme/app_theme.dart';
import 'package:bedlink/shared/widgets/cards/bedlink_card.dart';
import 'package:bedlink/shared/widgets/cards/bedlink_metric_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget createTestWidget(Widget child) {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      home: Scaffold(
        body: Center(child: child),
      ),
    );
  }

  group('BedLinkCard & MetricCard Tests', () {
    testWidgets('BedLinkCard renders child content and triggers onTap', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        createTestWidget(
          BedLinkCard(
            variant: BedLinkCardVariant.recommended,
            onTap: () => tapped = true,
            child: const Text('Card Body Content'),
          ),
        ),
      );

      expect(find.text('Card Body Content'), findsOneWidget);
      await tester.tap(find.text('Card Body Content'));
      expect(tapped, true);
    });

    testWidgets('BedLinkMetricCard renders label, value, unit, and icon', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          const BedLinkMetricCard(
            label: 'Road ETA',
            value: '14',
            unit: 'MIN',
            icon: Icons.navigation,
          ),
        ),
      );

      expect(find.text('ROAD ETA'), findsOneWidget);
      expect(find.text('14'), findsOneWidget);
      expect(find.text('MIN'), findsOneWidget);
      expect(find.byIcon(Icons.navigation), findsOneWidget);
    });
  });
}
