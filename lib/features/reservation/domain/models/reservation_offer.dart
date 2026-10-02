import 'package:flutter/foundation.dart';
import '../../../matching/domain/models/hospital_match.dart';
import 'hold_status.dart';

/// In-memory domain representation of an emergency bed hold request and offer lifecycle.
@immutable
class ReservationOffer {
  const ReservationOffer({
    required this.offerId,
    required this.hospital,
    required this.status,
    required this.remainingSeconds,
    required this.attemptNumber,
    required this.requestedAt,
    this.fallbackHospital,
    this.rejectionReason,
  });

  /// Deterministic client reservation request token (e.g. 'HLD-2026-9481').
  final String offerId;

  /// Primary target hospital currently evaluating the hold request.
  final HospitalMatch hospital;

  /// Next standby candidate hospital in case of rejection or timeout.
  final HospitalMatch? fallbackHospital;

  /// Current hold lifecycle state (pending, accepted, rejected, timedOut, fallbackTransition).
  final HoldLifecycleState status;

  /// Remaining seconds in the 120-second countdown (120..0).
  final int remainingSeconds;

  /// Sequential routing attempt count (1 for primary, 2 for first fallback, etc.).
  final int attemptNumber;

  /// Timestamp when the hold request was submitted.
  final DateTime requestedAt;

  /// Optional reason provided by hospital triage desk upon rejection.
  final String? rejectionReason;

  /// Formatted countdown display string (e.g. '02:00', '00:45').
  String get formattedCountdown {
    final minutes = (remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (remainingSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  /// Progress fraction for circular indicator (1.0 at 120s down to 0.0 at 0s).
  double get progressFraction => (remainingSeconds / 120.0).clamp(0.0, 1.0);

  ReservationOffer copyWith({
    String? offerId,
    HospitalMatch? hospital,
    HospitalMatch? fallbackHospital,
    HoldLifecycleState? status,
    int? remainingSeconds,
    int? attemptNumber,
    DateTime? requestedAt,
    String? rejectionReason,
  }) {
    return ReservationOffer(
      offerId: offerId ?? this.offerId,
      hospital: hospital ?? this.hospital,
      fallbackHospital: fallbackHospital ?? this.fallbackHospital,
      status: status ?? this.status,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      attemptNumber: attemptNumber ?? this.attemptNumber,
      requestedAt: requestedAt ?? this.requestedAt,
      rejectionReason: rejectionReason ?? this.rejectionReason,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ReservationOffer &&
        other.offerId == offerId &&
        other.hospital.id == hospital.id &&
        other.status == status &&
        other.remainingSeconds == remainingSeconds &&
        other.attemptNumber == attemptNumber;
  }

  @override
  int get hashCode => Object.hash(
        offerId,
        hospital.id,
        status,
        remainingSeconds,
        attemptNumber,
      );

  @override
  String toString() =>
      'ReservationOffer($offerId: ${hospital.name}, status: $status, $formattedCountdown)';
}
