import 'package:bedlink/app/app.dart';
import 'package:bedlink/app/router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GoRouter Route Integration Tests', () {
    testWidgets('Navigating to /login renders Login screen', (WidgetTester tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const BedLinkApp(),
        ),
      );
      await tester.pumpAndSettle();

      container.read(routerProvider).go('/login');
      await tester.pumpAndSettle();

      expect(find.text('BedLink Login'), findsOneWidget);
      expect(find.text('Select Role & Sign In'), findsOneWidget);
      expect(find.text('Login as Ambulance Crew'), findsOneWidget);
      expect(find.text('Login as Hospital Staff'), findsOneWidget);
    });

    testWidgets('Navigating to /ambulance renders Ambulance Dashboard', (WidgetTester tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const BedLinkApp(),
        ),
      );
      await tester.pumpAndSettle();

      container.read(routerProvider).go('/ambulance');
      await tester.pumpAndSettle();

      expect(find.text('Ambulance Dashboard'), findsOneWidget);
      expect(find.text('Emergency Dispatch Ready'), findsOneWidget);
    });

    testWidgets('Navigating through ambulance sub-routes renders correctly', (WidgetTester tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const BedLinkApp(),
        ),
      );
      await tester.pumpAndSettle();

      // /ambulance/intake
      container.read(routerProvider).go('/ambulance/intake');
      await tester.pumpAndSettle();
      expect(find.text('Patient Intake'), findsOneWidget);

      // /ambulance/requirements
      container.read(routerProvider).go('/ambulance/requirements');
      await tester.pumpAndSettle();
      expect(find.text('Bed Need Assessment'), findsOneWidget);

      // /ambulance/hospitals
      container.read(routerProvider).go('/ambulance/hospitals');
      await tester.pumpAndSettle();
      expect(find.text('Hospital Match Grid'), findsOneWidget);

      // /ambulance/hold
      container.read(routerProvider).go('/ambulance/hold');
      await tester.pumpAndSettle();
      expect(find.text('Hold Confirmation'), findsOneWidget);

      // /ambulance/navigation
      container.read(routerProvider).go('/ambulance/navigation');
      await tester.pumpAndSettle();
      expect(find.text('En Route & Navigation'), findsOneWidget);
    });

    testWidgets('Navigating to /hospital and sub-routes renders correctly', (WidgetTester tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const BedLinkApp(),
        ),
      );
      await tester.pumpAndSettle();

      // /hospital
      container.read(routerProvider).go('/hospital');
      await tester.pumpAndSettle();
      expect(find.text('Hospital Dashboard'), findsOneWidget);

      // /hospital/resources
      container.read(routerProvider).go('/hospital/resources');
      await tester.pumpAndSettle();
      expect(find.text('Resource Inventory'), findsOneWidget);

      // /hospital/requests
      container.read(routerProvider).go('/hospital/requests');
      await tester.pumpAndSettle();
      expect(find.text('Incoming Emergency Requests'), findsOneWidget);

      // /hospital/holds
      container.read(routerProvider).go('/hospital/holds');
      await tester.pumpAndSettle();
      expect(find.text('Active Holds & Reservations'), findsOneWidget);
    });

    testWidgets('Navigating to invalid route triggers error builder', (WidgetTester tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const BedLinkApp(),
        ),
      );
      await tester.pumpAndSettle();

      container.read(routerProvider).go('/invalid-route-xyz');
      await tester.pumpAndSettle();

      expect(find.text('Navigation Error'), findsOneWidget);
      expect(find.text('Return to Home'), findsOneWidget);
    });
  });
}
