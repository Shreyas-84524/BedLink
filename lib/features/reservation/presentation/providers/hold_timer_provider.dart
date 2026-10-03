import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/data/supabase_client_provider.dart';
import '../../../../core/services/location/location_provider.dart';
import '../../../../shared/providers/session_provider.dart';
import '../../../ambulance/domain/models/emergency_request.dart';
import '../../../ambulance/presentation/providers/emergency_request_provider.dart';
import '../../../ambulance/presentation/providers/intake_provider.dart';
import '../../../ambulance/presentation/providers/requirement_provider.dart';
import '../../../matching/data/mock_hospital_data.dart';
import '../../../matching/domain/models/hospital_match.dart';
import '../../../matching/presentation/providers/matching_provider.dart';
import '../../../matching/presentation/providers/selected_hospital_provider.dart';
import '../../domain/models/hold_status.dart';
import '../../domain/models/reservation_offer.dart';

/// Riverpod Notifier managing the 2-minute emergency hospital hold protocol and fallback lifecycle.
class HoldTimerNotifier extends Notifier<ReservationOffer?> {
  /// Global switch to disable background periodic timer in widget test environments.
  static bool disablePeriodicTickerForTesting = false;

  Timer? _timer;
  StreamSubscription<EmergencyRequest?>? _realtimeSub;

  @override
  ReservationOffer? build() {
    ref.onDispose(() {
      _timer?.cancel();
      _realtimeSub?.cancel();
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
    _dispatchRealEmergencyRequest(selectedHospital);
    return initialOffer;
  }

  /// Resolves the next candidate hospital in rank order.
  /// Uses real matches from matchingProvider if available.
  /// Strictly isolates MockHospitalData to explicit mock mode!
  HospitalMatch? _resolveNextFallback(HospitalMatch current) {
    final matches = ref.read(matchingProvider).matches;
    if (matches.isNotEmpty) {
      final currentIndex = matches.indexWhere((h) => h.id == current.id);
      if (currentIndex >= 0 && currentIndex + 1 < matches.length) {
        return matches[currentIndex + 1];
      }
      return null;
    }

    final config = ref.read(supabaseConfigProvider);
    if (config.useMock) {
      const candidates = MockHospitalData.standardCandidates;
      final currentIndex = candidates.indexWhere((h) => h.id == current.id);
      if (currentIndex >= 0 && currentIndex + 1 < candidates.length) {
        return candidates[currentIndex + 1];
      }
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

  /// Dispatches real emergency request to Supabase and watches for real-time status transitions.
  Future<void> _dispatchRealEmergencyRequest(HospitalMatch targetHospital) async {
    final reqRepo = ref.read(emergencyRequestRepositoryProvider);
    if (!reqRepo.isRealBackend) return;

    final session = ref.read(sessionProvider);
    final ambulanceId = session.userId ?? 'AMB-108';
    final location = ref.read(ambulanceLocationProvider);
    final intake = ref.read(patientIntakeProvider);
    final reqs = ref.read(bedRequirementProvider);

    final expiresAt = DateTime.now().add(const Duration(seconds: 120));

    // Determine primary bed type from requirements
    String primaryBed = 'ICU';
    for (final key in reqs.selectedRequirements.keys) {
      final lower = key.toLowerCase();
      if (lower.contains('general')) {
        primaryBed = 'general';
        break;
      } else if (lower.contains('emergency')) {
        primaryBed = 'emergency';
        break;
      }
    }

    final request = EmergencyRequest(
      id: '',
      ambulanceId: ambulanceId,
      bedType: primaryBed,
      latitude: location.location?.latitude ?? 18.9980,
      longitude: location.location?.longitude ?? 72.8420,
      status: EmergencyRequestStatus.offered,
      urgency: intake.urgency,
      patientName: intake.patientName.isNotEmpty ? intake.patientName : 'Inbound Patient',
      patientAge: intake.age,
      chiefComplaint: intake.chiefComplaint.isNotEmpty ? intake.chiefComplaint : 'Emergency Transfer',
      requiredResources: Map<String, int>.from(reqs.selectedRequirements),
      requiredCapabilities: const [],
      hospitalId: targetHospital.id,
      hospitalName: targetHospital.name,
      expiresAt: expiresAt,
      createdAt: DateTime.now(),
    );

    try {
      final created = await ref.read(activeEmergencyRequestProvider.notifier).dispatchRequest(request);
      if (created != null) {
        state = state?.copyWith(offerId: created.id);
        _watchRealtimeOffer(created.id);
      }
    } catch (e) {
      // In case of error, local countdown continues without breaking UI
    }
  }

  /// Subscribes to real-time status changes for the given request ID.
  void _watchRealtimeOffer(String requestId) {
    _realtimeSub?.cancel();
    final reqRepo = ref.read(emergencyRequestRepositoryProvider);
    if (!reqRepo.isRealBackend) return;

    _realtimeSub = reqRepo.watchRequest(requestId).listen((req) {
      if (req == null || state == null) return;

      if (req.status == EmergencyRequestStatus.reserved) {
        _timer?.cancel();
        state = state!.copyWith(status: HoldLifecycleState.accepted);
      } else if (req.status == EmergencyRequestStatus.cancelled) {
        _timer?.cancel();
        state = state!.copyWith(
          status: HoldLifecycleState.rejected,
          rejectionReason: req.cancellationReason ?? 'Emergency Department at maximum surge capacity',
        );
      } else if (req.status == EmergencyRequestStatus.completed) {
        _timer?.cancel();
        state = state!.copyWith(status: HoldLifecycleState.accepted);
      } else if (req.expiresAt != null && state!.status == HoldLifecycleState.pending) {
        final remaining = req.expiresAt!.difference(DateTime.now()).inSeconds;
        if (remaining <= 0) {
          _timer?.cancel();
          state = state!.copyWith(
            remainingSeconds: 0,
            status: HoldLifecycleState.timedOut,
          );
        } else if (remaining < state!.remainingSeconds) {
          state = state!.copyWith(remainingSeconds: remaining);
        }
      }
    });
  }

  /// Restarts or initializes a new hold request for the target hospital.
  void startHold({HospitalMatch? targetHospital}) {
    final current = targetHospital ?? state?.hospital ?? ref.read(selectedHospitalProvider);
    if (current == null) return;

    final fallback = _resolveNextFallback(current);

    _timer?.cancel();
    _realtimeSub?.cancel();
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
    _dispatchRealEmergencyRequest(current);
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
    _realtimeSub?.cancel();
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
    _dispatchRealEmergencyRequest(nextHospital);
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
    _realtimeSub?.cancel();
    state = null;
  }
}

/// Global provider for the active 2-minute bed hold lifecycle state.
final holdTimerProvider =
    NotifierProvider<HoldTimerNotifier, ReservationOffer?>(
  HoldTimerNotifier.new,
);
