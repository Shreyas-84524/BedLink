import 'package:bedlink/core/theme/app_theme.dart';
import 'package:bedlink/core/theme/semantic_tokens.dart';
import 'package:bedlink/shared/widgets/badges/bedlink_badge.dart';
import 'package:bedlink/shared/widgets/badges/status_badges.dart';
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

  group('Status Badges & Chips Tests', () {
    testWidgets('BedLinkBadge renders label in uppercase', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          const BedLinkBadge(label: 'Custom Status'),
        ),
      );

      expect(find.text('CUSTOM STATUS'), findsOneWidget);
    });

    testWidgets('FreshnessBadge renders formatted age label', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          FreshnessBadge.fromMinutes(3),
        ),
      );

      expect(find.text('UPDATED 3M AGO'), findsOneWidget);
    });

    testWidgets('HospitalLoadBadge renders occupancy percentage', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          HospitalLoadBadge.fromOccupancy(0.85),
        ),
      );

      expect(find.text('85% OCCUPIED'), findsOneWidget);
    });

    testWidgets('EmergencyUrgencyBadge renders acuity tier', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          const EmergencyUrgencyBadge(acuity: EmergencyAcuity.critical),
        ),
      );

      expect(find.text('CRITICAL • TIER 1'), findsOneWidget);
    });

    testWidgets('AvailabilityBadge renders bed count when available or divert when 0', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          AvailabilityBadge.fromCount(4),
        ),
      );
      expect(find.text('4 AVAILABLE'), findsOneWidget);

      await tester.pumpWidget(
        createTestWidget(
          AvailabilityBadge.fromCount(0),
        ),
      );
      expect(find.text('0 BEDS • DIVERT'), findsOneWidget);
    });

    testWidgets('ConnectivityBadge renders MED-NET LIVE', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          const ConnectivityBadge(state: ConnectivityState.live),
        ),
      );

      expect(find.text('MED-NET LIVE'), findsOneWidget);
    });
  });
}
