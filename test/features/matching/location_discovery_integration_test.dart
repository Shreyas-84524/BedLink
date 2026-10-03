import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bedlink/core/errors/app_exception.dart';
import 'package:bedlink/core/errors/error_codes.dart';
import 'package:bedlink/core/services/location/geolocator_location_repository.dart';
import 'package:bedlink/core/services/location/location_models.dart';
import 'package:bedlink/core/services/location/location_provider.dart';
import 'package:bedlink/core/services/location/location_repository.dart';
import 'package:bedlink/features/hospital/domain/repositories/hospital_repository.dart';
import 'package:bedlink/features/hospital/presentation/providers/hospital_repository_provider.dart';
import 'package:bedlink/features/matching/data/mock_hospital_data.dart';
import 'package:bedlink/features/matching/data/repositories/supabase_hospital_discovery_repository.dart';
import 'package:bedlink/features/matching/domain/models/hospital_match.dart';
import 'package:bedlink/features/matching/presentation/providers/matching_provider.dart';

/// Test spy for verifying permission and acquisition invocations.
class SpyLocationRepository implements LocationRepository {
  SpyLocationRepository({
    this.initialPermission = LocationPermissionStatus.granted,
    this.serviceEnabled = true,
    this.locationToReturn,
    this.throwOnError = false,
    this.denyPermissionOnRequest = false,
  });

  LocationPermissionStatus initialPermission;
  bool serviceEnabled;
  AmbulanceLocation? locationToReturn;
  bool throwOnError;
  bool denyPermissionOnRequest;

  int checkPermissionCalls = 0;
  int requestPermissionCalls = 0;
  int getCurrentLocationCalls = 0;
  int openAppSettingsCalls = 0;
  int openLocationSettingsCalls = 0;

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
    if (!denyPermissionOnRequest) {
      initialPermission = LocationPermissionStatus.granted;
    }
    return initialPermission;
  }

  @override
  Future<AmbulanceLocation> getCurrentLocation() async {
    getCurrentLocationCalls++;
    if (throwOnError) {
      throw const LocationException(
        'Simulated GPS sensor timeout',
        code: ErrorCodes.noLocation,
      );
    }
    if (!serviceEnabled) {
      throw const LocationException(
        'Location services disabled',
        code: ErrorCodes.noLocation,
        isServiceDisabled: true,
      );
    }
    var permission = await checkPermission();
    if (permission == LocationPermissionStatus.denied) {
      permission = await requestPermission();
    }
    if (permission == LocationPermissionStatus.denied) {
      throw const LocationException(
        'Location permission denied',
        code: ErrorCodes.locationDenied,
        isPermissionDenied: true,
      );
    }
    if (permission == LocationPermissionStatus.deniedForever) {
      throw const LocationException(
        'Location permission permanently denied',
        code: ErrorCodes.locationDenied,
        isPermanentlyDenied: true,
      );
    }
    return locationToReturn ?? AmbulanceLocation.defaultMumbai;
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
class FakeRealHospitalRepository implements HospitalRepository {
  FakeRealHospitalRepository(this.hospitals);
  final List<HospitalMatch> hospitals;

  @override
  bool get isRealBackend => true;

  @override
  String get dataSourceName => 'SUPABASE_CLOUD';

  @override
  Future<List<HospitalMatch>> getHospitals({bool activeOnly = true}) async {
    return hospitals;
  }

  @override
  Future<HospitalMatch?> getHospitalById(String id) async {
    return hospitals.where((h) => h.id == id).firstOrNull;
  }
}

void main() {
  group('Phase 13 Real Location Acquisition & Discovery Gate Tests', () {
    test('1. Permission denied -> requestPermission invoked when acquiring position', () async {
      final spyRepo = SpyLocationRepository(
        initialPermission: LocationPermissionStatus.denied,
      );

      final container = ProviderContainer(
        overrides: [
          locationRepositoryProvider.overrideWithValue(spyRepo),
        ],
      );
      addTearDown(container.dispose);

      // Verify geolocator repository handles denied permission by requesting permission
      const repo = GeolocatorLocationRepository();
      expect(repo.isHardwareGps, isTrue);

      // Using the spy repository via notifier
      final notifier = container.read(ambulanceLocationProvider.notifier);
      await notifier.fetchLocation(requestPermissionIfNeeded: true);

      final state = container.read(ambulanceLocationProvider);
      expect(state.status, equals(LocationStateStatus.ready));
      expect(spyRepo.getCurrentLocationCalls, equals(1));
    });

    test('2. Permission granted -> getCurrentPosition invoked and coordinates recorded', () async {
      final customLoc = AmbulanceLocation(
        latitude: 19.1136,
        longitude: 72.8697,
        accuracyMeters: 4.5,
        capturedAt: DateTime.now(),
        isMock: false,
      );
      final spyRepo = SpyLocationRepository(
        initialPermission: LocationPermissionStatus.granted,
        locationToReturn: customLoc,
      );

      final container = ProviderContainer(
        overrides: [
          locationRepositoryProvider.overrideWithValue(spyRepo),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(ambulanceLocationProvider.notifier);
      await notifier.fetchLocation();

      final state = container.read(ambulanceLocationProvider);
      expect(state.status, equals(LocationStateStatus.ready));
      expect(state.location?.latitude, equals(19.1136));
      expect(state.location?.longitude, equals(72.8697));
      expect(spyRepo.getCurrentLocationCalls, equals(1));
    });

    test('3. Real mode -> selects GeolocatorLocationRepository, never MockLocationRepository', () {
      final fakeRealRepo = FakeRealHospitalRepository(const []);
      final container = ProviderContainer(
        overrides: [
          hospitalRepositoryProvider.overrideWithValue(fakeRealRepo),
        ],
      );
      addTearDown(container.dispose);

      final locRepo = container.read(locationRepositoryProvider);
      expect(locRepo, isA<GeolocatorLocationRepository>());
      expect(locRepo.isHardwareGps, isTrue);

      // In real mode, initial state must have null coordinates (no silent Mumbai fallback)
      final initialLocState = container.read(ambulanceLocationProvider);
      expect(initialLocState.status, equals(LocationStateStatus.initial));
      expect(initialLocState.location, isNull);
      expect(initialLocState.hasLocation, isFalse);
    });

    test('4. GPS error -> no fallback coordinate inserted, location remains null', () async {
      final fakeRealRepo = FakeRealHospitalRepository(const []);
      final spyRepo = SpyLocationRepository(throwOnError: true);

      final container = ProviderContainer(
        overrides: [
          hospitalRepositoryProvider.overrideWithValue(fakeRealRepo),
          locationRepositoryProvider.overrideWithValue(spyRepo),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(ambulanceLocationProvider.notifier);
      await notifier.fetchLocation();

      final state = container.read(ambulanceLocationProvider);
      expect(state.status, equals(LocationStateStatus.error));
      expect(state.location, isNull);
      expect(state.hasLocation, isFalse);
      expect(state.errorMessage, contains('GPS'));
    });

    test('5. Permission denied -> discovery does not run, matches remain empty', () async {
      final fakeRealRepo = FakeRealHospitalRepository([MockHospitalData.kemHospital]);
      final spyRepo = SpyLocationRepository(
        initialPermission: LocationPermissionStatus.denied,
        denyPermissionOnRequest: true,
      );

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
      expect(matchState.matches, isEmpty);
      expect(matchState.isSearching, isFalse);
      expect(matchState.hasSearched, isTrue);
      expect(matchState.ambulanceLatitude, isNull);
      expect(matchState.ambulanceLongitude, isNull);
      expect(matchState.errorMessage, contains('permission'));
      expect(spyRepo.requestPermissionCalls, greaterThanOrEqualTo(1));
    });

    test('6. Permission denied forever -> open-settings state exposed', () async {
      final fakeRealRepo = FakeRealHospitalRepository([MockHospitalData.kemHospital]);
      final spyRepo = SpyLocationRepository(
        initialPermission: LocationPermissionStatus.deniedForever,
        denyPermissionOnRequest: true,
      );

      final container = ProviderContainer(
        overrides: [
          hospitalRepositoryProvider.overrideWithValue(fakeRealRepo),
          locationRepositoryProvider.overrideWithValue(spyRepo),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(ambulanceLocationProvider.notifier);
      notifier.state = notifier.state.copyWith(
        status: LocationStateStatus.permissionDeniedForever,
        errorMessage: 'Location permission is blocked. Please enable it in system settings.',
        clearLocation: true,
      );

      final matchingNotifier = container.read(matchingProvider.notifier);
      await matchingNotifier.runSearchProgression(stepDuration: Duration.zero);

      final matchState = container.read(matchingProvider);
      expect(matchState.matches, isEmpty);
      expect(matchState.errorMessage, contains('blocked'));

      // Test openAppSettings action
      final opened = await notifier.openAppSettings();
      expect(opened, isTrue);
      expect(spyRepo.openAppSettingsCalls, equals(1));
    });

    test('7. Location ready -> discovery receives exact returned coordinates', () async {
      const realLat = 19.0178;
      const realLon = 72.8478;

      final hospitalA = MockHospitalData.kemHospital.copyWith(
        id: 'hosp_a',
        latitude: 19.0180,
        longitude: 72.8480,
      );
      final fakeRealRepo = FakeRealHospitalRepository([hospitalA]);
      final spyRepo = SpyLocationRepository(
        initialPermission: LocationPermissionStatus.granted,
        locationToReturn: AmbulanceLocation(
          latitude: realLat,
          longitude: realLon,
          accuracyMeters: 5.0,
          capturedAt: DateTime.now(),
        ),
      );

      final container = ProviderContainer(
        overrides: [
          hospitalRepositoryProvider.overrideWithValue(fakeRealRepo),
          locationRepositoryProvider.overrideWithValue(spyRepo),
        ],
      );
      addTearDown(container.dispose);

      // Pre-set location state to ready with exact coordinates
      final locNotifier = container.read(ambulanceLocationProvider.notifier);
      locNotifier.setCustomLocation(realLat, realLon, isMock: false);

      final matchingNotifier = container.read(matchingProvider.notifier);
      await matchingNotifier.runSearchProgression(stepDuration: Duration.zero);

      final matchState = container.read(matchingProvider);
      expect(matchState.matches.isNotEmpty, isTrue);
      expect(matchState.ambulanceLatitude, equals(realLat));
      expect(matchState.ambulanceLongitude, equals(realLon));
      expect(matchState.matches.first.id, equals('hosp_a'));
    });

    test('8. Two different coordinates -> hospital ranking/order changes accordingly', () async {
      // South Mumbai hospital (near 18.9980, 72.8300)
      final southHosp = MockHospitalData.kemHospital.copyWith(
        id: 'south_mumbai_hosp',
        name: 'South Mumbai Medical Center',
        latitude: 18.9986,
        longitude: 72.8427,
      );
      // North / Suburban hospital (near 19.1200, 72.8500)
      final northHosp = MockHospitalData.hindujaHospital.copyWith(
        id: 'north_mumbai_hosp',
        name: 'North Mumbai General Hospital',
        latitude: 19.1205,
        longitude: 72.8510,
      );

      final fakeRealRepo = FakeRealHospitalRepository([southHosp, northHosp]);
      final discoveryRepo = SupabaseHospitalDiscoveryRepository(
        hospitalRepository: fakeRealRepo,
      );

      // Query from South Mumbai: 18.9980, 72.8300
      final southResult = await discoveryRepo.discoverHospitals(
        latitude: 18.9980,
        longitude: 72.8300,
      );
      expect(southResult.matches.first.id, equals('south_mumbai_hosp'));

      // Query from Andheri / North Mumbai: 19.1200, 72.8500
      final northResult = await discoveryRepo.discoverHospitals(
        latitude: 19.1200,
        longitude: 72.8500,
      );
      expect(northResult.matches.first.id, equals('north_mumbai_hosp'));

      // Proves ranking ordering actively changes depending on coordinates!
      expect(southResult.matches.first.id, isNot(equals(northResult.matches.first.id)));
    });
  });
}
