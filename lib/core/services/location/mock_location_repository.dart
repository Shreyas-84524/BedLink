import '../../errors/app_exception.dart';
import '../../errors/error_codes.dart';
import 'location_models.dart';
import 'location_repository.dart';

/// Test fixture and fallback implementation of [LocationRepository].
class MockLocationRepository implements LocationRepository {
  MockLocationRepository({
    AmbulanceLocation? initialLocation,
    this.isServiceEnabled = true,
    this.permissionStatus = LocationPermissionStatus.granted,
    this.shouldThrow = false,
  }) : _currentLocation = initialLocation ?? AmbulanceLocation.defaultMumbai;

  AmbulanceLocation _currentLocation;
  bool isServiceEnabled;
  LocationPermissionStatus permissionStatus;
  bool shouldThrow;

  @override
  bool get isHardwareGps => false;

  void setLocation(AmbulanceLocation location) {
    _currentLocation = location;
  }

  @override
  Future<bool> isLocationServiceEnabled() async {
    return isServiceEnabled;
  }

  @override
  Future<LocationPermissionStatus> checkPermission() async {
    return permissionStatus;
  }

  @override
  Future<LocationPermissionStatus> requestPermission() async {
    if (permissionStatus == LocationPermissionStatus.denied) {
      permissionStatus = LocationPermissionStatus.granted;
    }
    return permissionStatus;
  }

  @override
  Future<AmbulanceLocation> getCurrentLocation() async {
    if (shouldThrow) {
      throw const LocationException(
        'Mock simulated GPS acquisition failure.',
        code: ErrorCodes.noLocation,
      );
    }

    if (!isServiceEnabled) {
      throw const LocationException(
        'Location services are disabled in mock repository.',
        code: ErrorCodes.noLocation,
        isServiceDisabled: true,
      );
    }

    if (permissionStatus == LocationPermissionStatus.denied) {
      throw const LocationException(
        'Location permission denied in mock repository.',
        code: ErrorCodes.locationDenied,
        isPermissionDenied: true,
      );
    }

    if (permissionStatus == LocationPermissionStatus.deniedForever) {
      throw const LocationException(
        'Location permission permanently denied in mock repository.',
        code: ErrorCodes.locationDenied,
        isPermanentlyDenied: true,
      );
    }

    return _currentLocation;
  }

  @override
  Future<bool> openAppSettings() async => true;

  @override
  Future<bool> openLocationSettings() async => true;
}
