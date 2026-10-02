import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bedlink/shared/providers/connectivity_provider.dart';
import 'package:bedlink/shared/widgets/chrome/connectivity_banner.dart';
import 'package:bedlink/shared/widgets/chrome/med_net_live_badge.dart';
import 'package:bedlink/shared/widgets/demo/dev_fixture_center.dart';
import 'package:bedlink/shared/widgets/empty/bedlink_empty_state.dart';
import 'package:bedlink/shared/widgets/errors/bedlink_error_state.dart';
import 'package:bedlink/shared/widgets/loading/bedlink_loading_indicator.dart';
import 'package:bedlink/shared/widgets/loading/bedlink_skeleton_card.dart';

void main() {
  group('Resilience Shared Components Widget Tests (Sub-phases 10.1, 10.2, 10.3, 10.4)', () {
    testWidgets('BedLinkLoadingIndicator renders clinical status and subtitle', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: BedLinkLoadingIndicator(
              statusText: 'SEARCHING MUMBAI ER BEDS...',
              subtitle: 'Querying 15km trauma radius',
              isCard: true,
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('SEARCHING MUMBAI ER BEDS...'), findsOneWidget);
      expect(find.text('Querying 15km trauma radius'), findsOneWidget);
    });

    testWidgets('BedLinkSkeletonCard renders placeholder lines without error', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: BedLinkSkeletonCard(lines: 3),
          ),
        ),
      );

      expect(find.byType(BedLinkSkeletonCard), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('BedLinkEmptyState renders title, description, and triggers action', (tester) async {
      bool actionTriggered = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BedLinkEmptyState(
              icon: Icons.inbox_rounded,
              title: 'NO ACTIVE RESERVATIONS',
              description: 'All hospital bed holds are currently completed.',
              actionLabel: 'FIND HOSPITAL',
              onAction: () {
                actionTriggered = true;
              },
            ),
          ),
        ),
      );

      expect(find.text('NO ACTIVE RESERVATIONS'), findsOneWidget);
      expect(find.text('All hospital bed holds are currently completed.'), findsOneWidget);
      expect(find.text('FIND HOSPITAL'), findsOneWidget);

      await tester.tap(find.text('FIND HOSPITAL'));
      await tester.pump();
      expect(actionTriggered, isTrue);
    });

    testWidgets('BedLinkErrorState renders error details and handles recovery buttons', (tester) async {
      bool retryTriggered = false;
      bool backTriggered = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BedLinkErrorState(
              title: 'HOSPITAL ROUTING FAILED',
              message: 'Unable to calculate matrix routing to destination.',
              primaryActionLabel: 'RETRY ROUTE',
              onPrimaryAction: () => retryTriggered = true,
              secondaryActionLabel: 'GO BACK',
              onSecondaryAction: () => backTriggered = true,
              isCritical: true,
            ),
          ),
        ),
      );

      expect(find.text('HOSPITAL ROUTING FAILED'), findsOneWidget);
      expect(find.text('Unable to calculate matrix routing to destination.'), findsOneWidget);
      expect(find.text('RETRY ROUTE'), findsOneWidget);
      expect(find.text('GO BACK'), findsOneWidget);

      await tester.tap(find.text('RETRY ROUTE'));
      await tester.pump();
      expect(retryTriggered, isTrue);

      await tester.tap(find.text('GO BACK'));
      await tester.pump();
      expect(backTriggered, isTrue);
    });

    testWidgets('ConnectivityBanner updates based on connectivity state and handles reconnect action', (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: Scaffold(
              body: ConnectivityBanner(),
            ),
          ),
        ),
      );

      // 1. Online: banner is shrink (hidden)
      expect(find.textContaining('OFFLINE MODE'), findsNothing);

      // 2. Offline: banner appears with Reconnect action
      container.read(connectivityProvider.notifier).setOffline();
      await tester.pump();

      expect(find.text('OFFLINE MODE • CACHED DATA ACTIVE'), findsOneWidget);
      expect(find.text('RECONNECT'), findsOneWidget);

      // 3. Tapping RECONNECT transitions to reconnecting
      await tester.tap(find.text('RECONNECT'));
      await tester.pump();

      expect(container.read(connectivityProvider), equals(ConnectivityStatus.reconnecting));
      expect(find.text('RECONNECTING TO MED-NET...'), findsOneWidget);
      expect(find.text('RESTORE'), findsOneWidget);

      // 4. Tapping RESTORE sets back to online
      await tester.tap(find.text('RESTORE'));
      await tester.pump();

      expect(container.read(connectivityProvider), equals(ConnectivityStatus.online));
      expect(find.textContaining('RECONNECTING TO MED-NET'), findsNothing);
    });

    testWidgets('MedNetLiveBadge reflects active connectivity state and cycles on tap', (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: Scaffold(
              body: MedNetLiveBadge(),
            ),
          ),
        ),
      );

      expect(find.text('MED-NET LIVE'), findsOneWidget);

      // Tap badge to cycle to offline
      await tester.tap(find.byType(MedNetLiveBadge));
      await tester.pump();

      expect(container.read(connectivityProvider), equals(ConnectivityStatus.offline));
      expect(find.text('OFFLINE'), findsOneWidget);

      // Tap badge to cycle to reconnecting
      await tester.tap(find.byType(MedNetLiveBadge));
      await tester.pump();

      expect(container.read(connectivityProvider), equals(ConnectivityStatus.reconnecting));
      expect(find.text('RECONNECTING'), findsOneWidget);
    });

    testWidgets('DevFixtureCenter renders on 320dp width without overflow', (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      tester.view.physicalSize = const Size(320.0, 800.0);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: Scaffold(
              body: DevFixtureCenter(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('DEV FIXTURE CENTER'), findsOneWidget);
      expect(find.text('ONLINE (MED-NET)'), findsOneWidget);
      expect(find.text('RESET EMERGENCY WORKFLOW'), findsOneWidget);
    });
  });
}
