import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:bedlink/core/config/map_config.dart';
import 'package:bedlink/core/errors/app_exception.dart';
import 'package:bedlink/features/navigation/data/services/ors_directions_service.dart';
import 'package:bedlink/features/navigation/domain/models/navigation_step.dart';

void main() {
  group('OrsDirectionsService Unit Tests', () {
    test('throws RoutingException when ORS_API_KEY is not configured', () async {
      final service = OrsDirectionsService(
        config: MapConfig.mock(),
      );

      expect(
        () => service.getDirections(
          originLat: 18.9950,
          originLng: 72.8250,
          destLat: 18.9980,
          destLng: 72.8300,
        ),
        throwsA(isA<RoutingException>().having((e) => e.isAuthError, 'isAuthError', isTrue)),
      );
    });

    test('correctly constructs GeoJSON request and parses coordinates, summary, and instructions', () async {
      String? capturedBody;
      Map<String, String>? capturedHeaders;

      final mockClient = MockClient((request) async {
        capturedBody = request.body;
        capturedHeaders = request.headers;

        final responseJson = jsonEncode({
          'type': 'FeatureCollection',
          'features': [
            {
              'type': 'Feature',
              'properties': {
                'summary': {
                  'distance': 4200.0,
                  'duration': 660.0,
                },
                'segments': [
                  {
                    'distance': 4200.0,
                    'duration': 660.0,
                    'steps': [
                      {
                        'distance': 1200.0,
                        'duration': 180.0,
                        'type': 11,
                        'instruction': 'Head north on Senapati Bapat Marg',
                        'name': 'Senapati Bapat Marg',
                      },
                      {
                        'distance': 800.0,
                        'duration': 120.0,
                        'type': 1,
                        'instruction': 'Turn right onto Tilak Bridge',
                        'name': 'Tilak Bridge',
                      },
                      {
                        'distance': 2200.0,
                        'duration': 360.0,
                        'type': 10,
                        'instruction': 'Arrive at KEM Hospital',
                        'name': 'Acharya Donde Marg',
                      },
                    ],
                  }
                ],
              },
              'geometry': {
                'type': 'LineString',
                'coordinates': [
                  [72.8250, 18.9950],
                  [72.8270, 18.9960],
                  [72.8300, 18.9980],
                ],
              },
            }
          ],
        });

        return http.Response(responseJson, 200, headers: {'content-type': 'application/json'});
      });

      final service = OrsDirectionsService(
        config: MapConfig.custom(orsApiKey: 'test_ors_key'),
        client: mockClient,
      );

      final result = await service.getDirections(
        originLat: 18.9950,
        originLng: 72.8250,
        destLat: 18.9980,
        destLng: 72.8300,
      );

      // Verify request payload: [longitude, latitude]
      expect(capturedBody, isNotNull);
      final decodedBody = jsonDecode(capturedBody!) as Map<String, dynamic>;
      final coords = (decodedBody['coordinates'] as List<dynamic>).cast<List<dynamic>>();
      expect(coords[0], equals([72.8250, 18.9950]));
      expect(coords[1], equals([72.8300, 18.9980]));

      // Verify headers
      expect(capturedHeaders?['Authorization'], equals('test_ors_key'));

      // Verify parsed metrics
      expect(result.totalDistanceKm, equals(4.2)); // 4200m = 4.2 km
      expect(result.totalDurationMinutes, equals(11)); // 660 sec = 11 min

      // Verify parsed coordinates (mapped to latitude, longitude)
      expect(result.coordinates.length, equals(3));
      expect(result.coordinates[0].latitude, equals(18.9950));
      expect(result.coordinates[0].longitude, equals(72.8250));
      expect(result.coordinates[2].latitude, equals(18.9980));
      expect(result.coordinates[2].longitude, equals(72.8300));

      // Verify instructions
      expect(result.instructions.length, equals(3));
      expect(result.instructions[0].maneuver, equals(NavigationManeuver.depart));
      expect(result.instructions[0].instruction, equals('Head north on Senapati Bapat Marg'));
      expect(result.instructions[1].maneuver, equals(NavigationManeuver.turnRight));
      expect(result.instructions[2].maneuver, equals(NavigationManeuver.arriveDestination));
    });

    test('handles 404/400 no route error with typed exception', () async {
      final mockClient = MockClient((request) async {
        return http.Response('{"error": "Could not find point"}', 404);
      });

      final service = OrsDirectionsService(
        config: MapConfig.custom(orsApiKey: 'test_key'),
        client: mockClient,
      );

      expect(
        () => service.getDirections(
          originLat: 0.0,
          originLng: 0.0,
          destLat: 1.0,
          destLng: 1.0,
        ),
        throwsA(isA<RoutingException>().having((e) => e.isNoRoute, 'isNoRoute', isTrue)),
      );
    });

    test('handles 401/403 authorization error safely without exposing key', () async {
      final mockClient = MockClient((request) async {
        return http.Response('{"error": "Unauthorized"}', 401);
      });

      final service = OrsDirectionsService(
        config: MapConfig.custom(orsApiKey: 'sensitive_key_value'),
        client: mockClient,
      );

      try {
        await service.getDirections(
          originLat: 18.9950,
          originLng: 72.8250,
          destLat: 18.9980,
          destLng: 72.8300,
        );
        fail('Expected RoutingException');
      } on RoutingException catch (e) {
        expect(e.isAuthError, isTrue);
        expect(e.message.contains('sensitive_key_value'), isFalse);
      }
    });
  });
}
