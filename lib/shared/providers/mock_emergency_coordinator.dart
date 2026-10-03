import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/ambulance/presentation/providers/intake_provider.dart';
import '../../features/ambulance/presentation/providers/requirement_provider.dart';
import '../../features/hospital/domain/models/hospital_request_item.dart';
import '../../features/hospital/presentation/providers/hospital_state_provider.dart';
import '../../features/matching/presentation/providers/selected_hospital_provider.dart';
import '../../features/navigation/presentation/providers/navigation_state_provider.dart';
import '../../features/reservation/presentation/providers/hold_timer_provider.dart';

/// Development-only in-memory coordinator that synchronizes ambulance dispatch actions
/// with hospital receiving desk state for complete frontend end-to-end demonstrations (Phase 10).
/// In Phase 12, this mock coordinator will be replaced by authoritative Supabase Realtime broadcast channels.
class MockEmergencyCoordinator {
  MockEmergencyCoordinator(this._ref);

  final Ref _ref;

  /// Synchronizes the active ambulance hold request to the hospital triage desk incoming requests list.
  void syncAmbulanceRequestToHospital() {
    final patient = _ref.read(patientIntakeProvider);
    final reqs = _ref.read(bedRequirementProvider).selectedRequirements;
    final hold = _ref.read(holdTimerProvider);
    final hospital = _ref.read(selectedHospitalProvider);

    if (hold == null || hospital == null) return;

    final hospitalState = _ref.read(hospitalStateProvider);

    // Check if request with this ID already exists
    final alreadyExists = hospitalState.incomingRequests.any((r) => r.id == hold.offerId);
    if (alreadyExists) return;

    final newReq = HospitalIncomingRequest(
      id: hold.offerId,
      ambulanceId: 'AMB-108',
      urgency: patient.urgency,
      patientDisplayName: patient.displayName,
      patientAge: patient.age,
      biologicalSex: patient.biologicalSex.label.substring(0, 1),
      chiefComplaint: patient.chiefComplaint.isNotEmpty
          ? patient.chiefComplaint
          : 'Emergency Transfer Request',
      requiredResources: reqs.isNotEmpty ? reqs : const {'icu_bed': 1},
      requiredCapabilities: const ['trauma_care'],
      etaMinutes: hospital.etaMinutes,
      remainingSeconds: hold.remainingSeconds,
      status: HospitalRequestStatus.pending,
      receivedAt: DateTime.now(),
    );

    _ref.read(hospitalStateProvider.notifier).injectMockRequest(
          id: newReq.id,
          ambulanceId: newReq.ambulanceId,
          urgency: newReq.urgency,
          patientName: newReq.patientDisplayName,
          requiredResources: newReq.requiredResources,
          etaMinutes: newReq.etaMinutes,
        );
  }

  /// Hospital triage staff accepts the emergency offer:
  /// 1. Updates hospital state: decreases available beds, increases held beds, creates active hold.
  /// 2. Automatically updates ambulance hold timer to accepted / locked.
  void hospitalAcceptsAmbulanceHold(String requestId) {
    // 1. Accept in hospital state
    _ref.read(hospitalStateProvider.notifier).acceptRequest(requestId);

    // 2. Accept ambulance hold
    _ref.read(holdTimerProvider.notifier).simulateAccept();
  }

  /// Hospital triage staff declines/diverts the emergency offer:
  /// 1. Updates hospital request to rejected.
  /// 2. Automatically triggers rejection and fallback on ambulance side.
  void hospitalRejectsAmbulanceHold(String requestId, {String? reason}) {
    // 1. Reject in hospital state
    _ref.read(hospitalStateProvider.notifier).rejectRequest(
          requestId,
          reason: reason ?? 'Emergency Department at maximum surge capacity',
        );

    // 2. Reject ambulance hold
    _ref.read(holdTimerProvider.notifier).simulateReject(reason: reason);
  }

  /// Simulates ambulance arrival at destination:
  /// 1. Confirms arrival in navigation state.
  /// 2. Shifts hospital active hold from held to occupied.
  void ambulanceArrivesAtHospital(String holdId) {
    _ref.read(navigationStateProvider.notifier).confirmArrival();
    _ref.read(hospitalStateProvider.notifier).markHoldArrived(holdId);
  }

  /// Completely resets the emergency workflow across all ambulance and hospital mock components.
  /// Strictly preserves user authentication and session state!
  void resetFullEmergencySystem() {
    _ref.read(navigationStateProvider.notifier).resetWorkflow();
    _ref.read(hospitalStateProvider.notifier).resetDemoFixture();
  }
}

/// Global provider for the Phase 10 mock emergency coordinator.
final mockEmergencyCoordinatorProvider = Provider<MockEmergencyCoordinator>((ref) {
  return MockEmergencyCoordinator(ref);
});
