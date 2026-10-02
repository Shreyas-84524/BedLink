import 'package:bedlink/core/theme/app_theme.dart';
import 'package:bedlink/shared/widgets/buttons/bedlink_button.dart';
import 'package:bedlink/shared/widgets/buttons/bedlink_icon_button.dart';
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

  group('BedLinkButton Widget Tests', () {
    testWidgets('Renders label and triggers onPressed when tapped', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        createTestWidget(
          BedLinkButton(
            label: 'Confirm Action',
            onPressed: () => tapped = true,
          ),
        ),
      );

      expect(find.text('Confirm Action'), findsOneWidget);
      await tester.tap(find.text('Confirm Action'));
      expect(tapped, true);
    });

    testWidgets('Disabled button does not trigger onPressed', (tester) async {
      const tapped = false;
      await tester.pumpWidget(
        createTestWidget(
          const BedLinkButton(
            label: 'Disabled Action',
            onPressed: null,
          ),
        ),
      );

      await tester.tap(find.text('Disabled Action'));
      expect(tapped, false);
    });

    testWidgets('Loading state renders CircularProgressIndicator and ignores taps', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        createTestWidget(
          BedLinkButton(
            label: 'Loading Action',
            isLoading: true,
            onPressed: () => tapped = true,
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Loading Action'), findsNothing);
      await tester.tap(find.byType(CircularProgressIndicator));
      expect(tapped, false);
    });

    testWidgets('Renders icon when provided', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          BedLinkButton(
            label: 'Search Action',
            icon: Icons.search,
            onPressed: () {},
          ),
        ),
      );

      expect(find.byIcon(Icons.search), findsOneWidget);
      expect(find.text('Search Action'), findsOneWidget);
    });
  });

  group('BedLinkIconButton Widget Tests', () {
    testWidgets('Renders icon and satisfies >=48dp tap target size', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        createTestWidget(
          BedLinkIconButton(
            icon: Icons.refresh,
            tooltip: 'Refresh',
            onPressed: () => tapped = true,
          ),
        ),
      );

      final size = tester.getSize(find.byType(BedLinkIconButton));
      expect(size.width, greaterThanOrEqualTo(48.0));
      expect(size.height, greaterThanOrEqualTo(48.0));

      await tester.tap(find.byIcon(Icons.refresh));
      expect(tapped, true);
    });
  });
}
