import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:bedlink/core/config/map_config.dart';
import 'package:bedlink/core/theme/semantic_tokens.dart';
import 'package:bedlink/features/hospital/domain/repositories/hospital_repository.dart';
import 'package:bedlink/features/matching/data/mock_hospital_data.dart';
import 'package:bedlink/features/matching/data/repositories/supabase_hospital_discovery_repository.dart';
import 'package:bedlink/features/matching/data/services/ors_matrix_service.dart';
import 'package:bedlink/features/matching/domain/models/hospital_match.dart';
import 'package:bedlink/features/matching/presentation/providers/selected_hospital_provider.dart';
import 'package:bedlink/features/navigation/data/services/ors_directions_service.dart';
import 'package:bedlink/features/navigation/presentation/providers/navigation_state_provider.dart';
import 'package:bedlink/features/navigation/presentation/screens/navigation_screen.dart';
import 'package:bedlink/features/navigation/presentation/widgets/bedlink_route_map.dart';
import 'package:bedlink/features/navigation/presentation/widgets/mock_route_map.dart';
import 'package:bedlink/features/reservation/presentation/providers/hold_timer_provider.dart';

/// Test implementation of HospitalRepository returning predictable Mumbai facilities.
class _TestHospitalRepository implements HospitalRepository {
  _TestHospitalRepository(this.hospitals);

  final List<HospitalMatch> hospitals;

  @override
  bool get isRealBackend => true;

  @override
  String get dataSourceName => 'TEST_BACKEND';

  @override
  Future<List<HospitalMatch>> getHospitals({bool activeOnly = true}) async => hospitals;

  @override
  Future<HospitalMatch?> getHospitalById(String id) async =>
      hospitals.where((h) => h.id == id).firstOrNull;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    HoldTimerNotifier.disablePeriodicTickerForTesting = true;
  });

  tearDown(() {
    HoldTimerNotifier.disablePeriodicTickerForTesting = false;
  });

  group('Phase 14.1 — MapConfig Integration Tests', () {
    test('MapConfig.fromEnvironment parses configuration safely', () {
      final config = MapConfig.fromEnvironment();
      expect(config, isNotNull);
      expect(config.isMapTilerConfigured, isA<bool>());
      expect(config.isOrsConfigured, isA<bool>());
    });

    test('MapConfig.mock creates offline/test configuration', () {
      final config = MapConfig.mock();
      expect(config.isMapTilerConfigured, isFalse);
      expect(config.isOrsConfigured, isFalse);
      expect(config.canRenderMapLibre, isFalse);
      expect(config.mapTilerStyleUrl, isEmpty);
    });

    test('MapConfig.custom provides valid style URL when key is set', () {
      final config = MapConfig.custom(
        maptilerApiKey: 'test_maptiler_key',
        orsApiKey: 'test_ors_key',
      );
      expect(config.isMapTilerConfigured, isTrue);
      expect(config.isOrsConfigured, isTrue);
      expect(config.mapTilerStyleUrl, contains('https://api.maptiler.com/maps/streets-v2/style.json?key=test_maptiler_key'));
    });
  });

  group('Phase 14.3, 14.4 & 14.5 — ORS Matrix & Candidate Ranking Integration', () {
    test('matrix response correctly updates candidate road ETA, distance, and re-ranks', () async {
      final testHospitals = [
        const HospitalMatch(
          id: 'hosp_a',
          name: 'Hospital A (Closer Straight-Line, Slower Road)',
          address: 'Address A',
          area: 'Area A',
          latitude: 18.9960,
          longitude: 72.8260, // ~0.2 km straight-line
          emergencyPhone: '1234567890',
          distanceKm: 0.2,
          etaMinutes: 10,
          updatedMinutesAgo: 2,
          freshnessState: FreshnessState.fresh,
          loadState: HospitalLoadState.low,
          occupancyRate: 50,
          rank: 1,
          recommendationTier: RecommendationTier.compatible,
          matchScore: 80.0,
          availableBedCounts: {'icu_bed': 5},
          supportedCapabilities: {'icu_care', 'emergency_care'},
          routeSummary: 'Corridor A',
        ),
        const HospitalMatch(
          id: 'hosp_b',
          name: 'Hospital B (Further Straight-Line, Faster Road)',
          address: 'Address B',
          area: 'Area B',
          latitude: 19.0100,
          longitude: 72.8350, // ~1.8 km straight-line
          emergencyPhone: '0987654321',
          distanceKm: 1.8,
          etaMinutes: 12,
          updatedMinutesAgo: 2,
          freshnessState: FreshnessState.fresh,
          loadState: HospitalLoadState.low,
          occupancyRate: 50,
          rank: 2,
          recommendationTier: RecommendationTier.compatible,
          matchScore: 80.0,
          availableBedCounts: {'icu_bed': 5},
          supportedCapabilities: {'icu_care', 'emergency_care'},
          routeSummary: 'Corridor B',
        ),
      ];

      // Mock ORS Matrix returning:
      // Hospital A -> 15 min road time (congestion)
      // Hospital B -> 7 min road time (highway corridor)
      final mockHttpClient = MockClient((request) async {
        final res = jsonEncode({
          'durations': [
            [900.0, 420.0], // Hosp A: 900s = 15m; Hosp B: 420s = 7m
          ],
          'distances': [
            [2500.0, 3100.0], // Hosp A: 2.5 km; Hosp B: 3.1 km
          ],
        });
        return http.Response(res, 200, headers: {'content-type': 'application/json'});
      });

      final matrixService = OrsMatrixService(
        config: MapConfig.custom(orsApiKey: 'test_ors_key'),
        client: mockHttpClient,
      );

      final discoveryRepo = SupabaseHospitalDiscoveryRepository(
        hospitalRepository: _TestHospitalRepository(testHospitals),
        matrixService: matrixService,
      );

      final result = await discoveryRepo.discoverHospitals(
        latitude: 18.9950,
        longitude: 72.8250,
      );

      expect(result.matches.length, equals(2));
      expect(result.isRealRoutingUsed, isTrue);

      // Hospital B is ranked #1 because its road ETA (7 min) is faster than Hospital A (15 min)
      final topRank = result.matches.first;
      expect(topRank.id, equals('hosp_b'));
      expect(topRank.rank, equals(1));
      expect(topRank.etaMinutes, equals(7));
      expect(topRank.distanceKm, equals(3.1));
      expect(topRank.isRealRoadRoute, isTrue);
      expect(topRank.recommendationTier, equals(RecommendationTier.topMatch));

      // Hospital A is ranked #2
      final secondRank = result.matches[1];
      expect(secondRank.id, equals('hosp_a'));
      expect(secondRank.rank, equals(2));
      expect(secondRank.etaMinutes, equals(15));
      expect(secondRank.distanceKm, equals(2.5));
      expect(secondRank.isRealRoadRoute, isTrue);
    });

    test('matrix failure falls back to straight-line distance safely without throwing', () async {
      final testHospitals = [
        const HospitalMatch(
          id: 'hosp_a',
          name: 'Hospital A',
          address: 'Address A',
          area: 'Area A',
          latitude: 18.9960,
          longitude: 72.8260,
          emergencyPhone: '1234567890',
          distanceKm: 0.2,
          etaMinutes: 5,
          updatedMinutesAgo: 2,
          freshnessState: FreshnessState.fresh,
          loadState: HospitalLoadState.low,
          occupancyRate: 50,
          rank: 1,
          recommendationTier: RecommendationTier.compatible,
          matchScore: 80.0,
          availableBedCounts: {'icu_bed': 5},
          supportedCapabilities: {'icu_care', 'emergency_care'},
          routeSummary: 'Corridor A',
        ),
      ];

      // Matrix returns 500 error
      final mockHttpClient = MockClient((request) async {
        return http.Response('Server Error', 500);
      });

      final matrixService = OrsMatrixService(
        config: MapConfig.custom(orsApiKey: 'test_ors_key'),
        client: mockHttpClient,
      );

      final discoveryRepo = SupabaseHospitalDiscoveryRepository(
        hospitalRepository: _TestHospitalRepository(testHospitals),
        matrixService: matrixService,
      );

      final result = await discoveryRepo.discoverHospitals(
        latitude: 18.9950,
        longitude: 72.8250,
      );

      expect(result.matches.isNotEmpty, isTrue);
      expect(result.isRealRoutingUsed, isFalse);
      expect(result.routingErrorMessage, isNotNull);
      expect(result.matches.first.id, equals('hosp_a'));
    });
  });

  group('Phase 14.6 & 14.7 — ORS Directions & Real Route Navigation Integration', () {
    test('NavigationStateNotifier loads real directions and updates progress state', () async {
      final mockHttpClient = MockClient((request) async {
        final res = jsonEncode({
          'type': 'FeatureCollection',
          'features': [
            {
              'type': 'Feature',
              'properties': {
                'summary': {
                  'distance': 4800.0,
                  'duration': 720.0,
                },
                'segments': [
                  {
                    'distance': 4800.0,
                    'duration': 720.0,
                    'steps': [
                      {
                        'distance': 1500.0,
                        'duration': 200.0,
                        'type': 11,
                        'instruction': 'Head north along arterial corridor',
                        'name': 'Senapati Bapat Marg',
                      },
                      {
                        'distance': 1800.0,
                        'duration': 260.0,
                        'type': 1,
                        'instruction': 'Turn right toward Parel Flyover',
                        'name': 'Tilak Bridge',
                      },
                      {
                        'distance': 1500.0,
                        'duration': 260.0,
                        'type': 10,
                        'instruction': 'Arrive at Emergency Bay',
                        'name': 'Hospital Gate',
                      },
                    ],
                  }
                ],
              },
              'geometry': {
                'type': 'LineString',
                'coordinates': [
                  [72.8250, 18.9950],
                  [72.8280, 18.9970],
                  [72.8300, 18.9990],
                ],
              },
            }
          ],
        });
        return http.Response(res, 200, headers: {'content-type': 'application/json'});
      });

      final directionsService = OrsDirectionsService(
        config: MapConfig.custom(orsApiKey: 'test_ors_key'),
        client: mockHttpClient,
      );

      final container = ProviderContainer(
        overrides: [
          orsDirectionsServiceProvider.overrideWithValue(directionsService),
        ],
      );
      addTearDown(container.dispose);

      container.read(selectedHospitalProvider.notifier).selectHospital(MockHospitalData.kemHospital);

      final notifier = container.read(navigationStateProvider.notifier);
      await notifier.loadRealDirections();

      final navState = container.read(navigationStateProvider);

      expect(navState.isRealRouting, isTrue);
      expect(navState.remainingEtaMinutes, equals(12)); // 720 sec = 12 min
      expect(navState.remainingDistanceKm, equals(4.8)); // 4800 m = 4.8 km
      expect(navState.routeGeometry.length, equals(3));
      expect(navState.routeGeometry.first.latitude, equals(18.9950));
      expect(navState.routeGeometry.last.latitude, equals(18.9990));
      expect(navState.instructions.length, equals(3));
      expect(navState.instructions.first.instruction, contains('Head north'));
    });

    test('directions error sets routingError in state gracefully without breaking navigation', () async {
      final mockHttpClient = MockClient((request) async {
        return http.Response('{"error": "Unauthorized"}', 401);
      });

      final directionsService = OrsDirectionsService(
        config: MapConfig.custom(orsApiKey: 'invalid_key'),
        client: mockHttpClient,
      );

      final container = ProviderContainer(
        overrides: [
          orsDirectionsServiceProvider.overrideWithValue(directionsService),
        ],
      );
      addTearDown(container.dispose);

      container.read(selectedHospitalProvider.notifier).selectHospital(MockHospitalData.kemHospital);

      final notifier = container.read(navigationStateProvider.notifier);
      await notifier.loadRealDirections();

      final navState = container.read(navigationStateProvider);

      expect(navState.isRealRouting, isFalse);
      expect(navState.routingError, isNotNull);
      expect(navState.remainingEtaMinutes, equals(MockHospitalData.kemHospital.etaMinutes));
      expect(navState.instructions.isNotEmpty, isTrue);
    });
  });

  group('Phase 14.2 & 14.7 — BedlinkRouteMap & UI Resilience', () {
    testWidgets('BedlinkRouteMap renders MockRouteMap fallback in test environment', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: BedlinkRouteMap(
                routeProgress: 0.4,
                destinationName: 'Lilavati Hospital',
                ambulanceLatitude: 18.9950,
                ambulanceLongitude: 72.8250,
                destinationLatitude: 18.9980,
                destinationLongitude: 72.8300,
                isRealRouting: true,
              ),
            ),
          ),
        ),
      );

      expect(find.byType(MockRouteMap), findsOneWidget);
      expect(find.textContaining('Lilavati Hospital'), findsOneWidget);
    });

    testWidgets('NavigationScreen renders BedlinkRouteMap and handles routing error without crash', (tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final container = ProviderContainer(
        overrides: [
          mapConfigProvider.overrideWithValue(MapConfig.mock()),
        ],
      );
      addTearDown(container.dispose);

      container.read(selectedHospitalProvider.notifier).selectHospital(MockHospitalData.kemHospital);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: NavigationScreen(),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(BedlinkRouteMap), findsOneWidget);
      expect(find.textContaining(MockHospitalData.kemHospital.name), findsWidgets);
      expect(find.text('TRANSIT NAVIGATION'), findsOneWidget);
    });

    testWidgets('NavigationScreen renders without overflow on 320dp width', (tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final container = ProviderContainer(
        overrides: [
          mapConfigProvider.overrideWithValue(MapConfig.mock()),
        ],
      );
      addTearDown(container.dispose);

      container.read(selectedHospitalProvider.notifier).selectHospital(MockHospitalData.kemHospital);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: NavigationScreen(),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(tester.takeException(), isNull);
    });
  });
}
