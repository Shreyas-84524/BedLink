import 'package:flutter/foundation.dart';

/// Permission status for device location access.
enum LocationPermissionStatus {
  granted,
  denied,
  deniedForever,
  serviceDisabled,
  unableToDetermine,
}

/// Lifecycle state for ambulance GPS tracking.
enum LocationStateStatus {
  initial,
  checkingPermission,
  permissionDenied,
  permissionDeniedForever,
  serviceDisabled,
  locating,
  ready,
  error,
}

/// Captured geographical coordinates and telemetry for the ambulance unit.
@immutable
class AmbulanceLocation {
  const AmbulanceLocation({
    required this.latitude,
    required this.longitude,
    required this.capturedAt,
    this.accuracyMeters,
    this.altitudeMeters,
    this.headingDegrees,
    this.speedMps,
    this.isMock = false,
  });

  /// Geographic latitude in decimal degrees (-90 to +90).
  final double latitude;

  /// Geographic longitude in decimal degrees (-180 to +180).
  final double longitude;

  /// Estimated horizontal radial accuracy in meters.
  final double? accuracyMeters;

  /// Altitude in meters above mean sea level.
  final double? altitudeMeters;

  /// Direction of travel in degrees (0 to 360).
  final double? headingDegrees;

  /// Ground speed in meters per second.
  final double? speedMps;

  /// Timestamp when coordinates were captured.
  final DateTime capturedAt;

  /// Whether these coordinates originate from a mock/fallback provider.
  final bool isMock;

  /// Formatted coordinates string, e.g. "18.9980, 72.8300".
  String get coordinatesFormatted =>
      '${latitude.toStringAsFixed(4)}, ${longitude.toStringAsFixed(4)}';

  /// Default Mumbai Emergency Dispatch center coordinates (Parel, Central Mumbai).
  static const double defaultMumbaiLat = 18.9980;
  static const double defaultMumbaiLng = 72.8300;

  /// Deterministic Mumbai emergency reference location.
  static AmbulanceLocation get defaultMumbai => AmbulanceLocation(
        latitude: defaultMumbaiLat,
        longitude: defaultMumbaiLng,
        capturedAt: DateTime.now(),
        accuracyMeters: 10.0,
        isMock: true,
      );

  AmbulanceLocation copyWith({
    double? latitude,
    double? longitude,
    DateTime? capturedAt,
    double? accuracyMeters,
    double? altitudeMeters,
    double? headingDegrees,
    double? speedMps,
    bool? isMock,
  }) {
    return AmbulanceLocation(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      capturedAt: capturedAt ?? this.capturedAt,
      accuracyMeters: accuracyMeters ?? this.accuracyMeters,
      altitudeMeters: altitudeMeters ?? this.altitudeMeters,
      headingDegrees: headingDegrees ?? this.headingDegrees,
      speedMps: speedMps ?? this.speedMps,
      isMock: isMock ?? this.isMock,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AmbulanceLocation &&
        other.latitude == latitude &&
        other.longitude == longitude &&
        other.isMock == isMock;
  }

  @override
  int get hashCode => Object.hash(latitude, longitude, isMock);

  @override
  String toString() =>
      'AmbulanceLocation($latitude, $longitude, accuracy: ${accuracyMeters}m, mock: $isMock)';
}
