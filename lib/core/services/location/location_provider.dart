import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../features/hospital/presentation/providers/hospital_repository_provider.dart';
import '../../errors/app_exception.dart';
import 'geolocator_location_repository.dart';
import 'location_models.dart';
import 'location_repository.dart';
import 'mock_location_repository.dart';

/// Provider exposing the active [LocationRepository] implementation.
/// Dynamically resolves to [GeolocatorLocationRepository] in real Supabase mode,
/// or [MockLocationRepository] in mock / test fixtures mode.
final locationRepositoryProvider = Provider<LocationRepository>((ref) {
  final hospitalRepo = ref.watch(hospitalRepositoryProvider);
  if (hospitalRepo.isRealBackend) {
    return const GeolocatorLocationRepository();
  }
  return MockLocationRepository();
});

/// State representation of the ambulance device's GPS and positioning status.
@immutable
class AmbulanceLocationState {
  const AmbulanceLocationState({
    required this.status,
    this.location,
    this.errorMessage,
  });

  factory AmbulanceLocationState.initial({AmbulanceLocation? initialLocation}) {
    return AmbulanceLocationState(
      status: LocationStateStatus.initial,
      location: initialLocation ?? AmbulanceLocation.defaultMumbai,
    );
  }

  final LocationStateStatus status;
  final AmbulanceLocation? location;
  final String? errorMessage;

  bool get isLoading =>
      status == LocationStateStatus.checkingPermission ||
      status == LocationStateStatus.locating;

  bool get hasLocation => location != null;

  bool get isPermissionDenied =>
      status == LocationStateStatus.permissionDenied ||
      status == LocationStateStatus.permissionDeniedForever;

  bool get isServiceDisabled => status == LocationStateStatus.serviceDisabled;

  bool get isPermissionGranted =>
      status == LocationStateStatus.permissionGranted ||
      status == LocationStateStatus.locating ||
      status == LocationStateStatus.ready;

  AmbulanceLocationState copyWith({
    LocationStateStatus? status,
    AmbulanceLocation? location,
    String? errorMessage,
    bool clearLocation = false,
  }) {
    return AmbulanceLocationState(
      status: status ?? this.status,
      location: clearLocation ? null : (location ?? this.location),
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AmbulanceLocationState &&
        other.status == status &&
        other.location == location &&
        other.errorMessage == errorMessage;
  }

  @override
  int get hashCode => Object.hash(status, location, errorMessage);
}

/// Notifier managing ambulance device location acquisition and permission lifecycle.
class AmbulanceLocationNotifier extends Notifier<AmbulanceLocationState> {
  @override
  AmbulanceLocationState build() {
    final hospitalRepo = ref.watch(hospitalRepositoryProvider);
    if (hospitalRepo.isRealBackend) {
      return const AmbulanceLocationState(
        status: LocationStateStatus.initial,
        location: null,
      );
    }
    return AmbulanceLocationState.initial();
  }

  /// Validates location services and user permissions before allowing GPS acquisition or hospital discovery.
  ///
  /// Required flow:
  /// 1. Check if location services are enabled on the host device (`isLocationServiceEnabled()`).
  ///    - if disabled: status = serviceDisabled, returns false.
  /// 2. If enabled, inspect current permission status (`checkPermission()`).
  ///    - if denied: call `requestPermission()`.
  /// 3. Handle resulting status:
  ///    - if denied: status = permissionDenied, returns false.
  ///    - if deniedForever: status = permissionDeniedForever, returns false.
  ///    - if granted: status = permissionGranted, returns true.
  ///
  /// In real mode, coordinates remain null until Phase B GPS acquisition.
  Future<bool> validateLocationPermission() async {
    final repository = ref.read(locationRepositoryProvider);
    final hospitalRepo = ref.read(hospitalRepositoryProvider);
    final isReal = hospitalRepo.isRealBackend;

    state = state.copyWith(
      status: LocationStateStatus.checkingPermission,
      errorMessage: null,
      clearLocation: isReal,
    );

    // 1. Check location services
    final serviceEnabled = await repository.isLocationServiceEnabled();
    if (!serviceEnabled) {
      state = state.copyWith(
        status: LocationStateStatus.serviceDisabled,
        errorMessage:
            'Device location services are turned off. Please enable GPS in device settings to discover nearby hospitals.',
        clearLocation: isReal,
      );
      return false;
    }

    // 2. Check permission
    var permission = await repository.checkPermission();
    if (permission == LocationPermissionStatus.denied) {
      permission = await repository.requestPermission();
    }

    // 3. Handle resulting status
    if (permission == LocationPermissionStatus.denied) {
      state = state.copyWith(
        status: LocationStateStatus.permissionDenied,
        errorMessage:
            'BedLink requires location permission to calculate distance and find the nearest emergency hospital.',
        clearLocation: isReal,
      );
      return false;
    }

    if (permission == LocationPermissionStatus.deniedForever) {
      state = state.copyWith(
        status: LocationStateStatus.permissionDeniedForever,
        errorMessage:
            'Location permission is permanently blocked in system settings. Please enable location permissions to continue.',
        clearLocation: isReal,
      );
      return false;
    }

    if (permission == LocationPermissionStatus.granted) {
      state = state.copyWith(
        status: state.location != null
            ? LocationStateStatus.ready
            : LocationStateStatus.permissionGranted,
        errorMessage: null,
      );
      return true;
    }

    state = state.copyWith(
      status: LocationStateStatus.error,
      errorMessage: 'Unable to determine location permission status.',
      clearLocation: isReal,
    );
    return false;
  }

  Future<void>? _inFlightAcquisition;

  /// Acquires real current GPS coordinates from the device hardware sensor.
  ///
  /// Prevents duplicate simultaneous acquisitions and ensures repeated widget rebuilds
  /// do not repeatedly trigger GPS queries.
  Future<void> acquireLocation({bool force = false}) async {
    if (_inFlightAcquisition != null) {
      return _inFlightAcquisition;
    }

    if (!force && state.status == LocationStateStatus.ready && state.location != null) {
      return;
    }

    _inFlightAcquisition = _performAcquisition();
    try {
      await _inFlightAcquisition;
    } finally {
      _inFlightAcquisition = null;
    }
  }

  Future<void> _performAcquisition() async {
    final repository = ref.read(locationRepositoryProvider);
    final hospitalRepo = ref.read(hospitalRepositoryProvider);
    final isReal = hospitalRepo.isRealBackend;

    state = state.copyWith(
      status: LocationStateStatus.locating,
      errorMessage: null,
      clearLocation: isReal,
    );

    try {
      final loc = await repository.getCurrentLocation();
      state = state.copyWith(
        status: LocationStateStatus.ready,
        location: loc,
        errorMessage: null,
      );
    } on LocationException catch (e) {
      LocationStateStatus targetStatus;
      if (e.isServiceDisabled) {
        targetStatus = LocationStateStatus.serviceDisabled;
      } else if (e.isPermanentlyDenied) {
        targetStatus = LocationStateStatus.permissionDeniedForever;
      } else if (e.isPermissionDenied) {
        targetStatus = LocationStateStatus.permissionDenied;
      } else {
        targetStatus = LocationStateStatus.error;
      }

      state = state.copyWith(
        status: targetStatus,
        errorMessage: e.message,
        clearLocation: isReal,
      );
    } catch (e) {
      state = state.copyWith(
        status: LocationStateStatus.error,
        errorMessage: 'Failed to acquire location: $e',
        clearLocation: isReal,
      );
    }
  }

  /// Attempts to acquire current device GPS position.
  Future<void> fetchLocation({
    bool requestPermissionIfNeeded = true,
    bool force = false,
  }) async {
    await acquireLocation(force: force);
  }

  /// Explicit retry action for acquiring device location after error or timeout.
  Future<void> retryLocation() async {
    await acquireLocation(force: true);
  }

  /// Explicit refresh action for re-acquiring GPS location.
  Future<void> refreshLocation() async {
    await acquireLocation(force: true);
  }

  /// Opens host system application settings page.
  Future<bool> openAppSettings() async {
    return await ref.read(locationRepositoryProvider).openAppSettings();
  }

  /// Opens host system location settings page.
  Future<bool> openLocationSettings() async {
    return await ref.read(locationRepositoryProvider).openLocationSettings();
  }

  /// Manually injects or overrides current location (e.g. for simulations / tests).
  void setCustomLocation(double lat, double lng, {bool isMock = true}) {
    final custom = AmbulanceLocation(
      latitude: lat,
      longitude: lng,
      capturedAt: DateTime.now(),
      accuracyMeters: 5.0,
      isMock: isMock,
    );
    state = state.copyWith(
      status: LocationStateStatus.ready,
      location: custom,
      errorMessage: null,
    );
  }

  /// Resets state back to initial defaults.
  void reset() {
    final hospitalRepo = ref.read(hospitalRepositoryProvider);
    if (hospitalRepo.isRealBackend) {
      state = const AmbulanceLocationState(
        status: LocationStateStatus.initial,
        location: null,
      );
    } else {
      state = AmbulanceLocationState.initial();
    }
  }
}

/// Global provider for ambulance GPS tracking.
final ambulanceLocationProvider =
    NotifierProvider<AmbulanceLocationNotifier, AmbulanceLocationState>(
  AmbulanceLocationNotifier.new,
);
