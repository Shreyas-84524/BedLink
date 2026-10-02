import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../errors/app_exception.dart';
import 'geolocator_location_repository.dart';
import 'location_models.dart';
import 'location_repository.dart';

/// Provider exposing the active [LocationRepository] implementation.
/// Defaults to [GeolocatorLocationRepository], easily overridable in tests.
final locationRepositoryProvider = Provider<LocationRepository>((ref) {
  return const GeolocatorLocationRepository();
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
  }) {
    return AmbulanceLocationState(
      status: status ?? this.status,
      location: location ?? this.location,
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
    return AmbulanceLocationState.initial();
  }

  /// Attempts to acquire current device GPS position.
  Future<void> fetchLocation({bool requestPermissionIfNeeded = true}) async {
    final repository = ref.read(locationRepositoryProvider);

    state = state.copyWith(
      status: LocationStateStatus.locating,
      errorMessage: null,
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
      );
    } catch (e) {
      state = state.copyWith(
        status: LocationStateStatus.error,
        errorMessage: 'Failed to acquire location: $e',
      );
    }
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
    state = AmbulanceLocationState.initial();
  }
}

/// Global provider for ambulance GPS tracking.
final ambulanceLocationProvider =
    NotifierProvider<AmbulanceLocationNotifier, AmbulanceLocationState>(
  AmbulanceLocationNotifier.new,
);
