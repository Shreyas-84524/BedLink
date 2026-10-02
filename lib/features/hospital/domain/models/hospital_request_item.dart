import 'package:flutter/foundation.dart';
import '../../../ambulance/domain/models/clinical_urgency.dart';

/// Lifecycle state for an incoming emergency triage request at the hospital desk.
enum HospitalRequestStatus {
  pending,
  accepted,
  rejected,
  expired;

  bool get isPending => this == HospitalRequestStatus.pending;
  bool get isAccepted => this == HospitalRequestStatus.accepted;
  bool get isRejected => this == HospitalRequestStatus.rejected;
  bool get isExpired => this == HospitalRequestStatus.expired;

  String get label {
    switch (this) {
      case HospitalRequestStatus.pending:
        return 'PENDING REVIEW';
      case HospitalRequestStatus.accepted:
        return 'REQUEST ACCEPTED';
      case HospitalRequestStatus.rejected:
        return 'REQUEST DECLINED';
      case HospitalRequestStatus.expired:
        return 'REQUEST EXPIRED';
    }
  }
}

/// Represents an inbound emergency reservation offer transmitted to this hospital.
@immutable
class HospitalIncomingRequest {
  const HospitalIncomingRequest({
    required this.id,
    required this.ambulanceId,
    required this.urgency,
    required this.patientDisplayName,
    required this.patientAge,
    required this.biologicalSex,
    required this.chiefComplaint,
    required this.requiredResources,
    required this.requiredCapabilities,
    required this.etaMinutes,
    required this.remainingSeconds,
    required this.status,
    required this.receivedAt,
    this.rejectionReason,
  });

  final String id;
  final String ambulanceId;
  final ClinicalUrgency urgency;
  final String patientDisplayName;
  final int patientAge;
  final String biologicalSex;
  final String chiefComplaint;
  final Map<String, int> requiredResources;
  final List<String> requiredCapabilities;
  final int etaMinutes;
  final int remainingSeconds;
  final HospitalRequestStatus status;
  final DateTime receivedAt;
  final String? rejectionReason;

  /// Formatted response countdown string (e.g. '01:42').
  String get formattedCountdown {
    final m = (remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final s = (remainingSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  HospitalIncomingRequest copyWith({
    String? id,
    String? ambulanceId,
    ClinicalUrgency? urgency,
    String? patientDisplayName,
    int? patientAge,
    String? biologicalSex,
    String? chiefComplaint,
    Map<String, int>? requiredResources,
    List<String>? requiredCapabilities,
    int? etaMinutes,
    int? remainingSeconds,
    HospitalRequestStatus? status,
    DateTime? receivedAt,
    String? rejectionReason,
  }) {
    return HospitalIncomingRequest(
      id: id ?? this.id,
      ambulanceId: ambulanceId ?? this.ambulanceId,
      urgency: urgency ?? this.urgency,
      patientDisplayName: patientDisplayName ?? this.patientDisplayName,
      patientAge: patientAge ?? this.patientAge,
      biologicalSex: biologicalSex ?? this.biologicalSex,
      chiefComplaint: chiefComplaint ?? this.chiefComplaint,
      requiredResources: requiredResources ?? this.requiredResources,
      requiredCapabilities: requiredCapabilities ?? this.requiredCapabilities,
      etaMinutes: etaMinutes ?? this.etaMinutes,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      status: status ?? this.status,
      receivedAt: receivedAt ?? this.receivedAt,
      rejectionReason: rejectionReason ?? this.rejectionReason,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is HospitalIncomingRequest &&
        other.id == id &&
        other.ambulanceId == ambulanceId &&
        other.status == status &&
        other.remainingSeconds == remainingSeconds;
  }

  @override
  int get hashCode => Object.hash(id, ambulanceId, status, remainingSeconds);
}
