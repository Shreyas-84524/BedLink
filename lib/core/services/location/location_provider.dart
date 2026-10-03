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

  /// Attempts to acquire current device GPS position.
  Future<void> fetchLocation({bool requestPermissionIfNeeded = true}) async {
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
