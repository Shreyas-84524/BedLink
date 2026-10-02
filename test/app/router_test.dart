import 'package:bedlink/app/app.dart';
import 'package:bedlink/app/router.dart';
import 'package:bedlink/shared/providers/session_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GoRouter Role-Based Route & Guard Integration Tests', () {
    testWidgets('Unauthenticated user navigating to /login renders LoginScreen', (WidgetTester tester) async {
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

      expect(find.text('EMERGENCY NETWORK ACCESS'), findsOneWidget);
      expect(find.text('SELECT ROLE'), findsOneWidget);
      expect(find.text('AUTHENTICATE AS AMBULANCE'), findsOneWidget);
    });

    testWidgets('Unauthenticated user navigating to protected /ambulance is redirected to /login', (WidgetTester tester) async {
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

      // Must be redirected to /login
      expect(find.text('EMERGENCY NETWORK ACCESS'), findsOneWidget);
      expect(find.text('AMBULANCE DISPATCH'), findsNothing);
    });

    testWidgets('Unauthenticated user navigating to protected /hospital is redirected to /login', (WidgetTester tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const BedLinkApp(),
        ),
      );
      await tester.pumpAndSettle();

      container.read(routerProvider).go('/hospital');
      await tester.pumpAndSettle();

      // Must be redirected to /login
      expect(find.text('EMERGENCY NETWORK ACCESS'), findsOneWidget);
      expect(find.text('HOSPITAL TRIAGE DESK'), findsNothing);
    });

    testWidgets('Ambulance Crew session accesses /ambulance and is blocked from /hospital', (WidgetTester tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const BedLinkApp(),
        ),
      );
      await tester.pumpAndSettle();

      // Authenticate as Ambulance Crew
      await container.read(sessionProvider.notifier).loginAsAmbulance();
      await tester.pumpAndSettle();

      container.read(routerProvider).go('/ambulance');
      await tester.pumpAndSettle();

      expect(find.text('AMBULANCE DISPATCH'), findsOneWidget);
      expect(find.text('START NEW PATIENT INTAKE'), findsOneWidget);

      // Attempt navigating to hospital route
      container.read(routerProvider).go('/hospital');
      await tester.pumpAndSettle();

      // Guard redirects back to ambulance
      expect(find.text('AMBULANCE DISPATCH'), findsOneWidget);
      expect(find.text('HOSPITAL TRIAGE DESK'), findsNothing);
    });

    testWidgets('Hospital Staff session accesses /hospital and is blocked from /ambulance', (WidgetTester tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const BedLinkApp(),
        ),
      );
      await tester.pumpAndSettle();

      // Authenticate as Hospital Staff
      await container.read(sessionProvider.notifier).loginAsHospital();
      await tester.pumpAndSettle();

      container.read(routerProvider).go('/hospital');
      await tester.pumpAndSettle();

      expect(find.text('HOSPITAL TRIAGE DESK'), findsOneWidget);
      expect(find.text('LIVE EMERGENCY CAPACITY SNAPSHOT'), findsOneWidget);

      // Attempt navigating to ambulance route
      container.read(routerProvider).go('/ambulance');
      await tester.pumpAndSettle();

      // Guard redirects back to hospital
      expect(find.text('HOSPITAL TRIAGE DESK'), findsOneWidget);
      expect(find.text('AMBULANCE DISPATCH'), findsNothing);
    });

    testWidgets('Ambulance sub-routes render with workflow steps for crew', (WidgetTester tester) async {
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

      // /ambulance/intake
      container.read(routerProvider).go('/ambulance/intake');
      await tester.pumpAndSettle();
      expect(find.text('PATIENT INTAKE'), findsOneWidget);

      // /ambulance/requirements
      container.read(routerProvider).go('/ambulance/requirements');
      await tester.pumpAndSettle();
      expect(find.text('BED REQUIREMENTS'), findsOneWidget);

      // /ambulance/hospitals
      container.read(routerProvider).go('/ambulance/hospitals');
      await tester.pumpAndSettle();
      expect(find.text('HOSPITAL MATCHES'), findsOneWidget);

      // /ambulance/hold
      container.read(routerProvider).go('/ambulance/hold');
      await tester.pumpAndSettle();
      expect(find.text('HOLD CONFIRMATION'), findsOneWidget);

      // /ambulance/navigation
      container.read(routerProvider).go('/ambulance/navigation');
      await tester.pumpAndSettle();
      expect(find.text('TRANSIT NAVIGATION'), findsOneWidget);
    });

    testWidgets('Hospital sub-routes render with modules for hospital staff', (WidgetTester tester) async {
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

      // /hospital/resources
      container.read(routerProvider).go('/hospital/resources');
      await tester.pumpAndSettle();
      expect(find.text('RESOURCE INVENTORY'), findsOneWidget);

      // /hospital/requests
      container.read(routerProvider).go('/hospital/requests');
      await tester.pumpAndSettle();
      expect(find.text('INCOMING REQUESTS'), findsOneWidget);

      // /hospital/holds
      container.read(routerProvider).go('/hospital/holds');
      await tester.pumpAndSettle();
      expect(find.text('ACTIVE HOLDS'), findsOneWidget);
    });

    testWidgets('Navigating to invalid route renders NotFoundScreen', (WidgetTester tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const BedLinkApp(),
        ),
      );
      await tester.pumpAndSettle();

      container.read(routerProvider).go('/invalid-dispatch-path');
      await tester.pumpAndSettle();

      expect(find.text('ROUTE NOT FOUND'), findsOneWidget);
      expect(find.text('Error Code: 404_ROUTE_UNKNOWN'), findsOneWidget);
    });
  });
}
