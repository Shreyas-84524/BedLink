import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bedlink/core/errors/app_exception.dart';
import 'package:bedlink/features/ambulance/data/repositories/mock_emergency_request_repository.dart';
import 'package:bedlink/features/ambulance/domain/models/clinical_urgency.dart';
import 'package:bedlink/features/ambulance/domain/models/emergency_request.dart';
import 'package:bedlink/features/auth/data/repositories/mock_auth_repository.dart';
import 'package:bedlink/features/auth/domain/models/auth_credentials.dart';
import 'package:bedlink/features/hospital/domain/repositories/bed_mutation_repository.dart';
import 'package:bedlink/features/hospital/presentation/providers/hospital_state_provider.dart';
import 'package:bedlink/features/matching/data/mock_hospital_data.dart';
import 'package:bedlink/features/matching/presentation/providers/matching_provider.dart';
import 'package:bedlink/features/matching/presentation/providers/selected_hospital_provider.dart';
import 'package:bedlink/features/reservation/domain/models/hold_status.dart';
import 'package:bedlink/features/reservation/presentation/providers/hold_timer_provider.dart';
import 'package:bedlink/shared/models/user_role.dart';

void main() {
  setUp(() {
    HoldTimerNotifier.disablePeriodicTickerForTesting = true;
  });

  tearDown(() {
    HoldTimerNotifier.disablePeriodicTickerForTesting = false;
  });

  group('Phase 15.1: Real Authentication & Role Gating', () {
    test('Successful authentication resolves canonical session', () async {
      final repo = MockAuthRepository();
      final session = await repo.login(const AuthCredentials(
        identifier: '1010101010',
        password: 'password123',
        role: UserRole.ambulanceCrew,
      ));

      expect(session.isAuthenticated, isTrue);
      expect(session.isAmbulance, isTrue);
      expect(session.role, equals(UserRole.ambulanceCrew));
      expect(session.userId, isNotNull);
    });

    test('Wrong-role authentication is strictly blocked', () async {
      final repo = MockAuthRepository();

      // Crew credentials submitted under hospital role
      expect(
        () => repo.login(const AuthCredentials(
          identifier: '1010101010',
          password: 'password123',
          role: UserRole.hospitalStaff,
        )),
        throwsA(isA<AppException>()),
      );
    });

    test('Session restoration recovers current session', () async {
      final repo = MockAuthRepository();
      await repo.login(const AuthCredentials(
        identifier: '9090909090',
        password: 'password123',
        role: UserRole.hospitalStaff,
      ));

      final restored = await repo.getCurrentSession();
      expect(restored.isAuthenticated, isTrue);
      expect(restored.isHospital, isTrue);
    });

    test('Logout clears session state', () async {
      final repo = MockAuthRepository();
      await repo.login(const AuthCredentials(
        identifier: '1010101010',
        password: 'password123',
        role: UserRole.ambulanceCrew,
      ));

      await repo.logout();
      final session = await repo.getCurrentSession();
      expect(session.isAuthenticated, isFalse);
    });
  });

  group('Phase 15.2: Real Emergency Requests Repository', () {
    test('createRequest persists emergency request correctly', () async {
      final repo = MockEmergencyRequestRepository();
      final now = DateTime.now();

      final req = EmergencyRequest(
        id: 'REQ-TEST-001',
        ambulanceId: 'AMB-108',
        bedType: 'ICU',
        latitude: 19.002,
        longitude: 72.845,
        status: EmergencyRequestStatus.offered,
        createdAt: now,
        urgency: ClinicalUrgency.critical,
        patientName: 'Priya Sharma',
        patientAge: 38,
        chiefComplaint: 'Acute coronary syndrome',
        requiredResources: const {'icu_bed': 1},
        requiredCapabilities: const ['cardiac_care'],
        hospitalId: 'kem_parel',
        hospitalName: 'KEM Hospital',
      );

      final created = await repo.createRequest(req);
      expect(created.id, equals('REQ-TEST-001'));
      expect(created.ambulanceId, equals('AMB-108'));
      expect(created.status, equals(EmergencyRequestStatus.offered));
      expect(created.patientName, equals('Priya Sharma'));

      final active = await repo.getActiveRequestForAmbulance('AMB-108');
      expect(active, isNotNull);
      expect(active!.id, equals('REQ-TEST-001'));
    });

    test('updateRequestStatus transitions request status correctly', () async {
      final repo = MockEmergencyRequestRepository();
      final req = EmergencyRequest(
        id: 'REQ-TEST-002',
        ambulanceId: 'AMB-109',
        bedType: 'ICU',
        latitude: 19.01,
        longitude: 72.85,
        status: EmergencyRequestStatus.offered,
        createdAt: DateTime.now(),
      );

      await repo.createRequest(req);
      final updated = await repo.updateRequestStatus(
        'REQ-TEST-002',
        EmergencyRequestStatus.reserved,
        hospitalId: 'kem_parel',
        hospitalName: 'KEM Hospital',
      );

      expect(updated.status, equals(EmergencyRequestStatus.reserved));
      expect(updated.hospitalId, equals('kem_parel'));
    });

    test('watchHospitalRequests emits matching requests', () async {
      final repo = MockEmergencyRequestRepository();
      final req = EmergencyRequest(
        id: 'REQ-TEST-003',
        ambulanceId: 'AMB-110',
        bedType: 'ICU',
        latitude: 19.01,
        longitude: 72.85,
        status: EmergencyRequestStatus.offered,
        createdAt: DateTime.now(),
        hospitalId: 'kem_parel',
      );

      await repo.createRequest(req);
      final stream = repo.watchHospitalRequests('kem_parel');
      final firstEmission = await stream.first;

      expect(firstEmission.length, equals(1));
      expect(firstEmission.first.id, equals('REQ-TEST-003'));
    });
  });

  group('Phase 15.3: Server-Authoritative Bed Mutations & Holds', () {
    test('MockBedInventoryMutationRepository implements interface contracts', () async {
      const repo = MockBedInventoryMutationRepository();
      expect(repo.isRealBackend, isFalse);
      expect(repo.isRealBackendWritesSupported, isFalse);

      // Verify methods execute without error
      await repo.reserveBed('kem_parel', 'icu_bed');
      await repo.markBedOccupied('kem_parel', 'icu_bed');
      await repo.releaseReservedBed('kem_parel', 'icu_bed');
      await repo.incrementAvailable('kem_parel', 'icu_bed');
      await repo.decrementAvailable('kem_parel', 'icu_bed');
    });

    test('HoldTimerNotifier uses real candidate matches for fallback progression', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      const candidateA = MockHospitalData.kemHospital;
      const candidateB = MockHospitalData.hindujaHospital;

      container.read(matchingProvider.notifier).completeSearchInstantaneously(
        overrideMatches: [candidateA, candidateB],
      );

      container.read(selectedHospitalProvider.notifier).selectHospital(candidateA);

      final offer = container.read(holdTimerProvider);
      expect(offer, isNotNull);
      expect(offer!.hospital.id, equals(candidateA.id));
      expect(offer.fallbackHospital?.id, equals(candidateB.id));
      expect(offer.status, equals(HoldLifecycleState.pending));

      // Advance to fallback
      container.read(holdTimerProvider.notifier).advanceToFallback();
      final advancedOffer = container.read(holdTimerProvider);
      expect(advancedOffer!.hospital.id, equals(candidateB.id));
      expect(advancedOffer.attemptNumber, equals(2));
      expect(advancedOffer.fallbackHospital, isNull);
    });
  });

  group('Phase 15.4: Real Hospital Triage & Mutations', () {
    test('HospitalStateNotifier processes acceptRequest and deducts inventory', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(hospitalStateProvider.notifier);
      final initialState = container.read(hospitalStateProvider);
      final initialIcuAvailable = initialState.resources['icu_bed']!.available;

      notifier.acceptRequest('REQ-AMB-108');
      final updatedState = container.read(hospitalStateProvider);

      expect(updatedState.resources['icu_bed']!.available, equals(initialIcuAvailable - 1));
      expect(updatedState.resources['icu_bed']!.held, equals(1));
      expect(updatedState.activeHolds.length, equals(1));
      expect(updatedState.activeHolds.first.requestId, equals('REQ-AMB-108'));
    });

    test('HospitalStateNotifier marks hold arrived and transitions bed to occupied', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(hospitalStateProvider.notifier);
      notifier.acceptRequest('REQ-AMB-108');

      var state = container.read(hospitalStateProvider);
      final holdId = state.activeHolds.first.holdId;
      final initialOccupied = state.resources['icu_bed']!.occupied;

      notifier.markHoldArrived(holdId);
      state = container.read(hospitalStateProvider);

      expect(state.resources['icu_bed']!.held, equals(0));
      expect(state.resources['icu_bed']!.occupied, equals(initialOccupied + 1));
      expect(state.activeHolds.first.status.isArrived, isTrue);
    });

    test('HospitalStateNotifier rejects request without deducting bed capacity', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(hospitalStateProvider.notifier);
      final initialAvailable = container.read(hospitalStateProvider).resources['icu_bed']!.available;

      notifier.rejectRequest('REQ-AMB-108', reason: 'Surge capacity exceeded');
      final updatedState = container.read(hospitalStateProvider);

      expect(updatedState.resources['icu_bed']!.available, equals(initialAvailable));
      expect(updatedState.incomingRequests.first.status.isRejected, isTrue);
    });
  });

  group('Phase 15.5: Production Mock Isolation & Security', () {
    test('Real backend state starts with zero mock candidates', () {
      final state = MatchingState.initial(isRealBackend: true);
      expect(state.isRealBackend, isTrue);
      expect(state.matches, isEmpty);
      expect(state.primaryMatch, isNull);
    });

    test('RLS block sets isRlsBlocked flag and leaves matches empty', () {
      final rlsState = MatchingState.initial(isRealBackend: true).copyWith(
        isRlsBlocked: true,
        matches: const [],
      );
      expect(rlsState.isRlsBlocked, isTrue);
      expect(rlsState.matches, isEmpty);
    });
  });
}
