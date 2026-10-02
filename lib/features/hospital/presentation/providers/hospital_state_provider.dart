import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/semantic_tokens.dart';
import '../../../ambulance/domain/models/clinical_urgency.dart';
import '../../domain/models/hospital_hold_item.dart';
import '../../domain/models/hospital_request_item.dart';
import '../../domain/models/hospital_resource_item.dart';

/// Complete in-memory operational state of the hospital triage desk and bed inventory.
class HospitalOperationalState {
  const HospitalOperationalState({
    required this.hospitalId,
    required this.hospitalName,
    required this.campus,
    required this.staffName,
    required this.resources,
    required this.incomingRequests,
    required this.activeHolds,
    required this.updatedAt,
    required this.lastConfirmedAt,
  });

  final String hospitalId;
  final String hospitalName;
  final String campus;
  final String staffName;
  final Map<String, HospitalResourceItem> resources;
  final List<HospitalIncomingRequest> incomingRequests;
  final List<HospitalActiveHold> activeHolds;
  final DateTime updatedAt;
  final DateTime lastConfirmedAt;

  /// Count of incoming offers awaiting review.
  int get pendingRequestCount =>
      incomingRequests.where((r) => r.status.isPending).length;

  /// Count of active / inbound temporary reservations.
  int get activeHoldCount =>
      activeHolds.where((h) => h.status.isInbound).length;

  /// Effective freshness state based on the most recent of updatedAt or lastConfirmedAt.
  FreshnessState get overallFreshnessState {
    final mostRecent = updatedAt.isAfter(lastConfirmedAt) ? updatedAt : lastConfirmedAt;
    final minutesAgo = DateTime.now().difference(mostRecent).inMinutes;
    return FreshnessState.fromMinutes(minutesAgo);
  }

  /// Minutes elapsed since last confirmation or quantity update.
  int get minutesSinceLastConfirmed {
    final mostRecent = updatedAt.isAfter(lastConfirmedAt) ? updatedAt : lastConfirmedAt;
    return DateTime.now().difference(mostRecent).inMinutes;
  }

  /// Computed total occupancy percentage across all countable beds.
  double get totalOccupancyRate {
    var totalCountable = 0;
    var totalInUse = 0;
    for (final res in resources.values) {
      if (res.isCountable && res.total > 0) {
        totalCountable += res.total;
        totalInUse += (res.occupied + res.held);
      }
    }
    if (totalCountable == 0) return 0.0;
    return (totalInUse / totalCountable).clamp(0.0, 1.0);
  }

  /// Hospital load categorization derived from aggregate bed occupancy.
  HospitalLoadState get loadState {
    final rate = totalOccupancyRate;
    if (rate >= 0.85) return HospitalLoadState.high;
    if (rate >= 0.65) return HospitalLoadState.moderate;
    return HospitalLoadState.low;
  }

  HospitalOperationalState copyWith({
    String? hospitalId,
    String? hospitalName,
    String? campus,
    String? staffName,
    Map<String, HospitalResourceItem>? resources,
    List<HospitalIncomingRequest>? incomingRequests,
    List<HospitalActiveHold>? activeHolds,
    DateTime? updatedAt,
    DateTime? lastConfirmedAt,
  }) {
    return HospitalOperationalState(
      hospitalId: hospitalId ?? this.hospitalId,
      hospitalName: hospitalName ?? this.hospitalName,
      campus: campus ?? this.campus,
      staffName: staffName ?? this.staffName,
      resources: resources ?? this.resources,
      incomingRequests: incomingRequests ?? this.incomingRequests,
      activeHolds: activeHolds ?? this.activeHolds,
      updatedAt: updatedAt ?? this.updatedAt,
      lastConfirmedAt: lastConfirmedAt ?? this.lastConfirmedAt,
    );
  }

  /// Creates realistic default hospital state for demo and testing.
  factory HospitalOperationalState.initial() {
    final now = DateTime.now();
    return HospitalOperationalState(
      hospitalId: 'kem_parel',
      hospitalName: 'King Edward Memorial Hospital',
      campus: 'Parel • Zone 2',
      staffName: 'Dr. A. Mehta (Triage Lead)',
      resources: {
        // Critical Care
        'icu_bed': const HospitalResourceItem(
          id: 'icu_bed',
          name: 'ICU Beds',
          category: 'Critical Care',
          isCountable: true,
          total: 12,
          available: 3,
          held: 0,
          occupied: 9,
        ),
        'ventilator': const HospitalResourceItem(
          id: 'ventilator',
          name: 'Ventilator Beds',
          category: 'Critical Care',
          isCountable: true,
          total: 8,
          available: 2,
          held: 0,
          occupied: 6,
        ),
        'pediatric_icu': const HospitalResourceItem(
          id: 'pediatric_icu',
          name: 'Pediatric ICU',
          category: 'Critical Care',
          isCountable: true,
          total: 6,
          available: 1,
          held: 0,
          occupied: 5,
        ),

        // Emergency & Acute
        'er_bed': const HospitalResourceItem(
          id: 'er_bed',
          name: 'General Emergency Beds',
          category: 'Acute & Emergency',
          isCountable: true,
          total: 15,
          available: 4,
          held: 0,
          occupied: 11,
        ),
        'oxygen_bed': const HospitalResourceItem(
          id: 'oxygen_bed',
          name: 'Oxygen Beds',
          category: 'Acute & Emergency',
          isCountable: true,
          total: 30,
          available: 8,
          held: 0,
          occupied: 22,
        ),
        'general_bed': const HospitalResourceItem(
          id: 'general_bed',
          name: 'General Ward Beds',
          category: 'Acute & Emergency',
          isCountable: true,
          total: 80,
          available: 14,
          held: 0,
          occupied: 66,
        ),

        // Specialized Care Capabilities
        'cardiac_care': const HospitalResourceItem(
          id: 'cardiac_care',
          name: 'Cardiac Care Unit (Cath Lab)',
          category: 'Specialized Capabilities',
          isCountable: false,
          isOperational: true,
        ),
        'trauma_care': const HospitalResourceItem(
          id: 'trauma_care',
          name: 'Level-1 Trauma Bays',
          category: 'Specialized Capabilities',
          isCountable: false,
          isOperational: true,
        ),
        'burns_care': const HospitalResourceItem(
          id: 'burns_care',
          name: 'Burns Care Unit',
          category: 'Specialized Capabilities',
          isCountable: false,
          isOperational: true,
        ),
      },
      incomingRequests: [
        HospitalIncomingRequest(
          id: 'REQ-AMB-108',
          ambulanceId: 'AMB-108',
          urgency: ClinicalUrgency.critical,
          patientDisplayName: 'Ramesh Patil',
          patientAge: 54,
          biologicalSex: 'M',
          chiefComplaint: 'Severe substernal chest pain radiating to left arm.',
          requiredResources: const {'icu_bed': 1, 'ventilator': 1},
          requiredCapabilities: const ['cardiac_care'],
          etaMinutes: 8,
          remainingSeconds: 104,
          status: HospitalRequestStatus.pending,
          receivedAt: now.subtract(const Duration(seconds: 16)),
        ),
      ],
      activeHolds: const [],
      updatedAt: now.subtract(const Duration(minutes: 2)),
      lastConfirmedAt: now.subtract(const Duration(minutes: 2)),
    );
  }
}

/// Riverpod Notifier providing fast hospital availability controls, request triage, and active holds.
class HospitalStateNotifier extends Notifier<HospitalOperationalState> {
  @override
  HospitalOperationalState build() {
    return HospitalOperationalState.initial();
  }

  /// Increments the available count for a countable resource without exceeding capacity.
  void incrementResource(String id) {
    final item = state.resources[id];
    if (item == null || !item.canIncrement) return;

    final updated = item.copyWith(available: item.available + 1);
    final newMap = Map<String, HospitalResourceItem>.from(state.resources)..[id] = updated;

    state = state.copyWith(
      resources: newMap,
      updatedAt: DateTime.now(),
    );
  }

  /// Decrements the available count for a countable resource without going negative.
  void decrementResource(String id) {
    final item = state.resources[id];
    if (item == null || !item.canDecrement) return;

    final updated = item.copyWith(available: item.available - 1);
    final newMap = Map<String, HospitalResourceItem>.from(state.resources)..[id] = updated;

    state = state.copyWith(
      resources: newMap,
      updatedAt: DateTime.now(),
    );
  }

  /// Confirms that current bed counts remain unchanged, refreshing the freshness timestamp.
  void confirmNoChange() {
    state = state.copyWith(
      lastConfirmedAt: DateTime.now(),
    );
  }

  /// Demonstration fixture: forces the hospital inventory into a stale freshness state (>30m).
  void simulateStaleState({int minutesAgo = 34}) {
    final staleTime = DateTime.now().subtract(Duration(minutes: minutesAgo));
    state = state.copyWith(
      updatedAt: staleTime,
      lastConfirmedAt: staleTime,
    );
  }

  /// Hospital triage desk accepts the incoming emergency request and creates an active hold.
  void acceptRequest(String requestId) {
    final requestIndex = state.incomingRequests.indexWhere((r) => r.id == requestId);
    if (requestIndex < 0) return;

    final request = state.incomingRequests[requestIndex];
    if (!request.status.isPending) return;

    // Transition request to accepted
    final updatedRequest = request.copyWith(status: HospitalRequestStatus.accepted);
    final newRequests = List<HospitalIncomingRequest>.from(state.incomingRequests)
      ..[requestIndex] = updatedRequest;

    // Deduct available beds and allocate to held
    final newResources = Map<String, HospitalResourceItem>.from(state.resources);
    for (final entry in request.requiredResources.entries) {
      final resItem = newResources[entry.key];
      if (resItem != null && resItem.isCountable) {
        final amountToHold = entry.value;
        final newAvail = (resItem.available - amountToHold).clamp(0, resItem.total);
        final newHeld = resItem.held + amountToHold;
        newResources[entry.key] = resItem.copyWith(
          available: newAvail,
          held: newHeld,
        );
      }
    }

    // Create corresponding active hold
    final newHold = HospitalActiveHold(
      holdId: 'BL-HOLD-00${state.activeHolds.length + 1}',
      requestId: request.id,
      ambulanceId: request.ambulanceId,
      patientName: request.patientDisplayName,
      urgency: request.urgency,
      heldResources: Map.from(request.requiredResources),
      heldCapabilities: List.from(request.requiredCapabilities),
      etaMinutes: request.etaMinutes,
      status: HospitalHoldStatus.inbound,
      confirmedAt: DateTime.now(),
    );
    final newHolds = List<HospitalActiveHold>.from(state.activeHolds)..add(newHold);

    state = state.copyWith(
      incomingRequests: newRequests,
      resources: newResources,
      activeHolds: newHolds,
      updatedAt: DateTime.now(),
    );
  }

  /// Hospital triage desk declines the incoming emergency request.
  void rejectRequest(String requestId, {String? reason}) {
    final requestIndex = state.incomingRequests.indexWhere((r) => r.id == requestId);
    if (requestIndex < 0) return;

    final request = state.incomingRequests[requestIndex];
    if (!request.status.isPending) return;

    final updatedRequest = request.copyWith(
      status: HospitalRequestStatus.rejected,
      rejectionReason: reason ?? 'Emergency Department at maximum surge capacity',
    );
    final newRequests = List<HospitalIncomingRequest>.from(state.incomingRequests)
      ..[requestIndex] = updatedRequest;

    state = state.copyWith(
      incomingRequests: newRequests,
    );
  }

  /// Simulates 2-minute timer expiry on an incoming request.
  void expireRequest(String requestId) {
    final requestIndex = state.incomingRequests.indexWhere((r) => r.id == requestId);
    if (requestIndex < 0) return;

    final request = state.incomingRequests[requestIndex];
    if (!request.status.isPending) return;

    final updatedRequest = request.copyWith(status: HospitalRequestStatus.expired);
    final newRequests = List<HospitalIncomingRequest>.from(state.incomingRequests)
      ..[requestIndex] = updatedRequest;

    state = state.copyWith(
      incomingRequests: newRequests,
    );
  }

  /// Marks an active hold as arrived at the Emergency Department and transitions held bed to occupied.
  void markHoldArrived(String holdId) {
    final holdIndex = state.activeHolds.indexWhere((h) => h.holdId == holdId);
    if (holdIndex < 0) return;

    final hold = state.activeHolds[holdIndex];
    if (!hold.status.isInbound) return;

    final updatedHold = hold.copyWith(status: HospitalHoldStatus.arrived);
    final newHolds = List<HospitalActiveHold>.from(state.activeHolds)
      ..[holdIndex] = updatedHold;

    final newResources = Map<String, HospitalResourceItem>.from(state.resources);
    for (final entry in hold.heldResources.entries) {
      final resItem = newResources[entry.key];
      if (resItem != null && resItem.isCountable) {
        final amount = entry.value;
        final newHeld = (resItem.held - amount).clamp(0, resItem.total);
        final newOccupied = (resItem.occupied + amount).clamp(0, resItem.total);
        newResources[entry.key] = resItem.copyWith(
          held: newHeld,
          occupied: newOccupied,
        );
      }
    }

    state = state.copyWith(
      activeHolds: newHolds,
      resources: newResources,
      updatedAt: DateTime.now(),
    );
  }

  /// Releases an active hold and returns the held beds back to available.
  void releaseHold(String holdId) {
    final holdIndex = state.activeHolds.indexWhere((h) => h.holdId == holdId);
    if (holdIndex < 0) return;

    final hold = state.activeHolds[holdIndex];
    if (!hold.status.isInbound) return;

    final updatedHold = hold.copyWith(status: HospitalHoldStatus.released);
    final newHolds = List<HospitalActiveHold>.from(state.activeHolds)
      ..[holdIndex] = updatedHold;

    final newResources = Map<String, HospitalResourceItem>.from(state.resources);
    for (final entry in hold.heldResources.entries) {
      final resItem = newResources[entry.key];
      if (resItem != null && resItem.isCountable) {
        final amountToRelease = entry.value;
        final newHeld = (resItem.held - amountToRelease).clamp(0, resItem.total);
        final newAvail = (resItem.available + amountToRelease).clamp(0, resItem.total);
        newResources[entry.key] = resItem.copyWith(
          available: newAvail,
          held: newHeld,
        );
      }
    }

    state = state.copyWith(
      activeHolds: newHolds,
      resources: newResources,
      updatedAt: DateTime.now(),
    );
  }

  /// Injects a new incoming emergency offer (useful for testing & demo).
  void injectMockRequest({
    String? id,
    String? ambulanceId,
    ClinicalUrgency? urgency,
    String? patientName,
    Map<String, int>? requiredResources,
    int? etaMinutes,
  }) {
    final now = DateTime.now();
    final newReq = HospitalIncomingRequest(
      id: id ?? 'REQ-AMB-${200 + state.incomingRequests.length}',
      ambulanceId: ambulanceId ?? 'AMB-${200 + state.incomingRequests.length}',
      urgency: urgency ?? ClinicalUrgency.urgent,
      patientDisplayName: patientName ?? 'Sneha Kulkarni',
      patientAge: 42,
      biologicalSex: 'F',
      chiefComplaint: 'Acute polytrauma and respiratory distress.',
      requiredResources: requiredResources ?? const {'icu_bed': 1},
      requiredCapabilities: const ['trauma_care'],
      etaMinutes: etaMinutes ?? 12,
      remainingSeconds: 120,
      status: HospitalRequestStatus.pending,
      receivedAt: now,
    );

    state = state.copyWith(
      incomingRequests: [newReq, ...state.incomingRequests],
    );
  }

  /// Resets state back to the initial deterministic demonstration baseline.
  void resetDemoFixture() {
    state = HospitalOperationalState.initial();
  }
}

/// Global Riverpod provider for hospital operational state.
final hospitalStateProvider =
    NotifierProvider<HospitalStateNotifier, HospitalOperationalState>(
  HospitalStateNotifier.new,
);
