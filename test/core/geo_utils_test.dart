import 'package:flutter_test/flutter_test.dart';
import 'package:bedlink/core/utils/geo_utils.dart';

void main() {
  group('GeoUtils Haversine Formula Tests', () {
    test('Distance between identical coordinates is 0.0 km', () {
      final d = GeoUtils.haversineDistanceKm(18.9980, 72.8300, 18.9980, 72.8300);
      expect(d, equals(0.0));
    });

    test('Distance between KEM and Hinduja hospitals matches realistic Mumbai distance (~3.8 km)', () {
      // KEM Hospital: 18.9986, 72.8427
      // Hinduja Hospital: 19.0330, 72.8384
      final d = GeoUtils.haversineDistanceKm(18.9986, 72.8427, 19.0330, 72.8384);
      expect(d, closeTo(3.85, 0.2));
    });

    test('Distance between Mumbai and Pune is approximately 115-125 km', () {
      final d = GeoUtils.haversineDistanceKm(18.9980, 72.8300, 18.5204, 73.8567);
      expect(d, greaterThan(110.0));
      expect(d, lessThan(130.0));
    });

    test('Returns double.infinity for invalid coordinates without crashing', () {
      expect(GeoUtils.haversineDistanceKm(double.nan, 72.83, 19.0, 72.8), equals(double.infinity));
      expect(GeoUtils.haversineDistanceKm(18.9, 72.83, 95.0, 72.8), equals(double.infinity));
      expect(GeoUtils.haversineDistanceKm(18.9, 200.0, 19.0, 72.8), equals(double.infinity));
    });
  });

  group('GeoUtils Coordinate Validation Tests', () {
    test('Validates legitimate geographic coordinates', () {
      expect(GeoUtils.isValidCoordinate(18.9980, 72.8300), isTrue);
      expect(GeoUtils.isValidCoordinate(0.0, 0.0), isTrue);
      expect(GeoUtils.isValidCoordinate(-45.0, -120.0), isTrue);
      expect(GeoUtils.isValidCoordinate(90.0, 180.0), isTrue);
      expect(GeoUtils.isValidCoordinate(-90.0, -180.0), isTrue);
    });

    test('Rejects null, NaN, Infinite, and out-of-range coordinates', () {
      expect(GeoUtils.isValidCoordinate(null, 72.8300), isFalse);
      expect(GeoUtils.isValidCoordinate(18.9980, null), isFalse);
      expect(GeoUtils.isValidCoordinate(double.nan, 72.8300), isFalse);
      expect(GeoUtils.isValidCoordinate(18.9980, double.infinity), isFalse);
      expect(GeoUtils.isValidCoordinate(90.01, 72.8300), isFalse);
      expect(GeoUtils.isValidCoordinate(-90.01, 72.8300), isFalse);
      expect(GeoUtils.isValidCoordinate(18.9980, 180.01), isFalse);
      expect(GeoUtils.isValidCoordinate(18.9980, -180.01), isFalse);
    });
  });

  group('GeoUtils formatDistance Tests', () {
    test('Formats distance under 1 km as meters', () {
      expect(GeoUtils.formatDistance(0.45), equals('450 m'));
      expect(GeoUtils.formatDistance(0.08), equals('80 m'));
      expect(GeoUtils.formatDistance(0.999), equals('999 m'));
    });

    test('Formats distance 1 km and above as kilometers with 1 decimal place', () {
      expect(GeoUtils.formatDistance(1.0), equals('1.0 km'));
      expect(GeoUtils.formatDistance(3.82), equals('3.8 km'));
      expect(GeoUtils.formatDistance(14.96), equals('15.0 km'));
    });

    test('Handles invalid numbers gracefully', () {
      expect(GeoUtils.formatDistance(double.nan), equals('Unknown dist'));
      expect(GeoUtils.formatDistance(double.infinity), equals('Unknown dist'));
    });
  });
}
