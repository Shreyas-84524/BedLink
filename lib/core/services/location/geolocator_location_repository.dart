import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import '../../errors/app_exception.dart';
import '../../errors/error_codes.dart';
import 'location_models.dart';
import 'location_repository.dart';

/// Real device location repository wrapping [Geolocator].
class GeolocatorLocationRepository implements LocationRepository {
  const GeolocatorLocationRepository({
    this.timeout = const Duration(seconds: 10),
  });

  final Duration timeout;

  @override
  bool get isHardwareGps => true;

  @override
  Future<bool> isLocationServiceEnabled() async {
    try {
      return await Geolocator.isLocationServiceEnabled();
    } catch (e) {
      debugPrint('Error checking location service: $e');
      return false;
    }
  }

  @override
  Future<LocationPermissionStatus> checkPermission() async {
    try {
      final permission = await Geolocator.checkPermission();
      return _mapPermission(permission);
    } catch (e) {
      debugPrint('Error checking permission: $e');
      return LocationPermissionStatus.unableToDetermine;
    }
  }

  @override
  Future<LocationPermissionStatus> requestPermission() async {
    try {
      final permission = await Geolocator.requestPermission();
      return _mapPermission(permission);
    } catch (e) {
      debugPrint('Error requesting permission: $e');
      return LocationPermissionStatus.unableToDetermine;
    }
  }

  @override
  Future<AmbulanceLocation> getCurrentLocation() async {
    final serviceEnabled = await isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw const LocationException(
        'Device location services are disabled. Please enable GPS in device settings.',
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
        'Location permission denied by user. Real device location is required for hospital discovery.',
        code: ErrorCodes.locationDenied,
        isPermissionDenied: true,
      );
    }

    if (permission == LocationPermissionStatus.deniedForever) {
      throw const LocationException(
        'Location permission permanently denied. Enable permissions in application settings.',
        code: ErrorCodes.locationDenied,
        isPermanentlyDenied: true,
      );
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: timeout,
        ),
      );

      return AmbulanceLocation(
        latitude: position.latitude,
        longitude: position.longitude,
        accuracyMeters: position.accuracy,
        altitudeMeters: position.altitude,
        headingDegrees: position.heading,
        speedMps: position.speed,
        capturedAt: position.timestamp,
        isMock: position.isMocked,
      );
    } catch (e) {
      throw LocationException(
        'Failed to acquire GPS fix: $e',
        code: ErrorCodes.noLocation,
        cause: e,
      );
    }
  }

  @override
  Future<bool> openAppSettings() async {
    try {
      return await Geolocator.openAppSettings();
    } catch (e) {
      debugPrint('Error opening app settings: $e');
      return false;
    }
  }

  @override
  Future<bool> openLocationSettings() async {
    try {
      return await Geolocator.openLocationSettings();
    } catch (e) {
      debugPrint('Error opening location settings: $e');
      return false;
    }
  }

  LocationPermissionStatus _mapPermission(LocationPermission permission) {
    switch (permission) {
      case LocationPermission.always:
      case LocationPermission.whileInUse:
        return LocationPermissionStatus.granted;
      case LocationPermission.denied:
        return LocationPermissionStatus.denied;
      case LocationPermission.deniedForever:
        return LocationPermissionStatus.deniedForever;
      case LocationPermission.unableToDetermine:
        return LocationPermissionStatus.unableToDetermine;
    }
  }
}
