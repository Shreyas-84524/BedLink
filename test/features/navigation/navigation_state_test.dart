import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bedlink/features/ambulance/presentation/providers/intake_provider.dart';
import 'package:bedlink/features/ambulance/presentation/providers/requirement_provider.dart';
import 'package:bedlink/features/matching/data/mock_hospital_data.dart';
import 'package:bedlink/features/matching/presentation/providers/selected_hospital_provider.dart';
import 'package:bedlink/features/navigation/domain/models/navigation_lifecycle.dart';
import 'package:bedlink/features/navigation/domain/models/navigation_step.dart';
import 'package:bedlink/features/navigation/presentation/providers/navigation_state_provider.dart';
import 'package:bedlink/features/reservation/presentation/providers/hold_timer_provider.dart';
import 'package:bedlink/shared/providers/session_provider.dart';

void main() {
  setUp(() {
    HoldTimerNotifier.disablePeriodicTickerForTesting = true;
  });

  tearDown(() {
    HoldTimerNotifier.disablePeriodicTickerForTesting = false;
  });

  group('Navigation Domain Models & Logic Tests (Sub-phase 9.1 & 9.4)', () {
    test('MockRouteInstruction formats distance in meters and km correctly', () {
      const step1 = MockRouteInstruction(
        id: 's1',
        maneuver: NavigationManeuver.continueStraight,
        instruction: 'Straight',
        distanceMeters: 450,
        roadName: 'Main St',
      );
      expect(step1.formattedDistance, equals('450 m'));

      const step2 = MockRouteInstruction(
        id: 's2',
        maneuver: NavigationManeuver.turnLeft,
        instruction: 'Turn Left',
        distanceMeters: 1400,
        roadName: 'Highway',
      );
      expect(step2.formattedDistance, equals('1.4 km'));
    });

    test('NavigationProgressState formattedEta and formattedDistance handle edge cases', () {
      final stateArrived = NavigationProgressState(
        status: NavigationStatus.arrived,
        remainingEtaMinutes: 0,
        remainingDistanceKm: 0.0,
        routeProgress: 1.0,
        currentInstructionIndex: 4,
        instructions: NavigationProgressState.defaultInstructions(),
      );

      expect(stateArrived.formattedEta, equals('ARRIVED'));
      expect(stateArrived.formattedDistance, equals('0 M'));

      final stateArriving = NavigationProgressState(
        status: NavigationStatus.arriving,
        remainingEtaMinutes: 1,
        remainingDistanceKm: 0.4,
        routeProgress: 0.9,
        currentInstructionIndex: 4,
        instructions: NavigationProgressState.defaultInstructions(),
      );

      expect(stateArriving.formattedEta, equals('< 1 MIN'));
      expect(stateArriving.formattedDistance, equals('400 M'));
    });
  });

  group('NavigationStateNotifier Unit Tests (Sub-phase 9.4, 9.6, 9.7)', () {
    test('Initializes with target hospital values or defaults', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final navState = container.read(navigationStateProvider);
      expect(navState.status, equals(NavigationStatus.enRoute));
      expect(navState.currentInstructionIndex, equals(0));
      expect(navState.instructions.isNotEmpty, isTrue);
      expect(navState.remainingEtaMinutes, equals(8));
      expect(navState.remainingDistanceKm, equals(3.8));
    });

    test('advanceProgress steps cleanly from depart through to arrived', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(navigationStateProvider.notifier);

      // Step 0 -> Step 1
      notifier.advanceProgress();
      var state = container.read(navigationStateProvider);
      expect(state.currentInstructionIndex, equals(1));
      expect(state.remainingEtaMinutes, equals(6));
      expect(state.remainingDistanceKm, equals(2.7));

      // Step 1 -> Step 2
      notifier.advanceProgress();
      state = container.read(navigationStateProvider);
      expect(state.currentInstructionIndex, equals(2));
      expect(state.remainingEtaMinutes, equals(3));

      // Step 2 -> Step 3
      notifier.advanceProgress();
      state = container.read(navigationStateProvider);
      expect(state.currentInstructionIndex, equals(3));
      expect(state.remainingEtaMinutes, equals(2));

      // Step 3 -> Step 4 (Arriving at ER approach)
      notifier.advanceProgress();
      state = container.read(navigationStateProvider);
      expect(state.currentInstructionIndex, equals(4));
      expect(state.status, equals(NavigationStatus.arriving));
      expect(state.remainingEtaMinutes, equals(1));
      expect(state.status.canConfirmArrival, isTrue);

      // Step 4 -> Arrived
      notifier.advanceProgress();
      state = container.read(navigationStateProvider);
      expect(state.status, equals(NavigationStatus.arrived));
      expect(state.remainingEtaMinutes, equals(0));
      expect(state.remainingDistanceKm, equals(0.0));
      expect(state.arrivedAt, isNotNull);
    });

    test('simulateNearArrival and simulateArrived shortcuts set accurate state', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(navigationStateProvider.notifier);

      notifier.simulateNearArrival();
      var state = container.read(navigationStateProvider);
      expect(state.status, equals(NavigationStatus.arriving));
      expect(state.remainingEtaMinutes, equals(1));
      expect(state.remainingDistanceKm, equals(0.2));

      notifier.simulateArrived();
      state = container.read(navigationStateProvider);
      expect(state.status, equals(NavigationStatus.arrived));
      expect(state.remainingEtaMinutes, equals(0));
      expect(state.remainingDistanceKm, equals(0.0));
      expect(state.arrivedAt, isNotNull);
    });

    test('confirmArrival is ignored when en route, works when arriving', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(navigationStateProvider.notifier);

      // Status is enRoute: confirmArrival does nothing
      notifier.confirmArrival();
      expect(container.read(navigationStateProvider).status, equals(NavigationStatus.enRoute));

      // Set arriving: confirmArrival works
      notifier.simulateNearArrival();
      notifier.confirmArrival();
      expect(container.read(navigationStateProvider).status, equals(NavigationStatus.arrived));
    });

    test('completeHandoff marks status as completed with completedAt timestamp', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(navigationStateProvider.notifier);
      notifier.completeHandoff();

      final state = container.read(navigationStateProvider);
      expect(state.status, equals(NavigationStatus.completed));
      expect(state.completedAt, isNotNull);
    });

    test('resetWorkflow clears all triage & navigation state but preserves session', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // 1. Authenticate ambulance
      await container.read(sessionProvider.notifier).loginAsAmbulance();
      expect(container.read(sessionProvider).isAuthenticated, isTrue);

      // 2. Populate workflow state across all phases
      container.read(patientIntakeProvider.notifier).fillQuickDemoPreset();
      container.read(bedRequirementProvider.notifier).applyPreset('cardiac_emergency');
      container.read(selectedHospitalProvider.notifier).selectHospital(MockHospitalData.kemHospital);
      container.read(navigationStateProvider.notifier).completeHandoff();

      expect(container.read(patientIntakeProvider).patientName.isNotEmpty, isTrue);
      expect(container.read(bedRequirementProvider).selectedRequirements.isNotEmpty, isTrue);
      expect(container.read(selectedHospitalProvider), isNotNull);
      expect(container.read(navigationStateProvider).status.isCompleted, isTrue);

      // 3. Reset workflow
      container.read(navigationStateProvider.notifier).resetWorkflow();

      // 4. Verify everything is reset
      expect(container.read(patientIntakeProvider).patientName.isEmpty, isTrue);
      expect(container.read(bedRequirementProvider).selectedRequirements.isEmpty, isTrue);
      expect(container.read(selectedHospitalProvider), isNull);
      expect(container.read(navigationStateProvider).status, equals(NavigationStatus.enRoute));
      expect(container.read(navigationStateProvider).currentInstructionIndex, equals(0));

      // 5. Verify ambulance session remains authenticated!
      expect(container.read(sessionProvider).isAuthenticated, isTrue);
      expect(container.read(sessionProvider).isAmbulance, isTrue);
    });
  });
}
