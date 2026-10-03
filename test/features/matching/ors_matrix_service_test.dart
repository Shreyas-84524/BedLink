import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:bedlink/core/config/map_config.dart';
import 'package:bedlink/core/errors/app_exception.dart';
import 'package:bedlink/features/matching/data/services/ors_matrix_service.dart';

void main() {
  group('OrsMatrixService Unit Tests', () {
    test('throws RoutingException when ORS_API_KEY is not configured', () async {
      final service = OrsMatrixService(
        config: MapConfig.mock(),
      );

      expect(
        () => service.getDistancesAndDurations(
          originLat: 18.9950,
          originLng: 72.8250,
          destinations: [(latitude: 18.9980, longitude: 72.8300)],
        ),
        throwsA(isA<RoutingException>().having((e) => e.isAuthError, 'isAuthError', isTrue)),
      );
    });

    test('correctly constructs request body with [lng, lat] coordinate order and parses 200 response', () async {
      String? capturedBody;
      Map<String, String>? capturedHeaders;

      final mockClient = MockClient((request) async {
        capturedBody = request.body;
        capturedHeaders = request.headers;

        final responseJson = jsonEncode({
          'durations': [
            [480.0, 720.0],
          ],
          'distances': [
            [3200.0, 5400.0],
          ],
        });

        return http.Response(responseJson, 200, headers: {'content-type': 'application/json'});
      });

      final service = OrsMatrixService(
        config: MapConfig.custom(orsApiKey: 'test_ors_key'),
        client: mockClient,
      );

      final results = await service.getDistancesAndDurations(
        originLat: 18.9950,
        originLng: 72.8250,
        destinations: [
          (latitude: 18.9980, longitude: 72.8300),
          (latitude: 19.0100, longitude: 72.8400),
        ],
      );

      // Verify coordinate order: [longitude, latitude]
      expect(capturedBody, isNotNull);
      final decodedBody = jsonDecode(capturedBody!) as Map<String, dynamic>;
      final locations = (decodedBody['locations'] as List<dynamic>).cast<List<dynamic>>();
      expect(locations[0], equals([72.8250, 18.9950])); // ambulance origin
      expect(locations[1], equals([72.8300, 18.9980])); // destination 1
      expect(locations[2], equals([72.8400, 19.0100])); // destination 2

      // Verify headers
      expect(capturedHeaders?['Authorization'], equals('test_ors_key'));

      // Verify parsed output
      expect(results.length, equals(2));
      expect(results[0]?.durationMinutes, equals(8)); // 480 sec = 8 min
      expect(results[0]?.distanceKm, equals(3.2)); // 3200 m = 3.2 km
      expect(results[1]?.durationMinutes, equals(12)); // 720 sec = 12 min
      expect(results[1]?.distanceKm, equals(5.4)); // 5400 m = 5.4 km
    });

    test('handles 401/403 authorization error safely without leaking key', () async {
      final mockClient = MockClient((request) async {
        return http.Response('{"error": "Unauthorized"}', 401);
      });

      final service = OrsMatrixService(
        config: MapConfig.custom(orsApiKey: 'secret_invalid_key'),
        client: mockClient,
      );

      try {
        await service.getDistancesAndDurations(
          originLat: 18.9950,
          originLng: 72.8250,
          destinations: [(latitude: 18.9980, longitude: 72.8300)],
        );
        fail('Should have thrown RoutingException');
      } on RoutingException catch (e) {
        expect(e.isAuthError, isTrue);
        expect(e.message, contains('authentication failed'));
        expect(e.message.contains('secret_invalid_key'), isFalse);
      }
    });

    test('handles 429 rate limit safely', () async {
      final mockClient = MockClient((request) async {
        return http.Response('{"error": "Rate limit exceeded"}', 429);
      });

      final service = OrsMatrixService(
        config: MapConfig.custom(orsApiKey: 'valid_key'),
        client: mockClient,
      );

      expect(
        () => service.getDistancesAndDurations(
          originLat: 18.9950,
          originLng: 72.8250,
          destinations: [(latitude: 18.9980, longitude: 72.8300)],
        ),
        throwsA(isA<RoutingException>().having((e) => e.isRateLimited, 'isRateLimited', isTrue)),
      );
    });

    test('handles unreachable/null destination in matrix response', () async {
      final mockClient = MockClient((request) async {
        final responseJson = jsonEncode({
          'durations': [
            [null, 600.0],
          ],
          'distances': [
            [null, 4000.0],
          ],
        });

        return http.Response(responseJson, 200, headers: {'content-type': 'application/json'});
      });

      final service = OrsMatrixService(
        config: MapConfig.custom(orsApiKey: 'valid_key'),
        client: mockClient,
      );

      final results = await service.getDistancesAndDurations(
        originLat: 18.9950,
        originLng: 72.8250,
        destinations: [
          (latitude: 18.9980, longitude: 72.8300),
          (latitude: 19.0100, longitude: 72.8400),
        ],
      );

      expect(results.containsKey(0), isFalse);
      expect(results[1]?.durationMinutes, equals(10));
      expect(results[1]?.distanceKm, equals(4.0));
    });
  });
}
