import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../ambulance/presentation/providers/intake_provider.dart';
import '../../../ambulance/presentation/providers/requirement_provider.dart';
import '../../../matching/presentation/providers/selected_hospital_provider.dart';
import '../../../reservation/presentation/providers/hold_timer_provider.dart';
import '../../domain/models/navigation_lifecycle.dart';

/// Riverpod Notifier managing mock en-route navigation, route instructions, and arrival lifecycle.
class NavigationStateNotifier extends Notifier<NavigationProgressState> {
  @override
  NavigationProgressState build() {
    final selectedHospital = ref.watch(selectedHospitalProvider);
    final initialEta = selectedHospital?.etaMinutes ?? 8;
    final initialDist = selectedHospital?.distanceKm ?? 3.8;

    return NavigationProgressState.initial(
      initialEta: initialEta,
      initialDistance: initialDist,
    );
  }

  /// Starts the mock navigation transit session.
  void startNavigation() {
    if (state.status.isReady) {
      state = state.copyWith(
        status: NavigationStatus.enRoute,
        startedAt: DateTime.now(),
      );
    }
  }

  /// Deterministically advances navigation progress, reducing ETA and distance, and advancing instructions.
  void advanceProgress() {
    if (state.status.isCompleted) return;

    final currIdx = state.currentInstructionIndex;

    if (currIdx == 0) {
      state = state.copyWith(
        status: NavigationStatus.enRoute,
        currentInstructionIndex: 1,
        remainingEtaMinutes: 6,
        remainingDistanceKm: 2.7,
        routeProgress: 0.30,
      );
    } else if (currIdx == 1) {
      state = state.copyWith(
        status: NavigationStatus.enRoute,
        currentInstructionIndex: 2,
        remainingEtaMinutes: 3,
        remainingDistanceKm: 1.2,
        routeProgress: 0.65,
      );
    } else if (currIdx == 2) {
      state = state.copyWith(
        status: NavigationStatus.enRoute,
        currentInstructionIndex: 3,
        remainingEtaMinutes: 2,
        remainingDistanceKm: 0.5,
        routeProgress: 0.85,
      );
    } else if (currIdx == 3) {
      state = state.copyWith(
        status: NavigationStatus.arriving,
        currentInstructionIndex: 4,
        remainingEtaMinutes: 1,
        remainingDistanceKm: 0.2,
        routeProgress: 0.95,
      );
    } else if (currIdx == 4 && state.status.isArriving) {
      state = state.copyWith(
        status: NavigationStatus.arrived,
        remainingEtaMinutes: 0,
        remainingDistanceKm: 0.0,
        routeProgress: 1.0,
        arrivedAt: DateTime.now(),
      );
    }
  }

  /// Development fixture: directly sets navigation to near arrival (<1 min, 200m).
  void simulateNearArrival() {
    state = state.copyWith(
      status: NavigationStatus.arriving,
      currentInstructionIndex: state.instructions.length - 1,
      remainingEtaMinutes: 1,
      remainingDistanceKm: 0.2,
      routeProgress: 0.95,
    );
  }

  /// Development fixture: directly sets navigation to arrived.
  void simulateArrived() {
    state = state.copyWith(
      status: NavigationStatus.arrived,
      currentInstructionIndex: state.instructions.length - 1,
      remainingEtaMinutes: 0,
      remainingDistanceKm: 0.0,
      routeProgress: 1.0,
      arrivedAt: DateTime.now(),
    );
  }

  /// Confirms arrival of the ambulance at the destination hospital emergency bay.
  /// Only valid when the ambulance status is arriving or arrived.
  void confirmArrival() {
    if (!state.status.canConfirmArrival) return;

    state = state.copyWith(
      status: NavigationStatus.arrived,
      remainingEtaMinutes: 0,
      remainingDistanceKm: 0.0,
      routeProgress: 1.0,
      arrivedAt: DateTime.now(),
    );
  }

  /// Completes patient handoff to the hospital emergency department team.
  void completeHandoff() {
    state = state.copyWith(
      status: NavigationStatus.completed,
      completedAt: DateTime.now(),
    );
  }

  /// Resets the full emergency workflow cleanly for the next triage case.
  /// Resets patient intake, bed requirements, selected hospital, reservation hold, and navigation.
  /// Preserves ambulance authentication and session!
  void resetWorkflow() {
    // 1. Reset navigation state
    state = NavigationProgressState.initial();

    // 2. Reset patient intake state
    ref.read(patientIntakeProvider.notifier).reset();

    // 3. Clear bed requirements
    ref.read(bedRequirementProvider.notifier).clearAll();

    // 4. Clear selected hospital
    ref.read(selectedHospitalProvider.notifier).clearSelection();

    // 5. Reset hold timer
    ref.read(holdTimerProvider.notifier).reset();
  }
}

/// Global provider for ambulance en-route navigation and arrival state.
final navigationStateProvider =
    NotifierProvider<NavigationStateNotifier, NavigationProgressState>(
  NavigationStateNotifier.new,
);
