import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bedlink/app/app.dart';
import 'package:bedlink/app/router.dart';
import 'package:bedlink/features/reservation/presentation/providers/hold_timer_provider.dart';
import 'package:bedlink/shared/providers/session_provider.dart';

void main() {
  setUp(() {
    HoldTimerNotifier.disablePeriodicTickerForTesting = true;
  });

  tearDown(() {
    HoldTimerNotifier.disablePeriodicTickerForTesting = false;
  });

  group('Routing Recovery & Role Guard Protection Tests (Sub-phases 10.4, 10.7)', () {
    testWidgets('Unauthenticated user cannot access /ambulance and is redirected to /login', (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const BedLinkApp(),
        ),
      );
      await tester.pumpAndSettle();

      // Attempt navigating directly to ambulance root while unauthenticated
      container.read(routerProvider).go('/ambulance');
      await tester.pumpAndSettle();

      expect(
        container.read(routerProvider).routerDelegate.currentConfiguration.uri.toString(),
        equals('/login'),
      );
    });

    testWidgets('Unauthenticated user cannot access /hospital and is redirected to /login', (tester) async {
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

      expect(
        container.read(routerProvider).routerDelegate.currentConfiguration.uri.toString(),
        equals('/login'),
      );
    });

    testWidgets('Ambulance crew cannot access /hospital and is redirected back to /ambulance', (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await container.read(sessionProvider.notifier).loginAsAmbulance();

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const BedLinkApp(),
        ),
      );
      await tester.pumpAndSettle();

      container.read(routerProvider).go('/hospital');
      await tester.pumpAndSettle();

      expect(
        container.read(routerProvider).routerDelegate.currentConfiguration.uri.toString(),
        equals('/ambulance'),
      );
    });

    testWidgets('Hospital staff cannot access /ambulance and is redirected back to /hospital', (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await container.read(sessionProvider.notifier).loginAsHospital();

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const BedLinkApp(),
        ),
      );
      await tester.pumpAndSettle();

      container.read(routerProvider).go('/ambulance');
      await tester.pumpAndSettle();

      expect(
        container.read(routerProvider).routerDelegate.currentConfiguration.uri.toString(),
        equals('/hospital'),
      );
    });

    testWidgets('Unknown route safely renders NotFoundScreen', (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const BedLinkApp(),
        ),
      );
      await tester.pumpAndSettle();

      container.read(routerProvider).go('/non-existent-route-xyz');
      await tester.pumpAndSettle();

      expect(find.text('ROUTE NOT FOUND'), findsOneWidget);
    });

    testWidgets('Access denied screen renders properly', (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const BedLinkApp(),
        ),
      );
      await tester.pumpAndSettle();

      container.read(routerProvider).go('/access-denied');
      await tester.pumpAndSettle();

      expect(find.text('ACCESS RESTRICTED'), findsOneWidget);
    });

    testWidgets('Navigation without selected destination shows recovery state with Discovery CTA', (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await container.read(sessionProvider.notifier).loginAsAmbulance();

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const BedLinkApp(),
        ),
      );
      await tester.pumpAndSettle();

      container.read(routerProvider).go('/ambulance/navigation');
      await tester.pumpAndSettle();

      expect(find.text('NO ACTIVE DESTINATION SELECTED'), findsOneWidget);
      expect(find.text('GO TO HOSPITAL DISCOVERY'), findsOneWidget);
    });

    testWidgets('Hold without selected hospital shows recovery state with Matches CTA', (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await container.read(sessionProvider.notifier).loginAsAmbulance();

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const BedLinkApp(),
        ),
      );
      await tester.pumpAndSettle();

      container.read(routerProvider).go('/ambulance/hold');
      await tester.pumpAndSettle();

      expect(find.text('NO HOSPITAL SELECTED'), findsOneWidget);
      expect(find.text('BACK TO HOSPITAL MATCHES'), findsOneWidget);
    });
  });
}
