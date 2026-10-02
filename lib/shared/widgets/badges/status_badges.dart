import 'package:flutter/material.dart';
import '../../../core/theme/semantic_tokens.dart';
import 'bedlink_badge.dart';

/// Badge displaying data freshness (e.g. "UPDATED 2m AGO", "STALE").
class FreshnessBadge extends StatelessWidget {
  const FreshnessBadge({
    required this.state,
    this.customLabel,
    super.key,
  });

  final FreshnessState state;
  final String? customLabel;

  factory FreshnessBadge.fromMinutes(int minutes, {Key? key}) {
    final state = FreshnessState.fromMinutes(minutes);
    final label = minutes < 1 ? 'JUST NOW' : '${minutes}m AGO';
    return FreshnessBadge(
      key: key,
      state: state,
      customLabel: 'UPDATED $label',
    );
  }

  @override
  Widget build(BuildContext context) {
    return BedLinkBadge.fromSemantic(
      label: customLabel ?? state.label,
      colors: state.colors,
      icon: Icons.access_time_rounded,
    );
  }
}

/// Badge displaying hospital load and surge status (e.g. "LOW LOAD", "CRITICAL SURGE").
class HospitalLoadBadge extends StatelessWidget {
  const HospitalLoadBadge({
    required this.state,
    this.customLabel,
    super.key,
  });

  final HospitalLoadState state;
  final String? customLabel;

  factory HospitalLoadBadge.fromOccupancy(double? percentage, {Key? key}) {
    final state = HospitalLoadState.fromOccupancy(percentage);
    final String? label = percentage != null ? '${(percentage * 100).round()}% OCCUPIED' : null;
    return HospitalLoadBadge(
      key: key,
      state: state,
      customLabel: label,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BedLinkBadge.fromSemantic(
      label: customLabel ?? state.label,
      colors: state.colors,
      icon: Icons.pie_chart_outline_rounded,
    );
  }
}

/// Badge displaying patient clinical triage urgency.
class EmergencyUrgencyBadge extends StatelessWidget {
  const EmergencyUrgencyBadge({
    required this.acuity,
    super.key,
  });

  final EmergencyAcuity acuity;

  @override
  Widget build(BuildContext context) {
    return BedLinkBadge.fromSemantic(
      label: acuity.label,
      colors: acuity.colors,
      icon: Icons.warning_amber_rounded,
    );
  }
}

/// Badge displaying resource inventory availability state.
class AvailabilityBadge extends StatelessWidget {
  const AvailabilityBadge({
    required this.state,
    this.count,
    super.key,
  });

  final AvailabilityState state;
  final int? count;

  factory AvailabilityBadge.fromCount(int count, {Key? key}) {
    final state = AvailabilityState.fromCount(count);
    return AvailabilityBadge(
      key: key,
      state: state,
      count: count,
    );
  }

  @override
  Widget build(BuildContext context) {
    final String label = count != null
        ? (count! > 0 ? '$count AVAILABLE' : '0 BEDS • DIVERT')
        : state.label;

    return BedLinkBadge.fromSemantic(
      label: label,
      colors: state.colors,
      icon: Icons.check_circle_outline_rounded,
      isMonospaced: count != null,
    );
  }
}

/// Badge displaying application connectivity and synchronization status.
class ConnectivityBadge extends StatelessWidget {
  const ConnectivityBadge({
    required this.state,
    super.key,
  });

  final ConnectivityState state;

  @override
  Widget build(BuildContext context) {
    return BedLinkBadge.fromSemantic(
      label: state.label,
      colors: state.colors,
      icon: Icons.sensors_rounded,
    );
  }
}

/// Badge displaying reservation and hold lifecycle state.
class ReservationStatusBadge extends StatelessWidget {
  const ReservationStatusBadge({
    required this.status,
    super.key,
  });

  final ReservationStatus status;

  @override
  Widget build(BuildContext context) {
    return BedLinkBadge.fromSemantic(
      label: status.label,
      colors: status.colors,
      icon: Icons.bookmark_added_rounded,
    );
  }
}
