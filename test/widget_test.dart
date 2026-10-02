import 'package:bedlink/app/app.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('BedLinkApp launches and renders splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: BedLinkApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('BedLink'), findsWidgets);
    expect(find.text('EMERGENCY HOSPITAL ALLOCATION'), findsOneWidget);
    expect(find.text('PROCEED TO LOGIN'), findsOneWidget);
  });
}
