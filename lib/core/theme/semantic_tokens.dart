import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Semantic token bundle containing background, text, border colors, and label.
class SemanticBadgeColors {
  const SemanticBadgeColors({
    required this.background,
    required this.text,
    required this.border,
    required this.icon,
  });

  final Color background;
  final Color text;
  final Color border;
  final Color icon;
}

/// Data Freshness categories adhering to PRD requirements.
enum FreshnessState {
  fresh('Fresh (<5m)'),
  recent('Recent (5-15m)'),
  aging('Aging (15-30m)'),
  stale('Stale (>=30m)');

  const FreshnessState(this.label);
  final String label;

  static FreshnessState fromMinutes(int minutes) {
    if (minutes < 5) return FreshnessState.fresh;
    if (minutes < 15) return FreshnessState.recent;
    if (minutes < 30) return FreshnessState.aging;
    return FreshnessState.stale;
  }

  SemanticBadgeColors get colors {
    switch (this) {
      case FreshnessState.fresh:
        return const SemanticBadgeColors(
          background: AppColors.tealSurface,
          text: AppColors.tealDark,
          border: AppColors.tealBorder,
          icon: AppColors.secondaryTeal,
        );
      case FreshnessState.recent:
        return const SemanticBadgeColors(
          background: AppColors.infoSurface,
          text: AppColors.infoDark,
          border: AppColors.infoBorder,
          icon: AppColors.infoBlue,
        );
      case FreshnessState.aging:
        return const SemanticBadgeColors(
          background: AppColors.warningSurface,
          text: AppColors.warningDark,
          border: AppColors.warningBorder,
          icon: AppColors.warningAmber,
        );
      case FreshnessState.stale:
        return const SemanticBadgeColors(
          background: AppColors.criticalSurface,
          text: AppColors.criticalDark,
          border: AppColors.criticalBorder,
          icon: AppColors.criticalRed,
        );
    }
  }
}

/// Hospital Department Load categories.
enum HospitalLoadState {
  low('Low Load'),
  moderate('Moderate Load'),
  high('Critical Surge'),
  unknown('Load Unavailable');

  const HospitalLoadState(this.label);
  final String label;

  static HospitalLoadState fromOccupancy(double? percentage) {
    if (percentage == null) return HospitalLoadState.unknown;
    if (percentage < 0.70) return HospitalLoadState.low;
    if (percentage < 0.90) return HospitalLoadState.moderate;
    return HospitalLoadState.high;
  }

  SemanticBadgeColors get colors {
    switch (this) {
      case HospitalLoadState.low:
        return const SemanticBadgeColors(
          background: AppColors.tealSurface,
          text: AppColors.tealDark,
          border: AppColors.tealBorder,
          icon: AppColors.secondaryTeal,
        );
      case HospitalLoadState.moderate:
        return const SemanticBadgeColors(
          background: AppColors.warningSurface,
          text: AppColors.warningDark,
          border: AppColors.warningBorder,
          icon: AppColors.warningAmber,
        );
      case HospitalLoadState.high:
        return const SemanticBadgeColors(
          background: AppColors.criticalSurface,
          text: AppColors.criticalDark,
          border: AppColors.criticalBorder,
          icon: AppColors.criticalRed,
        );
      case HospitalLoadState.unknown:
        return const SemanticBadgeColors(
          background: AppColors.surfaceSubtle,
          text: AppColors.textSecondary,
          border: AppColors.border,
          icon: AppColors.textMuted,
        );
    }
  }
}

/// Resource Availability categories.
enum AvailabilityState {
  available('Available'),
  limited('Limited (<2)'),
  unavailable('Zero Available / Divert');

  const AvailabilityState(this.label);
  final String label;

  static AvailabilityState fromCount(int count) {
    if (count <= 0) return AvailabilityState.unavailable;
    if (count <= 2) return AvailabilityState.limited;
    return AvailabilityState.available;
  }

  SemanticBadgeColors get colors {
    switch (this) {
      case AvailabilityState.available:
        return const SemanticBadgeColors(
          background: AppColors.tealSurface,
          text: AppColors.tealDark,
          border: AppColors.tealBorder,
          icon: AppColors.secondaryTeal,
        );
      case AvailabilityState.limited:
        return const SemanticBadgeColors(
          background: AppColors.warningSurface,
          text: AppColors.warningDark,
          border: AppColors.warningBorder,
          icon: AppColors.warningAmber,
        );
      case AvailabilityState.unavailable:
        return const SemanticBadgeColors(
          background: AppColors.criticalSurface,
          text: AppColors.criticalDark,
          border: AppColors.criticalBorder,
          icon: AppColors.criticalRed,
        );
    }
  }
}

/// Clinical Emergency Urgency / Acuity tiers.
enum EmergencyAcuity {
  routine('Routine • Tier 3', 'Stable vitals, non-immediate resuscitation'),
  urgent('Urgent • Tier 2', 'Potentially unstable, expedited bed needed'),
  critical('Critical • Tier 1', 'Immediate life-threat, direct resuscitation required');

  const EmergencyAcuity(this.label, this.description);
  final String label;
  final String description;

  SemanticBadgeColors get colors {
    switch (this) {
      case EmergencyAcuity.routine:
        return const SemanticBadgeColors(
          background: AppColors.surfaceSubtle,
          text: AppColors.textPrimary,
          border: AppColors.border,
          icon: AppColors.textSecondary,
        );
      case EmergencyAcuity.urgent:
        return const SemanticBadgeColors(
          background: AppColors.warningSurface,
          text: AppColors.warningDark,
          border: AppColors.warningBorder,
          icon: AppColors.warningAmber,
        );
      case EmergencyAcuity.critical:
        return const SemanticBadgeColors(
          background: AppColors.criticalSurface,
          text: AppColors.criticalDark,
          border: AppColors.criticalBorder,
          icon: AppColors.criticalRed,
        );
    }
  }
}

/// Network & Connectivity state.
enum ConnectivityState {
  live('MED-NET LIVE'),
  reconnecting('RECONNECTING...'),
  offline('OFFLINE (CACHED)');

  const ConnectivityState(this.label);
  final String label;

  SemanticBadgeColors get colors {
    switch (this) {
      case ConnectivityState.live:
        return const SemanticBadgeColors(
          background: AppColors.tealSurface,
          text: AppColors.tealDark,
          border: AppColors.tealBorder,
          icon: AppColors.secondaryTeal,
        );
      case ConnectivityState.reconnecting:
        return const SemanticBadgeColors(
          background: AppColors.warningSurface,
          text: AppColors.warningDark,
          border: AppColors.warningBorder,
          icon: AppColors.warningAmber,
        );
      case ConnectivityState.offline:
        return const SemanticBadgeColors(
          background: AppColors.surfaceSubtle,
          text: AppColors.textSecondary,
          border: AppColors.border,
          icon: AppColors.textMuted,
        );
    }
  }
}

/// Reservation & Hold states.
enum ReservationStatus {
  pending('Pending Offer'),
  locked('2-Min Hold Active'),
  accepted('Bed Reserved & Confirmed'),
  rejected('Offer Rejected'),
  timedOut('Offer Timed Out'),
  expired('Hold Released');

  const ReservationStatus(this.label);
  final String label;

  SemanticBadgeColors get colors {
    switch (this) {
      case ReservationStatus.pending:
      case ReservationStatus.locked:
        return const SemanticBadgeColors(
          background: AppColors.warningSurface,
          text: AppColors.warningDark,
          border: AppColors.warningBorder,
          icon: AppColors.warningAmber,
        );
      case ReservationStatus.accepted:
        return const SemanticBadgeColors(
          background: AppColors.tealSurface,
          text: AppColors.tealDark,
          border: AppColors.tealBorder,
          icon: AppColors.secondaryTeal,
        );
      case ReservationStatus.rejected:
      case ReservationStatus.timedOut:
      case ReservationStatus.expired:
        return const SemanticBadgeColors(
          background: AppColors.criticalSurface,
          text: AppColors.criticalDark,
          border: AppColors.criticalBorder,
          icon: AppColors.criticalRed,
        );
    }
  }
}
