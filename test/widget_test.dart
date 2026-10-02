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

    expect(find.text('BedLink'), findsOneWidget);
    expect(find.text('Right bed. Right hospital. Right now.'), findsOneWidget);
    expect(find.text('Enter Application'), findsOneWidget);
  });
}
