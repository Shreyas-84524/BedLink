import 'package:flutter/foundation.dart';
import '../../../ambulance/domain/models/clinical_urgency.dart';

/// Status of an active bed reservation / hold assigned to this facility.
enum HospitalHoldStatus {
  inbound,
  arrived,
  released,
  cancelled;

  bool get isInbound => this == HospitalHoldStatus.inbound;
  bool get isArrived => this == HospitalHoldStatus.arrived;
  bool get isReleased => this == HospitalHoldStatus.released;

  String get label {
    switch (this) {
      case HospitalHoldStatus.inbound:
        return 'AMBULANCE INBOUND';
      case HospitalHoldStatus.arrived:
        return 'PATIENT ARRIVED';
      case HospitalHoldStatus.released:
        return 'HOLD RELEASED';
      case HospitalHoldStatus.cancelled:
        return 'HOLD CANCELLED';
    }
  }
}

/// Represents a confirmed temporary bed hold with an en-route ambulance.
@immutable
class HospitalActiveHold {
  const HospitalActiveHold({
    required this.holdId,
    required this.requestId,
    required this.ambulanceId,
    required this.patientName,
    required this.urgency,
    required this.heldResources,
    required this.heldCapabilities,
    required this.etaMinutes,
    required this.status,
    required this.confirmedAt,
  });

  final String holdId;
  final String requestId;
  final String ambulanceId;
  final String patientName;
  final ClinicalUrgency urgency;
  final Map<String, int> heldResources;
  final List<String> heldCapabilities;
  final int etaMinutes;
  final HospitalHoldStatus status;
  final DateTime confirmedAt;

  HospitalActiveHold copyWith({
    String? holdId,
    String? requestId,
    String? ambulanceId,
    String? patientName,
    ClinicalUrgency? urgency,
    Map<String, int>? heldResources,
    List<String>? heldCapabilities,
    int? etaMinutes,
    HospitalHoldStatus? status,
    DateTime? confirmedAt,
  }) {
    return HospitalActiveHold(
      holdId: holdId ?? this.holdId,
      requestId: requestId ?? this.requestId,
      ambulanceId: ambulanceId ?? this.ambulanceId,
      patientName: patientName ?? this.patientName,
      urgency: urgency ?? this.urgency,
      heldResources: heldResources ?? this.heldResources,
      heldCapabilities: heldCapabilities ?? this.heldCapabilities,
      etaMinutes: etaMinutes ?? this.etaMinutes,
      status: status ?? this.status,
      confirmedAt: confirmedAt ?? this.confirmedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is HospitalActiveHold &&
        other.holdId == holdId &&
        other.ambulanceId == ambulanceId &&
        other.status == status;
  }

  @override
  int get hashCode => Object.hash(holdId, ambulanceId, status);
}
