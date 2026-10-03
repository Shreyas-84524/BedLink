import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bedlink/core/errors/app_exception.dart';
import 'package:bedlink/core/errors/error_codes.dart';
import 'package:bedlink/core/services/location/location_models.dart';
import 'package:bedlink/core/services/location/location_provider.dart';
import 'package:bedlink/core/services/location/location_repository.dart';
import 'package:bedlink/core/theme/semantic_tokens.dart';
import 'package:bedlink/features/hospital/domain/repositories/hospital_repository.dart';
import 'package:bedlink/features/hospital/presentation/providers/hospital_repository_provider.dart';
import 'package:bedlink/features/matching/data/mock_hospital_data.dart';
import 'package:bedlink/features/matching/data/repositories/supabase_hospital_discovery_repository.dart';
import 'package:bedlink/features/matching/domain/models/hospital_match.dart';
import 'package:bedlink/features/matching/presentation/providers/matching_provider.dart';
import 'package:bedlink/features/matching/presentation/screens/hospital_discovery_screen.dart';

/// Test spy location repository for Phase C verification.
class PhaseCSpyLocationRepository implements LocationRepository {
  PhaseCSpyLocationRepository({
    this.initialPermission = LocationPermissionStatus.granted,
    this.serviceEnabled = true,
    this.locationToReturn,
    this.shouldThrow = false,
  });

  LocationPermissionStatus initialPermission;
  bool serviceEnabled;
  AmbulanceLocation? locationToReturn;
  bool shouldThrow;

  int checkPermissionCalls = 0;
  int requestPermissionCalls = 0;
  int getCurrentLocationCalls = 0;

  @override
  bool get isHardwareGps => true;

  @override
  Future<bool> isLocationServiceEnabled() async => serviceEnabled;

  @override
  Future<LocationPermissionStatus> checkPermission() async {
    checkPermissionCalls++;
    return initialPermission;
  }

  @override
  Future<LocationPermissionStatus> requestPermission() async {
    requestPermissionCalls++;
    return initialPermission;
  }

  @override
  Future<AmbulanceLocation> getCurrentLocation() async {
    getCurrentLocationCalls++;
    if (shouldThrow) {
      throw const LocationException('GPS Sensor error', code: ErrorCodes.noLocation);
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
  Future<bool> openAppSettings() async => true;

  @override
  Future<bool> openLocationSettings() async => true;
}

/// Fake hospital repository allowing custom hospital datasets and error simulation.
class PhaseCFakeHospitalRepository implements HospitalRepository {
  PhaseCFakeHospitalRepository({
    this.hospitals = const [],
    this.shouldThrow = false,
  });

  List<HospitalMatch> hospitals;
  bool shouldThrow;
  int getHospitalsCalls = 0;

  @override
  bool get isRealBackend => true;

  @override
  String get dataSourceName => 'SUPABASE_CLOUD';

  @override
  Future<List<HospitalMatch>> getHospitals({bool activeOnly = true}) async {
    getHospitalsCalls++;
    if (shouldThrow) {
      throw const HospitalRepositoryException(
        'Database connection timeout.',
        code: ErrorCodes.repositoryError,
      );
    }
    return hospitals;
  }

  @override
  Future<HospitalMatch?> getHospitalById(String id) async {
    try {
      return hospitals.firstWhere((h) => h.id == id);
    } catch (_) {
      return null;
    }
  }
}

/// Helper to wrap HospitalDiscoveryScreen for widget tests.
Widget createTestDiscoveryScreen(ProviderContainer container) {
  return UncontrolledProviderScope(
    container: container,
    child: const MaterialApp(
      home: HospitalDiscoveryScreen(),
    ),
  );
}

void main() {
  group('Phase C — Real Nearby Hospital Discovery Tests', () {
    // -------------------------------------------------------------------------
    // 1. Discovery does not run before location ready
    // -------------------------------------------------------------------------
    test('1. Discovery does not run before location ready (locating or initial)', () async {
      final fakeHospitalRepo = PhaseCFakeHospitalRepository(hospitals: [MockHospitalData.kemHospital]);
      final spyLocRepo = PhaseCSpyLocationRepository();

      final container = ProviderContainer(
        overrides: [
          hospitalRepositoryProvider.overrideWithValue(fakeHospitalRepo),
          locationRepositoryProvider.overrideWithValue(spyLocRepo),
        ],
      );
      addTearDown(container.dispose);

      // In real mode, initial status is initial and location is null
      final locState = container.read(ambulanceLocationProvider);
      expect(locState.status, equals(LocationStateStatus.initial));
      expect(locState.location, isNull);

      // Directly set locating status
      container.read(ambulanceLocationProvider.notifier).state = const AmbulanceLocationState(
        status: LocationStateStatus.locating,
        location: null,
      );

      final matchingNotifier = container.read(matchingProvider.notifier);
      await matchingNotifier.runSearchProgression(stepDuration: Duration.zero);

      final matchState = container.read(matchingProvider);
      // Discovery must not have queried hospitals while locating!
      expect(fakeHospitalRepo.getHospitalsCalls, equals(0));
      expect(matchState.matches, isEmpty);
      expect(matchState.ambulanceLatitude, isNull);
    });

    test('1b. Discovery blocks when permission or service is not ready', () async {
      final fakeHospitalRepo = PhaseCFakeHospitalRepository(hospitals: [MockHospitalData.kemHospital]);
      final spyLocRepo = PhaseCSpyLocationRepository(
        serviceEnabled: false,
      );

      final container = ProviderContainer(
        overrides: [
          hospitalRepositoryProvider.overrideWithValue(fakeHospitalRepo),
          locationRepositoryProvider.overrideWithValue(spyLocRepo),
        ],
      );
      addTearDown(container.dispose);

      final matchingNotifier = container.read(matchingProvider.notifier);
      await matchingNotifier.runSearchProgression(stepDuration: Duration.zero);

      final matchState = container.read(matchingProvider);
      expect(matchState.matches, isEmpty);
      expect(matchState.errorMessage, contains('disabled'));
      expect(fakeHospitalRepo.getHospitalsCalls, equals(0));
    });

    // -------------------------------------------------------------------------
    // 2. Exact real coordinates are passed into discovery
    // -------------------------------------------------------------------------
    test('2. Exact real coordinates are passed into discovery', () async {
      const realLat = 19.1136;
      const realLon = 72.8697;

      final hospital = MockHospitalData.kemHospital.copyWith(
        id: 'hosp_exact',
        latitude: 19.1140,
        longitude: 72.8700,
      );
      final fakeHospitalRepo = PhaseCFakeHospitalRepository(hospitals: [hospital]);
      final spyLocRepo = PhaseCSpyLocationRepository(
        locationToReturn: AmbulanceLocation(
          latitude: realLat,
          longitude: realLon,
          capturedAt: DateTime.now(),
          accuracyMeters: 3.5,
          isMock: false,
        ),
      );

      final container = ProviderContainer(
        overrides: [
          hospitalRepositoryProvider.overrideWithValue(fakeHospitalRepo),
          locationRepositoryProvider.overrideWithValue(spyLocRepo),
        ],
      );
      addTearDown(container.dispose);

      // Acquire real GPS
      await container.read(ambulanceLocationProvider.notifier).acquireLocation();
      expect(container.read(ambulanceLocationProvider).status, equals(LocationStateStatus.ready));

      final matchingNotifier = container.read(matchingProvider.notifier);
      await matchingNotifier.runSearchProgression(stepDuration: Duration.zero);

      final matchState = container.read(matchingProvider);
      expect(matchState.ambulanceLatitude, equals(realLat));
      expect(matchState.ambulanceLongitude, equals(realLon));
      expect(matchState.matches.isNotEmpty, isTrue);
      expect(matchState.matches.first.id, equals('hosp_exact'));
      expect(fakeHospitalRepo.getHospitalsCalls, equals(1));
    });

    // -------------------------------------------------------------------------
    // 3. Null-coordinate hospitals excluded
    // -------------------------------------------------------------------------
    test('3. Safely excludes hospitals with null or NaN coordinates', () async {
      final validHosp = MockHospitalData.kemHospital.copyWith(
        id: 'valid_hosp',
        latitude: 19.0000,
        longitude: 72.8300,
      );
      const nullHosp = HospitalMatch(
        id: 'null_coord_hosp',
        name: 'Null Coordinate Clinic',
        address: 'Unknown',
        area: 'Mumbai',
        distanceKm: 5.0,
        etaMinutes: 10,
        updatedMinutesAgo: 2,
        freshnessState: FreshnessState.fresh,
        loadState: HospitalLoadState.low,
        occupancyRate: 40,
        rank: 2,
        recommendationTier: RecommendationTier.compatible,
        matchScore: 85.0,
        availableBedCounts: {},
        supportedCapabilities: {},
        routeSummary: '',
        emergencyPhone: '',
        latitude: null,
        longitude: null,
      );
      final nanHosp = MockHospitalData.kemHospital.copyWith(
        id: 'nan_coord_hosp',
        latitude: double.nan,
        longitude: 72.8300,
      );

      final fakeRepo = PhaseCFakeHospitalRepository(hospitals: [validHosp, nullHosp, nanHosp]);
      final discoveryRepo = SupabaseHospitalDiscoveryRepository(hospitalRepository: fakeRepo);

      final result = await discoveryRepo.discoverHospitals(
        latitude: 19.0000,
        longitude: 72.8300,
      );

      expect(result.totalEvaluated, equals(3));
      expect(result.totalWithCoordinates, equals(1));
      expect(result.matches.length, equals(1));
      expect(result.matches.first.id, equals('valid_hosp'));
    });

    // -------------------------------------------------------------------------
    // 4. 5 km search results
    // -------------------------------------------------------------------------
    test('4. 5 km search finds candidates within 5km without expanding', () async {
      // Ambulance at 18.9980, 72.8300
      // Hosp 1 at ~1.4 km
      final hosp1 = MockHospitalData.kemHospital.copyWith(
        id: 'hosp_1_4km',
        latitude: 18.9986,
        longitude: 72.8427,
      );
      // Hosp 2 at ~3.2 km
      final hosp2 = MockHospitalData.hindujaHospital.copyWith(
        id: 'hosp_3_2km',
        latitude: 19.0200,
        longitude: 72.8400,
      );

      final fakeRepo = PhaseCFakeHospitalRepository(hospitals: [hosp1, hosp2]);
      final discoveryRepo = SupabaseHospitalDiscoveryRepository(hospitalRepository: fakeRepo);

      final result = await discoveryRepo.discoverHospitals(
        latitude: 18.9980,
        longitude: 72.8300,
      );

      expect(result.effectiveRadiusKm, equals(5));
      expect(result.matches.length, equals(2));
      for (final m in result.matches) {
        expect(m.distanceKm, lessThanOrEqualTo(5.0));
      }
    });

    // -------------------------------------------------------------------------
    // 5. 10 km expansion
    // -------------------------------------------------------------------------
    test('5. 10 km expansion occurs when fewer than 2 candidates within 5km', () async {
      // Hosp 1 at ~1.4 km (within 5 km)
      final hosp1 = MockHospitalData.kemHospital.copyWith(
        id: 'hosp_close',
        latitude: 18.9986,
        longitude: 72.8427,
      );
      // Hosp 2 at ~7.5 km (within 10 km, but outside 5 km)
      final hosp2 = MockHospitalData.hindujaHospital.copyWith(
        id: 'hosp_mid',
        latitude: 19.0600,
        longitude: 72.8350,
      );

      final fakeRepo = PhaseCFakeHospitalRepository(hospitals: [hosp1, hosp2]);
      final discoveryRepo = SupabaseHospitalDiscoveryRepository(hospitalRepository: fakeRepo);

      final result = await discoveryRepo.discoverHospitals(
        latitude: 18.9980,
        longitude: 72.8300,
      );

      expect(result.effectiveRadiusKm, equals(10));
      expect(result.matches.length, equals(2));
      expect(result.matches.map((m) => m.id), containsAll(['hosp_close', 'hosp_mid']));
    });

    // -------------------------------------------------------------------------
    // 6. 15 km expansion
    // -------------------------------------------------------------------------
    test('6. 15 km expansion occurs when fewer than 2 candidates within 10km', () async {
      // Hosp 1 at ~7.5 km (only 1 within 10 km, 0 within 5 km)
      final hosp1 = MockHospitalData.kemHospital.copyWith(
        id: 'hosp_mid',
        latitude: 19.0600,
        longitude: 72.8350,
      );
      // Hosp 2 at ~13.5 km (within 15 km)
      final hosp2 = MockHospitalData.hindujaHospital.copyWith(
        id: 'hosp_far',
        latitude: 19.1200,
        longitude: 72.8350,
      );

      final fakeRepo = PhaseCFakeHospitalRepository(hospitals: [hosp1, hosp2]);
      final discoveryRepo = SupabaseHospitalDiscoveryRepository(hospitalRepository: fakeRepo);

      final result = await discoveryRepo.discoverHospitals(
        latitude: 18.9980,
        longitude: 72.8300,
      );

      expect(result.effectiveRadiusKm, equals(15));
      expect(result.matches.length, equals(2));
      expect(result.matches.map((m) => m.id), containsAll(['hosp_mid', 'hosp_far']));
    });

    // -------------------------------------------------------------------------
    // 7. No-match case
    // -------------------------------------------------------------------------
    test('7. No-match case returns empty matches list and stops at 15km max', () async {
      // Hospital at 25 km away (> 15 km)
      final distantHosp = MockHospitalData.kemHospital.copyWith(
        id: 'hosp_distant',
        latitude: 19.3000,
        longitude: 72.8500,
      );

      final fakeRepo = PhaseCFakeHospitalRepository(hospitals: [distantHosp]);
      final discoveryRepo = SupabaseHospitalDiscoveryRepository(hospitalRepository: fakeRepo);

      final result = await discoveryRepo.discoverHospitals(
        latitude: 18.9980,
        longitude: 72.8300,
      );

      expect(result.effectiveRadiusKm, equals(15));
      expect(result.matches, isEmpty);
      expect(result.isEmpty, isTrue);
    });

    testWidgets('7b. No-match case renders frozen Phase 6 empty state with recovery actions', (tester) async {
      // Hospital at 25 km away (> 15 km)
      final distantHosp = MockHospitalData.kemHospital.copyWith(
        id: 'hosp_distant',
        latitude: 19.3000,
        longitude: 72.8500,
      );
      final fakeHospitalRepo = PhaseCFakeHospitalRepository(hospitals: [distantHosp]);
      final spyLocRepo = PhaseCSpyLocationRepository(
        locationToReturn: AmbulanceLocation(
          latitude: 19.0000,
          longitude: 72.8300,
          capturedAt: DateTime.now(),
          accuracyMeters: 5.0,
          isMock: false,
        ),
      );

      final container = ProviderContainer(
        overrides: [
          hospitalRepositoryProvider.overrideWithValue(fakeHospitalRepo),
          locationRepositoryProvider.overrideWithValue(spyLocRepo),
        ],
      );
      addTearDown(container.dispose);

      // Pre-set location state to ready
      container.read(ambulanceLocationProvider.notifier).state = AmbulanceLocationState(
        status: LocationStateStatus.ready,
        location: AmbulanceLocation(
          latitude: 19.0000,
          longitude: 72.8300,
          capturedAt: DateTime.now(),
          accuracyMeters: 5.0,
          isMock: false,
        ),
      );

      // Run search progression
      await container.read(matchingProvider.notifier).runSearchProgression(stepDuration: Duration.zero);

      await tester.pumpWidget(createTestDiscoveryScreen(container));
      await tester.pumpAndSettle();

      // Verifies the frozen Phase 6 empty state and recovery buttons
      expect(find.text('NO COMPATIBLE HOSPITALS FOUND'), findsOneWidget);
      expect(find.text('EXPAND SEARCH RADIUS TO 30 KM'), findsOneWidget);
      expect(find.text('RELAX REQUIREMENTS'), findsOneWidget);
    });

    // -------------------------------------------------------------------------
    // 8. Candidates sorted by real distance
    // -------------------------------------------------------------------------
    test('8. Candidates sorted ascending by real geographic distance', () async {
      // Ambulance at 18.9980, 72.8300
      final hospNear = MockHospitalData.kemHospital.copyWith(
        id: 'hosp_near',
        latitude: 18.9986, // ~1.4 km
        longitude: 72.8427,
      );
      final hospMid = MockHospitalData.sionHospital.copyWith(
        id: 'hosp_mid',
        latitude: 19.0150, // ~2.0 km
        longitude: 72.8350,
      );
      final hospFar = MockHospitalData.hindujaHospital.copyWith(
        id: 'hosp_far',
        latitude: 19.0300, // ~3.6 km
        longitude: 72.8350,
      );

      // Pass out of order to ensure repository sorts properly
      final fakeRepo = PhaseCFakeHospitalRepository(hospitals: [hospFar, hospNear, hospMid]);
      final discoveryRepo = SupabaseHospitalDiscoveryRepository(hospitalRepository: fakeRepo);

      final result = await discoveryRepo.discoverHospitals(
        latitude: 18.9980,
        longitude: 72.8300,
      );

      expect(result.matches.length, equals(3));
      expect(result.matches[0].id, equals('hosp_near'));
      expect(result.matches[0].rank, equals(1));
      expect(result.matches[1].id, equals('hosp_mid'));
      expect(result.matches[1].rank, equals(2));
      expect(result.matches[2].id, equals('hosp_far'));
      expect(result.matches[2].rank, equals(3));
      expect(result.matches[0].distanceKm, lessThan(result.matches[1].distanceKm));
      expect(result.matches[1].distanceKm, lessThan(result.matches[2].distanceKm));
    });

    // -------------------------------------------------------------------------
    // 9. Changing ambulance coordinates changes hospital ordering
    // -------------------------------------------------------------------------
    test('9. Changing ambulance coordinates alters hospital ordering', () async {
      final southHosp = MockHospitalData.kemHospital.copyWith(
        id: 'south_hosp',
        name: 'South Medical Hub',
        latitude: 18.9986,
        longitude: 72.8427,
      );
      final northHosp = MockHospitalData.hindujaHospital.copyWith(
        id: 'north_hosp',
        name: 'North General Hospital',
        latitude: 19.1205,
        longitude: 72.8510,
      );

      final fakeRepo = PhaseCFakeHospitalRepository(hospitals: [southHosp, northHosp]);
      final discoveryRepo = SupabaseHospitalDiscoveryRepository(hospitalRepository: fakeRepo);

      // Origin South Mumbai: 18.9980, 72.8300
      final resultSouth = await discoveryRepo.discoverHospitals(
        latitude: 18.9980,
        longitude: 72.8300,
      );
      expect(resultSouth.matches.first.id, equals('south_hosp'));

      // Origin North Mumbai: 19.1200, 72.8500
      final resultNorth = await discoveryRepo.discoverHospitals(
        latitude: 19.1200,
        longitude: 72.8500,
      );
      expect(resultNorth.matches.first.id, equals('north_hosp'));
    });

    // -------------------------------------------------------------------------
    // 10. ICU compatibility check
    // -------------------------------------------------------------------------
    test('10. Hospital with available ICU beds matches; hospital with 0 ICU beds excluded', () async {
      final hospWithIcu = MockHospitalData.kemHospital.copyWith(
        id: 'hosp_with_icu',
        latitude: 18.9986,
        longitude: 72.8427,
        availableBedCounts: {'icu_bed': 3, 'general_bed': 10},
        supportedCapabilities: {'icu_care', 'emergency_care'},
      );
      final hospWithoutIcu = MockHospitalData.tataMemorialHospital.copyWith(
        id: 'hosp_no_icu',
        latitude: 19.0020,
        longitude: 72.8410,
        availableBedCounts: {'icu_bed': 0, 'general_bed': 10},
        supportedCapabilities: {'emergency_care'}, // No icu_care
      );

      final fakeRepo = PhaseCFakeHospitalRepository(hospitals: [hospWithIcu, hospWithoutIcu]);
      final discoveryRepo = SupabaseHospitalDiscoveryRepository(hospitalRepository: fakeRepo);

      final result = await discoveryRepo.discoverHospitals(
        latitude: 18.9980,
        longitude: 72.8300,
        selectedRequirements: {'icu_bed': 1},
      );

      expect(result.matches.length, equals(1));
      expect(result.matches.first.id, equals('hosp_with_icu'));
    });

    // -------------------------------------------------------------------------
    // 11. Emergency compatibility check
    // -------------------------------------------------------------------------
    test('11. Hospital with Emergency capability matches; hospital without is excluded', () async {
      final hospWithEd = MockHospitalData.kemHospital.copyWith(
        id: 'hosp_ed',
        latitude: 18.9986,
        longitude: 72.8427,
        availableBedCounts: {'emergency_bed': 5},
        supportedCapabilities: {'emergency_care'},
      );
      final hospWithoutEd = MockHospitalData.hindujaHospital.copyWith(
        id: 'hosp_no_ed',
        latitude: 19.0020,
        longitude: 72.8410,
        availableBedCounts: {'emergency_bed': 0},
        supportedCapabilities: {'general_care'},
      );

      final fakeRepo = PhaseCFakeHospitalRepository(hospitals: [hospWithEd, hospWithoutEd]);
      final discoveryRepo = SupabaseHospitalDiscoveryRepository(hospitalRepository: fakeRepo);

      final result = await discoveryRepo.discoverHospitals(
        latitude: 18.9980,
        longitude: 72.8300,
        selectedRequirements: {'emergency_bed': 1},
      );

      expect(result.matches.length, equals(1));
      expect(result.matches.first.id, equals('hosp_ed'));
    });

    // -------------------------------------------------------------------------
    // 12. Trauma compatibility check
    // -------------------------------------------------------------------------
    test('12. Hospital with Trauma capability matches; hospital without is excluded', () async {
      final hospWithTrauma = MockHospitalData.kemHospital.copyWith(
        id: 'hosp_trauma',
        latitude: 18.9986,
        longitude: 72.8427,
        supportedCapabilities: {'trauma_care', 'emergency_care'},
      );
      final hospWithoutTrauma = MockHospitalData.hindujaHospital.copyWith(
        id: 'hosp_no_trauma',
        latitude: 19.0020,
        longitude: 72.8410,
        supportedCapabilities: {'emergency_care'}, // Missing trauma_care
      );

      final fakeRepo = PhaseCFakeHospitalRepository(hospitals: [hospWithTrauma, hospWithoutTrauma]);
      final discoveryRepo = SupabaseHospitalDiscoveryRepository(hospitalRepository: fakeRepo);

      final result = await discoveryRepo.discoverHospitals(
        latitude: 18.9980,
        longitude: 72.8300,
        selectedRequirements: {'trauma_care': 1},
      );

      expect(result.matches.length, equals(1));
      expect(result.matches.first.id, equals('hosp_trauma'));
    });

    // -------------------------------------------------------------------------
    // 13. Unsupported requirements stay unverified
    // -------------------------------------------------------------------------
    test('13. Unsupported requirements are flagged in result and do not reject compatible hospital', () async {
      final hosp = MockHospitalData.kemHospital.copyWith(
        id: 'hosp_standard',
        latitude: 18.9986,
        longitude: 72.8427,
        availableBedCounts: {'icu_bed': 2},
        supportedCapabilities: {'icu_care'},
      );

      final fakeRepo = PhaseCFakeHospitalRepository(hospitals: [hosp]);
      final discoveryRepo = SupabaseHospitalDiscoveryRepository(hospitalRepository: fakeRepo);

      final result = await discoveryRepo.discoverHospitals(
        latitude: 18.9980,
        longitude: 72.8300,
        selectedRequirements: {
          'icu_bed': 1,
          'ventilator': 1,
          'oxygen_bed': 1,
          'cardiac_care': 1,
          'burns_care': 1,
          'pediatric_icu_bed': 1,
        },
      );

      // Hospital is still returned because ventilator/oxygen/cardiac are unsupported by backend
      expect(result.matches.length, equals(1));
      expect(result.unsupportedRequirementsRequested, contains('ventilator'));
      expect(result.unsupportedRequirementsRequested, contains('oxygen_bed'));
      expect(result.unsupportedRequirementsRequested, contains('cardiac_care'));
      expect(result.unsupportedRequirementsRequested, contains('burns_care'));
      expect(result.unsupportedRequirementsRequested, contains('pediatric_icu_bed'));
    });

    // -------------------------------------------------------------------------
    // 14. Repository failure handled safely
    // -------------------------------------------------------------------------
    test('14. Repository failure returns empty matches with error message safely', () async {
      final fakeRepo = PhaseCFakeHospitalRepository(shouldThrow: true);
      final discoveryRepo = SupabaseHospitalDiscoveryRepository(hospitalRepository: fakeRepo);

      final result = await discoveryRepo.discoverHospitals(
        latitude: 18.9980,
        longitude: 72.8300,
      );

      expect(result.matches, isEmpty);
      expect(result.errorMessage, contains('Database connection timeout'));
    });

    testWidgets('14b. UI displays DISCOVERY SEARCH FAILED error state on repository failure', (tester) async {
      final fakeHospitalRepo = PhaseCFakeHospitalRepository(shouldThrow: true);
      final spyLocRepo = PhaseCSpyLocationRepository(
        locationToReturn: AmbulanceLocation(
          latitude: 19.0000,
          longitude: 72.8300,
          capturedAt: DateTime.now(),
          accuracyMeters: 5.0,
          isMock: false,
        ),
      );

      final container = ProviderContainer(
        overrides: [
          hospitalRepositoryProvider.overrideWithValue(fakeHospitalRepo),
          locationRepositoryProvider.overrideWithValue(spyLocRepo),
        ],
      );
      addTearDown(container.dispose);

      container.read(ambulanceLocationProvider.notifier).state = AmbulanceLocationState(
        status: LocationStateStatus.ready,
        location: AmbulanceLocation(
          latitude: 19.0000,
          longitude: 72.8300,
          capturedAt: DateTime.now(),
          accuracyMeters: 5.0,
          isMock: false,
        ),
      );

      await container.read(matchingProvider.notifier).runSearchProgression(stepDuration: Duration.zero);

      await tester.pumpWidget(createTestDiscoveryScreen(container));
      await tester.pumpAndSettle();

      expect(find.text('DISCOVERY SEARCH FAILED'), findsOneWidget);
      expect(find.text('TRY AGAIN'), findsOneWidget);
    });

    // -------------------------------------------------------------------------
    // 15. No hardcoded Mumbai coordinate used in real path
    // -------------------------------------------------------------------------
    test('15. Real mode never injects or falls back to hardcoded Mumbai coordinates', () async {
      final fakeHospitalRepo = PhaseCFakeHospitalRepository(hospitals: [MockHospitalData.kemHospital]);
      final spyLocRepo = PhaseCSpyLocationRepository();

      final container = ProviderContainer(
        overrides: [
          hospitalRepositoryProvider.overrideWithValue(fakeHospitalRepo),
          locationRepositoryProvider.overrideWithValue(spyLocRepo),
        ],
      );
      addTearDown(container.dispose);

      // Verify initial state
      final locState = container.read(ambulanceLocationProvider);
      expect(locState.location, isNull);

      final matchState = container.read(matchingProvider);
      expect(matchState.ambulanceLatitude, isNull);
      expect(matchState.ambulanceLongitude, isNull);
      expect(matchState.isRealBackend, isTrue);

      // Trigger search progression while location is not ready
      await container.read(matchingProvider.notifier).runSearchProgression(stepDuration: Duration.zero);

      final updatedMatchState = container.read(matchingProvider);
      // In real mode, coordinates must NEVER silently become 18.9980, 72.8300!
      expect(updatedMatchState.ambulanceLatitude, isNot(equals(18.9980)));
      expect(updatedMatchState.ambulanceLongitude, isNot(equals(72.8300)));
    });

    // -------------------------------------------------------------------------
    // 16. Frozen Phase 6 UI components preserved when candidates match
    // -------------------------------------------------------------------------
    testWidgets('16. Real candidate renders in PrimaryHospitalCard with real name, address, and straight-line distance', (tester) async {
      final realHosp = MockHospitalData.kemHospital.copyWith(
        id: 'kem_real_uuid',
        name: 'KEM Memorial Real Hospital',
        address: 'Acharya Donde Marg, Parel, Mumbai',
        area: 'Ward F/S, Mumbai',
        latitude: 19.0010,
        longitude: 72.8310,
        availableBedCounts: {'icu_bed': 4, 'emergency_bed': 6, 'general_bed': 15},
        supportedCapabilities: {'trauma_care', 'emergency_care', 'icu_care'},
      );

      final fakeHospitalRepo = PhaseCFakeHospitalRepository(hospitals: [realHosp]);
      final spyLocRepo = PhaseCSpyLocationRepository(
        locationToReturn: AmbulanceLocation(
          latitude: 19.0000,
          longitude: 72.8300,
          capturedAt: DateTime.now(),
          accuracyMeters: 5.0,
          isMock: false,
        ),
      );

      final container = ProviderContainer(
        overrides: [
          hospitalRepositoryProvider.overrideWithValue(fakeHospitalRepo),
          locationRepositoryProvider.overrideWithValue(spyLocRepo),
        ],
      );
      addTearDown(container.dispose);

      container.read(ambulanceLocationProvider.notifier).state = AmbulanceLocationState(
        status: LocationStateStatus.ready,
        location: AmbulanceLocation(
          latitude: 19.0000,
          longitude: 72.8300,
          capturedAt: DateTime.now(),
          accuracyMeters: 5.0,
          isMock: false,
        ),
      );

      await container.read(matchingProvider.notifier).runSearchProgression(stepDuration: Duration.zero);

      await tester.pumpWidget(createTestDiscoveryScreen(container));
      await tester.pumpAndSettle();

      // Verify real hospital details rendered in frozen UI
      expect(find.text('KEM Memorial Real Hospital'), findsOneWidget);
      expect(find.textContaining('Acharya Donde Marg, Parel'), findsOneWidget);
      expect(find.text('PRIMARY RECOMMENDATION'), findsOneWidget);
      expect(find.text('REQUEST 2-MIN BED HOLD'), findsOneWidget);
    });
  });
}
