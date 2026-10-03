import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:bedlink/core/services/location/geolocator_location_repository.dart';
import 'package:bedlink/core/services/location/location_models.dart';
import 'package:bedlink/core/services/location/location_provider.dart';
import 'package:bedlink/core/services/location/location_repository.dart';
import 'package:bedlink/core/theme/app_theme.dart';
import 'package:bedlink/features/hospital/domain/repositories/hospital_repository.dart';
import 'package:bedlink/features/hospital/presentation/providers/hospital_repository_provider.dart';
import 'package:bedlink/features/matching/data/mock_hospital_data.dart';
import 'package:bedlink/features/matching/domain/models/hospital_match.dart';
import 'package:bedlink/features/matching/presentation/providers/matching_provider.dart';
import 'package:bedlink/features/matching/presentation/screens/hospital_discovery_screen.dart';
import 'package:bedlink/shared/widgets/buttons/bedlink_button.dart';

/// Test spy for verifying permission and location service lifecycle.
class PhaseASpyLocationRepository implements LocationRepository {
  PhaseASpyLocationRepository({
    this.serviceEnabled = true,
    this.initialPermission = LocationPermissionStatus.granted,
    this.denyPermissionOnRequest = false,
    this.permissionOnRequest,
  });

  bool serviceEnabled;
  LocationPermissionStatus initialPermission;
  bool denyPermissionOnRequest;
  LocationPermissionStatus? permissionOnRequest;

  int isLocationServiceEnabledCalls = 0;
  int checkPermissionCalls = 0;
  int requestPermissionCalls = 0;
  int getCurrentLocationCalls = 0;
  int openAppSettingsCalls = 0;
  int openLocationSettingsCalls = 0;

  @override
  bool get isHardwareGps => true;

  @override
  Future<bool> isLocationServiceEnabled() async {
    isLocationServiceEnabledCalls++;
    return serviceEnabled;
  }

  @override
  Future<LocationPermissionStatus> checkPermission() async {
    checkPermissionCalls++;
    return initialPermission;
  }

  @override
  Future<LocationPermissionStatus> requestPermission() async {
    requestPermissionCalls++;
    if (permissionOnRequest != null) {
      initialPermission = permissionOnRequest!;
    } else if (denyPermissionOnRequest) {
      initialPermission = LocationPermissionStatus.denied;
    } else {
      initialPermission = LocationPermissionStatus.granted;
    }
    return initialPermission;
  }

  @override
  Future<AmbulanceLocation> getCurrentLocation() async {
    getCurrentLocationCalls++;
    return AmbulanceLocation.defaultMumbai;
  }

  @override
  Future<bool> openAppSettings() async {
    openAppSettingsCalls++;
    return true;
  }

  @override
  Future<bool> openLocationSettings() async {
    openLocationSettingsCalls++;
    return true;
  }
}

/// Fake real hospital repository for testing discovery queries.
class PhaseAFakeRealHospitalRepository implements HospitalRepository {
  PhaseAFakeRealHospitalRepository([this.hospitals = const []]);
  final List<HospitalMatch> hospitals;

  int getHospitalsCalls = 0;

  @override
  bool get isRealBackend => true;

  @override
  String get dataSourceName => 'SUPABASE_CLOUD';

  @override
  Future<List<HospitalMatch>> getHospitals({bool activeOnly = true}) async {
    getHospitalsCalls++;
    return hospitals;
  }

  @override
  Future<HospitalMatch?> getHospitalById(String id) async {
    return hospitals.where((h) => h.id == id).firstOrNull;
  }
}

void main() {
  Widget createTestDiscoveryWidget(ProviderContainer container) {
    final router = GoRouter(
      initialLocation: '/ambulance/hospitals',
      routes: [
        GoRoute(
          path: '/ambulance/hospitals',
          builder: (context, state) => const HospitalDiscoveryScreen(),
        ),
        GoRoute(
          path: '/ambulance/requirements',
          builder: (context, state) => const Scaffold(body: Text('Requirements Screen')),
        ),
        GoRoute(
          path: '/ambulance/hold',
          builder: (context, state) => const Scaffold(body: Text('Hold Confirmation Screen')),
        ),
      ],
    );

    return UncontrolledProviderScope(
      container: container,
      child: MaterialApp.router(
        theme: AppTheme.lightTheme,
        routerConfig: router,
      ),
    );
  }

  group('Phase A — Location Service & Permission Gate Tests', () {
    test('1. service disabled blocks progress', () async {
      final spyRepo = PhaseASpyLocationRepository(
        serviceEnabled: false,
        initialPermission: LocationPermissionStatus.granted,
      );
      final fakeRealRepo = PhaseAFakeRealHospitalRepository();

      final container = ProviderContainer(
        overrides: [
          hospitalRepositoryProvider.overrideWithValue(fakeRealRepo),
          locationRepositoryProvider.overrideWithValue(spyRepo),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(ambulanceLocationProvider.notifier);
      final permitted = await notifier.validateLocationPermission();

      expect(permitted, isFalse);
      final state = container.read(ambulanceLocationProvider);
      expect(state.status, equals(LocationStateStatus.serviceDisabled));
      expect(state.location, isNull);
      expect(state.hasLocation, isFalse);
      expect(spyRepo.isLocationServiceEnabledCalls, equals(1));
      // Location service disabled blocks further checks & location acquisition!
      expect(spyRepo.checkPermissionCalls, equals(0));
      expect(spyRepo.requestPermissionCalls, equals(0));
      expect(spyRepo.getCurrentLocationCalls, equals(0));
    });

    test('2. denied permission requests permission', () async {
      final spyRepo = PhaseASpyLocationRepository(
        serviceEnabled: true,
        initialPermission: LocationPermissionStatus.denied,
        denyPermissionOnRequest: false, // will become granted on request
      );
      final fakeRealRepo = PhaseAFakeRealHospitalRepository();

      final container = ProviderContainer(
        overrides: [
          hospitalRepositoryProvider.overrideWithValue(fakeRealRepo),
          locationRepositoryProvider.overrideWithValue(spyRepo),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(ambulanceLocationProvider.notifier);
      final permitted = await notifier.validateLocationPermission();

      expect(permitted, isTrue);
      expect(spyRepo.checkPermissionCalls, equals(1));
      expect(spyRepo.requestPermissionCalls, equals(1));
      final state = container.read(ambulanceLocationProvider);
      expect(state.status, equals(LocationStateStatus.permissionGranted));
      expect(spyRepo.getCurrentLocationCalls, equals(0)); // GPS acquisition not started in Phase A
    });

    test('3. denied after request shows ACCESS REQUIRED', () async {
      final spyRepo = PhaseASpyLocationRepository(
        serviceEnabled: true,
        initialPermission: LocationPermissionStatus.denied,
        denyPermissionOnRequest: true, // remains denied after request
      );
      final fakeRealRepo = PhaseAFakeRealHospitalRepository();

      final container = ProviderContainer(
        overrides: [
          hospitalRepositoryProvider.overrideWithValue(fakeRealRepo),
          locationRepositoryProvider.overrideWithValue(spyRepo),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(ambulanceLocationProvider.notifier);
      final permitted = await notifier.validateLocationPermission();

      expect(permitted, isFalse);
      final state = container.read(ambulanceLocationProvider);
      expect(state.status, equals(LocationStateStatus.permissionDenied));
      expect(state.location, isNull);
      expect(spyRepo.checkPermissionCalls, equals(1));
      expect(spyRepo.requestPermissionCalls, equals(1));
      expect(spyRepo.getCurrentLocationCalls, equals(0));
    });

    test('4. denied forever shows APP SETTINGS action', () async {
      final spyRepo = PhaseASpyLocationRepository(
        serviceEnabled: true,
        initialPermission: LocationPermissionStatus.deniedForever,
      );
      final fakeRealRepo = PhaseAFakeRealHospitalRepository();

      final container = ProviderContainer(
        overrides: [
          hospitalRepositoryProvider.overrideWithValue(fakeRealRepo),
          locationRepositoryProvider.overrideWithValue(spyRepo),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(ambulanceLocationProvider.notifier);
      final permitted = await notifier.validateLocationPermission();

      expect(permitted, isFalse);
      final state = container.read(ambulanceLocationProvider);
      expect(state.status, equals(LocationStateStatus.permissionDeniedForever));
      expect(state.location, isNull);

      // Verify openAppSettings action works
      final opened = await notifier.openAppSettings();
      expect(opened, isTrue);
      expect(spyRepo.openAppSettingsCalls, equals(1));
    });

    test('5. granted permission allows progression', () async {
      final spyRepo = PhaseASpyLocationRepository(
        serviceEnabled: true,
        initialPermission: LocationPermissionStatus.granted,
      );
      final fakeRealRepo = PhaseAFakeRealHospitalRepository();

      final container = ProviderContainer(
        overrides: [
          hospitalRepositoryProvider.overrideWithValue(fakeRealRepo),
          locationRepositoryProvider.overrideWithValue(spyRepo),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(ambulanceLocationProvider.notifier);
      final permitted = await notifier.validateLocationPermission();

      expect(permitted, isTrue);
      final state = container.read(ambulanceLocationProvider);
      expect(state.status, equals(LocationStateStatus.permissionGranted));
      expect(state.isPermissionGranted, isTrue);
      // In Phase A, progression to Phase B is allowed, but GPS acquisition has not started
      expect(state.location, isNull);
      expect(spyRepo.getCurrentLocationCalls, equals(0));
    });

    test('6. real mode never falls back to mock coordinates', () {
      final fakeRealRepo = PhaseAFakeRealHospitalRepository();
      final container = ProviderContainer(
        overrides: [
          hospitalRepositoryProvider.overrideWithValue(fakeRealRepo),
        ],
      );
      addTearDown(container.dispose);

      // Verify real mode resolves to GeolocatorLocationRepository
      final repo = container.read(locationRepositoryProvider);
      expect(repo, isA<GeolocatorLocationRepository>());
      expect(repo.isHardwareGps, isTrue);

      // Verify initial state has null coordinates
      final initialLoc = container.read(ambulanceLocationProvider);
      expect(initialLoc.location, isNull);
      expect(initialLoc.hasLocation, isFalse);

      // Verify matching state has null coordinates
      final matchState = container.read(matchingProvider);
      expect(matchState.ambulanceLatitude, isNull);
      expect(matchState.ambulanceLongitude, isNull);
      expect(matchState.isRealBackend, isTrue);
    });

    test('7. hospital discovery does not run before permission success', () async {
      final spyRepo = PhaseASpyLocationRepository(
        serviceEnabled: true,
        initialPermission: LocationPermissionStatus.denied,
        denyPermissionOnRequest: true,
      );
      final fakeRealRepo = PhaseAFakeRealHospitalRepository([MockHospitalData.kemHospital]);

      final container = ProviderContainer(
        overrides: [
          hospitalRepositoryProvider.overrideWithValue(fakeRealRepo),
          locationRepositoryProvider.overrideWithValue(spyRepo),
        ],
      );
      addTearDown(container.dispose);

      final matchingNotifier = container.read(matchingProvider.notifier);
      await matchingNotifier.runSearchProgression(stepDuration: Duration.zero);

      final matchState = container.read(matchingProvider);
      // Matches must remain empty and discovery query must NOT run
      expect(matchState.matches, isEmpty);
      expect(matchState.isSearching, isFalse);
      expect(fakeRealRepo.getHospitalsCalls, equals(0));
      expect(matchState.ambulanceLatitude, isNull);
      expect(matchState.ambulanceLongitude, isNull);
      expect(matchState.errorMessage, contains('permission'));
    });

    testWidgets('UI Resilience: serviceDisabled displays card and actions', (tester) async {
      final spyRepo = PhaseASpyLocationRepository(
        serviceEnabled: false,
      );
      final fakeRealRepo = PhaseAFakeRealHospitalRepository();

      final container = ProviderContainer(
        overrides: [
          hospitalRepositoryProvider.overrideWithValue(fakeRealRepo),
          locationRepositoryProvider.overrideWithValue(spyRepo),
        ],
      );
      addTearDown(container.dispose);

      // Pre-set state to serviceDisabled
      container.read(ambulanceLocationProvider.notifier).state = const AmbulanceLocationState(
        status: LocationStateStatus.serviceDisabled,
        location: null,
      );

      await tester.pumpWidget(createTestDiscoveryWidget(container));
      await tester.pumpAndSettle();

      expect(find.text('LOCATION SERVICES DISABLED'), findsOneWidget);
      expect(find.widgetWithText(BedLinkButton, 'OPEN LOCATION SETTINGS'), findsOneWidget);
      expect(find.widgetWithText(BedLinkButton, 'TRY AGAIN'), findsOneWidget);

      await tester.tap(find.widgetWithText(BedLinkButton, 'OPEN LOCATION SETTINGS'));
      await tester.pump();
      expect(spyRepo.openLocationSettingsCalls, equals(1));
    });

    testWidgets('UI Resilience: permissionDenied displays ACCESS REQUIRED and TRY AGAIN', (tester) async {
      final spyRepo = PhaseASpyLocationRepository(
        serviceEnabled: true,
        initialPermission: LocationPermissionStatus.denied,
        denyPermissionOnRequest: true,
      );
      final fakeRealRepo = PhaseAFakeRealHospitalRepository();

      final container = ProviderContainer(
        overrides: [
          hospitalRepositoryProvider.overrideWithValue(fakeRealRepo),
          locationRepositoryProvider.overrideWithValue(spyRepo),
        ],
      );
      addTearDown(container.dispose);

      container.read(ambulanceLocationProvider.notifier).state = const AmbulanceLocationState(
        status: LocationStateStatus.permissionDenied,
        location: null,
      );

      await tester.pumpWidget(createTestDiscoveryWidget(container));
      await tester.pumpAndSettle();

      expect(find.text('LOCATION ACCESS REQUIRED'), findsOneWidget);
      expect(find.widgetWithText(BedLinkButton, 'TRY AGAIN'), findsOneWidget);

      await tester.tap(find.widgetWithText(BedLinkButton, 'TRY AGAIN'));
      await tester.pump();
      expect(spyRepo.requestPermissionCalls, greaterThanOrEqualTo(1));
    });

    testWidgets('UI Resilience: permissionDeniedForever displays card and OPEN APP SETTINGS', (tester) async {
      final spyRepo = PhaseASpyLocationRepository(
        serviceEnabled: true,
        initialPermission: LocationPermissionStatus.deniedForever,
      );
      final fakeRealRepo = PhaseAFakeRealHospitalRepository();

      final container = ProviderContainer(
        overrides: [
          hospitalRepositoryProvider.overrideWithValue(fakeRealRepo),
          locationRepositoryProvider.overrideWithValue(spyRepo),
        ],
      );
      addTearDown(container.dispose);

      container.read(ambulanceLocationProvider.notifier).state = const AmbulanceLocationState(
        status: LocationStateStatus.permissionDeniedForever,
        location: null,
      );

      await tester.pumpWidget(createTestDiscoveryWidget(container));
      await tester.pumpAndSettle();

      expect(find.text('LOCATION PERMISSION BLOCKED'), findsOneWidget);
      expect(find.widgetWithText(BedLinkButton, 'OPEN APP SETTINGS'), findsOneWidget);
      expect(find.widgetWithText(BedLinkButton, 'TRY AGAIN'), findsOneWidget);

      await tester.tap(find.widgetWithText(BedLinkButton, 'OPEN APP SETTINGS'));
      await tester.pump();
      expect(spyRepo.openAppSettingsCalls, equals(1));
    });

    testWidgets('UI Resilience: permissionGranted in Phase A shows success state without running discovery', (tester) async {
      final spyRepo = PhaseASpyLocationRepository(
        serviceEnabled: true,
        initialPermission: LocationPermissionStatus.granted,
      );
      final fakeRealRepo = PhaseAFakeRealHospitalRepository([MockHospitalData.kemHospital]);

      final container = ProviderContainer(
        overrides: [
          hospitalRepositoryProvider.overrideWithValue(fakeRealRepo),
          locationRepositoryProvider.overrideWithValue(spyRepo),
        ],
      );
      addTearDown(container.dispose);

      container.read(ambulanceLocationProvider.notifier).state = const AmbulanceLocationState(
        status: LocationStateStatus.permissionGranted,
        location: null,
      );

      await tester.pumpWidget(createTestDiscoveryWidget(container));
      await tester.pumpAndSettle();

      expect(find.text('LOCATION PERMISSION GRANTED'), findsOneWidget);
      // Discovery has not started in Phase A:
      expect(fakeRealRepo.getHospitalsCalls, equals(0));
    });
  });
}
