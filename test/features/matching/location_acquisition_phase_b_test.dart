import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:bedlink/core/errors/app_exception.dart';
import 'package:bedlink/core/errors/error_codes.dart';
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

/// Test spy for verifying Phase B real GPS acquisition behavior.
class PhaseBSpyLocationRepository implements LocationRepository {
  PhaseBSpyLocationRepository({
    this.serviceEnabled = true,
    this.initialPermission = LocationPermissionStatus.granted,
    this.locationToReturn,
    this.shouldTimeout = false,
    this.shouldThrow = false,
    this.errorMessage = 'Hardware GPS sensor error',
    this.acquisitionDelay = Duration.zero,
  });

  bool serviceEnabled;
  LocationPermissionStatus initialPermission;
  AmbulanceLocation? locationToReturn;
  bool shouldTimeout;
  bool shouldThrow;
  String errorMessage;
  Duration acquisitionDelay;

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
    initialPermission = LocationPermissionStatus.granted;
    return initialPermission;
  }

  @override
  Future<AmbulanceLocation> getCurrentLocation() async {
    getCurrentLocationCalls++;
    if (acquisitionDelay > Duration.zero) {
      await Future<void>.delayed(acquisitionDelay);
    }
    if (shouldTimeout) {
      throw const LocationException(
        'GPS acquisition timed out. Please check device location signal and try again.',
        code: ErrorCodes.noLocation,
      );
    }
    if (shouldThrow) {
      throw LocationException(
        errorMessage,
        code: ErrorCodes.noLocation,
      );
    }
    return locationToReturn ??
        AmbulanceLocation(
          latitude: 19.0760,
          longitude: 72.8777,
          capturedAt: DateTime.now(),
          accuracyMeters: 4.5,
          isMock: false,
        );
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
class PhaseBFakeRealHospitalRepository implements HospitalRepository {
  PhaseBFakeRealHospitalRepository([this.hospitals = const []]);
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

  group('Phase B — Real GPS Acquisition Tests', () {
    test('1. granted permission triggers getCurrentPosition()', () async {
      final spyRepo = PhaseBSpyLocationRepository(
        serviceEnabled: true,
        initialPermission: LocationPermissionStatus.granted,
      );
      final fakeRealRepo = PhaseBFakeRealHospitalRepository();

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

      await notifier.acquireLocation();

      expect(spyRepo.getCurrentLocationCalls, equals(1));
      final state = container.read(ambulanceLocationProvider);
      expect(state.status, equals(LocationStateStatus.ready));
    });

    test('2. ready state stores returned coordinates', () async {
      final expectedLoc = AmbulanceLocation(
        latitude: 19.0178,
        longitude: 72.8478,
        capturedAt: DateTime.now(),
        accuracyMeters: 5.0,
        isMock: false,
      );
      final spyRepo = PhaseBSpyLocationRepository(
        locationToReturn: expectedLoc,
      );
      final fakeRealRepo = PhaseBFakeRealHospitalRepository();

      final container = ProviderContainer(
        overrides: [
          hospitalRepositoryProvider.overrideWithValue(fakeRealRepo),
          locationRepositoryProvider.overrideWithValue(spyRepo),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(ambulanceLocationProvider.notifier);
      await notifier.acquireLocation();

      final state = container.read(ambulanceLocationProvider);
      expect(state.status, equals(LocationStateStatus.ready));
      expect(state.location?.latitude, equals(19.0178));
      expect(state.location?.longitude, equals(72.8478));
    });

    test('3. accuracy stored correctly', () async {
      final expectedLoc = AmbulanceLocation(
        latitude: 19.0178,
        longitude: 72.8478,
        capturedAt: DateTime.now(),
        accuracyMeters: 3.25,
        isMock: false,
      );
      final spyRepo = PhaseBSpyLocationRepository(
        locationToReturn: expectedLoc,
      );
      final fakeRealRepo = PhaseBFakeRealHospitalRepository();

      final container = ProviderContainer(
        overrides: [
          hospitalRepositoryProvider.overrideWithValue(fakeRealRepo),
          locationRepositoryProvider.overrideWithValue(spyRepo),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(ambulanceLocationProvider.notifier);
      await notifier.acquireLocation();

      final state = container.read(ambulanceLocationProvider);
      expect(state.location?.accuracyMeters, equals(3.25));
    });

    test('4. timestamp stored', () async {
      final testTime = DateTime(2026, 10, 3, 15, 45, 30);
      final expectedLoc = AmbulanceLocation(
        latitude: 19.0178,
        longitude: 72.8478,
        capturedAt: testTime,
        accuracyMeters: 4.0,
        isMock: false,
      );
      final spyRepo = PhaseBSpyLocationRepository(
        locationToReturn: expectedLoc,
      );
      final fakeRealRepo = PhaseBFakeRealHospitalRepository();

      final container = ProviderContainer(
        overrides: [
          hospitalRepositoryProvider.overrideWithValue(fakeRealRepo),
          locationRepositoryProvider.overrideWithValue(spyRepo),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(ambulanceLocationProvider.notifier);
      await notifier.acquireLocation();

      final state = container.read(ambulanceLocationProvider);
      expect(state.location?.capturedAt, equals(testTime));
    });

    test('5. timeout -> error state', () async {
      final spyRepo = PhaseBSpyLocationRepository(
        shouldTimeout: true,
      );
      final fakeRealRepo = PhaseBFakeRealHospitalRepository();

      final container = ProviderContainer(
        overrides: [
          hospitalRepositoryProvider.overrideWithValue(fakeRealRepo),
          locationRepositoryProvider.overrideWithValue(spyRepo),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(ambulanceLocationProvider.notifier);
      await notifier.acquireLocation();

      final state = container.read(ambulanceLocationProvider);
      expect(state.status, equals(LocationStateStatus.error));
      expect(state.location, isNull);
      expect(state.hasLocation, isFalse);
      expect(state.errorMessage, contains('timed out'));
    });

    test('6. repository error -> error state', () async {
      final spyRepo = PhaseBSpyLocationRepository(
        shouldThrow: true,
        errorMessage: 'Satellite signal lost',
      );
      final fakeRealRepo = PhaseBFakeRealHospitalRepository();

      final container = ProviderContainer(
        overrides: [
          hospitalRepositoryProvider.overrideWithValue(fakeRealRepo),
          locationRepositoryProvider.overrideWithValue(spyRepo),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(ambulanceLocationProvider.notifier);
      await notifier.acquireLocation();

      final state = container.read(ambulanceLocationProvider);
      expect(state.status, equals(LocationStateStatus.error));
      expect(state.location, isNull);
      expect(state.errorMessage, contains('Satellite signal lost'));
    });

    test('7. retry calls location acquisition again', () async {
      final spyRepo = PhaseBSpyLocationRepository(
        shouldThrow: true,
        errorMessage: 'Temporary glitch',
      );
      final fakeRealRepo = PhaseBFakeRealHospitalRepository();

      final container = ProviderContainer(
        overrides: [
          hospitalRepositoryProvider.overrideWithValue(fakeRealRepo),
          locationRepositoryProvider.overrideWithValue(spyRepo),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(ambulanceLocationProvider.notifier);
      await notifier.acquireLocation();

      expect(spyRepo.getCurrentLocationCalls, equals(1));
      expect(container.read(ambulanceLocationProvider).status, equals(LocationStateStatus.error));

      // Clear the error and retry
      spyRepo.shouldThrow = false;
      await notifier.retryLocation();

      expect(spyRepo.getCurrentLocationCalls, equals(2));
      final state = container.read(ambulanceLocationProvider);
      expect(state.status, equals(LocationStateStatus.ready));
      expect(state.location, isNotNull);
    });

    test('8. real mode never injects mock coordinates', () async {
      final fakeRealRepo = PhaseBFakeRealHospitalRepository();

      // 1. Verify real mode resolves to GeolocatorLocationRepository
      final realModeContainer = ProviderContainer(
        overrides: [
          hospitalRepositoryProvider.overrideWithValue(fakeRealRepo),
        ],
      );
      addTearDown(realModeContainer.dispose);

      final repo = realModeContainer.read(locationRepositoryProvider);
      expect(repo, isA<GeolocatorLocationRepository>());
      expect(repo.isHardwareGps, isTrue);

      // 2. When an error occurs during GPS acquisition in real mode
      final spyRepo = PhaseBSpyLocationRepository(
        shouldThrow: true,
      );
      final container = ProviderContainer(
        overrides: [
          hospitalRepositoryProvider.overrideWithValue(fakeRealRepo),
          locationRepositoryProvider.overrideWithValue(spyRepo),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(ambulanceLocationProvider.notifier);
      await notifier.acquireLocation();

      final state = container.read(ambulanceLocationProvider);
      expect(state.status, equals(LocationStateStatus.error));
      expect(state.location, isNull);
      expect(state.hasLocation, isFalse);
    });

    test('9. locating state blocks downstream discovery', () async {
      final fakeRealRepo = PhaseBFakeRealHospitalRepository([MockHospitalData.kemHospital]);
      final spyRepo = PhaseBSpyLocationRepository();

      final container = ProviderContainer(
        overrides: [
          hospitalRepositoryProvider.overrideWithValue(fakeRealRepo),
          locationRepositoryProvider.overrideWithValue(spyRepo),
        ],
      );
      addTearDown(container.dispose);

      // Pre-set state to locating
      container.read(ambulanceLocationProvider.notifier).state = const AmbulanceLocationState(
        status: LocationStateStatus.locating,
        location: null,
      );

      final matchingNotifier = container.read(matchingProvider.notifier);
      await matchingNotifier.runSearchProgression(stepDuration: Duration.zero);

      final matchState = container.read(matchingProvider);
      // Discovery must NOT run while locating!
      expect(matchState.matches, isEmpty);
      expect(fakeRealRepo.getHospitalsCalls, equals(0));
    });

    test('10. repeated rebuild does not trigger duplicate location calls', () async {
      final spyRepo = PhaseBSpyLocationRepository(
        acquisitionDelay: const Duration(milliseconds: 50),
      );
      final fakeRealRepo = PhaseBFakeRealHospitalRepository();

      final container = ProviderContainer(
        overrides: [
          hospitalRepositoryProvider.overrideWithValue(fakeRealRepo),
          locationRepositoryProvider.overrideWithValue(spyRepo),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(ambulanceLocationProvider.notifier);

      // Call acquireLocation concurrently (simulating multiple widget builds / listeners)
      await Future.wait([
        notifier.acquireLocation(),
        notifier.acquireLocation(),
        notifier.acquireLocation(),
      ]);

      // Then call again when already ready
      await notifier.acquireLocation();

      // Only ONE hardware GPS acquisition must have been executed
      expect(spyRepo.getCurrentLocationCalls, equals(1));
    });

    testWidgets('UI Resilience: locating state displays GETTING CURRENT LOCATION...', (tester) async {
      final spyRepo = PhaseBSpyLocationRepository();
      final fakeRealRepo = PhaseBFakeRealHospitalRepository();

      final container = ProviderContainer(
        overrides: [
          hospitalRepositoryProvider.overrideWithValue(fakeRealRepo),
          locationRepositoryProvider.overrideWithValue(spyRepo),
        ],
      );
      addTearDown(container.dispose);

      container.read(ambulanceLocationProvider.notifier).state = const AmbulanceLocationState(
        status: LocationStateStatus.locating,
        location: null,
      );

      await tester.pumpWidget(createTestDiscoveryWidget(container));
      await tester.pump();

      expect(find.text('GETTING CURRENT LOCATION...'), findsOneWidget);
    });

    testWidgets('UI Resilience: error state displays RETRY LOCATION and tapping triggers retry', (tester) async {
      final spyRepo = PhaseBSpyLocationRepository(
        shouldThrow: true,
        errorMessage: 'GPS antenna disconnected',
      );
      final fakeRealRepo = PhaseBFakeRealHospitalRepository();

      final container = ProviderContainer(
        overrides: [
          hospitalRepositoryProvider.overrideWithValue(fakeRealRepo),
          locationRepositoryProvider.overrideWithValue(spyRepo),
        ],
      );
      addTearDown(container.dispose);

      container.read(ambulanceLocationProvider.notifier).state = const AmbulanceLocationState(
        status: LocationStateStatus.error,
        errorMessage: 'GPS antenna disconnected',
        location: null,
      );

      await tester.pumpWidget(createTestDiscoveryWidget(container));
      await tester.pumpAndSettle();

      expect(find.text('UNABLE TO GET CURRENT LOCATION'), findsOneWidget);
      expect(find.widgetWithText(BedLinkButton, 'RETRY LOCATION'), findsOneWidget);

      spyRepo.shouldThrow = false;
      await tester.tap(find.widgetWithText(BedLinkButton, 'RETRY LOCATION'));
      await tester.pumpAndSettle();

      expect(spyRepo.getCurrentLocationCalls, equals(1));
    });

    testWidgets('UI Resilience: ready state displays LOCATION READY card without exact coordinates in UI', (tester) async {
      final spyRepo = PhaseBSpyLocationRepository();
      final fakeRealRepo = PhaseBFakeRealHospitalRepository();

      final container = ProviderContainer(
        overrides: [
          hospitalRepositoryProvider.overrideWithValue(fakeRealRepo),
          locationRepositoryProvider.overrideWithValue(spyRepo),
        ],
      );
      addTearDown(container.dispose);

      container.read(ambulanceLocationProvider.notifier).state = AmbulanceLocationState(
        status: LocationStateStatus.ready,
        location: AmbulanceLocation(
          latitude: 19.0760,
          longitude: 72.8777,
          capturedAt: DateTime.now(),
          accuracyMeters: 4.0,
          isMock: false,
        ),
      );

      await tester.pumpWidget(createTestDiscoveryWidget(container));
      await tester.pumpAndSettle();

      expect(find.text('LOCATION READY'), findsOneWidget);
      // Production UI displays ready confirmation, not raw coordinates
      expect(find.text('Device GPS coordinates acquired. Ready for hospital discovery (Phase C).'), findsOneWidget);
    });
  });
}
