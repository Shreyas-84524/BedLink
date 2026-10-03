import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../../../../core/config/map_config.dart';
import '../../../../core/errors/app_exception.dart';
import '../../domain/models/navigation_step.dart';

/// Decoded route geometry point (latitude, longitude).
typedef RoutePoint = ({double latitude, double longitude});

/// Parsed route result from OpenRouteService Directions.
@immutable
class OrsRouteResult {
  const OrsRouteResult({
    required this.coordinates,
    required this.totalDistanceKm,
    required this.totalDurationMinutes,
    required this.instructions,
  });

  /// Ordered path coordinates for polyline rendering.
  final List<RoutePoint> coordinates;

  /// Total road distance in kilometers.
  final double totalDistanceKm;

  /// Total transit time in minutes.
  final int totalDurationMinutes;

  /// Ordered turn-by-turn navigation instructions.
  final List<MockRouteInstruction> instructions;
}

/// Service querying OpenRouteService (ORS) v2 Directions API (GeoJSON)
/// to fetch real route geometries and turn-by-turn guidance for the active destination.
class OrsDirectionsService {
  OrsDirectionsService({
    required this.config,
    http.Client? client,
  }) : _client = client ?? http.Client();

  final MapConfig config;
  final http.Client _client;

  static const String _directionsEndpoint =
      'https://api.openrouteservice.org/v2/directions/driving-car/geojson';

  /// Fetches real driving route from [originLat], [originLng] to [destLat], [destLng].
  ///
  /// Returns [OrsRouteResult] containing polyline coordinates, driving distance,
  /// duration, and turn-by-turn instructions.
  /// Never exposes the API key in logs or error messages.
  Future<OrsRouteResult> getDirections({
    required double originLat,
    required double originLng,
    required double destLat,
    required double destLng,
    Duration timeout = const Duration(seconds: 12),
  }) async {
    if (!config.isOrsConfigured) {
      throw const RoutingException(
        'OpenRouteService is not configured (missing ORS_API_KEY)',
        isAuthError: true,
      );
    }

    // ORS GeoJSON endpoint expects coordinates as [longitude, latitude]!
    final requestBody = jsonEncode({
      'coordinates': [
        [originLng, originLat],
        [destLng, destLat],
      ],
      'instructions': true,
      'preference': 'fastest',
    });

    try {
      final response = await _client
          .post(
            Uri.parse(_directionsEndpoint),
            headers: {
              'Authorization': config.orsApiKey,
              'Content-Type': 'application/json; charset=utf-8',
              'Accept': 'application/json, application/geo+json',
            },
            body: requestBody,
          )
          .timeout(timeout);

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        return _parseDirectionsResponse(decoded);
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        throw const RoutingException(
          'OpenRouteService authentication failed (invalid or unauthorized key)',
          isAuthError: true,
        );
      } else if (response.statusCode == 429) {
        throw const RoutingException(
          'OpenRouteService rate limit exceeded',
          isRateLimited: true,
        );
      } else if (response.statusCode == 404 || response.statusCode == 400) {
        throw const RoutingException(
          'No drivable route found to destination hospital',
          isNoRoute: true,
        );
      } else {
        throw RoutingException(
          'OpenRouteService Directions returned HTTP ${response.statusCode}',
        );
      }
    } on TimeoutException {
      throw const RoutingException('OpenRouteService Directions request timed out');
    } on http.ClientException catch (e) {
      throw RoutingException('Network connection failed during directions query', cause: e);
    } on RoutingException {
      rethrow;
    } catch (e) {
      throw RoutingException('Failed to query routing directions: $e', cause: e);
    }
  }

  OrsRouteResult _parseDirectionsResponse(Map<String, dynamic> data) {
    final features = data['features'] as List?;
    if (features == null || features.isEmpty) {
      throw const RoutingException('No features found in directions response');
    }

    final feature = features.first as Map<String, dynamic>;
    final geometry = feature['geometry'] as Map<String, dynamic>?;
    final properties = feature['properties'] as Map<String, dynamic>?;

    if (geometry == null || properties == null) {
      throw const RoutingException('Malformed directions GeoJSON from ORS');
    }

    // 1. Parse route coordinates from GeoJSON LineString [longitude, latitude]
    final rawCoords = (geometry['coordinates'] as List?) ?? [];
    final coordinates = <RoutePoint>[];
    for (final coord in rawCoords) {
      if (coord is List && coord.length >= 2) {
        final lng = (coord[0] as num).toDouble();
        final lat = (coord[1] as num).toDouble();
        coordinates.add((latitude: lat, longitude: lng));
      }
    }

    // 2. Parse summary metrics
    final summary = properties['summary'] as Map<String, dynamic>? ?? {};
    final totalDistanceMeters = (summary['distance'] as num?)?.toDouble() ?? 0.0;
    final totalDurationSeconds = (summary['duration'] as num?)?.toDouble() ?? 0.0;

    final totalDistanceKm = double.parse((totalDistanceMeters / 1000.0).toStringAsFixed(1));
    final totalDurationMinutes = (totalDurationSeconds / 60.0).round().clamp(1, 180);

    // 3. Parse turn-by-turn instruction steps
    final segments = properties['segments'] as List?;
    final instructions = <MockRouteInstruction>[];

    if (segments != null && segments.isNotEmpty) {
      final firstSegment = segments.first as Map<String, dynamic>;
      final rawSteps = firstSegment['steps'] as List?;

      if (rawSteps != null) {
        for (var i = 0; i < rawSteps.length; i++) {
          final step = rawSteps[i] as Map<String, dynamic>;
          final dist = ((step['distance'] as num?) ?? 0).round();
          final instText = (step['instruction'] as String?) ?? 'Proceed along route';
          final name = (step['name'] as String?) ?? 'Main Road';
          final type = (step['type'] as int?) ?? -1;

          final maneuver = _mapManeuverType(type, i, rawSteps.length);

          instructions.add(MockRouteInstruction(
            id: 'ors_step_$i',
            maneuver: maneuver,
            instruction: instText,
            distanceMeters: dist,
            roadName: name.isNotEmpty ? name : 'Main Road',
          ));
        }
      }
    }

    return OrsRouteResult(
      coordinates: coordinates,
      totalDistanceKm: totalDistanceKm,
      totalDurationMinutes: totalDurationMinutes,
      instructions: instructions.isNotEmpty
          ? instructions
          : [
              MockRouteInstruction(
                id: 'step_default',
                maneuver: NavigationManeuver.depart,
                instruction: 'Proceed toward destination hospital',
                distanceMeters: (totalDistanceKm * 1000).toInt(),
                roadName: 'Main Road',
              ),
            ],
    );
  }

  /// Maps OpenRouteService numeric maneuver type to BedLink [NavigationManeuver].
  NavigationManeuver _mapManeuverType(int type, int index, int totalSteps) {
    if (index == 0) return NavigationManeuver.depart;
    if (index == totalSteps - 1 || type == 10) return NavigationManeuver.arriveDestination;

    switch (type) {
      case 0:
        return NavigationManeuver.turnLeft;
      case 1:
        return NavigationManeuver.turnRight;
      case 2:
        return NavigationManeuver.slightLeft;
      case 3:
        return NavigationManeuver.slightRight;
      case 6:
        return NavigationManeuver.continueStraight;
      case 7:
        return NavigationManeuver.depart;
      case 10:
        return NavigationManeuver.arriveDestination;
      case 11:
        return NavigationManeuver.depart;
      case 12:
      case 13:
        return NavigationManeuver.uTurn;
      default:
        return NavigationManeuver.continueStraight;
    }
  }
}

/// Global provider for OrsDirectionsService.
final orsDirectionsServiceProvider = Provider<OrsDirectionsService>((ref) {
  final config = ref.watch(mapConfigProvider);
  return OrsDirectionsService(config: config);
});
