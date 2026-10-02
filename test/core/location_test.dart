import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bedlink/core/errors/app_exception.dart';
import 'package:bedlink/core/services/location/location_models.dart';
import 'package:bedlink/core/services/location/location_provider.dart';
import 'package:bedlink/core/services/location/mock_location_repository.dart';

void main() {
  group('AmbulanceLocation Model Tests', () {
    test('Default Mumbai location is properly populated', () {
      final loc = AmbulanceLocation.defaultMumbai;
      expect(loc.latitude, equals(18.9980));
      expect(loc.longitude, equals(72.8300));
      expect(loc.isMock, isTrue);
      expect(loc.coordinatesFormatted, equals('18.9980, 72.8300'));
    });

    test('Custom AmbulanceLocation copies and formats correctly', () {
      final captured = DateTime(2026, 10, 3, 12, 0);
      final loc = AmbulanceLocation(
        latitude: 19.0514,
        longitude: 72.8295,
        capturedAt: captured,
        accuracyMeters: 5.2,
        isMock: false,
      );

      expect(loc.latitude, equals(19.0514));
      expect(loc.longitude, equals(72.8295));
      expect(loc.accuracyMeters, equals(5.2));
      expect(loc.isMock, isFalse);
      expect(loc.coordinatesFormatted, equals('19.0514, 72.8295'));

      final modified = loc.copyWith(isMock: true, accuracyMeters: 12.0);
      expect(modified.isMock, isTrue);
      expect(modified.accuracyMeters, equals(12.0));
      expect(modified.latitude, equals(19.0514));
    });
  });

  group('MockLocationRepository Tests', () {
    test('Returns configured location when enabled and granted', () async {
      final repo = MockLocationRepository();
      expect(await repo.isLocationServiceEnabled(), isTrue);
      expect(await repo.checkPermission(), equals(LocationPermissionStatus.granted));

      final loc = await repo.getCurrentLocation();
      expect(loc.latitude, equals(AmbulanceLocation.defaultMumbaiLat));
      expect(loc.longitude, equals(AmbulanceLocation.defaultMumbaiLng));
    });

    test('Throws LocationException when service is disabled', () async {
      final repo = MockLocationRepository(isServiceEnabled: false);
      expect(await repo.isLocationServiceEnabled(), isFalse);

      expect(
        () => repo.getCurrentLocation(),
        throwsA(isA<LocationException>().having((e) => e.isServiceDisabled, 'isServiceDisabled', isTrue)),
      );
    });

    test('Throws LocationException when permission is denied', () async {
      final repo = MockLocationRepository(permissionStatus: LocationPermissionStatus.denied);
      expect(
        () => repo.getCurrentLocation(),
        throwsA(isA<LocationException>().having((e) => e.isPermissionDenied, 'isPermissionDenied', isTrue)),
      );
    });

    test('Throws LocationException when permission is denied forever', () async {
      final repo = MockLocationRepository(permissionStatus: LocationPermissionStatus.deniedForever);
      expect(
        () => repo.getCurrentLocation(),
        throwsA(isA<LocationException>().having((e) => e.isPermanentlyDenied, 'isPermanentlyDenied', isTrue)),
      );
    });

    test('Allows changing mock location dynamically', () async {
      final repo = MockLocationRepository();
      final custom = AmbulanceLocation(
        latitude: 19.0760,
        longitude: 72.8777,
        capturedAt: DateTime.now(),
      );

      repo.setLocation(custom);
      final fetched = await repo.getCurrentLocation();
      expect(fetched.latitude, equals(19.0760));
      expect(fetched.longitude, equals(72.8777));
    });
  });

  group('AmbulanceLocationNotifier & Provider Tests', () {
    test('Initial state provides Central Mumbai fallback coordinates', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final state = container.read(ambulanceLocationProvider);
      expect(state.status, equals(LocationStateStatus.initial));
      expect(state.hasLocation, isTrue);
      expect(state.location?.latitude, equals(AmbulanceLocation.defaultMumbaiLat));
      expect(state.location?.longitude, equals(AmbulanceLocation.defaultMumbaiLng));
      expect(state.isLoading, isFalse);
    });

    test('fetchLocation updates state to ready on success', () async {
      final mockRepo = MockLocationRepository();
      final container = ProviderContainer(
        overrides: [
          locationRepositoryProvider.overrideWithValue(mockRepo),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(ambulanceLocationProvider.notifier);
      await notifier.fetchLocation();

      final state = container.read(ambulanceLocationProvider);
      expect(state.status, equals(LocationStateStatus.ready));
      expect(state.hasLocation, isTrue);
      expect(state.errorMessage, isNull);
    });

    test('fetchLocation handles location service disabled', () async {
      final mockRepo = MockLocationRepository(isServiceEnabled: false);
      final container = ProviderContainer(
        overrides: [
          locationRepositoryProvider.overrideWithValue(mockRepo),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(ambulanceLocationProvider.notifier);
      await notifier.fetchLocation();

      final state = container.read(ambulanceLocationProvider);
      expect(state.status, equals(LocationStateStatus.serviceDisabled));
      expect(state.isServiceDisabled, isTrue);
      expect(state.errorMessage, contains('disabled'));
    });

    test('fetchLocation handles permission denied', () async {
      final mockRepo = MockLocationRepository(permissionStatus: LocationPermissionStatus.denied);
      final container = ProviderContainer(
        overrides: [
          locationRepositoryProvider.overrideWithValue(mockRepo),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(ambulanceLocationProvider.notifier);
      await notifier.fetchLocation();

      final state = container.read(ambulanceLocationProvider);
      expect(state.status, equals(LocationStateStatus.permissionDenied));
      expect(state.isPermissionDenied, isTrue);
    });

    test('setCustomLocation overrides coordinates immediately', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(ambulanceLocationProvider.notifier);
      notifier.setCustomLocation(19.2183, 72.9781);

      final state = container.read(ambulanceLocationProvider);
      expect(state.status, equals(LocationStateStatus.ready));
      expect(state.location?.latitude, equals(19.2183));
      expect(state.location?.longitude, equals(72.9781));
    });

    test('reset restores initial defaults', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(ambulanceLocationProvider.notifier);
      notifier.setCustomLocation(19.2183, 72.9781);
      expect(container.read(ambulanceLocationProvider).location?.latitude, equals(19.2183));

      notifier.reset();
      final resetState = container.read(ambulanceLocationProvider);
      expect(resetState.status, equals(LocationStateStatus.initial));
      expect(resetState.location?.latitude, equals(AmbulanceLocation.defaultMumbaiLat));
    });
  });
}
