import 'package:flutter/material.dart';

/// Maneuver type for turn-by-turn route guidance.
enum NavigationManeuver {
  depart(Icons.navigation_rounded, 'DEPART'),
  continueStraight(Icons.straight_rounded, 'CONTINUE STRAIGHT'),
  turnLeft(Icons.turn_left_rounded, 'TURN LEFT'),
  turnRight(Icons.turn_right_rounded, 'TURN RIGHT'),
  slightLeft(Icons.turn_slight_left_rounded, 'SLIGHT LEFT'),
  slightRight(Icons.turn_slight_right_rounded, 'SLIGHT RIGHT'),
  uTurn(Icons.u_turn_left_rounded, 'U-TURN'),
  arriveDestination(Icons.local_hospital_rounded, 'ARRIVE AT HOSPITAL');

  const NavigationManeuver(this.icon, this.label);
  final IconData icon;
  final String label;
}

/// Represents a deterministic navigation route instruction step.
/// Designed to be replaceable in Phase 14 by real OpenRouteService Directions steps.
@immutable
class MockRouteInstruction {
  const MockRouteInstruction({
    required this.id,
    required this.maneuver,
    required this.instruction,
    required this.distanceMeters,
    required this.roadName,
  });

  final String id;
  final NavigationManeuver maneuver;
  final String instruction;
  final int distanceMeters;
  final String roadName;

  /// Human-readable distance formatting (e.g. "800 m" or "1.2 km").
  String get formattedDistance {
    if (distanceMeters >= 1000) {
      final km = (distanceMeters / 1000).toStringAsFixed(1);
      return '$km km';
    }
    return '$distanceMeters m';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MockRouteInstruction &&
        other.id == id &&
        other.maneuver == maneuver &&
        other.distanceMeters == distanceMeters;
  }

  @override
  int get hashCode => Object.hash(id, maneuver, distanceMeters);
}
