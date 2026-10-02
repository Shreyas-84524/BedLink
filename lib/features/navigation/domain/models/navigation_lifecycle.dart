import 'package:flutter/foundation.dart';
import 'navigation_step.dart';

/// Explicit lifecycle states for the ambulance en-route navigation workflow.
enum NavigationStatus {
  ready,
  enRoute,
  arriving,
  arrived,
  completed;

  bool get isReady => this == NavigationStatus.ready;
  bool get isEnRoute => this == NavigationStatus.enRoute;
  bool get isArriving => this == NavigationStatus.arriving;
  bool get isArrived => this == NavigationStatus.arrived;
  bool get isCompleted => this == NavigationStatus.completed;

  /// Whether the ambulance is close enough to enable arrival confirmation.
  bool get canConfirmArrival => isArriving || isArrived;

  String get label {
    switch (this) {
      case NavigationStatus.ready:
        return 'NAVIGATION READY';
      case NavigationStatus.enRoute:
        return 'AMBULANCE EN ROUTE';
      case NavigationStatus.arriving:
        return 'APPROACHING ER BAY (<1 MIN)';
      case NavigationStatus.arrived:
        return 'ARRIVED AT DESTINATION';
      case NavigationStatus.completed:
        return 'PATIENT HANDOFF COMPLETE';
    }
  }
}

/// Immutable state bundle capturing live navigation progress, instructions, and ETAs.
@immutable
class NavigationProgressState {
  const NavigationProgressState({
    required this.status,
    required this.remainingEtaMinutes,
    required this.remainingDistanceKm,
    required this.routeProgress,
    required this.currentInstructionIndex,
    required this.instructions,
    this.startedAt,
    this.arrivedAt,
    this.completedAt,
  });

  final NavigationStatus status;
  final int remainingEtaMinutes;
  final double remainingDistanceKm;
  final double routeProgress; // 0.0 .. 1.0
  final int currentInstructionIndex;
  final List<MockRouteInstruction> instructions;
  final DateTime? startedAt;
  final DateTime? arrivedAt;
  final DateTime? completedAt;

  /// Current active instruction step.
  MockRouteInstruction get currentInstruction {
    if (instructions.isEmpty) {
      return const MockRouteInstruction(
        id: 'step_default',
        maneuver: NavigationManeuver.continueStraight,
        instruction: 'Proceed toward destination hospital',
        distanceMeters: 500,
        roadName: 'Main Arterial Road',
      );
    }
    final index = currentInstructionIndex.clamp(0, instructions.length - 1);
    return instructions[index];
  }

  /// Next upcoming instruction step (preview), or null if on last step.
  MockRouteInstruction? get nextInstruction {
    if (currentInstructionIndex + 1 < instructions.length) {
      return instructions[currentInstructionIndex + 1];
    }
    return null;
  }

  /// Formatted ETA string (e.g. "8 MIN" or "< 1 MIN").
  String get formattedEta {
    if (remainingEtaMinutes <= 0 || status.isArrived || status.isCompleted) {
      return 'ARRIVED';
    }
    if (remainingEtaMinutes == 1 || status.isArriving) {
      return '< 1 MIN';
    }
    return '$remainingEtaMinutes MIN';
  }

  /// Formatted distance string (e.g. "3.8 KM" or "200 M").
  String get formattedDistance {
    if (remainingDistanceKm <= 0.0 || status.isArrived || status.isCompleted) {
      return '0 M';
    }
    if (remainingDistanceKm < 1.0) {
      final meters = (remainingDistanceKm * 1000).toInt();
      return '$meters M';
    }
    return '${remainingDistanceKm.toStringAsFixed(1)} KM';
  }

  NavigationProgressState copyWith({
    NavigationStatus? status,
    int? remainingEtaMinutes,
    double? remainingDistanceKm,
    double? routeProgress,
    int? currentInstructionIndex,
    List<MockRouteInstruction>? instructions,
    DateTime? startedAt,
    DateTime? arrivedAt,
    DateTime? completedAt,
  }) {
    return NavigationProgressState(
      status: status ?? this.status,
      remainingEtaMinutes: remainingEtaMinutes ?? this.remainingEtaMinutes,
      remainingDistanceKm: remainingDistanceKm ?? this.remainingDistanceKm,
      routeProgress: routeProgress ?? this.routeProgress,
      currentInstructionIndex: currentInstructionIndex ?? this.currentInstructionIndex,
      instructions: instructions ?? this.instructions,
      startedAt: startedAt ?? this.startedAt,
      arrivedAt: arrivedAt ?? this.arrivedAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  /// Standard deterministic instruction set from origin to KEM Hospital Mumbai.
  static List<MockRouteInstruction> defaultInstructions() {
    return const [
      MockRouteInstruction(
        id: 'step_1',
        maneuver: NavigationManeuver.depart,
        instruction: 'Head north on Senapati Bapat Marg toward Lower Parel',
        distanceMeters: 1200,
        roadName: 'Senapati Bapat Marg',
      ),
      MockRouteInstruction(
        id: 'step_2',
        maneuver: NavigationManeuver.turnRight,
        instruction: 'Turn right onto Elphinstone Flyover / Tilak Bridge',
        distanceMeters: 900,
        roadName: 'Tilak Bridge',
      ),
      MockRouteInstruction(
        id: 'step_3',
        maneuver: NavigationManeuver.continueStraight,
        instruction: 'Continue straight onto Dr. Babasaheb Ambedkar Road',
        distanceMeters: 1100,
        roadName: 'Dr. B. Ambedkar Road',
      ),
      MockRouteInstruction(
        id: 'step_4',
        maneuver: NavigationManeuver.slightLeft,
        instruction: 'Keep left toward Acharya Donde Marg (Hospital Approach)',
        distanceMeters: 400,
        roadName: 'Acharya Donde Marg',
      ),
      MockRouteInstruction(
        id: 'step_5',
        maneuver: NavigationManeuver.arriveDestination,
        instruction: 'Arrive at Emergency Bay, King Edward Memorial Hospital on right',
        distanceMeters: 200,
        roadName: 'KEM Emergency Entrance',
      ),
    ];
  }

  /// Factory creating initial state before ambulance starts rolling.
  factory NavigationProgressState.initial({
    int initialEta = 8,
    double initialDistance = 3.8,
  }) {
    return NavigationProgressState(
      status: NavigationStatus.enRoute,
      remainingEtaMinutes: initialEta,
      remainingDistanceKm: initialDistance,
      routeProgress: 0.05,
      currentInstructionIndex: 0,
      instructions: defaultInstructions(),
      startedAt: DateTime.now(),
    );
  }
}
