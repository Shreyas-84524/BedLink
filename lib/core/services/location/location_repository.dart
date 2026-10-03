import 'location_models.dart';

/// Contract for checking GPS permissions, service status, and obtaining device coordinates.
abstract class LocationRepository {
  /// Checks whether hardware location services are enabled on the host device.
  Future<bool> isLocationServiceEnabled();

  /// Inspects current application location permission status without prompting.
  Future<LocationPermissionStatus> checkPermission();

  /// Prompts the user for location access permission.
  Future<LocationPermissionStatus> requestPermission();

  /// Obtains the current device coordinates.
  Future<AmbulanceLocation> getCurrentLocation();

  /// Opens host system application settings page.
  Future<bool> openAppSettings();

  /// Opens host system location settings page.
  Future<bool> openLocationSettings();

  /// Whether this repository is backed by real hardware GPS sensors.
  bool get isHardwareGps;
}
