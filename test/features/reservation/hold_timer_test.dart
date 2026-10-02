import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bedlink/features/matching/data/mock_hospital_data.dart';
import 'package:bedlink/features/matching/presentation/providers/selected_hospital_provider.dart';
import 'package:bedlink/features/reservation/domain/models/hold_status.dart';
import 'package:bedlink/features/reservation/domain/models/reservation_offer.dart';
import 'package:bedlink/features/reservation/presentation/providers/hold_timer_provider.dart';

void main() {
  group('HoldTimerNotifier State & Lifecycle Tests (Sub-phases 7.2, 7.5, 7.6, 7.7)', () {
    test('Initial state is null when no hospital is selected', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final offer = container.read(holdTimerProvider);
      expect(offer, isNull);
    });

    test('Initializes with 120s countdown, pending status, and resolves fallback', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      const kem = MockHospitalData.kemHospital;
      container.read(selectedHospitalProvider.notifier).selectHospital(kem);

      final offer = container.read(holdTimerProvider);
      expect(offer, isNotNull);
      expect(offer!.hospital.id, equals('kem_parel'));
      expect(offer.fallbackHospital?.id, equals('hinduja_mahim'));
      expect(offer.status, equals(HoldLifecycleState.pending));
      expect(offer.remainingSeconds, equals(120));
      expect(offer.formattedCountdown, equals('02:00'));
      expect(offer.attemptNumber, equals(1));
    });

    test('Resolves null fallback when selected hospital is last in list', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      const tata = MockHospitalData.tataMemorialHospital;
      container.read(selectedHospitalProvider.notifier).selectHospital(tata);

      final offer = container.read(holdTimerProvider);
      expect(offer, isNotNull);
      expect(offer!.hospital.id, equals('tata_memorial'));
      expect(offer.fallbackHospital, isNull);
    });

    test('simulateAccept transitions state to accepted without error', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(selectedHospitalProvider.notifier).selectHospital(MockHospitalData.kemHospital);

      final notifier = container.read(holdTimerProvider.notifier);
      notifier.pauseTimerForTesting();
      notifier.simulateAccept();

      final offer = container.read(holdTimerProvider);
      expect(offer!.status, equals(HoldLifecycleState.accepted));
      expect(offer.status.isAccepted, isTrue);
    });

    test('simulateReject records rejection reason and transitions to rejected', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(selectedHospitalProvider.notifier).selectHospital(MockHospitalData.kemHospital);

      final notifier = container.read(holdTimerProvider.notifier);
      notifier.pauseTimerForTesting();
      notifier.simulateReject(reason: 'Trauma bays at surge capacity');

      final offer = container.read(holdTimerProvider);
      expect(offer!.status, equals(HoldLifecycleState.rejected));
      expect(offer.rejectionReason, equals('Trauma bays at surge capacity'));
    });

    test('simulateTimeout sets remaining seconds to 0 and status to timedOut', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(selectedHospitalProvider.notifier).selectHospital(MockHospitalData.kemHospital);

      final notifier = container.read(holdTimerProvider.notifier);
      notifier.pauseTimerForTesting();
      notifier.simulateTimeout();

      final offer = container.read(holdTimerProvider);
      expect(offer!.status, equals(HoldLifecycleState.timedOut));
      expect(offer.remainingSeconds, equals(0));
      expect(offer.formattedCountdown, equals('00:00'));
    });

    test('advanceToFallback transitions to next hospital and resets timer', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(selectedHospitalProvider.notifier).selectHospital(MockHospitalData.kemHospital);

      final notifier = container.read(holdTimerProvider.notifier);
      notifier.pauseTimerForTesting();
      notifier.advanceToFallback();

      final offer = container.read(holdTimerProvider);
      expect(offer!.hospital.id, equals('hinduja_mahim'));
      expect(offer.fallbackHospital?.id, equals('lilavati_bandra'));
      expect(offer.remainingSeconds, equals(120));
      expect(offer.status, equals(HoldLifecycleState.pending));
      expect(offer.attemptNumber, equals(2));

      // Selected hospital provider must also be kept synchronized
      expect(container.read(selectedHospitalProvider)?.id, equals('hinduja_mahim'));
    });

    test('setRemainingSeconds updates time and triggers timeout when zero', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(selectedHospitalProvider.notifier).selectHospital(MockHospitalData.kemHospital);

      final notifier = container.read(holdTimerProvider.notifier);
      notifier.pauseTimerForTesting();

      notifier.setRemainingSeconds(30);
      ReservationOffer? offer = container.read(holdTimerProvider);
      expect(offer?.remainingSeconds, equals(30));
      expect(offer?.formattedCountdown, equals('00:30'));

      notifier.setRemainingSeconds(0);
      offer = container.read(holdTimerProvider);
      expect(offer?.remainingSeconds, equals(0));
      expect(offer?.status, equals(HoldLifecycleState.timedOut));
    });
  });
}
