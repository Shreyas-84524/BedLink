import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bedlink/features/ambulance/presentation/providers/intake_provider.dart';
import 'package:bedlink/features/ambulance/presentation/providers/requirement_provider.dart';
import 'package:bedlink/features/matching/data/mock_hospital_data.dart';
import 'package:bedlink/features/matching/presentation/providers/selected_hospital_provider.dart';
import 'package:bedlink/features/reservation/presentation/providers/hold_timer_provider.dart';
import 'package:bedlink/shared/providers/connectivity_provider.dart';
import 'package:bedlink/shared/providers/session_provider.dart';

void main() {
  setUp(() {
    HoldTimerNotifier.disablePeriodicTickerForTesting = true;
  });

  tearDown(() {
    HoldTimerNotifier.disablePeriodicTickerForTesting = false;
  });

  group('ConnectivityStatus Model Tests (Sub-phase 10.3)', () {
    test('online status properties and indicators', () {
      const status = ConnectivityStatus.online;
      expect(status.isOnline, isTrue);
      expect(status.isOffline, isFalse);
      expect(status.isReconnecting, isFalse);
      expect(status.label, equals('MED-NET LIVE'));
      expect(status.description.isNotEmpty, isTrue);
      expect(status.indicatorColor, isNotNull);
      expect(status.backgroundColor, isNotNull);
      expect(status.borderColor, isNotNull);
    });

    test('offline status properties and indicators', () {
      const status = ConnectivityStatus.offline;
      expect(status.isOnline, isFalse);
      expect(status.isOffline, isTrue);
      expect(status.isReconnecting, isFalse);
      expect(status.label, equals('OFFLINE'));
      expect(status.description.contains('offline mode'), isTrue);
    });

    test('reconnecting status properties and indicators', () {
      const status = ConnectivityStatus.reconnecting;
      expect(status.isOnline, isFalse);
      expect(status.isOffline, isFalse);
      expect(status.isReconnecting, isTrue);
      expect(status.label, equals('RECONNECTING'));
      expect(status.description.contains('Re-establishing'), isTrue);
    });
  });

  group('ConnectivityNotifier & State Preservation Tests (Sub-phase 10.3)', () {
    test('Initial state defaults to online', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final status = container.read(connectivityProvider);
      expect(status, equals(ConnectivityStatus.online));
    });

    test('Transitions correctly through online, offline, and reconnecting states', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(connectivityProvider.notifier);

      notifier.setOffline();
      expect(container.read(connectivityProvider), equals(ConnectivityStatus.offline));

      notifier.setReconnecting();
      expect(container.read(connectivityProvider), equals(ConnectivityStatus.reconnecting));

      notifier.setOnline();
      expect(container.read(connectivityProvider), equals(ConnectivityStatus.online));
    });

    test('cycleNextState cycles in expected deterministic order', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(connectivityProvider.notifier);

      expect(container.read(connectivityProvider), equals(ConnectivityStatus.online));

      notifier.cycleNextState();
      expect(container.read(connectivityProvider), equals(ConnectivityStatus.offline));

      notifier.cycleNextState();
      expect(container.read(connectivityProvider), equals(ConnectivityStatus.reconnecting));

      notifier.cycleNextState();
      expect(container.read(connectivityProvider), equals(ConnectivityStatus.online));
    });

    test('Simulated connectivity transitions strictly preserve workflow and session state', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Setup active workflow state
      await container.read(sessionProvider.notifier).loginAsAmbulance();
      container.read(patientIntakeProvider.notifier).fillQuickDemoPreset();
      container.read(bedRequirementProvider.notifier).applyPreset('cardiac_emergency');
      container.read(selectedHospitalProvider.notifier).selectHospital(MockHospitalData.kemHospital);

      expect(container.read(patientIntakeProvider).patientName.isNotEmpty, isTrue);
      expect(container.read(bedRequirementProvider).selectedRequirements.isNotEmpty, isTrue);
      expect(container.read(selectedHospitalProvider), isNotNull);

      // Simulate network dropping to offline
      container.read(connectivityProvider.notifier).setOffline();
      expect(container.read(connectivityProvider), equals(ConnectivityStatus.offline));

      // Verify all workflow state remains intact!
      expect(container.read(sessionProvider).isAuthenticated, isTrue);
      expect(container.read(patientIntakeProvider).patientName, equals('Ramesh Patil (Cardiac Case)'));
      expect(container.read(bedRequirementProvider).selectedRequirements.containsKey('icu_bed'), isTrue);
      expect(container.read(selectedHospitalProvider)?.id, equals('kem_parel'));

      // Simulate reconnecting
      container.read(connectivityProvider.notifier).setReconnecting();
      expect(container.read(patientIntakeProvider).patientName, equals('Ramesh Patil (Cardiac Case)'));

      // Simulate restored online
      container.read(connectivityProvider.notifier).setOnline();
      expect(container.read(sessionProvider).isAuthenticated, isTrue);
      expect(container.read(selectedHospitalProvider)?.id, equals('kem_parel'));
    });
  });
}
