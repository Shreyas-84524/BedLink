import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../../../../core/config/map_config.dart';
import '../../../../core/errors/app_exception.dart';

/// Single hospital route estimate from OpenRouteService Matrix.
@immutable
class MatrixEstimate {
  const MatrixEstimate({
    required this.distanceKm,
    required this.durationMinutes,
  });

  final double distanceKm;
  final int durationMinutes;

  @override
  String toString() => 'MatrixEstimate(${distanceKm.toStringAsFixed(1)} km, $durationMinutes min)';
}

/// Service querying OpenRouteService (ORS) v2 Matrix API to fetch
/// real road driving distances and ETAs for candidate hospital destinations.
class OrsMatrixService {
  OrsMatrixService({
    required this.config,
    http.Client? client,
  }) : _client = client ?? http.Client();

  final MapConfig config;
  final http.Client _client;

  static const String _matrixEndpoint =
      'https://api.openrouteservice.org/v2/matrix/driving-car';

  /// Fetches real driving distance and ETA matrix from [originLat], [originLng]
  /// to multiple [destinations].
  ///
  /// Destination list contains `(latitude, longitude)` pairs.
  /// Returns a map from destination index to [MatrixEstimate].
  /// Never exposes the API key in logs or error messages.
  Future<Map<int, MatrixEstimate>> getDistancesAndDurations({
    required double originLat,
    required double originLng,
    required List<({double latitude, double longitude})> destinations,
    Duration timeout = const Duration(seconds: 10),
  }) async {
    if (destinations.isEmpty) return const {};

    if (!config.isOrsConfigured) {
      throw const RoutingException(
        'OpenRouteService is not configured (missing ORS_API_KEY)',
        isAuthError: true,
      );
    }

    // Build locations array: index 0 is origin, followed by destinations.
    // Note: ORS requires [longitude, latitude] order!
    final locations = <List<double>>[
      [originLng, originLat],
      ...destinations.map((d) => [d.longitude, d.latitude]),
    ];

    final requestBody = jsonEncode({
      'locations': locations,
      'sources': [0],
      'destinations': List.generate(destinations.length, (i) => i + 1),
      'metrics': ['distance', 'duration'],
    });

    try {
      final response = await _client
          .post(
            Uri.parse(_matrixEndpoint),
            headers: {
              'Authorization': config.orsApiKey,
              'Content-Type': 'application/json; charset=utf-8',
              'Accept': 'application/json',
            },
            body: requestBody,
          )
          .timeout(timeout);

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        return _parseMatrixResponse(decoded, destinations.length);
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
      } else {
        throw RoutingException(
          'OpenRouteService Matrix returned HTTP ${response.statusCode}',
        );
      }
    } on TimeoutException {
      throw const RoutingException('OpenRouteService Matrix request timed out');
    } on http.ClientException catch (e) {
      throw RoutingException('Network connection failed during matrix query', cause: e);
    } on RoutingException {
      rethrow;
    } catch (e) {
      throw RoutingException('Failed to query routing matrix: $e', cause: e);
    }
  }

  Map<int, MatrixEstimate> _parseMatrixResponse(
    Map<String, dynamic> data,
    int expectedDestinations,
  ) {
    final durations = (data['durations'] as List?)?.firstOrNull as List?;
    final distances = (data['distances'] as List?)?.firstOrNull as List?;

    if (durations == null || distances == null) {
      throw const RoutingException('Invalid matrix response structure from ORS');
    }

    final results = <int, MatrixEstimate>{};

    for (var i = 0; i < expectedDestinations; i++) {
      if (i >= durations.length || i >= distances.length) break;

      final durationVal = durations[i];
      final distanceVal = distances[i];

      if (durationVal == null || distanceVal == null) {
        // Destination was unreachable / no route found
        continue;
      }

      final durationSec = (durationVal as num).toDouble();
      final distanceMeters = (distanceVal as num).toDouble();

      // Convert seconds to minutes (minimum 1 min, max 180 min)
      final durationMin = (durationSec / 60.0).round().clamp(1, 180);
      // Convert meters to km
      final distanceKm = double.parse((distanceMeters / 1000.0).toStringAsFixed(1));

      results[i] = MatrixEstimate(
        distanceKm: distanceKm,
        durationMinutes: durationMin,
      );
    }

    return results;
  }
}

/// Global provider for OrsMatrixService.
final orsMatrixServiceProvider = Provider<OrsMatrixService>((ref) {
  final config = ref.watch(mapConfigProvider);
  return OrsMatrixService(config: config);
});
