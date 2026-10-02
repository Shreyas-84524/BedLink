import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../matching/data/mock_hospital_data.dart';
import '../../../matching/domain/models/hospital_match.dart';
import '../../../matching/presentation/providers/selected_hospital_provider.dart';
import '../../domain/models/hold_status.dart';
import '../../domain/models/reservation_offer.dart';

/// NOTE FOR FUTURE PHASES:
/// In Phase 7, the 120-second countdown and fallback transitions are simulated locally.
/// In Phase 12 (Supabase Realtime & Reservations), this timer will be replaced with
/// authoritative server-side `expires_at` timestamps and Postgres Change event streams.
/// Client devices must NEVER authoritatively decide offer timeouts in production.

/// Riverpod Notifier managing the 2-minute emergency hospital hold protocol and fallback lifecycle.
class HoldTimerNotifier extends Notifier<ReservationOffer?> {
  /// Global switch to disable background periodic timer in widget test environments.
  static bool disablePeriodicTickerForTesting = false;

  Timer? _timer;

  @override
  ReservationOffer? build() {
    ref.onDispose(() {
      _timer?.cancel();
    });

    final selectedHospital = ref.watch(selectedHospitalProvider);
    if (selectedHospital == null) {
      return null;
    }

    final fallback = _resolveNextFallback(selectedHospital);

    final initialOffer = ReservationOffer(
      offerId: 'HLD-2026-9481',
      hospital: selectedHospital,
      fallbackHospital: fallback,
      status: HoldLifecycleState.pending,
      remainingSeconds: 120,
      attemptNumber: 1,
      requestedAt: DateTime.now(),
    );

    _startCountdownTimer();
    return initialOffer;
  }

  /// Resolves the next candidate hospital in rank order from Phase 6 mock data.
  HospitalMatch? _resolveNextFallback(HospitalMatch current) {
    const candidates = MockHospitalData.standardCandidates;
    final currentIndex = candidates.indexWhere((h) => h.id == current.id);
    if (currentIndex >= 0 && currentIndex + 1 < candidates.length) {
      return candidates[currentIndex + 1];
    }
    return null;
  }

  /// Starts the 1-second interval countdown timer.
  void _startCountdownTimer() {
    _timer?.cancel();
    if (disablePeriodicTickerForTesting) return;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state == null) {
        timer.cancel();
        return;
      }

      if (state!.status != HoldLifecycleState.pending) {
        timer.cancel();
        return;
      }

      final nextSeconds = state!.remainingSeconds - 1;
      if (nextSeconds <= 0) {
        timer.cancel();
        state = state!.copyWith(
          remainingSeconds: 0,
          status: HoldLifecycleState.timedOut,
        );
      } else {
        state = state!.copyWith(remainingSeconds: nextSeconds);
      }
    });
  }

  /// Restarts or initializes a new hold request for the target hospital.
  void startHold({HospitalMatch? targetHospital}) {
    final current = targetHospital ?? state?.hospital ?? ref.read(selectedHospitalProvider);
    if (current == null) return;

    final fallback = _resolveNextFallback(current);

    _timer?.cancel();
    state = ReservationOffer(
      offerId: 'HLD-2026-${1000 + (state?.attemptNumber ?? 1) * 23}',
      hospital: current,
      fallbackHospital: fallback,
      status: HoldLifecycleState.pending,
      remainingSeconds: 120,
      attemptNumber: (state?.attemptNumber ?? 0) + 1,
      requestedAt: DateTime.now(),
    );

    _startCountdownTimer();
  }

  /// Simulates hospital triage desk accepting the transfer and locking the requested bed.
  void simulateAccept() {
    _timer?.cancel();
    if (state == null) return;
    state = state!.copyWith(
      status: HoldLifecycleState.accepted,
    );
  }

  /// Simulates hospital triage desk declining the transfer with an optional clinical reason.
  void simulateReject({String? reason}) {
    _timer?.cancel();
    if (state == null) return;
    state = state!.copyWith(
      status: HoldLifecycleState.rejected,
      rejectionReason: reason ?? 'Emergency Department at maximum surge capacity',
    );
  }

  /// Simulates expiration of the 2-minute hold offer window without hospital response.
  void simulateTimeout() {
    _timer?.cancel();
    if (state == null) return;
    state = state!.copyWith(
      remainingSeconds: 0,
      status: HoldLifecycleState.timedOut,
    );
  }

  /// Advances automatically or manually to the standby fallback hospital candidate.
  void advanceToFallback() {
    if (state?.fallbackHospital == null) return;

    final nextHospital = state!.fallbackHospital!;
    ref.read(selectedHospitalProvider.notifier).selectHospital(nextHospital);

    final nextFallback = _resolveNextFallback(nextHospital);

    _timer?.cancel();
    state = ReservationOffer(
      offerId: 'HLD-2026-${2000 + (state!.attemptNumber + 1) * 31}',
      hospital: nextHospital,
      fallbackHospital: nextFallback,
      status: HoldLifecycleState.pending,
      remainingSeconds: 120,
      attemptNumber: state!.attemptNumber + 1,
      requestedAt: DateTime.now(),
    );

    _startCountdownTimer();
  }

  /// Development & test helper: sets exact remaining seconds without real-time waiting.
  void setRemainingSeconds(int seconds) {
    if (state == null) return;
    final clamped = seconds.clamp(0, 120);
    state = state!.copyWith(
      remainingSeconds: clamped,
      status: clamped == 0 ? HoldLifecycleState.timedOut : state!.status,
    );
    if (clamped == 0) {
      _timer?.cancel();
    }
  }

  /// Pauses the countdown timer (useful for deterministic widget tests).
  void pauseTimerForTesting() {
    _timer?.cancel();
  }

  /// Resets hold state.
  void reset() {
    _timer?.cancel();
    state = null;
  }
}

/// Global provider for the active 2-minute bed hold lifecycle state.
final holdTimerProvider =
    NotifierProvider<HoldTimerNotifier, ReservationOffer?>(
  HoldTimerNotifier.new,
);
