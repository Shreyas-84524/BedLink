import 'dart:math' as math;

/// Utility class for geographic coordinates validation, Haversine straight-line distance,
/// and localized distance formatting.
class GeoUtils {
  const GeoUtils._();

  /// Mean radius of the Earth in kilometers (WGS-84 spherical approximation).
  static const double earthRadiusKm = 6371.0;

  /// Calculates the straight-line great-circle distance between two geographic coordinates
  /// using the Haversine formula.
  ///
  /// Returns distance in kilometers (km).
  /// If coordinates are identical or invalid, handles gracefully without NaN/Infinity.
  static double haversineDistanceKm(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    if (!isValidCoordinate(lat1, lon1) || !isValidCoordinate(lat2, lon2)) {
      return double.infinity;
    }

    if (lat1 == lat2 && lon1 == lon2) {
      return 0.0;
    }

    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);

    final radLat1 = _toRadians(lat1);
    final radLat2 = _toRadians(lat2);

    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(radLat1) * math.cos(radLat2) * math.sin(dLon / 2) * math.sin(dLon / 2);

    final clampedA = a.clamp(0.0, 1.0);
    final c = 2 * math.atan2(math.sqrt(clampedA), math.sqrt(1 - clampedA));

    return earthRadiusKm * c;
  }

  /// Validates whether a given latitude and longitude pair represents a legitimate
  /// decimal degrees coordinate on Earth.
  static bool isValidCoordinate(double? lat, double? lon) {
    if (lat == null || lon == null) return false;
    if (lat.isNaN || lon.isNaN || lat.isInfinite || lon.isInfinite) return false;
    if (lat < -90.0 || lat > 90.0) return false;
    if (lon < -180.0 || lon > 180.0) return false;
    return true;
  }

  /// Converts decimal degrees to radians.
  static double _toRadians(double degrees) => degrees * (math.pi / 180.0);

  /// Formats distance into a human-readable string.
  /// E.g.:
  /// - 0.45 km -> "450 m"
  /// - 3.82 km -> "3.8 km"
  static String formatDistance(double km) {
    if (km.isNaN || km.isInfinite) return 'Unknown dist';
    if (km < 1.0) {
      final meters = (km * 1000).round();
      return '$meters m';
    }
    return '${km.toStringAsFixed(1)} km';
  }
}
