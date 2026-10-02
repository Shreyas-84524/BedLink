import 'package:bedlink/core/theme/app_theme.dart';
import 'package:bedlink/shared/widgets/inputs/bedlink_chips.dart';
import 'package:bedlink/shared/widgets/inputs/bedlink_counter_control.dart';
import 'package:bedlink/shared/widgets/inputs/bedlink_option_card.dart';
import 'package:bedlink/shared/widgets/inputs/bedlink_search_field.dart';
import 'package:bedlink/shared/widgets/inputs/bedlink_segmented_selector.dart';
import 'package:bedlink/shared/widgets/inputs/bedlink_text_field.dart';
import 'package:bedlink/shared/widgets/inputs/bedlink_validation_message.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget createTestWidget(Widget child) {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      home: Scaffold(
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: child,
        ),
      ),
    );
  }

  group('Form and Interaction Component Tests', () {
    testWidgets('BedLinkTextField handles user input and displays label', (tester) async {
      String changed = '';
      await tester.pumpWidget(
        createTestWidget(
          BedLinkTextField(
            label: 'Patient ID',
            hint: 'Enter ID',
            onChanged: (val) => changed = val,
          ),
        ),
      );

      expect(find.text('Patient ID'), findsOneWidget);
      await tester.enterText(find.byType(TextFormField), 'TAG-901');
      expect(changed, 'TAG-901');
    });

    testWidgets('BedLinkSearchField enters text and clears when cancel tapped', (tester) async {
      String searched = '';
      bool cleared = false;
      await tester.pumpWidget(
        createTestWidget(
          BedLinkSearchField(
            onChanged: (val) => searched = val,
            onClear: () => cleared = true,
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'Ventilator');
      await tester.pumpAndSettle();
      expect(searched, 'Ventilator');
      expect(find.byIcon(Icons.cancel_rounded), findsOneWidget);

      await tester.tap(find.byIcon(Icons.cancel_rounded));
      await tester.pumpAndSettle();
      expect(cleared, true);
    });

    testWidgets('BedLinkSegmentedSelector updates selected value on tap', (tester) async {
      int selected = 0;
      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            return createTestWidget(
              BedLinkSegmentedSelector<int>(
                options: const [
                  BedLinkSegmentOption(value: 0, label: 'Option A'),
                  BedLinkSegmentOption(value: 1, label: 'Option B'),
                ],
                selectedValue: selected,
                onChanged: (val) => setState(() => selected = val),
              ),
            );
          },
        ),
      );

      expect(find.text('Option A'), findsOneWidget);
      expect(find.text('Option B'), findsOneWidget);

      await tester.tap(find.text('Option B'));
      await tester.pumpAndSettle();
      expect(selected, 1);
    });

    testWidgets('BedLinkCounterControl increments and decrements within bounds', (tester) async {
      int count = 2;
      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            return createTestWidget(
              BedLinkCounterControl(
                value: count,
                min: 0,
                max: 5,
                onChanged: (val) => setState(() => count = val),
              ),
            );
          },
        ),
      );

      expect(find.text('02'), findsOneWidget);

      // Increment (+)
      await tester.tap(find.byIcon(Icons.add_rounded));
      await tester.pumpAndSettle();
      expect(count, 3);
      expect(find.text('03'), findsOneWidget);

      // Decrement (-)
      await tester.tap(find.byIcon(Icons.remove_rounded));
      await tester.pumpAndSettle();
      expect(count, 2);
    });

    testWidgets('BedLinkOptionCard handles tap and selection indicator', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        createTestWidget(
          BedLinkOptionCard(
            title: 'Critical Tier',
            subtitle: 'Immediate resuscitation',
            isSelected: true,
            onTap: () => tapped = true,
          ),
        ),
      );

      expect(find.text('Critical Tier'), findsOneWidget);
      expect(find.byIcon(Icons.check), findsOneWidget);

      await tester.tap(find.text('Critical Tier'));
      expect(tapped, true);
    });

    testWidgets('BedLinkRequirementChip and QuickAddChip render correctly', (tester) async {
      bool removed = false;
      bool quickAdded = false;

      await tester.pumpWidget(
        createTestWidget(
          Column(
            children: [
              BedLinkRequirementChip(
                label: 'ICU Bed',
                quantity: 2,
                onRemove: () => removed = true,
              ),
              BedLinkQuickAddChip(
                label: 'Oxygen Bed',
                onTap: () => quickAdded = true,
              ),
            ],
          ),
        ),
      );

      expect(find.text('ICU Bed'), findsOneWidget);
      expect(find.text('2x'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.close_rounded));
      expect(removed, true);

      await tester.tap(find.text('Oxygen Bed'));
      expect(quickAdded, true);
    });

    testWidgets('BedLinkValidationMessage displays message and optional action', (tester) async {
      bool actionTriggered = false;
      await tester.pumpWidget(
        createTestWidget(
          BedLinkValidationMessage(
            message: 'Please select at least one bed requirement.',
            severity: ValidationSeverity.error,
            actionLabel: 'Review',
            onAction: () => actionTriggered = true,
          ),
        ),
      );

      expect(find.text('Please select at least one bed requirement.'), findsOneWidget);
      expect(find.text('Review'), findsOneWidget);

      await tester.tap(find.text('Review'));
      expect(actionTriggered, true);
    });
  });
}
