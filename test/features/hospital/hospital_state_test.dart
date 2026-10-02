import 'package:bedlink/core/theme/semantic_tokens.dart';
import 'package:bedlink/features/hospital/domain/models/hospital_hold_item.dart';
import 'package:bedlink/features/hospital/domain/models/hospital_request_item.dart';
import 'package:bedlink/features/hospital/domain/models/hospital_resource_item.dart';
import 'package:bedlink/features/hospital/presentation/providers/hospital_state_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Hospital Operational State & Notifier Tests', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('Initial hospital state contains correct baseline data and resources', () {
      final state = container.read(hospitalStateProvider);

      expect(state.hospitalId, 'kem_parel');
      expect(state.hospitalName, contains('King Edward Memorial'));
      expect(state.campus, contains('Parel'));
      expect(state.resources.containsKey('icu_bed'), isTrue);
      expect(state.resources.containsKey('ventilator'), isTrue);
      expect(state.resources.containsKey('oxygen_bed'), isTrue);
      expect(state.resources.containsKey('trauma_care'), isTrue);

      final icu = state.resources['icu_bed']!;
      expect(icu.isCountable, isTrue);
      expect(icu.available, 3);
      expect(icu.held, 0);
      expect(icu.occupied, 9);
      expect(icu.total, 12);
      expect(icu.available + icu.held + icu.occupied, lessThanOrEqualTo(icu.total));

      expect(state.pendingRequestCount, 1);
      expect(state.activeHoldCount, 0);
      expect(state.incomingRequests.first.patientDisplayName, 'Ramesh Patil');
    });

    test('Fast one-tap availability controls increment and decrement within capacity limits', () {
      final notifier = container.read(hospitalStateProvider.notifier);

      final initialAvail = container.read(hospitalStateProvider).resources['icu_bed']!.available;

      // Decrement first from 3 to 2
      notifier.decrementResource('icu_bed');
      expect(container.read(hospitalStateProvider).resources['icu_bed']!.available, initialAvail - 1);

      // Increment back from 2 to 3
      notifier.incrementResource('icu_bed');
      expect(container.read(hospitalStateProvider).resources['icu_bed']!.available, initialAvail);

      // Cannot increment past total capacity (3 + 9 = 12 == total)
      notifier.incrementResource('icu_bed');
      expect(container.read(hospitalStateProvider).resources['icu_bed']!.available, initialAvail);

      // Decrement all the way to 0
      while (container.read(hospitalStateProvider).resources['icu_bed']!.available > 0) {
        notifier.decrementResource('icu_bed');
      }
      expect(container.read(hospitalStateProvider).resources['icu_bed']!.available, 0);

      // Cannot decrement below 0
      notifier.decrementResource('icu_bed');
      expect(container.read(hospitalStateProvider).resources['icu_bed']!.available, 0);
    });

    test('Confirm No Change refreshes timestamp without modifying inventory counts', () {
      final notifier = container.read(hospitalStateProvider.notifier);

      // Simulate stale state
      notifier.simulateStaleState(minutesAgo: 45);
      final staleState = container.read(hospitalStateProvider);
      expect(staleState.overallFreshnessState, FreshnessState.stale);
      expect(staleState.minutesSinceLastConfirmed, greaterThanOrEqualTo(45));

      final preAvail = staleState.resources['oxygen_bed']!.available;

      // Confirm no change
      notifier.confirmNoChange();
      final freshState = container.read(hospitalStateProvider);
      expect(freshState.overallFreshnessState, FreshnessState.fresh);
      expect(freshState.minutesSinceLastConfirmed, lessThan(2));
      expect(freshState.resources['oxygen_bed']!.available, preAvail);
    });

    test('Accepting an incoming emergency offer holds beds and creates active hold', () {
      final notifier = container.read(hospitalStateProvider.notifier);
      final initialIcu = container.read(hospitalStateProvider).resources['icu_bed']!;

      expect(container.read(hospitalStateProvider).activeHoldCount, 0);
      expect(container.read(hospitalStateProvider).pendingRequestCount, 1);

      // Accept REQ-AMB-108 (requires 1 icu_bed and 1 ventilator)
      notifier.acceptRequest('REQ-AMB-108');

      final state = container.read(hospitalStateProvider);
      expect(state.pendingRequestCount, 0);
      expect(state.activeHoldCount, 1);

      // Request marked accepted
      final req = state.incomingRequests.firstWhere((r) => r.id == 'REQ-AMB-108');
      expect(req.status, HospitalRequestStatus.accepted);

      // Bed held
      final updatedIcu = state.resources['icu_bed']!;
      expect(updatedIcu.available, initialIcu.available - 1);
      expect(updatedIcu.held, initialIcu.held + 1);

      // Active hold created
      final hold = state.activeHolds.first;
      expect(hold.requestId, 'REQ-AMB-108');
      expect(hold.ambulanceId, 'AMB-108');
      expect(hold.patientName, 'Ramesh Patil');
      expect(hold.status, HospitalHoldStatus.inbound);
      expect(hold.heldResources['icu_bed'], 1);
    });

    test('Rejecting an incoming offer marks request as rejected without modifying inventory', () {
      final notifier = container.read(hospitalStateProvider.notifier);
      final initialIcu = container.read(hospitalStateProvider).resources['icu_bed']!;

      notifier.rejectRequest('REQ-AMB-108', reason: 'Cath Lab Diverted');

      final state = container.read(hospitalStateProvider);
      expect(state.pendingRequestCount, 0);
      expect(state.activeHoldCount, 0);

      final req = state.incomingRequests.firstWhere((r) => r.id == 'REQ-AMB-108');
      expect(req.status, HospitalRequestStatus.rejected);
      expect(req.rejectionReason, 'Cath Lab Diverted');

      final icu = state.resources['icu_bed']!;
      expect(icu.available, initialIcu.available);
      expect(icu.held, initialIcu.held);
    });

    test('Expiring an incoming offer marks request as expired without modifying inventory', () {
      final notifier = container.read(hospitalStateProvider.notifier);
      final initialIcu = container.read(hospitalStateProvider).resources['icu_bed']!;

      notifier.expireRequest('REQ-AMB-108');

      final state = container.read(hospitalStateProvider);
      expect(state.pendingRequestCount, 0);

      final req = state.incomingRequests.firstWhere((r) => r.id == 'REQ-AMB-108');
      expect(req.status, HospitalRequestStatus.expired);

      final icu = state.resources['icu_bed']!;
      expect(icu.available, initialIcu.available);
      expect(icu.held, initialIcu.held);
    });

    test('Marking hold arrived shifts held bed to occupied', () {
      final notifier = container.read(hospitalStateProvider.notifier);
      notifier.acceptRequest('REQ-AMB-108');

      final postAcceptState = container.read(hospitalStateProvider);
      final hold = postAcceptState.activeHolds.first;
      final heldIcu = postAcceptState.resources['icu_bed']!;

      notifier.markHoldArrived(hold.holdId);

      final postArrivalState = container.read(hospitalStateProvider);
      final arrivedHold = postArrivalState.activeHolds.first;
      expect(arrivedHold.status, HospitalHoldStatus.arrived);

      final arrivedIcu = postArrivalState.resources['icu_bed']!;
      expect(arrivedIcu.held, heldIcu.held - 1);
      expect(arrivedIcu.occupied, heldIcu.occupied + 1);
      expect(arrivedIcu.available, heldIcu.available);
    });

    test('Releasing an active hold returns held beds to available capacity', () {
      final notifier = container.read(hospitalStateProvider.notifier);
      final baseIcu = container.read(hospitalStateProvider).resources['icu_bed']!;

      notifier.acceptRequest('REQ-AMB-108');
      final hold = container.read(hospitalStateProvider).activeHolds.first;

      notifier.releaseHold(hold.holdId);

      final releasedState = container.read(hospitalStateProvider);
      final releasedHold = releasedState.activeHolds.first;
      expect(releasedHold.status, HospitalHoldStatus.released);

      final icu = releasedState.resources['icu_bed']!;
      expect(icu.available, baseIcu.available);
      expect(icu.held, baseIcu.held);
    });

    test('Injecting mock request adds new pending offer to queue', () {
      final notifier = container.read(hospitalStateProvider.notifier);
      expect(container.read(hospitalStateProvider).incomingRequests.length, 1);

      notifier.injectMockRequest(
        patientName: 'Sunita Sharma',
        ambulanceId: 'AMB-204',
      );

      final state = container.read(hospitalStateProvider);
      expect(state.incomingRequests.length, 2);
      expect(state.pendingRequestCount, 2);
      expect(state.incomingRequests.first.patientDisplayName, 'Sunita Sharma');
    });

    test('HospitalResourceItem invariants enforce non-negative and capacity constraints', () {
      expect(
        () => HospitalResourceItem(
          id: 'test',
          name: 'Test',
          category: 'Care',
          isCountable: true,
          total: 10,
          available: 6,
          held: 3,
          occupied: 2, // 6 + 3 + 2 = 11 > 10
        ),
        throwsA(isA<AssertionError>()),
      );

      expect(
        () => HospitalResourceItem(
          id: 'test',
          name: 'Test',
          category: 'Care',
          isCountable: true,
          total: 10,
          available: -1,
        ),
        throwsA(isA<AssertionError>()),
      );
    });
  });
}
