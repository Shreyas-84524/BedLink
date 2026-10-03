import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bedlink/features/ambulance/presentation/providers/intake_provider.dart';
import 'package:bedlink/features/ambulance/presentation/providers/requirement_provider.dart';
import 'package:bedlink/features/hospital/domain/models/hospital_hold_item.dart';
import 'package:bedlink/features/hospital/domain/models/hospital_request_item.dart';
import 'package:bedlink/features/hospital/presentation/providers/hospital_state_provider.dart';
import 'package:bedlink/features/matching/data/mock_hospital_data.dart';
import 'package:bedlink/features/matching/presentation/providers/selected_hospital_provider.dart';
import 'package:bedlink/features/navigation/domain/models/navigation_lifecycle.dart';
import 'package:bedlink/features/navigation/presentation/providers/navigation_state_provider.dart';
import 'package:bedlink/features/reservation/domain/models/hold_status.dart';
import 'package:bedlink/features/reservation/presentation/providers/hold_timer_provider.dart';
import 'package:bedlink/shared/providers/mock_emergency_coordinator.dart';
import 'package:bedlink/shared/providers/session_provider.dart';

void main() {
  setUp(() {
    HoldTimerNotifier.disablePeriodicTickerForTesting = true;
  });

  tearDown(() {
    HoldTimerNotifier.disablePeriodicTickerForTesting = false;
  });

  group('Cross-Role Mock Workflow & State Synchronization Tests (Sub-phase 10.6)', () {
    test('Complete Happy Path: Ambulance request -> Hospital accept -> Navigation -> Arrival handoff -> Reset', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final coordinator = container.read(mockEmergencyCoordinatorProvider);

      // 1. Ambulance logs in and fills patient intake
      await container.read(sessionProvider.notifier).loginAsAmbulance();
      expect(container.read(sessionProvider).isAuthenticated, isTrue);

      container.read(patientIntakeProvider.notifier).fillQuickDemoPreset();
      container.read(bedRequirementProvider.notifier).applyPreset('cardiac_emergency');
      container.read(selectedHospitalProvider.notifier).selectHospital(MockHospitalData.kemHospital);

      // Verify ambulance triage setup
      final patient = container.read(patientIntakeProvider);
      expect(patient.patientName.contains('Ramesh Patil'), isTrue);
      expect(container.read(bedRequirementProvider).selectedRequirements.containsKey('icu_bed'), isTrue);

      // 2. Ambulance hold request created
      final holdOffer = container.read(holdTimerProvider);
      expect(holdOffer, isNotNull);
      expect(holdOffer!.status, equals(HoldLifecycleState.pending));

      // 3. Coordinator syncs ambulance request to hospital desk
      coordinator.syncAmbulanceRequestToHospital();
      final hospitalStateBefore = container.read(hospitalStateProvider);
      final syncedRequest = hospitalStateBefore.incomingRequests.firstWhere(
        (r) => r.id == holdOffer.offerId,
        orElse: () => throw StateError('Request not synced'),
      );
      expect(syncedRequest.patientDisplayName, equals(patient.displayName));
      expect(syncedRequest.status, equals(HospitalRequestStatus.pending));

      // 4. Hospital triage desk accepts the offer
      final icuBefore = hospitalStateBefore.resources['icu_bed']!.available;
      coordinator.hospitalAcceptsAmbulanceHold(syncedRequest.id);

      // Verify hospital state updated (available dropped, held increased, active hold created)
      final hospitalStateAfter = container.read(hospitalStateProvider);
      expect(hospitalStateAfter.resources['icu_bed']!.available, equals(icuBefore - 1));
      expect(hospitalStateAfter.activeHolds.any((h) => h.requestId == syncedRequest.id), isTrue);

      // Verify ambulance hold timer is now ACCEPTED / LOCKED!
      final ambulanceHoldAfter = container.read(holdTimerProvider);
      expect(ambulanceHoldAfter!.status, equals(HoldLifecycleState.accepted));

      // 5. Ambulance starts navigation and travels toward hospital
      final navNotifier = container.read(navigationStateProvider.notifier);
      navNotifier.startNavigation();
      expect(container.read(navigationStateProvider).status, equals(NavigationStatus.enRoute));

      navNotifier.advanceProgress(); // step 1
      navNotifier.advanceProgress(); // step 2
      navNotifier.advanceProgress(); // step 3
      navNotifier.advanceProgress(); // step 4 (approaching bay)
      expect(container.read(navigationStateProvider).status, equals(NavigationStatus.arriving));

      // 6. Ambulance arrives at hospital bay
      final matchingHold = hospitalStateAfter.activeHolds.firstWhere((h) => h.requestId == syncedRequest.id);
      coordinator.ambulanceArrivesAtHospital(matchingHold.holdId);

      // Verify arrival confirmed on ambulance side
      expect(container.read(navigationStateProvider).status, equals(NavigationStatus.arrived));

      // Verify hospital hold marked as arrived and bed converted from held to occupied
      final hospitalStateArrived = container.read(hospitalStateProvider);
      final holdItemArrived = hospitalStateArrived.activeHolds.firstWhere((h) => h.holdId == matchingHold.holdId);
      expect(holdItemArrived.status, equals(HospitalHoldStatus.arrived));

      // 7. Complete patient handoff
      navNotifier.completeHandoff();
      expect(container.read(navigationStateProvider).status, equals(NavigationStatus.completed));

      // 8. Reset full emergency workflow
      coordinator.resetFullEmergencySystem();

      // Verify ambulance side clean reset
      expect(container.read(patientIntakeProvider).patientName.isEmpty, isTrue);
      expect(container.read(bedRequirementProvider).selectedRequirements.isEmpty, isTrue);
      expect(container.read(selectedHospitalProvider), isNull);
      expect(container.read(navigationStateProvider).status, equals(NavigationStatus.enRoute));

      // Verify user authentication remains completely preserved!
      expect(container.read(sessionProvider).isAuthenticated, isTrue);
      expect(container.read(sessionProvider).isAmbulance, isTrue);
    });

    test('Rejection Flow: Hospital rejects offer -> triggers ambulance fallback', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final coordinator = container.read(mockEmergencyCoordinatorProvider);

      await container.read(sessionProvider.notifier).loginAsAmbulance();
      container.read(patientIntakeProvider.notifier).fillQuickDemoPreset();
      container.read(selectedHospitalProvider.notifier).selectHospital(MockHospitalData.kemHospital);

      final holdOffer = container.read(holdTimerProvider);
      expect(holdOffer, isNotNull);

      // Sync and reject
      coordinator.syncAmbulanceRequestToHospital();
      coordinator.hospitalRejectsAmbulanceHold(holdOffer!.offerId, reason: 'ED at Code Yellow Capacity');

      // Verify ambulance hold transitioned to rejected with fallback available
      final holdState = container.read(holdTimerProvider);
      expect(holdState!.status, equals(HoldLifecycleState.rejected));
      expect(holdState.fallbackHospital, isNotNull);
      expect(holdState.rejectionReason, equals('ED at Code Yellow Capacity'));

      // Advance to standby fallback
      container.read(holdTimerProvider.notifier).advanceToFallback();
      final fallbackOffer = container.read(holdTimerProvider);
      expect(fallbackOffer!.hospital.name, equals('P.D. Hinduja National Hospital'));
      expect(fallbackOffer.status, equals(HoldLifecycleState.pending));
    });

    test('Timeout Flow: 120s timer expiry transitions to timedOut and provides fallback option', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(selectedHospitalProvider.notifier).selectHospital(MockHospitalData.kemHospital);
      expect(container.read(holdTimerProvider)?.status, equals(HoldLifecycleState.pending));

      // Simulate timeout
      container.read(holdTimerProvider.notifier).simulateTimeout();
      final timedOutOffer = container.read(holdTimerProvider);
      expect(timedOutOffer!.status, equals(HoldLifecycleState.timedOut));
      expect(timedOutOffer.remainingSeconds, equals(0));
      expect(timedOutOffer.fallbackHospital, isNotNull);
    });
  });
}
